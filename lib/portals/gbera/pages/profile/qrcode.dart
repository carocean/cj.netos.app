import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/qrcode_scanner.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Qrcode extends StatelessWidget {
  PageContext context;
  var qrcodeKey = GlobalKey();

  Qrcode({this.context});

  @override
  Widget build(BuildContext context) {
    var bb = this.context.parameters['back_button'];
    var data = <String, String>{};
    data['itis'] = 'profile.person';
    data['data'] = this.context.principal.person;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: bb == null ? true : false,
        leading: getLeading(bb),
      ),
      body: Container(
        alignment: Alignment.center,
        child: RepaintBoundary(
          key: qrcodeKey,
          child: QrImage(
            ///二维码数据
            data: jsonEncode(data),
            version: QrVersions.auto,
            size: 200.0,
            gapless: false,
            embeddedImage: FileImage(
              File(
                this.context.principal.avatarOnLocal,
              ),
            ),
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: Size(40, 40),
            ),
          ),
        ),
      ),
    );
  }

  getLeading(bb) {
    if (bb == null) return null;
    return IconButton(
      onPressed: () {
        this.context.backward();
      },
      icon: Icon(
        Icons.clear,
        size: 18,
      ),
    );
  }
}

void registerQrcodeAction(PageContext context) {
  if (qrcodeScanner.actions.containsKey('profile.person')) {
    return;
  }
  qrcodeScanner.actions['profile.person'] =
      QrcodeAction(parse: (itis, data) async {
    IPersonService personService = context.site.getService('/gbera/persons');

    var person = await personService.getPerson(
      data,
      isDownloadAvatar: true,
    );
    if (person == null) {
      return QrcodeInfo(
        title: '加为公众',
        tips: Row(
          children: [
            Text('用户不存在'),
          ],
        ),
        itis: itis,
        props: {'action': 'notExists', 'person': data},
      );
    }

    var avatar = person.avatar;
    var image;
    if (StringUtil.isEmpty(avatar)) {
      image = Image.asset('lib/portals/gbera/images/avatar.png');
    } else if (avatar.startsWith('/')) {
      image = Image.file(File(avatar));
    } else {
      image = FadeInImage.assetNetwork(
        placeholder: 'lib/portals/gbera/images/default_watting.gif',
        image: '$avatar?accessToken=${context.principal.accessToken}',
      );
    }
    var personWidget = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.forward('/person/view',
            arguments: {'person': person}).then((value) {});
      },
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: image,
          ),
          SizedBox(
            width: 10,
          ),
          Text('${person.nickName}'),
        ],
      ),
    );
    if (await personService.existsPerson(data)) {
      return QrcodeInfo(
        title: '加为公众',
        tips: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            personWidget,
            SizedBox(
              height: 20,
            ),
            Text(
              '已加为公众，取消选是',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
        itis: itis,
        props: {'action': 'remove', 'person': data},
      );
    }
    return QrcodeInfo(
      title: '加为公众',
      tips: personWidget,
      itis: itis,
      props: {'action': 'add', 'person': data},
    );
  }, doit: (info) async {
    IPersonService personService = context.site.getService('/gbera/persons');
    var action = info.props['action'];
    var person = info.props['person'];
    switch (action) {
      case 'notExists':
        break;
      case 'remove':
        await personService.removePerson(person);
        break;
      case 'add':
        var p = await personService.getPerson(
          person,
          isDownloadAvatar: true,
        );
        await personService.addPerson(
          p,
          isOnlyLocal: true,
        );
        break;
    }
  });
}
