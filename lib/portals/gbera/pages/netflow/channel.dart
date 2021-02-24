import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:common_utils/common_utils.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/cc_medias_widget.dart';
import 'package:netos_app/common/easy_refresh.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/netflow.dart';
import 'package:netos_app/portals/gbera/pages/system/tip_off_item.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/parts/parts.dart';
import 'package:netos_app/portals/gbera/store/remotes.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/gbera/store/sync_tasks.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/system.dart';
import 'package:uuid/uuid.dart';

import 'article_entities.dart';
import 'channel_handler.dart';

class ChannelPage extends StatefulWidget {
  PageContext context;

  ChannelPage({this.context});

  @override
  _ChannelPageState createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  List<ChannelMessage> _pageMessages;
  int limit = 15, offset = 0;
  GlobalKey<_ChannelPageState> _scaffoldKey;
  Channel _channel;
  EasyRefreshController _refreshController;

  @override
  void initState() {
    _refreshController = EasyRefreshController();
    _channel = widget.context.parameters['channel'];
    _scaffoldKey = GlobalKey<_ChannelPageState>();
    _pageMessages = <ChannelMessage>[];
    syncTaskMananger.tasks['netflow.channel.inputPin'] = SyncTask(
      doTask: _sync_inputPin_task,
    )..run(
        syncName: 'netflow.channel.inputPin',
        context: widget.context,
        checkRemote: _sync_inputPin_check,
        forceSync: true,
      );
    syncTaskMananger.tasks['netflow.channel.outputPin'] = SyncTask(
      doTask: _sync_outputPin_task,
    )..run(
        syncName: 'netflow.channel.outputPin',
        context: widget.context,
        checkRemote: _sync_outputPin_check,
        forceSync: true,
      );
    _onload().then((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _channel = null;
    _scaffoldKey = null;
    _pageMessages.clear();
    super.dispose();
  }

  Future<SyncArgs> _sync_inputPin_check(PageContext context) async {
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    ChannelInputPerson lastInputPerson =
        await pinService.getLastInputPerson(_channel.id);
    int beginInputPersonTime =
        lastInputPerson == null ? 0 : lastInputPerson.atime;
    var portsurl = context.site.getService('@.prop.ports.link.netflow');
    return SyncArgs(
      portsUrl: portsurl,
      restCmd: 'listAllInputPerson',
      parameters: {
        'channel': _channel.id,
        'atime': beginInputPersonTime,
      },
    );
  }

  Future<void> _sync_inputPin_task(PageContext context, Frame frame) async {
    var source = frame.contentText;
    List list = jsonDecode(source);
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    for (var iperson in list) {
      ChannelInputPerson inputPerson = ChannelInputPerson(
        iperson['id'],
        iperson['channel'],
        iperson['person'],
        iperson['rights'],
        iperson['atime'],
        context.principal.person,
      );
      if (await pinService.existsInputPerson(
          inputPerson.person, inputPerson.channel)) {
        continue;
      }
      if (!(await personService.existsPerson(inputPerson.person))) {
        var person = await personService.getPerson(inputPerson.person,
            isDownloadAvatar: true);
        await personService.addPerson(person);
      }
      await pinService.addInputPerson(inputPerson);
    }
  }

  Future<SyncArgs> _sync_outputPin_check(PageContext context) async {
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    ChannelOutputPerson lastOutputPerson =
        await pinService.getLastOutputPerson(_channel.id);
    int beginOutputPersonTime =
        lastOutputPerson == null ? 0 : lastOutputPerson.atime;
    var portsurl = context.site.getService('@.prop.ports.link.netflow');
    return SyncArgs(
      portsUrl: portsurl,
      restCmd: 'listAllOutputPerson',
      parameters: {
        'channel': _channel.id,
        'atime': beginOutputPersonTime,
      },
    );
  }

  Future<void> _sync_outputPin_task(PageContext context, Frame frame) async {
    var source = frame.contentText;
    List list = jsonDecode(source);
    IChannelPinService pinService =
        widget.context.site.getService('/channel/pin');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    for (var operson in list) {
      var outputPerson = ChannelOutputPerson(
        operson['id'],
        operson['channel'],
        operson['person'],
        operson['rights'],
        operson['atime'],
        context.principal.person,
      );
      if (await pinService.existsOutputPerson(
          outputPerson.person, outputPerson.channel)) {
        continue;
      }
      if (!(await personService.existsPerson(outputPerson.person))) {
        var person = await personService.getPerson(outputPerson.person,
            isDownloadAvatar: true);
        await personService.addPerson(person);
      }
      await pinService.addOutputPerson(outputPerson);
    }
  }

  _reloadChannel() async {
    IChannelService channelService =
        widget.context.site.getService('/netflow/channels');
    _channel = await channelService.getChannel(_channel.id);
    setState(() {});
  }

  _refreshMessages() async {
    this.offset = 0;
    this._pageMessages.clear();
    _onload().then((v) {
      _refreshController.resetLoadState();
      setState(() {});
    });
  }

  Future<List<ChannelMessage>> _onload() async {
    var onchannel = widget.context.parameters['channel']?.id;
    IChannelMessageService messageService =
        widget.context.site.getService('/channel/messages');
    await messageService.readAllArrivedMessage(onchannel);
    var messages = await messageService.pageMessage(limit, offset, onchannel);
    if (messages != null && !messages.isEmpty) {
      offset += messages.length;
      for (var msg in messages) {
        _pageMessages.add(msg);
      }
    } else {
      _refreshController.finishLoad(noMore: true, success: true);
    }
    return _pageMessages;
  }

  @override
  Widget build(BuildContext context) {
    var slivers = <Widget>[
      SliverToBoxAdapter(
        child: Header(
          context: widget.context,
          channel: _channel,
          refresh: () {
            _reloadChannel();
            _refreshMessages();
          },
        ),
      ),
    ];
    if (_pageMessages.isEmpty) {
      slivers.add(
        SliverFillRemaining(
          child: Container(
            constraints: BoxConstraints.expand(),
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(
              top: 20,
            ),
            child: Text('没有活动'),
            color: Colors.white,
          ),
        ),
      );
    }
    for (var msg in _pageMessages) {
      slivers.add(
        SliverToBoxAdapter(
          child: _MessageCard(
            context: widget.context,
            message: msg,
            channel: _channel,
            onDeleted: (msg) {
              _pageMessages.remove(msg);
              setState(() {});
            },
          ),
        ),
      );
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _channel?.name,
        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        toolbarOpacity: 1,
        actions: <Widget>[
          useSimpleLayout()
              ? SizedBox.shrink()
              : _AbsorberAction(
                  context: widget.context,
                  channel: _channel,
                ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () {
              if (useSimpleLayout()) {
                widget.context.forward('/netflow/channel/publish_article/ios',
                    arguments: <String, dynamic>{
                      'type': 'text',
                      'channel': _channel,
                      'refreshMessages': _refreshMessages
                    });
                return;
              }
              widget.context.forward('/netflow/channel/publish_article',
                  arguments: <String, dynamic>{
                    'type': 'text',
                    'channel': _channel,
                    'refreshMessages': _refreshMessages
                  });
            },
            child: IconButton(
              icon: Icon(
                Icons.camera_enhance,
                size: 20,
              ),
              onPressed: () {
                showDialog<Map<String, Object>>(
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                    title: Text('请选择'),
                    children: <Widget>[
                      DialogItem(
                        text: '文本',
                        subtext: '注：长按窗口右上角按钮便可不弹出该对话框直接发文',
                        icon: Icons.font_download,
                        color: Colors.grey[500],
                        onPressed: () {
                          widget.context.backward(
                              result: <String, dynamic>{'type': 'text'});
                        },
                      ),
                      DialogItem(
                        text: '从相册选择',
                        icon: Icons.image,
                        color: Colors.grey[500],
                        onPressed: () async {
                          var image = await ImagePicker().getImage(
                            source: ImageSource.gallery,
                            maxHeight: Adapt.screenH(),
                            imageQuality: 80,
                          );
                          if (image == null) {
                            widget.context.backward();
                            return;
                          }
                          widget.context.backward(result: <String, dynamic>{
                            'type': 'gallery',
                            'mediaFile': MediaFile(
                                type: MediaFileType.image,
                                src: File(image.path)),
                          });
                        },
                      ),
                    ],
                  ),
                ).then<void>((value) {
                  if (value == null) {
                    return;
                  }
                  value['channel'] = _channel;
                  value['refreshMessages'] = _refreshMessages;
                  widget.context.forward('/netflow/channel/publish_article',
                      arguments: value);
                });
              },
            ),
          ),
        ],
      ),
      body: EasyRefresh.custom(
        header: easyRefreshHeader(),
        footer: easyRefreshFooter(),
        controller: _refreshController,
//        onRefresh: _onRefresh,//注释掉onRefresh则不支持下拉
        onLoad: _onload,
        //onload是上拉
//        footer: BallPulseFooter(),
        slivers: slivers,
      ),
    );
  }
}

