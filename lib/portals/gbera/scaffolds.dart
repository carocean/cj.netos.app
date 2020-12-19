import 'package:accept_share/accept_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_plugin_record/flutter_plugin_record.dart';
import 'package:framework/framework.dart';

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
    AcceptShare.setCallback((call)async{
      if(!call.method.startsWith('forward')){
        return;
      }
      _forwardShare(call.method,call.arguments);
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
  _forwardShare(String action,Map arguments){
    switch(action){
      case 'forwardEasyTalk':
        widget.context.forward(
          "/share/easyTalk",
          clearHistoryByPagePath: '.',
          arguments: arguments.cast<String,Object>(),
        );
        break;
      case 'forwardNetflow':
        widget.context.forward(
          "/share/netflow",
          clearHistoryByPagePath: '.',
          arguments: arguments.cast<String,Object>(),
        );
        break;
      case 'forwardGeosphere':
        widget.context.forward(
          "/share/geosphere",
          clearHistoryByPagePath: '.',
          arguments: arguments.cast<String,Object>(),
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
          image: use_wallpapper
              ? DecorationImage(
                  image: AssetImage(wallpaper),
                  fit: BoxFit.cover,
                )
              : null,
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
}
