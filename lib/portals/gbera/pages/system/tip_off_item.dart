import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';

class TipOffItem extends StatefulWidget {
  PageContext context;

  TipOffItem({this.context});

  @override
  _TipOffItemState createState() => _TipOffItemState();
}

class _TipOffItemState extends State<TipOffItem> {
  TipOffItemArgs _args;

  @override
  void initState() {
    _args = widget.context.partArgs['item'];
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('举报'),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.clear,
            ),
            onPressed: () {
              widget.context.backward();
            },
          ),
        ],
      ),
      resizeToAvoidBottomPadding: false,
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Column(
          children: [
            Expanded(
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
                            '举报对象',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${_args?.desc ?? ''}',
                                    maxLines: 4,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _renderCausePanel(),
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
                            '意见描述',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10,),
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
                              decoration: InputDecoration(
                                hintText: '留下你的意见和建议，我们会及时处理',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                              ),
                              maxLines: 4,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              onChanged: (value) {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: RaisedButton(
                          color: Colors.green,
                          textColor: Colors.white,
                          padding: EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                          ),
                          onPressed: () {},
                          child: Text(
                            '提交',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
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
          ],
        ),
      ),
    );
  }

  Widget _renderCausePanel() {
    var items = <Widget>[];
    for (var i = 0; i < 10; i++) {
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: Checkbox(
                value: true,
                onChanged: (v) {},
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text('广告'),
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
            '举报理由',
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
}

class TipOffItemArgs {
  String type; //举报的目标类型
  String id; //要举报的内容标识
  String desc; //内容描述

  TipOffItemArgs({this.type, this.id, this.desc});
}
