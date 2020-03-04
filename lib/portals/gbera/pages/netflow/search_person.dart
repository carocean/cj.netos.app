import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';

class PersonSearchDelegate extends SearchDelegate<String> {
  PageContext context;

  PersonSearchDelegate(this.context)
      : super(
          searchFieldLabel: '公号/统一号/手机号等',
        );

  @override
  List<Widget> buildActions(BuildContext context) {
    //右侧显示内容 这里放清除按钮
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //左侧显示内容 这里放了返回按钮
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        if (query.isEmpty) {
          close(context, null);
        } else {
          query = "";
          showSuggestions(context);
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: Text('结果'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _PersonSuggestions(query: query, context: this.context);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      textTheme: TextTheme(
        title: TextStyle(
          fontSize: 14,
        ),
      ),
      primaryColor: Theme.of(context).primaryColor,
      appBarTheme: AppBarTheme(
        elevation: 0.0,
        textTheme: Theme.of(context).appBarTheme.textTheme,
        color: Theme.of(context).appBarTheme.color,
        actionsIconTheme: Theme.of(context).appBarTheme.actionsIconTheme,
        brightness: Theme.of(context).appBarTheme.brightness,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      ),
    );
  }
}

class _PersonSuggestions extends StatefulWidget {
  String query;
  PageContext context;

  _PersonSuggestions({this.query, this.context});

  @override
  __PersonSuggestionsState createState() => __PersonSuggestionsState();
}

class __PersonSuggestionsState extends State<_PersonSuggestions> {
  EasyRefreshController _controller;

  @override
  void initState() {
    _controller = EasyRefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.custom(
      shrinkWrap: true,
      controller: _controller,
      onRefresh: _onRefresh,
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 10,
            ),
            child: Text(
              '推荐',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _PersonCard(widget.context),
        ),
        SliverToBoxAdapter(
          child: _PersonCard(widget.context),
        ),
        SliverToBoxAdapter(
          child: _PersonCard(widget.context),
        ),
        SliverToBoxAdapter(
          child: _PersonCard(widget.context),
        ),
      ],
    );
  }

  Future<void> _onRefresh() async {
    return;
  }
}

class _PersonCard extends StatefulWidget {
  PageContext context;

  _PersonCard(this.context);

  @override
  _PersonCardState createState() => _PersonCardState();
}

class _PersonCardState extends State<_PersonCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      margin: EdgeInsets.only(
        left: 15,
        right: 15,
        bottom: 10,
        top: 10,
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              right: 10,
            ),
            child: Image.network(
              'http://47.105.165.186:7100/public/8d1db39600c6a2b8b784d28f22a9bc58.jpg?accessToken=${widget.context.principal.accessToken}',
              fit: BoxFit.cover,
              width: 140,
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '杨采妮',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '${widget.context.principal.person}',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    '韩国新冠肺炎累计确诊病例突破5300例，是中国境外最大的感染地。 韩国总统文在寅称其为：“进入一场战争。”',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
