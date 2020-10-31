
import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:easy_contact_picker/easy_contact_picker.dart';
import 'package:flutter/material.dart';
import 'package:netos_app/system/local/entities.dart';

class ContactInfo extends ISuspensionBean {
  String nickName;
  String tagIndex;
  String namePinyin;

  Color bgColor;
  IconData iconData;

  String avatar;
  String person;
  String firstletter;
  dynamic attach;
  ContactInfo({
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

  ContactInfo.fromJson(Person p)
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
