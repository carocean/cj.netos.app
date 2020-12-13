import 'dart:io';

import 'package:badges/badges.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/portlet_market.dart';
import 'package:netos_app/common/qrcode_scanner.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/profile/qrcode.dart' as person;
import 'package:netos_app/portals/gbera/pages/wallet/receivables.dart'
    as receivables;
import 'package:netos_app/portals/gbera/pages/wallet/payables.dart' as payables;
import 'package:netos_app/portals/gbera/store/remotes/feedback_tiptool.dart';

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
  CustomPopupMenuController _customPopupMenuController =
      CustomPopupMenuController();
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
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _customPopupMenuController?.dispose();
    _desklets.clear();
    _isloaded = false;
    super.dispose();
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
      widget.context.forward('/profile');
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
              Badge(
                position: BadgePosition.bottomStart(
                  bottom: 0,
                  start: 0,
                ),
                elevation: 0,
                showBadge: true,
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
                        color: Color(0xefFFFFFF),
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
                      ),
                    );
                  },
                  arrowColor: Colors.black38,
                  barrierColor: Colors.transparent,
                  pressType: PressType.singleClick,
                ),
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

class TipToolPanel extends StatefulWidget {
  PageContext context;

  TipToolPanel({this.context});

  @override
  _TipToolPanelState createState() => _TipToolPanelState();
}

class _TipToolPanelState extends State<TipToolPanel> {
  bool _isChecked = false;
  int _offset = 0;
  TipsDocOR _doc;

  @override
  void initState() {
    _readNextTipsDocs();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _readNextTipsDocs() async {
    ITipToolRemote tipToolRemote =
        widget.context.site.getService('/feedback/tiptool');
    var docs = await tipToolRemote.readNextTipsDocs(1, _offset);
    if (docs.isEmpty) {
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += docs.length;
    _doc = docs[0];
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var content;
    if (_doc == null) {
      content = Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          top: 20,
          bottom: 20,
        ),
        child: Text(
          '没有提示了',
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
          // color: Colors.white,
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
                      color: Colors.grey[600],
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
    }

    return Column(
      children: [
        content,
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isChecked = !_isChecked;
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
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
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
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                setState(() {});
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
          ],
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
