import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';

import 'wybank_form.dart';

class AdoptWybank extends StatefulWidget {
  PageContext context;

  AdoptWybank({this.context});

  @override
  _AdoptWybankState createState() => _AdoptWybankState();
}

class _AdoptWybankState extends State<AdoptWybank> {
  WorkItem _workitem;
  OrgLicenceOL _orgLicenceOL;
  TextEditingController _serviceFeeRatio =
      TextEditingController(text: '0.3400');
  TextEditingController _reserveRatio = TextEditingController(text: '0.1000');
  TextEditingController _ttmRatio = TextEditingController(text: '1.1000');
  TextEditingController _maxAmount = TextEditingController(text: '100');
  TextEditingController _minAmount = TextEditingController(text: '199');
  TextEditingController _platformShuntRatio =
      TextEditingController(text: '0.1000');
  TextEditingController _ispShuntRatio = TextEditingController(text: '0.2000');
  TextEditingController _laShuntRatio = TextEditingController(text: '0.4000');
  TextEditingController _absorbShuntRatio =
      TextEditingController(text: '0.3000');
  WybankConfigTemplate _currentConfigTemplate;
  List<TtmInfo> _ttmConfig = [];

  @override
  void initState() {
    _workitem = widget.context.parameters['workitem'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _serviceFeeRatio?.dispose();
    _reserveRatio?.dispose();
    _ttmRatio?.dispose();
    _maxAmount?.dispose();
    _minAmount?.dispose();
    _platformShuntRatio?.dispose();
    _ispShuntRatio?.dispose();
    _laShuntRatio?.dispose();
    _absorbShuntRatio?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await wybankConfigTemplateContainer.load();
    _currentConfigTemplate = wybankConfigTemplateContainer.templates[0];
    changeTemplate();
    var form = jsonDecode(_workitem.workInst.data);
    ILicenceRemote licenceRemote =
        widget.context.site.getService('/remote/org/licence');
    _orgLicenceOL = await licenceRemote.getLicenceByID(form['licence']);
    if (mounted) {
      setState(() {});
    }
  }

  changeTemplate() {
    _serviceFeeRatio?.text =
        '${_currentConfigTemplate.serviceFeeRatio.toStringAsFixed(4)}';
    _reserveRatio?.text =
        '${_currentConfigTemplate.serviceFeeRatio.toStringAsFixed(4)}';

    _ttmConfig.clear();
    var ttmConfig = _currentConfigTemplate.ttmConfig;
    for (var ttm in ttmConfig) {
      _ttmConfig.add(ttm);
    }
    var ttmItem = _ttmConfig[0];
    _ttmRatio?.text = '${ttmItem.ttm.toStringAsFixed(4)}';
    _maxAmount?.text = '${ttmItem.maxAmount}';
    _minAmount?.text = '${ttmItem.minAmount}';
    _platformShuntRatio?.text =
        '${_currentConfigTemplate.platformRatio.toStringAsFixed(4)}';
    _ispShuntRatio?.text =
        '${_currentConfigTemplate.ispRatio.toStringAsFixed(4)}';
    _laShuntRatio?.text =
        '${_currentConfigTemplate.laRatio.toStringAsFixed(4)}';
    _absorbShuntRatio?.text =
        '${_currentConfigTemplate.absorbRatio.toStringAsFixed(4)}';
  }

  Future<void> _doAdopt() async {

  }

  Future<void> _doReturn() async {}

  @override
  Widget build(BuildContext context) {
    if (_workitem == null || _orgLicenceOL == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
        ),
        body: Center(
          child: Text(
            '加载中...',
          ),
        ),
      );
    }
    var inst = _workitem.workInst;
    var event = _workitem.workEvent;
    var form = jsonDecode(event.data);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: true,
        titleSpacing: 0,
        title: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                right: 5,
              ),
              child: Image.network(
                '${inst.icon}?accessToken=${widget.context.principal.accessToken}',
                width: 30,
                height: 30,
                fit: BoxFit.fill,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${inst.name}'),
                  Text(
                    '件号:${event.id}',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 10,
                  ),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'lib/portals/gbera/images/default_watting.gif',
                    image:
                        '${form['icon']}?accessToken=${widget.context.principal.accessToken}',
                    width: 40,
                    height: 40,
                    fit: BoxFit.fill,
                  ),
                ),
                Expanded(
                  child: Wrap(
                    direction: Axis.vertical,
                    spacing: 5,
                    children: <Widget>[
                      Text(
                        '${form['title']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text.rich(TextSpan(
                        text: '申请人:',
                        children: [
                          TextSpan(
                            text: '${form['creator']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      )),
                      Text.rich(TextSpan(
                        text: '行政区:',
                        children: [
                          TextSpan(
                            text: '${form['districtTitle']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      )),
                      Text.rich(
                        TextSpan(
                          text: '区代码:',
                          children: [
                            TextSpan(
                              text: '${form['districtCode']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: 30,
              right: 30,
            ),
            child: CardItem(
              title: 'LA营业执照',
              onItemTap: () {
                widget.context.forward(
                  '/viewer/licence',
                  scene: 'gbera',
                  arguments: {
                    'organ': _orgLicenceOL.organ,
                    'type': _orgLicenceOL.privilegeLevel,
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              margin: EdgeInsets.only(
                left: 30,
                right: 30,
                bottom: 20,
              ),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: 10,
              ),
              color: Colors.white,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints.tightForFinite(
                          width: double.maxFinite,
                        ),
                        padding: EdgeInsets.only(
                          bottom: 10,
                          top: 10,
                          left: 10,
                          right: 10,
                        ),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 10,
                              ),
                              child: Text(
                                '选择模板: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  underline: Container(
                                    height: 1,
                                    color: Colors.grey[400],
                                  ),
                                  isExpanded: false,
                                  elevation: 1,
                                  value: _currentConfigTemplate,
                                  onChanged: (v) {
                                    _currentConfigTemplate = v;
                                    changeTemplate();
                                    setState(() {});
                                  },
                                  items: wybankConfigTemplateContainer.templates
                                      .map((template) {
                                    return DropdownMenuItem(
                                      child: Text(
                                        '${template.template ?? ''}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      value: template,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                              ),
                            ),
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: '费率',
                                          labelStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          hintText: '输入小数',
                                        ),
                                        controller: _serviceFeeRatio,
                                        onChanged: (v) {
                                          if (StringUtil.isEmpty(v)) {
                                            _serviceFeeRatio.text = '0';
                                          }
                                          if (mounted) {
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: '准备金率',
                                          labelStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          hintText: '输入小数',
                                        ),
                                        controller: _reserveRatio,
                                        onChanged: (v) {
                                          if (StringUtil.isEmpty(v)) {
                                            _reserveRatio.text = '0';
                                          }
                                          if (mounted) {
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    bottom: 5,
                                    top: 10,
                                    left: 10,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(
                                    direction: Axis.vertical,
                                    spacing: 5,
                                    children: <Widget>[
                                      Text.rich(
                                        TextSpan(
                                          text: '投单金额(1.0000)=',
                                          children: [
                                            TextSpan(
                                              text:
                                                  '本金率(${_getPrincipalRatio().toStringAsFixed(4)})+',
                                            ),
                                            TextSpan(
                                              text:
                                                  '费率(${_serviceFeeRatio.text})',
                                            ),
                                          ],
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red,
                                        ),
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          text: '费率(${_serviceFeeRatio.text})=',
                                          children: [
                                            TextSpan(
                                              text:
                                                  '准备率(${_reserveRatio.text})+',
                                            ),
                                            TextSpan(
                                              text:
                                                  '自由金率(${_getFreeRatio().toStringAsFixed(4)})]',
                                            ),
                                          ],
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 2,
                            left: 18,
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.only(
                                left: 2,
                                right: 2,
                              ),
                              child: Text(
                                '费率设置',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                              ),
                            ),
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: '市盈率',
                                          labelStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          hintText: '输入小数',
                                        ),
                                        controller: _ttmRatio,
                                        onChanged: (v) {
                                          if (StringUtil.isEmpty(v)) {
                                            _ttmRatio.text = '0';
                                          }
                                          if (mounted) {
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: '匹配投单金额上限',
                                          labelStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          hintText: '输入整数，单位为分',
                                        ),
                                        controller: _maxAmount,
                                        onChanged: (v) {
                                          if (StringUtil.isEmpty(v)) {
                                            _maxAmount.text = '0';
                                          }
                                          if (mounted) {
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: '匹配投单金额下限',
                                          labelStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          hintText: '输入整数，单位为分',
                                        ),
                                        controller: _minAmount,
                                        onChanged: (v) {
                                          if (StringUtil.isEmpty(v)) {
                                            _minAmount.text = '0';
                                          }
                                          if (mounted) {
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (ctx) {
                                              return widget.context.part(
                                                  '/adopt/wybank/ttm', ctx,
                                                  arguments: {
                                                    'ttmConfig': _ttmConfig
                                                  });
                                            }).then((value) {
                                          if (value == null) {
                                            return;
                                          }
                                        });
                                      },
                                      child: Text('查看'),
                                    ),
                                    FlatButton(
                                      onPressed: () {
                                        for (var info in _ttmConfig) {
                                          if (info.ttm ==
                                              double.parse(_ttmRatio.text)) {
                                            return;
                                          }
                                        }
                                        _ttmConfig.add(
                                          TtmInfo(
                                            ttm: double.parse(_ttmRatio.text),
                                            minAmount:
                                                int.parse(_minAmount.text),
                                            maxAmount:
                                                int.parse(_maxAmount.text),
                                          ),
                                        );
                                      },
                                      child: Text('添加'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            top: 2,
                            left: 18,
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.only(
                                left: 2,
                                right: 2,
                              ),
                              child: Text(
                                '市盈率设置',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                              ),
                            ),
                            constraints: BoxConstraints.tightForFinite(
                              width: double.maxFinite,
                            ),
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: '平台',
                                          labelStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          hintText: '输入小数',
                                        ),
                                        controller: _platformShuntRatio,
                                        onChanged: (v) {
                                          if (StringUtil.isEmpty(v)) {
                                            _platformShuntRatio.text = '0';
                                          }
                                          if (mounted) {
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: '运营商',
                                          labelStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          hintText: '输入小数',
                                        ),
                                        controller: _ispShuntRatio,
                                        onChanged: (v) {
                                          if (StringUtil.isEmpty(v)) {
                                            _ispShuntRatio.text = '0';
                                          }
                                          if (mounted) {
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: '地商',
                                          labelStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          hintText: '输入小数',
                                        ),
                                        controller: _laShuntRatio,
                                        onChanged: (v) {
                                          if (StringUtil.isEmpty(v)) {
                                            _laShuntRatio.text = '0';
                                          }
                                          if (mounted) {
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: '网络洇金',
                                          labelStyle: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          hintText: '输入小数',
                                        ),
                                        controller: _absorbShuntRatio,
                                        onChanged: (v) {
                                          if (StringUtil.isEmpty(v)) {
                                            _absorbShuntRatio.text = '0';
                                          }
                                          if (mounted) {
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    bottom: 5,
                                    top: 10,
                                    left: 10,
                                  ),
                                  constraints: BoxConstraints.tightForFinite(
                                    width: double.maxFinite,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(
                                    direction: Axis.vertical,
                                    spacing: 5,
                                    children: <Widget>[
                                      Text.rich(
                                        TextSpan(
                                          text: '',
                                          children: [
                                            TextSpan(
                                              text:
                                                  '平台(${_platformShuntRatio.text})\n',
                                            ),
                                            TextSpan(
                                              text:
                                                  '运营商(${_ispShuntRatio.text})\n',
                                            ),
                                            TextSpan(
                                              text:
                                                  '地商(${_laShuntRatio.text})\n',
                                            ),
                                            TextSpan(
                                              text:
                                                  '网络洇金(${_absorbShuntRatio.text})\n',
                                            ),
                                            TextSpan(
                                              text: '---------------------\n',
                                            ),
                                            TextSpan(
                                              text:
                                                  '自由金(${_totalShunter() != 1.0 ? '错误：${_totalShunter().toStringAsFixed(4)}' : _totalShunter().toStringAsFixed(4)})',
                                            ),
                                          ],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    bottom: 5,
                                    top: 5,
                                    left: 10,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Text.rich(
                                    TextSpan(
                                      text: '地商账金提现人:',
                                      children: [
                                        TextSpan(
                                          text: ' ${inst.creator}',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 2,
                            left: 18,
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.only(
                                left: 2,
                                right: 2,
                              ),
                              child: Text(
                                '账比设置',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  child: Text('批准'),
                  onPressed: !_checkForm()
                      ? null
                      : () {
                          _doAdopt();
                        },
                ),
                FlatButton(
                  child: Text('退回'),
                  onPressed: () {
                    _doReturn();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  double _getPrincipalRatio() {
    return 1.00 - double.parse(_serviceFeeRatio.text);
  }

  double _getFreeRatio() {
    return double.parse(_serviceFeeRatio.text) -
        double.parse(_reserveRatio.text);
  }

  double _totalShunter() {
    return double.parse(_platformShuntRatio.text) +
        double.parse(_ispShuntRatio.text) +
        double.parse(_laShuntRatio.text) +
        double.parse(_absorbShuntRatio.text);
  }

  WybankForm _createForm() {
    var event = _workitem.workEvent;
    var form = jsonDecode(event.data);
    return WybankForm(
      ttmConfig: _ttmConfig,
      serviceFeeRatio: double.parse(_serviceFeeRatio.text),
      reserveRatio: double.parse(_reserveRatio.text),
      principalRatio: 1.0000 - double.parse(_serviceFeeRatio.text),
      platformRatio: double.parse(_platformShuntRatio.text),
      laRatio: double.parse(_laShuntRatio.text),
      ispRatio: double.parse(_ispShuntRatio.text),
      absorbRatio: double.parse(_absorbShuntRatio.text),
      title: form['title'],
      creator: form['creator'],
      districtCode: form['districtCode'],
      districtTitle: form['districtTitle'],
      icon: form['icon'],
      licence: form['licence'],
    );
  }

  bool _checkForm() {
    var form = _createForm();
    return form.isValid();
  }
}
