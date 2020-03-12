import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';

class TestInsiteMessages extends StatefulWidget {
  PageContext context;

  TestInsiteMessages({this.context});

  @override
  _TestInsiteMessagesState createState() => _TestInsiteMessagesState();
}

class _TestInsiteMessagesState extends State<TestInsiteMessages> {
  TextEditingController _jsonText;

  @override
  void initState() {
    super.initState();
    _jsonText = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('摸拟消息入站'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              child: FlatButton(
                child: Text('更新'),
                onPressed: () async {
                  List<dynamic> messages = json.decode(_jsonText.text);
                  IInsiteMessageService msgService =
                      widget.context.site.getService('/insite/messages');
                  var list = await msgService.pageMessage(1000,0);
                  print('消息个数：${list.length}');
                  await msgService.empty();
                  for (var obj in messages) {
                    print(obj);
                    if (await msgService.existsMessage(obj['id'])) {
                      continue;
                    }
                    InsiteMessage message = InsiteMessage(
                      obj['id'],
                      obj['docid'],
                      obj['upstreamPerson'],
                      obj['upstreamChannel'],
                      obj['sourceSite'],
                      obj['sourceApp'],
                      obj['creator'],
                      obj['ctime'],
                      obj['atime'],
                      obj['rtime'],
                      obj['dtime'],
                      obj['state'],
                      obj['digests'],
                      obj['wy'],
                      obj['location'],
                      widget.context.principal.person,
                    );
                    msgService.addMessage(message);
                  }
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: FutureBuilder(
                future: _loadInsiteMessageJson(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  _jsonText.text = snapshot.data ?? '';
                  return TextField(
                    controller: _jsonText,
                    minLines: 10,
                    maxLines: 1000,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _loadInsiteMessageJson(context) async {
    var json =
        DefaultAssetBundle.of(context).loadString('model/insite_messages.json');
    return json;
  }
}
