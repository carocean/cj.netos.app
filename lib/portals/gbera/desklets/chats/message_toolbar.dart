import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:zefyr/zefyr.dart';

class MessageToolbar extends StatefulWidget {
  Widget child;
  ChatMessage message;
  PageContext context;
  ZefyrController controller;

  MessageToolbar({this.child, this.context, this.message, this.controller});
  @override
  _MessageToolbarState createState() => _MessageToolbarState();
}

class _MessageToolbarState extends State<MessageToolbar> {
  bool get isMessageForSender =>
      widget.message.sender == widget.context.principal.person;
  CustomPopupMenuController _customPopupMenuController=CustomPopupMenuController();
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
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      controller: _customPopupMenuController,
      onHideMenu: (){
        var selection = TextSelection(
            baseOffset: 0, extentOffset: 0);
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
        if(widget.controller!=null) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            var selection = widget.controller.selection.copyWith(
                baseOffset: 0, extentOffset: widget.message.content?.length ?? 0);
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
    if (isMessageForSender) {
      extra.add(
        Padding(
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
    return <Widget>[
      Padding(
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
      ...extra,
      Padding(
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
    ];
  }

  List<Widget> _renderAudioMessageActions(TextStyle textStyle) {
    var extra = <Widget>[];
    if (isMessageForSender) {
      extra.add(
        Padding(
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
    return <Widget>[
      Padding(
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
      ...extra,
      Padding(
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
    ];
  }

  List<Widget> _renderImageMessageActions(TextStyle textStyle) {
    var extra = <Widget>[];
    if (isMessageForSender) {
      extra.add(
        Padding(
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
    return <Widget>[
      Padding(
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
      ...extra,
      Padding(
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
    ];
  }

  List<Widget> _renderShareMessageActions(TextStyle textStyle) {
    var extra = <Widget>[];
    if (isMessageForSender) {
      extra.add(
        Padding(
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
    return <Widget>[
      Padding(
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
      ...extra,
      Padding(
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
    ];
  }

  List<Widget> _renderTextMessageActions(TextStyle textStyle) {
    var extra = <Widget>[];
    if (isMessageForSender) {
      extra.add(
        Padding(
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

    return <Widget>[
      InkWell(
        onTap: widget.controller == null
            ? null
            : () {

          var data = ClipboardData(text: widget.message.content??'');
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
      ),
      Padding(
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
      ...extra,
      InkWell(
        onTap: (){
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
      ),
    ];
  }
  Future<void> _deleteMessage()async{
    IP2PMessageService messageService =
    widget.context.site.getService('/chat/p2p/messages');
    // messageService.
  }
}
