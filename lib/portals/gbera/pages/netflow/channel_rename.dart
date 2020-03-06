import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';

class RenameChannel extends StatefulWidget {
  PageContext context;

  RenameChannel({this.context});

  @override
  _RenameChannelState createState() => _RenameChannelState();
}

class _RenameChannelState extends State<RenameChannel> {
  Channel _channel;
  TextEditingController _controller;
  String _errorText;
  @override
  void initState() {
    _channel = widget.context.parameters['channel'];
    _controller=TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    this._channel = null;
    _controller.dispose();
    super.dispose();
  }

  Future<void> _renameChannel() async {
    IChannelService channelService=widget.context.site.getService('/netflow/channels');
    await channelService.updateName(_channel.id,_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page.title,
        ),
        titleSpacing: 0,
        elevation: 0.0,
        automaticallyImplyLeading: true,
        actions: <Widget>[
          IconButton(
            color: Colors.red,
            icon: Icon(
              Icons.check,
            ),
            onPressed: () {
              var text=_controller.text;
              if(StringUtil.isEmpty(text)) {
                _errorText='不能为空';
              }
              _renameChannel().then((v) {
                widget.context.backward();
              }).catchError((e) {
                print('error:${e.toString()}');
              });
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(
          left: 40,
          right: 40,
        ),
        alignment: Alignment.center,
        child: Card(
          child: TextField(
            onChanged: (v){
              _errorText='';
            },
            controller: _controller,
            maxLines: 1,
            maxLength: 20,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '输入新的管道名',
              contentPadding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 50,
                bottom: 50,
              ),
              border: InputBorder.none,
              errorText: _errorText,
              labelText: '管道名',
              labelStyle: TextStyle(
                color: Colors.grey[500],
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
