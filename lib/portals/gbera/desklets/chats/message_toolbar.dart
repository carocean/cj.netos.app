import 'dart:convert';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zefyr/zefyr.dart';

import 'chattalk_opener.dart';

class MessageToolbar extends StatefulWidget {
  Widget child;
  ChatRoom chatRoom;
  ChatMessage message;
  PageContext context;
  BuildContext buildContext;
  ZefyrController controller;

  MessageToolbar(
      {this.child,
        this.chatRoom,
      this.context,
      this.buildContext,
      this.message,
      this.controller});

  @override
  _MessageToolbarState createState() => _MessageToolbarState();
}

class _MessageToolbarState extends State<MessageToolbar> {
  bool get isMessageForSender =>
      widget.message.sender == widget.context.principal.person;
  bool get isMessageCanceled=>widget.message.state=='canceled';
  CustomPopupMenuController _customPopupMenuController =
      CustomPopupMenuController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _customPopupMenuController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MessageToolbar oldWidget) {
    if (oldWidget.message != widget.message) {
      oldWidget.child = widget.child;
      oldWidget.message = widget.message;
      oldWidget.context = widget.context;
      oldWidget.controller = widget.controller;
      oldWidget.chatRoom=widget.chatRoom;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      controller: _customPopupMenuController,
      onHideMenu: () {
        var selection = TextSelection(baseOffset: 0, extentOffset: 0);
        widget.controller?.updateSelection(selection);
      },
      child: widget.child,
      menuBuilder: () {
        return Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF4C4C4C),
            borderRadius: BorderRadius.circular(4),
          ),
          constraints: BoxConstraints(
            minWidth: 200,
          ),
          child: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 15,
            children: _renderActions(),
          ),
        );
      },
      barrierColor: Colors.transparent,
      pressType: PressType.longPress,
    );
  }

  List<Widget> _renderActions() {
    var items = <Widget>[];
    var type = widget.message.contentType;
    var textStyle = TextStyle(
      fontSize: 12,
      color: Colors.white,
    );
    switch (type) {
      case 'text':
        if (widget.controller != null) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            var selection = widget.controller.selection.copyWith(
                baseOffset: 0,
                extentOffset: widget.message.content?.length ?? 0);
            widget.controller.updateSelection(selection);
          });
        }
        items.addAll(
          _renderTextMessageActions(textStyle),
        );
        break;
      case 'share':
        items.addAll(
          _renderShareMessageActions(textStyle),
        );
        break;
      case 'image':
        items.addAll(
          _renderImageMessageActions(textStyle),
        );
        break;
      case 'audio':
        items.addAll(
          _renderAudioMessageActions(textStyle),
        );
        break;
      case 'video':
        items.addAll(
          _renderVideoMessageActions(textStyle),
        );
        break;
      case 'transTo':
        break;
      case '/pay/absorbs':
        break;
      case '/pay/trials':
        break;
      default:
        print('没有为该消息类型定义菜单:$type');
        break;
    }
    return items;
  }

  List<Widget> _renderVideoMessageActions(TextStyle textStyle) {
    var extra = <Widget>[];
    if (isMessageForSender&&!isMessageCanceled) {
      extra.add(
        _getActionCancel(textStyle),
      );
    }
    return <Widget>[
      _getActionForward(textStyle),
      _getActionSave(textStyle),
      ...extra,
      _getActionDelete(textStyle),
    ];
  }

  List<Widget> _renderAudioMessageActions(TextStyle textStyle) {
    var extra = <Widget>[];
    if (isMessageForSender&&!isMessageCanceled) {
      extra.add(
        _getActionCancel(textStyle),
      );
    }
    return <Widget>[
      _getActionForward(textStyle),
      ...extra,
      _getActionDelete(textStyle),
    ];
  }

  List<Widget> _renderImageMessageActions(TextStyle textStyle) {
    var extra = <Widget>[];
    if (isMessageForSender&&!isMessageCanceled) {
      extra.add(
        _getActionCancel(textStyle),
      );
    }
    return <Widget>[
      _getActionForward(textStyle),
      _getActionSave(textStyle),
      ...extra,
      _getActionDelete(textStyle),
    ];
  }

  List<Widget> _renderShareMessageActions(TextStyle textStyle) {
    var extra = <Widget>[];
    if (isMessageForSender&&!isMessageCanceled) {
      extra.add(
        _getActionCancel(textStyle),
      );
    }
    return <Widget>[
      _getActionForward(textStyle),
      ...extra,
      _getActionDelete(textStyle),
    ];
  }

  List<Widget> _renderTextMessageActions(TextStyle textStyle) {
    var extra = <Widget>[];
    if (isMessageForSender&&!isMessageCanceled) {
      extra.add(
        _getActionCancel(textStyle),
      );
    }
    return <Widget>[
      _getActionCopy(textStyle),
      _getActionForward(textStyle),
      ...extra,
      _getActionDelete(textStyle),
    ];
  }

  Widget _getActionSave(TextStyle textStyle) {
    return InkWell(
      onTap: _isSaving
          ? null
          : () {
              _save();
            },
      child: Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Column(
          children: [
            Icon(
              Icons.redo,
              size: 18,
              color: Colors.white,
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              '保存',
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getActionCancel(TextStyle textStyle) {
    return InkWell(
      onTap: () {
        _cancel();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Column(
          children: [
            Icon(
              Icons.redo,
              size: 18,
              color: Colors.white,
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              '撤回',
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getActionCopy(TextStyle textStyle) {
    return InkWell(
      onTap: widget.controller == null
          ? null
          : () {
              var data = ClipboardData(text: widget.message.content ?? '');
              Clipboard.setData(data);
              var done = TextSelection(baseOffset: 0, extentOffset: 0);
              // var done = widget.controller.selection.copyWith(
              //     baseOffset: 0, extentOffset:  0);
              widget.controller.updateSelection(done);
              _customPopupMenuController?.hideMenu();
            },
      child: Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Column(
          children: [
            Icon(
              Icons.copy,
              size: 18,
              color: Colors.white,
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              '复制',
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getActionForward(TextStyle textStyle) {
    return InkWell(
      onTap: () {
        _forward();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Column(
          children: [
            Icon(
              Icons.share,
              size: 18,
              color: Colors.white,
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              '转发',
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getActionDelete(TextStyle textStyle) {
    return InkWell(
      onTap: () {
        _deleteMessage();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Column(
          children: [
            Icon(
              Icons.delete,
              size: 18,
              color: Colors.white,
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              '删除',
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMessage() async {
    IP2PMessageService messageService =
        widget.context.site.getService('/chat/p2p/messages');
    var msg = widget.message;
    await messageService.remove(msg.room, msg.id);
    _customPopupMenuController.hideMenu();
    ToolbarNotification(command: 'delete', message: msg)
        .dispatch(widget.buildContext);
  }

  Future<void> _save() async {
    _isSaving = true;
    setState(() {});
    var content = widget.message.content;
    var map = jsonDecode(content);
    var file = map['path'];
    _customPopupMenuController.hideMenu();
    var v = await showDialog(
      context: widget.buildContext,
      child: AlertDialog(
        title: Text('保存到相册'),
        elevation: 0,
        content: _MediaSaveWidget(
          context: widget.context,
          file: file,
        ),
        actions: [
          FlatButton(
            onPressed: () {
              widget.context.backward();
            },
            child: Text(
              '取消',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
    _isSaving = false;
  }

  Future<void> _forward() async {
    _customPopupMenuController.hideMenu();
    await showDialog(
      context: widget.buildContext,
      child: widget.context.part(
        '/chatroom/message/forward',
        context,
        arguments: {
          'message': widget.message,
        },
      ),
    );
  }

  Future<void> _cancel() async {
    var message=widget.message;
    var room=widget.chatRoom;
    _customPopupMenuController.hideMenu();
    IP2PMessageService messageService =
        widget.context.site.getService('/chat/p2p/messages');
    await messageService.cancelMessage(room.creator,message.room, message.id);
    ToolbarNotification(message:message, command: 'cancelMessage')
        .dispatch(widget.buildContext);
  }
}

class ToolbarNotification extends Notification {
  String command;
  ChatMessage message;

  ToolbarNotification({this.command, this.message});
}

class _MediaSaveWidget extends StatefulWidget {
  PageContext context;
  String file;

  _MediaSaveWidget({this.context, this.file});

  @override
  __MediaSaveWidgetState createState() => __MediaSaveWidgetState();
}

class __MediaSaveWidgetState extends State<_MediaSaveWidget> {
  double _baifenbi;
  int _process = 0;

  @override
  void initState() {
    _doProcess();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _doProcess() async {
    var file = widget.file;
    if (!file.startsWith('/')) {
      var dir = await getExternalStorageDirectory();
      var localFile = '${dir.path}/${MD5Util.MD5(file)}.${fileExt(file)}';
      await widget.context.ports.download(file, localFile,
          onReceiveProgress: (i, j) {
        _baifenbi = ((i * 1.0) / j) * 100.00;
        if (mounted) {
          setState(() {});
        }
      });
    }
    _process = 1;
    if (mounted) {
      setState(() {});
    }
    var result = await ImageGallerySaver.saveFile(file);
    _process = -1;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_process) {
      case 0:
        return Container(
          height: 60,
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '正在下载...',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text('${_baifenbi.toStringAsFixed(2)}%'),
            ],
          ),
        );
        break;
      case 1:
        return Container(
          height: 60,
          alignment: Alignment.center,
          child: Text(
            '正在保存...',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        );
        break;
      default:
        return Container(
          height: 60,
          alignment: Alignment.center,
          child: Text(
            '保存成功，请到相册中查看',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        );
    }
    if (_process < 0) {}
  }
}
