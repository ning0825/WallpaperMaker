import 'package:flutter/material.dart';
import 'package:leancloud_feedback/leancloud_feedback.dart';
import 'package:wallpaper_maker/inherited_config.dart';

class FeedbackMessages extends StatefulWidget {
  FeedbackMessages({this.threadId});

  final String threadId;

  @override
  _FeedbackMessagesState createState() => _FeedbackMessagesState();
}

class _FeedbackMessagesState extends State<FeedbackMessages> {
  ConfigWidgetState data;

  Future messageFuture;
  bool createdThread = false;
  List<Message> messages = [];
  String threadId;

  @override
  void initState() {
    super.initState();

    messageFuture = widget.threadId != null
        ? fetchMessages(widget.threadId)
        : noNeedFetch();
  }

  Future<List<Message>> noNeedFetch() async {
    return Future.value(<Message>[]);
  }

  @override
  Widget build(BuildContext context) {
    data = ConfigWidget.of(context);
    return Scaffold(
      body: FutureBuilder<List<Message>>(
          future: messageFuture,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                messages = snapshot.data;
                return ConversationWidget(
                  messages: messages,
                  onSendText: (s) async {
                    if (widget.threadId == null) {
                      if (createdThread) {
                        await userAppendMessage(threadId, s);
                        messages.add(Message(type: 'user', content: s));
                      } else {
                        SendResponse send =
                            await createFeedback(s, data.contact);
                        threadId = send.objectId;
                        createdThread = true;
                        messages.add(Message(type: 'user', content: s));
                      }
                    } else {
                      await userAppendMessage(widget.threadId, s);
                      messages.add(Message(type: 'user', content: s));
                    }
                    setState(() {});
                  },
                );
              }
            }
            return Text('loading');
          }),
    );
  }
}
