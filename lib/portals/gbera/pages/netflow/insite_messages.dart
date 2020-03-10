import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/swipe_refresh.dart';
import 'package:netos_app/portals/gbera/store/services.dart';

import 'message_views.dart';

class InsiteMessagePage extends StatefulWidget {
  PageContext pageContext;

  InsiteMessagePage({this.pageContext});

  @override
  _InsiteMessagePageState createState() => _InsiteMessagePageState();
}

class _InsiteMessagePageState extends State<InsiteMessagePage>
    with SingleTickerProviderStateMixin {
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
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: _MessagesRegion(
            context: widget.pageContext,
          ),
        ),
      ),
    );
  }
}

class _MessagesRegion extends StatefulWidget {
  PageContext context;
  MessageTabView tabView;

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

  Future<void> _onLoadMessages() async {
    IInsiteMessageService messageService =
        widget.context.site.getService('/insite/messages');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    var messages = await messageService.pageMessage(limit, offset);
    if (messages.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      return;
    }
    offset += messages.length;
    for (var msg in messages) {
      var person = await personService.getPerson(msg.creator);
      var timeText = TimelineUtil.formatByDateTime(
              DateTime.fromMillisecondsSinceEpoch(msg.atime),
              locale: 'zh',
              dayFormat: DayFormat.Simple)
          .toString();
      var channel = await channelService.getChannel(msg.onChannel);
      var view = MessageView(
        who: person.nickName,
        channel: channel?.name,
        content: msg.digests,
        money: (msg.wy ?? 0).toStringAsFixed(2),
        time: timeText,
        picCount: 0,
        onTap: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return widget.context
                    .part('/site/insite/approvals', context, arguments: {
                  'message': msg,
                  'channel': channel,
                  'person': person,
                });
              });
        },
      );
      messageViews.add(view);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      controller: _controller,
      onLoad: _onLoadMessages,
      child: ListView(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Container(
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
                  return GestureDetector(
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
                                    color: Colors.black87,
                                    height: 1.35,
                                    fontSize: 18,
                                  ),
                                  text: '${v.content}',
                                ),
                              ],
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(
                            right: 10,
                            left: 10,
                            top: 6,
                          ),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                !StringUtil.isEmpty(v.time)
                                    ? TextSpan(text: '${v.time}')
                                    : TextSpan(text: ''),
                                !StringUtil.isEmpty(v.money)
                                    ? TextSpan(
                                        text: '  洇金:¥',
                                        children: [
                                          TextSpan(
                                            text: '${v.money}',
                                            style: TextStyle(
                                              color: Colors.blueGrey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      )
                                    : TextSpan(text: ''),
                                TextSpan(
                                  text: '  来自:',
                                ),
                                TextSpan(
                                  text: '  ${v.who}',
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                !StringUtil.isEmpty(v.channel)
                                    ? TextSpan(
                                        text: '',
                                        children: [
                                          TextSpan(
                                            text: '  ${v.channel}',
                                            style: TextStyle(
                                              color: Colors.blueGrey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      )
                                    : TextSpan(text: ''),
                                v.picCount > 0
                                    ? TextSpan(text: '  图片${v.picCount}个')
                                    : TextSpan(text: ''),
                              ],
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 10,
                              ),
                            ),
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
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
