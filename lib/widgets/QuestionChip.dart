import 'package:flutter/material.dart';

class QuestionChip extends StatelessWidget {
  final String text;
  final Color color;

  QuestionChip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 10.0),
              ),
      ),
    );
  }
}
