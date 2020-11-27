import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'misc.dart' as misc;

class AdaptiveProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return misc.isIOS()
        ? CupertinoActivityIndicator()
        : CircularProgressIndicator();
  }
}

class AdaptivePageScaffold extends StatelessWidget {
  const AdaptivePageScaffold(
      {this.hideAppBar,
      this.title,
      this.actions,
      @required this.child,
      this.backgroundColor,
      this.drawer,
      this.bottomNavigationBar,
      this.floatingActionButton,
      this.heroTag,
      this.centerTitle
      })
      : assert(child != null);

  final Color backgroundColor;
  final bool hideAppBar;
  final List<Widget> actions;
  final String title;
  final Widget child;
  final Drawer drawer;
  final BottomNavigationBar bottomNavigationBar;
  final FloatingActionButton floatingActionButton;
  final Object heroTag;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    if (misc.isIOS()) {
      return AdaptiveTextTheme(
        child: CupertinoPageScaffold(
          backgroundColor: backgroundColor,
          navigationBar: hideAppBar == null || hideAppBar
              ? null
              : CupertinoNavigationBar(
                  transitionBetweenRoutes: false,
                  // heroTag: heroTag,
                  previousPageTitle: "Back",
                  middle: Text(title ?? ""),
                  trailing: actions != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: actions,
                        )
                      : null,
                ),
          resizeToAvoidBottomInset: false,
          child: child,
        ),
      );
    } else {
      return AdaptiveTextTheme(
        child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: hideAppBar == null || hideAppBar
              ? null
              : AppBar(
                centerTitle: (centerTitle == null) ? false :centerTitle ,
                  iconTheme: IconThemeData(
                    color: Colors.white,
                  ),
                  title: Text(
                    title ?? "",
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: actions,
                  elevation: 0,
                ),
          drawer: drawer,
          body: child,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      );
    }
  }
}

class AdaptiveTextTheme extends StatelessWidget {
  const AdaptiveTextTheme({
    Key key,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final materialThemeData = Theme.of(context);
    final cupertinoThemeData = CupertinoTheme.of(context);

    return _AdaptiveTextThemeProvider(
      data: AdaptiveTextThemeData(
        materialThemeData?.textTheme,
        cupertinoThemeData?.textTheme,
      ),
      child: child,
    );
  }

  static AdaptiveTextThemeData of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<_AdaptiveTextThemeProvider>();
    return provider?.data;
  }
}

class _AdaptiveTextThemeProvider extends InheritedWidget {
  _AdaptiveTextThemeProvider({
    this.data,
    @required Widget child,
    Key key,
  }) : super(child: child, key: key);

  final AdaptiveTextThemeData data;

  @override
  bool updateShouldNotify(_AdaptiveTextThemeProvider oldWidget) {
    return data != oldWidget.data;
  }
}

class AdaptiveTextThemeData {
  const AdaptiveTextThemeData(this.materialThemeData, this.cupertinoThemeData);

  final TextTheme materialThemeData;
  final CupertinoTextThemeData cupertinoThemeData;

  TextStyle get headline => (materialThemeData?.headline5 ??
              cupertinoThemeData.navLargeTitleTextStyle)
          .copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.6,
      );

  TextStyle get subhead =>
      (materialThemeData?.subtitle1 ?? cupertinoThemeData.textStyle).copyWith(
        color: Color(0xDE000000),
        fontSize: 14,
        letterSpacing: 0.1,
      );

  TextStyle get tileTitle =>
      (materialThemeData?.bodyText2 ?? cupertinoThemeData.textStyle).copyWith(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      );

  TextStyle get bodySmall =>
      (materialThemeData?.bodyText2 ?? cupertinoThemeData.textStyle).copyWith(
        color: Color(0xDE000000),
        fontSize: 12,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w500,
      );

  TextStyle get body =>
      (materialThemeData?.subtitle1 ?? cupertinoThemeData.navTitleTextStyle)
          .copyWith(
        color: Color(0xDE000000),
        fontSize: 14.05,
        letterSpacing: 0.25,
        fontWeight: FontWeight.w500,
      );

  TextStyle get label =>
      (materialThemeData?.bodyText2 ?? cupertinoThemeData.textStyle).copyWith(
        fontStyle: FontStyle.italic,
        fontSize: 12,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w500,
        color: Color(0x99000000),
      );

  @override
  int get hashCode => materialThemeData.hashCode ^ cupertinoThemeData.hashCode;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final AdaptiveTextThemeData typedOther = other;
    return materialThemeData != typedOther.materialThemeData ||
        cupertinoThemeData != typedOther.cupertinoThemeData;
  }
}