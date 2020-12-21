import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/single_media_widget.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_receptor_opener.dart';
import 'package:netos_app/portals/gbera/share/share_card.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

class GeosphereSharePage extends StatefulWidget {
  PageContext context;

  GeosphereSharePage({this.context});

  @override
  _GeosphereSharePageState createState() => _GeosphereSharePageState();
}

class _GeosphereSharePageState extends State<GeosphereSharePage> {
  String _href;
  String _title;
  String _summary;
  String _leading;
  List<GeoReceptor> _receptors = [];
  int _loadState = 0; //0正在载感知器；1正搜索位置；-1完成
  GeoReceptor _selector;
  EasyRefreshController _controller = EasyRefreshController();
  int _limit = 10, _offset = 0;
  TextEditingController _commentController = TextEditingController();
  PurchaseInfo _purchaseInfo;
  int _purchse_amount = 100; //单位为分
  int _purchase_method = 0; //0是零钱；1为体验金
  bool _canPublish = false;
  bool _isEnoughMoney = true;
  int _publishingState = 0; //1正在申购；2正在发布；3发布出错；4成功完成且跳转
  String _districtCode;
  AmapPoi _poi;
  String _label = '';
  StreamController _rechargeController;
  StreamSubscription _rechargeHandler;
  String _purchaseError;
  StreamSubscription _purchaseHandler;

