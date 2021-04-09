import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/parts/timeline_listview.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';
import 'package:netos_app/portals/gbera/store/remotes/market.dart';
import 'dart:math';
import 'package:tobias/tobias.dart' as tobias;
import 'package:netos_app/portals/gbera/store/remotes/market_material.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class Market extends StatefulWidget {
  final PageContext context;

  Market({this.context});

  @override
  _MarketState createState() => _MarketState();
}

class _MarketState extends State<Market> with AutomaticKeepAliveClientMixin {
  EasyRefreshController _controller;
  bool _showSearch = true;
  EcSourceOR _currentSource;
  EcSiteOR _currentSite;
  List<EcSiteOR> _currentSites = [];
  List<EcChannelOR> _currentChannels = [];
  EcChannelOR _selectedChannel;
  List<Map<String, Object>> _materials = [];
  CustomPopupMenuController _channelMenuController =
      CustomPopupMenuController();
  int _limit = 20, _offset = 0;
  List<EcSourceOR> _sources = [];
  bool _isDataLoading = true;
  bool _isHeadLoading = true;
  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  String _query;
  PersonCardOR _personCardOR;

  @override
  bool get wantKeepAlive {
    return true;
  }

  @override
  void initState() {
    _controller = EasyRefreshController();
    _focusNode.addListener(_focusListner);
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _searchController?.dispose();
    _channelMenuController?.dispose();
    _controller.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  Future<void> _focusListner() async {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      var result = await showSearch(
        context: context,
        delegate: _SearchBarDelegate(sites: _currentSites),
      );
      if (result == null || result == '') {
        return;
      }
      _query = null;
      var map = result as Map;
      switch (map['action']) {
        case 'onsite':
          await _loadSite(map['query'] as EcSiteOR);
          if (mounted) {
            setState(() {});
          }
          break;
        case 'onquery':
          _query = map['query'];
          await _searchMaterial();
          if (mounted) {
            setState(() {});
          }
          break;
      }
    }
  }

  Future<void> _load() async {
    await _loadMarket();
    if (mounted) {
      setState(() {
        _isHeadLoading = false;
      });
    }
    await _onload();
    await _checkFissionMFTask();
    if (mounted) {
      setState(() {
        _isDataLoading = false;
      });
    }
  }

