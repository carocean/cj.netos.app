import 'dart:io';

import 'package:badges/badges.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/common/portlet_market.dart';
import 'package:netos_app/common/qrcode_scanner.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/profile/qrcode.dart' as person;
import 'package:netos_app/portals/gbera/pages/system/tiptool_opener.dart';
import 'package:netos_app/portals/gbera/pages/wallet/receivables.dart'
    as receivables;
import 'package:netos_app/portals/gbera/pages/wallet/payables.dart' as payables;
import 'package:netos_app/portals/gbera/store/remotes/feedback_tiptool.dart';
import 'package:netos_app/portals/gbera/store/remotes/operation_screen.dart';

class Desktop extends StatefulWidget {
  PageContext context;

  Desktop({
    this.context,
  });

  @override
  _DesktopState createState() => _DesktopState();
}

class _DesktopState extends State<Desktop> with AutomaticKeepAliveClientMixin {
  bool use_wallpapper = false;
  List<Widget> _desklets = [];
  bool _isloaded = false;
  EasyRefreshController _controller;

  bool _isChecked = false;

  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  void initState() {
    _controller = EasyRefreshController();
    _load().then((v) async {
      _isloaded = true;
      if (mounted) {
        setState(() {});
      }
    });
    _registerQrcodeActions();
    _checkScreenPopup();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _desklets.clear();
    _isloaded = false;
    super.dispose();
  }
  Future<void> _checkScreenPopup()async{
    IScreenRemote screenRemote =
    widget.context.site.getService('/desktop/screen');
    var screen=await screenRemote.getCurrent();
    if(screen==null){
      return;
    }
    var rule=screen.rule;
    switch(rule.code){
      case 'none':
        break;
      case 'after_installed':
        break;
      case 'every_opened':
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          showDialog(context: context,child: widget.context.part('/desktop/screen/popup', context));
        });
        break;
      case 'once_opened':
        break;
    }
  }
  _registerQrcodeActions() {
    receivables.registerQrcodeAction(widget.context);
    payables.registerQrcodeAction(widget.context);
    person.registerQrcodeAction(widget.context);
  }

  Future<void> _load() async {
    if (_isloaded) {
      _controller.finishLoad(success: true, noMore: true);
      return;
    }
    var portlets = await desktopManager.getInstalledPortlets(widget.context);
    if (portlets != null) {
      for (Portlet portlet in portlets) {
        var desklet = portlet.build(context: widget.context);
        _desklets.add(desklet);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isloaded) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    use_wallpapper = widget.context.parameters['use_wallpapper'];

    var onProfileTap = () {
      widget.context.forward('/profile').then((value) {
        if (mounted) {
          setState(() {});
        }
      });
    };
    var url = widget.context.page.parameters['From-Page-Url'];
    var scaffold = widget.context.findPage('$url');

    var _slivers = <Widget>[
      SliverToBoxAdapter(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 30,
                bottom: 30,
              ),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onProfileTap,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 10,
                      ),
                      child: CircleAvatar(
                        backgroundImage: FileImage(
                          File('${widget.context.principal.avatarOnLocal}'),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onProfileTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${widget.context.principal?.nickName}',
                          softWrap: true,
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        StringUtil.isEmpty(widget.context.principal.signature)
                            ? Container(
                                width: 0,
                                height: 0,
                              )
                            : Padding(
                                padding: EdgeInsets.only(
                                  top: 3,
                                ),
                                child: Text(
                                  '${widget.context.principal.signature}',
                                  softWrap: true,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 2),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              // Expanded(
              //   flex: 1,
              //   child: Text(
              //     '桌面',
              //     style: TextStyle(
              //       fontSize: 18,
              //     ),
              //   ),
              // ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 5,
                          ),
                          child: Text(
                            '',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          '',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    var lets_region = SliverToBoxAdapter(
      child: Container(
//            margin: EdgeInsets.only(left: 10,right: 10,),
        child: Column(
          children: _desklets,
        ),
      ),
    );
    _slivers.add(lets_region);
    var myarea = EasyRefresh.custom(
      header: MaterialHeader(),
      footer: MaterialFooter(),
      controller: _controller,
      onLoad: _load,
      slivers: _slivers,
    );
    return Column(
      children: <Widget>[
        MediaQuery.removePadding(
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          context: context,
          child: AppBar(
            title: Text(
              scaffold?.title ?? '',
            ),
            titleSpacing: 10,
            centerTitle: false,
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            toolbarOpacity: 1,
            actions: <Widget>[
              IconButton(icon: Icon(Icons.live_help_outlined,), onPressed: (){
                widget.context.forward('/system/help_feedback');
              },),
              TipToolButton(
                context: widget.context,
              ),
              IconButton(
                // Use the FontAwesomeIcons class for the IconData
                icon: new Icon(Icons.crop_free),
                onPressed: () async {
                  await qrcodeScanner.scan(context, widget.context);
                },
              ),
              /*
              IconButton(
                // Use the FontAwesomeIcons class for the IconData
                icon: new Icon(
                  widget.context.findPage('/desktop/lets/settings')?.icon,
                ),
                onPressed: () {
                  widget.context.forward(
                    '/desktop/lets/settings',
                    arguments: {
                      'back_button': true,
                    },
                  ).then((v) {
                    _desklets.clear();
                    _load().then((v) {
                      if (mounted) {
                        setState(() {});
                      }
                    });
                  });
                },
              ),
               */
            ],
          ),
        ),
        Expanded(
          child: myarea,
        ),
      ],
    );
  }
}

Function() _tipToolReadEndNotify;

class TipToolButton extends StatefulWidget {
  PageContext context;

  TipToolButton({this.context});

  @override
  _TipToolButtonState createState() => _TipToolButtonState();
}

class _TipToolButtonState extends State<TipToolButton> {
  CustomPopupMenuController _customPopupMenuController =
      CustomPopupMenuController();
  bool _canReadableTipDocs = false;

  @override
  void initState() {
    _tipToolReadEndNotify = () async {
      if (mounted) {
        _load();
      }
    };
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _customPopupMenuController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    ITipToolRemote tipToolRemote =
        widget.context.site.getService('/feedback/tiptool');
    _canReadableTipDocs = await tipToolRemote.totalReadableTipDocs() > 0;
    if (_canReadableTipDocs && mounted) {
      await _checkAutoShowTiptoolPanel();
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _checkAutoShowTiptoolPanel() async {
    var isShow = widget.context
        .sharedPreferences()
        .getString('tiptool.isShow', person: widget.context.principal.person);
    if (StringUtil.isEmpty(isShow) || isShow == 'true') {
      _customPopupMenuController.showMenu();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Badge(
      position: BadgePosition.bottomStart(
        bottom: 0,
        start: 0,
      ),
      elevation: 0,
      showBadge: _canReadableTipDocs,
      badgeContent: Text(
        '',
      ),
      child: CustomPopupMenu(
        controller: _customPopupMenuController,
        child: Padding(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Icon(
            Icons.lightbulb_outline_sharp,
            size: 25,
          ),
        ),
        menuBuilder: () {
          return Container(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 10,
              top: 15,
            ),
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            decoration: BoxDecoration(
              // color: Color(0xefFFFFFF),
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(
                    2,
                    2,
                  ),
                  blurRadius: 4,
                ),
              ],
            ),
            constraints: BoxConstraints(
              minHeight: 100,
              minWidth: 200,
            ),
            child: TipToolPanel(
              context: widget.context,
              controller: _customPopupMenuController,
            ),
          );
        },
        arrowColor: Colors.white,
        barrierColor: Colors.transparent,
        pressType: PressType.singleClick,
      ),
    );
  }
}

class TipToolPanel extends StatefulWidget {
  PageContext context;
  CustomPopupMenuController controller;

  TipToolPanel({this.context, this.controller});

  @override
  _TipToolPanelState createState() => _TipToolPanelState();
}

class _TipToolPanelState extends State<TipToolPanel> {
  bool _isChecked = false;
  TipsDocOR _doc;
  bool _isLoading = false;

  @override
  void initState() {
    () async {
      _isLoading = true;
      _readNextTipsDocs();
      await _checkAutoShowTiptoolPanel();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _readNextTipsDocs() async {
    ITipToolRemote tipToolRemote =
        widget.context.site.getService('/feedback/tiptool');
    var docs = await tipToolRemote.readNextTipsDocs(1, 0); //每次从0开始读1个
    if (docs.isEmpty) {
      _doc = null;
      if (_tipToolReadEndNotify != null) {
        _tipToolReadEndNotify();
      }
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _doc = docs[0];
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _checkAutoShowTiptoolPanel() async {
    var isShow = widget.context
        .sharedPreferences()
        .getString('tiptool.isShow', person: widget.context.principal.person);
    if (StringUtil.isEmpty(isShow) || isShow == 'true') {
      _isChecked = false;
    } else {
      _isChecked = true;
    }
  }

  Future<void> _setAutoShowTiptoolPanel() async {
    widget.context.sharedPreferences().setString(
        'tiptool.isShow', _isChecked ? 'false' : 'true',
        person: widget.context.principal.person);
  }

  @override
  Widget build(BuildContext context) {
    var content;
    if (_isLoading) {
      content = SizedBox();
    } else {
      if (_doc == null) {
        content = Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            top: 20,
            bottom: 20,
          ),
          child: Text(
            '没有提示！',
          ),
        );
      } else {
        content = Container(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            top: 5,
            bottom: 5,
          ),
          decoration: BoxDecoration(
            color: Color(0xeef5f5f5),
            // color: Colors.yellow,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 55,
                height: 55,
                child: getAvatarWidget(
                  _doc.leading,
                  widget.context,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_doc.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${_doc.summary}',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        content = InkWell(
          onTap: () {
            tiptoolOpener.open(_doc.id,
                context: widget.context, controller: widget.controller);
          },
          child: content,
        );
      }
    }

    var actions = <Widget>[];
    actions.add(
      InkWell(
        onTap: () {
          setState(() {
            _isChecked = !_isChecked;
            _setAutoShowTiptoolPanel();
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                  // shape: BoxShape.circle,
                  // color: Colors.blue,
                  ),
              child: _isChecked
                  ? Icon(
                      Icons.check,
                      size: 14.0,
                      color: Colors.green,
                    )
                  : Icon(
                      Icons.check_box_outline_blank,
                      size: 14.0,
                      color: Colors.grey,
                    ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              '不再自动弹出',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
    actions.add(
      SizedBox(
        width: 10,
      ),
    );
    actions.add(
      InkWell(
        onTap: () {
          widget.controller.hideMenu();
          widget.context.forward('/system/help_feedback');
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.help_center_outlined,
              size: 14,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              '帮助',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );

    if (_doc != null) {
      // actions.add(
      //   SizedBox(
      //     width: 10,
      //   ),
      // );
      // actions.add(
      //   InkWell(
      //     onTap: () {},
      //     child: Row(
      //       mainAxisSize: MainAxisSize.min,
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       children: [
      //         Icon(
      //           Icons.star_border,
      //           size: 14,
      //         ),
      //         SizedBox(
      //           width: 5,
      //         ),
      //         Text(
      //           '收藏',
      //           style: TextStyle(
      //             fontSize: 12,
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // );
      actions.add(
        SizedBox(
          width: 10,
        ),
      );
      actions.add(
        InkWell(
          onTap: () {
            _readNextTipsDocs();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '下一提示',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Icon(
                Icons.skip_next,
                size: 14,
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        content,
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions,
        ),
      ],
    );
  }
}

/// Sample time series data type.
class MyRow {
  final DateTime timeStamp;
  final int cost;

  MyRow(this.timeStamp, this.cost);
}
