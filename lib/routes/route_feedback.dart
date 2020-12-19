import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_maker/utils.dart';
import 'package:wallpaper_maker/models/send_response.dart';
import 'package:wallpaper_maker/models/thread_response.dart';
import 'package:wallpaper_maker/models/thread_detail_response.dart';

class FeedbackRoute extends StatefulWidget {
  @override
  _FeedbackRouteState createState() => _FeedbackRouteState();
}

class _FeedbackRouteState extends State<FeedbackRoute> {
  TextEditingController _controller;

  List<FeedbackMessage> messages = [];

  String threadId;

  bool isThreadIdExist = false;

  SharedPreferences sp;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();

    _initThread();
  }

  _initThread() async {
    await _getThreadId();
    if (isThreadIdExist) _getThreadInfo();
  }

  _sendMessage(String content) async {
    SendResponse sendResponse;
    if (isThreadIdExist) {
      sendResponse = await appendMessage(threadId, content);
    } else {
      sendResponse = await sendFeedback(content, 'contact');
      threadId = sendResponse.objectId;
      isThreadIdExist = true;
      _saveThreadId(threadId);
    }
    messages.add(FeedbackMessage(content, 'user'));
    _controller.clear();
    if (!isThreadIdExist) _saveThreadId(sendResponse.objectId);
    setState(() {});
  }

  _saveThreadId(String threadId) async {
    assert(sp != null);
    sp.setString('threadId', threadId);
  }

  _getThreadId() async {
    if (sp == null) {
      sp = await SharedPreferences.getInstance();
    }
    threadId = sp.get('threadId');
    isThreadIdExist = threadId != null;
  }

  _getThreadInfo() async {
    ThreadResponse threadInfo = await getThreadInfo(threadId);
    assert(threadInfo.results.length == 1,
        'Thread info result\'s length expected to be 1, but is ${threadInfo.results.length}');
    messages.add(FeedbackMessage(threadInfo.results[0].content, 'user'));

    ThreadDetailResponse detail = await getThreadDetail(threadId);
    detail.results.forEach((element) {
      messages.add(FeedbackMessage(element.content, element.type));
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return DevResponseWidget(
                    feedbackMessage: messages[index],
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                    ),
                  ),
                  RaisedButton(
                    child: Text('send'),
                    onPressed: () {
                      _sendMessage(_controller.text);
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FeedbackMessage {
  const FeedbackMessage(this.content, this.type);

  //This field's value is [user] or [dev].
  final String type;

  final dynamic content;
}

class DevResponseWidget extends StatelessWidget {
  DevResponseWidget({this.feedbackMessage});

  final FeedbackMessage feedbackMessage;

  @override
  Widget build(BuildContext context) {
    Widget result;
    if (feedbackMessage.type == 'dev') {
      result = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.developer_board,
            size: 50,
            color: Colors.black,
          ),
          Container(
            constraints: BoxConstraints.loose(Size(300, 1000)),
            padding: EdgeInsets.all(8),
            child: Text(feedbackMessage.content),
            decoration: BoxDecoration(border: Border.all()),
          ),
        ],
      );
    } else if (feedbackMessage.type == 'user') {
      result = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints.loose(Size(300, 1000)),
            padding: EdgeInsets.all(8),
            child: Text(feedbackMessage.content),
            decoration:
                BoxDecoration(border: Border.all(), color: Colors.greenAccent),
          ),
          Icon(
            Icons.supervised_user_circle,
            size: 50,
            color: Colors.black,
          ),
        ],
      );
    }
    return result;
  }
}
