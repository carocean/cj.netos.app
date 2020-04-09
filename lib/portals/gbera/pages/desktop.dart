import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/framework.dart';

import 'package:netos_app/common/persistent_header_delegate.dart';
import 'package:netos_app/common/portlet_market.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class Desktop extends StatefulWidget {
  PageContext context;

  Desktop({
    this.context,
  });

  @override
  _DesktopState createState() => _DesktopState();
}

class _DesktopState extends State<Desktop>  {
  bool use_wallpapper = false;
  List<Widget> _desklets = [];
  bool _isloaded = false;


  @override
  void initState() {
    _load().then((v) {
      _isloaded = true;
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _desklets.clear();
    _isloaded = false;
    super.dispose();
  }

  Future<void> _load() async {
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
      SliverPersistentHeader(
        floating: false,
        pinned: true,
        delegate: GberaPersistentHeaderDelegate(
          title: Text(
            scaffold?.title ?? '',
          ),
          titleSpacing: 10,
          centerTitle: false,
          automaticallyImplyLeading: false,
          elevation: 0,
          actions: <Widget>[
            IconButton(
              // Use the FontAwesomeIcons class for the IconData
              icon: new Icon(Icons.crop_free),
              onPressed: () async {
                String cameraScanResult = await scanner.scan();
                showDialog(
                  context: context,
                  barrierDismissible: true, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('扫好友、扫地物、支付、收款等'),
                      content: Text(cameraScanResult),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('YES'),
                          onPressed: () {
                            print('yes...');
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('NO'),
                          onPressed: () {
                            print('no...');
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                      backgroundColor: Colors.yellowAccent,
                      elevation: 20,
                      semanticLabel: '哈哈哈哈',
                      // 设置成 圆角
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    );
                  },
                );
              },
            ),
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
                  _load().then((v) {
                    _desklets.clear();
                    if (mounted) {
                      setState(() {});
                    }
                  });
                });
              },
            ),
          ],
        ),
      ),
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
              Expanded(
                flex: 1,
                child: Text(
                  '桌面',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
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

    var myarea = CustomScrollView(
      shrinkWrap: true,
      slivers: _slivers,
    );
    return myarea;
  }
}

/// Sample time series data type.
class MyRow {
  final DateTime timeStamp;
  final int cost;

  MyRow(this.timeStamp, this.cost);
}
