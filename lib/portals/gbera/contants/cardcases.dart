import 'dart:io';

import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_contact_picker/easy_contact_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/contants/person_models.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;
import 'cardcase_models.dart';

class CardcasesPage extends StatefulWidget {
  PageContext context;

  CardcasesPage({this.context});

  @override
  _CardcasesPageState createState() => _CardcasesPageState();
}

class _CardcasesPageState extends State<CardcasesPage> {
  List<CardcaseInfo> _cardcases = [];

  @override
  void initState() {
    _syncDevice();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _syncDevice() async {
    // 申请权限

    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler()
            .requestPermissions([PermissionGroup.contacts]);
    // 申请结果
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted) {
      return;
    }
    final List<Contact> result = await EasyContactPicker().selectContacts();
    if (result == null) {
      return null;
    }

    result.forEach((f) async {
      var card = CardcaseInfo.formContact(f, true);
      _cardcases.add(card);
    });
    _handleList(_cardcases);

    if (mounted) {
      setState(() {});
    }
  }

  void _handleList(List<CardcaseInfo> list) {
    if (list == null || list.isEmpty) return;
    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(_cardcases);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(_cardcases);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('名片夹'),
        elevation: 0,
        titleSpacing: 0,
      ),
      body: AzListView(
        data: _cardcases,
        itemCount: _cardcases.length,
        itemBuilder: (BuildContext context, int index) {
          CardcaseInfo model = _cardcases[index];
          return _getCardcaseListItem(
            context,
            model,
            defHeaderBgColor: Color(0xFFE5E5E5),
            pageContext: widget.context,
          );
        },
        physics: BouncingScrollPhysics(),
        susItemBuilder: (BuildContext context, int index) {
          CardcaseInfo model = _cardcases[index];
          if ('↑' == model.getSuspensionTag()) {
            return Container();
          }
          return _getSusItem(context, model.getSuspensionTag());
        },
        indexBarData: ['☆', ...kIndexBarData],
        indexBarOptions: IndexBarOptions(
          needRebuild: true,
          ignoreDragCancel: true,
          downTextStyle: TextStyle(fontSize: 12, color: Colors.white),
          downItemDecoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.green),
          indexHintWidth: 120 / 2,
          indexHintHeight: 100 / 2,
          indexHintDecoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'lib/portals/gbera/images/ic_index_bar_bubble_gray.png'),
              fit: BoxFit.contain,
            ),
          ),
          indexHintAlignment: Alignment.centerRight,
          indexHintChildAlignment: Alignment(-0.25, 0.0),
          indexHintOffset: Offset(-20, 0),
        ),
      ),
    );
  }
}

Widget _getSusItem(BuildContext context, String tag, {double susHeight = 40}) {
  if (tag == '★') {
    tag = '★ 热门城市';
  }
  return Container(
    height: susHeight,
    width: MediaQuery.of(context).size.width,
    padding: EdgeInsets.only(left: 16.0),
    color: Theme.of(context).backgroundColor,
    alignment: Alignment.centerLeft,
    child: Text(
      '$tag',
      softWrap: false,
      style: TextStyle(
        fontSize: 14.0,
        color: Color(0xFF666666),
      ),
    ),
  );
}

Widget _getCardcaseListItem(
  BuildContext context,
  CardcaseInfo model, {
  double susHeight = 40,
  Color defHeaderBgColor,
  PageContext pageContext,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Offstage(
        offstage: !(model.isShowSuspension == true),
        child: _getSusItem(context, model.getSuspensionTag(),
            susHeight: susHeight),
      ),
      Container(
        color: Colors.white,
        child: _getCardcaseItem(context, model,
            defHeaderBgColor: defHeaderBgColor, pageContext: pageContext),
      ),
    ],
  );
}

Widget _getCardcaseItem(
  BuildContext context,
  CardcaseInfo model, {
  Color defHeaderBgColor,
  PageContext pageContext,
}) {
  var leading;
  if (model.phoneNumber.indexOf('@') < 0) {
    leading = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        var phoneNumber = model.phoneNumber;
        phoneNumber = model.trim(phoneNumber);
        await launch('tel://${phoneNumber}');
      },
      child: Icon(
        Icons.call,
        color: Colors.green,
      ),
    );
  } else {
    leading = Image.asset(
      'lib/portals/gbera/images/default_avatar.png',
      width: 20,
      height: 20,
    );
  }
  return Padding(
    padding: EdgeInsets.only(
      top: 10,
      bottom: 10,
    ),
    child: Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                var phoneNumber = model.phoneNumber;
                phoneNumber = model.trim(phoneNumber);
                var data = ClipboardData(text: phoneNumber);
                Clipboard.setData(data);
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('复制成功。电话号码：$phoneNumber'),
                ));
              },
              child: Row(
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: leading,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${model.fullName}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          '${model.phoneNumber ?? ''}',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ..._renderButtons(model, pageContext),
      ],
    ),
  );
}

