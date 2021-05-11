import 'package:flutter/material.dart';

class PC {
  final String name;

  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  PC(this.name, {this.strength, this.dexterity, this.constitution, this.intelligence, this.wisdom, this.charisma});
}

class User {
  final String name;
  final IconData icon;

  User(this.name, this.icon);
}
