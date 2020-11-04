import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';

class ChannelGateway extends StatefulWidget {
  PageContext context;

  ChannelGateway({this.context});

  @override
  _ChannelGatewayState createState() => _ChannelGatewayState();
}

class _ChannelGatewayState extends State<ChannelGateway> {
  Channel _channel;
  bool _isSetGeo = false;

  @override
  void initState() {
    _channel = widget.context.parameters['channel'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    this._channel = null;
    this._isSetGeo = false;
    super.dispose();
  }

  _load() async {
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    this._isSetGeo = await pinService.getOutputGeoSelector(_channel.id);
    setState(() {});
  }

  _setGeo() async {
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    if (_isSetGeo) {
      await pinService.setOutputGeoSelector(_channel.id, false);
    } else {
      await pinService.setOutputGeoSelector(_channel.id, true);
    }
    this._isSetGeo = await pinService.getOutputGeoSelector(_channel.id);
    setState(() {});
  }

  _reloadChannel() async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    _channel = await channelService.getChannel(_channel.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '管道设置',
        ),
        titleSpacing: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              widget.context.backward();
            },
            icon: Icon(
              Icons.clear,
            ),
          ),
        ],
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: _Card(
                title: '',
                items: [
                  _CardItem(
                    title: '名称',
                    tipsText: '${_channel?.name}',
                    onItemTap: () {
                      widget.context.forward(
                        '/netflow/channel/rename',
                        arguments: {
                          'channel': _channel,
                        },
                      ).then((v) {
                        _reloadChannel();
                      });
                    },
                  ),
                  _CardItem(
                    title: '二维码',
                    tipsIconData: FontAwesomeIcons.qrcode,
                    onItemTap: () {
                      widget.context.forward(
                        '/netflow/channel/qrcode',
                        arguments: {
                          'channel': _channel,
                        },
                      );
                    },
                  ),
//                  _CardItem(
//                    title: '微站',
//                    tipsText: '百味湘菜馆',
//                    onItemTap: () {
//                      widget.context.forward('/site/marchant');
//                    },
//                  ),
                  _CardItem(
                    title: '管道动态',
                    onItemTap: () {
                      widget.context.forward(
                        '/netflow/portal/channel',
                        arguments: {
                          'channel': _channel,
                          'owner':widget.context.principal.person,
                        },
                      ).then((v) {
                        setState(() {});
                      });
                    },
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 10,
              ),
            ),
            SliverToBoxAdapter(
              child: _Card(
                title: '管道进口',
                items: [
                  _CardItem(
                    title: '公众',
                    tipsText: '如果不愿接收某人的信息可将他移除',
                    onItemTap: () {
                      widget.context.forward('/netflow/channel/insite/persons',
                          arguments: <String, Object>{'channel': _channel});
                    },
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 10,
              ),
            ),
            SliverToBoxAdapter(
              child: _Card(
                title: '管道出口',
                items: [
                  _CardItem(
                    title: '公众',
                    tipsText: '如果不愿让某人接收信息可将他移除',
                    onItemTap: () {
                      widget.context.forward('/netflow/channel/outsite/persons',
                          arguments: <String, Object>{'channel': _channel});
                    },
                  ),
                  // _CardItem(
                  //   title: '地圈',
                  //   tipsText: '是否充许本管道的信息推送到我的地圈',
                  //   operator: _MySwitch(
                  //     value: _isSetGeo,
                  //     onTap: () {
                  //       _setGeo();
                  //     },
                  //   ),
                  // ),
//                  _CardItem(
//                    title: '微信朋友圈',
//                    tipsText: '是否充许本管道的信息推送到我的微信朋友圈',
//                    operator: _MySwitch(),
//                    onItemTap: () {},
//                  ),
//                  _CardItem(
//                    title: '微信用户',
//                    tipsText: '是否充许本管道的信息推送到我的微信用户',
//                    operator: _MySwitch(),
//                    onItemTap: () {},
//                  ),
                ],
              ),
            ),
//            SliverToBoxAdapter(
//              child: Container(
//                height: 10,
//              ),
//            ),
//            SliverToBoxAdapter(
//              child: _Card(
//                title: '',
//                items: [
//                  _CardItem(
//                    title: '权限',
//                    tipsText: '管道动态、出入口公众等',
//                    onItemTap: () {},
//                  ),
//                ],
//              ),
//            ),
            SliverToBoxAdapter(
              child: Container(
                height: 10,
              ),
            ),
//            SliverToBoxAdapter(
//              child: _Card(
//                title: '',
//                items: [
//                  _CardItem(
//                    title: '推广',
//                    tipsText: '让别人帮您推广本管道，请充钱',
//                    onItemTap: () {
//                      widget.context.forward('/netflow/channel/popularize');
//                    },
//                  ),
//                  _CardItem(
//                    title: '转让',
//                    tipsText: '受让方除得到本管道且连同所属微站',
//                    onItemTap: () {
//                      widget.context.forward('/netflow/channel/popularize');
//                    },
//                  ),
//                ],
//              ),
//            ),
          ],
        ),
      ),
    );
  }
}

