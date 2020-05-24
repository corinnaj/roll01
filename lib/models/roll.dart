import 'package:flutter/material.dart';
import 'dart:math';

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
        Modifier modifier = Modifier(modifier: int.parse(fullMatch));
        parts.add(modifier);
      }
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
    DoubleRoll result = DoubleRoll();
    result.advantage = match.contains("a");
    String rollString = (match.replaceAll(new RegExp(r'[ai]?'), ''));
    result.first = parseRoll(rollString)[0];
    result.second = parseRoll(rollString)[0];
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
      Roll roll = Roll();
      roll.die = die;
      roll.negated = negated;
      result.add(roll);
    }
    return result;
  }

  Result.fromJson(Map<String, dynamic> json)
      : user = json['user'],
        time = json['time'],
        parts = json['parts'].map((p) {
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
        });

  Map<String, dynamic> toJson() => {
        'hidden': hidden,
        'time': time,
        'user': user,
        'parts': parts.map((p) => p.toJson()).toList(),
      };

  int get result => parts.map((p) => p.effectiveResult).fold(0, (sum, current) => sum + current);
}

abstract class ResultPart {
  int result;
  int get effectiveResult => result;
  //Widget build();
  Map<String, dynamic> toJson();

  ResultPart({this.result});
}

class Roll extends ResultPart {
  int die;
  bool negated;

  Roll();

  @override
  int get effectiveResult => negated ? -result : result;

  Roll.fromJson(Map<String, dynamic> json)
      : die = json['die'],
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
  Roll first;
  Roll second;
  bool advantage;

  DoubleRoll();

  DoubleRoll.fromJson(Map<String, dynamic> json)
      : first = Roll.fromJson(json['first']),
        second = Roll.fromJson(json['second']),
        advantage = json['advantage'];

  int get result {
    return advantage ? max(first.result, second.result) : min(first.result, second.result);
  }

  Map<String, dynamic> toJson() => {
        "type": "doubleroll",
        "advantage": advantage,
        "first": first.toJson(),
        "second": second.toJson(),
      };
}

class Modifier extends ResultPart {
  int modifier;
  @override
  int get result => modifier;

  Modifier({this.modifier});

  Modifier.fromJson(Map<String, dynamic> json) : modifier = json['modifier'];

  Map<String, dynamic> toJson() => {
        "type": "modifier",
        "modifier": modifier,
      };
}
