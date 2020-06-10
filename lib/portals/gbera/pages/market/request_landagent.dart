import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class RequestLandagent extends StatefulWidget {
  PageContext context;

  RequestLandagent({this.context});

  @override
  _RequestLandagentState createState() => _RequestLandagentState();
}

class _RequestLandagentState extends State<RequestLandagent> {
  int _activityNo = 0;
  ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _controller,
        headerSliverBuilder: (ctx, s) {
          return [
            SliverAppBar(
              pinned: true,
              title: Text(
                '地商(LA)申请',
              ),
              elevation: 0,
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: DemoHeader(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 40,
                    right: 40,
                    top: 10,
                    bottom: 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              '资料登记',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: 20,
                          ),
                          child: Divider(
                            height: 1,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _activityNo > 0 ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              '付款',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: 20,
                          ),
                          child: Divider(
                            height: 1,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _activityNo > 1 ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5,
                            ),
                            child: Text(
                              '平台审批',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: 20,
                          ),
                          child: Divider(
                            height: 1,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              '4',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _activityNo > 2 ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 5,
                              left: 10,
                              right: 10,
                            ),
                            child: Text(
                              '完成',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          constraints: BoxConstraints.expand(),
          color: Colors.white,
          child: IndexedStack(
            index: _activityNo,
            children: <Widget>[
              _renderStep1RegisterPanel(),
              _renderStep2PaymentPanel(),
            ],
          ),
        ),
      ),
    );
  }

  _renderStep1RegisterPanel() {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        left: 40,
        right: 40,
      ),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            bottom: 0,
            top: 10,
          ),
          child: Row(
            children: <Widget>[
              Padding(
                child: Text(
                  '公司名:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  right: 5,
                ),
              ),
              Expanded(
                child: TextField(
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '输入营业执照上的公司名',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
            top: 0,
          ),
          child: Row(
            children: <Widget>[
              Padding(
                child: Text(
                  '统一社会信用代码:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  right: 5,
                ),
              ),
              Expanded(
                child: TextField(
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '输入营业执照上的信用代码',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
            top: 20,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            right: 5,
                          ),
                          child: Text(
                            '营业执照:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {},
                          child: Text('上传'),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 20,
                      ),
                      child: Center(
                        child: FadeInImage.assetNetwork(
                          placeholder:
                              'lib/portals/gbera/images/default_image.png',
                          image:
                              'http://47.105.165.186:7100/public/IMG_0220.jpg?accessToken=${widget.context.principal.accessToken}',
                          height: 200,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
            top: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  '金额:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  right: 5,
                ),
              ),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '每年¥999.00元',
                    border: InputBorder.none,
                    prefixText: '¥',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 5,
                ),
                child: Text('元'),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
            top: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  '地商经营牌照期限:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  right: 5,
                ),
              ),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '自每一个竞标成功后第2天始',
                    border: InputBorder.none,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 5,
                ),
                child: Text('年'),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 20,
            top: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  '可竞标区域:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  right: 5,
                ),
              ),
              Expanded(
                child: Text('河南省内'),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 20,
            top: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  '归属运营商:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  right: 5,
                ),
              ),
              Expanded(
                child: Text('科信集团（河南省运营商）'),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
            top: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  '所有人姓名:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  right: 5,
                ),
              ),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '输入真实姓名',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
            top: 10,
          ),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    child: Text(
                      '所有人手机号:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    padding: EdgeInsets.only(
                      right: 5,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: '输入手机号',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      left: 5,
                      right: 5,
                      top: 5,
                      bottom: 5,
                    ),
                    color: Colors.green,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: Text(
                        '获取验证码',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 5,
                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: '输入验证码',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 10,
            top: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  '签约:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                padding: EdgeInsets.only(
                  right: 5,
                ),
              ),
              Checkbox(
                value: true,
              ),
              Text('地商(LA)经营牌照许可协议条款')
            ],
          ),
        ),
        FlatButton(
          onPressed: () {
            _activityNo++;
            _controller?.jumpTo(0);
            setState(() {});
          },
          color: Colors.green,
          textColor: Colors.white,
          child: Text(
            '下一步',
          ),
        )
      ],
    );
  }

  _renderStep2PaymentPanel() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 20,
        top: 20,
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      child: Text(
                        '应付金额:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                      padding: EdgeInsets.only(
                        right: 5,
                        bottom: 20,
                      ),
                    ),
                    Center(
                      child: Text(
                        '¥29999.00',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 20,
                    top: 10,
                  ),
                  child: Text(
                    '平台收款行信息：',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 10,
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    runSpacing: 10,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 60,
                            child: Text(
                              '开户行:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '中国工商银行',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 60,
                            child: Text(
                              '行号:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '083838822773737733',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  child: Divider(
                    height: 1,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          child: Text(
                            '拍摄交易单:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          padding: EdgeInsets.only(
                            right: 5,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {},
                          child: Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: FadeInImage.assetNetwork(
                        placeholder:
                            'lib/portals/gbera/images/default_image.png',
                        image:
                            'http://47.105.165.186:7100/public/market/aab308de346c6d2544304fd8ce9eab45.jpg?accessToken=${widget.context.principal.accessToken}',
                        height: 200,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              child: FlatButton(
                color: Colors.green,
                onPressed: () {},
                textColor: Colors.white,
                child: Text('立即支付'),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 20,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _activityNo--;
                _controller?.jumpTo(0);
                if (mounted) {
                  setState(() {});
                }
              },
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  '上一步',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DemoHeader extends SliverPersistentHeaderDelegate {
  Widget child;

  DemoHeader({this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).backgroundColor,
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      child: child,
    );
  } // 头部展示内容

  @override
  double get maxExtent {
    return 72;
  } // 最大高度

  @override
  double get minExtent => 72.0; // 最小高度

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) =>
      true; // 因为所有的内容都是固定的，所以不需要更新
}
