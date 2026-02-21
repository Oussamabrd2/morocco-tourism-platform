import 'package:flutter/material.dart';

class ActivityDetailScreen extends StatelessWidget {
  final int id;
  const ActivityDetailScreen(this.id, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Activité')),
      body: Center(child: Text('Détails activité #$id')),
    );
  }
}
