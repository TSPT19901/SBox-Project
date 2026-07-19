import 'package:flutter/material.dart';

class Photo {
  final int id;
  final DateTime created;
  final num size;
  final String type;

  const Photo({required this.id, required this.created, required this.size, required this.type});
}
