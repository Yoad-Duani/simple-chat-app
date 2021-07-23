import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  fillColor: Colors.white,
  // focusColor: Colors.red,
  // hoverColor: Colors.red,
  filled: true,
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type a message...',
  border: InputBorder.none,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 0.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 0.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kMessageContainerDecoration = BoxDecoration(
    // color: Colors.red,
    // border: Border(
    //   top: BorderSide(color: Colors.lightBlueAccent, width: 0.0),
    // ),
    );

const kTextFielDecoration = InputDecoration(
  // fillColor: Colors.red,
  // focusColor: Colors.red,
  // hoverColor: Colors.red,
  // filled: true,
  hintText: 'Enter a value',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);
