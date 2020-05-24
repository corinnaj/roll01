import 'dart:html';

import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart' as fs;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roll01/models/roll.dart';

void main() {
  if (fb.apps.isEmpty) {
    fb.initializeApp(
      apiKey: "AIzaSyBrCzS_tvU3Qw4PsaCdODueeJ4dU3XUf7A",
      authDomain: "roll01.firebaseapp.com",
      databaseURL: "https://roll01.firebaseio.com",
      projectId: "roll01",
      storageBucket: "roll01.appspot.com",
      messagingSenderId: "512354010672",
      appId: "1:512354010672:web:772b47f8dec2e9f7008ff5",
    );
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roll01',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
        title: 'Roll01',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  fs.CollectionReference rollRef;

  @override
  void initState() {
    final store = fb.firestore();
    rollRef = store.collection('Rolls');
    super.initState();
  }

  void onRoll(String roll) {
    Result result;
    result = Result.fromString(roll);
    result.time = DateTime.now();
    result.user = 'Kitty';
    result.hidden = false;
    result.evaluate();
    rollRef.add(result.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          RollInputArea(onRoll: (String roll) => onRoll(roll)),
          StreamBuilder(
              stream: rollRef.orderBy('time', 'desc').onSnapshot,
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text(snapshot.error.toString());
                if (!snapshot.hasData) return CircularProgressIndicator();
                return Center(
                  child: Row(
                    children: ['Kitty', 'Emlyn', 'Dyri', 'DM']
                        .map(
                          (String name) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: snapshot.data.docs
                                  .where((doc) => doc.data()['user'] == name)
                                  .take(10)
                                  .map<Widget>((fs.DocumentSnapshot doc) {
                                return Result.fromJson(doc.data()).build();
                              }).toList()
                                    ..insert(0, Text(name, style: TextStyle(fontSize: 30))),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              }),
        ],
      ),
    );
  }
}

class RollInputArea extends StatefulWidget {
  final void Function(String rollString) onRoll;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Column(
              children: {4, 6, 8, 10, 12, 20, 100}
                  .map((int die) => FloatingActionButton(
                        child: FaIcon(Roll.iconForDie(die)),
                        heroTag: 'd' + die.toString(),
                        onPressed: () => textController.text = textController.text + 'd' + die.toString(),
                      ))
                  .toList(),
            ),
            Column(
              children: (List<int>.generate(8, (int i) => i - 2).map((int modifier) {
                return RaisedButton(
                  onPressed: () {
                    if (modifier != 0) {
                      textController.text = textController.text + (modifier.sign > 0 ? '+' : '-');
                      textController.text = textController.text + modifier.toString();
                    }
                    roll();
                  },
                  child: Text(modifier == 0 ? 'Roll' : modifier.toString()),
                );
              })).toList(),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
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
