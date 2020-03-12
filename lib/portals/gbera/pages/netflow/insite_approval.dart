import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/system/local/entities.dart';

class InsiteApprovals extends StatefulWidget {
  PageContext context;

  InsiteApprovals({this.context});

  @override
  _InsiteApprovalsState createState() => _InsiteApprovalsState();
}

class _InsiteApprovalsState extends State<InsiteApprovals> {
  InsiteMessage _message;
  Channel _channel;
  Person _person;

  @override
  void initState() {
    _message = widget.context.page.parameters['message'];
    _channel = widget.context.page.parameters['channel'];
    _person = widget.context.page.parameters['person'];
    super.initState();
  }

  @override
  void dispose() {
    _message = null;
    _channel = null;
    _person = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      fit: StackFit.expand,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              height: 40,
            ),
            Container(
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 5,
                    offset: Offset.zero,
                    blurRadius: 3,
                    color: Colors.grey[200],
                  ),
                ],
              ),
              margin: EdgeInsets.only(
                left: 40,
                right: 40,
              ),
              padding: EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () {
                  widget.context.backward();
                  widget.context.forward('/site/personal');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Image.file(
                        File(_person.avatar),
                        width: 40,
                        height: 40,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 2,
                            ),
                            child: Text(
                              '${_person.nickName ?? _person.accountName}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              text: '${_message.digests ?? ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 2,
                              top: 5,
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${TimelineUtil.format(
                                      _message.ctime,
                                      dayFormat: DayFormat.Simple,
                                    )}',
                                    children: [
                                      TextSpan(text: '  '),
                                    ],
                                  ),
                                  TextSpan(
                                    text: '洇金:¥',
                                    children: [
                                      TextSpan(
                                          text: (_message.wy * 0.001)
                                              .toStringAsFixed(2)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              margin: EdgeInsets.only(
                left: 40,
                right: 40,
              ),
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Container(
//                    color: Colors.white,
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CardItem(
                          paddingTop: 10,
                          paddingBottom: 10,
                          title: '拒收他的消息',
                          titleColor: Colors.grey,
                          titleSize: 12,
                          tail: Icon(
                            Icons.check,
                            color: Colors.red,
                            size: 14,
                          ),
                        ),
                        Divider(
                          height: 1,
                        ),
                        CardItem(
                          paddingTop: 10,
                          paddingBottom: 10,
                          title: '拒发消息给他',
                          titleColor: Colors.grey,
                          titleSize: 12,
                          tail: Icon(
                            Icons.check,
                            color: Colors.red,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 5,
                          offset: Offset.zero,
                          blurRadius: 3,
                          color: Colors.grey[200],
                        ),
                      ],
                    ),
                    child: FlatButton(
                      onPressed: () {
                        print('加入管道');
                      },
                      padding: EdgeInsets.only(
                        left: 50,
                        right: 50,
                      ),
                      child: Text.rich(
                        TextSpan(
                          text: '加入管道',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      '您可获得: ¥2.21',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 5,
                    offset: Offset.zero,
                    blurRadius: 3,
                    color: Colors.grey[200],
                  ),
                ],
              ),
              margin: EdgeInsets.only(
                top: 10,
              ),
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              child: FlatButton(
                onPressed: () {
                  widget.context.backward(result: {'action': 'cancel'});
                },
                child: Text(
                  '取消',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: -40,
          left: 20,
          child: Row(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 8,
                      color: Colors.white,
                    ),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _channel?.leading == null
                          ? AssetImage(
                              'lib/portals/gbera/images/netflow.png',
                            )
                          : FileImage(
                              File(
                                _channel?.leading,
                              ),
                            ),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        offset: Offset.zero,
                        spreadRadius: 3,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  print('xxxx');
                  widget.context.backward();
//                  widget.context.forward('/channel/viewer');
                  widget.context.forward('/netflow/portal/channel',
                      arguments: {'channel': _channel}).then((v) {});
                },
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 2,
                  right: 10,
                ),
                height: 55,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${_channel?.name}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
