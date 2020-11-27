import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionCard extends StatelessWidget {
  final Map data;

  QuestionCard(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xffe6e6e6),
            blurRadius: 10.0,
            spreadRadius: 0.001,
            offset: const Offset(0.0, 0.0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        child: Container(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 14.0),
                  child: Text(data['title'],
                      style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                              letterSpacing: 0.96,
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
