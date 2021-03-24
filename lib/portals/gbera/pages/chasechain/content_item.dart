import 'dart:async';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/cc_medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/system/system.dart';

import 'collapsible_panel.dart';

class ContentItemPanel extends StatefulWidget {
  PageContext context;
  ContentItemOR item;
  String towncode;
  ContentItemShowMode showMode;

  ContentItemPanel({
    this.context,
    this.item,
    this.towncode,
    this.showMode,
  }) {
    if (this.showMode == null) {
      this.showMode = ContentItemShowMode.showBox;
    }
  }

  @override
  _ContentItemPanelState createState() => _ContentItemPanelState();
}

class _ContentItemPanelState extends State<ContentItemPanel> {
  int _maxLines = 4;
  RecommenderDocument _doc;
  TrafficPool _pool;
  bool _isCollapsibled = true;
  Person _provider;
  ContentBoxOR _contentBox;
  ItemBehavior _itemInnerBehavior;
  // PurchaseOR _purchaseOR;
  StreamController _streamController;
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _streamController = StreamController.broadcast();
    _streamSubscription = Stream.periodic(
        Duration(
          seconds: 5,
        ), (count) {
      return count;
    }).listen((event) {
      _streamController.add({'count': event});
    });
    _loadDocumentContent();
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _streamController?.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(ContentItemPanel oldWidget) {
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.towncode != widget.towncode) {
      oldWidget.item = widget.item;
      oldWidget.towncode = widget.towncode;
      _loadDocumentContent();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadDocumentContent() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    _doc = await recommender.getDocument(widget.item);
    if (_doc == null) {
      return;
    }
    _pool = await _getPool();
    _provider = await _getPerson(widget.context.site, _doc.message.creator);
    _contentBox = await _getContentBox();
    _itemInnerBehavior = await _getItemInnerBehavior();
    // _purchaseOR = await _getPurchase();
    if (mounted) setState(() {});
  }
/*
  Future<PurchaseOR> _getPurchase() async {
    var sn = _doc?.message?.purchaseSn;
    if (StringUtil.isEmpty(sn)) {
      return null;
    }
    IWyBankPurchaserRemote purchaserRemote =
        widget.context.site.getService('/remote/purchaser');
    return await purchaserRemote.getPurchaseRecordPerson(
        _doc?.message?.creator, sn);
  }


 */
  Future<TrafficPool> _getPool() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    return await recommender.getTrafficPool(_doc.item.pool);
  }

  Future<ContentBoxOR> _getContentBox() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    return await recommender.getContentBox(_doc.item.pool, _doc.item.box);
  }

  Future<ItemBehavior> _getItemInnerBehavior() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    return await recommender.getItemInnerBehavior(_doc.item.pool, _doc.item.id);
  }

  Future<TrafficDashboard> _getTrafficDashboard() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    return await recommender.getTrafficDashboard(_doc.item.pool);
  }

  @override
  Widget build(BuildContext context) {
    if (_doc == null ||
        _provider == null ||
        _contentBox == null ||
        _pool == null) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }

    var layout = <Widget>[];
    switch (_doc.message.layout) {
      case 0: //上文下图
        if (!StringUtil.isEmpty(_doc.message.content)) {
          if (_doc.medias.isEmpty) {
            layout.add(
              SizedBox(
                height: 5,
              ),
            );
          }
          layout.add(
            _renderContent(),
          );
          if (_doc.medias.isEmpty) {
            layout.add(
              SizedBox(
                height: 20,
              ),
            );
          }
        }
        if (_doc.medias.isNotEmpty) {
          layout.add(
            SizedBox(
              height: 10,
            ),
          );
          layout.add(
            Row(
              children: [
                Expanded(
                  child: _renderMedias(),
                ),
              ],
            ),
          );
          layout.add(
            SizedBox(
              height: 10,
            ),
          );
        }
        break;
      case 1: //左文右图
        var rows = <Widget>[];
        if (!StringUtil.isEmpty(_doc.message.content)) {
          rows.add(
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 100,
                ),
                child: _renderContent(),
              ),
            ),
          );
        }
        if (_doc.medias.isNotEmpty) {
          rows.add(
            SizedBox(
              width: 150,
              height: 100,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10,
                ),
                child: _renderMedias(),
              ),
            ),
          );
        }
        layout.add(
          SizedBox(
            height: 10,
          ),
        );
        layout.add(
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rows,
          ),
        );
        layout.add(
          SizedBox(
            height: 10,
          ),
        );
        break;
      case 2: //左图右文
        var rows = <Widget>[];
        if (_doc.medias.isNotEmpty) {
          rows.add(
            SizedBox(
              width: 150,
              height: 100,
              child: Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: _renderMedias(),
              ),
            ),
          );
        }
        if (!StringUtil.isEmpty(_doc.message.content)) {
          rows.add(
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _renderContent(),
                  ],
                ),
              ),
            ),
          );
        }
        layout.add(
          SizedBox(
            height: 10,
          ),
        );
        layout.add(
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rows,
          ),
        );
        layout.add(
          SizedBox(
            height: 10,
          ),
        );
        break;
      default:
        print('未知布局! 消息:${_doc.message.id} ${_doc.message.content}');
        break;
    }
    // layout.add(
    //   SizedBox(
    //     height: 20,
    //     child: Divider(
    //       height: 1,
    //     ),
    //   ),
    // );

    var body = Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: layout,
      ),
    );
    return _renderItem(body);
  }

  Widget _renderItem(Widget body) {
    Widget portal;
    switch (widget.showMode) {
      case ContentItemShowMode.showProvider:
        portal = Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        widget.context.forward('/chasechain/provider', arguments: {
                          'provider': _provider.official,
                          'pool': _pool.id,
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: getAvatarWidget(
                                _provider?.avatar ?? '',
                                widget.context,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '${_provider?.nickName ?? ''}',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 25,
                      right: 15,
                    ),
                    child: Column(
                      children: [
                        body,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${TimelineUtil.format(
                                    _doc.message.ctime,
                                    locale: 'zh',
                                    dayFormat: DayFormat.Full,
                                  )}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                // SizedBox(
                                //   width: useSimpleLayout()||_purchaseOR == null ? 0 : 10,
                                // ),
                                /*
                               useSimpleLayout()|| _purchaseOR == null
                                    ? SizedBox(
                                  width: 0,
                                  height: 0,
                                )
                                    : GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  child: Text(
                                    '¥${((_purchaseOR?.principalAmount ?? 0.00) / 100.00).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                      decoration:
                                      TextDecoration.underline,
                                    ),
                                  ),
                                  onTap: () async {
                                    if (_purchaseOR == null) {
                                      return;
                                    }
                                    IWyBankPurchaserRemote
                                    purchaserRemote =
                                    widget.context.site.getService(
                                        '/remote/purchaser');
                                    WenyBank bank = await purchaserRemote
                                        .getWenyBank(_purchaseOR.bankid);
                                    widget.context.forward(
                                      '/wybank/purchase/details',
                                      arguments: {
                                        'purch': _purchaseOR,
                                        'bank': bank
                                      },
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: 10,
                                ),

                                 */

                              ],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                // _itemInnerBehavior == null
                                //     ? SizedBox(
                                //   width: 0,
                                //   height: 0,
                                // )
                                //     : Row(
                                //   children: <Widget>[
                                //     Text(
                                //       '${parseInt(_itemInnerBehavior.likes, 2)}个赞',
                                //       style: TextStyle(
                                //         fontSize: 10,
                                //         color: Colors.grey[600],
                                //         fontWeight: FontWeight.w500,
                                //       ),
                                //     ),
                                //     SizedBox(
                                //       width: 4,
                                //     ),
                                //     Text(
                                //       '${parseInt(_itemInnerBehavior.comments, 2)}个评',
                                //       style: TextStyle(
                                //         fontSize: 10,
                                //         color: Colors.grey[600],
                                //         fontWeight: FontWeight.w500,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                // SizedBox(
                                //   width: 5,
                                // ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    // if (_doc.message.layout == 0) {
                                    //   _isCollapsibled = !_isCollapsibled;
                                    //   if (mounted) {
                                    //     setState(() {});
                                    //   }
                                    //   return;
                                    // }
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (ctx) {
                                          return CollapsiblePanel(
                                            context: widget.context,
                                            doc: _doc,
                                            pool: _pool,
                                            usePopupLayout: true,
                                            towncode: widget.towncode,
                                          );
                                        });
                                  },
                                  child: Wrap(
                                    direction: Axis.horizontal,
                                    spacing: 2,
                                    crossAxisAlignment: WrapCrossAlignment.end,
                                    children: <Widget>[
                                      Icon(
                                        Icons.pool,
                                        size: 11,
                                        color: _pool.isGeosphere
                                            ? Colors.green
                                            : Colors.grey[600],
                                      ),
                                      Text(
                                        '${_pool.title}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
          ],
        );
        break;
      case ContentItemShowMode.showBox:
        portal = Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        widget.context.forward(
                          '/chasechain/box',
                          arguments: {
                            'box': _contentBox,
                            'pool': _contentBox.pool,
                          },
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: getAvatarWidget(
                                _contentBox?.pointer?.leading ?? '',
                                widget.context,
                                'lib/portals/gbera/images/netflow.png',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '${_contentBox?.pointer?.title ?? ''}',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 25,
                      right: 15,
                    ),
                    child: Column(
                      children: [
                        body,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${TimelineUtil.format(
                                    _doc.message.ctime,
                                    locale: 'zh',
                                    dayFormat: DayFormat.Full,
                                  )}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                // SizedBox(
                                //   width: _purchaseOR == null ? 0 : 10,
                                // ),
                                /*
                                _purchaseOR == null
                                    ? SizedBox(
                                        width: 0,
                                        height: 0,
                                      )
                                    : GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        child: Text(
                                          '¥${((_purchaseOR?.principalAmount ?? 0.00) / 100.00).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                        onTap: () async {
                                          if (_purchaseOR == null) {
                                            return;
                                          }
                                          IWyBankPurchaserRemote
                                              purchaserRemote =
                                              widget.context.site.getService(
                                                  '/remote/purchaser');
                                          WenyBank bank = await purchaserRemote
                                              .getWenyBank(_purchaseOR.bankid);
                                          widget.context.forward(
                                            '/wybank/purchase/details',
                                            arguments: {
                                              'purch': _purchaseOR,
                                              'bank': bank
                                            },
                                          );
                                        },
                                      ),
                                SizedBox(
                                  width: 10,
                                ),

                                 */
                              ],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                // _itemInnerBehavior == null
                                //     ? SizedBox(
                                //         width: 0,
                                //         height: 0,
                                //       )
                                //     : Row(
                                //         children: <Widget>[
                                //           Text(
                                //             '${parseInt(_itemInnerBehavior.likes, 2)}个赞',
                                //             style: TextStyle(
                                //               fontSize: 10,
                                //               color: Colors.grey[600],
                                //               fontWeight: FontWeight.w500,
                                //             ),
                                //           ),
                                //           SizedBox(
                                //             width: 4,
                                //           ),
                                //           Text(
                                //             '${parseInt(_itemInnerBehavior.comments, 2)}个评',
                                //             style: TextStyle(
                                //               fontSize: 10,
                                //               color: Colors.grey[600],
                                //               fontWeight: FontWeight.w500,
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                // SizedBox(
                                //   width: 5,
                                // ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    // if (_doc.message.layout == 0) {
                                    //   _isCollapsibled = !_isCollapsibled;
                                    //   if (mounted) {
                                    //     setState(() {});
                                    //   }
                                    //   return;
                                    // }
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (ctx) {
                                          return CollapsiblePanel(
                                            context: widget.context,
                                            doc: _doc,
                                            pool: _pool,
                                            usePopupLayout: true,
                                            towncode: widget.towncode,
                                          );
                                        });
                                  },
                                  child: Wrap(
                                    direction: Axis.horizontal,
                                    spacing: 2,
                                    crossAxisAlignment: WrapCrossAlignment.end,
                                    children: <Widget>[

                                      Icon(
                                        Icons.pool,
                                        size: 13,
                                        color: _pool.isGeosphere
                                            ? Colors.green
                                            : Colors.grey[600],
                                      ),
                                      Text(
                                        '${_pool.title}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
          ],
        );
        break;

    }
    return portal;
  }

  Widget _renderContent() {
    return Container(
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _maxLines = _maxLines == 4 ? 10000 : 4;
          if (mounted) {
            setState(() {});
          }
        },
        child: Text(
          '${_doc.message.content ?? ''}',
          maxLines: _maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
//            letterSpacing: 0.8,
//            wordSpacing: 1.4,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _renderMedias() {
    return RecommenderMediaWidget(
      _doc.medias,
      widget.context,
    );
  }
}

Future<Person> _getPerson(IServiceProvider site, String person) async {
  IPersonService personService = site.getService('/gbera/persons');
  return await personService.getPerson(person);
}

enum ContentItemShowMode { showProvider, showBox }
