import 'dart:io';

import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:netos_app/portals/gbera/contants/person_models.dart';
import 'package:netos_app/portals/gbera/pages/netflow/search_person.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class PublicPersonsPage extends StatefulWidget {
  PageContext context;

  PublicPersonsPage({this.context});

  @override
  _PublicPersonsPageState createState() => _PublicPersonsPageState();
}

class _PublicPersonsPageState extends State<PublicPersonsPage> {
  List<ContactInfo> _contactList = [];

  @override
  void initState() {
    _onLoad();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _onLoad() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    List<Person> persons = await personService.pagePerson(10000000, 0);
    persons.forEach((v) {
      _contactList.add(ContactInfo.fromJson(v));
    });
    _handleList(_contactList);
  }

  void _handleList(List<ContactInfo> list) {
    if (list == null || list.isEmpty) return;
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(list[i].nickName);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = "#";
      }
    }
    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(_contactList);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(_contactList);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('公众'),
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          _getPopupMenu(),
        ],
      ),
      body: AzListView(
        data: _contactList,
        itemCount: _contactList.length,
        itemBuilder: (BuildContext context, int index) {
          ContactInfo model = _contactList[index];
          return _getContactListItem(
            context,
            model,
            defHeaderBgColor: Color(0xFFE5E5E5),
            pageContext: widget.context,
          );
        },
        physics: BouncingScrollPhysics(),
        susItemBuilder: (BuildContext context, int index) {
          ContactInfo model = _contactList[index];
          if ('↑' == model.getSuspensionTag()) {
            return Container();
          }
          return _getSusItem(context, model.getSuspensionTag());
        },
        indexBarData: ['↑', '☆', ...kIndexBarData],
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

  _getPopupMenu() {
    return PopupMenuButton<String>(
      offset: Offset(
        0,
        50,
      ),
      onSelected: (value) async {
        if (value == null) return;
        var arguments = <String, Object>{};
        switch (value) {
          case '/netflow/manager/search_person':
//            widget.context.forward(value, arguments: null);
            showSearch(
              context: context,
              delegate: PersonSearchDelegate(widget.context),
            ).then((v) {
              // __refresher.fireRefresh();
            });
            break;
          case '/netflow/manager/export_contacts':
            widget.context.forward('/cardcases');
            break;
          case '/netflow/manager/scan_person':
            String cameraScanResult = await scanner.scan();
            if (cameraScanResult == null) break;
            arguments['qrcode'] = cameraScanResult;
            widget.context.forward(value, arguments: arguments);
            break;
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: '/netflow/manager/search_person',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Icon(
                  Icons.youtube_searched_for,
                  color: Colors.grey[500],
                  size: 16,
                ),
              ),
              Text(
                '搜索以添加',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: '/netflow/manager/export_contacts',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Icon(
                  Icons.import_contacts,
                  color: Colors.grey[500],
                  size: 16,
                ),
              ),
              Text(
                '从通讯录导入',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: '/netflow/manager/scan_person',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Icon(
                  FontAwesomeIcons.qrcode,
                  color: Colors.grey[500],
                  size: 15,
                ),
              ),
              Text(
                '扫码以添加',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
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

Widget _getContactListItem(
  BuildContext context,
  ContactInfo model, {
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
        child: _getContactItem(context, model,
            defHeaderBgColor: defHeaderBgColor, pageContext: pageContext),
      ),
    ],
  );
}

Widget _getContactItem(
  BuildContext context,
  ContactInfo model, {
  Color defHeaderBgColor,
  PageContext pageContext,
}) {
  DecorationImage image;
  if (!StringUtil.isEmpty(model.avatar)) {
    var avatar = model.avatar;
    if (avatar.startsWith('/')) {
      image = DecorationImage(
        image: FileImage(File(avatar)),
        fit: BoxFit.contain,
      );
    } else {
      image = DecorationImage(
        image: CachedNetworkImageProvider(
            '$avatar?accessToken=${pageContext.principal.accessToken}'),
        fit: BoxFit.contain,
      );
    }
  }
  return ListTile(
    leading: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(4.0),
        color: model.bgColor ?? defHeaderBgColor,
        image: image,
      ),
      child: model.iconData == null
          ? null
          : Icon(
              model.iconData,
              color: Colors.white,
              size: 20,
            ),
    ),
    title: Text(model.nickName),
    onTap: () {
      if (pageContext.parameters['personViewer'] == 'chasechain') {
        pageContext
            .forward('/person/view', arguments: {'person': model.attach});
        return;
      }
      pageContext.forward('/site/personal',
          arguments: {'person': model.attach}).then((v) {});
    },
  );
}
