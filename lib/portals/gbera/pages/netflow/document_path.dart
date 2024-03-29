import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/system/system.dart';

import 'cat_widget.dart';

class _ActivityInfo {
  String docid;
  Person creator;
  Person activitor;
  Channel channel;
  String action; //流转动作：send,arrive.comment,arrive.like
  String attach; //流转附件说明;
  int ctime; //流转操作触发时间
  String purchaseSn;

  _ActivityInfo({
    this.docid,
    this.creator,
    this.activitor,
    this.channel,
    this.action,
    this.attach,
    this.ctime,
    this.purchaseSn,
  });
}

class DocumentPath extends StatefulWidget {
  PageContext context;

  DocumentPath({this.context});

  @override
  _DocumentPathState createState() => _DocumentPathState();
}

class _DocumentPathState extends State<DocumentPath> {
  Person _person;
  InsiteMessage _message;
  Channel _channel;
  int _limit = 20, _offset = 0;
  List<_ActivityInfo> _activities = [];
  EasyRefreshController _controller;
  PurchaseOR _purchaseOR;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _person = widget.context.parameters['person'];
    _message = widget.context.parameters['message'];
    _channel = widget.context.parameters['channel'];
    _purchaseOR = widget.context.parameters['purchase'];
    _loadActivities().then((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _activities.clear();
    _channel = null;
    _message = null;
    _person = null;
    super.dispose();
  }

  Future<void> _loadActivities() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    var ports = widget.context.ports;
    var portsUrl =
        widget.context.site.getService('@.prop.ports.document.network.channel');
    var list = await ports.portGET(
      portsUrl,
      'pageExtraActivity',
      parameters: {
        'docid': _message.docid,
        'channel': _message.upstreamChannel,
        'creator': _message.creator,
        'limit': _limit,
        'offset': _offset,
      },
    );
    //[{docid: ab68db7ead9ac63440fb5df6bdba9ae7, creator: cj@gbera.netos, channel: fcf1aa24a815198b4b16886d4e3791e1, activitor: zxb@gbera.netos, atime: 1584634749930}, {docid: ab68db7ead9ac63440fb5df6bdba9ae7, creator: cj@gbera.netos, channel: fcf1aa24a815198b4b16886d4e3791e1, activitor: 18102759773@gbera.netos, atime: 1584634792531}]
    if (list.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      return;
    }
    _offset += list.length;
    for (var act in list) {
      var creator = await personService.getPerson(act['creator'],
          isDownloadAvatar: false);
      var activitor = await personService.getPerson(act['activitor'],
          isDownloadAvatar: false);
      var channel = await channelService.fetchChannelOfPerson(
          act['channel'], activitor.official);
      _activities.add(_ActivityInfo(
        docid: act['docid'],
        creator: creator,
        activitor: activitor,
        channel: channel,
        action: act['action'],
        attach: act['attach'],
        ctime: act['ctime'],
        purchaseSn: act['purchaseSn'],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    if (_activities.isEmpty) {
      items.add(
        Center(
          child: Padding(
            padding: EdgeInsets.only(
              top: 20,
            ),
            child: Text('正在加载...'),
          ),
        ),
      );
    }
    for (var act in _activities) {
      items.add(
        _ActivityCard(
          activityInfo: act,
          context: widget.context,
        ),
      );
      items.add(
        Divider(
          height: 1,
        ),
      );
    }
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, s) {
          return [
            SliverAppBar(
              elevation: 0,
              title: Text('流转'),
              pinned: true,
            ),
            SliverToBoxAdapter(
              child: _DocumentRegion(
                context: widget.context,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 20,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  bottom: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: (){
                              widget.context.forward("/netflow/channel/portal/channel", arguments: {
                                'channel': _channel.id,
                                'origin':_person.official,
                              });
                            },
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: getAvatarWidget(
                                    _channel.leading, widget.context,'lib/portals/gbera/images/netflow.png'),
                              ),
                            ),
                          ),
                          SizedBox(width: 10,),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: (){
                              widget.context.forward("/netflow/channel/portal/channel", arguments: {
                                'channel': _channel.id,
                                'origin':_person.official,
                              });
                            },
                            child: Text(
                              '${_channel.name}',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CatWidget(
                      context: widget.context,
                      person: _message?.creator,
                      size: 20,
                      canTap: true,
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Container(
          color: Colors.white,
          child: EasyRefresh(
            header: easyRefreshHeader(),
            footer: easyRefreshFooter(),
            controller: _controller,
            onLoad: _loadActivities,
            child: ListView(
              shrinkWrap: true,
              children: items,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatefulWidget {
  _ActivityInfo activityInfo;
  PageContext context;

  _ActivityCard({this.activityInfo, this.context});

  @override
  __ActivityCardState createState() => __ActivityCardState();
}

class __ActivityCardState extends State<_ActivityCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 15,
        bottom: 15,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.context.forward("/netflow/channel/portal/person",
                        arguments: {
                          'person': widget.activityInfo.activitor,
                        });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: getAvatarWidget(
                          widget.activityInfo.activitor.avatar,
                          widget.context,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          widget.context.forward("/netflow/channel/portal/person",
                              arguments: {
                                'person': widget.activityInfo.activitor,
                              });
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                            widget.activityInfo.activitor.nickName,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        runSpacing: 5,
                        children: <Widget>[
                          widget.activityInfo.action == 'send.comment'
                              ? Text(
                                  widget.activityInfo.attach ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : widget.activityInfo.action == 'send.like'
                                  ? Icon(
                                      Icons.favorite_border,
                                      size: 20,
                                      color: Colors.red,
                                    )
                                  : Icon(
                                      FontAwesomeIcons.planeArrival,
                                      size: 20,
                                      color: Colors.grey[500],
                                    ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 5,
                        ),
                        child: Row(
                          children: <Widget>[
//                            Padding(
//                              padding: EdgeInsets.only(
//                                right: 10,
//                              ),
//                              child: Text(
//                                '洇取:¥12.00',
//                                style: TextStyle(
//                                  fontSize: 12,
//                                  fontWeight: FontWeight.w500,
//                                  color: Colors.grey[500],
//                                ),
//                              ),
//                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                right: 10,
                              ),
                              child: Text(
                                TimelineUtil.format(
                                  widget.activityInfo.ctime,
                                  locale: 'zh',
                                  dayFormat: DayFormat.Simple,
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                widget.activityInfo?.channel != null
                                    ? SizedBox(width: 14,height: 14,child: getAvatarWidget(widget.activityInfo.channel.leading, widget.context,'lib/portals/gbera/images/netflow.png'),)
                                    : Container(
                                        width: 0,
                                        height: 0,
                                      ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 2,
                                  ),
                                  child: Text(
                                    widget.activityInfo?.channel?.name ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
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
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: widget.activityInfo.action == 'arrive' ? '送达' : '发出',
                ),
//                TextSpan(
//                  text:
//                      '${widget.activityInfo.action == 'arrive' ? TimelineUtil.format(widget.activityInfo.atime ?? '', dayFormat: DayFormat.Simple) : TimelineUtil.format(widget.activityInfo.ctime ?? '', dayFormat: DayFormat.Simple)}',
//                ),
              ],
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentRegion extends StatefulWidget {
  PageContext context;

  _DocumentRegion({this.context});

  @override
  __DocumentRegionState createState() => __DocumentRegionState();
}

class __DocumentRegionState extends State<_DocumentRegion> {
  Person _creator;
  InsiteMessage _message;
  PurchaseOR _purchaseOR;
  int _maxlines = 6;

  @override
  void initState() {
    _message = widget.context.parameters['message'];
    () async {
      await _loadCreator();
      _purchaseOR = await _getPurchase();
    }();

    super.initState();
  }

  @override
  void dispose() {
    _message = null;
    super.dispose();
  }

  Future<PurchaseOR> _getPurchase() async {
    var sn = _message.purchaseSn;
    if (StringUtil.isEmpty(sn)) {
      return null;
    }
    IWyBankPurchaserRemote purchaserRemote =
        widget.context.site.getService('/remote/purchaser');
    return await purchaserRemote.getPurchaseRecordPerson(_message.creator, sn);
  }

  Future<void> _loadCreator() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _creator = await personService.getPerson(_message.creator);
  }

  @override
  Widget build(BuildContext context) {
    if (_creator == null) {
      return Center(
        child: Text('加载中...'),
      );
    }
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(
        left: 30,
        right: 30,
      ),
//      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward("/netflow/channel/portal/person",
                  arguments: {
                    'person': _creator,
                  });
            },
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: SizedBox(
                  height: 60,
                  width: 60,
                  child: getAvatarWidget(
                    _creator.avatar,
                    widget.context,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.context.forward("/netflow/channel/portal/person",
                        arguments: {
                          'person': _creator,
                        });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: 2,
                    ),
                    child: Text(
                      '${_creator.nickName}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _maxlines = _maxlines == null ? 6 : null;
                    if (mounted) setState(() {});
                  },
                  child: Text.rich(
                    TextSpan(
                      text: '${_message.digests ?? ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    maxLines: _maxlines,
                    overflow: _maxlines == null ? null : TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 5,
                    bottom: 2,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${TimelineUtil.format(
                          _message.ctime,
                          locale: 'zh',
                          dayFormat: DayFormat.Simple,
                        )}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      (useSimpleLayout()||_purchaseOR?.principalAmount==null)?SizedBox.shrink():
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          if (_purchaseOR == null) {
                            return;
                          }
                          IWyBankPurchaserRemote purchaserRemote = widget
                              .context.site
                              .getService('/remote/purchaser');
                          WenyBank bank = await purchaserRemote
                              .getWenyBank(_purchaseOR.bankid);
                          widget.context.forward(
                            '/wybank/purchase/details',
                            arguments: {
                              'purch': _purchaseOR,
                              'bank': bank,
                            },
                          );
                        },
                        child: Text(
                          '¥${((_purchaseOR?.principalAmount ?? 0.00) / 100.00).toStringAsFixed(2)}',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blueGrey,
                            fontSize: 14,
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
    );
  }
}
