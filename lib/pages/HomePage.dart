import 'package:demux_task/utils/adaptiveWidgets.dart';
import 'package:demux_task/widgets/QuestionCard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'dart:math';

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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  List questions;
  List currentSet;

  ScrollController _scrollController = ScrollController();

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => needsRefresh == null ? true : !needsRefresh;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && currentSet.length < questions.length) {
        _addToSet();
      }
    });
  }

  void dispose() {
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return AdaptivePageScaffold(
        hideAppBar: false,
        title: 'Questions',
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
                          return Text("Error");
                        } else if (!snapshot.hasData)
                          return Center(
                            child: AdaptiveProgressIndicator(),
                          );
                        questions = snapshot.data;
                        currentSet = [];
                        for (var i = 0; i < 13; i++) {
                          currentSet.add(questions[i]);
                        }
                        return buildMainWidget();
                      }
                    default:
                      return Text('Placeholder');
                  }
                }));
  }

  Widget buildMainWidget() {
    if (questions == null || questions.length < 0) {
      return Text('bruh');
    }

    if (currentSet == null || currentSet.length < 0) {
      return Text('bruh');
    }

    // List<Widget> ret = [];

    // for (Map question in questions) {
    //   ret.add(QuestionCard(question));
    // }

    return RefreshIndicator(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: min(currentSet.length+1, questions.length),
          itemBuilder: (context, index) {
            if (currentSet.length == index) {
              return Center(child: AdaptiveProgressIndicator());
            }
          return QuestionCard(currentSet[index]);
        }),
        onRefresh: _onRefresh);
  }

  Future<Null> _onRefresh() async {
    setState(() {
      needsRefresh = true;
      questions = null;
    });
  }

  _getData() async {
    try {
      DataSnapshot data = await dbRef.child("questions").once();
      List _data = data.value.toList();
      return _data;
    } catch (e) {
      print('[ERROR] ' + e.toString());
    }
  }

  _addToSet() async {
    await Future.delayed(Duration(milliseconds: 2000));
    for (var i = currentSet.length; i < min(currentSet.length+10, questions.length); i++) {
      // print(i);
      currentSet.add(questions[i]);
    }
    setState(() {});
  }
}
