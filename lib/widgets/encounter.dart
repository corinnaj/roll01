import 'package:flutter/material.dart';
import 'package:roll01/models/roll.dart';

class EncounterTracker extends StatelessWidget {
  final List<dynamic> initiatives;
  final int initiativeStep;

  EncounterTracker({this.initiatives, this.initiativeStep});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: initiatives.map<Widget>((i) {
            int result = Result.fromJson(i['roll']).result;
            return Container(
              color: initiatives.indexOf(i) == initiativeStep ? Colors.red : Colors.transparent,
              child: Text('${i['userId']}: ${result}'),
            );
          }).toList(),
        )
      ],
    );
  }
}
