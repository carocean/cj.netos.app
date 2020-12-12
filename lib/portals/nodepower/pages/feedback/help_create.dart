import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_helper.dart';
import 'package:uuid/uuid.dart';

class HelperCreator extends StatefulWidget {
  PageContext context;

  HelperCreator({this.context});

  @override
  _HelperCreatorState createState() => _HelperCreatorState();
}

class _HelperCreatorState extends State<HelperCreator> {
  List<HelpTypeOR> _types = [];
  String _selectHelpTypeId;
  TextEditingController _titleController;
  TextEditingController _contentController;
  String _titleErrorText;
  Map<String, HelpAttachmentOR> _attachs = {}; //key是本地文件路径
  Map<String, TextEditingController> _attachControllers = {}; //key是本地文件路径
  double _progress = 0.00;

  @override
  void initState() {
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _titleController?.dispose();
    _contentController?.dispose();
    _attachControllers?.forEach((key, value) {
      value?.dispose();
    });
    super.dispose();
  }

  Future<void> _load() async {
    IHelperRemote helperRemote =
        widget.context.site.getService('/feedback/helper');
    var types = await helperRemote.listHelpTypes();
    for (var type in types) {
      _types.add(type);
    }
    if (mounted) {
      setState(() {});
    }
  }

  bool _checkButton() {
    return !StringUtil.isEmpty(_selectHelpTypeId) &&
        !StringUtil.isEmpty(_titleController.text) &&
        !StringUtil.isEmpty(_contentController.text);
  }

  Future<void> _createWOForm() async {
    IHelperRemote helperRemote =
        await widget.context.site.getService('/feedback/helper');
    await helperRemote.createHelpForm(_titleController.text, _selectHelpTypeId,
        _contentController.text, _attachs.values);
    widget.context.backward();
  }

  Future<void> _addAttach() async {
    var image = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxHeight: Adapt.screenH(),
      imageQuality: 80,
    );
    if (image == null) {
      return;
    }
    var _attachLocal = image.path;
    if (mounted) {
      setState(() {});
    }
    var map = await widget.context.ports
        .upload('/app/feedback/', [_attachLocal], onSendProgress: (i, j) {
      _progress = ((i * 1.0) / j) * 100.00;
      if (mounted) {
        setState(() {});
      }
    });
    var _attachRemote = map[_attachLocal];
    _attachs[_attachLocal] = HelpAttachmentOR(
      text: '',
      url: _attachRemote,
    );
    _attachControllers[_attachLocal] = TextEditingController();
    _progress = 0.00;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('创建帮助'),
        elevation: 0,
        titleSpacing: 0,
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
            textColor: !_checkButton() ? Colors.grey : Colors.green,
            onPressed: !_checkButton()
                ? null
                : () {
                    _createWOForm();
                  },
            child: Icon(
              Icons.check,
            ),
          ),
        ],
      ),
      // resizeToAvoidBottomPadding: false,
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _renderHelpTypesPanel(),
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
                      '标题',
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
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: '请输帮助标题',
                          hintStyle: TextStyle(
                            fontSize: 14,
                          ),
                          errorText: _titleErrorText,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                        onChanged: (value) {
                          if (StringUtil.isEmpty(value)) {
                            _titleErrorText = '不能为空';
                            setState(() {});
                            return;
                          }
                          _titleErrorText = null;
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
                      '概述',
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
                          hintText: '帮助的总体描述，一定要简要',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '图文',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _addAttach();
                          },
                          child: Icon(
                            Icons.add,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      children: _renderAttachs(),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderHelpTypesPanel() {
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
                value: _selectHelpTypeId == type.id,
                activeColor: Colors.green,
                onChanged: (v) {
                  _selectHelpTypeId = v ? type.id : null;
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
                if (_selectHelpTypeId == type.id) {
                  _selectHelpTypeId = null;
                } else {
                  _selectHelpTypeId = type.id;
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
            '功能',
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

  List<Widget> _renderAttachs() {
    var items = <Widget>[];
    if (_attachs.isEmpty) {
      items.add(
        SizedBox(
          height: 20,
        ),
      );
      items.add(
        Center(
          child: Text(
            '没有图文',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
      return items;
    }
    _attachs.forEach((local, attach) {
      items.add(
        Padding(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            top: 10,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                        controller: _attachControllers[local],
                        decoration: InputDecoration(
                          hintText: '下图的描述',
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
                          attach.text = value;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              MediaWidget(
                [
                  MediaSrc(
                    id: Uuid().v1(),
                    type: 'image',
                    text: '',
                    sourceType: 'image',
                    src: local,
                  ),
                ],
                widget.context,
              ),
              SizedBox(
                height: 10,
              ),
              _progress > 0.00
                  ? Text('${_progress.toStringAsFixed(2)}%')
                  : StringUtil.isEmpty(attach.url)
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
          ),
        ),
      );
      items.add(
        SizedBox(
          height: 20,
          child: Divider(
            height: 1,
            color: Colors.green,
          ),
        ),
      );
    });
    return items;
  }
}
