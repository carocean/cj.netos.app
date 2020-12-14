import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_tiptool.dart';
import 'package:uuid/uuid.dart';

class TipsDocCreator extends StatefulWidget {
  PageContext context;

  TipsDocCreator({this.context});

  @override
  _TipsDocCreatorState createState() => _TipsDocCreatorState();
}

class _TipsDocCreatorState extends State<TipsDocCreator> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _summaryController = TextEditingController();
  TextEditingController _hrefController = TextEditingController();
  String _leadingLocal;
  String _leadingRemote;
  double _progress = 0.00;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _titleController?.dispose();
    _summaryController?.dispose();
    _hrefController?.dispose();
    super.dispose();
  }

  bool _checkButton() {
    return !StringUtil.isEmpty(_titleController.text) &&
        !StringUtil.isEmpty(_summaryController.text);
  }

  Future<void> _createTipDoc() async {
    ITipToolRemote tipToolRemote =
        await widget.context.site.getService('/feedback/tiptool');
    await tipToolRemote.createTipsDoc(_titleController.text, _leadingRemote,
        _summaryController.text, _hrefController.text);
    widget.context.backward();
  }

  Future<void> _addLeading() async {
    var image = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxHeight: Adapt.screenH(),
      imageQuality: 80,
    );
    if (image == null) {
      return;
    }
    _leadingLocal = image.path;
    if (mounted) {
      setState(() {});
    }
    var map = await widget.context.ports
        .upload('/app/feedback/', [_leadingLocal], onSendProgress: (i, j) {
      _progress = ((i * 1.0) / j) * 100.00;
      if (mounted) {
        setState(() {});
      }
    });
    _leadingRemote = map[_leadingLocal];
    _progress = 0.00;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('创建提示'),
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
                    _createTipDoc();
                  },
            child: Icon(
              Icons.check,
            ),
          ),
        ],
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                          hintText: '请输入提示标题',
                          hintStyle: TextStyle(
                            fontSize: 14,
                          ),
                          // errorText: _titleErrorText,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                        onChanged: (value) {
                          // _titleErrorText = null;
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
                      '打开提示的链接',
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
                        controller: _hrefController,
                        decoration: InputDecoration(
                          hintText:
                              '请输入链接地址。如：http://xx;help://xx;tiptool://xxxx，如果为空默认为:tiptool://xx',
                          hintStyle: TextStyle(
                            fontSize: 14,
                          ),
                          // errorText: _titleErrorText,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                        ),
                        onChanged: (value) {
                          if (StringUtil.isEmpty(value)) {
                            // _titleErrorText = '不能为空';
                            setState(() {});
                            return;
                          }
                          // _titleErrorText = null;
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
                      '摘要',
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
                        controller: _summaryController,
                        decoration: InputDecoration(
                          hintText: '请输入提示的摘要信息',
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
                          '提示的显示图片',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _addLeading();
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
                      children: _renderLeading(),
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

  List<Widget> _renderLeading() {
    var items = <Widget>[];
    if (StringUtil.isEmpty(_leadingLocal)) {
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
    items.add(
      Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
        ),
        child: Column(
          children: [
            MediaWidget(
              [
                MediaSrc(
                  id: Uuid().v1(),
                  type: 'image',
                  text: '',
                  sourceType: 'image',
                  src: _leadingLocal,
                ),
              ],
              widget.context,
            ),
            SizedBox(
              height: 10,
            ),
            _progress > 0.00
                ? Text('${_progress.toStringAsFixed(2)}%')
                : StringUtil.isEmpty(_leadingRemote)
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
    return items;
  }
}
