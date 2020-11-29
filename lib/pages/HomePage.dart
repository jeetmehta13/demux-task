import 'package:demux_task/utils/adaptiveWidgets.dart';
import 'package:demux_task/widgets/ErrorCard.dart';
import 'package:demux_task/widgets/QuestionCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:demux_task/utils/misc.dart' as misc;

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  bool needsRefresh = false;

  final dbRef = FirebaseDatabase.instance.reference();

  List questions;
  List currentSet = [];
  int currQuestion = 0;

  ScrollController _scrollController = ScrollController();

  var selectedFrequencyRange = RangeValues(0.0, 100.0);
  List<bool> difficultySelected = [true, false, false, false];
  bool trending = false;
  List<bool> jobTypeSelected = [true, false, false];
  List<bool> testTypeSelected = [true, false, false];
  String selectedCompany = 'All';
  String selectedCollege = 'All';
  List<String> collegesAvailable = ['All'];
  List<String> companiesAvailable = ['All'];
  bool completed = false;

  Map<int, String> jobTypeyMap = {
    1: 'Internship',
    2: 'Placement',
  };

  Map<int, String> testTypeMap = {
    1: 'Online',
    2: 'Interview',
  };

  @override
  bool get wantKeepAlive => needsRefresh == null ? true : !needsRefresh;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          currentSet.length < questions.length) {
        await _addToSet();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AdaptivePageScaffold(
        hideAppBar: false,
        title: 'Questions',
        actions: [
          (misc.isIOS())
              ? FlatButton(
                  onPressed: () => _showFilter(), child: Text('Filter'), padding: EdgeInsets.zero,)
              : IconButton(
                  icon: Icon(Icons.filter_list_outlined),
                  onPressed: () => _showFilter())
        ],
        child: (questions != null)
            ? buildMainWidget()
            : FutureBuilder(
                future: _getData(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.active:
                    case ConnectionState.waiting:
                      return Center(
                        child: AdaptiveProgressIndicator(),
                      );
                    case ConnectionState.done:
                      {
                        if (snapshot.hasError) {
                          return RefreshIndicator(
                              child: ErrorCard(
                                  'Some Error Occured', Icons.error_outline),
                              onRefresh: _onRefresh);
                        } else if (!snapshot.hasData)
                          return Center(
                            child: AdaptiveProgressIndicator(),
                          );
                        if (snapshot.data.length <= 0) {
                          return RefreshIndicator(
                              child: ErrorCard(
                                  'No Questions Found!', Icons.error_outline),
                              onRefresh: _onRefresh);
                        }
                        questions = snapshot.data;

                        return buildMainWidget();
                      }
                    default:
                      return RefreshIndicator(
                          child: ErrorCard(
                              'Some Error Occured', Icons.error_outline),
                          onRefresh: _onRefresh);
                  }
                }));
  }

  Widget buildMainWidget() {
    if (questions == null || questions.length < 0) {
      return RefreshIndicator(
          child: ErrorCard('Some Error Occured', Icons.error_outline),
          onRefresh: _onRefresh);
    }

    for (var question in questions) {
      currQuestion++;
      if (currentSet.length > 10) {
        break;
      }
      currentSet.add(question);
      if (!difficultySelected[0]) {
        for (var i = 1; i <= 3; i++) {
          if (difficultySelected[i] && question['difficulty'] != i) {
            currentSet.remove(question);
          }
        }
      }
      if (!jobTypeSelected[0]) {
        for (var i = 1; i <= 2; i++) {
          if (jobTypeSelected[i] &&
              !question['job_type'].contains(jobTypeyMap[i])) {
            currentSet.remove(question);
          }
        }
      }
      if (!testTypeSelected[0]) {
        for (var i = 1; i <= 2; i++) {
          if (testTypeSelected[i] &&
              !question['test_type'].contains(testTypeMap[i])) {
            currentSet.remove(question);
          }
        }
      }
      int frequency = int.parse(question['frequency']);
      if (frequency < selectedFrequencyRange.start.toInt() ||
          frequency > selectedFrequencyRange.end.toInt()) {
        currentSet.remove(question);
      }
      if (selectedCollege != 'All' &&
          !question['colleges'].contains(selectedCollege)) {
        currentSet.remove(question);
      }
      if (selectedCompany != 'All' &&
          !question['companies'].contains(selectedCompany)) {
        currentSet.remove(question);
      }
    }

    if (currQuestion >= questions.length) {
      completed = true;
    }

    if (currentSet.length <= 0) {
      return RefreshIndicator(
          child: ErrorCard('No Questions found!\nTry a different filter!',
              Icons.error_outline),
          onRefresh: _onRefresh);
    }

    return (!misc.isIOS())
        ? RefreshIndicator(
            child: ListView.builder(
                key: PageStorageKey('List'),
                controller: _scrollController,
                itemCount:
                    (completed) ? currentSet.length : currentSet.length + 1,
                // itemExtent: 60,
                itemBuilder: (context, index) {
                  if (currentSet.length == index && !completed) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(child: AdaptiveProgressIndicator()),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: QuestionCard(currentSet[index]),
                  );
                }),
            onRefresh: _onRefresh)
        : SafeArea(
            top: true,
            child: CustomScrollView(
              key: PageStorageKey('List'),
              controller: _scrollController,
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: _onRefresh,
                ),
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (currentSet.length == index && !completed) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(child: AdaptiveProgressIndicator()),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: QuestionCard(currentSet[index]),
                    );
                  },
                  childCount:
                      (completed) ? currentSet.length : currentSet.length + 1,
                ))
              ],
            ),
          );
  }

  Future<Null> _onRefresh() async {
    setState(() {
      needsRefresh = true;
      questions = null;
      currentSet = [];
      selectedFrequencyRange = RangeValues(0.0, 100.0);
      difficultySelected = [true, false, false, false];
      trending = false;
      jobTypeSelected = [true, false, false];
      testTypeSelected = [true, false, false];
      selectedCompany = 'All';
      selectedCollege = 'All';
      collegesAvailable = ['All'];
      companiesAvailable = ['All'];
      currQuestion = 0;
      completed = false;
    });
  }

  _getData() async {
    try {
      DataSnapshot data = await dbRef.child("questions").once();
      List _data = data.value.toList();
      for (var i = 0; i < _data.length; i++) {
        for (var item in _data[i]['colleges']) {
          if (!collegesAvailable.contains(item)) {
            collegesAvailable.add(item);
          }
        }
        for (var item in _data[i]['companies']) {
          if (!companiesAvailable.contains(item)) {
            companiesAvailable.add(item);
          }
        }
      }
      // print(collegesAvailable);
      return _data;
    } catch (e) {
      print('[ERROR] ' + e.toString());
    }
  }

  _addToSet() async {
    await Future.delayed(Duration(milliseconds: 1000));
    int itemsAdded = 0;
    int firstQuestion = currQuestion;
    for (var i = firstQuestion; i < questions.length; i++) {
      currQuestion++;
      if (itemsAdded > 7) {
        break;
      }
      var question = questions[i];
      currentSet.add(question);
      itemsAdded++;
      if (!difficultySelected[0]) {
        for (var i = 1; i <= 3; i++) {
          if (difficultySelected[i] && question['difficulty'] != i) {
            currentSet.remove(question);
            itemsAdded--;
          }
        }
      }
      if (!jobTypeSelected[0]) {
        for (var i = 1; i <= 2; i++) {
          if (jobTypeSelected[i] &&
              !question['job_type'].contains(jobTypeyMap[i])) {
            itemsAdded--;
            currentSet.remove(question);
          }
        }
      }
      if (!testTypeSelected[0]) {
        for (var i = 1; i <= 2; i++) {
          if (testTypeSelected[i] &&
              !question['test_type'].contains(testTypeMap[i])) {
            itemsAdded--;
            currentSet.remove(question);
          }
        }
      }
      int frequency = int.parse(question['frequency']);
      if (frequency < selectedFrequencyRange.start.toInt() ||
          frequency > selectedFrequencyRange.end.toInt()) {
        itemsAdded--;
        currentSet.remove(question);
      }
      if (selectedCollege != 'All' &&
          !question['colleges'].contains(selectedCollege)) {
        itemsAdded--;
        currentSet.remove(question);
      }
      if (selectedCompany != 'All' &&
          !question['companies'].contains(selectedCompany)) {
        itemsAdded--;
        currentSet.remove(question);
      }
    }
    if (currQuestion >= questions.length) {
      completed = true;
    }
    // return;
    setState(() {});
  }

  _showFilter() {
    var selectedNewRange = selectedFrequencyRange;
    var labels = RangeLabels(
        selectedFrequencyRange.start.toInt().toString() + '%',
        selectedFrequencyRange.end.toInt().toString() + '%');
    List<bool> newDifficultySelected = difficultySelected;
    List<bool> newJobTypeSelected = jobTypeSelected;
    List<bool> newTestTypeSelected = testTypeSelected;
    String newSelectedCollege = selectedCollege;
    String newSelectedCompany = selectedCompany;
    showAdaptiveModalSheet(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setStateOne) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Filter',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                                TextSpan(
                                  text: ' your search',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Frequency',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                                TextSpan(
                                  text: ' Range',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: Row(
                            children: <Widget>[
                              Text("0%"),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                      valueIndicatorTextStyle:
                                          TextStyle(color: Colors.white)),
                                  child: RangeSlider(
                                    divisions: 10,
                                    values: selectedNewRange,
                                    onChanged: (newRange) {
                                      setStateOne(
                                        () {
                                          selectedNewRange = newRange;
                                          labels = RangeLabels(
                                              selectedNewRange.start
                                                      .toInt()
                                                      .toString() +
                                                  '%',
                                              selectedNewRange.end
                                                      .toInt()
                                                      .toString() +
                                                  '%');
                                        },
                                      );
                                    },
                                    labels: labels,
                                    min: 0.0,
                                    max: 100.0,
                                  ),
                                ),
                              ),
                              Text("100%")
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Difficulty',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: Material(
                              child: ToggleButtons(
                                children: [
                                  Container(
                                    width: (MediaQuery.of(context).size.width -
                                            36) /
                                        4,
                                    child: Center(
                                      child: Text("Any"),
                                    ),
                                  ),
                                  Container(
                                    width: (MediaQuery.of(context).size.width -
                                            36) /
                                        4,
                                    child: Center(
                                      child: Text("Easy"),
                                    ),
                                  ),
                                  Container(
                                    width: (MediaQuery.of(context).size.width -
                                            36) /
                                        4,
                                    child: Center(
                                      child: Text("Medium"),
                                    ),
                                  ),
                                  Container(
                                    width: (MediaQuery.of(context).size.width -
                                            36) /
                                        4,
                                    child: Center(
                                      child: Text("Hard"),
                                    ),
                                  ),
                                ],
                                isSelected: newDifficultySelected,
                                onPressed: (index) {
                                  setStateOne(
                                    () {
                                      for (var i = 0;
                                          i < newDifficultySelected.length;
                                          i++) {
                                        if (i == index) {
                                          newDifficultySelected[i] = true;
                                        } else
                                          newDifficultySelected[i] = false;
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Job',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                                TextSpan(
                                  text: ' Type',
                                  style: TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Material(
                          child: ToggleButtons(
                            children: [
                              Container(
                                width:
                                    (MediaQuery.of(context).size.width - 36) /
                                        3,
                                child: Center(
                                  child: Text("Any"),
                                ),
                              ),
                              Container(
                                width:
                                    (MediaQuery.of(context).size.width - 36) /
                                        3,
                                child: Center(
                                  child: Text("Internship"),
                                ),
                              ),
                              Container(
                                width:
                                    (MediaQuery.of(context).size.width - 36) /
                                        3,
                                child: Center(
                                  child: Text("Placement"),
                                ),
                              )
                            ],
                            isSelected: newJobTypeSelected,
                            onPressed: (index) {
                              setStateOne(
                                () {
                                  for (var i = 0;
                                      i < newJobTypeSelected.length;
                                      i++) {
                                    if (i == index) {
                                      newJobTypeSelected[i] = true;
                                    } else
                                      newJobTypeSelected[i] = false;
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Test',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                                TextSpan(
                                  text: ' Type',
                                  style: TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Material(
                          child: ToggleButtons(
                            children: [
                              Container(
                                width:
                                    (MediaQuery.of(context).size.width - 36) /
                                        3,
                                child: Center(
                                  child: Text("Any"),
                                ),
                              ),
                              Container(
                                width:
                                    (MediaQuery.of(context).size.width - 36) /
                                        3,
                                child: Center(
                                  child: Text("Online Test"),
                                ),
                              ),
                              Container(
                                width:
                                    (MediaQuery.of(context).size.width - 36) /
                                        3,
                                child: Center(
                                  child: Text("Interview"),
                                ),
                              )
                            ],
                            isSelected: newTestTypeSelected,
                            onPressed: (index) {
                              setStateOne(
                                () {
                                  for (var i = 0;
                                      i < newTestTypeSelected.length;
                                      i++) {
                                    if (i == index) {
                                      newTestTypeSelected[i] = true;
                                    } else
                                      newTestTypeSelected[i] = false;
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Choose',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                                TextSpan(
                                  text: ' Company',
                                  style: TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Material(
                          child: DropdownButton(
                              isExpanded: true,
                              value: newSelectedCompany,
                              items: companiesAvailable
                                  .map<DropdownMenuItem<String>>(
                                      (e) => DropdownMenuItem<String>(
                                            value: e,
                                            child: Text(e),
                                          ))
                                  .toList(),
                              onChanged: (String newvalue) => {
                                    setStateOne(() {
                                      newSelectedCompany = newvalue;
                                    })
                                  }),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Choose',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                                TextSpan(
                                  text: ' College',
                                  style: TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Material(
                          child: DropdownButton(
                              isExpanded: true,
                              value: newSelectedCollege,
                              items: collegesAvailable
                                  .map<DropdownMenuItem<String>>(
                                      (e) => DropdownMenuItem<String>(
                                            value: e,
                                            child: Text(e),
                                          ))
                                  .toList(),
                              onChanged: (String newvalue) => {
                                    setStateOne(() {
                                      newSelectedCollege = newvalue;
                                    })
                                  }),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }).whenComplete(() => setState(() {
          selectedFrequencyRange = selectedNewRange;
          selectedCollege = newSelectedCollege;
          selectedCompany = newSelectedCompany;
          difficultySelected = newDifficultySelected;
          jobTypeSelected = newJobTypeSelected;
          testTypeSelected = newTestTypeSelected;
          currQuestion = 0;
          currentSet = [];
          completed = false;
        }));
  }
}
