import 'dart:ui';

import 'package:demux_task/widgets/CompanyChip.dart';
import 'package:demux_task/widgets/QuestionChip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:demux_task/utils/misc.dart' as misc;
import 'package:url_launcher/url_launcher.dart';


class QuestionCard extends StatefulWidget {
  final Map data;

  QuestionCard(this.data);

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  List<Widget> companychips;

  List<Widget> topicchips;

  List<Widget> questionchips;

  @override
  Widget build(BuildContext context) {
    companychips = [];
    topicchips = [];
    questionchips = [];

    for (var item in widget.data['companies']) {
      // print(item);
      companychips.add(CompanyChip(item));
    }

    for (var item in widget.data['topics']) {
      topicchips.add(CompanyChip(item));
    }

    questionchips.add(QuestionChip(
      (widget.data['difficulty'] == 1)
          ? 'EASY'
          : (widget.data['difficulty'] == 2)
              ? 'MEDIUM'
              : 'HARD',
      (widget.data['difficulty'] == 1)
          ? Colors.green
          : (widget.data['difficulty'] == 2)
              ? Color(0xffF0AD4E)
              : Colors.red,
    ));

    questionchips.add(
      QuestionChip('Frequency: ' + widget.data['frequency'] + '%',
          Theme.of(context).accentColor),
    );

    for (var item in widget.data['job_type']) {
      questionchips.add(QuestionChip(item, Theme.of(context).accentColor));
    }

    for (var item in widget.data['test_type']) {
      questionchips.add(Padding(
          padding: const EdgeInsets.only(left: 3.0),
          child: QuestionChip(item, Theme.of(context).accentColor)));
    }

    return GestureDetector(
      onTap: () => _launchURL(widget.data['link']),
          child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0xffbfbfbf),
              blurRadius: 10.0,
              spreadRadius: 0.001,
              offset: const Offset(0.0, 0.0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 5.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.zero,
                            child: Text(widget.data['title'],
                                style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                        letterSpacing: 0.96,
                                        fontSize: 21.0,
                                        fontWeight: FontWeight.bold))),
                          ),
                        ),
                      ),
                      widget.data['trending'] == 'true'
                          ? Column(
                              children: [
                                Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: EdgeInsets.zero,
                                      child: Icon(
                                        FontAwesomeIcons.paperPlane,
                                        size: 15,
                                        color: Theme.of(context).accentColor,
                                      ),
                                    )),
                                Text(
                                  'Trending',
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 10),
                                )
                              ],
                            )
                          : Container()
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      // width: (MediaQuery.of(context).size.width) - 100,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Wrap(
                          spacing: 3.0,
                          children: questionchips,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Topics: ', style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 3.0,
                            children: topicchips,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  // width: (MediaQuery.of(context).size.width) / 2.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Asked by: ', style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 3.0,
                            children: companychips,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
