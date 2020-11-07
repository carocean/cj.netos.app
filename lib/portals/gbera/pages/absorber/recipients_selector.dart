import 'dart:io';

import 'package:azlistview/azlistview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:netos_app/common/swipe_refresh.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/contants/person_models.dart';
import 'package:netos_app/portals/gbera/pages/netflow/search_person.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:uuid/uuid.dart';

Map<String, bool> _selected = {};

class AbsorberRecipientsSelector extends StatefulWidget {
  PageContext context;

  AbsorberRecipientsSelector({this.context});

  @override
  _AbsorberRecipientsSelectorState createState() =>
      _AbsorberRecipientsSelectorState();
}

class _AbsorberRecipientsSelectorState
    extends State<AbsorberRecipientsSelector> {
  List<ContactInfo> _contactList = [];
  List<String> _selectedFriends = [];
  String _absorberId;

  @override
  void initState() {
    _absorberId = widget.context.parameters['absorberId'];
    _onLoad();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refresh() async {
    _contactList.clear();
    _onLoad();
  }

  Future<void> _onLoad() async {
    //每次仅判断选500个洇取人是否在公众中，且仅取100个公共来配，如果想配更多则再次打开来配
    IPersonService personService =
        widget.context.site.getService("/gbera/persons");
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    var recipients = await robotRemote.pageRecipients(_absorberId, 500, 0);
    var ids = <String>[];
    for (var r in recipients) {
      ids.add(r.person);
    }
    List<Person> friends = await personService.pagePersonWithout(ids, 100, 0);
    friends.forEach((v) {
      if (v.official == widget.context.principal.person) {
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

  @override
  Widget build(BuildContext context) {
    var body;
    if (_contactList.isEmpty) {
      body = Container(
        constraints: BoxConstraints.expand(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              '没有其他可选公众',
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
        title: Text('添加成员'),
        titleSpacing: 0,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              FontAwesomeIcons.userPlus,
              size: 20,
            ),
            onPressed: () {
              widget.context.forward('/contacts/person/selector').then((value) {
                _refresh();
              });
            },
          ),
        ],
      ),
      body: _RenderBody(body),
    );
  }

  Widget _RenderBody(body) {
    if (_selectedFriends.isEmpty) {
      return body;
    }
    var items = <Widget>[];
    for (var friend in _contactList) {
      if (items.length >= 11) {
        //最多显示11个已选中的,带上一个更多总共12个
        break;
      }
      for (var person in _selectedFriends) {
        if (friend.person != person) {
          continue;
        }
        items.add(
          Container(
            width: 40,
            height: 40,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Friend f = friend.attach;
                widget.context.forward('/person/view',
                    arguments: {'person': f.toPerson()});
              },
              onLongPress: () {
                _selectedFriends.removeWhere((p) {
                  return p == person;
                });
                setState(() {});
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: getAvatarWidget(friend.avatar, widget.context),
              ),
            ),
          ),
        );
      }
    }
    if (items.isNotEmpty) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context.forward('/contacts/friend/selected', arguments: {
              'selected': _selectedFriends,
            });
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                width: 1,
                color: Colors.grey[400],
              ),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: 10,
            bottom: 10,
          ),
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: items,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: body,
        ),
        Container(
          padding: EdgeInsets.only(
            top: 10,
            bottom: 10,
          ),
          child: Center(
            child: SizedBox(
              height: 30,
              child: RaisedButton(
                onPressed: () {
                  widget.context.backward(result: _selectedFriends);
                },
                color: Colors.green,
                textColor: Colors.white,
                child: Text(
                  '完成(${_selectedFriends.length})',
                ),
              ),
            ),
          ),
        )
      ],
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
    double susHeight = 30,
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
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          child: Row(
            children: [
              Expanded(
                child: _getContactItem(
                  context,
                  model,
                  defHeaderBgColor: defHeaderBgColor,
                  pageContext: pageContext,
                  refresh: refresh,
                ),
              ),
            ],
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
      if (avatar.startsWith(':')) {
        switch (avatar) {
          case ':around':
            image = DecorationImage(
              image: AssetImage('lib/portals/gbera/images/zhoubian.png'),
              fit: BoxFit.contain,
            );
            break;
          default:
            image = DecorationImage(
              image: AssetImage('lib/portals/gbera/images/default_image.png'),
              fit: BoxFit.contain,
            );
            break;
        }
      } else if (avatar.startsWith('/')) {
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (model.person == '↑') {
          widget.context.forward('/chat/friend/around',
              arguments: {'selected': _selectedFriends}).then((value) {
            if (value == null) {
              return;
            }
            for (var v in value) {
              if (_selectedFriends.contains(v)) {
                continue;
              }
              _selectedFriends.add(v);
            }
            _refresh();
          });
          return;
        }
        if (_selectedFriends.contains(model.person)) {
          _selectedFriends.remove(model.person);
        } else {
          _selectedFriends.add(model.person);
        }
        setState(() {});
      },
      child: Container(
        constraints: BoxConstraints.tightForFinite(
          width: double.maxFinite,
        ),
        padding: EdgeInsets.only(
          top: 10,
          bottom: 10,
        ),
        child: Row(
          children: [
            model.person == '↑'
                ? SizedBox(
                    width: 0,
                    height: 0,
                  )
                : Container(
                    width: 30,
                    margin: EdgeInsets.only(
                      left: 15,
                    ),
                    child: Center(
                      child: Radio(
                        value: _selectedFriends.contains(model.person),
                        groupValue: true,
                        activeColor: Colors.green,
                        onChanged: (v) {
                          if (v) {
                            _selectedFriends.add(model.person);
                          } else {
                            _selectedFriends.remove(model.person);
                          }
                          setState(() {});
                        },
                      ),
                    ),
                  ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(4.0),
                      // color: model.bgColor ?? defHeaderBgColor,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