  Future<void> _checkFissionMFTask() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    var isTask = await cashierRemote.isTask("goShop");
    if (!isTask) {
      return;
    }
    await cashierRemote.doneTask();
    await showDialog(
      context: context,
      child: AlertDialog(
        title: Text(
          '裂变游戏·交个朋友',
        ),
        content: Text('任务处理完毕，请去微信继续抢红包！'),
        actions: [
          FlatButton(
            onPressed: () {
              widget.context.backward();
            },
            child: Text(
              '好',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchMaterial() async {
    _materials.clear();
    _offset = 0;
    await _onload();
  }

  Future<void> _loadSite(EcSiteOR site) async {
    IMarketRemote marketRemote = widget.context.site.getService('/market');
    _currentSite = site;
    var channels =
        await marketRemote.listChannel(_currentSource.id, _currentSite.id);
    _currentChannels.clear();
    _currentChannels.addAll(channels);
    _selectedChannel = channels.first;
    _materials.clear();
    _offset = 0;
    await _onload();
  }

  Future<void> _loadMarket() async {
    IMarketRemote marketRemote = widget.context.site.getService('/market');
    var sources = await marketRemote.listSource();
    _sources.addAll(sources);
    _currentSource = _sources.first;
    await _loadSource();
  }

  Future<void> _loadSource() async {
    IPayChannelRemote payChannelRemote =
        widget.context.site.getService('/wallet/payChannels');
    _personCardOR = await payChannelRemote.getPersonCard('alipay');
    if (_personCardOR == null) {
      //唤起提现方的支付宝，并获取auth_code,然后向后台传入auth_code创建公众卡，并返回
      var text =
          'apiname=com.alipay.account.auth&app_id=2021001198622080&app_name=m&auth_type=AUTHACCOUNT&biz_type=openservice&method=alipay.open.auth.sdk.code.get&pid=2088831336090722&product_id=APP_FAST_LOGIN&scope=kuaijie&target_id=2014122542424';
      var map = await tobias.aliPayAuth(text);
      // print('----$map');
      var status = map['resultStatus'];
      if (status != '9000') {
        //出错
        return null;
      }
      var result = map['result'];
      var params = parseUrlParams(result);
      var authCode = params['auth_code'];
      // var userId = params['user_id'];
      _personCardOR = await payChannelRemote.createPersonCardByAuthCode(
        'alipay',
        authCode,
      );
    }

    IMarketRemote marketRemote = widget.context.site.getService('/market');
    var sites = await marketRemote.listSite(_currentSource.id);
    _currentSite = sites.first;
    _currentSites.addAll(sites);
    var channels =
        await marketRemote.listChannel(_currentSource.id, _currentSite.id);
    _currentChannels.addAll(channels);
    _selectedChannel = channels.first;
  }

  Future<void> _onload() async {
    IMarketMaterialRemote marketMaterialRemote =
        widget.context.site.getService('/market/material');
    dynamic materials;
    if (!StringUtil.isEmpty(_query)) {
      materials = await marketMaterialRemote.searchMaterial(
          _query, int.parse(_selectedChannel.code), _limit, _offset);
    } else {
      materials = await marketMaterialRemote.pageMaterial(
          int.parse(_selectedChannel.code ?? "0"), _limit, _offset);
    }
    if (materials.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      setState(() {});
      return;
    }
    _offset += materials.length;
    _materials.addAll(materials);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _createTaoBaoPWD(material) async {
    IMarketMaterialRemote marketMaterialRemote =
        widget.context.site.getService('/market/material');
    String logo = material['pict_url'];
    if (!logo.startsWith('http')) {
      logo = 'https:$logo';
    }
    String url = material['coupon_share_url']; //coupon_click_url，click_url
    if (StringUtil.isEmpty(url)) {
      //没有券地址则直接进入商品
      url = material['click_url'];
    }
    if (!url.startsWith('http')) {
      url = 'https:$url';
    }
    var obj = await marketMaterialRemote.createTaoPWD(
        _personCardOR.cardHolder, material['title'], url, logo);
    var model = obj['model'];
    await Clipboard.setData(ClipboardData(text: '${model ?? ''}'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: NestedScrollView(
        headerSliverBuilder: (ctx, innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
            // SliverToBoxAdapter(
            //   child: _renderBonus(),
            // ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
            SliverPersistentHeader(
              pinned: true, //是否固定在顶部
              floating: true,
              delegate: _SliverAppBarDelegate(
                minHeight: _showSearch ? 120 : 80, //收起的高度
                maxHeight: _showSearch ? 120 : 80,
                child: _renderNav(),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
          ];
        },
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 10,
                right: 15,
              ),
              child: Row(
                children: [
                  StringUtil.isEmpty(_query)
                      ? Text(
                          '${_currentSite?.title ?? ''}:${_selectedChannel?.title ?? ''}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        )
                      : Text(
                          '搜索:$_query',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: EasyRefresh(
                controller: _controller,
                onLoad: _onload,
                child: ListView(
                  children: _renderItems(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderBonus() {
    return Container(
      padding: EdgeInsets.only(
        left: 45,
        right: 15,
        top: 10,
        bottom: 10,
      ),
      child: Row(
        children: [
          Icon(
            IconData(0xe71c, fontFamily: 'market_icon'),
            color: Color(0xFFFF6347),
            size: 50,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: '',
                    children: [
                      TextSpan(
                        text: '当前补贴',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: '¥',
                        style: TextStyle(),
                      ),
                      TextSpan(
                        text: '6',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                      TextSpan(
                        text: '.00',
                        style: TextStyle(),
                      ),
                      TextSpan(
                        text: '元',
                        style: TextStyle(),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text.rich(
                  TextSpan(
                    text: '',
                    children: [
                      TextSpan(
                        text: '补贴速度',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: '2',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: '.30',
                        style: TextStyle(),
                      ),
                      TextSpan(
                        text: '元/小时',
                        style: TextStyle(),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderNav() {
    var menu = <Widget>[];

    for (var item in _currentChannels) {
      menu.add(
        InkWell(
          onTap: () {
            _selectedChannel = item;
            _materials.clear();
            _offset = 0;
            _query = null;
            _onload();
          },
          child: Padding(
            padding: EdgeInsets.only(
              right: 20,
            ),
            child: Text(
              '${item.title}',
              style: TextStyle(
                fontSize: 14,
                color: item.id == _selectedChannel.id
                    ? Color(0xFFFF4500)
                    : Colors.black,
                fontWeight: FontWeight.w600,
                decoration: item.id == _selectedChannel.id
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
        ),
      );
    }
    var searchRegion = <Widget>[];
    if (_showSearch) {
      searchRegion.addAll(
        [
          SizedBox(
            height: 10,
          ),
          Container(
            margin: EdgeInsets.only(
              left: 30,
              right: 5,
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText:
                    '${!StringUtil.isEmpty(_query) ? '搜索:$_query' : '找宝贝...'}',
                hintStyle: TextStyle(
                  fontSize: 14,
                ),
                fillColor: Colors.white,
                filled: true,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 5,
                  bottom: 5,
                ),
                // prefix: Padding(
                //   padding: EdgeInsets.only(right: 5),
                //   child: Icon(
                //     Icons.search,
                //     size: 14,
                //   ),
                // ),
                suffix: InkWell(
                  onTap: () {
                    _searchController?.clear();
                    _focusNode.unfocus();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Icon(
                      Icons.clear,
                      size: 14,
                    ),
                  ),
                ),
              ),
              maxLines: 1,
              onChanged: (v) {},
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    IconData(0xe695, fontFamily: 'market_icon'),
                    color: Color(0xFFFF8C00),
                    size: 30,
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Text(
                    '${_currentSource?.title ?? ''}',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  children: _renderSource(),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _showSearch = !_showSearch;
                  });
                },
                child: Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          ...searchRegion,
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: menu,
                    ),
                  ),
                ),
              ),
              CustomPopupMenu(
                controller: _channelMenuController,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 5,
                  ),
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                  ),
                ),
                onHideMenu: () {
                  // print('------1');
                },
                menuBuilder: () {
                  return Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      // color: Color(0xFFFF4500),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(2, 2),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            '${_currentSite.title}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                          child: Divider(
                            height: 1,
                          ),
                        ),
                        Wrap(
                          direction: Axis.horizontal,
                          spacing: 5,
                          runSpacing: 10,
                          children: _currentChannels.map((e) {
                            return InkWell(
                              onTap: () {
                                _channelMenuController.hideMenu();
                                _selectedChannel = e;
                                _materials.clear();
                                _offset = 0;
                                _onload();
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: 10,
                                  left: 10,
                                ),
                                child: Text(
                                  '${e.title}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    // fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
                arrowSize: 14,
                // arrowColor: Color(0xFFFF4500),
                arrowColor: Colors.grey[300],
                barrierColor: Colors.transparent,
                pressType: PressType.singleClick,
              ),
            ],
          ),
          // SizedBox(
          //   height: 10,
          //   child: Divider(
          //     height: 1,
          //     indent: 30,
          //     color: Color(0xFFFF4500),
          //   ),
          // ),
        ],
      ),
    );
  }

  List<Widget> _renderItems() {
    var items = <Widget>[];
    if (_isDataLoading) {
      items.add(
        Container(
          padding: EdgeInsets.only(
            top: 40,
          ),
          alignment: Alignment.center,
          child: Text(
            '正在加载...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      );
      return items;
    }
    for (var material in _materials) {
      items.add(
        Stack(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              var medias = <MediaSrc>[
                                MediaSrc(
                                    id: '${Uuid().v1()}',
                                    text: '',
                                    src:
                                        '${(material['pict_url'] as String).startsWith('https') ? material['pict_url'] : 'https:${material['pict_url']}'}',
                                    type: 'image'),
                              ];
                              var images = material['small_images'] as Map;
                              var imageStrings = images['string'];
                              for (var src in imageStrings) {
                                medias.add(
                                  MediaSrc(
                                    id: '${Uuid().v1()}',
                                    text: '',
                                    src: 'https:$src',
                                    type: 'image',
                                  ),
                                );
                              }
                              widget.context.forward(
                                '/images/viewer/external',
                                arguments: {
                                  'medias': medias,
                                  'index': 0,
                                },
                              );
                            },
                            child: FadeInImage.assetNetwork(
                              placeholder:
                                  'lib/portals/gbera/images/default_watting.gif',
                              image:
                                  '${(material['pict_url'] as String).startsWith('https') ? material['pict_url'] : 'https:${material['pict_url']}'}',
                              width: 150,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          StringUtil.isEmpty(material['nick'])
                              ? SizedBox.shrink()
                              : SizedBox(
                                  height: 5,
                                ),
                          StringUtil.isEmpty(material['nick'])
                              ? SizedBox.shrink()
                              : Container(
                                  child: Text(
                                    '${material['nick'] ?? ''}',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Color(0xFFFF4500),
                              ),
                            ),
                            padding: EdgeInsets.only(
                              left: 2,
                              right: 2,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '已售',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFFF4500),
                                  ),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  '${(material['volume'] as double).toStringAsFixed(0)}件',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFFF4500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              children: [
                                Container(
                                  child: Text(
                                    '${_renderType(material['user_type'] as double)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Color(0xFFB22222),
                                  ),
                                  padding: EdgeInsets.only(
                                    left: 3,
                                    right: 3,
                                  ),
                                ),
                                Text(
                                  '${material['title']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: EdgeInsets.only(
                                        left: 4,
                                        right: 4,
                                      ),
                                      margin: EdgeInsets.only(
                                        left: 20,
                                      ),
                                      child: Text(
                                        '原价',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      '¥${(double.parse(material['zk_final_price'])).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                rendTimelineListRow(
                                  title: Row(
                                    children: [
                                      Text(
                                        '券',
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        '余${(material['coupon_remain_count'] as double).toStringAsFixed(0)}张',
                                        style: TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    '- ${(double.parse('${material['coupon_amount'] ?? '0.00'}')).toStringAsFixed(2)}元',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                // rendTimelineListRow(
                                //   title: Text(
                                //     '补',
                                //     style: TextStyle(
                                //       fontSize: 12,
                                //     ),
                                //   ),
                                //   content: Text(
                                //     '6.00元',
                                //     style: TextStyle(
                                //       fontSize: 12,
                                //     ),
                                //   ),
                                // ),
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFF6347),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: EdgeInsets.only(
                                        left: 4,
                                        right: 4,
                                      ),
                                      margin: EdgeInsets.only(
                                        left: 18,
                                      ),
                                      child: Text(
                                        '现价',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        text: '¥',
                                        children: [
                                          TextSpan(
                                            text:
                                                '${(double.parse(material['zk_final_price']) - double.parse('${material['coupon_amount'] ?? '0.00'}')).truncate()}',
                                            style: TextStyle(
                                              fontSize: 25,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '.${formatNum2(double.parse(material['zk_final_price']) - double.parse('${material['coupon_amount'] ?? '0.00'}'))}',
                                            style: TextStyle(),
                                          ),
                                        ],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              bottom: 10,
              child: InkWell(
                onTap: () async {
                  var url = 'taobao://taobao.com';
                  if (!(await canLaunch(url))) {
                    await showDialog(
                      context: context,
                      child: AlertDialog(
                        title: Text('提示'),
                        elevation: 0,
                        content: Container(
                          padding: EdgeInsets.only(left: 10,right: 10,),
                          child: Text(
                            '没有安装淘宝app，请到应用商店下载',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
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
                    return;
                  }
                  //生成淘口令并拷贝到粘贴版
                  await _createTaoBaoPWD(material);
                  await launch(
                    url,
                    forceWebView: false,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6347),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300],
                        blurRadius: 3,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(
                    left: 20,
                    top: 5,
                    bottom: 5,
                    right: 20,
                  ),
                  child: Text(
                    '去买',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
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
    }
    return items;
  }

  _renderSource() {
    var items = <Widget>[];
    if (_isDataLoading) {
      return items;
    }
    for (var source in _sources) {
      if (source.id == _currentSource.id) {
        continue;
      }
      items.addAll(
        [
          InkWell(
            onTap: () async {
              _currentSource = source;
              await _loadSource();
              if (mounted) {
                setState(() {});
              }
            },
            child: Text(
              '${source.title}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      );
    }
    return items;
  }

  _renderType(double material) {
    switch (material.floor()) {
      case 0:
        return '淘宝';
      case 1:
        return '天猫';
      case 2:
        return '特价版';
      default:
        return '';
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: shrinkOffset == maxHeight - minHeight
                ? 0.0
                : ((shrinkOffset) * 0.5).clamp(0.0, 1.0), //根据滑动高度隐藏显示
            child: Container(
              constraints: BoxConstraints.expand(),
              color: Theme.of(context).backgroundColor,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            right: 0,
            child: child,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    var should = maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
    return should;
  }
}

class _LinearContainer extends StatefulWidget {
  Widget child;

  _LinearContainer({this.child});

  @override
  __LinearContainerState createState() => __LinearContainerState();
}

class __LinearContainerState extends State<_LinearContainer> {
  @override
  void didUpdateWidget(covariant _LinearContainer oldWidget) {
    if (oldWidget.child != widget.child) {
      widget.child = oldWidget.child;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}

class _SearchBarDelegate extends SearchDelegate<dynamic> {
  List<EcSiteOR> sites = [];

  // 搜索条右侧的按钮执行方法，我们在这里方法里放入一个clear图标。 当点击图片时，清空搜索的内容。
  _SearchBarDelegate({this.sites})
      : super(
          searchFieldLabel: '找宝贝',
        );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          // 清空搜索内容
          query = "";
        },
      )
    ];
  }

  // 搜索栏左侧的图标和功能，点击时关闭整个搜索页面
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, "");
      },
    );
  }

  // 搜索到内容了
  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      close(context, {'action': 'onquery', 'query': query});
    });
    return Container();
  }

  // 输入时的推荐及搜索结果
  @override
  Widget buildSuggestions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StringUtil.isEmpty(query)
            ? SizedBox.shrink()
            : InkWell(
                onTap: () {
                  close(context, {'action': 'onquery', 'query': query});
                },
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: 5,
                          bottom: 5,
                          left: 10,
                          right: 10,
                        ),
                        child: Text(
                          '搜索:',
                          style: TextStyle(),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '$query',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 10,
            bottom: 2,
          ),
          child: Text(
            '推荐',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 10,
            ),
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Wrap(
              runSpacing: 10,
              spacing: 15,
              children: sites.map((e) {
                return InkWell(
                  onTap: () {
                    close(context, {'action': 'onsite', 'query': e});
                  },
                  child: Text(
                    '${e.title}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
