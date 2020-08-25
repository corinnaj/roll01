import 'package:flutter/material.dart';
import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Result {
  List<ResultPart> parts = [];
  String user;
  DateTime time;
  bool hidden;

  Result({this.user, this.time, this.hidden});

  Result.fromString(String rollString) {
    rollString = rollString.trim();
    RegExp regex = new RegExp(r"([+-]?[0-9]*)?(d[0-9]*[ai]?)?");
    Iterable<Match> matches = regex.allMatches(rollString);
    for (Match m in matches) {
      String fullMatch = m.group(0);
      if (fullMatch == "") continue;
      if (fullMatch.contains('d')) {
        parts.addAll(parseRoll(fullMatch));
      } else {
        Modifier modifier = Modifier(int.parse(fullMatch));
        parts.add(modifier);
      }
    }
  }

  Widget build() {
    print(parts);
    return Row(children: <Widget>[
      Text(this.user),
      ...parts.map((ResultPart part) => part.build()),
      Text(' = ' + result.toString()),
    ]);
  }

  void evaluate() {
    for (ResultPart part in parts) {
      part.evaluate();
    }
  }

  bool parseSign(String match) {
    return match.contains("-");
  }

  int parseAmount(String match) {
    if (match.split("d")[0].isEmpty || match.split("d")[0] == "-" || match.split("d") == "+") {
      return 1;
    } else {
      return int.parse(match.split("d")[0]);
    }
  }

  int parseDie(String match) {
    return int.parse(match.split("d")[1]);
  }

  List<ResultPart> parseDoubleRoll(String match) {
    bool advantage = match.contains("a");
    String rollString = (match.replaceAll(new RegExp(r'[ai]?'), ''));
    Roll first = parseRoll(rollString)[0];
    Roll second = parseRoll(rollString)[0];
    DoubleRoll result = DoubleRoll(first, second, advantage);
    return [result];
  }

  List<ResultPart> parseRoll(String match) {
    List<ResultPart> result = [];
    if (match.contains("a") || match.contains("i")) {
      return parseDoubleRoll(match);
    }
    bool negated = parseSign(match);
    int amount = parseAmount(match);
    int die = parseDie(match);

    for (int i = 0; i < amount.abs(); i++) {
      Roll roll = Roll(die, negated);
      result.add(roll);
    }
    return result;
  }

  Result.fromJson(Map<String, dynamic> json)
      : user = json['user'],
        time = DateTime.parse(json['time']),
        parts = json['parts'].map<ResultPart>((p) {
          switch (p['type']) {
            case 'roll':
              return Roll.fromJson(p);
            case 'modifier':
              return Modifier.fromJson(p);
            case 'doubleroll':
              return DoubleRoll.fromJson(p);
            default:
              assert(false);
              return null;
          }
        }).toList();

  Map<String, dynamic> toJson() => {
        'hidden': hidden,
        'time': time.toIso8601String(),
        'user': user,
        'parts': parts.map((p) => p.toJson()).toList(),
      };

  int get result => parts.map((p) => p.effectiveResult).fold(0, (sum, current) => sum + current);
}

abstract class ResultPart {
  int result;
  int get effectiveResult => result;
  Widget build();
  Map<String, dynamic> toJson();
  void evaluate();

  ResultPart({this.result});
}

class Roll extends ResultPart {
  final int die;
  final bool negated; // = false;

  Roll(this.die, this.negated);

  @override
  int get effectiveResult => negated ? -result : result;

  static IconData iconForDie(int die) {
    switch (die) {
      case 4:
        return FontAwesomeIcons.diceD4;
      case 6:
        return FontAwesomeIcons.diceD6;
      case 8:
        return FontAwesomeIcons.diceD8;
      case 10:
        return FontAwesomeIcons.diceD10;
      case 12:
        return FontAwesomeIcons.diceD12;
      case 20:
        return FontAwesomeIcons.diceD20;
      case 100:
        return FontAwesomeIcons.percent;
      default:
        return FontAwesomeIcons.questionCircle;
    }
  }

  @override
  Widget build() {
    Color color =
        (result == 1 && die == 20) ? Colors.red : (result == die && die == 20) ? Colors.green : Colors.black26;
    return Row(
      children: <Widget>[
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              iconForDie(die),
              color: color,
              size: 40,
            ),
            Text(
              result.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ],
    );
  }

  Roll.fromJson(Map<String, dynamic> json)
      : die = json['die'],
        negated = json['negated'],
        super(result: json['result']);

  int evaluate() {
    if (result == null) {
      final random = Random.secure();
      result = random.nextInt(die) + 1;
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        "type": "roll",
        "die": die,
        "negated": negated,
        "result": result,
      };
}

class DoubleRoll extends ResultPart {
  final Roll first;
  final Roll second;
  final bool advantage;

  DoubleRoll(this.first, this.second, this.advantage);

  DoubleRoll.fromJson(Map<String, dynamic> json)
      : first = Roll.fromJson(json['first']),
        second = Roll.fromJson(json['second']),
        advantage = json['advantage'];

  int get result {
    return advantage ? max(first.result, second.result) : min(first.result, second.result);
  }

  Widget build() {
    return Row(children: [
      Text('(', style: TextStyle(fontSize: 30)),
      first.build(),
      second.build(),
      Text(')', style: TextStyle(fontSize: 30)),
    ]);
  }

  void evaluate() {
    first.evaluate();
    second.evaluate();
  }

  Map<String, dynamic> toJson() => {
        "type": "doubleroll",
        "advantage": advantage,
        "first": first.toJson(),
        "second": second.toJson(),
      };
}

class Modifier extends ResultPart {
  final int modifier;
  @override
  int get result => modifier;

  Widget build() {
    return Text(
      (modifier.sign > 0 ? '+' : '') + modifier.toString(),
      style: TextStyle(fontSize: 20),
    );
  }

  void evaluate() {
    return;
  }

  Modifier(this.modifier);

  Modifier.fromJson(Map<String, dynamic> json) : modifier = json['modifier'];

  Map<String, dynamic> toJson() => {
        "type": "modifier",
        "modifier": modifier,
      };
}
