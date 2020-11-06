import 'dart:developer';

import 'package:common_utils/common_utils.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_remote_ports.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/load_indicator.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/common/wpopup_menu/w_popup_menu.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/parts/timeline_listview.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

import 'channel_router_path.dart';

class NetflowChannelPortal extends StatefulWidget {
  PageContext context;

  NetflowChannelPortal({this.context});

  @override
  _NetflowChannelPortalState createState() => _NetflowChannelPortalState();
}

class _NetflowChannelPortalState extends State<NetflowChannelPortal>
    with SingleTickerProviderStateMixin {
  Channel _channel;
  Person _person;
  TabController _tabController;
  List<Tab> _tabs;
  bool _showRouterPanel = false;

  @override
  void initState() {
    _tabs = <Tab>[
      Tab(
        text: "",
      ),
    ];
    _tabController = TabController(length: _tabs.length, vsync: this);
    var origin = widget.context.parameters['origin'];
    () async {
      await _loadChannel();
      await _loadPerson(origin);
      if (mounted) {
        setState(() {});
      }
    }();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _loadChannel() async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    var channelid = widget.context.parameters['channel'];
    _channel = await channelService.getChannel(channelid);
  }

  Future<void> _loadPerson(String origin) async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    if (StringUtil.isEmpty(origin)) {
      _person = await personService.getPerson(_channel.owner);
    } else {
      _person = await personService.getPerson(origin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, s) {
          var items = <Widget>[];
          items.add(
            SliverAppBar(
              title: Text('微管'),
              pinned: true,
              elevation: 0,
              titleSpacing: 0,
              actions: <Widget>[],
            ),
          );
          items.add(
            SliverToBoxAdapter(
              child: _Header(
                context: widget.context,
                channel: _channel,
              ),
            ),
          );
          items.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 5,
                  right: 25,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _showRouterPanel = !_showRouterPanel;
                        });
                      },
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _showRouterPanel
                              ? FontAwesomeIcons.ellipsisV
                              : FontAwesomeIcons.ellipsisH,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          if (_channel != null && _showRouterPanel) {
            var origin = widget.context.parameters['origin'];
            var child = Container(
              decoration: BoxDecoration(
                color: Color(0xddFFFFFF),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(1, 3),
                    blurRadius: 5,
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                top: 10,
                bottom: 10,
              ),
              margin: EdgeInsets.only(
                left: 25,
                right: 25,
                bottom: 20,
              ),
              child: NotificationListener(
                onNotification: (notify) {
                  if (notify is ChanngeSelectedPersonNotification) {
                    _person = notify.person;
                    if (mounted) {
                      setState(() {});
                    }
                  }
                  return true;
                },
                child: widget.context.part('/netflow/channel/router', context,
                    arguments: {'channel': _channel, 'origin': origin}),
              ),
            );
            items.add(
              SliverToBoxAdapter(
                child: child,
              ),
            );
          }
          items.add(
            SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
                child: TabBar(
                  isScrollable: false,
                  indicatorColor: Colors.transparent,
                  controller: this._tabController,
                  tabs: _tabs.map((e) {
                    return e;
                  }).toList(),
                ),
              ),
            ),
          );
          return items;
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            (_person == null || _channel == null)
                ? SizedBox(
                    width: 0,
                    height: 0,
                  )
                : _MessageList(
                    person: _person,
                    channel: _channel,
                    context: widget.context,
                  ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  Channel channel;
  PageContext context;

  _Header({
    this.channel,
    this.context,
  });

  @override
  __HeaderState createState() => __HeaderState();
}

