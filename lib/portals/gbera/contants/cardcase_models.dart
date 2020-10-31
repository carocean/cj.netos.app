import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:easy_contact_picker/easy_contact_picker.dart';
import 'package:framework/core_lib/_utimate.dart';

class CardcaseInfo extends ISuspensionBean {
  /// The full name of the contact, e.g. "Dr. Daniel Higgens Jr.".
  final String fullName;

  /// The phone number of the contact.
  final String phoneNumber;

  /// The firstLetter of the fullName.
  final String firstLetter;
  final bool inSystem;

  CardcaseInfo({
    this.fullName,
    this.phoneNumber,
    this.firstLetter,
    this.inSystem,
  });

  CardcaseInfo.formContact(Contact f,bool inSystem)
      : this.fullName = f.fullName,
        this.phoneNumber = f.phoneNumber,
        this.firstLetter = f.firstLetter,
        this.inSystem = inSystem;

  toMap() {
    return json.encode(this);
  }

  @override
  String getSuspensionTag() {
    return firstLetter;
  }
  trim(String str){
    if(StringUtil.isEmpty(str)) {
      return null;
    }
    return str.replaceAll(' ', '');
  }
}
