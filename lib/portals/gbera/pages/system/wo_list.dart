import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';

class WOList extends StatefulWidget {
  PageContext context;

  WOList({this.context});

  @override
  _WOListState createState() => _WOListState();
}
///列出指定问题类型下的已经关闭的工单
class _WOListState extends State<WOList> {
  EasyRefreshController _controller;

  @override
  void initState() {
    _controller = EasyRefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('某问题类型'),
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
    for (var i = 0; i < 10; i++) {
      items.add(
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: (){
              widget.context.forward('/system/wo/flow');
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
                    child: Text('系统问题'),
                  ),
                  Expanded(
                    child: Text('已关闭'),
                  ),
                  Expanded(
                    child: Text(
                      '2020/12/10 17:47',
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
          )
      );
      items.add(
        Divider(
          height: 1,
          indent: 15,
        ),
      );
    }
    return items;
  }
}
