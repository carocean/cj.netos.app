import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_tiptool.dart';

class TipsDocPreviewAndCreate extends StatefulWidget {
  PageContext context;

  TipsDocPreviewAndCreate({this.context});

  @override
  _TipsDocPreviewAndCreateState createState() =>
      _TipsDocPreviewAndCreateState();
}

class _TipsDocPreviewAndCreateState extends State<TipsDocPreviewAndCreate> {
  String _leading;
  String _title;
  String _summary;
  String _href;
  double _progress = 0.0;

  @override
  void initState() {
    _title = widget.context.partArgs['title'];
    _leading = widget.context.partArgs['leading'];
    _href = widget.context.partArgs['href'];
    _summary = widget.context.partArgs['summary'];
    _checkAndUploadLeading();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _checkAndUploadLeading() async {
    if (StringUtil.isEmpty(_leading)) {
      return;
    }
    if (!_leading.startsWith('/')) {
      return;
    }
    var map = await widget.context.ports.upload('/app/feedback/', [_leading],
        onSendProgress: (i, j) {
      _progress = ((i * 1.0) / j) * 100.00;
      if (mounted) {
        setState(() {});
      }
    });
    _leading = map[_leading];
    _progress=0.0;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _create() async {
    ITipToolRemote tipToolRemote =
        await widget.context.site.getService('/feedback/tiptool');
    await tipToolRemote.createTipsDoc(_title, _leading, _summary, _href);
    showDialog(
        context: context,
        child: AlertDialog(
          title: Text('提示'),
          elevation: 0,
          content: Text('成功分享到桌面提示工具栏！'),
          actions: [
            FlatButton(
              child: const Text(
                '确定',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                widget.context.backward();
              },
            ),
          ],
        )).then((value) {
      widget.context.backward();
    });
  }

  bool _checkButton() {
    return !StringUtil.isEmpty(_leading) &&
        !_leading.startsWith('/') &&
        !StringUtil.isEmpty(_title) &&
        !StringUtil.isEmpty(_summary) &&
        !StringUtil.isEmpty(_href);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0,
      ),
      body: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              //doc.href的协议头判断：http://|https://是打开网页;help://为打开帮助
            },
            child: Container(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: 10,
              ),
              margin: EdgeInsets.only(
                left: 15,
                right: 15,
                top: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                // color: Colors.white,
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: 55,
                        height: 55,
                        child: getAvatarWidget(
                          _leading,
                          widget.context,
                        ),
                      ),
                      _progress > 0
                          ? Center(
                              child: Text(
                                '${_progress.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : SizedBox(
                              width: 0,
                              height: 0,
                            ),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '${_summary}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SizedBox(),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: RaisedButton(
                    color: Colors.green,
                    textColor: Colors.white,
                    disabledTextColor: Colors.white70,
                    onPressed: !_checkButton()
                        ? null
                        : () {
                            _create();
                          },
                    child: Text('提交'),
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
    );
  }
}
