import 'dart:io';

import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:netos_app/portals/gbera/contants/person_menus.dart';
import 'package:netos_app/portals/gbera/contants/person_models.dart';
import 'package:netos_app/portals/gbera/pages/profile/qrcode.dart' as person;
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class PublicPersonsPage extends StatefulWidget {
  PageContext context;

  PublicPersonsPage({this.context});

  @override
  _PublicPersonsPageState createState() => _PublicPersonsPageState();
}

class _PublicPersonsPageState extends State<PublicPersonsPage> {
  List<ContactInfo> _contactList = [];
  TextEditingController _controller;
  String _query;
  FocusNode _focusNode;
  @override
  void initState() {
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _controller = TextEditingController();
    person.registerQrcodeAction(widget.context);
    _onLoad();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _contactList.clear();
    _onLoad();
  }

  Future<void> _onLoad() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    List<Person> persons;
    if (StringUtil.isEmpty(_query)) {
      persons = await personService.pagePerson(10000000, 0);
    } else {
      persons =
      await personService.pagePersonLikeName0('%$_query%', 10000000, 0);
    }
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
    var body;
    if (_contactList.isEmpty) {
      body = Container();
    } else {
      body = AzListView(
        data: _contactList,
        itemCount: _contactList.length,
        itemBuilder: (BuildContext context, int index) {
          ContactInfo model = _contactList[index];
          return _getContactListItem(
            context,
            model,
            defHeaderBgColor: Color(0xFFE5E5E5),
            pageContext: widget.context,
            refresh: _refresh,
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
      );
    }
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          onChanged: (v) {
            _query = v;
            _refresh();
          },
          onSubmitted: (v) {
            _query = v;
            _refresh();
          },
          focusNode: _focusNode,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          textAlign: _focusNode.hasFocus ? TextAlign.left : TextAlign.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            filled: true,
            fillColor: Theme.of(context).backgroundColor,
            hintText: _focusNode.hasFocus ?'输入公众名、电话、手机号':'公众',
            hintStyle: _focusNode.hasFocus
                ? null
                : TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
            suffix: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: (){
                _controller.clear();
                _query='';
                _refresh().then((value) {
                  _focusNode.nextFocus();
                });
              },
              child: Icon(Icons.clear,color: Colors.grey,size: 14,),
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        titleSpacing: 0,
        actions: <Widget>[
          getPersonsPagePopupMenu(
            refresh: _refresh,
            pageContext: widget.context,
            context: context,
          ),
        ],
      ),
      body: body,
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
  Future<void> Function() refresh,
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
        child: _getContactItem(
          context,
          model,
          defHeaderBgColor: defHeaderBgColor,
          pageContext: pageContext,
          refresh: refresh,
        ),
      ),
    ],
  );
}

Widget _getContactItem(
  BuildContext context,
  ContactInfo model, {
  Color defHeaderBgColor,
  PageContext pageContext,
  Future<void> Function() refresh,
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
      pageContext.forward('/person/view',
          arguments: {'person': model.attach}).then((value) {
        refresh();
      });
    },
  );
}
