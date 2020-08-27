import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/cc_medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

import 'collapsible_panel.dart';

class ContentItemPanel extends StatefulWidget {
  PageContext context;
  ContentItemOR item;
  String towncode;

  ContentItemPanel({
    this.context,
    this.item,
    this.towncode,
  });

  @override
  _ContentItemPanelState createState() => _ContentItemPanelState();
}

class _ContentItemPanelState extends State<ContentItemPanel> {
  int _maxLines = 4;
  RecommenderDocument _doc;
  Future<TrafficPool> _future_getPool;
  bool _isCollapsibled = true;
  Future<Person> _future_getPerson;
  Future<ContentBoxOR> _future_getContentBox;
  Future<ItemBehavior> _future_getItemInnerBehavior;

  @override
  void initState() {
    _loadDocumentContent();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(ContentItemPanel oldWidget) {
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.towncode != widget.towncode) {
      oldWidget.item = widget.item;
      oldWidget.towncode = widget.towncode;
      _loadDocumentContent();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadDocumentContent() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    _doc = await recommender.getDocument(widget.item);
    _future_getPool = _getPool();
    _future_getPerson = _getPerson(widget.context.site, _doc.message.creator);
    _future_getContentBox = _getContentBox();
    _future_getItemInnerBehavior = _getItemInnerBehavior();
    if (mounted) setState(() {});
  }

  Future<TrafficPool> _getPool() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    return await recommender.getTrafficPool(_doc.item.pool);
  }

