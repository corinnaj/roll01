import 'dart:math';

import 'package:flutter/material.dart';
import 'package:roll01/main.dart';

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
