import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CompanyChip extends StatelessWidget {
  final String company;

  CompanyChip(this.company);

  final Map<String, IconData> _map = {
    "Microsoft": FontAwesomeIcons.microsoft,
    "Facebook": FontAwesomeIcons.facebook,
    "LinkedIn": FontAwesomeIcons.linkedin,
    "Google": FontAwesomeIcons.google,
    "Amazon": FontAwesomeIcons.amazon
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.lightBlue,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: (_map.containsKey(company))
            ? Icon(
                _map[company],
                color: Colors.white,
                size: 15,
              )
            : Text(
                company,
                style: TextStyle(color: Colors.white, fontSize: 12.0),
              ),
      ),
    );
  }
}
