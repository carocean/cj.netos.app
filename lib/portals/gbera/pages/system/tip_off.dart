import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class TipOff extends StatefulWidget {
  PageContext context;

  TipOff({this.context});

  @override
  _TipOffState createState() => _TipOffState();
}

class _TipOffState extends State<TipOff> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('举报'),
        elevation: 0,
        centerTitle: true,
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
                            '举报人姓名',
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
                              decoration: InputDecoration(
                                hintText: '请输入姓名',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              onChanged: (value) {},
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
                            '举报人电话',
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
                              decoration: InputDecoration(
                                hintText: '请输入电话',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              onChanged: (value) {},
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: '请输入验证码',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                    onChanged: (value) {},
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                RaisedButton(
                                  color: Colors.green,
                                  textColor: Colors.white,
                                  onPressed: () {},
                                  child: Text('获取验证码'),
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
                    Container(
                      padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '举报内容',
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
                            '附件',
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
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text('1.jpg'),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                RaisedButton(
                                  color: Colors.green,
                                  textColor: Colors.white,
                                  onPressed: () {},
                                  child: Text('上传'),
                                ),
                              ],
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
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: (){
                    widget.context.forward('/system/copyrights');
                  },
                  child: Text(
                    '版权保护投诉指引',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
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
