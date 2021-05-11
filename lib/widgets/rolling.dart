import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roll01/models/roll.dart';

class RollInputArea extends StatefulWidget {
  final Result Function(String rollString) onRoll;

  RollInputArea({this.onRoll});

  @override
  _RollInputAreaState createState() => _RollInputAreaState();
}

class _RollInputAreaState extends State<RollInputArea> {
  TextEditingController textController;

  @override
  void initState() {
    textController = TextEditingController();
    super.initState();
  }

  void roll() {
    widget.onRoll(textController.text);
    textController.text = '';
  }

  void addText(String newText, {bool concat = false}) {
    if (concat)
      textController.text = textController.text + (textController.text == '' ? newText : '+' + newText);
    else
      textController.text = textController.text + newText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Wrap(
          runSpacing: 6.0,
          spacing: 6.0,
          children: {4, 6, 8, 10, 12, 20, 100}
              .map((int die) => FloatingActionButton(
                    elevation: 2,
                    focusElevation: 4,
                    child: FaIcon(Roll.iconForDie(die)),
                    heroTag: 'd' + die.toString(),
                    onPressed: () => addText('d' + die.toString(), concat: true),
                  ))
              .toList(),
        ),
        SizedBox(height: 20),
        Wrap(
          runSpacing: 12.0,
          spacing: 12.0,
          children: (List<int>.generate(7, (int i) => i - 2).map((int modifier) {
            return Container(
              width: 50,
              height: 50,
              child: RaisedButton(
                elevation: 2,
                focusElevation: 4,
                color: Theme.of(context).accentColor,
                onPressed: () {
                  if (modifier != 0) {
                    addText(modifier.sign > 0 ? '+' : '');
                    addText(modifier.toString());
                  }
                  roll();
                },
                child: Text(
                  modifier.sign > 0 ? '+' + modifier.toString() : modifier.toString(),
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                //child: Text(modifier == 0 ? 'Roll' : modifier.toString()),
              ),
            );
          })).toList(),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                  child: TextField(
                controller: textController,
              )),
              RaisedButton(
                child: Text('Submit'),
                onPressed: () => roll(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