List<Widget> _renderButtons(CardcaseInfo model, PageContext pageContext) {
  var items = <Widget>[];
  if (model.inSystem ?? false) {
    items.add(
      SizedBox(
        width: 10,
      ),
    );
    items.add(
      FutureBuilder<bool>(
        future: _existsAccount(pageContext, model.trim(model.phoneNumber)),
        builder: (ctx, snatshop) {
          if (snatshop.connectionState != ConnectionState.done) {
            return SizedBox(
              height: 0,
              width: 0,
            );
          }
          var exists = snatshop.data;
          if (!exists) {
            if (model.phoneNumber.indexOf('@') > 0) {
              return Row(
                children: [
                  FlatButton(
                    onPressed: () async {
                      var sliceId =
                          await _selectOrCreateQrcodeSlice(pageContext);
                      if (StringUtil.isEmpty(sliceId)) {
                        return;
                      }
                      var phoneNumber = model.phoneNumber;
                      phoneNumber = model.trim(phoneNumber);
                      await launch(
                          'mailto:$phoneNumber?subject=${pageContext.principal.nickName} 邀请您打码喽！&body='
                          '【地微】扫码不断有，惊喜不重样！\r\n'
                          '       \r\n'
                          '点击链接: http://nodespower.com/qrslice/?id=$sliceId\r\n');
                    },
                    child: Text(
                      '邀请打码',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                FlatButton(
                  onPressed: () async {
                    var sliceId = await _selectOrCreateQrcodeSlice(pageContext);
                    if (StringUtil.isEmpty(sliceId)) {
                      return;
                    }
                    var phoneNumber = model.phoneNumber;
                    phoneNumber = model.trim(phoneNumber);
                    String _result = await sendSMS(
                        message: ''
                            '【地微】扫码不断有，惊喜不重样！\r\n'
                            '       \r\n'
                            '点击链接: http://nodespower.com/qrslice/?id=$sliceId\r\n\r\n'
                            '             ${pageContext.principal.nickName} 邀请您！\r\n'
                            '**********************************',
                        recipients: [phoneNumber]).catchError(
                      (onError) {
                        print(onError);
                      },
                    );
                    print(_result);
                  },
                  child: Text(
                    '邀请打码',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ],
            );
          }
          return Row(
            children: [
              AddPersonButton(context: pageContext, model: model),
            ],
          );
        },
      ),
    );
    items.add(
      SizedBox(
        width: 10,
      ),
    );
  }
  return items;
}

Future<String> _selectOrCreateQrcodeSlice(PageContext pageContext) async {
  IRobotRemote robotRemote = pageContext.site.getService('/remote/robot');
  List<QrcodeSliceOR> slices = await robotRemote.listUnconsumeSlices();
  if (slices.isEmpty) {
    await pageContext.forward('/robot/createSlices');
    slices = await robotRemote.listUnconsumeSlices();
  }
  if (slices.isEmpty) {
    return null;
  }
  if (slices.length == 1) {
    return slices[0].id;
  }
  int index = Uuid().v1().hashCode.abs() % slices.length;
  return slices[index].id;
}

Future<bool> _existsAccount(PageContext context, phoneNumber) async {
  if (StringUtil.isEmpty(phoneNumber)) {
    return false;
  }
  IPersonService personService = context.site.getService('/gbera/persons');
  return await personService.existsAccount(phoneNumber);
}

class AddPersonButton extends StatefulWidget {
  PageContext context;
  CardcaseInfo model;

  AddPersonButton({this.context, this.model});

  @override
  _AddPersonButtonState createState() => _AddPersonButtonState();
}

class _AddPersonButtonState extends State<AddPersonButton> {
  bool _added = false;
  Person _person;
  bool _isWorking = false;

  @override
  void initState() {
    _existsPerson();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(AddPersonButton oldWidget) {
    if (oldWidget.model != widget.model) {
      oldWidget.model = widget.model;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _existsPerson() async {
    var phoneNumber = widget.model.phoneNumber;
    phoneNumber = widget.model.trim(phoneNumber);
    if (StringUtil.isEmpty(phoneNumber)) {
      return false;
    }
    var p = '${phoneNumber}@gbera.netos';
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _added = await personService.existsPerson(p);
    _person = await personService.getPerson(
      p,
      isDownloadAvatar: true,
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _addPerson() async {
    setState(() {
      _isWorking = true;
    });
    var phoneNumber = widget.model.phoneNumber;
    phoneNumber = widget.model.trim(phoneNumber);
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    await personService.addPerson(_person, isOnlyLocal: true);
    _existsPerson();
    if (mounted) {
      setState(() {
        _isWorking = false;
      });
    }
  }

  Future<void> _removePerson() async {
    setState(() {
      _isWorking = true;
    });
    var phoneNumber = widget.model.phoneNumber;
    phoneNumber = widget.model.trim(phoneNumber);
    var person = '$phoneNumber@gbera.netos';
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    await personService.removePerson(
      person,
    );
    _existsPerson();
    if (mounted) {
      setState(() {
        _isWorking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_person == null) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }
    var url = _person.avatar;
    Widget avatarImage;
    if (StringUtil.isEmpty(url)) {
    } else if (url.startsWith('/')) {
      avatarImage = Image.file(
        File('$url'),
      );
    } else {
      avatarImage = FadeInImage.assetNetwork(
        placeholder: 'lib/portals/gbera/images/default_watting.gif',
        image: '$url?accessToken=${widget.context.principal.accessToken}',
      );
    }
    var items = <Widget>[
      Text(
        '${_person.nickName ?? ''}',
        style: TextStyle(
          fontSize: 12,
        ),
      ),
      SizedBox(
        height: 5,
      ),
    ];
    if (!_added) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _isWorking
              ? null
              : () {
                  _addPerson();
                },
          child: Text(
            _isWorking ? '加为公众...' : '加为公众',
            style: TextStyle(
              fontSize: 10,
              color: Colors.red,
            ),
          ),
        ),
      );
    } else {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _isWorking
              ? null
              : () {
                  _removePerson();
                },
          child: Text(
            _isWorking ? '不再加为公众...' : '不再加为公众',
            style: TextStyle(
              fontSize: 10,
              color: Colors.red,
            ),
          ),
        ),
      );
    }
    var panel = Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context
                .forward('/person/view', arguments: {'person': _person});
          },
          child: SizedBox(
            width: 30,
            height: 30,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: avatarImage,
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: items,
        ),
        SizedBox(
          width: 25,
        ),
      ],
    );

    return panel;
  }
}