  @override
  void initState() {
    var args = widget.context.parameters;
    _href = args['href'];
    _title = args['title'];
    _summary = args['summary'];
    _leading = args['leading'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _commentController?.dispose();
    _rechargeController?.close();
    _rechargeHandler?.cancel();
    _purchaseHandler?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    await _loadReceptors();
    if (mounted) {
      setState(() {
        _loadState = 1;
      });
    }
    await _loadMoney();
    if (mounted) {
      setState(() {
        _loadState = -1;
      });
    }
  }

  Future<void> _loadMoney() async {
    var result = await AmapLocation.fetchLocation();
    _districtCode = await result.adCode;
    if (StringUtil.isEmpty(_districtCode)) {
      return;
    }
    var latlng = await result.latLng;
//    var city = await result.city;
    String title = await result.poiName;
    String address = await result.address;
    var poiId = await result.adCode;
    _poi = AmapPoi(
      title: title,
      latLng: latlng,
      address: address,
      poiId: poiId,
    );
    var purchaseInfo = await _getPurchaseInfo();
    if (purchaseInfo.bankInfo == null) {
      return;
    }
    _purchaseInfo = purchaseInfo;
    if (purchaseInfo.myWallet.trial >= 100) {
      _purchase_method = 1;
      _label = '体验金  ¥${(_purchse_amount / 100.00).toStringAsFixed(2)}元';
      _canPublish = true;
      return;
    }
    _purchase_method = 0;
    if (purchaseInfo.myWallet.change < _purchse_amount) {
      _isEnoughMoney = false;
      var balance =
          '¥${(purchaseInfo.myWallet.change / 100.00).toStringAsFixed(2)}元';
      var least = '¥${(_purchse_amount / 100.00).toStringAsFixed(2)}元';
      _label = '余额:$balance，至少:$least，请到钱包中充值';
      return;
    }
    _label = '零钱  ¥${(_purchse_amount / 100.00).toStringAsFixed(2)}元';
    _canPublish = true;
  }

  Future<void> _loadReceptors() async {
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    var receptors = await receptorService.page(_limit, _offset);
    if (receptors.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += receptors.length;
    _receptors.addAll(receptors);
    if (mounted) {
      setState(() {});
    }
  }

  bool _isEnabledButton() {
    return _selector != null &&
        _canPublish &&
        !StringUtil.isEmpty(_commentController.text) &&
        (_purchaseInfo.myWallet.change >= _purchse_amount &&
            _publishingState < 1) &&
        !StringUtil.isEmpty(_districtCode);
  }

  Future<void> _publish() async {
    await receptorOpener.open(widget.context, _selector.id, (receptor) async {
      //发布消息
      await _publishMessage(receptor);
      return false;
    });
  }

  Future<void> _publishMessage(GeoReceptor receptor) async {
    UserPrincipal user = widget.context.principal;
    var content = _commentController.text;
    var msgid = MD5Util.MD5('${Uuid().v1()}');

    if (mounted) {
      setState(() {
        _publishingState = 1;
      });
    }
    var purchaseOR = await _purchaseImpl(receptor, user, msgid);
    IWyBankPurchaserRemote purchaserRemote =
        widget.context.site.getService('/remote/purchaser');
    _purchaseHandler = Stream.periodic(Duration(seconds: 1), (count) async {
      var record = await purchaserRemote.getPurchaseRecord(purchaseOR.sn);
      return record;
    }).listen((event) async {
      var result = await event;
      if (result == null) {
        return;
      }
      if (result.state != 1) {
        print('申购中...');
        return;
      }
      _purchaseHandler?.cancel();
      if (result.status != 200) {
        _purchaseError = '${result.status} ${result.message}';
        print('申购完成【${result.status} ${result.message}】，但出错');
        _publishingState = 3;
        setState(() {});
        return;
      }
      print('成功申购');
      _publishingState = 2;
      if (mounted) {
        setState(() {});
      }
      await _publishImpl(receptor, user, content, msgid, result);
      _publishingState = 0;
      if (mounted) {
        setState(() {});
      }
      print('发布完成');
      var url;
      if (receptor.creator == widget.context.principal.person) {
        //每人只能有一个手机行人地圈
        if (receptor.category == 'mobiles') {
          url = '/geosphere/receptor.lord';
        } else {
          url = '/geosphere/receptor.mines';
        }
      } else {
        url = '/geosphere/receptor.fans';
      }
      await widget.context.forward(url, arguments: {
        'receptor': ReceptorInfo.create(receptor),
      });
      await _forwardDialog();
    });
  }

  Future<PurchaseOR> _purchaseImpl(GeoReceptor receptor, user, msgid) async {
    IWyBankPurchaserRemote purchaserRemote =
        widget.context.site.getService('/remote/purchaser');
    var purchaseOR = await purchaserRemote.doPurchase(
        _purchaseInfo.bankInfo.id,
        _purchse_amount,
        _purchase_method,
        'receptor',
        'geo.receptor/$msgid',
        '在地理感知器${receptor.title}');
    return purchaseOR;
  }

  Future<void> _publishImpl(
      GeoReceptor receptor, user, content, msgid, purchaseOR) async {
    var content = _commentController.text;
    var location = jsonEncode(_poi.latLng.toJson());

    IGeosphereMessageService geoMessageService =
        widget.context.site.getService('/geosphere/receptor/messages');
    IGeosphereMediaService mediaService =
        widget.context.site.getService('/geosphere/receptor/messages/medias');

    await geoMessageService.addMessage(
      GeosphereMessageOL(
        msgid,
        null,
        null,
        null,
        null,
        null,
        null,
        receptor.id,
        user.person,
        DateTime.now().millisecondsSinceEpoch,
        null,
        null,
        null,
        'sended',
        content,
        purchaseOR.sn,
        location,
        receptor.channel,
        receptor.category,
        receptor.brand,
        widget.context.principal.person,
      ),
    );
    var media = GeosphereMediaOL(
      MD5Util.MD5(Uuid().v1()),
      'share',
      _href,
      _leading,
      msgid,
      _title,
      receptor.id,
      widget.context.principal.person,
    );
    await mediaService.addMediaNotPush(media);
  }

  Future<void> _buywy() async {
    if (!_isEnoughMoney) {
      if (_rechargeController == null) {
        _rechargeController = StreamController();
        _rechargeHandler = _rechargeController.stream.listen((event) async {
          // print('---充值返回---$event');
          _purchaseInfo = await _getPurchaseInfo();
          if (_purchaseInfo.bankInfo == null) {
            return;
          }
          if (_purchaseInfo.myWallet.change >= _purchse_amount) {
            _isEnoughMoney = true;
            _canPublish = true;
            _label = '¥${(_purchse_amount / 100.00).toStringAsFixed(2)}元';
            if (mounted) {
              setState(() {});
            }
            return;
          }
          var balance =
              '¥${(_purchaseInfo.myWallet.change / 100.00).toStringAsFixed(2)}元';
          var least = '¥${(_purchse_amount / 100.00).toStringAsFixed(2)}元';
          _label = '余额:$balance，至少:$least，请到钱包中充值';
        });
      }
      widget.context.forward('/wallet/change/deposit',
          arguments: {'changeController': _rechargeController});
      return;
    }
    widget.context.forward('/channel/article/buywy', arguments: {
      'purchaseInfo': _purchaseInfo,
      'purchaseAmount': _purchse_amount,
      'purchaseMethod': _purchase_method,
    }).then((value) async {
      if (value == null) {
        return;
      }
      if (mounted) {
        setState(() {
          _label = '正在检查申购服务，请稍候...';
        });
      }
      var purchaseInfo = await _getPurchaseInfo();
      if (purchaseInfo.bankInfo == null) {
        return;
      }
      var result = value as Map;
      var amount = result['amount'];
      var method = result['method'];
      if (method == 0 && purchaseInfo.myWallet.change < amount) {
        _isEnoughMoney = false;
        var v = amount;
        var labelV = '¥${(v / 100.00).toStringAsFixed(2)}';
        _label =
            '欲购金额:$labelV元 大于 现有零钱余额：¥${(purchaseInfo.myWallet.change / 100.00).toStringAsFixed(2)}元，请充值';
        if (mounted) {
          setState(() {});
        }
        return;
      }
      if (method == 1 && purchaseInfo.myWallet.trial < amount) {
        _isEnoughMoney = false;
        var v = amount;
        var labelV = '¥${(v / 100.00).toStringAsFixed(2)}';
        _label =
            '欲购金额:$labelV元 大于 现有体验金余额：¥${(purchaseInfo.myWallet.change / 100.00).toStringAsFixed(2)}元，请充值';
        if (mounted) {
          setState(() {});
        }
        return;
      }
      _purchase_method = method;
      _purchse_amount = amount;
      _label =
          '${method == 0 ? '零钱' : '体验金'}  ¥${(_purchse_amount / 100.00).toStringAsFixed(2)}';
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<PurchaseInfo> _getPurchaseInfo() async {
    IWyBankPurchaserRemote purchaserRemote =
        widget.context.site.getService('/remote/purchaser');
    var purchaseInfo = await purchaserRemote.getPurchaseInfo(_districtCode);
    return purchaseInfo;
  }

  Future<void> _forwardDialog() async {
    await showDialog(
      context: context,
      child: AlertDialog(
        title: Text('选择'),
        elevation: 0,
        actions: [
          FlatButton(
            onPressed: () {
              widget.context.forward(
                '/',
                clearHistoryByPagePath: '.',
              );
            },
            child: Text(
              '留在地微',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          FlatButton(
            onPressed: () async {
              await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
            child: Text(
              '返回',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('地圈发布'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () async {
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
        actions: [
          InkWell(
            onTap: !_isEnabledButton()
                ? null
                : () {
                    _publish();
                  },
            child: Container(
              color: !_isEnabledButton() ? Colors.grey[500] : Colors.green,
              margin: EdgeInsets.only(
                right: 15,
                top: 12,
                bottom: 12,
              ),
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              alignment: Alignment.center,
              child: Text(
                '发布',
                style: TextStyle(
                  color: !_isEnabledButton() ? Colors.white70 : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            renderShareEditor(
                context: widget.context,
                title: _title,
                href: _href,
                leading: _leading,
                summary: _summary,
                controller: _commentController,
                onChanged: (v) {
                  setState(() {});
                }),
            SizedBox(
              height: 10,
            ),
            ..._renderProcessing(),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        InkWell(
                          onTap: StringUtil.isEmpty(_districtCode)
                              ? null
                              : () {
                                  _buywy();
                                },
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 15,
                              bottom: 15,
                              left: 10,
                              right: 10,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                    right: 10,
                                  ),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Icon(
                                      Icons.spellcheck,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Text(
                                  '购买该服务',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${_loadState > -1 ? '正在搜寻当地的服务商...' : (StringUtil.isEmpty(_districtCode) ? '没找到当地服务商，因此无法提供发布服务' : _label)}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          height: 1,
                          indent: 15,
                        ),
                        InkWell(
                          onTap: () {
                            widget.context.forward('/geosphere/amap/near',
                                arguments: {'poi': _poi}).then((result) {
                              if (result == null) {
                                return;
                              }
                              _poi = (result as Map)['poi'];
                              setState(() {});
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 15,
                              bottom: 15,
                              left: 10,
                              right: 10,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                    right: 10,
                                  ),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Text(
                                  '所在位置',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${_poi == null ? '定位中...' : '${_poi.title}附近'}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '分享给',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Wrap(
                            runSpacing: 10,
                            spacing: 10,
                            children: _renderSelected(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                '地圈',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: EasyRefresh(
                                controller: _controller,
                                onLoad: _loadReceptors,
                                child: ListView(
                                  children: _renderReceptors(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getLeading(GeoReceptor receptor) {
    Widget imgSrc = null;
    if (StringUtil.isEmpty(receptor.leading)) {
      imgSrc = Icon(
        IconData(
          0xe604,
          fontFamily: 'netflow2',
        ),
        size: 32,
        color: Colors.grey[500],
      );
    } else if (receptor.leading.startsWith('/')) {
      //本地存储
      imgSrc = Image.file(
        File(receptor.leading),
        width: 40,
        height: 40,
      );
    } else {
      imgSrc = FadeInImage.assetNetwork(
        placeholder: 'lib/portals/gbera/images/default_watting.gif',
        image:
            '${receptor.leading}?accessToken=${widget.context.principal.accessToken}',
        width: 40,
        height: 40,
      );
    }
    return imgSrc;
  }

  List<Widget> _renderReceptors() {
    var items = <Widget>[];
    if (_loadState == 0) {
      items.add(
        Container(
          height: 60,
          alignment: Alignment.center,
          child: Text('正在加载...'),
        ),
      );
      return items;
    }
    if (_receptors.isEmpty) {
      items.add(
        Container(
          height: 60,
          alignment: Alignment.center,
          child: Text('没有地理感知器'),
        ),
      );
      return items;
    }
    for (var receptor in _receptors) {
      items.add(InkWell(
        onTap: () {
          _selector = receptor;
          if (mounted) {
            setState(() {});
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            top: 15,
            bottom: 15,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: _getLeading(receptor),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${receptor.title}',
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              (_selector != null && _selector.id == receptor.id)
                  ? Icon(
                      Icons.check,
                      color: Colors.grey,
                      size: 18,
                    )
                  : SizedBox(
                      width: 0,
                      height: 0,
                    ),
            ],
          ),
        ),
      ));
      items.add(
        Divider(
          height: 1,
          indent: 40,
        ),
      );
    }
    return items;
  }

  List<Widget> _renderSelected() {
    var items = <Widget>[];
    if (_selector != null) {
      items.add(
        Column(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: _getLeading(_selector),
              ),
            ),
            SizedBox(
              height: 2,
            ),
            Container(
              width: 60,
              alignment: Alignment.center,
              child: Text(
                '${_selector.title}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[800],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
    return items;
  }

  List<Widget> _renderProcessing() {
    var items = <Widget>[];

    if (_publishingState > 0) {
      var tips = '';
      switch (_publishingState) {
        case 1:
          tips = '正在申购发文服务..';
          break;
        case 2:
          tips = '申购完成，正在发表';
          break;
        case 3:
          tips = _purchaseError;
          break;
        case 4:
          tips = '成功发表';
          break;
      }
      items.add(
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            bottom: 10,
            top: 10,
            left: 15,
            right: 15,
          ),
          child: Text(
            '$tips',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
        ),
      );
      items.add(
        SizedBox(
          height: 10,
        ),
      );
    }
    return items;
  }
}
