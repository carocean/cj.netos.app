import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/qrcode_scanner.dart';
import 'package:netos_app/portals/gbera/pages/netflow/search_person.dart';

getPersonsPagePopupMenu({BuildContext context,PageContext pageContext,Future<void>Function() refresh}) {
  return PopupMenuButton<String>(
    offset: Offset(
      0,
      50,
    ),
    onSelected: (value) async {
      if (value == null) return;
      switch (value) {
        case '/netflow/manager/search_person':
          showSearch(
            context: context,
            delegate: PersonSearchDelegate(pageContext),
          ).then((v) {
            refresh();
          });
          break;
        case '/netflow/manager/export_contacts':
          pageContext.forward('/cardcases').then((value) {
            refresh();
          });
          break;
        case '/netflow/manager/scan_person':
          var result=await qrcodeScanner.scan(context, pageContext);
          if(result=='yes') {
            refresh();
          }
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
