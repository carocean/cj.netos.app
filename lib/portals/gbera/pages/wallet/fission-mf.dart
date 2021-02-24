import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:city_pickers/meta/_province.dart';
import 'package:city_pickers/meta/province.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_bill.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_record.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:intl/intl.dart' as intl;

class FissionMFCashierPage extends StatefulWidget {
  PageContext context;

  FissionMFCashierPage({this.context});

  @override
  _FissionMFCashierPageState createState() => _FissionMFCashierPageState();
}

class _FissionMFCashierPageState extends State<FissionMFCashierPage> {
  bool _isOpening = false;
  MyWallet _myWallet;
  bool _isRecharging = false, _isWithdrawing = false;
  CashierOR _cashierOR;
  int _assessCacCount = 0;
  int _totalPayeeOnDay = 0, _totalPayerOnDay = 0;
  int _totalPayeeAll = 0, _totalPayerAll = 0;
  int _totalProfitOnDay = 0;
  int _totalPayAmountOnDay = 0;
  bool _isLoading = true;
  List<FissionMFPerson> _payees = [];
  List<FissionMFPerson> _payers = [];
  List<FissionMFTagOR> _tags = [];

  @override
  void initState() {
    _myWallet = widget.context.parameters['wallet'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    IFissionMFCashierBillRemote cashierBillRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier/bill');
    IFissionMFCashierRecordRemote cashierRecordRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier/record');
    _updateLocation(cashierRemote); //异步更新
    _cashierOR = await cashierRemote.getCashier();
    _isOpening = _cashierOR.state == 0;
    _assessCacCount = await cashierRemote.assessCacCount();
    var time = DateTime.now();
    var timeStr = intl.DateFormat('yyyyMMdd').format(time);
    _totalPayeeOnDay = await cashierRecordRemote.totalPayeeOfDay(timeStr);
    _totalPayerOnDay = await cashierRecordRemote.totalPayerOnDay(timeStr);
    _totalPayeeAll = await cashierRecordRemote.totalPayee();
    _totalPayerAll = await cashierRecordRemote.totalPayer();
    var payees = await cashierRecordRemote.pagePayeeInfo(5, 0);
    _payees.addAll(payees);
    var payers = await cashierRecordRemote.pagePayerInfo(5, 0);
    _payers.addAll(payers);
    _totalProfitOnDay = await cashierBillRemote.totalBillOfDayByOrder(
        3, time.year, time.month, time.day);
    _totalPayAmountOnDay = await cashierBillRemote.totalBillOfDayByOrder(
        2, time.year, time.month, time.day);
    var tags = await cashierRemote.listMyPropertyTag();
    if (tags.isNotEmpty) {
      _tags.addAll(tags);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        showDialog(
          context: context,
          child: Scaffold(
            body: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 10,
                    top: 30,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '请先设置您的兴趣标签再说使用，兴趣标签不仅可以给你精准引荐朋友，还可将你推荐给志同道合的人',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: widget.context.part(
                    '/wallet/fission/mf/tag/properties',
                    context,
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateLocation(IFissionMFCashierRemote cashierRemote) async {
    var location = await geoLocation.location;
    var latLng = location.latLng;
    var recode =
        await AmapSearch.instance.searchReGeocode(latLng, radius: 200.0);
    var towncode = recode.townCode;
    var adcode = recode.adCode;
    var province = findProvinceCode(recode.provinceName);
    var city = findCityCode(province, recode.cityName);
    await cashierRemote.updateLocation(
      latLng,
      city: recode.cityName,
      district: recode.districtName,
      province: recode.provinceName,
      town: recode.township,
      cityCode: city,
      districtCode: adcode,
      provinceCode: province,
      townCode: towncode,
    );
  }

  Future<void> _withdraw() async {
    if (mounted) {
      setState(() {
        _isWithdrawing = true;
      });
    }
    var result = await showDialog(
      context: context,
      child: _WithdrawPopupWidget(context: widget.context, wallet: _myWallet),
    );
    if (result == null) {
      return;
    }
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    var amount = result as int;
    await cashierRemote.withdraw(amount);
    Future.delayed(
        Duration(
          seconds: 1,
        ), () async {
      var balance = await cashierRemote.getCashierBalance();
      _myWallet.fissionMf = balance.balance;
      _myWallet.change += amount;
      _assessCacCount = await cashierRemote.assessCacCount();
      if (mounted) {
        setState(() {
          _isWithdrawing = false;
        });
      }
    });
  }

  Future<void> _recharge(int amount) async {
    if (mounted) {
      setState(() {
        _isRecharging = true;
      });
    }
    IFissionMFCashierRemote cashier =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    await cashier.recharge(amount);

    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    Future.delayed(
        Duration(
          seconds: 1,
        ), () async {
      var balance = await cashierRemote.getCashierBalance();
      _myWallet.fissionMf = balance.balance;
      _myWallet.change -= amount;
      _assessCacCount = await cashierRemote.assessCacCount();
      if (mounted) {
        setState(() {
          _isRecharging = false;
        });
      }
    });
  }

  Future<void> _updateState() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    if (_isOpening) {
      await cashierRemote.startCashier();
    } else {
      await cashierRemote.stopCashier('主动停止营业');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('交个朋友'),
        elevation: 0,
        titleSpacing: 0,
        actions: [
          FlatButton(
            onPressed: () {
              widget.context.forward('/wallet/fission/mf/bill');
            },
            child: Text(
              '收益及明细',
            ),
          ),
        ],
      ),
      body: _rendBody(),
    );
  }

  Widget _rendBody() {
    if (_isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              '加载中...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
            ),
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              '今日收入',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              '¥${(_totalProfitOnDay / 100.00).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              '今日支出',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              '¥${(_totalPayAmountOnDay / 100.00).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              '今日进群',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              '$_totalPayeeOnDay人',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              '今日加群',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              '$_totalPayerOnDay个',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Column(
            children: [
              Text(
                '红包余额',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text.rich(
                TextSpan(
                  text: '¥',
                  children: [
                    TextSpan(
                      text: '${_myWallet.fissionMFYan ?? '0.00'}',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '营业状态：${_isOpening ? '营业中' : '已停业'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                onPressed: _isRecharging
                    ? null
                    : () async {
                        var v = await widget.context.forward(
                            '/wallet/fission/mf/recharge',
                            arguments: {'wallet': _myWallet});
                        if (v == null) {
                          return;
                        }
                        var args = v as Map;
                        var amount = args['amount'];
                        _recharge(amount as int);
                      },
                child: Text(
                  '${_isRecharging ? '处理中...' : '充钱到红包'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                color: Colors.green,
                textColor: Colors.white,
              ),
              RaisedButton(
                onPressed: _isWithdrawing
                    ? null
                    : () {
                        _withdraw();
                      },
                child: Text(
                  '${_isWithdrawing ? '处理中...' : '提取到零钱'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                color: Colors.green,
                textColor: Colors.white,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            children: [
              Container(
                color: Colors.white,
                constraints: BoxConstraints.tightForFinite(
                  width: double.maxFinite,
                ),
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '营业状态',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '营业中状态表示系统会将你推荐给其他用户，用户通过点你头像，从而会消耗你的红包余额；停止营业则不会扣费，系统也不会向其他用户推荐你',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          '${_isOpening ? '营业中' : '已停业'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        Switch.adaptive(
                          value: _isOpening,
                          onChanged: (v) {
                            setState(() {
                              _isOpening = v;
                            });
                            _updateState();
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    !_isOpening
                        ? SizedBox(
                            width: 0,
                            height: 0,
                          )
                        : InkWell(
                            onTap: () {
                              widget.context.forward(
                                  '/wallet/fission/mf/monitor',
                                  arguments: {
                                    'cashier': _cashierOR,
                                    'wallet': _myWallet,
                                    'assessCacCount': _assessCacCount
                                  }).then((value) async {
                                IFissionMFCashierRemote cashierRemote = widget
                                    .context.site
                                    .getService('/wallet/fission/mf/cashier');
                                _assessCacCount =
                                    await cashierRemote.assessCacCount();
                                if (mounted) {
                                  setState(() {});
                                }
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '营业参数:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      '¥${(_cashierOR.cacAverage / 100.00).toStringAsFixed(2)}元/客',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '预计可拉新$_assessCacCount人',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      '设置',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                constraints: BoxConstraints.tightForFinite(
                  width: double.maxFinite,
                ),
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '我的兴趣标签',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '兴趣标签帮助您发展有共同兴趣有爱好的朋友',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        widget.context.forward(
                            '/wallet/fission/mf/tag/properties',
                            arguments: {
                              'wallet': _myWallet,
                              'cashier': _cashierOR,
                            });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Wrap(
                              children: _tags.map((tag) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey[300], width: 1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: EdgeInsets.only(
                                    left: 8,
                                    right: 8,
                                    top: 2,
                                    bottom: 2,
                                  ),
                                  child: Text(
                                    '${tag.name ?? ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                              spacing: 5,
                              runSpacing: 5,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              '设置',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                constraints: BoxConstraints.tightForFinite(
                  width: double.maxFinite,
                ),
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '广告附件',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '在用户领取你的红包时，必看该广告，支持图片、视频',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        widget.context
                            .forward('/wallet/fission/mf/attach', arguments: {
                          'wallet': _myWallet,
                          'cashier': _cashierOR,
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              '设置',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                constraints: BoxConstraints.tightForFinite(
                  width: double.maxFinite,
                ),
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '我的朋友',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      '查看你发展的朋友',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        widget.context.forward(
                            '/wallet/fission/mf/group/payees',
                            arguments: {
                              'wallet': _myWallet,
                              'cashier': _cashierOR,
                            });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              children: _payees.map((e) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: 5,
                                  ),
                                  child: FadeInImage.assetNetwork(
                                    width: 30,
                                    height: 30,
                                    image: '${e?.avatarUrl ?? ''}',
                                    placeholder:
                                        'lib/portals/gbera/images/default_watting.gif',
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              '共进群$_totalPayeeAll人',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                      child: Divider(
                        height: 50,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        widget.context.forward(
                            '/wallet/fission/mf/group/payers',
                            arguments: {
                              'wallet': _myWallet,
                              'cashier': _cashierOR,
                            });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              children: _payers.map((e) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: 5,
                                  ),
                                  child: FadeInImage.assetNetwork(
                                    width: 30,
                                    height: 30,
                                    image: '${e?.avatarUrl ?? ''}',
                                    placeholder:
                                        'lib/portals/gbera/images/default_watting.gif',
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              '共加群$_totalPayerAll个',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              /*
                SizedBox(
                  height: 10,
                ),
                Container(
                  color: Colors.white,
                  constraints: BoxConstraints.tightForFinite(
                    width: double.maxFinite,
                  ),
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '自动充值策略',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '想进群就要正确定义你的推广策略。系统会按你的定义从你的地微钱包零钱中划扣，并充钱到红包余额',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            '扣费策略',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                '每日',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                '¥500.00',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                 */
            ],
          ),
        ],
      ),
    );
  }
}

class _WithdrawPopupWidget extends StatefulWidget {
  PageContext context;
  MyWallet wallet;

  _WithdrawPopupWidget({this.context, this.wallet});

  @override
  __WithdrawPopupWidgetState createState() => __WithdrawPopupWidgetState();
}

class __WithdrawPopupWidgetState extends State<_WithdrawPopupWidget> {
  TextEditingController _amountController = TextEditingController();
  MyWallet _myWallet;
  String _errorText;

  @override
  void initState() {
    _myWallet = widget.wallet;
    _amountController.text =
        '${(_myWallet.fissionMf / 100.00).toStringAsFixed(2)}';
    super.initState();
  }

  @override
  void dispose() {
    _amountController?.dispose();
    super.dispose();
  }

  bool _isValid() {
    var v = _amountController.text;
    if (!StringUtil.isEmpty(v)) {
      try {
        var amount = double.parse(v);
        if (amount * 100 <= _myWallet.fissionMf) {
          return true;
        }
      } catch (e) {}
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('提取到零钱'),
        actions: [
          FlatButton(
            onPressed: !_isValid()
                ? null
                : () {
                    var v = _amountController.text;
                    var amount = double.parse(v);
                    int result = (amount * 100).floor();
                    widget.context.backward(result: result);
                  },
            child: Text(
              '确认',
              style: TextStyle(
                color: !_isValid() ? Colors.grey[400] : Colors.green,
              ),
            ),
          ),
        ],
        elevation: 0,
        titleSpacing: 0,
      ),
      body: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 40,
        ),
        child: TextField(
          controller: _amountController,
          keyboardType: TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          decoration: InputDecoration(
            labelText: '提取金额',
            hintText: '输入金额...',
            prefixIcon: Icon(
              FontAwesomeIcons.yenSign,
              size: 14,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey[100],
              ),
            ),
            errorText: _errorText,
          ),
          onChanged: (v) {
            if (!StringUtil.isEmpty(v)) {
              _errorText = null;
              if (!v.endsWith('.')) {
                try {
                  double amount = double.parse(v);
                  if (amount * 100 > _myWallet.fissionMf) {
                    _errorText = '超出余额';
                    _amountController.text = '';
                  }
                } catch (e) {
                  _errorText = '不是合法的输入值';
                  _amountController.text = '';
                }
              }
            }
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}