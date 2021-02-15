import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_record.dart';

class FissionMFPersonPage extends StatefulWidget {
  PageContext context;

  FissionMFPersonPage({this.context});

  @override
  _FissionMFPersonPageState createState() => _FissionMFPersonPageState();
}

class _FissionMFPersonPageState extends State<FissionMFPersonPage> {
  PayPersonOR _payPersonOR;
  List<FissionMFTagOR> _tags = [];

  @override
  void initState() {
    _payPersonOR = widget.context.parameters['record'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _load() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    var tags =
        await cashierRemote.listPropertyTagOfPerson(_payPersonOR.person.id);
    _tags.addAll(tags);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MediaQuery.removePadding(
            removeBottom: true,
            removeLeft: true,
            removeRight: true,
            context: context,
            child: AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.white,
              toolbarOpacity: 1,
              actions: <Widget>[],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 10,
              top: 10,
            ),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FadeInImage.assetNetwork(
                    width: 50,
                    height: 50,
                    placeholder: 'lib/portals/gbera/images/default_watting.gif',
                    image:
                        '${_payPersonOR.person.avatarUrl}?accessToken=${widget.context.principal.accessToken}',
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_payPersonOR.person.nickName}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                          '${_payPersonOR.payee == _payPersonOR.person.id ? '支出' : '收入'} ¥${(_payPersonOR.amount / 100.00).toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _renderPropTags(),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    widget.context.forward('/person/view', arguments: {
                      'official': '${_payPersonOR.person.id}@gbera.netos'
                    });
                  },
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('更多资料'),
                      ],
                    ),
                    color: Colors.white,
                    padding: EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderPropTags() {
    var items = <Widget>[];
    for (var tag in _tags) {
      items.add(
        Container(
          padding: EdgeInsets.only(
            left: 5,
            right: 5,
            top: 2,
            bottom: 2,
          ),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey[300]),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${tag.name}',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.only(
        left: 45,
        right: 15,
        top: 10,
        bottom: 10,
      ),
      color: Colors.white,
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      child: Row(
        children: [
          Text(
            '标签',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Wrap(
              spacing: 5,
              runSpacing: 5,
              children: items,
            ),
          ),
        ],
      ),
    );
  }
}
