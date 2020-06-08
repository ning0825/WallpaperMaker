import 'package:flutter/material.dart';

// class EditRoute extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: EditRouteHome(),
//     );
//   }
// }

class EditRouteHome extends StatefulWidget {
  @override
  _EditRouteHomeState createState() => _EditRouteHomeState();
}

class _EditRouteHomeState extends State<EditRouteHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(child: Text('test')),
          ),
          Hero(
            tag: 'herotag',
            child: Container(
              width: double.infinity,
              height: 250,
              color: Colors.black,
            ),
          )
        ],
      ),
    );
  }
}
