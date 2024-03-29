import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class ChannelRecycleBin extends StatefulWidget {
  PageContext context;

  ChannelRecycleBin({this.context});

  @override
  _ChannelRecycleBinState createState() => _ChannelRecycleBinState();
}

class _ChannelRecycleBinState extends State<ChannelRecycleBin> {
  EasyRefreshController _controller = EasyRefreshController();
  List<Channel> _channels = [];
  int _limit = 40, _offset = 0;
  bool _isLoading = true;
  Map<String,bool> _isProcessing={};
  @override
  void initState() {
    _load().then((value) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    IChannelRemote channelRemote =
        widget.context.site.getService('/remote/channels');
    var items = await channelRemote.pageMyDeletedChannel(_limit, _offset);
    if (items.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += items.length;
    _channels.addAll(items);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _recoverChannel(Channel channel) async {
    setState(() {
      _isProcessing[channel.id]=true;
    });
    IChannelRemote channelRemote =
        widget.context.site.getService('/remote/channels');
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    await channelRemote.recoverChannel(channel.id);
    await channelService.addChannel(channel, isOnlyLocal: true);
    _channels.removeWhere((element) => element.id == channel.id);
    if (mounted) {
      setState(() {
        _isProcessing.remove(channel.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('回收站'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: EasyRefresh(
              header: easyRefreshHeader(),
              footer: easyRefreshFooter(),
              controller: _controller,
              onLoad: _load,
              child: ListView(
                children: _renderItems(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 20,
              bottom: 10,
              left: 20,
              right: 20,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '注意：',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(
                    '系统清理规则：为不定期，且清理后其内容不能恢复。如有仍需要请及时恢复',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _renderItems() {
    var items = <Widget>[];
    if (_isLoading) {
      items.add(
        SizedBox(
          height: 20,
        ),
      );
      items.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '正在加载...',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
      return items;
    }
    if (_channels.isEmpty) {
      items.add(
        SizedBox(
          height: 20,
        ),
      );
      items.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '回收站为空',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
      return items;
    }
    for (var ch in _channels) {
      items.add(
        Padding(
          padding: EdgeInsets.only(
            top: 15,
            bottom: 15,
            left: 15,
            right: 15,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: getAvatarWidget(ch.leading, widget.context),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text('${ch.name ?? ''}'),
              ),
              SizedBox(
                width: 10,
              ),
              RaisedButton(
                color: (_isProcessing[ch.id]??false)?Colors.grey:Colors.green,
                onPressed:(_isProcessing[ch.id]??false)?null: () {
                  _recoverChannel(ch);
                },
                child: Text(
                  '恢复',
                  style: TextStyle(
                    color: (_isProcessing[ch.id]??false)?Colors.white24:Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      items.add(
        Divider(
          height: 1,
          indent: 65,
        ),
      );
    }
    return items;
  }
}