class __HeaderState extends State<_Header> {
  @override
  void didUpdateWidget(covariant _Header oldWidget) {
    if (oldWidget.channel != widget.channel) {
      oldWidget.channel = widget.channel;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var channel = widget.channel;
    if (channel == null) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 40,
        top: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  right: 20,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(6),
                  ),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: getAvatarWidget(
                      channel.leading,
                      widget.context,
                      'lib/portals/gbera/images/netflow.png',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 5,
                      ),
                      child: Text(
                        channel.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatefulWidget {
  PageContext context;

  _MessageList({this.context, this.person, this.channel});

  Person person;
  Channel channel;

  @override
  __MessageListState createState() => __MessageListState();
}

class __MessageListState extends State<_MessageList> {
  Person _person;
  Channel _channel;
  List<ChannelMessageOR> _messages = [];
  int _limit = 15, _offset = 0;
  EasyRefreshController _controller;

  @override
  void initState() {
    _channel = widget.channel;
    _person = widget.person;
    _controller = EasyRefreshController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _MessageList oldWidget) {
    if (oldWidget.person != widget.person ||
        oldWidget.channel != widget.channel) {
      _person = widget.person;
      _channel = widget.channel;
      _refresh();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _refresh() {
    _offset = 0;
    _messages.clear();
    _load();
  }

  Future<void> _load() async {
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    IChannelRemote channelRemote =
        widget.context.site.getService('/remote/channels');
    List<ChannelMessageOR> messages = await channelRemote.pageDocument(
        _person.official, _channel.id, _limit, _offset);
    if (messages.isEmpty) {
      _controller.finishLoad(
        noMore: true,
        success: true,
      );
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += messages.length;
    _messages.addAll(messages);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 10,
              bottom: 5,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Column(
                    children: [
                     GestureDetector(
                       behavior: HitTestBehavior.opaque,
                       onTap: (){
                         widget.context.forward("/netflow/channel/portal/person",
                             arguments: {
                               'person': _person,
                             });
                       },
                       child:  SizedBox(
                         width: 40,
                         height: 40,
                         child: ClipRRect(
                           borderRadius: BorderRadius.circular(20),
                           child:
                           getAvatarWidget(_person.avatar, widget.context),
                         ),
                       ),
                     ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        '${_person.nickName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: EasyRefresh(
              onLoad: _load,
              controller: _controller,
              child: ListView(
                shrinkWrap: true,
                children: _renderList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _renderList() {
    if (_messages.isEmpty) {
      return <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: 30,
          ),
          child: Center(
            child: Text(
              '他很懒，没有内容',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ];
    }
    return _messages.map((e) {
      var panel = _MessagePanel(
        context: widget.context,
        message: e,
        channel: _channel,
        onDeleted: (e) {
          _messages.remove(e);
          setState(() {});
        },
      );

      return rendTimelineListRow(
        content: panel,
        title: Row(
          children: [
            Text(
              '${TimelineUtil.format(
                e.ctime,
                locale: 'zh',
                dayFormat: DayFormat.Full,
              )}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            FutureBuilder<PurchaseOR>(
              future: _getPurchase(e.creator, e.purchaseSn),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return SizedBox(
                    height: 0,
                    width: 0,
                  );
                }
                var _purchaseOR = snapshot.data;
                return Text.rich(
                  TextSpan(
                    text:
                        '¥${((_purchaseOR?.principalAmount ?? 0.00) / 100.00).toStringAsFixed(2)}',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        IWyBankPurchaserRemote purchaserRemote =
                            widget.context.site.getService('/remote/purchaser');
                        WenyBank bank = await purchaserRemote
                            .getWenyBank(_purchaseOR.bankid);
                        widget.context.forward(
                          '/wybank/purchase/details',
                          arguments: {'purch': _purchaseOR, 'bank': bank},
                        );
                      },
                  ),
                );
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<PurchaseOR> _getPurchase(String creator, String sn) async {
    if (StringUtil.isEmpty(sn)) {
      return null;
    }
    IWyBankPurchaserRemote purchaserRemote =
        widget.context.site.getService('/remote/purchaser');
    return await purchaserRemote.getPurchaseRecordPerson(creator, sn);
  }
}

class _MessagePanel extends StatefulWidget {
  PageContext context;
  ChannelMessageOR message;
  Channel channel;
  void Function(ChannelMessageOR message) onDeleted;

  _MessagePanel({this.context, this.message, this.channel, this.onDeleted});

  @override
  __MessagePanelState createState() => __MessagePanelState();
}

class __MessagePanelState extends State<_MessagePanel> {
  ChannelMessageOR _message;
  bool _isLoading = false;
  Person _creator;
  List<MediaSrc> _medias = [];
  _InteractiveRegionRefreshAdapter _interactiveRegionRefreshAdapter;
  int _maxLines=4;
  @override
  void initState() {
    _message = widget.message;
    _interactiveRegionRefreshAdapter = _InteractiveRegionRefreshAdapter();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _interactiveRegionRefreshAdapter = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _MessagePanel oldWidget) {
    if (oldWidget.message != widget.message) {
      _message = widget.message;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    _isLoading = true;
    setState(() {});
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _creator = await personService.getPerson(_message.creator);
    await _loadMedias();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMedias() async {
    IChannelRemote channelRemote =
        widget.context.site.getService('/remote/channels');
    var medias = await channelRemote.listExtraMedia(
        _message.id, _creator.official, _message.channel);
    for (var m in medias) {
      _medias.add(m.toMediaSrc());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        children: _renderList(),
      ),
    );
  }

  List<Widget> _renderList() {
    var items = <Widget>[
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _maxLines = (_maxLines == null ? 4 : null);
                setState(() {});
              },
              child: Text(
                '${_message.content ?? ''}',
                style: TextStyle(
                  fontSize: 16,
                ),
                maxLines: _maxLines,
                overflow: _maxLines == null ? null : TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    ];

    items.add(
      Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: MediaWidget(
          _medias,
          widget.context,
        ),
      ),
    );
    items.add(
      Row(
        //内容坠
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: _MessageOperatesPopupMenu(
              message: widget.message,
              context: widget.context,
              onDeleted: () {
                if (widget.onDeleted != null) {
                  widget.onDeleted(_message);
                }
                setState(() {});
              },
              onComment: () {
                _interactiveRegionRefreshAdapter.refresh('comment');
              },
              onliked: () {
                _interactiveRegionRefreshAdapter.refresh('liked');
              },
              onUnliked: () {
                _interactiveRegionRefreshAdapter.refresh('unliked');
              },
              onViewFlow: () {
                widget.context
                    .forward('/netflow/channel/document/path', arguments: {
                  'person': _creator,
                  'channel': widget.channel,
                  'message': _message.toInsiteMessage(
                      _creator.official, widget.context.principal.person),
                });
              },
            ),
          ),
        ],
      ),
    );
    items.add(
      SizedBox(
        height: 10,
      ),
    );
    items.add(
      ///相关交互区
      _InteractiveRegion(
        message: _message,
        context: widget.context,
        interactiveRegionRefreshAdapter: _interactiveRegionRefreshAdapter,
      ),
    );
    return items;
  }
}

class _CommentEditor extends StatefulWidget {
  void Function(String content) onFinished;
  void Function() onCloseWin;
  PageContext context;

  _CommentEditor({this.context, this.onFinished, this.onCloseWin});

  @override
  __CommentEditorState createState() => __CommentEditorState();
}

class __CommentEditorState extends State<_CommentEditor> {
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            //解决了无法计算边界问题
            fit: FlexFit.tight,
            child: ExtendedTextField(
              controller: _controller,
              autofocus: true,
              onSubmitted: (v) {
                print(v);
              },
              onEditingComplete: () {
                print('----');
              },
              style: TextStyle(
                fontSize: 14,
              ),
              maxLines: 50,
              minLines: 4,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixText: '说道>',
                prefixStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                labelText:
                    '${widget.context.principal.nickName ?? widget.context.principal.accountCode}',
                labelStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
                fillColor: Colors.white,
                filled: true,
                hintText: '输入您的评论',
                hintStyle: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.check,
                  size: 14,
                ),
                onPressed: () async {
                  if (widget.onFinished != null) {
                    await widget.onFinished(_controller.text);
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 14,
                ),
                onPressed: () async {
                  _controller.text = '';
                  if (widget.onCloseWin != null) {
                    await widget.onCloseWin();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageOperatesPopupMenu extends StatefulWidget {
  ChannelMessageOR message;
  PageContext context;
  void Function() onDeleted;
  void Function() onComment;
  void Function() onliked;
  void Function() onUnliked;
  void Function() onViewFlow;

  _MessageOperatesPopupMenu({
    this.message,
    this.context,
    this.onDeleted,
    this.onComment,
    this.onliked,
    this.onUnliked,
    this.onViewFlow,
  });

  @override
  __MessageOperatesPopupMenuState createState() =>
      __MessageOperatesPopupMenuState();
}

class __MessageOperatesPopupMenuState extends State<_MessageOperatesPopupMenu> {
  Future<Map<String, bool>> _getOperatorRights() async {
    bool isLiked = await _isLiked();
    return {
      'isLiked': isLiked,
      'canComment': true,
      'canDelete': widget.message.creator == widget.context.principal.person,
    };
  }

  Future<bool> _isLiked() async {
    IChannelLikeService likeService =
        widget.context.site.getService('/channel/messages/likes');
    return await likeService.isLiked(
        widget.message.id, widget.context.principal.person);
  }

  Future<void> _like() async {
    IChannelLikeService likeService =
        widget.context.site.getService('/channel/messages/likes');
    LikePerson likePerson = LikePerson(
      '${Uuid().v1()}',
      widget.context.principal.person,
      widget.context.principal.avatarOnRemote,
      widget.message.id,
      DateTime.now().millisecondsSinceEpoch,
      widget.context.principal.nickName ?? widget.context.principal.accountCode,
      widget.message.channel,
      widget.context.principal.person,
    );
    await likeService.like(likePerson);

    //向下游推文
    if (widget.message.creator != widget.context.principal.person) {
      //不是消息的创建者则推
      var flowChannelPortsUrl =
          widget.context.site.getService('@.prop.ports.flow.channel');
      IRemotePorts ports = widget.context.ports;
      ports.portTask.addPortPOSTTask(
        flowChannelPortsUrl,
        'pushChannelDocumentOfPerson',
        parameters: {
          'channel': widget.message.channel,
          'docid': widget.message.id,
          'creator': widget.message.creator,
          'interval': 100,
        },
      );
      IChannelMessageService channelMessageService =
          widget.context.site.getService('/channel/messages');
      await channelMessageService.setCurrentActivityTask(
        creator: widget.message.creator,
        docid: widget.message.id,
        channel: widget.message.channel,
        attach: likePerson.person,
        action: 'send.like',
      );
    }
  }

  Future<void> _unlike() async {
    IChannelLikeService likeService =
        widget.context.site.getService('/channel/messages/likes');
    await likeService.unlike(
        widget.message.id, widget.context.principal.person);
  }

  Future<void> _deleteMessage() async {
    IChannelMessageService messageService =
        widget.context.site.getService('/channel/messages');
    messageService.removeMessage(widget.message.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getOperatorRights(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          print('${snapshot.error}');
        }
        var rights = snapshot.data;
        var actions = <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 2,
                  left: 2,
                ),
                child: Icon(
                  FontAwesomeIcons.thumbsUp,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              Text(
                rights['isLiked'] ? '取消点赞' : '点赞',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 2,
                  top: 2,
                ),
                child: Icon(
                  Icons.comment,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              Text(
                '评论',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 2,
                  top: 2,
                ),
                child: Icon(
                  Icons.timeline,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              Text(
                '流程',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ];
        if (rights['canDelete']) {
          actions.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 2,
                    top: 1,
                  ),
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                Text(
                  '删除',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: EdgeInsets.only(
            top: 4,
            bottom: 4,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: WPopupMenu(
              child: Icon(
                IconData(
                  0xe79d,
                  fontFamily: 'ellipse',
                ),
                size: 22,
              ),
              actions: actions,
              pressType: PressType.singleClick,
              onValueChanged: (index) {
                switch (index) {
                  case 0: //点赞或取消
                    if (rights['isLiked']) {
                      _unlike().whenComplete(() {
                        setState(() {});
                        if (widget.onUnliked != null) {
                          widget.onUnliked();
                        }
                      });
                    } else {
                      _like().whenComplete(() {
                        setState(() {});
                        if (widget.onliked != null) {
                          widget.onliked();
                        }
                      });
                    }
                    break;
                  case 1: //评论
                    if (widget.onComment != null) {
                      widget.onComment();
                    }
                    break;
                  case 2: //流程
                    if (widget.onViewFlow != null) {
                      widget.onViewFlow();
                    }
                    break;
                  case 3: //删除
                    _deleteMessage().whenComplete(() {
                      if (widget.onDeleted != null) {
                        widget.onDeleted();
                      }
                    });
                    break;
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _InteractiveRegion extends StatefulWidget {
  ChannelMessageOR message;
  PageContext context;
  _InteractiveRegionRefreshAdapter interactiveRegionRefreshAdapter;

  _InteractiveRegion({
    this.message,
    this.context,
    this.interactiveRegionRefreshAdapter,
  });

  @override
  __InteractiveRegionState createState() => __InteractiveRegionState();
}

class __InteractiveRegionState extends State<_InteractiveRegion> {
  bool _isShowCommentEditor = false;

  @override
  void initState() {
    if (widget.interactiveRegionRefreshAdapter != null) {
      widget.interactiveRegionRefreshAdapter.handler = (cause) {
        switch (cause) {
          case 'comment':
            _isShowCommentEditor = true;
            break;
        }
        setState(() {});
      };
    }
    super.initState();
  }

  @override
  void dispose() {
    _isShowCommentEditor = false;
    if (widget.interactiveRegionRefreshAdapter != null) {
      widget.interactiveRegionRefreshAdapter.handler = null;
      widget.interactiveRegionRefreshAdapter = null;
    }
    super.dispose();
  }

  Future<Map<String, List<dynamic>>> _loadInteractiveRegion() async {
    IChannelLikeService likeService =
        widget.context.site.getService('/channel/messages/likes');
    IChannelCommentService commentService =
        widget.context.site.getService('/channel/messages/comments');
    List<LikePerson> likes =
        await likeService.pageLikePersons(widget.message.id, 10, 0);
    List<ChannelComment> comments =
        await commentService.pageComments(widget.message.id, 20, 0);
    return <String, List<dynamic>>{"likePersons": likes, "comments": comments};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List>>(
      future: _loadInteractiveRegion(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            width: 0,
            height: 0,
          );
        }
        if (snapshot.hasError) {
          print('${snapshot.error}');
          return Container(
            width: 0,
            height: 0,
          );
        }
        if (snapshot.data == null || snapshot.data.isEmpty) {
          return Container(
            width: 0,
            height: 0,
          );
        }
        var comments = snapshot.data['comments'];
        var likePersons = snapshot.data['likePersons'];
        bool isHide =
            comments.isEmpty && likePersons.isEmpty && !_isShowCommentEditor;
        if (isHide) {
          return Container(
            width: 0,
            height: 0,
          );
        }
        var commentListWidgets = <Widget>[];
        for (ChannelComment comment in comments) {
          bool isMine = comment.person == widget.context.principal.person;
          commentListWidgets.add(Padding(
            padding: EdgeInsets.only(
              bottom: 5,
            ),
            child: Text.rich(
              //评论区
              TextSpan(
                text: '${comment.nickName ?? ''}:',
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    widget.context
                        .forward("/netflow/channel/portal/channel", arguments: {
                      'channel': widget.message.channel,
                      'origin': comment.person,
                    });
                  },
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
                children: [
                  TextSpan(
                    text: '${comment.text ?? ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: '\t${comment.ctime != null ? TimelineUtil.format(
                        comment.ctime,
                        locale: 'zh',
                        dayFormat: DayFormat.Simple,
                      ) : ''}\t',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  isMine
                      ? TextSpan(
                          text: '删除',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await _deleteComment(comment);
                              setState(() {});
                            },
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        )
                      : TextSpan(text: ''),
                ],
              ),
              softWrap: true,
            ),
          ));
        }
        if (_isShowCommentEditor) {
          commentListWidgets.add(
            _CommentEditor(
              context: widget.context,
              onFinished: (content) async {
                await _appendComment(content);
                _isShowCommentEditor = false;
                setState(() {});
              },
              onCloseWin: () async {
                _isShowCommentEditor = false;
                setState(() {});
              },
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            color: Color(0xFFF5F5F5),
          ),
          padding: EdgeInsets.only(
            left: 10,
            right: 5,
            top: 5,
            bottom: 5,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ///点赞区
              likePersons.isEmpty
                  ? Container(
                      width: 0,
                      height: 0,
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 5,
                          ),
                          child: Icon(
                            FontAwesomeIcons.thumbsUp,
                            color: Colors.grey[500],
                            size: 12,
                          ),
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: likePersons.map((like) {
                                return TextSpan(
                                  text: '${like.nickName}',
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      widget.context
                                          .forward("/netflow/channel/portal/channel", arguments: {
                                        'channel': widget.message.channel,
                                        'origin': like.person,
                                      });
                                    },
                                  children: [
                                    TextSpan(
                                      text: ';  ',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
//                                maxLines: 4,
//                                overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
              likePersons.isEmpty || comments.isEmpty
                  ? Container(
                      width: 0,
                      height: 3,
                    )
                  : Padding(
                      padding: EdgeInsets.only(
                        bottom: 6,
                        top: 6,
                      ),
                      child: Divider(
                        height: 1,
                      ),
                    ),

              ///评论区
              ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(0),
                physics: NeverScrollableScrollPhysics(),
                children: commentListWidgets,
              ),
            ],
          ),
        );
      },
    );
  }

  _appendComment(String content) async {
    IChannelCommentService commentService =
        widget.context.site.getService('/channel/messages/comments');
    await commentService.addComment(
      ChannelComment(
        '${MD5Util.MD5(Uuid().v1())}',
        widget.context.principal.person,
        widget.context.principal.avatarOnRemote,
        widget.message.id,
        content,
        DateTime.now().millisecondsSinceEpoch,
        widget.context.principal.nickName ??
            widget.context.principal.accountCode,
        widget.message.channel,
        widget.context.principal.person,
      ),
    );
    //向下游推文
    if (widget.message.creator != widget.context.principal.person) {
      //不是消息的创建者则推
      var flowChannelPortsUrl =
          widget.context.site.getService('@.prop.ports.flow.channel');
      IRemotePorts ports = widget.context.ports;
      ports.portTask.addPortPOSTTask(
        flowChannelPortsUrl,
        'pushChannelDocumentOfPerson',
        parameters: {
          'channel': widget.message.channel,
          'docid': widget.message.id,
          'creator': widget.message.creator,
          'interval': 100,
        },
      );
      IChannelMessageService channelMessageService =
          widget.context.site.getService('/channel/messages');
      await channelMessageService.setCurrentActivityTask(
        creator: widget.message.creator,
        docid: widget.message.id,
        channel: widget.message.channel,
        attach: content,
        action: 'send.comment',
      );
    }
  }

  _deleteComment(ChannelComment comment) async {
    IChannelCommentService commentService =
        widget.context.site.getService('/channel/messages/comments');
    await commentService.removeComment(comment.msgid, comment.id);
  }
}

class _InteractiveRegionRefreshAdapter {
  void Function(String cause) handler;

  void refresh(String cause) {
    if (handler != null) {
      handler(cause);
    }
  }
}
