import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roll01/models/roll.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MyApp());
}

class GridState {
  int rows;
  int columns;
  bool visible;

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
  final rolls = List<Roll>();
  Socket socket;
  final commands = List<dynamic>();
  List<dynamic> initiatives = [];
  Map<String, CharacterState> characters = {};
  String playerName;
  GridState gridState;

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
          rolls.add(Roll.fromJson(data));
          break;
        case 'initiative':
          initiatives.add(data);
          initiatives.sort((a, b) => b['roll']['finalResult'] - a['roll']['finalResult']);
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
    Roll roll = _roll(20);
    Map<String, dynamic> initiative = {
      'userId': 'Gwyndolin',
      'roll': roll.toJson(),
    };
    emitCommand('initiative', initiative);
  }

  Roll _roll(int dice, {int modifiers = 0}) {
    int rollResult = random.nextInt(dice) + 1;
    int finalResult = rollResult + modifiers;
    final String modifierString = modifiers == 0 ? '' : (modifiers.sign < 0 ? '-' : '+') + modifiers.abs().toString();
    Roll roll = Roll(
      id: Uuid().v4(),
      result: rollResult.toString() + modifierString,
      rolled: 'd' + dice.toString() + modifierString,
      finalResult: finalResult,
      rolledAt: DateTime.now(),
      userId: 'Gwindolyn',
      shouldOnlyShowResult: false,
    );

    emitCommand('roll', roll.toJson());
    return roll;
  }

  void emitCommand(String type, [Map<String, dynamic> data = null]) {
    if (data == null) data = {};
    data['type'] = type;
    socket.emit('command', data);
    doCommand(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EncounterTracker(
              initiatives: initiatives,
              initiativeStep: initiativeStep,
            ),
            ...rolls.map<Widget>((roll) {
              return RollDisplay(roll: roll);
            }),
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
          children: initiatives
              .map<Widget>((i) => Container(
                    color: initiatives.indexOf(i) == initiativeStep ? Colors.red : Colors.transparent,
                    child: Text('${i['userId']}: ${i['roll']['finalResult']}'),
                  ))
              .toList(),
        )
      ],
    );
  }
}

class MapGrid extends StatelessWidget {
  final int rows;
  final int columns;
  final Map<String, CharacterState> characters;
  final Function(int x, int y) onMove;

  const MapGrid({this.rows, this.columns, this.characters, this.onMove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => onMove(4, 2),
            child: CustomPaint(
              painter: MapGridPainter(columns, rows),
            ),
          ),
        ),
        ...characters.values.map<Widget>((character) => AnimatedPositioned(
              child: Image.network(character.tokenUrl, width: 48, height: 48),
              duration: Duration(milliseconds: 300),
              left: character.x * 64.0, // TODO use layoutbuilder instead of hardcoding
              top: character.y * 64.0,
            )),
      ],
    );
  }
}

class MapGridPainter extends CustomPainter {
  final int rows;
  final int columns;

  MapGridPainter(this.columns, this.rows);

  @override
  void paint(Canvas canvas, Size size) {
    final pixelSize = min(size.width / columns, size.height / rows);
    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    for (int y = 0; y <= rows; y++) {
      canvas.drawLine(Offset(0, y * pixelSize), Offset(columns * pixelSize, y * pixelSize), linePaint);
    }

    for (int x = 0; x <= columns; x++) {
      canvas.drawLine(Offset(x * pixelSize, 0), Offset(x * pixelSize, rows * pixelSize), linePaint);
    }
  }

  @override
  bool shouldRepaint(MapGridPainter oldDelegate) => rows != oldDelegate.rows || columns != oldDelegate.columns;
}
