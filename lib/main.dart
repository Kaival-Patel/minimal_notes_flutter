import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notes_by_kaival/mainScreen.dart';
import 'package:notes_by_kaival/signInWithGoogle.dart';
void main() async
{
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(myApp());
}

class myApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(accentColor: Color(0xFF3E436A),primaryColor:Colors.white,fontFamily: 'Heebo',canvasColor: Colors.transparent),
      debugShowCheckedModeBanner: false,
      title: 'Minimal Note App',
      home:mainScreen()
    );
  }

}