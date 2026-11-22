import 'package:flutter/material.dart';

AngleConsole angleConsole = AngleConsole();

// ignore: camel_case_types
class AngleConsole {

  /// Returns true if this is a verbose logger
  static bool isVerbose = false;

  /// Gives access to internal logger
  dynamic get rawLogger => null;

  /// Creates a instance of [FLILogger].
  /// In case [isVerbose] is `true`,
  /// it logs all the [verbose] logs to console
  AngleConsole();

    /// Logs error messages
  void error(Object? message) => throw('Error Log', error: '⚠️ $message');

  /// Prints to console if [isVerbose] is true
  void verbose(Object? message){
    if(isVerbose){
      debugPrint(message.toString());
    }
  }
  /// Prints to console
  void warning(Object? message){
    if(isVerbose){
      print(message.toString());
    }
  }
  /// Prints to console if [isVerbose] is true
  void info(Object? message){
    if(isVerbose){
      debugPrint(message.toString());
    }
  }
}
