import 'package:flutter/material.dart';

class NoteColors {
  static const List<List<Color>> pastelGradients = [
    [Color.fromARGB(255, 255, 233, 180), Color(0xFFFFE8B8)], 
    [Color.fromARGB(255, 218, 243, 255), Color(0xFFCCEEFF)],
    [Color.fromARGB(255, 230, 213, 255), Color(0xFFE0CCFF)],
    [Color.fromARGB(255, 255, 213, 213), Color(0xFFFFCCCC)], 
    [Color.fromARGB(255, 215, 255, 226), Color(0xFFCCFFDD)], 
    [Color.fromARGB(255, 255, 233, 218), Color(0xFFFFE0CC)], 
  ];

  static List<Color> getGradient(int index) {
    return pastelGradients[index % pastelGradients.length];
  }
}
