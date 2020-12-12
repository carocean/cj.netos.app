import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_tipoff.dart';
import 'package:uuid/uuid.dart';

class TipOff extends StatefulWidget {
  PageContext context;

  TipOff({this.context});

  @override
  _TipOffState createState() => _TipOffState();
}

class _TipOffState extends State<TipOff> {
  List<TipOffTypeOR> _types = [];
  String _selectTypeId;
  TextEditingController _realNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _verifyCodeController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  String _phoneErrorText;
  String _attachRemote;
  String _attachLocal;
  double _progress = 0.00;

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _realNameController?.dispose();
    _phoneController?.dispose();
    _verifyCodeController?.dispose();
    _contentController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    ITipOffRemote tipOffRemote =
        widget.context.site.getService('/feedback/tipoff');
    var types = await tipOffRemote.listTipOffTypes();
    _types.addAll(types);
    if (mounted) {
      setState(() {});
    }
  }

  bool _checkButton() {
    return !StringUtil.isEmpty(_selectTypeId) &&
        !StringUtil.isEmpty(_realNameController.text) &&
        !StringUtil.isEmpty(_phoneController.text) &&
        !StringUtil.isEmpty(_contentController.text);
  }

  Future<void> _createForm() async {
    ITipOffRemote tipOffRemote =
        widget.context.site.getService('/feedback/tipoff');
    await tipOffRemote.createDirectForm(
      _selectTypeId,
      _realNameController.text,
      _phoneController.text,
      _contentController.text,
      _attachRemote,
    );
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('提示'),
            content: Text('举报成功！'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  '确认',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () {
                  widget.context.backward();
                },
              ),
            ],
          );
        }).then((value) {
      widget.context.backward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('举报'),
        elevation: 0,
        centerTitle: true,
      ),
      // resizeToAvoidBottomPadding: false,
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _renderCausePanel(),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '举报人姓名',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: TextField(
                              controller: _realNameController,
                              decoration: InputDecoration(
                                hintText: '请输入姓名',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
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
                        left: 15,
                        right: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '举报人电话',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: TextField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                hintText: '请输入电话',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                ),
                                errorText: _phoneErrorText,
                              ),
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              onChanged: (value) {
                                if (StringUtil.isEmpty(value)) {
                                  setState(() {
                                    _phoneErrorText = '手机号为空';
                                  });
                                  return;
                                }
                                if (value.length != 11) {
                                  setState(() {
                                    _phoneErrorText = '号码长度不对';
                                  });
                                  return;
                                }
                                try {
                                  int.parse(value);
                                } catch (e) {
                                  setState(() {
                                    _phoneErrorText = '不是数字';
                                  });
                                  return;
                                }
                                setState(() {
                                  _phoneErrorText = null;
                                });
                              },
                            ),
                          ),
                          /*
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _verifyCodeController,
                                    decoration: InputDecoration(
                                      hintText: '请输入验证码',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                    onChanged: (value) {},
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                RaisedButton(
                                  color: Colors.green,
                                  textColor: Colors.white,
                                  onPressed: () {},
                                  child: Text('获取验证码'),
                                ),
                              ],
                            ),
                          ),

                           */
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '举报内容',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                left: BorderSide(
                                  width: 1,
                                  color: Colors.grey[300],
                                ),
                                top: BorderSide(
                                  width: 1,
                                  color: Colors.grey[300],
                                ),
                                right: BorderSide(
                                  width: 1,
                                  color: Colors.grey[300],
                                ),
                                bottom: BorderSide(
                                  width: 1,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ),
                            child: TextField(
                              controller: _contentController,
                              decoration: InputDecoration(
                                hintText: '留下你的意见和建议，我们会及时处理',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                              ),
                              maxLines: 4,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
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
                        left: 15,
                        right: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '附件',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    child: StringUtil.isEmpty(_attachLocal)
                                        ? Text('无')
                                        : Column(
                                            children: [
                                              MediaWidget(
                                                [
                                                  MediaSrc(
                                                    id: Uuid().v1(),
                                                    type: 'image',
                                                    text: '',
                                                    sourceType: 'image',
                                                    src: _attachLocal,
                                                  ),
                                                ],
                                                widget.context,
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              _progress > 0.00
                                                  ? Text(
                                                      '${_progress.toStringAsFixed(2)}%')
                                                  : StringUtil.isEmpty(
                                                          _attachRemote)
                                                      ? SizedBox(
                                                          width: 0,
                                                          height: 0,
                                                        )
                                                      : Text(
                                                          '已上传',
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                          ),
                                                        )
                                            ],
                                          )),
                                SizedBox(
                                  width: 10,
                                ),
                                RaisedButton(
                                  color: Colors.green,
                                  textColor: Colors.white,
                                  onPressed: () async {
                                    var image = await ImagePicker().getImage(
                                      source: ImageSource.gallery,
                                      maxHeight: Adapt.screenH(),
                                      imageQuality: 80,
                                    );
                                    if (image == null) {
                                      return;
                                    }
                                    _attachLocal = image.path;
                                    if (mounted) {
                                      setState(() {});
                                    }
                                    var map = await widget.context.ports.upload(
                                        '/app/feedback/', [_attachLocal],
                                        onSendProgress: (i, j) {
                                      _progress = ((i * 1.0) / j) * 100.00;
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    });
                                    _attachRemote = map[_attachLocal];
                                    _progress = 0.00;
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                  child: Text('上传'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: RaisedButton(
                          color: !_checkButton() ? Colors.grey : Colors.green,
                          textColor: Colors.white,
                          disabledTextColor: Colors.white70,
                          padding: EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                          ),
                          onPressed: !_checkButton()
                              ? null
                              : () {
                                  _createForm();
                                },
                          child: Text(
                            '提交',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
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
          ],
        ),
      ),
    );
  }

  Widget _renderCausePanel() {
    var items = <Widget>[];
    for (var type in _types) {
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: Checkbox(
                value: _selectTypeId == type.id,
                activeColor: Colors.green,
                onChanged: (v) {
                  _selectTypeId = v ? type.id : null;
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ),
            SizedBox(
              width: 5,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_selectTypeId == type.id) {
                  _selectTypeId = null;
                } else {
                  _selectTypeId = type.id;
                }
                if (mounted) {
                  setState(() {});
                }
              },
              child: Text('${type.title}'),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '举报理由',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Wrap(
              direction: Axis.horizontal,
              spacing: 20,
              runSpacing: 20,
              children: items,
            ),
          ),
        ],
      ),
    );
  }
}
