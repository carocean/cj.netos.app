import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_tipoff.dart';
import 'package:intl/intl.dart' as intl;
class TipOffObjectPage extends StatefulWidget {
  PageContext context;

  TipOffObjectPage({this.context});

  @override
  _TipOffObjectPageState createState() => _TipOffObjectPageState();
}

class _TipOffObjectPageState extends State<TipOffObjectPage> {
  EasyRefreshController _controller;
  List<TipOffObjectFormOR> _forms = [];
  int _limit = 30, _offset = 0;
  int _filter = 0; //0待办；1已办;
  @override
  void initState() {
    _controller = EasyRefreshController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  Future<void> _refresh()async{
    _offset=0;
    _forms.clear();
    await _load();
  }
  Future<void> _load() async {
    ITipOffRemote tipOffRemote =
    widget.context.site.getService('/feedback/tipoff');
    var forms;
    if (_filter == 0) {
      forms = await tipOffRemote.pageOpenedObjectForm(_limit, _offset);
    } else if(_filter==1){
      forms = await tipOffRemote.pageClosedObjectForm(_limit, _offset);
    }else{
      forms = await tipOffRemote.pageObjectForm(_limit, _offset);
    }
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
        title: Text('对象举报'),
        elevation: 0,
        titleSpacing: 0,
      ),
      body: Container(
        constraints: BoxConstraints.tightForFinite(
          width: double.maxFinite,
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: 15,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  showDialog(
                    context: context,
                    child: SimpleDialog(
                      title: Text('选择'),
                      children: [
                        DialogItem(
                          onPressed: () {
                            widget.context.backward(result: 0);
                          },
                          text: '待办',
                        ),
                        DialogItem(
                          onPressed: () {
                            widget.context.backward(result: 1);
                          },
                          text: '已办',
                        ),
                        DialogItem(
                          onPressed: () {
                            widget.context.backward(result: 2);
                          },
                          text: '全部',
                        ),
                      ],
                    ),
                  ).then((value) {
                    if (value == null) {
                      return;
                    }
                    _filter = value;
                    _refresh();
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${_filter == 0 ? '待办' : _filter==1?'已办':'全部'}',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Icon(
                      FontAwesomeIcons.filter,
                      size: 20,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
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
                      '举报理由',
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
            '你还没有提交过问题',
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
          widget.context.forward('/feedback/tipoff/object/flow', arguments: {'form': form}).then((value) {
            if(value==null) {
              return;
            }
            if(_filter==0){
              _forms.removeWhere((element) => form.id==value);
            }
          });
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

  _getState(TipOffObjectFormOR form) {
    switch (form.state) {
      case 0:
        return '处理中';
      case -1:
        return '已关闭';
      default:
        return '';
    }
  }
}
