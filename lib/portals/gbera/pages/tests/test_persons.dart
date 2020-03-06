import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/pics/downloads.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class TestUpstreamPersonService extends StatefulWidget {
  PageContext context;

  TestUpstreamPersonService({this.context});

  @override
  _TestUpstreamPersonServiceState createState() =>
      _TestUpstreamPersonServiceState();
}

class _TestUpstreamPersonServiceState extends State<TestUpstreamPersonService> {
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
        title: Text('公众'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              child: FlatButton(
                child: Text('更新'),
                onPressed: () async {
                  List<dynamic> persons = json.decode(_jsonText.text);
                  IPersonService personService =
                      widget.context.site.getService('/gbera/persons');
                  IChannelService channelService =
                      widget.context.site.getService('/netflow/channels');
                  Dio dio = widget.context.site.getService('@.http');
                  await personService.empty();
                  for (var obj in persons) {
                    if (await personService.existsPerson(obj['official'])) {
                      continue;
                    }
                    var avatar = await Downloads.downloadPersonAvatar(dio: dio,avatarUrl: obj['avatar']);
                    Person person = Person(
                      Uuid().v1(),
                      obj['official'],
                      obj['uid'],
                      obj['accountid'],
                      obj['accountName'],
                      obj['appid'],
                      obj['tenantid'],
                      avatar,
                      obj['rights'],
                      obj['nickName'],
                      obj['signature'],
                      StringUtil.isEmpty(obj['nickName'])?null:PinyinHelper.getPinyin(obj['nickName']),
                      widget.context.principal.person,
                    );
                    await personService.addPerson(person);
                    var objchs = obj['channels'];
                    if (objchs == null) {
                      continue;
                    }

                    await channelService.emptyOfPerson(person.official);
                    await channelService.initSystemChannel(widget.context.principal);
                    for (var och in objchs) {
                      if (await channelService.existsChannel(och['code'])) {
                        continue;
                      }
                      String leading=och['leading'];
                      if(!StringUtil.isEmpty(leading)){
                        leading=await Downloads.downloadChannelAvatar(dio: dio,avatarUrl: leading);
                      }
                      Channel ch = Channel(
                        Uuid().v1(),
                        och['code'],
                        och['name'],
                        och['owner'],
                        leading,
                        och['site'],
                        DateTime.now().millisecondsSinceEpoch,
                        widget.context.principal.person,
                      );
                      channelService.addChannel(ch);
                    }
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
                future: _loadUpstreamPersonJson(context),
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

  Future<String> _loadUpstreamPersonJson(context) async {
    var json = DefaultAssetBundle.of(context)
        .loadString('model/persons.json');
    return json;
  }
}
