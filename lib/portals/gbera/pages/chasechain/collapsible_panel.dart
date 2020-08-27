import 'package:common_utils/common_utils.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/cc_medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class CollapsiblePanel extends StatefulWidget {
  PageContext context;
  RecommenderDocument doc;
  TrafficPool pool;
  bool usePopupLayout;
  String towncode;

  CollapsiblePanel(
      {this.context, this.doc, this.pool, this.usePopupLayout, this.towncode});

  @override
  _CollapsiblePanelState createState() => _CollapsiblePanelState();
}

class _CollapsiblePanelState extends State<CollapsiblePanel> {
  bool _isShowCommentEditor = false;
  ItemBehavior _itemInnerBehavior;
  ItemBehavior _itemInnateBehavior;
  bool _isLiked;
  List<BehaviorDetails> _likes = [];
  List<BehaviorDetails> _comments = [];
  List<BehaviorDetails> _recommends = [];
  int _limit = 10;
  int _offset_likes = 0, _offset_comments = 0, _offset_recommends = 0;
  Map<String, Person> _cachePersons = {};
  bool _isDohaving = false;
  bool _isShowRecommends = false;
  List<_ContentItemDetail> _routeItemOnPools = [];
  ContentBoxOR _contentBox;
  Person _itemProvider;
  bool _isLoading = false;

  @override
  void initState() {
    () async {
      _isLoading = true;
      await _loadItemInnerBehavior();
      _isLiked = await _hasLike();
      await _loadLikes();
      await _loadComments();
      await _loadRoutePools();
      await _loadItemInnateBehavior(); //它依赖于流径
      await _loadContentBox();
      _isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didUpdateWidget(CollapsiblePanel oldWidget) {
    if (oldWidget.doc.item.id != widget.doc.item.id) {
      oldWidget.doc = widget.doc;
    }
    if (oldWidget.pool.id != widget.pool.id) {
      oldWidget.pool = widget.pool;
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadRoutePools() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    var pool = widget.doc.item.upstreamPool;
    if (StringUtil.isEmpty(pool)) {
      return;
    }
    return await __loadRoutePools(recommender, pool, widget.doc.item.id);
  }

  Future<void> __loadRoutePools(IChasechainRecommenderRemote recommender,
      String poolid, String item) async {
    var pool = await recommender.getTrafficPool(poolid);
    if (pool == null) {
      return;
    }
    var upstreamItem = await recommender.getContentItem(pool.id, item);
    if (upstreamItem == null) {
      return;
    }
    var behavior =
        await recommender.getItemInnerBehavior(pool.id, upstreamItem.id);
    _routeItemOnPools.add(
      _ContentItemDetail(
        item: upstreamItem,
        pool: pool,
        behavior: behavior,
      ),
    );
    var upstreamPool = upstreamItem.upstreamPool;
    if (!StringUtil.isEmpty(upstreamPool)) {
      await __loadRoutePools(recommender, pool.id, item);
    }
  }

  Future<void> _loadContentBox() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    var _doc = widget.doc;
    _contentBox =
        await recommender.getContentBox(_doc.item.pool, _doc.item.box);
    _itemProvider =
        await _getPerson(widget.context.site, _contentBox.pointer.creator);
  }

  Future<void> _loadItemInnerBehavior() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    _itemInnerBehavior = await recommender.getItemInnerBehavior(
        widget.doc.item.pool, widget.doc.item.id);
  }

  Future<bool> _hasLike() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    int has = await recommender.hasBehave(
        widget.doc.item.pool, widget.doc.item.id, 'like');
    return has > 0;
  }

