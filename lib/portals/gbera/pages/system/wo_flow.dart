import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/parts/timeline_listview.dart';

class WOFlow extends StatefulWidget {
  PageContext context;

  WOFlow({this.context});

  @override
  _WOFlowState createState() => _WOFlowState();
}

class _WOFlowState extends State<WOFlow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('处理进度'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        constraints: BoxConstraints.tightForFinite(
          width: double.maxFinite,
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '资源下载99%不动',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('反馈编号:'),
                SizedBox(
                  width: 10,
                ),
                Text('20202883838838383823'),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
              height: 1,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 10,
                  ),
                  child: Column(
                    children: _renderFlowPanel(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _renderFlowPanel() {
    var items = <Widget>[];
    for (var i = 0; i < 5; i++) {
      items.add(
        rendTimelineListRow(
          title: Container(
            child: Row(
              children: [
                Text('2020/1/23 24:28:28'),
              ],
            ),
          ),
          paddingLeft: 12,
          paddingContentLeft: 40,
          content: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/system/wo/view');
            },
            child: Container(
              padding: EdgeInsets.all(10),
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('已提交问题'),
                  Text('问题标描：'),
                  Text('是什么，是啥'),
                ],
              ),
            ),
          ),
        ),
      );
    }
    items.add(
      SizedBox(
        height: 20,
        child: Divider(
          height: 1,
        ),
      ),
    );
    items.add(
      Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '发表你的意见和建议',
                    hintStyle: TextStyle(
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    fillColor: Colors.white,
                  ),
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  onChanged: (value) {},
                ),
              ),
              SizedBox(
                width: 10,
              ),
              OutlineButton(
                onPressed: () {},
                child: Text('发送'),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: Text('1.jpg'),
              ),
              SizedBox(
                width: 10,
              ),
              OutlineButton(
                onPressed: () {},
                child: Text('上传附件'),
              ),
            ],
          ),
        ],
      ),
    );
    items.add(
      SizedBox(
        height: 20,
      ),
    );
    return items;
  }
}
