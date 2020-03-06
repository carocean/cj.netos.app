import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/local/local_principals.dart' as lp;

class ProfileEditor extends StatefulWidget {
  PageContext context;

  ProfileEditor({this.context});

  @override
  _ProfileEditorState createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  String _per = "";
  String _avatarFile;
  Map<String, dynamic> _personInfo = {};

  @override
  void initState() {
    super.initState();
    _avatarFile = widget.context.principal.avatarOnLocal;
    _loadPersonInfo().then((v) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _personInfo.clear();
    super.dispose();
  }

  Future<void> _loadPersonInfo() async {
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    await widget.context.portsCB(
      headline,
      restCommand: 'getPersonInfo',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
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

  Future<void> _updateAvatar(localAvatar) async {
    _avatarFile = localAvatar;
    setState(() {});
    var remoteAvatar = '';
    var map = await widget.context.upload(
        '/app',
        <String>[
          localAvatar,
        ],
        accessToken: widget.context.principal.accessToken,
        onSendProgress: (i, j) {
      _per = '${((i * 1.0 / j) * 100.00).toStringAsFixed(0)}%';
      setState(() {});
    });
    remoteAvatar = map[localAvatar];
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    await widget.context.portsCB(
      headline,
      restCommand: 'updatePersonAvatar',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      parameters: {
        'avatar': remoteAvatar,
      },
      onsucceed: ({rc, response}) async {
       lp. IPlatformLocalPrincipalManager manager =
            widget.context.site.getService('/local/principals');
        await manager.updateAvatar(
            widget.context.principal.person, localAvatar, remoteAvatar);
        setState(() {});
      },
      onerror: ({e, stack}) {
        print(e);
      },
    );
  }

  Future<void> _updateSex(sex) async {
    String headline =
        'get ${widget.context.site.getService('@.prop.ports.uc.person')} http/1.1';
    await widget.context.portsCB(
      headline,
      restCommand: 'updatePersonSex',
      headers: {
        'cjtoken': widget.context.principal.accessToken,
      },
      parameters: {
        'sex': sex,
      },
      onsucceed: ({rc, response}) async {
        _loadPersonInfo().then((v) {
          setState(() {});
        });
      },
      onerror: ({e, stack}) {
        print(e);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var bb = widget.context.parameters['back_button'];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: bb == null ? true : false,
        leading: getLeading(bb),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          shrinkWrap: true,
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context
                    .forward('/widgets/avatar')
                    .then((localAvatar) async {
                  if (StringUtil.isEmpty(localAvatar)) {
                    return;
                  }
                  _updateAvatar(localAvatar);
                });
              },
              child: Container(
                padding: EdgeInsets.only(
                  bottom: 15,
                  top: 15,
                ),
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
                              _avatarFile.startsWith('/')
                                  ? Image.file(
                                      File(_avatarFile),
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      '$_avatarFile?accessToken=${widget.context.principal.accessToken}',
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    ),
                              Positioned(
                                left: 0,
                                bottom: 0,
                                right: 0,
                                top: 0,
                                child: Center(
                                  child: Text(
                                    '$_per',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
            Divider(
              height: 1,
            ),
            Builder(
              builder: (context) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    var data =
                        ClipboardData(text: widget.context.principal.person);
                    Clipboard.setData(data);
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('复制成功'),
                    ));
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: 15,
                      top: 15,
                    ),
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
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Text(
                                widget.context.principal.person,
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
                      ],
                    ),
                  ),
                );
              },
            ),
            Divider(
              height: 1,
            ),
            Builder(
              builder: (context) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    var data =
                        ClipboardData(text: widget.context.principal.uid);
                    Clipboard.setData(data);
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('复制成功'),
                    ));
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: 15,
                      top: 15,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '用户号',
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
                                widget.context.principal.uid,
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
                      ],
                    ),
                  ),
                );
              },
            ),
            Divider(
              height: 1,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: false,
                    useRootNavigator: false,
                    builder: (context) {
                      return widget.context.part(
                          '/profile/editor/nickname?back_button=true', context);
                    }).then((v) {
                  setState(() {});
                });
              },
              child: Container(
                padding: EdgeInsets.only(
                  bottom: 15,
                  top: 15,
                ),
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
                            '${widget.context.principal.nickName}',
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
            Divider(
              height: 1,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: false,
                    useRootNavigator: false,
                    builder: (context) {
                      return widget.context.part(
                          '/profile/editor/realname?back_button=true', context,
                          arguments: {'personInfo': _personInfo});
                    }).then((v) {
                  _loadPersonInfo().then((v) {
                    setState(() {});
                  });
                });
              },
              child: Container(
                padding: EdgeInsets.only(
                  bottom: 15,
                  top: 15,
                ),
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
            Divider(
              height: 1,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: false,
                    useRootNavigator: false,
                    builder: (context) {
                      return widget.context.part(
                          '/profile/editor/sex?back_button=true', context,
                          arguments: {'personInfo': _personInfo});
                    }).then((map) {
                  _updateSex(map['sex']);
                });
              },
              child: Container(
                padding: EdgeInsets.only(
                  bottom: 15,
                  top: 15,
                ),
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
            Divider(
              height: 1,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: false,
                    useRootNavigator: false,
                    builder: (context) {
                      return widget.context.part(
                          '/profile/editor/signature?back_button=true',
                          context);
                    }).then((v) {
                  setState(() {});
                });
              },
              child: Container(
                padding: EdgeInsets.only(
                  bottom: 15,
                  top: 15,
                ),
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
                                '${widget.context.principal.signature ?? ''}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                ),
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                textDirection: TextDirection.rtl,
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
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward('/profile/editor/more',arguments: {'personInfo':_personInfo});
//                showModalBottomSheet(
//                    context: context,
//                    isScrollControlled: true,
//                    builder: (context) {
//                      return widget.context.part(
//                          '/profile/editor/more?back_button=true', context);
//                    });
              },
              child: Container(
                padding: EdgeInsets.only(
                  bottom: 15,
                  top: 15,
                ),
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

  getLeading(bb) {
    if (bb == null) return null;
    return IconButton(
      onPressed: () {
        widget.context.backward();
      },
      icon: Icon(
        Icons.clear,
        size: 18,
      ),
    );
  }
}
