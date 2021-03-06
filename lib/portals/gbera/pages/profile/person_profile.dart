import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class PersonProfile extends StatefulWidget {
  PageContext context;

  PersonProfile({this.context});

  @override
  _PersonProfileState createState() => _PersonProfileState();
}

class _PersonProfileState extends State<PersonProfile> {
  Person _person;
  Map<String, dynamic> _personInfo = {};
  List<dynamic> _accounts = [];
  bool _isLoading = false;
  int _index = 0;

  @override
  void initState() {
    _load();
    super.initState();
  }

  Future<void> _load() async {
    _isLoading = true;
    if (mounted) setState(() {});
    var person = widget.context.parameters['person'];
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _person = await personService.getPerson(person);
    await _loadPersonInfo();
    await _loadAccounts();
    _isLoading = false;
    if (mounted) setState(() {});
  }

  Future<void> _loadPersonInfo() async {
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    await widget.context.ports.callback(
      headline,
      restCommand: 'findPerson',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      parameters: {
        'person': _person.official,
      },
      onsucceed: ({rc, response}) async {
        var json = rc['dataText'];
        var info = jsonDecode(json);
        _personInfo.clear();
        _personInfo.addAll(info);
      },
      onerror: ({e, stack}) {
        print(e);
      },
    );
  }

