import 'package:flutter/material.dart';
import 'package:wf_chat/model/conversation.dart';
import 'package:wf_chat/model/event.dart';
import 'package:wf_chat/wf_chat.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final WFChat _chat = WFChat();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              FlatButton(
                child: Text("登录"),
                onPressed: () async {
                  var result = await _chat.setDraftConversation(IMConversation(type: 1, target: "", line: 1), "Sending...");
                  print(result);
                },
              ),
              StreamBuilder<IMEventConnect>(
                  stream: _chat.connectStatus,
                  initialData: IMEventConnect(status: 1),
                  builder: (c, s) => Text("联网状态:${s.data.status}")),
              StreamBuilder<IMEventSendResult>(
                stream: _chat.sendResult,
                initialData: IMEventSendResult(status: 10),
                builder: (_, data) => Text("发送状态: ${data.data.status}"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
