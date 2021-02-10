import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';

class FissionMFMonitorPage extends StatefulWidget {
  PageContext context;

  FissionMFMonitorPage({this.context});

  @override
  _FissionMFMonitorPageState createState() => _FissionMFMonitorPageState();
}

class _FissionMFMonitorPageState extends State<FissionMFMonitorPage> {
  CashierOR _cashierOR;
  MyWallet _myWallet;
  List<int> _cacList = [];
  List<double> _amplitudeFactorList = [];
  int _assessCacCount = 0;
  AlgorithmInfoOR _algorithmInfoOR;
  @override
  void initState() {
    _cashierOR = widget.context.parameters['cashier'];
    _myWallet = widget.context.parameters['wallet'];
    _assessCacCount = widget.context.parameters['assessCacCount'];
    _cacList.addAll([
      30,
      40,
      50,
      60,
      70,
      80,
      90,
      100,
      150,
      200,
      250,
      300,
      350,
      400,
      500,
      600,
      700,
      800,
      900,
      1000,
      5000,
      10000
    ]);
    _amplitudeFactorList
        .addAll([0, 0.5, 1.0, 1.5, 2, 2.5, 3, 3.5, 4, 5, 6, 7, 8, 9, 10]);
    _reCompute();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _reCompute() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    _assessCacCount = await cashierRemote.assessCacCount();
    _algorithmInfoOR=await cashierRemote. getAlgorithmInfo();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _setCasAverage(int cac) async{
    IFissionMFCashierRemote cashierRemote =
    widget.context.site.getService('/wallet/fission/mf/cashier');
    await cashierRemote.setCacAverage(cac);
    await  _reCompute();
    _cashierOR.cacAverage = cac;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _setAmplitudeFactor(double amplitudeFactor) async{
    IFissionMFCashierRemote cashierRemote =
    widget.context.site.getService('/wallet/fission/mf/cashier');
    await cashierRemote.setAmplitudeFactor(amplitudeFactor);
    await  _reCompute();
    _cashierOR.amplitudeFactor = amplitudeFactor;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [],
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            constraints: BoxConstraints.tightForFinite(
              width: double.maxFinite,
            ),
            child: Column(
              children: [
                Text(
                  '预计可拉新人数',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text.rich(
                  TextSpan(
                    text: '≈',
                    children: [
                      TextSpan(
                        text: '$_assessCacCount人',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ],
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '红包余额 ¥${_myWallet.fissionMFYan}',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 15,
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
                  '拉新成本',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '即拉一个人进群你能接受的平均花费',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: '¥',
                        children: [
                          TextSpan(
                            text:
                                '${(_cashierOR.cacAverage / 100.00).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                        ],
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 5,
                        runSpacing: 10,
                        children: _cacList.map((e) {
                          return InkWell(
                            onTap: () {
                              _setCasAverage(e);
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 5,
                                right: 5,
                                top: 1,
                                bottom: 1,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey[300],
                                ),
                              ),
                              child: Text(
                                '¥${(e / 100.00).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          child: _CustomCacDialog(
                            context: widget.context,
                            defaultCac: _cashierOR.cacAverage,
                          ),
                        ).then((value) {
                          if (value == null) {
                            return;
                          }
                          _setCasAverage(value);
                        });
                      },
                      child: Text(
                        '自定义',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
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
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
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
                    '振幅因子',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '用于控制红包的金额浮动区间，或分布概率',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: '',
                          children: [
                            TextSpan(
                              text:
                                  '${_cashierOR.amplitudeFactor.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                          ],
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
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
                                    text: '[',
                                  ),
                                  TextSpan(
                                    text: '最小',
                                  ),
                                  TextSpan(
                                    text: ',',
                                  ),
                                  TextSpan(
                                    text: '最大',
                                  ),
                                  TextSpan(
                                    text: '] = (',
                                  ),
                                  TextSpan(
                                    text: '稳定上限',
                                    children: [
                                      TextSpan(
                                        text: '+[',
                                      ),
                                      TextSpan(
                                        text: '浮动下限',
                                      ),
                                      TextSpan(
                                        text: ',',
                                      ),
                                      TextSpan(
                                        text: '浮动上限',
                                      ),
                                      TextSpan(
                                        text: ']',
                                      ),
                                    ],
                                  ),
                                  TextSpan(
                                    text: ')* ',
                                  ),
                                  TextSpan(
                                    text: '2',
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 5,),
                            Text.rich(
                              TextSpan(
                                text: '',
                                children: [
                                  TextSpan(
                                    text: '[',
                                  ),
                                  TextSpan(
                                    text: '¥0.01',
                                  ),
                                  TextSpan(
                                    text: ',',
                                  ),
                                  TextSpan(
                                    text: '¥${((_algorithmInfoOR?.upMaxBound??0)/100.00).toStringAsFixed(2)}',
                                  ),
                                  TextSpan(
                                    text: '] = (',
                                  ),
                                  TextSpan(
                                    text: '¥${((_algorithmInfoOR?.baseLine??0)/100.00).toStringAsFixed(2)}',
                                    children: [
                                      TextSpan(
                                        text: '+[',
                                      ),
                                      TextSpan(
                                        text: '¥0.00',
                                      ),
                                      TextSpan(
                                        text: ',',
                                      ),
                                      TextSpan(
                                        text: '¥${((_algorithmInfoOR?.amplitude??0)/100.00).toStringAsFixed(2)}',
                                      ),
                                      TextSpan(
                                        text: ']',
                                      ),
                                    ],
                                  ),
                                  TextSpan(
                                    text: ')* ',
                                  ),
                                  TextSpan(
                                    text: '2',
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 5,
                          runSpacing: 10,
                          children: _amplitudeFactorList.map((e) {
                            return InkWell(
                              onTap: () {
                                _setAmplitudeFactor(e);
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 5,
                                  right: 5,
                                  top: 1,
                                  bottom: 1,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                child: Text(
                                  '${e.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            child: _CustomAmplitudeFactorDialog(
                              context: widget.context,
                              defaultAmplitudeFactor:
                                  _cashierOR.amplitudeFactor,
                            ),
                          ).then((value) {
                            if (value == null) {
                              return;
                            }
                            _setAmplitudeFactor(value);
                          });
                        },
                        child: Text(
                          '自定义',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomCacDialog extends StatefulWidget {
  PageContext context;
  int defaultCac;

  _CustomCacDialog({this.context, this.defaultCac});

  @override
  __CustomCacDialogState createState() => __CustomCacDialogState();
}

class __CustomCacDialogState extends State<_CustomCacDialog> {
  TextEditingController _controller;
  String _error;

  @override
  void initState() {
    _controller = TextEditingController(
        text: '${(widget.defaultCac / 100.00).toStringAsFixed(2)}');

    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool _isInvalid() {
    var v = _controller.text;
    if (StringUtil.isEmpty(v)) {
      return true;
    }
    if (v.endsWith('.')) {
      return true;
    }
    try {
      var d = double.parse(v);
      var intV = (d * 100).floor();
      if (intV < 30) {
        return true;
      }
      return false;
    } catch (e) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('定义拉新成本'),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(
              top: 10,
              bottom: 10,
              right: 15,
            ),
            child: FlatButton(
              color: Colors.green,
              disabledColor: Colors.grey[300],
              textColor: Colors.white,
              disabledTextColor: Colors.white,
              onPressed: _isInvalid()
                  ? null
                  : () {
                      var v = _controller.text;
                      var d = double.parse(v);
                      var intV = (d * 100).floor();
                      widget.context.backward(result: intV);
                    },
              child: Text('完成'),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        child: TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          decoration: InputDecoration(
            labelText: '拉新成本',
            hintText: '输入金额，至少0.3元',
            hintStyle: TextStyle(
              fontSize: 12,
            ),
            errorText: _error,
            prefixIcon: Icon(
              FontAwesomeIcons.yenSign,
              size: 14,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey[100],
              ),
            ),
          ),
          onChanged: (v) {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}

class _CustomAmplitudeFactorDialog extends StatefulWidget {
  PageContext context;
  double defaultAmplitudeFactor;

  _CustomAmplitudeFactorDialog({this.context, this.defaultAmplitudeFactor});

  @override
  __CustomAmplitudeFactorDialogState createState() =>
      __CustomAmplitudeFactorDialogState();
}

class __CustomAmplitudeFactorDialogState
    extends State<_CustomAmplitudeFactorDialog> {
  TextEditingController _controller;
  String _error;

  @override
  void initState() {
    _controller = TextEditingController(
        text: '${widget.defaultAmplitudeFactor.toStringAsFixed(2)}');

    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool _isInvalid() {
    var v = _controller.text;
    if (StringUtil.isEmpty(v)) {
      return true;
    }
    if (v.endsWith('.')) {
      return true;
    }
    try {
      var d = double.parse(v);
      if (d < 0) {
        return true;
      }
      return false;
    } catch (e) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('定义振幅因子'),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(
              top: 10,
              bottom: 10,
              right: 15,
            ),
            child: FlatButton(
              color: Colors.green,
              disabledColor: Colors.grey[300],
              textColor: Colors.white,
              disabledTextColor: Colors.white,
              onPressed: _isInvalid()
                  ? null
                  : () {
                      var v = _controller.text;
                      var d = double.parse(v);
                      widget.context.backward(result: d);
                    },
              child: Text('完成'),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        child: TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          decoration: InputDecoration(
            labelText: '振幅因子',
            hintText: '输入金额，必须为正小数',
            hintStyle: TextStyle(
              fontSize: 12,
            ),
            errorText: _error,
            prefixIcon: Icon(
              FontAwesomeIcons.yenSign,
              size: 14,
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey[100],
              ),
            ),
          ),
          onChanged: (v) {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}
