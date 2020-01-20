// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  // A temporary measure until Platform supports web and TargetPlatform supports
  // macOS.
  if (!kIsWeb && Platform.isMacOS) {
    // TODO(gspencergoog): Update this when TargetPlatform includes macOS.
    // https://github.com/flutter/flutter/issues/31366
    // See https://github.com/flutter/flutter/wiki/Desktop-shells#target-platform-override.
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  // This creates a clock that enables you to customize it.
  //
  // The [ClockCustomizer] takes in a [ClockBuilder] that consists of:
  //  - A clock widget (in this case, [AnalogClock])
  //  - A model (provided to you by [ClockModel])
  // For more information, see the flutter_clock_helper package.
  //
  // Your job is to edit [AnalogClock], or replace it with your own clock
  // widget. (Look in analog_clock.dart for more details!)
  runApp(ClockCustomizer((ClockModel model) => MyApp(model)));
}

class MyApp extends StatelessWidget {
  final ClockModel model;
  MyApp(this.model);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: new HomeContent());
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  double min, sec, hour;
  String _timeString;
  var amPmDesignator = "AM";

  @override
  void initState() {
    super.initState();
    min = DateTime.now().minute.toDouble();
    sec = DateTime.now().second.toDouble();
    hour = DateTime.now().hour.toDouble();
    hour >= 12 ? hour = hour - 12 : hour;
    _designator(hour);
    _timeString = "${hour.toInt()} : ${min.toInt()} ";
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getCurrentTime());
  }

  void _designator(hour) {
    if (hour == 12)
      amPmDesignator = "PM";
    else if (hour > 12) {
      amPmDesignator = "PM";
    }
  }

  void _getCurrentTime() {
    setState(() {
      min = DateTime.now().minute.toDouble();
      sec = DateTime.now().second.toDouble();
      hour = DateTime.now().hour.toDouble();
      hour >= 12 ? hour = hour - 12 : hour;
      _designator(hour);
      _timeString = "${hour.toInt()} : ${min.toInt()} ";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CompCircle(
            width: 200,
            height: 200,
            percentage: hour * 0.523599,
            timeString: _timeString,
            strokeWidth: 7.0,
            change: amPmDesignator,
            color: Colors.lightGreenAccent),
        CompCircle(
            width: 165,
            height: 165,
            percentage: min * 0.104,
            timeString: "",
            change: "",
            strokeWidth: 5.0,
            color: Colors.orangeAccent),
        CompCircle(
            width: 130,
            height: 130,
            percentage: sec * 0.104,
            timeString: "",
            change: "",
            strokeWidth: 3.0,
            color: Colors.red),
      ],
    );
  }
}

class CompCircle extends StatelessWidget {
  const CompCircle(
      {Key key,
      @required this.percentage,
      @required String timeString,
      this.height,
      this.width,
      this.color,
      this.strokeWidth,
      this.change})
      : _timeString = timeString,
        super(key: key);

  final double percentage;
  final String _timeString, change;
  final double width, height, strokeWidth;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.center,
        height: height,
        width: width,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: new CustomPaint(
          foregroundPainter: new MyPainter(
            lineColor: Colors.transparent,
            completeColor: color,
            completePercent: percentage,
            width: strokeWidth,
          ),
          child: new Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _timeString,
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  ),
                  Text(
                    change,
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  Color lineColor;
  Color completeColor;
  double completePercent;
  double width;

  MyPainter(
      {this.lineColor, this.completeColor, this.completePercent, this.width});

  @override
  void paint(Canvas canvas, Size size) {
    Paint line = new Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Paint complete = new Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Offset center = new Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, line);
    double arcAngle = completePercent;
    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, complete);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
