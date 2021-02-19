import 'dart:async';

import 'package:flutter/material.dart';
import 'package:leancloud_feedback/leancloud_feedback.dart';
import 'package:wallpaper_maker/inherited_config.dart';
import 'package:wallpaper_maker/routes/route_feedbackMessage.dart';

class FeedbackRoute extends StatefulWidget {
  @override
  _FeedbackRouteState createState() => _FeedbackRouteState();
}

class _FeedbackRouteState extends State<FeedbackRoute>
    with WidgetsBindingObserver {
  TextEditingController _textController;
  ConfigWidgetState data;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();

    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      data.checkContact(
        () => showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: TextField(
                controller: _textController,
              ),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('cancel')),
                FlatButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_textController.text),
                    child: Text('ok')),
              ],
            );
          },
        ),
      );
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('My feedbacks'),
          backgroundColor: Colors.white,
          textTheme: ThemeData.light().textTheme,
          actionsIconTheme: ThemeData.light().iconTheme,
          iconTheme: ThemeData.light().iconTheme,
          actions: [
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => FeedbackMessages(),
                  ));
                }),
          ],
        ),
        body: StreamBuilder<List<Thread>>(
          stream: data.threadsStream,
          initialData: [],
          builder: (context, snapshot) {
            print(snapshot.connectionState.toString());
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (_, index) {
                      return ListTile(
                        title: Text(snapshot.data[index].content),
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) {
                            return FeedbackMessages(
                              threadId: snapshot.data[index].objectId,
                            );
                          }));
                        },
                      );
                    });
              } else if (snapshot.hasError) {
                print('snapshot.hasError');
              }
            } else {
              return Text('loading');
            }
            return Container();
          },
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state.toString() + '/state');
  }

  @override
  void dispose() {
    data.streamController.close();
    data.streamController = StreamController();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