class DialogItem extends StatelessWidget {
  const DialogItem(
      {Key key, this.icon, this.color, this.text, this.subtext, this.onPressed})
      : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final String subtext;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 36.0, color: color),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 5,
                    ),
                    child: Text(text),
                  ),
                  subtext == null
                      ? Container(
                          width: 0,
                          height: 0,
                        )
                      : Container(
                          constraints: BoxConstraints.tightForFinite(
                            width: double.maxFinite,
                          ),
                          child: Text(
                            subtext,
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey[300],
                            ),
                            softWrap: true,
//                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Header extends StatefulWidget {
  PageContext context;
  Function() refresh;
  Channel channel;

  Header({
    this.context,
    this.refresh,
    this.channel,
  });

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  int _arrivedMessageCount = 0;
  String _arrivedMessageTips = '';
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    Stream<ChannelEventArgs> _events = channelNotifyStreamController.stream;
    _streamSubscription = _events.listen((event) {
      var command = event.command;
      var channel = event.channel;
      if (widget.channel.id != channel) {
        return;
      }
      var args = event.args;
      if ("pushDocumentCommand" == command && args is Map) {
        var msg = args['message'];
        if (msg.onChannel != widget.channel?.id) {
          return;
        }
      }
      _arrivedMessageCount++;
//      switch(command) {
//        case 'likeDocumentCommand':
//          _arrivedMessageTips='';
//          break;
//        case 'unlikeDocumentCommand':
//          break;
//        default:
//          print('不明确的消息提示刷新');
//          break;
//      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _arrivedMessageCount = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _channel = widget.context.parameters['channel'];
    return Container(
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.only(
        top: 20,
        left: 15,
        bottom: 10,
        right: 15,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/netflow/manager/channel_gateway',
                  arguments: <String, dynamic>{'channel': _channel}).then((v) {
                if (widget.refresh != null) {
                  widget.refresh();
                }
              });
            },
            child: Padding(
              padding: EdgeInsets.only(
                right: 5,
              ),
              child: Icon(
                widget.context
                    .findPage('/netflow/manager/channel_gateway')
                    ?.icon,
                size: 18,
                color: Colors.grey[600],
              ),
            ),
          ),
          _arrivedMessageCount == 0
              ? Container(
                  width: 0,
                  height: 0,
                )
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _arrivedMessageCount = 0;
                    if (widget.refresh != null) {
                      widget.refresh();
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 10,
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: '有$_arrivedMessageCount条新消息',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatefulWidget {
  PageContext context;
  ChannelMessage message;
  Channel channel;
  void Function(ChannelMessage message) onDeleted;

  _MessageCard({
    this.context,
    this.channel,
    this.message,
    this.onDeleted,
  });

  @override
  __MessageCardState createState() => __MessageCardState();
}

class __MessageCardState extends State<_MessageCard> {
  int maxLines = 4;
  _InteractiveRegionRefreshAdapter _interactiveRegionRefreshAdapter;
  Person _person;
  Future<Person> _future_getPerson;
  PurchaseOR _purchaseOR;
  bool _isLoaded = false;
  AbsorberResultOR _absorberResultOR;
  String _shareImg;

  @override
  void initState() {
    _future_getPerson = _getPerson();
    _interactiveRegionRefreshAdapter = _InteractiveRegionRefreshAdapter();
    _load().then((value) {
      if (mounted) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _interactiveRegionRefreshAdapter = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(_MessageCard oldWidget) {
    if (oldWidget.message.id != widget.message.id) {
      oldWidget.message = widget.message;
      _load().then((value) {
        if (mounted) {
          setState(() {});
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _load() async {
    _isLoaded = false;
    _person = await _getPerson();
    _purchaseOR = await _getPurchase();
    var absorber = widget.message.absorber;
    _absorberResultOR = await _getAbsorber(absorber);
    _isLoaded = true;
  }

  Future<AbsorberResultOR> _getAbsorber(String absorber) async {
    if (StringUtil.isEmpty(absorber)) {
      return null;
    }
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    return await robotRemote.getAbsorber(absorber);
  }

  Future<PurchaseOR> _getPurchase() async {
    var sn = widget.message.purchaseSn;
    if (StringUtil.isEmpty(sn)) {
      return null;
    }
    IWyBankPurchaserRemote purchaserRemote =
        widget.context.site.getService('/remote/purchaser');
    return await purchaserRemote.getPurchaseRecordPerson(
        widget.message.creator, sn);
  }

  Future<Person> _getPerson() async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    var person = '';
    if (!StringUtil.isEmpty(widget.message.upstreamPerson)) {
      person = widget.message.upstreamPerson;
    }
    if (StringUtil.isEmpty(person)) {
      person = widget.message.creator;
    }
    if (StringUtil.isEmpty(person)) {
      return null;
    }
    return await personService.getPerson(person);
  }

  Future<List<MediaSrc>> _getMedias() async {
    IChannelMediaService channelMediaService =
        widget.context.site.getService('/channel/messages/medias');
    var medias = await channelMediaService.getMedias(widget.message.id);
    List<MediaSrc> list = [];
    for (var media in medias) {
      if (StringUtil.isEmpty(_shareImg) && 'image' == media.type) {
        _shareImg = media.src;
      }
      list.add(media.toMediaSrc());
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return Center(
        child: SizedBox(
          width: 0,
          height: 0,
        ),
      );
    }
    return Card(
      shape: Border(),
      elevation: 0,
      margin: EdgeInsets.only(bottom: 15),
      child: Container(
        padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context
                    .forward("/netflow/channel/portal/channel", arguments: {
                  'channel': widget.channel.id,
                  'origin': _person.official,
                });
              },
              child: Padding(
                padding: EdgeInsets.only(top: 5, right: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: getAvatarWidget(_person?.avatar, widget.context),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          widget.context.forward(
                              "/netflow/channel/portal/channel",
                              arguments: {
                                'channel': widget.channel.id,
                                'origin': _person.official,
                              });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          '${_person?.nickName}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
//                      SizedBox(
//                        height: 20,
//                        width: 20,
//                        child: IconButton(
//                          padding: EdgeInsets.all(0),
//                          onPressed: () {
//                            showModalBottomSheet(
//                                context: context,
//                                builder: (context) {
//                                  return widget.context.part(
//                                      '/netflow/channel/serviceMenu', context);
//                                }).then((value) {
//                              print('-----$value');
//                              if (value == null) return;
//                              widget.context
//                                  .forward('/micro/app', arguments: value);
//                            });
//                          },
//                          icon: Icon(
//                            Icons.art_track,
//                            size: 20,
//                            color: Colors.grey[700],
//                          ),
//                        ),
//                      ),
                    ],
                  ),
                  Container(
                    //内容区
                    padding: EdgeInsets.only(top: 5, bottom: 10),
                    alignment: Alignment.topLeft,
                    child: Text.rich(
                      TextSpan(
                        text: '${widget.message.text}',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            setState(() {
                              if (maxLines == 4) {
                                maxLines = 100;
                              } else {
                                maxLines = 4;
                              }
                            });
                          },
                      ),
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  FutureBuilder<List<MediaSrc>>(
                    future: _getMedias(),
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
                      if (snapshot.data.isEmpty) {
                        return Container(
                          width: 0,
                          height: 0,
                        );
                      }
                      return MediaWidget(
                        snapshot.data,
                        widget.context,
                      );
                    },
                  ),
                  Row(
                    //内容坠
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          top: 10,
                        ),
                        child: FutureBuilder<Person>(
                            future: _future_getPerson,
                            builder: (ctx, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.done) {
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
                              var person = snapshot.data;
                              if (person == null) {
                                return Container(
                                  width: 0,
                                  height: 0,
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          text: '${TimelineUtil.format(
                                            widget.message.ctime,
                                            locale: 'zh',
                                            dayFormat: DayFormat.Simple,
                                          )}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[400],
                                          ),
                                          children: [
                                            TextSpan(text: '  '),
                                            (useSimpleLayout() ||
                                                    _purchaseOR
                                                            ?.principalAmount ==
                                                        null)
                                                ? TextSpan(text: '')
                                                : TextSpan(
                                                    text:
                                                        '¥${((_purchaseOR?.principalAmount ?? 0.00) / 100.00).toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () async {
                                                            IWyBankPurchaserRemote
                                                                purchaserRemote =
                                                                widget.context
                                                                    .site
                                                                    .getService(
                                                                        '/remote/purchaser');
                                                            WenyBank bank =
                                                                await purchaserRemote
                                                                    .getWenyBank(
                                                                        _purchaseOR
                                                                            .bankid);
                                                            widget.context
                                                                .forward(
                                                              '/wybank/purchase/details',
                                                              arguments: {
                                                                'purch':
                                                                    _purchaseOR,
                                                                'bank': bank
                                                              },
                                                            );
                                                          },
                                                  ),
                                          ],
                                        ),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
//                                  SizedBox(
//                                    height: 3,
//                                  ),
//                                  Text.rich(
//                                    TextSpan(
//                                      text: '',
//                                      style: TextStyle(
//                                        fontSize: 12,
//                                        color: Colors.grey[400],
//                                      ),
//                                      children: [
//                                        TextSpan(
//                                          text:
//                                              '${widget.context.principal?.person == snapshot.data.official ? '创建自 ' : '来自 '}',
//                                          children: [
//                                            TextSpan(
//                                              text:
//                                                  '${widget.context.principal?.person == snapshot.data.official ? '我' : snapshot.data.nickName}',
//                                              style: TextStyle(
//                                                color: Colors.grey,
//                                                decoration:
//                                                    TextDecoration.underline,
//                                              ),
//                                              recognizer: TapGestureRecognizer()
//                                                ..onTap = () {
//                                                  widget.context.forward(
//                                                      "/site/personal",
//                                                      arguments: {
//                                                        'person': snapshot.data,
//                                                      });
//                                                },
//                                            ),
//                                          ],
//                                        )
//                                      ],
//                                    ),
//                                    softWrap: true,
//                                  ),
                                ],
                              );
                            }),
                      ),
                      _MessageOperatesPopupMenu(
                        message: widget.message,
                        context: widget.context,
                        channel: widget.channel,
                        shareImg: _shareImg,
                        creator: _person,
                        onDeleted: () {
                          if (widget.onDeleted != null) {
                            widget.onDeleted(widget.message);
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
                          widget.context.forward(
                              '/netflow/channel/document/path',
                              arguments: {
                                'person': _person,
                                'channel': widget.channel,
                                'message': widget.message.copy(),
                              });
                        },
                      ),
                    ],
                  ),
                  Container(
                    height: 7,
                  ),

                  ///相关交互区
                  _InteractiveRegion(
                    message: widget.message,
                    context: widget.context,
                    interactiveRegionRefreshAdapter:
                        _interactiveRegionRefreshAdapter,
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
  ChannelMessage message;
  PageContext context;
  Channel channel;
  Person creator;
  String shareImg;
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
    this.channel,
    this.creator,
    this.shareImg,
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
      widget.message.onChannel,
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
          'channel': widget.message.onChannel,
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
        channel: widget.message.onChannel,
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

  Future<void> _tipoffItem() async {
    showDialog(
        context: context,
        child: widget.context.part('/system/tip_off/item', context, arguments: {
          'item': TipOffItemArgs(
            id: widget.message.id,
            type: 'netflow',
            desc: widget.message.text,
          )
        })).then((value) {
      if (value == null) {
        return;
      }
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('举报事项已提交'),
        ),
      );
    });
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (mounted) {
                setState(() {});
              }
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
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
          ),
          SizedBox(
            width: 10,
            height: 14,
            child: VerticalDivider(
              color: Colors.white,
              width: 1,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (mounted) {
                setState(() {});
              }
              if (widget.onComment != null) {
                widget.onComment();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
          ),
          SizedBox(
            width: 10,
            height: 14,
            child: VerticalDivider(
              color: Colors.white,
              width: 1,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (mounted) {
                setState(() {});
              }
              if (widget.onViewFlow != null) {
                widget.onViewFlow();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
          ),
          SizedBox(
            width: 10,
            height: 14,
            child: VerticalDivider(
              color: Colors.white,
              width: 1,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (mounted) {
                setState(() {});
              }
              showModalBottomSheet(
                  context: context,
                  builder: (ctx) {
                    var webshareSite = widget.context.site
                        .getService('@.prop.website.webshare.netflow-viewer');
                    String imgSrc = widget.channel.leading;
                    if (!StringUtil.isEmpty(widget.shareImg)) {
                      imgSrc = widget.shareImg;
                    }
                    return Container(
                      height: 100,
                      constraints: BoxConstraints.tightForFinite(
                        width: double.maxFinite,
                      ),
                      child: widget.context.part(
                        '/external/share',
                        context,
                        arguments: {
                          'title': widget.channel.name,
                          'desc': widget.message.text ?? '',
                          'imgSrc': imgSrc,
                          'link':
                              '$webshareSite?creator=${widget.message.creator}&docid=${widget.message.id}',
                        },
                      ),
                    );
                  });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 2, top: 5, bottom: 5),
                  child: Icon(
                    Icons.comment,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                Text(
                  '分享',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 10,
            height: 14,
            child: VerticalDivider(
              color: Colors.white,
              width: 1,
            ),
          ),
        ];
        if (rights['canDelete']) {
          actions.add(
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (mounted) {
                  setState(() {});
                }
                if (rights['canDelete']) {
                  //如果有删除按钮
                  _deleteMessage().whenComplete(() {
                    if (widget.onDeleted != null) {
                      widget.onDeleted();
                    }
                  });
                } else {
                  //没有删除按钮即为举报
                  _tipoffItem();
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
            ),
          );
          actions.add(
            SizedBox(
              width: 10,
              height: 14,
              child: VerticalDivider(
                color: Colors.white,
                width: 1,
              ),
            ),
          );
        }
        actions.add(GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (mounted) {
              setState(() {});
            }
            _tipoffItem();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 2,
                  top: 1,
                ),
                child: Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              Text(
                '举报',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ));
        return Padding(
          padding: EdgeInsets.only(
            top: 6,
            bottom: 4,
          ),
          child: CustomPopupMenu(
            child: Icon(
              Icons.more_horiz,
              size: 18,
            ),
            menuBuilder: () {
              return Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4C4C4C),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Wrap(
                  direction: Axis.horizontal,
                  spacing: 10,
                  runSpacing: 15,
                  children: actions,
                ),
              );
            },
            barrierColor: Colors.transparent,
            pressType: PressType.singleClick,
          ),
        );
      },
    );
  }
}

class _InteractiveRegion extends StatefulWidget {
  ChannelMessage message;
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
                      'channel': widget.message.onChannel,
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
                                      widget.context.forward(
                                          "/netflow/channel/portal/channel",
                                          arguments: {
                                            'channel': widget.message.onChannel,
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
        '${Uuid().v1()}',
        widget.context.principal.person,
        widget.context.principal.avatarOnRemote,
        widget.message.id,
        content,
        DateTime.now().millisecondsSinceEpoch,
        widget.context.principal.nickName ??
            widget.context.principal.accountCode,
        widget.message.onChannel,
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
          'channel': widget.message.onChannel,
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
        channel: widget.message.onChannel,
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

class _AbsorberAction extends StatefulWidget {
  PageContext context;
  Channel channel;

  _AbsorberAction({
    this.context,
    this.channel,
  });

  @override
  __AbsorberActionState createState() => __AbsorberActionState();
}

class __AbsorberActionState extends State<_AbsorberAction> {
  AbsorberResultOR _absorberResultOR;
  DomainBulletin _bulletin;
  bool _isLoaded = false, _isRefreshing = false;
  StreamController _streamController;
  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _streamController = StreamController.broadcast();
    _isLoaded = false;
    _load().then((value) {
      _isLoaded = true;
      if (mounted) setState(() {});
    });
    _streamSubscription = Stream.periodic(
        Duration(
          seconds: 5,
        ), (count) async {
      if (!_isRefreshing && mounted) {
        return await _refresh();
      }
    }).listen((event) async {
      var v = await event;
      if (v == null) {
        return;
      }
      if (v && !_streamController.isClosed) {
        _streamController
            .add({'absorber': _absorberResultOR, 'bulletin': _bulletin});
      }
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _streamController?.close();
    super.dispose();
  }

  Future<bool> _refresh() async {
    _isRefreshing = true;
    var diff = await _load();
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
    return diff;
  }

  Future<bool> _load() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    var sourceCreator = widget.channel.sourceCreator;
    if (StringUtil.isEmpty(sourceCreator)) {
      sourceCreator = widget.channel.owner;
    }
    var absorbabler = '$sourceCreator/${widget.channel.id}';
    var absorberResultOR =
        await robotRemote.getAbsorberByAbsorbabler(absorbabler);
    if (absorberResultOR == null) {
      return false;
    }
    var bulletin =
        await robotRemote.getDomainBucket(absorberResultOR.absorber.bankid);
    bool diff = (_absorberResultOR == null ||
        (_absorberResultOR.bucket.price != absorberResultOR.bucket.price) ||
        (_bulletin.bucket.waaPrice != bulletin.bucket.waaPrice));
    _bulletin = bulletin;
    _absorberResultOR = absorberResultOR;
    return diff;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return SizedBox(
        height: 0,
        width: 0,
      );
    }

    if (_absorberResultOR == null) {
      return IconButton(
        onPressed: () {
          var channel = widget.channel;
          widget.context.forward(
            '/absorber/apply/simple',
            arguments: {
              'title': channel.name,
              'usage': 0,
              'absorbabler': '${widget.channel.owner}/${widget.channel.id}',
            },
          ).then((value) {
            _load().then((value) {
              _isLoaded = true;
              if (mounted) setState(() {});
            });
          });
        },
        icon: Icon(
          IconData(
            0xe6b2,
            fontFamily: 'absorber',
          ),
          size: 20,
          color: Colors.grey,
        ),
      );
    }
    //存在
    return IconButton(
      icon: Icon(
        IconData(
          0xe6b2,
          fontFamily: 'absorber',
        ),
        size: 20,
        color: _absorberResultOR.bucket.price >= _bulletin.bucket.waaPrice
            ? Colors.red
            : Colors.green,
      ),
      onPressed: () {
        widget.context.forward('/absorber/details/simple', arguments: {
          'absorber': _absorberResultOR.absorber.id,
          'stream': _streamController.stream.asBroadcastStream(),
          'initAbsorber': _absorberResultOR,
          'initBulletin': _bulletin,
        });
      },
    );
  }
}
