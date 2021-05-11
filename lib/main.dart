import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roll01/models/roll.dart';
import 'package:roll01/models/user.dart';
import 'package:roll01/widgets/encounter.dart';
import 'package:roll01/widgets/map.dart';
import 'package:roll01/widgets/rolling.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MyApp());
}

class GridState {
  int rows;
  int columns;
  bool visible;

  GridState.init()
      : rows = 0,
        columns = 0,
        visible = false;

  GridState.fromJson(dynamic data)
      : rows = data['rows'],
        columns = data['columns '],
        visible = data['visible'];
}

class CharacterState {
  int x = 0;
  int y = 0;
  String name;
  String tokenUrl;
  CharacterState(this.name, this.tokenUrl);
  void move(int x, int y) {
    this.x += x;
    this.y += y;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roll01',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.indigo,
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
  final results = List<Result>();
  Socket socket;
  final commands = List<dynamic>();
  List<dynamic> initiatives = [];
  Map<String, CharacterState> characters = {};
  String playerName;
  GridState gridState = GridState.init();

  List<User> users = [
    User('Corinna', FontAwesomeIcons.duotoneHandHoldingMagic),
    User('Tom', FontAwesomeIcons.duotoneShield),
  ];

  bool hasJoined = false;

  int initiativeStep = 0;

  @override
  void initState() {
    socket = io('http://localhost:3000', <String, dynamic>{
      // 'transports': ['websocket'],
      // 'autoConnect': true,
    });

    socket.on('request_join', (data) {
      socket.emit('answer_join', {'requesterSocketId': data['requesterSocketId'], 'commands': commands});
    });

    socket.on('init_commands', (data) {
      if (hasJoined) return;
      hasJoined = true;
      for (final cmd in data) doCommand(cmd);
    });
    socket.on('command', doCommand);

    socket.on('connect', (data) => print('Connected'));
    socket.connect();

    if (playerName == null) requestPlayerName();

    super.initState();
  }

  void requestPlayerName() async {
    // THIS DOENST WORK MAYBE final controller = TextEditingController();
    /*TextEditingController controller;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(controller: controller),
              actions: [FlatButton(onPressed: () => Navigator.of(context).pop(controller.text), child: Text('Enter'))],
            ));*/
    setState(() {
      playerName = 'Gwindolyn';
      emitCommand('add_character', {'name': playerName, 'tokenUrl': 'http://localhost:8000/token_norbi.png'});
    });
  }

  void doCommand(dynamic data) {
    commands.add(data);

    setState(() {
      switch (data['type']) {
        case 'roll':
          results.add(Result.fromJson(data));
          break;
        case 'initiative':
          initiatives.add(data);
          initiatives.sort((a, b) => Result.fromJson(b['roll']).result - Result.fromJson(a['roll']).result);
          break;
        case 'clear_initiative':
          initiatives = [];
          initiativeStep = 0;
          break;
        case 'step_initiative':
          initiativeStep++;
          if (initiativeStep >= initiatives.length) initiativeStep = 0;
          break;
        case 'add_character':
          characters[data['name']] = CharacterState(data['name'], data['tokenUrl']);
          break;
        case 'remove_character':
          characters.remove(data['name']);
          break;
        case 'move_character':
          characters[data['name']].move(data['x'], data['y']);
          break;
        case 'set_character_token_url':
          characters[data['name']].tokenUrl = data['tokenUrl'];
          break;
        case 'set_grid':
          gridState = GridState.fromJson(data);
          break;
      }
    });
  }

  void _addInitiative() {
    Result roll = _roll('d20');
    Map<String, dynamic> initiative = {
      'userId': roll.user,
      'roll': roll.toJson(),
    };
    emitCommand('initiative', initiative);
  }

  Result _roll(String roll) {
    Result result;
    result = Result.fromString(roll);
    result.time = DateTime.now();
    result.user = 'Kitty';
    result.hidden = false;
    result.evaluate();

    emitCommand('roll', result.toJson());
    return result;
  }

  void emitCommand(String type, [Map<String, dynamic> data = null]) {
    if (data == null) data = {};
    data['type'] = type;
    socket.emit('command', data);
    doCommand(data);
  }

  Widget buildRollsArea() {
    return Container(
      color: Colors.black12,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ...results.map<Widget>((roll) {
            return roll.build();
          }),
          RollInputArea(
            onRoll: (s) => _roll(s),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EncounterTracker(
                  initiatives: initiatives,
                  initiativeStep: initiativeStep,
                ),
                if (gridState.visible)
                  Container(
                    width: 400,
                    height: 400,
                    child: MapGrid(
                      rows: gridState.rows,
                      columns: gridState.columns,
                      characters: characters,
                      onMove: (x, y) => emitCommand('move_character', {'x': x, 'y': y, 'name': playerName}),
                    ),
                  ),
                RaisedButton.icon(
                    onPressed: () => _addInitiative(), icon: Icon(Icons.play_arrow), label: Text('Add Initiative')),
                RaisedButton.icon(
                    onPressed: () => emitCommand('clear_initiative'),
                    icon: Icon(Icons.smoking_rooms),
                    label: Text('Start New Encounter')),
                RaisedButton.icon(
                    onPressed: () => emitCommand('step_initiative'),
                    icon: Icon(Icons.skip_next),
                    label: Text('Step Inititive')),
              ],
            ),
          ),
          Expanded(child: buildRollsArea()),
        ],
      ),
    );
  }
}
