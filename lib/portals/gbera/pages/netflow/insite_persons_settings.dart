import 'dart:io';

import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:netos_app/common/swipe_refresh.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/contants/person_models.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:uuid/uuid.dart';

class InsitePersonsSettings extends StatefulWidget {
  PageContext context;

  InsitePersonsSettings({this.context});

  @override
  _InsitePersonsSettingsState createState() => _InsitePersonsSettingsState();
}

class _InsitePersonsSettingsState extends State<InsitePersonsSettings> {
  PinPersonsSettingsStrategy _selected_insite_persons_strategy;
  Channel _channel;
  IChannelPinService _pinService;
  int _limit = 20;
  int _offset = 0;
  List<ContactInfo> _contactList = [];

  @override
  void initState() {
    _selected_insite_persons_strategy = PinPersonsSettingsStrategy.all_except;
    _channel = widget.context.parameters['channel'];
    _pinService = widget.context.site.getService('/channel/pin');
    _load();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _load() async {
    _selected_insite_persons_strategy =
        await _pinService.getInputPersonSelector(_channel.id);
    if (_selected_insite_persons_strategy !=
        PinPersonsSettingsStrategy.only_select) {
      print('进站网关仅支持选定的公众');
      return;
    }
    IChannelRemote channelRemote =
        widget.context.site.getService('/remote/channels');

    var offical = widget.context.principal.person;
    var persons = await channelRemote.pageInputPersonOf(
        _channel.id, offical, _limit, _offset);

    persons.forEach((v) {
      if (offical == v.official) {
        return true;
      }
      _contactList.add(ContactInfo.fromJson(v));
    });
    _handleList(_contactList);
  }

  void _handleList(List<ContactInfo> list) {
    if (list == null || list.isEmpty) {
      if (mounted) {
        setState(() {});
      }
      return;
    }
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

  Future<bool> _isAllowPerson(official) async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var person = await personService.getPerson(official);
    if (person.rights == 'denyUpstream' || person.rights == 'denyBoth') {
      return false;
    }
    return true;
  }

  Future<bool> _isAllowPersonRights(official) async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var person = await personService.getPerson(official);
    if (person.rights == 'denyUpstream' || person.rights == 'denyBoth') {
      return false;
    }
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    var o = await pinService.getInputPerson(person.official, _channel.id);
    if (o == null) {
      return false;
    }
    return (StringUtil.isEmpty(o.rights) || o.rights == 'allow') ? true : false;
  }

  Future<bool> _isAllowPersonInChannel(official) async {
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    var o = await pinService.getInputPerson(official, _channel.id);
    if (o == null) {
      return false;
    }
    return (StringUtil.isEmpty(o.rights) || o.rights == 'allow') ? true : false;
  }

  Future<void> _deny(official) async {
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
   await pinService.updateInputPersonRights(official, _channel.id, 'deny');
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _allow(official) async {
    IChannelPinService pinService =
    widget.context.site.getService('/channel/pin');
    await pinService.updateInputPersonRights(official, _channel.id, 'allow');
    if (mounted) {
      setState(() {});
    }
  }
  Future<void> _remove(official) async {
    IChannelPinService pinService =
    widget.context.site.getService('/channel/pin');
    await pinService.removeInputPerson(official, _channel.id, );
    _contactList.removeWhere((element) => element.person==official);
    if (mounted) {
      setState(() {});
    }
  }
  @override
  Widget build(BuildContext context) {
    var body;
    if (_contactList.isEmpty) {
      body = Container(
        constraints: BoxConstraints.expand(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '没有好友',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
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
        title: Text('权限'),
        elevation: 0,
        titleSpacing: 0,
        centerTitle: true,
      ),
      body: body,
    );
  }

  Widget _getSusItem(BuildContext context, String tag,
      {double susHeight = 40}) {
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
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          padding: EdgeInsets.only(
            right: 30,
          ),
          child: _getContactItem(
            context,
            model,
            defHeaderBgColor: defHeaderBgColor,
            pageContext: pageContext,
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
    var row = Row(
      children: [
        Stack(
          overflow: Overflow.visible,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(4.0),
                image: image,
              ),
            ),
            Positioned(
              right: -8,
              top: -3,
              child: FutureBuilder<bool>(
                future: _isAllowPersonRights(model.person),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done ||
                      snapshot.data) {
                    return SizedBox(
                      width: 0,
                      height: 0,
                    );
                  }
                  return Icon(
                    Icons.security,
                    size: 14,
                    color: Colors.red,
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            model.nickName,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FutureBuilder(
              future: _isAllowPerson(model.person),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState != ConnectionState.done ||
                    snapshot.data) {
                  return SizedBox(
                    width: 22,
                    height: 0,
                  );
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.context.forward('/site/personal/rights',
                        arguments: {'person': model.attach});
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 2,
                      bottom: 2,
                      left: 5,
                      right: 5,
                    ),
                    child: Icon(
                      IconData(0xe637, fontFamily: 'user_security'),
                      size: 14,
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              width: 10,
            ),
            FutureBuilder(
              future: _isAllowPersonInChannel(model.person),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return SizedBox(
                    width: 0,
                    height: 0,
                  );
                }
                var isAllow = snapshot.data;
                if (isAllow) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _deny(model.person);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 2,
                        bottom: 2,
                        left: 5,
                        right: 5,
                      ),
                      child: Text(
                        '不再充许',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  );
                }
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _allow(model.person);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 2,
                      bottom: 2,
                      left: 5,
                      right: 5,
                    ),
                    child: Text(
                      '不再拒绝',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: (){
                _remove(model.person);
              },
              child: Padding(
                padding: EdgeInsets.only(
                  top: 2,
                  bottom: 2,
                  left: 5,
                  right: 5,
                ),
                child: Icon(
                  Icons.clear,
                  size: 14,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        pageContext.forward("/netflow/channel/portal/person", arguments: {
          'person': model.attach,
        });
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10,
          bottom: 10,
        ),
        child: row,
      ),
    );
  }
}
