///商户站点
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/persistent_header_delegate.dart';

class MarchantSite extends StatefulWidget {
  PageContext context;

  MarchantSite({this.context});

  @override
  _MarchantSiteState createState() => _MarchantSiteState();
}

class _MarchantSiteState extends State<MarchantSite> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            floating: false,
            pinned: true,
            delegate: GberaPersistentHeaderDelegate(
              elevation: 0,
              backgroundColor: Colors.white,
              isFixedBackgroundColor: true,
              automaticallyImplyLeading: false,
              centerTitle: true,
              onAppBarStateChange: (d, v) {
                if (v) {
                  d.title = Text('广东邮政局');
                } else {
                  d.title = null;
                }
              },
              leading: IconButton(
                onPressed: () {
                  widget.context.backward();
                },
                icon: Icon(
                  Icons.clear,
                ),
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return _ActionSheet(
                            context: widget.context,
                          );
                        }).then((v) {
//                    widget.context.forward('/netflow/portal/site');
                    });
                  },
                  icon: Icon(
                    FontAwesomeIcons.ellipsisH,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _Header(
              context: widget.context,
              face:
                  'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572968518621&di=a96148d59f4d9ce41011683df834b098&imgtype=0&src=http%3A%2F%2Fimagecdn.edeng.cn%2Fuimages%2F5%2F15%2F62%2F103232523.gif',
              title: '广东邮政局',
              introText:
                  'H，我是广东邮政微邮局小，表叫我小YY哦！在微邮局您将可以轻松查邮件。中国邮政集团公司（英文名称China Post Group Corporation，中文简称中国邮政）成立于2007年1月29日，是在原国家邮政局所属的经营性资产和部分企事业单位基础上，依照《中华人民共和国全民所有制工业企业法》组建的大型国有独资企业。',
              eyes: false,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 10,
            ),
          ),
          SliverToBoxAdapter(
            child: _ServiceApp(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              _listBuilder,
              childCount: 10,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _listBuilder(BuildContext context, int index) {
  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            bottom: 5,
            right: 10,
          ),
          child: Text(
            '星期日 14:00',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          margin: EdgeInsets.only(left: 10, right: 10, bottom: 15),
          padding: EdgeInsets.only(
            bottom: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Image.network(
                  'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572976584319&di=f82aed28ab6e005a8bb63368478a1399&imgtype=0&src=http%3A%2F%2Fpic31.nipic.com%2F20130801%2F12713162_095926600000_2.jpg',
                  fit: BoxFit.fitWidth,
                ),
                padding: EdgeInsets.only(
                  bottom: 10,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Text(
                        '立秋吃得好，不怕秋老虎！',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 0,
                      ),
                      child: Text(
                        '1年250个工作天，我想照顾您的每一餐。',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ActionSheet extends StatelessWidget {
  PageContext context;

  _ActionSheet({this.context});

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: const Text(
            '推荐给朋友',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          onPressed: () {
            this
                .context
                .backward(result: <String, Object>{'action': 'activies'});
          },
        ),
        CupertinoActionSheetAction(
          child: const Text(
            '二维码',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          onPressed: () {
            this
                .context
                .backward(result: <String, Object>{'action': 'activies'});
          },
        ),
        CupertinoActionSheetAction(
          child: const Text(
            '更多资料',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          onPressed: () {
            this
                .context
                .backward(result: <String, Object>{'action': 'activies'});
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text('取消'),
        isDefaultAction: true,
        onPressed: () {
          Navigator.pop(context, 'Cancel');
        },
      ),
    );
  }
}

class _ServiceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _Header extends StatefulWidget {
  PageContext context;
  String face;
  String title;
  String introText;
  bool eyes; //是否已被关注
  _Header({
    this.face,
    this.title,
    this.introText,
    this.eyes = false,
    this.context,
  });

  @override
  __HeaderState createState() => __HeaderState();
}

class __HeaderState extends State<_Header> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: Image.network(
                  widget.face,
                  width: 50,
                  height: 50,
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.loose,
                      child: Text.rich(
                        TextSpan(
                          text: widget.introText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  left: 5,
                ),
                child: FlatButton(
                  onPressed: () {
                    setState(() {
                      widget.eyes = widget.eyes ? false : true;
                    });
                  },
                  child: Text(
                    widget.eyes ? '不再关注' : '关注',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 16,
                padding: EdgeInsets.only(
                  top: 2,
                  bottom: 2,
                ),
                child: VerticalDivider(
                  color: Colors.grey[400],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 5,
                ),
                child: FlatButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return widget.context
                              .part('/netflow/channel/serviceMenu', context);
                        }).then((value) {
                      print('-----$value');
                      if (value == null) return;
                      widget.context.forward('/micro/app', arguments: value);
                    });
                  },
                  child: Text(
                    '微应用',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 16,
                padding: EdgeInsets.only(
                  top: 2,
                  bottom: 2,
                ),
                child: VerticalDivider(
                  color: Colors.grey[400],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 5,
                ),
                child: FlatButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return widget.context
                              .part('/netflow/channel/site/output', context);
                        }).then((value) {
                      if (value == null) return;
                      widget.context.forward('/channel/viewer');
                    });
                  },
                  child: Text(
                    '网流',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
