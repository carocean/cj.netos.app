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
import 'package:netos_app/portals/gbera/pages/netflow/channel.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_bill.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_record.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

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
  GlobalKey<ScaffoldState> _key = GlobalKey();

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
      setState(() {
        _isWithdrawing = false;
      });
      return;
    }
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    var amount = result as int;
    try {
      await cashierRemote.withdraw(amount);
    } catch (e) {
      // _key.currentState.showSnackBar(SnackBar(
      //   content: Text('$e'),
      // ),);
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text('温馨提示'),
            content: Container(
              child: Text(
                '$e',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              padding: EdgeInsets.all(10),
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
          ));
      return;
    }
    Future.delayed(
        Duration(
          seconds: 1,
        ), () async {
      IWalletAccountRemote walletAccountService =
          widget.context.site.getService('/wallet/accounts');
      var wallet = await walletAccountService.getAllAcounts();
      _myWallet.fissionMf = wallet.fissionMf;
      _myWallet.change = wallet.change;
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
    String salesman = 'cj@gbera.netos'; //客户经理
    await cashier.recharge(amount, salesman);

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
      key: _key,
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
                      '营业中状态表示系统会将你推荐给其他用户，停止营业系统便不再向其他用户推荐你',
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
                            if (!v && _myWallet.fissionMf < 5000) {
                              _key.currentState.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '余额不足以停止营业！如果想继续停止营业，余额至少有50元。去挣钱或充值。',
                                  ),
                                ),
                              );
                              return;
                            }
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
                      '附件将在用户点你的头像时弹出，用于展示你的商品，支持的格式有：图片，视频等',
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
  int _stayBalance;
  bool _isLoading = true;
  WithdrawShuntOR _shuntOR;
  Person _referrer;

  @override
  void initState() {
    _myWallet = widget.wallet;
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _amountController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    _stayBalance = await cashierRemote.getStayBalance();
    int amount = _myWallet.fissionMf - _stayBalance;
    _shuntOR = await cashierRemote.computeWithdrawShuntInfo(amount);
    var cashier = await cashierRemote.getCashier();
    if (!StringUtil.isEmpty(cashier.referrer)) {
      _referrer =
          await personService.getPerson('${cashier.referrer}@gbera.netos');
    }
    _amountController.text = '${(amount / 100.00).toStringAsFixed(2)}';
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _recomputeShunt(int amount) async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    _shuntOR = await cashierRemote.computeWithdrawShuntInfo(amount);
    if (mounted) {
      setState(() {});
    }
  }

  bool _isValid() {
    if (_isLoading) {
      //留存余额还在加载
      return false;
    }
    if (_myWallet.fissionMf < _stayBalance) {
      //如果账上已小于留存余额，则不可提
      return false;
    }
    var v = _amountController.text;
    if (!StringUtil.isEmpty(v)) {
      try {
        var amount = double.parse(v);
        if (amount * 100 <= _myWallet.fissionMf - _stayBalance &&
            amount * 100 >= 100) {
          return true;
        }
      } catch (e) {}
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              '完成',
              style: TextStyle(
                color: !_isValid() ? Colors.grey[400] : Colors.green,
              ),
            ),
          ),
        ],
        elevation: 0,
        titleSpacing: 0,
      ),
      body: _renderBody(),
    );
  }

  _renderBody() {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(
            child: Text(
              '正在计算可提资金...',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 30,
            right: 30,
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
              labelStyle: TextStyle(
                fontSize: 18,
              ),
              hintText: '输入金额...',
              hintStyle: TextStyle(
                fontSize: 18,
              ),
              prefix: Padding(
                padding: EdgeInsets.only(
                  right: 5,
                  top: 10,
                ),
                child: Icon(
                  FontAwesomeIcons.yenSign,
                  size: 40,
                ),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey[100],
                ),
              ),
              errorText: _errorText,
            ),
            style: TextStyle(
              fontSize: 30,
            ),
            onChanged: (v) {
              if (!StringUtil.isEmpty(v)) {
                _errorText = null;
                if (!v.endsWith('.')) {
                  try {
                    double amount = double.parse(v);
                    if (amount * 100 > _myWallet.fissionMf - _stayBalance) {
                      _errorText = '超出可提金额';
                      _amountController.text = '';
                    } else {
                      if (amount * 100 < 100) {
                        _errorText = '至少1元起';
                      } else {
                        _recomputeShunt((amount * 100).floor());
                      }
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
        SizedBox(
          height: 40,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              width: 1,
              color: Colors.grey[300],
            ),
          ),
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Stack(
            overflow: Overflow.visible,
            children: [
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '可提金额:',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '¥',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${((_myWallet.fissionMf - _stayBalance) / 100.00).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text('='),
                      SizedBox(
                        width: 10,
                      ),
                      Text.rich(
                        TextSpan(
                          text:
                              '¥${(_myWallet.fissionMf / 100.00).toStringAsFixed(2)}',
                          children: [
                            TextSpan(
                              text: '(红包余额)',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('-'),
                      SizedBox(
                        width: 10,
                      ),
                      Text.rich(
                        TextSpan(
                          text:
                              '¥${(_stayBalance / 100.00).toStringAsFixed(2)}',
                          children: [
                            TextSpan(
                              text: '(留存金额)',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: -30,
                left: -5,
                child: Text(
                  '政策',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.only(
            left: 10,
            bottom: 5,
          ),
          alignment: Alignment.bottomLeft,
          child: Text(
            '提取金分账',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 15,
            ),
            color: Colors.white,
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '应得金额',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${(_shuntOR.gainAmount / 100.00).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        '服务费',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                        '¥${(_shuntOR.incomeAmount / 100.00).toStringAsFixed(2)}')
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        '发招财猫',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                        '¥${(_shuntOR.absorbAmount / 100.00).toStringAsFixed(2)}')
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        '发给老板',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _referrer == null
                          ? null
                          : () {
                              widget.context.forward('/person/view',
                                  arguments: {'person': _referrer});
                            },
                      child: Text(
                        '${_referrer?.nickName ?? '-'}',
                        style: TextStyle(
                          decoration: _referrer == null
                              ? TextDecoration.none
                              : TextDecoration.underline,
                          color: _referrer == null ? null : Colors.blueGrey,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                        '¥${(_shuntOR.commissionAmount / 100.00).toStringAsFixed(2)}')
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        InkWell(
          onTap: () {
            widget.context.forward('/wallet/fission/mf/become/boss');
          },
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              top: 15,
              bottom: 15,
              left: 20,
              right: 20,
            ),
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '我也要做老板',
                  style: TextStyle(
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