  Future<void> _doBehave(String behave, String attachment) async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    await recommender.doBehave(
        widget.doc.item.pool, widget.doc.item.id, behave, attachment);
  }

  Future<void> _undoBehave(String behave) async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    await recommender.undoBehave(
        widget.doc.item.pool, widget.doc.item.id, behave);
  }

  Future<void> _loadLikes() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    List<BehaviorDetails> details = await recommender.pageBehave(
        widget.doc.item.pool,
        widget.doc.item.id,
        'like',
        _limit,
        _offset_likes);
    if (details.isEmpty) {
      return;
    }
    for (var detail in details) {
      var person = await _getPerson(widget.context.site, detail.person);
      if (person != null && !_cachePersons.containsKey(person)) {
        _cachePersons[person.official] = person;
      }
      _likes.add(detail);
    }
    _offset_likes += details.length;
  }

  Future<void> _loadComments() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    List<BehaviorDetails> details = await recommender.pageBehave(
        widget.doc.item.pool,
        widget.doc.item.id,
        'comment',
        _limit,
        _offset_comments);
    if (details.isEmpty) {
      return;
    }
    for (var detail in details) {
      var person = await _getPerson(widget.context.site, detail.person);
      if (person != null && !_cachePersons.containsKey(person)) {
        _cachePersons[person.official] = person;
      }
      _comments.add(detail);
    }
    _offset_comments += details.length;
  }

  Future<void> _loadRecommends() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    List<BehaviorDetails> details = await recommender.pageBehave(
        widget.doc.item.pool,
        widget.doc.item.id,
        'recommend',
        _limit,
        _offset_recommends);
    if (details.isEmpty) {
      return;
    }
    for (var detail in details) {
      var person = await _getPerson(widget.context.site, detail.person);
      if (person != null && !_cachePersons.containsKey(person)) {
        _cachePersons[person.official] = person;
      }
      _recommends.add(detail);
    }
    _offset_recommends += details.length;
  }

  Future<void> _loadItemInnateBehavior() async {
    IChasechainRecommenderRemote recommender =
        widget.context.site.getService('/remote/chasechain/recommender');
    TrafficPool pool;
    if (_routeItemOnPools.isEmpty) {
      pool = widget.pool;
    } else {
      pool = _routeItemOnPools[_routeItemOnPools.length - 1]?.pool;
    }
    _itemInnateBehavior =
        await recommender.getItemInnateBehavior(pool.id, widget.doc.item.id);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          top: 20,
          bottom: 20,
        ),
        child: Text(
          '加载中...',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      );
    }
    var body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: widget.usePopupLayout ? 0 : 10,
        ),
        _getCurrentPoolPanel(),
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.only(
            left: 10,
          ),
          child: Text(
            '来源',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        _getSourcePanel(),
        SizedBox(
          height: 20,
        ),
        _routeItemOnPools.isEmpty
            ? SizedBox(
                height: 0,
              )
            : Container(
                padding: EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  '流径',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
        SizedBox(
          height: _routeItemOnPools.isEmpty ? 0 : 10,
        ),
        _getRoutePoolPanel(),
      ],
    );
    if (!widget.usePopupLayout) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white70,
