import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/common/swipe_refresh.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel_handler.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/gbera/store/services.dart';

import '../netflow.dart';
import 'cat_widget.dart';
import 'message_views.dart';

class InsiteMessagePage extends StatefulWidget {
  PageContext pageContext;

  InsiteMessagePage({this.pageContext});

  @override
  _InsiteMessagePageState createState() => _InsiteMessagePageState();
}

class _InsiteMessagePageState extends State<InsiteMessagePage>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  List<ActivityTabView> _tabViews;

  @override
  void initState() {
    super.initState();
    _tabViews = <ActivityTabView>[
      ActivityTabView(
        text: '收件箱',
        id: 'inbox',
      ),
      ActivityTabView(
        text: '发件箱',
        id: 'outbox',
      ),
    ];
    _controller = TabController(vsync: this, length: _tabViews.length);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabViews.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageContext.page.title),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              widget.pageContext.backward();
            },
          ),
        ],
        elevation: 0.0,
        bottom: TabBar(
          controller: _controller,
          isScrollable: true,
          labelColor: Colors.black,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          tabs: _tabViews.map<Tab>((ActivityTabView view) {
            return Tab(
              text: view.text,
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: _tabViews.map<Widget>((ActivityTabView tabView) {
          return SafeArea(
            top: false,
            bottom: false,
            child: Container(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              color: Colors.white,
              child: _MessagesRegion(
                context: widget.pageContext,
                tabView: tabView,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MessagesRegion extends StatefulWidget {
  PageContext context;
  ActivityTabView tabView;

  _MessagesRegion({this.tabView, this.context});

  @override
  _MessagesRegionState createState() => _MessagesRegionState();
}

class _MessagesRegionState extends State<_MessagesRegion> {
  var limit = 20;
  var offset = 0;
  var index = 0;
  var messageViews = <MessageView>[];
  EasyRefreshController _controller;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _onLoadMessages().then((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    messageViews.clear();
    super.dispose();
  }

//
//  @override
//  void didUpdateWidget(_MessagesRegion oldWidget) {
//    if (oldWidget.selectedTableViewId != widget.selectedTableViewId) {
////      offset = 0;
////      messageViews.clear();
//      oldWidget.selectedTableViewId = widget.selectedTableViewId;
//      oldWidget.tabView=widget.tabView;
////      setState(() {});
//    }
//    super.didUpdateWidget(oldWidget);
//  }
  Future<PurchaseOR> _getPurchase(msg) async {
    var sn = msg.purchaseSn;
    if (StringUtil.isEmpty(sn)) {
      return null;
    }
    IWyBankPurchaserRemote purchaserRemote =
        widget.context.site.getService('/remote/purchaser');
    return await purchaserRemote.getPurchaseRecordPerson(msg.creator, sn);
  }

  Future<void> _onLoadMessages() async {
    IInsiteMessageService messageService =
        widget.context.site.getService('/insite/messages');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    print(widget.tabView.id);
    var messages =
        await messageService.pageMessageWhere(widget.tabView.id, limit, offset);
    if (messages.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      return;
    }
    offset += messages.length;
    for (var msg in messages) {
      // print('---insite messages-----');
      var person = await personService.getPerson(msg.creator);
      var timeText = TimelineUtil.formatByDateTime(
              DateTime.fromMillisecondsSinceEpoch(msg.atime),
              locale: 'zh',
              dayFormat: DayFormat.Simple)
          .toString();
      var channel = await channelService.getChannel(msg.upstreamChannel);
      var purchaseOR = await _getPurchase(msg);
      var view = MessageView(
        who: person.nickName,
        whois: person,
        channel: channel?.name,
        channelis: channel,
        content: msg.digests,
        money:
            ((purchaseOR?.principalAmount ?? 0.0) / 100.00).toStringAsFixed(2),
        time: timeText,
        picCount: 0,
        onTap: () {
          showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) {
                return widget.context
                    .part('/site/insite/approvals', context, arguments: {
                  'message': msg,
                  'channel': channel,
                  'person': person,
                });
              }).then((result) {
            if (result != null && (result['refresh'] ?? false)) {
              messageViews
                  .removeWhere((element) => element.channelis == channel);
              if (mounted) {
                setState(() {});
              }
              netflowRefresherController.sink.add({});
            }
          });
        },
      );
      messageViews.add(view);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      header: easyRefreshHeader(),
      footer: easyRefreshFooter(),
      controller: _controller,
      onLoad: _onLoadMessages,
      child: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Column(
              children: messageViews.map((v) {
                index++;
                bool notBottom = index < messageViews.length;
                if (index >= messageViews.length) {
                  index = 0;
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: getAvatarWidget(
                          v.whois?.avatar,
                          widget.context,
                        ),
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
                            '${v.who}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: v.onTap,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            height: 1.35,
                                            fontSize: 16,
                                          ),
                                          text: '${v.content}',
                                        ),
                                      ],
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // padding: EdgeInsets.only(
                                  //   left: 10,
                                  //   right: 10,
                                  // ),
                                ),
                                Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(
                                    // right: 10,
                                    // left: 10,
                                    top: 6,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            !StringUtil.isEmpty(v.time)
                                                ? TextSpan(text: '${v.time}')
                                                : TextSpan(text: ''),
                                            !StringUtil.isEmpty(v.money)
                                                ? TextSpan(
                                                    text: '  ¥',
                                                    children: [
                                                      TextSpan(
                                                        text: '${v.money}',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : TextSpan(text: ''),
                                            // TextSpan(
                                            //   text: '  来自:',
                                            // ),
                                            // TextSpan(
                                            //   text: '  ${v.who}',
                                            //   style: TextStyle(
                                            //     color: Colors.blueGrey,
                                            //     fontWeight: FontWeight.w600,
                                            //   ),
                                            // ),
                                            !StringUtil.isEmpty(v.channel)
                                                ? TextSpan(
                                                    text: '',
                                                    children: [
                                                      TextSpan(
                                                        text: '  ${v.channel}',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : TextSpan(text: ''),
                                            v.picCount > 0
                                                ? TextSpan(
                                                    text: '  图片${v.picCount}个')
                                                : TextSpan(text: ''),
                                          ],
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      CatWidget(
                                        context: widget.context,
                                        channelId: v.channelis?.id,
                                        size: 11,
                                        canTap: false,
                                      ),
                                    ],
                                  ),
                                ),
                                notBottom
                                    ? Container(
                                        child: Divider(
                                          height: 1,
                                        ),
                                        padding: EdgeInsets.only(
                                          top: 10,
                                          bottom: 10,
                                        ),
                                      )
                                    : Container(
                                        width: 0,
                                        height: 0,
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
