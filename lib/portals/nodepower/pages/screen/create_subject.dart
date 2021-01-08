import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/store/remotes/operation_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CreateScreenSubjectPage extends StatefulWidget {
  PageContext context;

  CreateScreenSubjectPage({this.context});

  @override
  _CreateScreenSubjectPageState createState() =>
      _CreateScreenSubjectPageState();
}

class _CreateScreenSubjectPageState extends State<CreateScreenSubjectPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _subTitleController = TextEditingController();
  TextEditingController _hrefController = TextEditingController();
  String _leading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _titleController?.dispose();
    _subTitleController?.dispose();
    _hrefController?.dispose();
    super.dispose();
  }

  bool _checkButton() {
    return !StringUtil.isEmpty(_leading) &&
        !StringUtil.isEmpty(_titleController.text) &&
        !StringUtil.isEmpty(_hrefController.text);
  }

  Future<void> _create() async {
    IScreenRemote screenRemote =
        widget.context.site.getService('/operation/screen');
    await screenRemote.createSubject(
        _titleController.text, _subTitleController.text, _leading,_hrefController.text);
    widget.context.backward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('创建主体'),
        elevation: 0,
        titleSpacing: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
              right: 15,
            ),
            child: RaisedButton(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              onPressed: !_checkButton()
                  ? null
                  : () {
                      _create();
                    },
              color: Colors.green,
              disabledColor: Colors.grey[600],
              disabledTextColor: Colors.white70,
              child: Text(
                '完成',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        constraints: BoxConstraints.expand(),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              onChanged: (v) {
                setState(() {});
              },
              onSubmitted: (v) {},
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  right: 14,
                ),
                border: InputBorder.none,
                labelText: '标题',
                hintText: '输入标题',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                suffix:StringUtil.isEmpty(_titleController.text)?null: InkWell(
                  onTap: () {
                    _titleController.clear();
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 2,right: 2,),
                    child: Icon(
                      Icons.close,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
              child: Divider(
                height: 1,
              ),
            ),
            TextField(
              controller: _subTitleController,
              onChanged: (v) {
                setState(() {});
              },
              onSubmitted: (v) {},
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  right: 15,
                ),
                border: InputBorder.none,
                labelText: '副标题',
                hintText: '输入副标题',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(
              height: 10,
              child: Divider(
                height: 1,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hrefController,
                    onChanged: (v) {
                      setState(() {});
                    },
                    onSubmitted: (v) {},
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                        right: 15,
                      ),
                      border: InputBorder.none,
                      labelText: '链接',
                      hintText: '输入超链接',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    var result =
                        await widget.context.forward('/qrcode/scanner');
                    if (result == null) {
                      return null;
                    }
                    var code = result as Barcode;
                    _hrefController.text = code.code;
                  },
                  child: Icon(
                    Icons.qr_code,
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: _renderWebview(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderWebview() {
    if (StringUtil.isEmpty(_hrefController.text)) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }
    return InAppWebView(
      initialUrl: _hrefController.text,
      onLoadStop: (controller, url) async {
        if(StringUtil.isEmpty(_titleController.text)) {
          _titleController.text=await controller.getTitle();
        }
        var pngBytes = await controller.takeScreenshot();
        Directory dir = await getApplicationDocumentsDirectory();
        var fn = '${dir.path}/${MD5Util.MD5(_hrefController.text)}.png';
        var file = File(fn);
        if (file.existsSync()) {
          file.deleteSync();
        }
        file.writeAsBytesSync(pngBytes);
        var map = await widget.context.ports.upload('/app/', [fn]);
        _leading = map[fn];
        if (mounted) {
          setState(() {});
        }
      },
    );
  }
}
