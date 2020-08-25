import 'package:flutter/material.dart';

class Roll {
  String id;
  String result;
  int finalResult;
  String userId;
  bool shouldOnlyShowResult;
  String rolled;
  DateTime rolledAt;

  Roll(
      {@required this.id,
      this.result,
      this.finalResult,
      this.userId,
      this.shouldOnlyShowResult,
      this.rolled,
      this.rolledAt});

  Roll.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          result: json['result'],
          finalResult: json['finalResult'],
          userId: json['userId'],
          shouldOnlyShowResult: json['shouldOnlyShowResult'],
          rolled: json['rolled'],
          rolledAt: DateTime.parse(json['rolledAt']),
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'result': result,
      'finalResult': finalResult,
      'userId': userId,
      'rolled': rolled,
      'shouldOnlyShowResults': shouldOnlyShowResult,
      'rolledAt': rolledAt.toIso8601String(),
    };
  }
}

class User {
  String id;
  String name;
  int icon;
  int color;
  bool isDM;

  User({this.id, this.name, this.isDM, this.icon, this.color});

  User.fromJson(Map<String, dynamic> json, String id)
      : this(
          id: id,
          name: json['name'],
          isDM: json['isDM'],
          icon: json['icon'],
          color: json['color'],
        );
}
