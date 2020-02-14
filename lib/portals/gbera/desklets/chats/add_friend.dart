import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';

class AddFriend extends StatefulWidget {
  PageContext context;

  AddFriend({this.context});

  @override
  _AddFriendState createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加朋友'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            CardItem(
              leading: Icon(
                Icons.group,
              ),
              title: '公众',
              subtitle: Text(
                '向网流的公众申请成为朋友',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              onItemTap: () {
                widget.context.forward('/portlet/chat/imports/persons');
              },
            ),
            Divider(
              height: 1,
              indent: 40,
            ),
            CardItem(
              leading: Icon(
                FontAwesomeIcons.phone,
              ),
              title: '行人',
              subtitle: Text(
                '向地圈的行人申请成为朋友',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
            Divider(
              height: 1,
              indent: 40,
            ),
            CardItem(
              leading: Icon(
                FontAwesomeIcons.qrcode,
              ),
              title: '扫一扫',
              subtitle: Text(
                '扫描二维码名片',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
