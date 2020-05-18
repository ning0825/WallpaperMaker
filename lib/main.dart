import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'edit_page.dart';

void main() => runApp(EditPage());

class ResolutionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ResolutionPage(),
    );
  }
}

class ResolutionPage extends StatefulWidget {
  @override
  _ResolutionPageState createState() => _ResolutionPageState();
}

class _ResolutionPageState extends State<ResolutionPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    _buildAutoDetectedOpt(),
                    _buildCustomizeOpt(),
                    SizedBox(height: 200),
                    _buildNextButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

_buildTitle() {
  return Padding(
    padding: EdgeInsets.only(left: 21, top: 83),
    child: Text(
      'Resolution',
      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
    ),
  );
}

_buildAutoDetectedOpt() {
  return Container(
    margin: EdgeInsets.only(top: 50),
    color: Color(0xFFFFF792),
    height: 160,
    child: Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Auto detected',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text('1920', style: TextStyle(fontSize: 32)),
              SizedBox(width: 26),
              Text('x'),
              SizedBox(width: 26),
              Text('1080',
                  style: TextStyle(fontSize: 32, fontFamily: 'JetBrains Mono'))
            ],
          ),
        ],
      ),
    ),
  );
}

_buildCustomizeOpt() {
  return Container(
    margin: EdgeInsets.only(top: 5),
    color: Color(0xFFFFF792),
    height: 163,
    child: Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customize',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 80,
                child: TextFormField(
                  autofocus: false,
                  style: TextStyle(fontSize: 32),
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 26),
              Text('x'),
              SizedBox(width: 26),
              Container(
                width: 80,
                child: TextFormField(
                  autofocus: false,
                  style: TextStyle(fontSize: 32),
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

_buildNextButton(BuildContext context) {
  return InkWell(
      child: Container(
        color: Color(0xFF669AFF),
        alignment: Alignment.center,
        child: Text(
          'Next',
          style: TextStyle(fontSize: 30),
        ),
        height: 66,
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EditPage(),
          ),
        );
      });
}
