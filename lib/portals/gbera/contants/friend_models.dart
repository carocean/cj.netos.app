import 'dart:convert';
import 'dart:ui';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:netos_app/system/local/entities.dart';

class FriendInfo extends ISuspensionBean{
  String nickName;
  String tagIndex;
  String namePinyin;

  Color bgColor;
  IconData iconData;

  String avatar;
  String person;
  String firstletter;
  dynamic attach;
  FriendInfo({
    this.nickName,
    this.tagIndex,
    this.namePinyin,
    this.bgColor,
    this.iconData,
    this.avatar,
    this.person,
    this.firstletter,
    this.attach,
  });

  FriendInfo.fromJson(Friend p)
      : nickName = p.nickName,
        avatar=p.avatar,
        person=p.official,
        attach=p,
        firstletter = null;

  Map<String, dynamic> toJson() => {
//        'id': id,
    'nickName': nickName,
    'avatar': avatar,
//        'firstletter': firstletter,
//        'tagIndex': tagIndex,
//        'namePinyin': namePinyin,
//        'isShowSuspension': isShowSuspension
  };

  @override
  String getSuspensionTag() => tagIndex;

  @override
  String toString() => json.encode(this);

}