import 'package:flutter/material.dart';

class ErrorCard extends StatelessWidget {
  final IconData icon;
  final String errorText;

  ErrorCard(this.errorText, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 100.0,
                    color: Colors.grey,
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        errorText,
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.grey,
                        ),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
