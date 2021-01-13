import 'dart:io';

import 'package:accept_share/accept_share.dart';
import 'package:buddy_push/buddy_push.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/local/local_principals.dart';

import 'parts/bottoms.dart';
import 'parts/parts.dart';

class WithBottomScaffold extends StatefulWidget {
  PageContext context;

  WithBottomScaffold({this.context});

  @override
  _WithBottomScaffoldState createState() => _WithBottomScaffoldState();
}

class _WithBottomScaffoldState extends State<WithBottomScaffold> {
  int selectedIndex = 0;
  var parts = <Widget>[];
  var wallpaper;
  PageController _pageController;

  @override
  void initState() {
    //记住，分享事件只能放这
    AcceptShare.setCallback((call) async {
      if (!call.method.startsWith('forward')) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _forwardShare(call.method, call.arguments);
      });
    });
    IPlatformLocalPrincipalManager _localPrincipalManager =
        widget.context.site.getService('/local/principals');
    bool isOnline = false;
    BuddyPush.supportsDriver((driver, isSupports) async {
      if (!isSupports) {
        print('--------online 1');
        isOnline = true;
        await _localPrincipalManager.online();
      }
    });
    BuddyPush.onEvent(
      onError: (driver, error) async {
        isOnline = true;
        await _localPrincipalManager.online();
      },
      onToken: (driver, regId) async {
        print('----onToken-----:$driver $regId');
        if (widget.context.principal.device != regId) {
          var device = '$driver://$regId';
          await _localPrincipalManager.updateDevice(device);
        }
        print('--------online 2');
        isOnline = true;
        await _localPrincipalManager.online();
      },
    );
    Future.delayed(Duration(seconds: 3), () async {
      if (isOnline) {
        return;
      }
      print('--------online 3');
      await _localPrincipalManager.online();
      isOnline = true;
    });
    super.initState();
    _pageController = PageController(initialPage: this.selectedIndex);
    wallpaper = widget.context.sharedPreferences().getString('@.wallpaper',
        person: widget.context.principal.person,
        scene: widget.context.currentScene());
    widget.context.parameters['use_wallpapper'] =
        StringUtil.isEmpty(wallpaper) ? false : true;

    parts.add(widget.context.part('/desktop', context,
        arguments: {'From-Page-Url': widget.context.page.url}));
    parts.add(widget.context.part('/netflow', context,
        arguments: {'From-Page-Url': widget.context.page.url}));
    parts.add(widget.context.part('/geosphere', context,
        arguments: {'From-Page-Url': widget.context.page.url}));
    parts.add(widget.context.part('/chasechain', context,
        arguments: {'From-Page-Url': widget.context.page.url}));
    parts.add(widget.context.part('/market', context,
        arguments: {'From-Page-Url': widget.context.page.url}));
  }

  @override
  void dispose() {
    parts.clear();
    selectedIndex = 0;
    _pageController.dispose();
    super.dispose();
  }

  _forwardShare(String action, Map arguments) {
    switch (action) {
      case 'forwardEasyTalk':
        widget.context.forward(
          "/share/easyTalk",
          clearHistoryByPagePath: '.',
          arguments: arguments.cast<String, Object>(),
        );
        break;
      case 'forwardNetflow':
        widget.context.forward(
          "/share/netflow",
          clearHistoryByPagePath: '.',
          arguments: arguments.cast<String, Object>(),
        );
        break;
      case 'forwardGeosphere':
        widget.context.forward(
          "/share/geosphere",
          clearHistoryByPagePath: '.',
          arguments: arguments.cast<String, Object>(),
        );
        break;
      case 'forwardTiptool':
        widget.context.forward(
          "/share/tiptool",
          clearHistoryByPagePath: '.',
          arguments: arguments.cast<String, Object>(),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    wallpaper = widget.context.sharedPreferences().getString('@.wallpaper',
        scene: widget.context.currentScene(),
        person: widget.context.principal.person);
    var use_wallpapper = widget.context.parameters['use_wallpapper'] =
        StringUtil.isEmpty(wallpaper) ? false : true;
    return Scaffold(
//      appBar: headers[selectedIndex],
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: use_wallpapper ? getWallpaperImage(wallpaper) : null,
        ),
        child: PageView(
          physics: NeverScrollableScrollPhysics(), //禁止页面左右滑动切换
          controller: _pageController,
          children: parts,
        ),
      ),
      bottomNavigationBar: GberaBottomNavigationBar(
        pageContext: widget.context,
        selectedIndex: selectedIndex,
        onSelected: (index) {
          setState(() {
            this.selectedIndex = index;
            this._pageController.jumpToPage(this.selectedIndex);
          });
        },
      ),
    );
  }

  getWallpaperImage(String wallpaper) {
    if (wallpaper.startsWith('/')) {
      return DecorationImage(
        image: FileImage(File(wallpaper)),
        fit: BoxFit.cover,
      );
    }
    return DecorationImage(
      image: AssetImage(wallpaper),
      fit: BoxFit.cover,
    );
  }
}
