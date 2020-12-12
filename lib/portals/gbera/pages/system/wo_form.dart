import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_woflow.dart';
import 'package:uuid/uuid.dart';

class WOForm extends StatefulWidget {
  PageContext context;

  WOForm({this.context});

  @override
  _WOFormState createState() => _WOFormState();
}

class _WOFormState extends State<WOForm> {
  List<WOTypeOR> _types = [];
  String _selectWoTypeId;
  TextEditingController _phoneController;
  TextEditingController _contentController;
  String _phoneErrorText;
  String _attachRemote;
  String _attachLocal;
  double _progress = 0.00;

  @override
  void initState() {
    _phoneController = TextEditingController();
    _contentController = TextEditingController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _phoneController?.dispose();
    _contentController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    IWOFlowRemote flowRemote =
        widget.context.site.getService('/feedback/woflow');
    var types = await flowRemote.listWOTypes();
    for (var type in types) {
      _types.add(type);
    }
    if (mounted) {
      setState(() {});
    }
  }

  bool _checkButton() {
    return !StringUtil.isEmpty(_selectWoTypeId) &&
        !StringUtil.isEmpty(_phoneController.text) &&
        !StringUtil.isEmpty(_contentController.text);
  }

  Future<void> _createWOForm() async {
    IWOFlowRemote flowRemote =
        widget.context.site.getService('/feedback/woflow');
    await flowRemote.createWOForm(_selectWoTypeId, _phoneController.text,
        _contentController.text, _attachRemote);
    widget.context.backward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('提交问题'),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.clear,
          ),
          onPressed: () {
            widget.context.backward();
          },
        ),
        actions: [
          FlatButton(
            onPressed: () {
              widget.context.forward('/system/wo/mines');
            },
            child: Text('我的问题'),
          ),
        ],
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
                    _renderWOTypesPanel(),
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
                            '手机号码',
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
                            '问题描述',
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
                                  _createWOForm();
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

  Widget _renderWOTypesPanel() {
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
                value: _selectWoTypeId == type.id,
                activeColor: Colors.green,
                onChanged: (v) {
                  _selectWoTypeId = v ? type.id : null;
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
                if (_selectWoTypeId == type.id) {
                  _selectWoTypeId = null;
                } else {
                  _selectWoTypeId = type.id;
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
            '问题类型',
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