//          borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8)),
        ),
        padding: EdgeInsets.only(
          right: 10,
          left: 0,
          bottom: 15,
        ),
        child: body,
      );
    }
    var content = widget.doc.message.content;
    return Scaffold(
      appBar: AppBar(
        leading: StringUtil.isEmpty(widget.pool.icon)
            ? SizedBox(
                width: 30,
                height: 30,
                child: Icon(
                  Icons.pool,
                  size: 20,
                  color:
                      widget.pool.isGeosphere ? Colors.green : Colors.grey[600],
                ),
              )
            : ClipRect(
                child: Image.network(
                  '${widget.pool.icon}?accessToken=${widget.context.principal.accessToken}',
                  height: 20,
                  width: 20,
                ),
              ),
        titleSpacing: 0,
        title: Text('${widget.pool.title}'),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _isShowCommentEditor = !_isShowCommentEditor;
              if (mounted) {
                setState(() {});
              }
            },
            icon: Icon(
              Icons.add_comment,
              color: Colors.black54,
              size: 16,
            ),
          ),
          IconButton(
            onPressed: _isDohaving
                ? null
                : () async {
                    if (_isDohaving) {
                      return;
                    }
                    try {
                      _isDohaving = true;
                      if (mounted) {
                        setState(() {});
                      }
                      if (await _hasLike()) {
                        await _undoBehave('like');
                      } else {
                        await _doBehave("like", null);
                      }
                      _isLiked = await _hasLike();
                      await _loadItemInnerBehavior();
                      _offset_likes = 0;
                      _likes.clear();
                      await _loadLikes();
                    } finally {
                      _isDohaving = false;
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  },
            icon: Icon(
              FontAwesomeIcons.thumbsUp,
              size: 16,
              color: _isLiked ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: 0,
          left: 10,
          right: 15,
          bottom: 30,
        ),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(
                bottom: 15,
                left: 32,
                right: 32,
              ),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Text(
                '$content',
                style: TextStyle(
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            body,
          ],
        ),
      ),
    );
  }

  Widget _getCurrentPoolPanel() {
    var columns = <Widget>[];
    if (!widget.usePopupLayout) {
      columns.add(
        Row(
          children: <Widget>[
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 2,
                    ),
                    child: StringUtil.isEmpty(widget.pool.icon)
                        ? SizedBox(
                            width: 30,
                            height: 30,
                            child: Icon(
                              Icons.pool,
                              size: 20,
                              color: widget.pool.isGeosphere
                                  ? Colors.green
                                  : Colors.grey[600],
                            ),
                          )
                        : ClipRect(
                            child: Image.network(
                              '${widget.pool.icon}?accessToken=${widget.context.principal.accessToken}',
                              height: 20,
                              width: 20,
                            ),
                          ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.context
                          .forward('/chasechain/traffic/pools', arguments: {
                        'towncode': widget.towncode,
                        'pool': widget.pool.id,
                      });
                    },
                    child: Text(
                      '${widget.pool.title}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _isShowCommentEditor = !_isShowCommentEditor;
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 15,
                    ),
                    child: Icon(
                      Icons.add_comment,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _isDohaving
                      ? null
                      : () async {
                          if (_isDohaving) {
                            return;
                          }
                          try {
                            _isDohaving = true;
                            if (mounted) {
                              setState(() {});
                            }
                            if (await _hasLike()) {
                              await _undoBehave('like');
                            } else {
                              await _doBehave("like", null);
                            }
                            _isLiked = await _hasLike();
                            await _loadItemInnerBehavior();
                            _offset_likes = 0;
                            _likes.clear();
                            await _loadLikes();
                          } finally {
                            _isDohaving = false;
                            if (mounted) {
                              setState(() {});
                            }
                          }
                        },
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 15,
                    ),
                    child: Icon(
                      FontAwesomeIcons.thumbsUp,
                      size: 16,
                      color: _isLiked ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      columns.add(
        SizedBox(
          height: 15,
        ),
      );
    }
    columns.add(
      Padding(
        padding: EdgeInsets.only(
          left: 15,
        ),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    right: 5,
                  ),
                  child: Icon(
                    Icons.remove_red_eye,
                    size: 12,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                        text: '已推荐给 ',
                        children: [
                          TextSpan(
                              text:
                                  '${parseInt(_itemInnerBehavior.recommends, 2)} 个人'),
                        ],
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            _isShowRecommends = !_isShowRecommends;
                            _offset_recommends = 0;
                            _recommends.clear();
                            await _loadRecommends();
                            if (mounted) setState(() {});
                          }),
                    style: TextStyle(
                      fontSize: 12,
                      color: _isShowRecommends ? Colors.blueGrey : null,
                      decoration: TextDecoration.underline,
                      fontWeight:
                          _isShowRecommends ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: !_isShowRecommends || _itemInnerBehavior.recommends == 0
                  ? 0
                  : 5,
            ),
            !_isShowRecommends || _itemInnerBehavior.recommends == 0
                ? SizedBox(
                    height: 0,
                    width: 0,
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: '> ',
                            children: _getRecommendSpanList(),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(
              height: _itemInnerBehavior.likes == 0 ? 0 : 10,
            ),
            _itemInnerBehavior.likes == 0
                ? SizedBox(
                    height: 0,
                    width: 0,
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Icon(
                          FontAwesomeIcons.thumbsUp,
                          size: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: '',
                            children: _getLikeSpanList(),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(
              height: _itemInnerBehavior.comments == 0 ? 0 : 10,
            ),
            _itemInnerBehavior.comments == 0
                ? SizedBox(
                    height: 0,
                    width: 0,
                  )
                : Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: 5,
                                  ),
                                  child: Icon(
                                    Icons.mode_comment,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${parseInt(_itemInnerBehavior.comments, 2)}个评论',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: _getCommentList(),
                      ),
                    ],
                  ),
            SizedBox(
              height: _isShowCommentEditor ? 20 : 0,
            ),
            _getCommentEditor(),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  '入池 ${TimelineUtil.format(widget.doc.item.ctime, dayFormat: DayFormat.Simple)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return Column(
      children: columns,
    );
  }

  List<TextSpan> _getRecommendSpanList() {
    var spans = <TextSpan>[];
    for (var recommend in _recommends) {
      var person = _cachePersons[recommend.person];
      spans.add(
        TextSpan(
          text: '${person?.nickName ?? recommend.person}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()..onTap=(){
            widget.context.forward('/chasechain/provider',
                arguments: {
                  'provider': person.official,
                  'pool': widget.pool.id,
                });
          },
        ),
      );
      spans.add(
        TextSpan(
          text: '; ',
        ),
      );
    }
    if (_itemInnerBehavior.recommends > _offset_recommends) {
      spans.add(
        TextSpan(
          text: '，',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      );
      spans.add(
        TextSpan(
          text: '更多',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _loadRecommends().then((value) {
                if (mounted) {
                  setState(() {});
                }
              });
            },
        ),
      );
    }
    return spans;
  }

  List<TextSpan> _getLikeSpanList() {
    var spans = <TextSpan>[];
    for (var like in _likes) {
      var person = _cachePersons[like.person];
      spans.add(
        TextSpan(
          text: '${person?.nickName ?? like.person}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            decoration: TextDecoration.underline,
          ),
            recognizer: TapGestureRecognizer()..onTap=() {
              widget.context.forward('/chasechain/provider',
                  arguments: {
                    'provider': person.official,
                    'pool': widget.pool.id,
                  });
            },
        ),
      );
      spans.add(
        TextSpan(
          text: '; ',
        ),
      );
    }
    spans.add(
      TextSpan(
        text: '共${parseInt(_itemInnerBehavior.likes, 2)}个人很赞',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.grey,
//          decoration: TextDecoration.underline,
        ),
      ),
    );
    if (_itemInnerBehavior.likes > _offset_likes) {
      spans.add(
        TextSpan(
          text: '，',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      );
      spans.add(
        TextSpan(
          text: '更多',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _loadLikes().then((value) {
                if (mounted) {
                  setState(() {});
                }
              });
            },
        ),
      );
    }
    return spans;
  }

  List<Widget> _getCommentList() {
    var commends = <Widget>[];
    for (var comment in _comments) {
      var isMe = comment.person == widget.context.principal.person;
      var person = _cachePersons[comment.person];
      commends.add(
        Padding(
          padding: EdgeInsets.only(
            left: 18,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: '${person?.nickName ?? comment.person}: ',
                    recognizer: TapGestureRecognizer()..onTap=() {
                      widget.context.forward('/chasechain/provider',
                          arguments: {
                            'provider': person.official,
                            'pool': widget.pool.id,
                          });
                    },
                    children: [
                      TextSpan(
                        text: '${comment.attachment ?? ''}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text:
                            '  ${TimelineUtil.format(comment.ctime, dayFormat: DayFormat.Simple)}  ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                      !isMe
                          ? TextSpan(text: '')
                          : TextSpan(
                              text: '删除',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _undoBehave('comment').then((value) async {
                                    _offset_comments = 0;
                                    _comments.clear();
                                    await _loadItemInnerBehavior();
                                    await _loadComments();
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  });
                                },
                            ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      commends.add(
        SizedBox(
          height: 6,
        ),
      );
    }
    if (_itemInnerBehavior.comments > _offset_comments) {
      commends.add(
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _loadComments().then((value) {
                if (mounted) {
                  setState(() {});
                }
              });
            },
            child: Text(
              '更多',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
        ),
      );
    }
    return commends;
  }

  Widget _getCommentEditor() {
    if (!_isShowCommentEditor) {
      return SizedBox(
        height: 0,
        width: 0,
      );
    }
    return _CommentEditor(
      context: widget.context,
      onCloseWin: () {
        _isShowCommentEditor = false;
        if (mounted) {
          setState(() {});
        }
      },
      onFinished: (v) {
        if (StringUtil.isEmpty(v)) {
          return;
        }
        _doBehave('comment', v).then((value) async {
          _isShowCommentEditor = false;
          _offset_comments = 0;
          _comments.clear();
          await _loadItemInnerBehavior();
          await _loadComments();
          if (mounted) {
            setState(() {});
          }
        });
      },
    );
  }

  Widget _getSourcePanel() {
    var columns = <Widget>[];
    columns.add(
      Padding(
        padding: EdgeInsets.only(
          left: 30,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward('/chasechain/provider', arguments: {
                  'provider': widget.doc.item.pointer.creator,
                  'pool': widget.doc.item.pool
                });
              },
              child: Text(
                '${_itemProvider?.nickName ?? ''}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              '的${_contentBox.pointer.type.startsWith('geo.receptor') ? '地理感知器' : '网流管道'}:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              width: 4,
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget.context.forward(
                          '/chasechain/box',
                          arguments: {
                            'box': _contentBox,
                            'pool': widget.pool.id
                          },
                        );
                      },
                      child: Text(
                        '${_contentBox?.pointer?.title ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${parseInt(_itemInnateBehavior.likes, 2)}个赞',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '${parseInt(_itemInnateBehavior.comments, 2)}个评',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
      ),
      child: Column(
        children: columns,
      ),
    );
  }

  Widget _getRoutePoolPanel() {
    var columns = <Widget>[];
    for (var i = 0; i < _routeItemOnPools.length; i++) {
      var detail = _routeItemOnPools[i];
      columns.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '${TimelineUtil.format(detail.item.ctime, dayFormat: DayFormat.Simple)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: 10,
                left: 10,
              ),
              child: Text(
                '发布到',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        right: 2,
                      ),
                      child: StringUtil.isEmpty(detail.pool.icon)
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: Icon(
                                Icons.pool,
                                size: 16,
                                color: detail.pool.isGeosphere
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            )
                          : ClipRect(
                              child: Image.network(
                                '${detail.pool.icon}?accessToken=${widget.context.principal.accessToken}',
                                height: 20,
                                width: 20,
                              ),
                            ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget.context
                            .forward('/chasechain/traffic/pools', arguments: {
                          'towncode': widget.towncode,
                          'pool': detail.pool.id,
                        });
                      },
                      child: Text(
                        '${detail.pool.title}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 2,
                ),
                Text.rich(
                  TextSpan(
                    text: '',
                    children: [
                      TextSpan(text: ' '),
                      TextSpan(
                        text:
                            '${parseInt(detail.behavior?.recommends ?? 0, 2)}个荐',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      TextSpan(
                        text: '${parseInt(detail.behavior?.likes ?? 0, 2)}个赞',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      TextSpan(text: ' '),
                      TextSpan(
                        text:
                            '${parseInt(detail.behavior?.comments ?? 0, 2)}个评',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
      if (i < _routeItemOnPools.length - 1) {
        columns.add(
          SizedBox(
            height: 10,
            child: Divider(
              height: 1,
            ),
          ),
        );
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
      ),
      child: Column(
        children: columns,
      ),
    );
  }
}

class _CommentEditor extends StatefulWidget {
  void Function(String content) onFinished;
  void Function() onCloseWin;
  PageContext context;

  _CommentEditor({this.context, this.onFinished, this.onCloseWin});

  @override
  __CommentEditorState createState() => __CommentEditorState();
}

class __CommentEditorState extends State<_CommentEditor> {
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            //解决了无法计算边界问题
            fit: FlexFit.tight,
            child: ExtendedTextField(
              controller: _controller,
              autofocus: true,
              onSubmitted: (v) {
                print(v);
              },
              onEditingComplete: () {
                print('----');
              },
              style: TextStyle(
                fontSize: 14,
              ),
              maxLines: 50,
              minLines: 4,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixText: '说道>',
                prefixStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                labelText:
                    '${widget.context.principal.nickName ?? widget.context.principal.accountCode}',
                labelStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
                fillColor: Colors.white,
                filled: true,
                hintText: '输入您的评论',
                hintStyle: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.check,
                  size: 14,
                ),
                onPressed: () async {
                  if (widget.onFinished != null) {
                    await widget.onFinished(_controller.text);
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 14,
                ),
                onPressed: () async {
                  _controller.text = '';
                  if (widget.onCloseWin != null) {
                    await widget.onCloseWin();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContentItemDetail {
  ContentItemOR item;
  TrafficPool pool;
  ItemBehavior behavior;

  _ContentItemDetail({this.item, this.pool, this.behavior});
}

Future<Person> _getPerson(IServiceProvider site, String person) async {
  IPersonService personService = site.getService('/gbera/persons');
  return await personService.getPerson(person);
}
