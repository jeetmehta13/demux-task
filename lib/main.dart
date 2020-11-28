import 'package:demux_task/pages/HomePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'utils/misc.dart' as misc;
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ErrorWidget.builder = (FlutterErrorDetails details) => Center(
        child: Directionality(
          child: Text(
            "Uh-Oh!\nAn unexpected error has occured.\nContact us at jeetsmehta13@gmail.com\nfor further details.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xff9FA0B5),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          textDirection: TextDirection.ltr,
        ),
      );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return misc.isIOS()
        ? CupertinoApp(
            title: 'Demux Task',
            theme: CupertinoThemeData(
              brightness: Brightness.light,
              textTheme: CupertinoTextThemeData(
                textStyle: GoogleFonts
                    .montserrat(), //TextStyle(fontFamily: 'Comfortaa'),
              ),
            ),
            home: HomePage(),
          )
        : MaterialApp(
            title: 'Demux Task',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              textTheme: GoogleFonts.montserratTextTheme(),
            ),
            home: HomePage(),
          );
  }
}
