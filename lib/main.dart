import 'dart:math';

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
  final random = Random.secure();
  fs.CollectionReference rollRef;

  @override
  void initState() {
    final store = fb.firestore();
    rollRef = store.collection('Rolls');
    super.initState();
  }

  void _roll(int dice, {int modifiers = 0}) {
    int rollResult = random.nextInt(dice) + 1;
    int finalResult = rollResult + modifiers;
    final String modifierString = modifiers == 0 ? '' : (modifiers.sign < 0 ? '-' : '+') + modifiers.abs().toString();
    Roll roll = Roll(
      result: rollResult.toString() + modifierString,
      rolled: 'd' + dice.toString() + modifierString,
      finalResult: finalResult,
      rolledAt: DateTime.now(),
      userId: 'Gwindolyn',
      shouldOnlyShowResult: false,
    );
    rollRef.add(roll.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder(
          stream: rollRef.orderBy('rolledAt', 'desc').limit(20).onSnapshot,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (!snapshot.hasData) return CircularProgressIndicator();

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: snapshot.data.docs.map<Widget>((fs.DocumentSnapshot doc) {
                  return RollDisplay(roll: Roll.fromJson(doc.data(), doc.id));
                }).toList(),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _roll(20, modifiers: -2),
        tooltip: 'Roll d20',
        child: FaIcon(FontAwesomeIcons.diceD20),
      ),
    );
  }
}

class RollDisplay extends StatelessWidget {
  final Roll roll;

  RollDisplay({@required this.roll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(roll.rolled + " "),
        Text(roll.result + " = "),
        Text(
          roll.finalResult.toString(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
