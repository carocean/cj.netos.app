import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/desklets/chats/chat_rooms.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/system/local/entities.dart';

class ChatroomSetNotice extends StatefulWidget {
  PageContext context;

  ChatroomSetNotice({this.context});

  @override
  _ChatroomSetNoticeState createState() => _ChatroomSetNoticeState();
}

class _ChatroomSetNoticeState extends State<ChatroomSetNotice> {
  ChatRoomModel _model;
  EasyRefreshController _controller;
  List<ChatRoomNotice> _notices = [];
  int _limit = 20;
  int _offset = 0;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _model = widget.context.parameters['model'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _notices.clear();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    IChatRoomRemote chatRoomRemote =
        widget.context.site.getService('/remote/chat/rooms');
    List<ChatRoomNotice> list =
        await chatRoomRemote.pageNotice(_model.chatRoom, _limit, _offset);
    if (list.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      return;
    }
    _offset += list.length;
    _notices.addAll(list);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var actions = <Widget>[];
    List<Widget> widgets = [];
    for (var notice in _notices) {
      Widget widget = _getRow(notice);
      widgets.add(widget);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('公告'),
        centerTitle: true,
        elevation: 0.0,
        actions: actions,
      ),
      floatingActionButton:
          widget.context.principal.person != _model.chatRoom.creator
              ? null
              : FloatingActionButton(
                  child: Icon(
                    Icons.add,
                  ),
                  onPressed: () {
                    widget.context.forward(
                      '/portlet/chat/room/publishNotice',
                      arguments: {
                        'model': _model,
                      },
                    ).then((v) {
                      _notices.clear();
                      _offset = 0;
                      _load().then((v) {
                        if (mounted) {
                          setState(() {});
                        }
                      });
                    });
                  },
                ),
      body: EasyRefresh(
        controller: _controller,
        onLoad: _load,
        child: ListView(
          shrinkWrap: true,
          children: widgets,
        ),
      ),
    );
  }

  Widget _getRow(ChatRoomNotice notice) {
    String timestr = TimelineUtil.format(
      notice.ctime,
      dayFormat: DayFormat.Full,
    );

    Widget firstRow;
    Widget contentWidget = SizedBox();
    //跟进记录
    contentWidget = Text(
      notice.notice ?? '',
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      softWrap: true,
    );

    firstRow = Row(
      children: <Widget>[
        Text(timestr,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.green,
            ))
      ],
    );

    Widget pointWidget;
    double topSpace = 0;
    topSpace = 3;
    pointWidget = ClipOval(
      child: Container(
        width: 7,
        height: 7,
        color: Colors.grey,
      ),
    );

    return Container(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //灰色右
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 37),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: topSpace == 0 ? 4 : 0,
                      ),
                      firstRow,
                      SizedBox(
                        height: 12.0,
                      ),
                      contentWidget,
                      SizedBox(
                        height: 12.0,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  width: 37,
                  bottom: 0,
                  top: topSpace,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        pointWidget,
                        Expanded(
                          child: Container(
                            width: 27,
                            child: _MySeparatorVertical(
                              color: Colors.grey,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MySeparatorVertical extends StatelessWidget {
  final Color color;

  const _MySeparatorVertical({this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final height = constraints.constrainHeight();
        final dashWidth = 4.0;
        final dashCount = (height / (2 * dashWidth)).floor();
        print("dashCount $dashCount  height $height");

        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: 1,
              height: dashWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.vertical,
        );
      },
    );
  }
}