class _MySwitch extends StatefulWidget {
  bool value;
  Function() onTap;

  _MySwitch({this.onTap, this.value = false});

  @override
  __MySwitchState createState() => __MySwitchState();
}

class __MySwitchState extends State<_MySwitch> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      child: Switch.adaptive(
        value: widget.value,
        onChanged: (value) {
          if (widget.onTap != null) {
            widget.onTap();
          }
          setState(() {
            widget.value = value;
          });
        },
      ),
    );
  }
}

class _CardItem extends StatefulWidget {
  String title;
  IconData tipsIconData;
  String tipsText;
  Widget operator;
  Function() onItemTap;
  List<String> images;

  _CardItem({
    this.title,
    this.tipsText = '',
    this.tipsIconData,
    this.operator,
    this.onItemTap,
    this.images,
  }) {
    if (operator == null) {
      this.operator = Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Colors.grey[500],
      );
    }
    if (this.images == null) {
      this.images = [];
    }
  }

  @override
  State createState() => _CardItemState();
}

class _CardItemState extends State<_CardItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: this.widget.onItemTap,
      child: Container(
        padding: EdgeInsets.only(
          top: 15,
          bottom: 15,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                right: 10,
              ),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        widget.images.isEmpty
                            ? Container(
                                width: 0,
                                height: 0,
                              )
                            : Flexible(
                                child: Wrap(
                                  textDirection: TextDirection.rtl,
                                  children: widget.images.map((value) {
                                    return Padding(
                                      padding: EdgeInsets.all(4),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(3),
                                        ),
                                        child: Image.network(
                                          value,
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                        StringUtil.isEmpty(widget.tipsText)
                            ? Container(
                                width: 0,
                                height: 0,
                              )
                            : Expanded(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text(
                                    widget.tipsText,
                                    softWrap: true,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  widget.tipsIconData == null
                      ? Container(
                          width: 0,
                          height: 0,
                        )
                      : Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Icon(
                            widget.tipsIconData,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                  Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: widget.operator,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatefulWidget {
  String title;
  List<_CardItem> items;

  _Card({this.title, this.items});

  @override
  __CardState createState() => __CardState();
}

class __CardState extends State<_Card> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      child: Row(
        children: <Widget>[
          StringUtil.isEmpty(widget.title)
              ? Container(
                  width: 0,
                  height: 0,
                )
              : Container(
                  width: 70,
                  child: Text(
                    widget.title,
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
          Expanded(
            child: Container(
              child: Column(
                children: widget.items.map((item) {
                  if (index < widget.items.length - 1) {
                    index++;
                    return Column(
                      children: <Widget>[
                        item,
                        Divider(
                          height: 1,
                        ),
                      ],
                    );
                  }
                  index = 0;
                  return item;
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
