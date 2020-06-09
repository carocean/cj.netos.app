import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';

class Profile extends StatefulWidget {
  PageContext context;

  Profile({this.context});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
  Widget build(BuildContext context) {
    var header = Padding(
      padding: EdgeInsets.only(
        top: 80,
        left: 10,
        right: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget.context.forward('/profile/editor').then((v){

                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: CircleAvatar(
                          backgroundImage: FileImage(
                            File(
                              widget.context.principal.avatarOnLocal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget.context.forward('/profile/editor');
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 5,
                            ),
                            child: Text(
                              '${widget.context.principal.nickName}',
                              style: widget
                                  .context
                                  .style('/profile/header-face-title.text'),
                            ),
                          ),
                          Text(
                            '${widget.context.principal?.person}',
                            style: widget
                                .context
                                .style('/profile/header-face-no.text'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
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
                  child:
                  widget.context.style('/profile/header-right-qrcode.icon'),
                ),
              ),
              widget.context.style('/profile/header-right-arrow.icon'),
            ],
          ),
        ],
      ),
    );
    var card_1 = Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //钱包
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward('/wallet');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      widget.context.findPage('/wallet').icon,
                      size: 30,
                      color:
                      widget.context.style('/profile/list/item-icon.color'),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.context.findPage('/wallet').title,
                          style: widget
                              .context
                              .style('/profile/list/item-title.text'),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          size: 20,
                          color: Colors.grey[400],
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
            indent: 40,
          ),
          //我的生意
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              onTap: () {
                widget.context.forward('/scaffolds/landagent',scene: 'landagent');
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      Icons.business,
                      size: 30,
                      color:
                      widget.context.style('/profile/list/item-icon.color'),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ///是用户的经营管理后台，如我有店铺就经营店铺，我有xx
                        Text(
                          '我是地商',
                          style: widget
                              .context
                              .style('/profile/list/item-title.text'),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          size: 20,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    var card_2 = Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[],
      ),
    );
    //设置
    var card_3 = Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //桌面设置
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward('/users/list');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      widget.context.findPage('/users/list')?.icon,
                      size: 30,
                      color:
                      widget.context.style('/profile/list/item-icon.color'),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.context.findPage('/users/list')?.title,
                          style: widget
                              .context
                              .style('/profile/list/item-title.text'),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          size: 20,
                          color: Colors.grey[400],
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
            indent: 40,
          ),
          //安全与隐私

          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/desktop/settings');
            },
            child: Container(
              padding: EdgeInsets.only(
                top: 15,
                bottom: 15,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      widget.context.findPage('/desktop/settings')?.icon,
                      size: 30,
                      color:
                      widget.context.style('/profile/list/item-icon.color'),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.context.findPage('/desktop/settings')?.title,
                          style: widget
                              .context
                              .style('/profile/list/item-title.text'),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          size: 20,
                          color: Colors.grey[400],
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
            indent: 40,
          ),
          //系统设置
          Container(
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward('/system/settings');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      widget.context.findPage('/system/settings').icon,
                      size: 30,
                      color:
                      widget.context.style('/profile/list/item-icon.color'),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '系统设置',
                          style: widget
                              .context
                              .style('/profile/list/item-title.text'),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          size: 20,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
//          title: Text(widget.context.page?.title,),
//          titleSpacing: 0,
//          centerTitle: false,
          backgroundColor: widget.context.style('/profile/header-bg.color'),
          elevation: 0.0,
          flexibleSpace: header,
          automaticallyImplyLeading: true,
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.only(
                top: 10,
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: card_1,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: card_2,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: card_3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

