import 'dart:io';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  final File extra;

  DetailPage(this.extra);
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Image.file(widget.extra),
      ),
    );
  }
}

class DetailTool extends StatefulWidget {
  @override
  _DetailToolState createState() => _DetailToolState();
}

class _DetailToolState extends State<DetailTool> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
