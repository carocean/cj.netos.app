import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/system/local/entities.dart';

class MessageToolbar extends StatelessWidget {
  Widget child;
  ChatMessage message;
  PageContext context;

  MessageToolbar({this.child, this.context, this.message});

  bool get isMessageForSender =>
      message.sender == this.context.principal.person;

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      child: child,
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
    var type = message.contentType;
    var textStyle = TextStyle(
      fontSize: 12,
      color: Colors.white,
    );
    switch (type) {
      case 'text':
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
    var extra=<Widget>[];
    if(isMessageForSender){
      extra.add( Padding(
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
      ),);
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
    var extra=<Widget>[];
    if(isMessageForSender){
      extra.add( Padding(
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
      ),);
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
    var extra=<Widget>[];
    if(isMessageForSender){
      extra.add( Padding(
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
      ),);
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
    var extra=<Widget>[];
    if(isMessageForSender){
      extra.add( Padding(
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
      ),);
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
    var extra=<Widget>[];
    if(isMessageForSender){
      extra.add( Padding(
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
      ),);
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
}
