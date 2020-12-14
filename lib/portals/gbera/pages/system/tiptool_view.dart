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

  @override
  void initState() {
    _title = widget.context.partArgs['title'];
    _leading = widget.context.partArgs['leading'];
    _href = widget.context.partArgs['href'];
    _summary = widget.context.partArgs['summary'];
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
                  SizedBox(
                    width: 55,
                    height: 55,
                    child: getAvatarWidget(
                      _leading,
                      widget.context,
                    ),
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
