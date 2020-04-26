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

  void _rolld20() {
    int result = random.nextInt(20) + 1;
    Roll roll =
        Roll(result: result, rolled: 'd20', userId: 'Gwindolyn', shouldOnlyShowResult: false, rolledAt: DateTime.now());
    rollRef.add(roll.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder(
          stream: rollRef.orderBy('rolledAt').onSnapshot,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text(snapshot.error.toString());
            if (!snapshot.hasData) return CircularProgressIndicator();

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: snapshot.data.docs.map<Widget>((fs.DocumentSnapshot doc) {
                  Roll roll = Roll.fromJson(doc.data(), doc.id);
                  return Text(roll.result.toString());
                }).toList(),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _rolld20(),
        tooltip: 'Roll d20',
        child: FaIcon(FontAwesomeIcons.diceD20),
      ),
    );
  }
}
