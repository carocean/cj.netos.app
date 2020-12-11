import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_woflow.dart';
import 'package:intl/intl.dart' as intl;
class WOList extends StatefulWidget {
  PageContext context;

  WOList({this.context});

  @override
  _WOListState createState() => _WOListState();
}
///列出指定问题类型下的已经关闭的工单
class _WOListState extends State<WOList> {
  EasyRefreshController _controller;
  WOTypeOR _type;
  List<WOFormOR> _forms = [];
  int _limit = 30, _offset = 0;
  @override
  void initState() {
    _type=widget.context.parameters['type'];
    _controller = EasyRefreshController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    IWOFlowRemote flowRemote =
    await widget.context.site.getService('/feedback/woflow');
    var forms = await flowRemote.pageClosedFormByType(_type.id,_limit, _offset);
    if (forms.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      setState(() {});
      return;
    }
    _offset += forms.length;
    _forms.addAll(forms);
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_type?.title??''}'),
        elevation: 0,
        titleSpacing: 0,
      ),
      resizeToAvoidBottomPadding: false,
      body: Container(
        constraints: BoxConstraints.tightForFinite(
          width: double.maxFinite,
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '问题',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '进度',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '发起时间',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 10,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
              child: Divider(
                height: 1,
              ),
            ),
            Expanded(
              child: EasyRefresh(
                controller: _controller,
                onLoad: _load,
                child: ListView(
                  shrinkWrap: true,
                  children: _renderItems(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _renderItems() {
    var items = <Widget>[];
    if (_forms.isEmpty) {
      items.add(
        SizedBox(
          height: 20,
        ),
      );
      items.add(
        Center(
          child: Text(
            '没有相关问题',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
      return items;
    }
    for (var form in _forms) {
      items.add(GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.context.forward('/system/wo/flow',arguments: {'form':form});
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: 10,
            bottom: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('${form.typeTitle ?? ''}'),
              ),
              Expanded(
                child: Text('${_getState(form)}'),
              ),
              Expanded(
                child: Text(
                  '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(form.ctime))}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
      items.add(
        Divider(
          height: 1,
          indent: 15,
        ),
      );
    }
    return items;
  }

  _getState(WOFormOR form) {
    switch (form.state) {
      case 0:
        return '已提交';
      case 1:
        return '处理中';
      case -1:
        return '已关闭';
      default:
        return '';
    }
  }
}