  Future<void> _loadAccounts() async {
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    await widget.context.ports.callback(
      headline,
      restCommand: 'listAccountOfPerson',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      parameters: {
        'appid': _person.appid,
        'person': _person.official,
      },
      onsucceed: ({rc, response}) {
        String json = rc['dataText'];
        List<dynamic> list = jsonDecode(json);
        _accounts.clear();
        for (var obj in list) {
          if (obj['person'] == _person.official) {
            continue;
          }
          _accounts.add(obj);
        }
      },
      onerror: ({e, stack}) {
        print(e);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('个人信息'),
          elevation: 0,
        ),
        body: Column(
          children: <Widget>[
            Center(
              child: Text(
                '加载中...',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('个人信息'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                bottom: 15,
                top: 15,
                left: 15,
                right: 15,
              ),
              color: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '头像',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Stack(
                          children: <Widget>[
                            _person.avatar.startsWith('/')
                                ? Image.file(
                                    File(_person.avatar),
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                  )
                                : FadeInImage.assetNetwork(
                                    placeholder:
                                        'lib/portals/gbera/images/default_watting.gif',
                                    image:
                                        '${_person.avatar}?accessToken=${widget.context.principal.accessToken}',
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              height: 2,
              child: Divider(
                height: 1,
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                bottom: 15,
                top: 15,
                left: 15,
                right: 15,
              ),
              color: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '二维码',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          widget.context.forward('/profile/qrcode');
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: 8,
                          ),
                          child: widget.context
                              .style('/profile/header-right-qrcode.icon'),
                        ),
                      ),
                      widget.context.style('/profile/header-right-arrow.icon'),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              height: 2,
              child: Divider(
                height: 1,
              ),
            ),
            Builder(
              builder: (context) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    var data = ClipboardData(text: _person.official);
                    Clipboard.setData(data);
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('复制成功'),
                    ));
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: 15,
                      top: 15,
                      left: 15,
                      right: 15,
                    ),
                    color: Colors.white,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '公号',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(
                                    right: 5,
                                  ),
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _person.official,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.content_copy,
                                size: 16,
                                color: Colors.grey[500],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Container(
              color: Colors.white,
              height: 2,
              child: Divider(
                height: 1,
              ),
            ),
            Builder(
              builder: (context) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    var data = ClipboardData(text: _person.uid);
                    Clipboard.setData(data);
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('复制成功'),
                    ));
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: 15,
                      top: 15,
                      left: 15,
                      right: 15,
                    ),
                    color: Colors.white,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: _accounts.isEmpty
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '用户号',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: 5,
                                    ),
                                    child: Text(
                                      _person.uid,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.content_copy,
                                    size: 16,
                                    color: Colors.grey[500],
                                  ),
                                ],
                              ),
                              _accounts.isEmpty
                                  ? SizedBox(
                                      height: 0,
                                      width: 0,
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                        top: 20,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            '其它公号',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Container(
//                                      decoration: BoxDecoration(
//                                        borderRadius: BorderRadius.all(Radius.circular(8)),
//                                        border: Border.all(color: Colors.grey[200],width: 1,),
//                                      ),
                                            constraints:
                                                BoxConstraints.tightForFinite(
                                              width: double.maxFinite,
                                            ),
                                            padding: EdgeInsets.only(
                                              left: 10,
                                              top: 10,
                                              bottom: 10,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: _accounts.map((e) {
                                                _index++;
                                                Map<String, dynamic> obj =
                                                    e as Map<String, dynamic>;
                                                return Column(
                                                  children: <Widget>[
                                                    GestureDetector(
                                                      behavior: HitTestBehavior
                                                          .opaque,
                                                      onTap: () {
                                                        var data =
                                                            ClipboardData(
                                                                text: obj[
                                                                    'person']);
                                                        Clipboard.setData(data);
                                                        Scaffold.of(context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text('复制成功'),
                                                        ));
                                                      },
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                obj['avatar']
                                                                        .startsWith(
                                                                            '/')
                                                                    ? Image
                                                                        .file(
                                                                        File(_person
                                                                            .avatar),
                                                                        width:
                                                                            30,
                                                                        height:
                                                                            30,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      )
                                                                    : FadeInImage
                                                                        .assetNetwork(
                                                                        placeholder:
                                                                            'lib/portals/gbera/images/default_watting.gif',
                                                                        image:
                                                                            '${obj['avatar']}?accessToken=${widget.context.principal.accessToken}',
                                                                        width:
                                                                            30,
                                                                        height:
                                                                            30,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        '${obj['nickName']}',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        '${obj['person']}',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey[500],
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons.content_copy,
                                                            size: 16,
                                                            color: Colors.grey,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    _index == _accounts.length
                                                        ? SizedBox(
                                                            height: 0,
                                                            width: 0,
                                                          )
                                                        : SizedBox(
                                                            height: 30,
                                                            child: Divider(
                                                              height: 1,
                                                            ),
                                                          ),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Container(
              color: Colors.white,
              height: 2,
              child: Divider(
                height: 1,
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                bottom: 15,
                top: 15,
                left: 15,
                right: 15,
              ),
              color: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '昵称',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Text(
                          '${_person.nickName}',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              height: 2,
              child: Divider(
                height: 1,
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                bottom: 15,
                top: 15,
                left: 15,
                right: 15,
              ),
              color: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '实名',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Text(
                          '${_personInfo['realName'] ?? ''}',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              height: 2,
              child: Divider(
                height: 1,
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                bottom: 15,
                top: 15,
                left: 15,
                right: 15,
              ),
              color: Colors.white,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '性别',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Text(
                          '${_personInfo['sex'] != null ? _personInfo['sex'] == 'male' ? '男' : _personInfo['sex'] == 'female' ? '女' : '' : ''}',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              height: 2,
              child: Divider(
                height: 1,
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                bottom: 15,
                top: 15,
                left: 15,
                right: 15,
              ),
              color: Colors.white,
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '个人签名',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: 5,
                              left: 20,
                            ),
                            child: Text(
                              '${_person?.signature ?? ''}',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              height: 2,
              child: Divider(
                height: 1,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward('/profile/view/more',
                    arguments: {'personInfo': _personInfo});
              },
              child: Container(
                padding: EdgeInsets.only(
                  bottom: 15,
                  top: 15,
                  left: 15,
                  right: 15,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '更多',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 5,
                          ),
                          child: Text(
                            '电话/地址/等等',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                      ],
                    ),
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
