import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';

class FissionMFContactUSPage extends StatefulWidget {
  PageContext context;

  FissionMFContactUSPage({this.context});

  @override
  _FissionMFContactUSPageState createState() => _FissionMFContactUSPageState();
}

class _FissionMFContactUSPageState extends State<FissionMFContactUSPage> {
  TextEditingController _phoneController;
  String _errorText;
  bool _becomeAgent = false;

  @override
  void initState() {
    _phoneController = TextEditingController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _phoneController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    var cashier = await cashierRemote.getCashier();
    _phoneController.text = cashier.phone;
    _becomeAgent = (cashier.becomeAgent ?? 0) == 1 ? true : false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _save() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    await cashierRemote.setRequirement(
        _becomeAgent ? 1 : 0, _phoneController.text);
    widget.context.backward(result: 'yes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('提交需求单'),
        elevation: 0,
        actions: [
          FlatButton(
            onPressed: StringUtil.isEmpty(_phoneController.text) ||
                    _phoneController.text.length != 11
                ? null
                : () {
                    _save();
                  },
            textColor: Colors.green,
            child: Text(
              '完成',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 15,
              bottom: 15,
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      widget.context.forward('/person/view', arguments: {
                        'official': widget.context.principal.person
                      });
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: getAvatarWidget(
                              widget.context.principal.avatarOnRemote,
                              widget.context),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '${widget.context.principal.nickName ?? ''}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                      ),
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.numberWithOptions(
                          signed: true,
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: '输入您的手机号...',
                          hintStyle: TextStyle(
                            fontSize: 16,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          errorText: _errorText ?? '',
                        ),
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        onChanged: (v) {
                          try {
                            int.parse(v);
                            if (!StringUtil.isEmpty(v)) {
                              if (v.length < 11) {
                                _errorText = '还差${11 - v.length}位';
                              } else if (v.length > 11) {
                                _errorText = '手机号位数越出11位';
                              } else {
                                _errorText = '';
                              }
                            }
                          } catch (e) {
                            _errorText = '手机号格式错误';
                          }
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 30,
                          child: Checkbox(
                            value: _becomeAgent,
                            activeColor: Colors.green,
                            onChanged: (v) {
                              setState(() {
                                _becomeAgent = v;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            _becomeAgent = !_becomeAgent;
                            setState(() {});
                          },
                          child: Text(
                            '是否想做代理',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 10,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '说明',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '找代理人拿优惠。平台会主动联系你，并为你指定代理人，请正确填写资料。',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
