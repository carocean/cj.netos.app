import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/share/share_card.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_tiptool.dart';

class TiptoolSharePage extends StatefulWidget {
  PageContext context;

  TiptoolSharePage({this.context});

  @override
  _TiptoolSharePageState createState() => _TiptoolSharePageState();
}

class _TiptoolSharePageState extends State<TiptoolSharePage> {
  String _href;
  String _title;
  String _summary;
  String _leading;
  bool _isLoading = true;
  TextEditingController _summaryController = TextEditingController();

  @override
  void initState() {
    var args = widget.context.parameters;
    _href = args['href'];
    _title = args['title'];
    _summary = args['summary'];
    _leading = args['leading'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _summaryController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    _isLoading = true;
    _isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _publish() async {
    ITipToolRemote tipToolRemote =
        await widget.context.site.getService('/feedback/tiptool');
    await tipToolRemote.createTipsDoc(
        _title, _leading, _summaryController.text, _href);
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text('选择'),
        elevation: 0,
        actions: [
          FlatButton(
            onPressed: () {
              widget.context.forward(
                '/',
                clearHistoryByPagePath: '.',
              );
            },
            child: Text(
              '留在地微',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          FlatButton(
            onPressed: () async {
              await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
            child: Text(
              '返回',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isEnabledButton() {
    return !StringUtil.isEmpty(_summaryController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding:false ,
      appBar: AppBar(
        title: Text('桌面提示栏'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () async {
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
        actions: [
          InkWell(
            onTap: !_isEnabledButton()
                ? null
                : () {
                    _publish();
                  },
            child: Container(
              color: _isEnabledButton() ? Colors.green : Colors.grey[500],
              margin: EdgeInsets.only(
                right: 15,
                top: 12,
                bottom: 12,
              ),
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              alignment: Alignment.center,
              child: Text(
                '发布',
                style: TextStyle(
                  color: _isEnabledButton() ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            renderShareEditor(
                context: widget.context,
                title: _title,
                href: _href,
                leading: _leading,
                summary: _summary,
                controller: _summaryController,
                onChanged: (v) {
                  setState(() {});
                }),
          ],
        ),
      ),
    );
  }
}