  Future<ContentBoxOR> _getContentBox() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    return await recommender.getContentBox(_doc.item.pool, _doc.item.box);
  }

  Future<ItemBehavior> _getItemInnerBehavior() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    return await recommender.getItemInnerBehavior(_doc.item.pool, _doc.item.id);
  }

  Future<TrafficDashboard> _getTrafficDashboard() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    return await recommender.getTrafficDashboard(_doc.item.pool);
  }

  @override
  Widget build(BuildContext context) {
    if (_doc == null) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }

    var layout = <Widget>[];
    switch (_doc.message.layout) {
      case 0: //上文下图
        if (!StringUtil.isEmpty(_doc.message.content)) {
          layout.add(
            _renderContent(),
          );
        }
        if (_doc.medias.isNotEmpty) {
          layout.add(
            SizedBox(
              height: 10,
            ),
          );
          layout.add(
            _renderMedias(),
          );
          layout.add(
            SizedBox(
              height: 10,
            ),
          );
        }
        if (_doc.medias.isEmpty) {
          layout.add(
            SizedBox(
              height: 10,
            ),
          );
        }
        layout.add(
          _renderFooter(),
        );
        break;
      case 1: //左文右图
        var rows = <Widget>[];
        if (!StringUtil.isEmpty(_doc.message.content)) {
          rows.add(
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 100,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _renderContent(),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                      ),
                      child: _renderFooter(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (_doc.medias.isNotEmpty) {
          rows.add(
            SizedBox(
              width: 150,
              height: 100,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10,
                ),
                child: _renderMedias(),
              ),
            ),
          );
        }
        layout.add(
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rows,
          ),
        );

        break;
      case 2: //左图右文
        var rows = <Widget>[];
        if (_doc.medias.isNotEmpty) {
          rows.add(
            SizedBox(
              width: 150,
              height: 100,
              child: Padding(
                padding: EdgeInsets.only(
                  right: 10,
                ),
                child: _renderMedias(),
              ),
            ),
          );
        }
        if (!StringUtil.isEmpty(_doc.message.content)) {
          rows.add(
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _renderContent(),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                      ),
                      child: _renderFooter(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        layout.add(
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rows,
          ),
        );
        break;
      default:
        print('未知布局! 消息:${_doc.message.id} ${_doc.message.content}');
        break;
    }
    layout.add(
      SizedBox(
        height: 20,
        child: Divider(
          height: 1,
        ),
      ),
    );
    return Container(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: layout,
      ),
    );
  }

  Widget _renderContent() {
    return Container(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _maxLines = _maxLines == 4 ? 10000 : 4;
          if (mounted) {
            setState(() {});
          }
        },
        child: Text(
          '${_doc.message.content ?? ''}',
          maxLines: _maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
//            letterSpacing: 0.8,
//            wordSpacing: 1.4,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _renderMedias() {
    return RecommenderMediaWidget(
      _doc.medias,
      widget.context,
    );
  }

  Widget _renderFooter() {
    var columns = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${TimelineUtil.format(
              _doc.message.ctime,
              dayFormat: DayFormat.Simple,
            )}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Row(
            children: <Widget>[
              FutureBuilder<Person>(
                future: _future_getPerson,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return SizedBox(
                      width: 0,
                      height: 0,
                    );
                  }
                  var person = snapshot.data;
                  if (person == null) {
                    return SizedBox(
                      width: 0,
                      height: 0,
                    );
                  }
                  return Text(
                    '${person?.nickName}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  );
                },
              ),
              SizedBox(
                width: 10,
              ),
              FutureBuilder<ContentBoxOR>(
                future: _future_getContentBox,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return SizedBox(
                      width: 0,
                      height: 0,
                    );
                  }
                  var box = snapshot.data;
                  if (box == null) {
                    return SizedBox(
                      width: 0,
                      height: 0,
                    );
                  }

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.context.forward('/chasechain/box',
                          arguments: {'box': box, 'pool': _doc.item.pool});
                    },
                    child: Wrap(
                      direction: Axis.horizontal,
                      spacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: <Widget>[
                        Icon(
                          _doc.message.type == 'netflow'
                              ? Icons.all_inclusive
                              : Icons.add_location,
                          size: 11,
                          color: Colors.grey,
                        ),
                        Text(
                          '${box.pointer.title}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FutureBuilder<ItemBehavior>(
                future: _future_getItemInnerBehavior,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done ||
                      snapshot.data == null) {
                    return SizedBox(
                      height: 0,
                      width: 0,
                    );
                  }
                  var behavior = snapshot.data;
                  return Row(
                    children: <Widget>[
                      Text(
                        '${parseInt(behavior.likes, 2)}个赞',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        '${parseInt(behavior.comments, 2)}个评',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(
                width: 5,
              ),
              FutureBuilder<TrafficPool>(
                future: _future_getPool,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return SizedBox(
                      width: 0,
                      height: 0,
                    );
                  }
                  var pool = snapshot.data;
                  if (pool == null) {
                    return SizedBox(
                      width: 0,
                      height: 0,
                    );
                  }
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (_doc.message.layout == 0) {
                        _isCollapsibled = !_isCollapsibled;
                        if (mounted) {
                          setState(() {});
                        }
                        return;
                      }
                      showModalBottomSheet(
                          context: context,
                          builder: (ctx) {
                            return CollapsiblePanel(
                              context: widget.context,
                              doc: _doc,
                              pool: pool,
                              usePopupLayout: true,
                              towncode: widget.towncode,
                            );
                          });
                    },
                    child: Wrap(
                      direction: Axis.horizontal,
                      spacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: <Widget>[
                        Icon(
                          Icons.pool,
                          size: 11,
                          color: pool.isGeosphere ? Colors.green : Colors.grey,
                        ),
                        Text(
                          '${pool.title}',
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                _isCollapsibled ? Colors.grey : Colors.blueGrey,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ];
    if (!_isCollapsibled) {
      columns.add(
        SizedBox(
          height: 10,
        ),
      );
      columns.add(
        FutureBuilder<TrafficPool>(
          future: _future_getPool,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return SizedBox(
                width: 0,
                height: 0,
              );
            }
            var pool = snapshot.data;
            if (pool == null) {
              return SizedBox(
                width: 0,
                height: 0,
              );
            }
            if (_doc.message.layout == 0) {
              return CollapsiblePanel(
                context: widget.context,
                doc: _doc,
                pool: pool,
                usePopupLayout: false,
                towncode: widget.towncode,
              );
            }
            return SizedBox(
              height: 0,
              width: 0,
            );
          },
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: columns,
    );
  }
}

Future<Person> _getPerson(IServiceProvider site, String person) async {
  IPersonService personService = site.getService('/gbera/persons');
  return await personService.getPerson(person);
}
