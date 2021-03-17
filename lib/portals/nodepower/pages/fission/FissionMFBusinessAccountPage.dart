import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/nodepower/remote/fission-mf-accounts.dart';
import 'package:netos_app/portals/nodepower/remote/fission-mf-records.dart';
import 'package:netos_app/system/local/entities.dart';

class FissionMFBusinessAccountPage extends StatefulWidget {
  PageContext context;

  FissionMFBusinessAccountPage({this.context});

  @override
  _FissionMFBusinessAccountPageState createState() =>
      _FissionMFBusinessAccountPageState();
}

class _FissionMFBusinessAccountPageState
    extends State<FissionMFBusinessAccountPage> {
  int _filter = 0; //0未分账；1已分账；-1所有
  EasyRefreshController _easyRefreshController = EasyRefreshController();
  bool _isLoading = true;
  FissionMFAccountOR _businessAccount;
  List<BusinessInRecord> _records = [];
  int _limit = 10, _offset = 0;
  Map<String, Person> _caches = {};

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _easyRefreshController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    IFissionMFAccountRemote accountRemote =
        widget.context.site.getService('/wallet/fission/mf/account');
    _businessAccount = await accountRemote.getBusinessAccount();
    await _loadRecords();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecords() async {
    IFissionMFRecordRemote recordRemote =
        widget.context.site.getService('/wallet/fission/mf/account/records');
    var records =
        await recordRemote.pageBusinessInRecord(_filter, _limit, _offset);
    if (records.isEmpty) {
      _easyRefreshController.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _offset += records.length;
    _records.addAll(records);
    if (mounted) {
      setState(() {});
    }
  }

  Future<Person> _loadPerson(String salesman) async {
    int pos = salesman.lastIndexOf('@');
    if (pos < 0) {
      salesman = '$salesman@gbera.netos';
    }
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    return await personService.getPerson(salesman);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, b) {
          return <Widget>[
            SliverAppBar(
              title: Text('营业账户'),
              elevation: 0,
              centerTitle: true,
              titleSpacing: 0,
              pinned: true,
              actions: [
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz,
                  ),
                  offset: Offset(
                    0,
                    50,
                  ),
                  onSelected: (value) async {
                    if (value == null) return;
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    PopupMenuItem(
                      value: 'partners',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              right: 10,
                            ),
                            child: Icon(
                              Icons.group,
                              color: Colors.grey[500],
                              size: 15,
                            ),
                          ),
                          Text(
                            '伙伴',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'bills',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              right: 10,
                            ),
                            child: Icon(
                              Icons.list_alt,
                              color: Colors.grey[500],
                              size: 15,
                            ),
                          ),
                          Text(
                            '账单',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: 20,
                bottom: 20,
              ),
              child: Column(
                children: [
                  Text(
                    '经营余额',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '¥',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        TextSpan(
                          text:
                              '${_isLoading ? '...' : ((_businessAccount.balance) / 100.00).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        TextSpan(
                          text: '元',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '进项',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      var filter = await showDialog(
                        context: context,
                        child: SimpleDialog(
                          title: Text('分账状态'),
                          elevation: 0,
                          children: [
                            DialogItem(
                              text: '全部',
                              onPressed: () {
                                widget.context.backward(result: -1);
                              },
                            ),
                            DialogItem(
                              text: '未分账',
                              onPressed: () {
                                widget.context.backward(result: 0);
                              },
                            ),
                            DialogItem(
                              text: '已分账',
                              onPressed: () {
                                widget.context.backward(result: 1);
                              },
                            ),
                          ],
                        ),
                      );
                      if (filter == null) {
                        return;
                      }
                      _filter = filter;
                      _offset = 0;
                      _records.clear();
                      _load();
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_renderFilter()}',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.filter_alt_outlined,
                          size: 25,
                          color: Colors.grey[700],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: EasyRefresh(
                  controller: _easyRefreshController,
                  onLoad: _loadRecords,
                  child: ListView(
                    children: _renderBusinessRecordList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _renderBusinessRecordList() {
    var items = <Widget>[];
    if (_isLoading) {
      items.add(
        Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
          ),
          alignment: Alignment.center,
          child: Text(
            '正在加载...',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
      return items;
    }
    if (_records.isEmpty) {
      items.add(
        Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
          ),
          alignment: Alignment.center,
          child: Text(
            '没有订单',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
      return items;
    }
    for (var record in _records) {
      var person = _caches['${record.person}@gbera.netos'];
      dynamic avatar;
      if (person != null) {
        avatar = InkWell(
          onTap: () {
            widget.context.forward('/person/view',
                arguments: {'person': person});
          },
          child: getAvatarWidget(person.avatar, widget.context),
        );
      } else {
        avatar = FutureBuilder<Person>(
          future: _loadPerson(record.person),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Icon(
                FontAwesomeIcons.moneyCheck,
                color: Colors.grey,
              );
            }
            var person = snapshot.data;
            if (person == null) {
              return Icon(
                FontAwesomeIcons.moneyCheck,
                color: Colors.grey,
              );
            }
            _caches[person.official] = person;
            return InkWell(
              onTap: () {
                widget.context.forward('/person/view',
                    arguments: {'person': person});
              },
              child: getAvatarWidget(person.avatar, widget.context),
            );
          },
        );
      }

      items.add(
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 15,
            bottom: 15,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                width: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: avatar,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              widget.context.forward('/person/view',
                                  arguments: {'person': person});
                            },
                            child: Text(
                              '${record.nickName ?? ''}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '单号：',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${record.sn}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '状态：',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${record.status}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  '${record.message}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          InkWell(
                            onTap: () {
                              widget.context.forward(
                                  '/wallet/fission/mf/record/recharge',
                                  arguments: {'sn': record.refsn});
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '充值单：',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${record.refsn}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueGrey,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              Text(
                                '伙伴：',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              _renderSalesman(record),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Column(
                      children: [
                        Text(
                          '¥${(record.amount / 100.00).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 25,
                              width: 70,
                              child: RaisedButton(
                                onPressed: () {},
                                padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                ),
                                color: Colors.green,
                                textColor: Colors.white,
                                child: Text(
                                  '分账',
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
      items.add(
        Divider(
          height: 1,
          indent: 70,
          color: Colors.grey[300],
        ),
      );
    }
    return items;
  }

  _renderFilter() {
    if (_filter == 0) {
      return '未分订单';
    }
    if (_filter == 1) {
      return '已分订单';
    }
    return '所有订单';
  }

  Widget _renderSalesman(BusinessInRecord record) {
    if (StringUtil.isEmpty(record.salesman)) {
      return Text(
        '无',
        style: TextStyle(
          color: Colors.blueGrey,
          decoration: TextDecoration.underline,
        ),
      );
    }
    var person = _caches['${record.salesman}@gbera.netos'];
    if (person != null) {
      return InkWell(
        onTap: () {
          widget.context.forward('/person/view', arguments: {'person': person});
        },
        child: Text(
          '${person.nickName}',
          style: TextStyle(
            color: Colors.blueGrey,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    }
    return FutureBuilder<Person>(
      future: _loadPerson(record.salesman),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Text(
            '...',
            style: TextStyle(
              color: Colors.blueGrey,
              decoration: TextDecoration.underline,
            ),
          );
        }
        var person = snapshot.data;
        if (person == null) {
          return Text(
            '不存在：${record.salesman}',
            style: TextStyle(
              color: Colors.blueGrey,
              decoration: TextDecoration.underline,
            ),
          );
        }
        _caches[person.official] = person;
        return InkWell(
          onTap: () {
            widget.context
                .forward('/person/view', arguments: {'person': person});
          },
          child: Text(
            '${person.nickName}',
            style: TextStyle(
              color: Colors.blueGrey,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      },
    );
  }
}
