import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:city_pickers/city_pickers.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/util.dart';
import 'dart:math' as math;

import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/pages/market/org_licence.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:uuid/uuid.dart';

class RequestISP extends StatefulWidget {
  PageContext context;

  RequestISP({this.context});

  @override
  _RequestISPState createState() => _RequestISPState();
}

class _RequestISPState extends State<RequestISP> {
  int _pannel_index = 0; //0为登记页；1为流程页；
  int _step_no = 0;
  bool _watting_for_check_workitem = true;
  ScrollController _controller;
  TextEditingController _cropName;
  TextEditingController _cropCode;
  TextEditingController _simpleName;
  TextEditingController _masterRealName;
  TextEditingController _masterPhone;
  TextEditingController _verifyCode;
  String _bussinessScope;
  String _bussinessAreaTitle;
  String _bussinessAreaCode;
  String _licenceSrc;
  String _cropLogo;
  String _licenceSrc_local;
  String _cropLogo_local;
  bool _signContract = true;
  int _operatePeriod = 12;
  int _fee = 0;
  int _isp_fee_per_month = 5000000; //isp每月收费5万元

  //上传进度条
  int _upload_licence_i = 0;
  int _upload_licence_j = 0;
  int _upload_logo_i = 0;
  int _upload_logo_j = 0;
  bool _licence_uploading = false;
  bool _logo_uploading = false;
  String _fetchCodeLabel = '获取验证码';
  bool _fetchButtonEnabled = false;
  int _verifyCode_result = 0; //验证结果.0还没验证；1成功；-1失败
  List<WorkItem> _workitems = [];
  WorkItem _currentWorkItem;
  bool _existsAreaCode = false;

  @override
  void initState() {
    _fee = _operatePeriod * _isp_fee_per_month;
    _controller = ScrollController();
    _cropName = TextEditingController();
    _cropCode = TextEditingController();
    _simpleName = TextEditingController();
    _masterRealName = TextEditingController();
    _masterPhone = TextEditingController();
    _verifyCode = TextEditingController();
    _bussinessScope =
        '授权贵公司在##内经营节点动力旗下地微相关产品服务，服务包括：\n1、平聊服务；\n2、网流服务；\n3、地圈服务；\n4、追链服务；\n5、地商服务；\n6、其它经双方约定的服务。';
    geoLocation.start();
    geoLocation.listen('/market/isp', 0, (location) async {
      if (!mounted) {
        return;
      }
      var province = await location.province;
      if (StringUtil.isEmpty(province)) {
        return;
      }
      geoLocation.unlisten('/market/isp');
      geoLocation.stop();
      var list = await AmapSearch.instance.searchKeyword(province);
      for (var item in list) {
        _bussinessAreaTitle = item.provinceName;
        _bussinessAreaCode = item.provinceCode;
        await _existsBusinessAreaCode();
        setState(() {});
        break;
      }
    });
    _loadWorkitem().then((v) {
      _watting_for_check_workitem = false;
      if (mounted) {
        setState(() {});
      }
    });
    _loadRecipientBanks().then((value) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _existsBusinessAreaCode() async {
    ILicenceRemote licenceRemote =
        widget.context.site.getService('/remote/org/licence');
    OrgLicenceOL licenceOL =
        await licenceRemote.getLicenceByAreaCode(2, _bussinessAreaCode);
    _existsAreaCode = licenceOL == null ? false : true;
  }

  Future<void> _loadWorkitem() async {
    IIspRemote remote = widget.context.site.getService('/remote/org/isp');
    List<WorkItem> items = await remote.pageMyWorkItemOnWorkflow(1);
    _workitems.addAll(items);
    if (items.isNotEmpty) {
      _currentWorkItem = items[0];
      _pannel_index = 1;
      switch (_currentWorkItem.workEvent.code) {
        case 'workInstBegin':
          _step_no = 0;
          break;
        case 'payConfirm':
          _step_no = 1;
          break;
        case 'platformChecker':
          _step_no = 1;
          break;
        case 'return':
          _step_no = 1;
          break;
        case 'workInstEnd':
          _step_no = 2;
          break;
      }
    } else {
      _pannel_index = 0;
    }
  }

  Future<void> _applyRegister() async {
    IIspRemote remote = widget.context.site.getService('/remote/org/isp');
    var workitem = await remote.applyRegisterByPerson(IspApplayBO(
      bussinessAreaCode: _bussinessAreaCode,
      bussinessAreaTitle: _bussinessAreaTitle,
      bussinessScop: (_bussinessScope ?? '')
          ?.replaceFirst('##', _bussinessAreaTitle ?? '...'),
      cropCode: _cropCode.text,
      cropLogo: _cropLogo,
      cropName: _cropName.text,
      fee: _fee,
      licenceSrc: _licenceSrc,
      masterPhone: _masterPhone.text,
      masterRealName: _masterRealName.text,
      operatePeriod: _operatePeriod,
      simpleName: _simpleName.text,
    ));
  }

  bool _checkNextButtonEnabled() {
    return !_existsAreaCode &&
        !StringUtil.isEmpty(_cropName.text) &&
        !StringUtil.isEmpty(_simpleName.text) &&
        !StringUtil.isEmpty(_cropCode.text) &&
        !StringUtil.isEmpty(_licenceSrc) &&
        !StringUtil.isEmpty(_cropLogo) &&
        _operatePeriod > 0 &&
        _fee > 0 &&
        !StringUtil.isEmpty(_bussinessAreaTitle) &&
        !StringUtil.isEmpty(_bussinessAreaCode) &&
        !StringUtil.isEmpty(_masterRealName.text) &&
        _verifyCode_result == 1 &&
        _signContract;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _controller,
        headerSliverBuilder: (ctx, s) {
          return [
            SliverAppBar(
              pinned: true,
              title: Text(
                '运营商(ISP)申请',
              ),
              elevation: 0,
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: DemoHeader(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 40,
                    right: 40,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              '资料登记',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: 20,
                          ),
                          child: Divider(
                            height: 1,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: _step_no > 0 ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              '付款',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: 20,
                          ),
                          child: Divider(
                            height: 1,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: _step_no > 1 ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              '平台审批',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: 20,
                          ),
                          child: Divider(
                            height: 1,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              '4',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: _step_no > 2 ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5,
                              left: 10,
                              right: 10,
                            ),
                            child: Text(
                              '完成',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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
          ];
        },
        body: _watting_for_check_workitem
            ? Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(
                constraints: BoxConstraints.expand(),
                color: Colors.white,
                child: IndexedStack(
                  index: _pannel_index,
                  children: <Widget>[
                    _renderStep1RegisterPanel(),
                    _renderWorkitemPannel(),
                    _renderStep2PaymentPanel(),
                    _renderStep3PlatformChecker(),
                    _renderStep4EndFlow(),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _uploadCropLogo() async {
    widget.context.forward('/widgets/avatar', arguments: {
      'aspectRatio': -1.0,
    }).then((avatar) async {
      if (StringUtil.isEmpty(avatar)) {
        return;
      }
      print('----$avatar');
      _cropLogo_local = avatar;
      _logo_uploading = true;
      setState(() {});
      var map = await widget.context.ports
          .upload('/app/org/isp/logo/', [avatar], onSendProgress: (i, j) {
        _upload_logo_i = i;
        _upload_logo_j = j;
        if (i == j) {
          _logo_uploading = false;
        }
        if (mounted) {
          setState(() {});
        }
      });
      _cropLogo = map[avatar];
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _uploadLicence() async {
    widget.context.forward('/widgets/avatar', arguments: {
      'aspectRatio': -1.0,
    }).then((avatar) async {
      if (StringUtil.isEmpty(avatar)) {
        return;
      }
      print('----$avatar');
      _licenceSrc_local = avatar;
      _licence_uploading = true;
      setState(() {});
      var map = await widget.context.ports
          .upload('/app/org/isp/licence/', [avatar], onSendProgress: (i, j) {
        _upload_licence_i = i;
        _upload_licence_j = j;
        if (i == j) {
          _licence_uploading = false;
        }
        if (mounted) {
          setState(() {});
        }
      });
      _licenceSrc = map[avatar];
      if (mounted) {
        setState(() {});
      }
    });
  }

  _requestCode() async {
    _fetchCodeLabel = '获取中...';
    _fetchButtonEnabled = false;
    setState(() {});
    AppKeyPair appKeyPair = widget.context.site.getService('@.appKeyPair');
    appKeyPair = await appKeyPair.getAppKeyPair(
        widget.context.principal.appid, widget.context.site);
    var nonce = MD5Util.MD5(Uuid().v1());
    await widget.context.ports.callback(
      'get ${widget.context.site.getService('@.prop.ports.uc.auth')} http/1.1',
      restCommand: 'sendVerifyCode',
      headers: {
        'app-id': appKeyPair.appid,
        'app-key': appKeyPair.appKey,
        'app-nonce': nonce,
        'app-sign': appKeyPair.appSign(nonce),
      },
      parameters: {
        "phone": _masterPhone.text,
      },
      onsucceed: ({dynamic rc, dynamic response}) {
        print(rc);
        _fetchCodeLabel = '获取成功';

        var times = 60;
        Timer.periodic(Duration(milliseconds: 1000), (t) {
          if (times == 0) {
            t.cancel();
            _fetchCodeLabel = '重新获取';
            _fetchButtonEnabled = true;
            if (super.mounted) {
              setState(() {});
            }
            return;
          }
          _fetchCodeLabel = '等待..${times}s';
          times--;
          if (super.mounted) {
            setState(() {});
          }
        });
      },
      onerror: ({e, stack}) {
        print(e);
        _fetchCodeLabel = '重新获取';
        _fetchButtonEnabled = true;

        setState(() {});
      },
      onReceiveProgress: (i, j) {
        print('$i-$j');
      },
    );
  }

  Future<void> _doVerfiyCode() async {
    AppKeyPair appKeyPair = widget.context.site.getService('@.appKeyPair');
    appKeyPair = await appKeyPair.getAppKeyPair(
        widget.context.principal.appid, widget.context.site);
    var nonce = MD5Util.MD5(Uuid().v1());
    await widget.context.ports.callback(
      'get ${widget.context.site.getService('@.prop.ports.uc.auth')} http/1.1',
      restCommand: 'verifyCode',
      headers: {
        'app-id': appKeyPair.appid,
        'app-key': appKeyPair.appKey,
        'app-nonce': nonce,
        'app-sign': appKeyPair.appSign(nonce),
      },
      parameters: {
        "phone": _masterPhone.text,
        'verifyCode': _verifyCode.text,
      },
      onsucceed: ({dynamic rc, dynamic response}) {
        var content = rc['dataText'];
        _verifyCode_result = content == 'true' ? 1 : -1;
        if (mounted) {
          setState(() {});
        }
      },
      onerror: ({e, stack}) {
        _verifyCode_result = -1;
        if (mounted) {
          setState(() {});
        }
      },
      onReceiveProgress: (i, j) {
        print('$i-$j');
      },
    );
  }

  _renderStep1RegisterPanel() {
    final ThemeData theme = Theme.of(context);
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        left: 40,
        right: 40,
      ),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            bottom: 0,
            top: 10,
          ),
          child: Row(
            children: <Widget>[
              Padding(
                child: Text(
                  '公司名:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  right: 5,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _cropName,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '输入营业执照上的公司名',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 0,
            top: 0,
          ),
          child: Row(
            children: <Widget>[
              Padding(
                child: Text(
                  '公司简称:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  right: 5,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _simpleName,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '输入企业简称',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
            top: 0,
          ),
          child: Row(
            children: <Widget>[
              Padding(
                child: Text(
                  '统一社会认证代码:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  right: 5,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _cropCode,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '输入营业执照上的信用代码',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
            top: 20,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 5,
                          ),
                          child: Text(
                            '公司Logo:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _uploadCropLogo().then((v) {
                              if (mounted) {
                                setState(() {});
                              }
                            });
                          },
                          child: Text('上传'),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 20,
                        bottom: 20,
                      ),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            StringUtil.isEmpty(_cropLogo_local)
                                ? Container(
                                    width: 0,
                                    height: 0,
                                  )
                                : Image.file(
                                    File('$_cropLogo_local'),
                                    width: 60,
                                  ),
                            !_logo_uploading
                                ? Container(
                                    width: 0,
                                    height: 0,
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                      top: 4,
                                    ),
                                    child: Text(
                                      '${((_upload_logo_i * 1.0 / _upload_logo_j) * 100.00).toStringAsFixed(0)}%',
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
            top: 20,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 5,
                          ),
                          child: Text(
                            '营业执照:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _uploadLicence().then((v) {
                              setState(() {});
                            });
                          },
                          child: Text('上传'),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 20,
                        bottom: 20,
                      ),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            StringUtil.isEmpty(_licenceSrc_local)
                                ? Container(
                                    width: 0,
                                    height: 0,
                                  )
                                : Image.file(
                                    File(_licenceSrc_local),
                                    height: 200,
                                  ),
                            !_licence_uploading
                                ? Container(
                                    width: 0,
                                    height: 0,
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                      top: 4,
                                    ),
                                    child: Text(
                                      '${((_upload_licence_i * 1.0 / _upload_licence_j) * 100.00).toStringAsFixed(0)}%',
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
            top: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                child: Text(
                  'ISP经营期限:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  top: 12,
                ),
              ),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: SliderTheme(
                          data: theme.sliderTheme.copyWith(
                            activeTrackColor: Colors.greenAccent,
                            inactiveTrackColor:
                                theme.colorScheme.onSurface.withOpacity(0.5),
                            activeTickMarkColor:
                                theme.colorScheme.onSurface.withOpacity(0.7),
                            inactiveTickMarkColor:
                                theme.colorScheme.surface.withOpacity(0.7),
                            overlayColor:
                                theme.colorScheme.onSurface.withOpacity(0.12),
                            thumbColor: Colors.redAccent,
                            valueIndicatorColor: Colors.deepPurpleAccent,
                            thumbShape: _CustomThumbShape(),
                            valueIndicatorShape: _CustomValueIndicatorShape(),
                            valueIndicatorTextStyle: theme.accentTextTheme.body2
                                .copyWith(color: theme.colorScheme.onSurface),
                          ),
                          child: Slider(
                            value: _operatePeriod * 1.0,
                            min: 12,
                            max: 120,
                            divisions: 18,
                            onChanged: (v) {
                              setState(() {
                                _operatePeriod = v.floor();
                                _fee = _operatePeriod * _isp_fee_per_month;
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 5,
                        ),
                        child: Text('${(_operatePeriod).toStringAsFixed(0)}个月'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      bottom: 10,
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(
                          '服务费: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          '¥${(_fee / 1000000.00).toStringAsFixed(2)}万元',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      bottom: 10,
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(
                          '注: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          '按月计费，每月服务费是:${(_isp_fee_per_month / 1000000.0).toStringAsFixed(2)}万元',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 20,
            top: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  '授权经营地域:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  right: 5,
                ),
              ),
              Expanded(
                child: Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  spacing: 5,
                  children: <Widget>[
                    Text.rich(
                      TextSpan(
                        text: '${_bussinessAreaTitle ?? '定位中...'}',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(text: '       '),
                          TextSpan(
                            text: '选择',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                Result result =
                                    await CityPickers.showCityPicker(
                                  context: context,
                                  confirmWidget: FlatButton(
                                    child: Text('确认'),
                                  ),
                                  cancelWidget: FlatButton(
                                    child: Text('取消'),
                                  ),
                                  showType: ShowType.p,
                                  locationCode: _bussinessAreaCode,
                                );
                                if (result == null) {
                                  return;
                                }
                                _bussinessAreaCode = result.provinceId;
                                _bussinessAreaTitle = result.provinceName;
                                await _existsBusinessAreaCode();
                                if (mounted) setState(() {});
                              },
                          ),
                          !widget.context.principal.roles
                                  .contains('platform:administrators')
                              ? TextSpan(text: '')
                              : TextSpan(
                                  text: '    ',
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '中国',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          _bussinessAreaCode =
                                              '100000'; //100000为中国编码
                                          _bussinessAreaTitle = '中国';
                                          await _existsBusinessAreaCode();
                                          if (mounted) setState(() {});
                                        },
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                    !_existsAreaCode
                        ? SizedBox(
                            width: 0,
                            height: 0,
                          )
                        : Text.rich(
                            TextSpan(
                              text: '该地区已被申请，请',
                              children: [TextSpan(text: '选择其它地区')],
                            ),
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 20,
            top: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  '经营范围:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  right: 5,
                ),
              ),
              Expanded(
                child: Text(
                  (_bussinessScope ?? '')
                      ?.replaceFirst('##', _bussinessAreaTitle ?? '...'),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
            top: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  '所有人姓名:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  right: 5,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _masterRealName,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '输入真实姓名',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
            top: 10,
          ),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    child: Text(
                      '所有人手机号:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _masterPhone,
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        _fetchButtonEnabled = !StringUtil.isEmpty(v);
                        setState(() {});
                      },
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: '输入手机号',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 5,
                      right: 5,
                      top: 5,
                      bottom: 5,
                    ),
                    color:
                        !_fetchButtonEnabled ? Colors.grey[400] : Colors.green,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: !_fetchButtonEnabled
                          ? null
                          : () {
                              _requestCode();
                            },
                      child: Text(
                        _fetchCodeLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 5,
                ),
                child: TextField(
                  controller: _verifyCode,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '输入验证码',
                    border: InputBorder.none,
                    counterText: '${_verifyCode_result == 1 ? '验证成功' : ''}',
                    errorText: '${_verifyCode_result == -1 ? '验证失败' : ''}',
                  ),
                  onChanged: (v) {
                    if (!StringUtil.isEmpty(v) && v.length == 6) {
                      _doVerfiyCode();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
            top: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  '签约:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  right: 5,
                ),
              ),
              Checkbox(
                value: _signContract,
                onChanged: (v) {
                  _signContract = v;
                  setState(() {});
                },
              ),
              Text('运营商(ISP)经营牌照许可协议条款')
            ],
          ),
        ),
        FlatButton(
          onPressed: !_checkNextButtonEnabled()
              ? null
              : () {
                  _pannel_index = 1;
                  _applyRegister().then((v) async {
                    _workitems.clear();
                    await _loadWorkitem();
                    _controller.jumpTo(0);
                    setState(() {});
                  });
                },
          color: Colors.green,
          disabledColor: Colors.grey[300],
          disabledTextColor: Colors.white,
          textColor: Colors.white,
          child: Text(
            '下一步',
          ),
        )
      ],
    );
  }

  List<ReceivingBankOL> _banks = [];

  Future<void> _loadRecipientBanks() async {
    IReceivingBankRemote remote =
        widget.context.site.getService('/remote/org/receivingBank');
    List<ReceivingBankOL> items = await remote.getAll();
    _banks.addAll(items);
  }

  String _evidence, _evidence_local;
  bool _evidence_uploading = false;
  int _upload_evidence_i = 0, _upload_evidence_j = 1;

  Future<void> _uploadTradeNo() async {
    widget.context.forward('/widgets/avatar', arguments: {
      'aspectRatio': -1.0,
    }).then((avatar) async {
      if (StringUtil.isEmpty(avatar)) {
        return;
      }
      _evidence_local = avatar;
      _evidence_uploading = true;
      setState(() {});
      var map = await widget.context.ports
          .upload('/app/org/isp/evidence/', [avatar], onSendProgress: (i, j) {
        _upload_evidence_i = i;
        _upload_evidence_j = j;
        if (i == j) {
          _evidence_uploading = false;
        }
        if (mounted) {
          setState(() {});
        }
      });
      _evidence = map[avatar];
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _confirmPayment() async {
    IIspRemote remote = widget.context.site.getService('/remote/org/isp');
    var workitem =
        await remote.confirmPayOrder(_currentWorkItem.workInst.id, _evidence);
    _pannel_index = 1;
    _workitems.clear();
    await _loadWorkitem();
    if (mounted) {
      setState(() {});
    }
  }

  _renderStep2PaymentPanel() {
    if (_currentWorkItem == null) {
      return Container();
    }
    var inst = _currentWorkItem.workInst;
    var event = _currentWorkItem.workEvent;
    var data = jsonDecode(inst.data);
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 20,
        top: 20,
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        child: Text(
                          '应付金额:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                        padding: EdgeInsets.only(
                          right: 5,
                          bottom: 20,
                        ),
                      ),
                      Center(
                        child: Text(
                          '¥${((data['fee'] as int) / 100 / 10000.0).toStringAsFixed(4)}万元',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 20,
                      top: 10,
                    ),
                    child: Text(
                      '平台收款行：',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 10,
                    ),
                    child: Column(
                      children: _banks.map((bank) {
                        return Wrap(
                          crossAxisAlignment: WrapCrossAlignment.start,
                          runSpacing: 10,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    '开户行:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${bank.bankName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    '户名:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${bank.accountName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    '账号:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${bank.accountNo}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                              child: Divider(
                                height: 1,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            child: Text(
                              '拍摄交易单:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            padding: EdgeInsets.only(
                              right: 5,
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _uploadTradeNo();
                            },
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      !_evidence_uploading
                          ? SizedBox(
                              width: 0,
                              height: 0,
                            )
                          : Center(
                              child: Text(
                                '${((_upload_evidence_i / _upload_evidence_j) * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                      StringUtil.isEmpty(_evidence_local)
                          ? SizedBox(
                              width: 0,
                              height: 0,
                            )
                          : Center(
                              child: Image.file(
                                File('$_evidence_local'),
                                width: 150,
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              child: FlatButton(
                color: Colors.green,
                disabledColor: Colors.grey[400],
                disabledTextColor: Colors.grey[100],
                onPressed: StringUtil.isEmpty(_evidence)
                    ? null
                    : () {
                        _confirmPayment();
                      },
                textColor: Colors.white,
                child: Text('确认'),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 20,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _pannel_index--;
                _controller?.jumpTo(0);
                if (mounted) {
                  setState(() {});
                }
              },
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  '上一步',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _renderWorkitemPannel() {
    return ListView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
      ),
      children: _workitems.map((item) {
        var inst = item.workInst;
        var event = item.workEvent;
        var map = jsonDecode(inst.data);
        switch (event.code) {
          case 'workInstBegin':
            _step_no = 0;
            break;
          case 'payConfirm':
            _step_no = 1;
            break;
          case 'platformChecker':
            _step_no = 2;
            break;
          case 'workInstEnd':
            _step_no = 3;
            break;
        }
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.context.forward('/org/workitem/details');
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        Image.network(
                          '${inst.icon}?accessToken=${widget.context.principal.accessToken}',
                          width: 35,
                          height: 35,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          top: 0,
                          child: Center(
                            child: Text(
                              '${event.stepNo + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      switch (event.code) {
                        case 'workInstBegin': //注册
                          break;
                        case 'return':
                        case 'payConfirm': //付款确认
                          _pannel_index = 2;
                          _step_no = 1;
                          _currentWorkItem = item;
                          break;
                        case 'platformChecker':
                          _pannel_index = 3;
                          _step_no = 2;
                          _currentWorkItem = item;
                          break;
                        case 'workInstEnd':
                          _pannel_index = 4;
                          _step_no = 3;
                          break;
                      }
                      setState(() {});
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              inst.name ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              TimelineUtil.formatByDateTime(
                                    parseStrTime(event.ctime, len: 17),
                                    dayFormat: DayFormat.Full,
                                  ) ??
                                  '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              '${map['simpleName']}',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: '',
                                children: [
                                  TextSpan(
                                    text: '${event.title ?? ''}',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
              child: Divider(
                height: 1,
              ),
            )
          ],
        );
      }).toList(),
    );
  }

  _renderStep3PlatformChecker() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Center(
            child: Text('等待平台审核'),
          ),
        ),
        Container(
          child: FlatButton(
            onPressed: () {
              _pannel_index = 1;
              setState(() {});
            },
            child: Text('返回'),
          ),
        ),
      ],
    );
  }

  _renderStep4EndFlow() {
    if (_currentWorkItem == null) {
      return Center(
        child: Text('没有数据'),
      );
    }
    var json = _currentWorkItem.workEvent.data;
    var obj = jsonDecode(json);
    var ispid = obj['organ'];
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              padding: EdgeInsets.only(
                left: 30,
                right: 30,
              ),
              child: OrgLicenceCard(
                context: widget.context,
                organ: ispid,
                type: 2,
              ),
            ),
          ),
        ),
        Container(
          color: Theme.of(context).backgroundColor,
          constraints: BoxConstraints.tightForFinite(
            width: double.maxFinite,
          ),
          child: FlatButton(
            onPressed: () {
              _pannel_index = 1;
              setState(() {});
            },
            child: Text('返回'),
          ),
        ),
      ],
    );
  }
}

class DemoHeader extends SliverPersistentHeaderDelegate {
  Widget child;

  DemoHeader({this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).backgroundColor,
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      child: child,
    );
  } // 头部展示内容

  @override
  double get maxExtent {
    return 72;
  } // 最大高度

  @override
  double get minExtent => 72.0; // 最小高度

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) =>
      true; // 因为所有的内容都是固定的，所以不需要更新
}

class _CustomThumbShape extends SliderComponentShape {
  static const double _thumbSize = 4.0;
  static const double _disabledThumbSize = 3.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return isEnabled
        ? const Size.fromRadius(_thumbSize)
        : const Size.fromRadius(_disabledThumbSize);
  }

  static final Animatable<double> sizeTween = Tween<double>(
    begin: _disabledThumbSize,
    end: _thumbSize,
  );

  @override
  void paint(PaintingContext context, Offset thumbCenter,
      {Animation<double> activationAnimation,
      Animation<double> enableAnimation,
      bool isDiscrete,
      TextPainter labelPainter,
      RenderBox parentBox,
      SliderThemeData sliderTheme,
      TextDirection textDirection,
      double value,
      double textScaleFactor,
      Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );
    final double size = _thumbSize * sizeTween.evaluate(enableAnimation);
    final Path thumbPath = _downTriangle(size, thumbCenter);
    canvas.drawPath(
        thumbPath, Paint()..color = colorTween.evaluate(enableAnimation));
  }
}

class _CustomValueIndicatorShape extends SliderComponentShape {
  static const double _indicatorSize = 4.0;
  static const double _disabledIndicatorSize = 3.0;
  static const double _slideUpHeight = 40.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(isEnabled ? _indicatorSize : _disabledIndicatorSize);
  }

  static final Animatable<double> sizeTween = Tween<double>(
    begin: _disabledIndicatorSize,
    end: _indicatorSize,
  );

  @override
  void paint(PaintingContext context, Offset thumbCenter,
      {Animation<double> activationAnimation,
      Animation<double> enableAnimation,
      bool isDiscrete,
      TextPainter labelPainter,
      RenderBox parentBox,
      SliderThemeData sliderTheme,
      TextDirection textDirection,
      double value,
      double textScaleFactor,
      Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;
    final ColorTween enableColor = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.valueIndicatorColor,
    );
    final Tween<double> slideUpTween = Tween<double>(
      begin: 0.0,
      end: _slideUpHeight,
    );
    final double size = _indicatorSize * sizeTween.evaluate(enableAnimation);
    final Offset slideUpOffset =
        Offset(0.0, -slideUpTween.evaluate(activationAnimation));
    final Path thumbPath = _upTriangle(size, thumbCenter + slideUpOffset);
    final Color paintColor = enableColor
        .evaluate(enableAnimation)
        .withAlpha((255.0 * activationAnimation.value).round());
    canvas.drawPath(
      thumbPath,
      Paint()..color = paintColor,
    );
    canvas.drawLine(
        thumbCenter,
        thumbCenter + slideUpOffset,
        Paint()
          ..color = paintColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0);
    labelPainter.paint(
        canvas,
        thumbCenter +
            slideUpOffset +
            Offset(-labelPainter.width / 2.0, -labelPainter.height - 4.0));
  }
}

Path _upTriangle(double size, Offset thumbCenter) =>
    _downTriangle(size, thumbCenter, invert: true);

Path _downTriangle(double size, Offset thumbCenter, {bool invert = false}) {
  final Path thumbPath = Path();
  final double height = math.sqrt(3.0) / 2.0;
  final double centerHeight = size * height / 3.0;
  final double halfSize = size / 2.0;
  final double sign = invert ? -1.0 : 1.0;
  thumbPath.moveTo(
      thumbCenter.dx - halfSize, thumbCenter.dy + sign * centerHeight);
  thumbPath.lineTo(thumbCenter.dx, thumbCenter.dy - 2.0 * sign * centerHeight);
  thumbPath.lineTo(
      thumbCenter.dx + halfSize, thumbCenter.dy + sign * centerHeight);
  thumbPath.close();
  return thumbPath;
}
