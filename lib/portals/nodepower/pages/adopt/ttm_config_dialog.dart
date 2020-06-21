import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/nodepower/pages/adopt/wybank_form.dart';

class TtmConfigDialog extends StatefulWidget {
  PageContext context;

  TtmConfigDialog({this.context});

  @override
  _TtmConfigDialogState createState() => _TtmConfigDialogState();
}

class _TtmConfigDialogState extends State<TtmConfigDialog> {
  List<TtmInfo> _ttmConfig;

  @override
  void initState() {
    _ttmConfig = widget.context.page.parameters['ttmConfig'];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    if (_ttmConfig == null || _ttmConfig.isEmpty) {
      items.add(
        Center(
          child: Text('没有配置'),
        ),
      );
    } else {
      for (var ttm in _ttmConfig) {
        items.add(
          Slidable(
            actionPane: SlidableDrawerActionPane(),
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: '移除',
                foregroundColor: Colors.grey[500],
                icon: Icons.delete,
                onTap: () {
                  _ttmConfig.removeWhere((element) {
                    return element.ttm == ttm.ttm;
                  });
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
            ],
            child: Container(
              color: Colors.white,
              margin: EdgeInsets.only(
                bottom: 1,
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: CardItem(
                title:
                    '${ttm.ttm.toStringAsFixed(4)}/${ttm.minAmount}-${ttm.maxAmount}',
                tail: SizedBox(
                  height: 0,
                  width: 0,
                ),
              ),
            ),
          ),
        );
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('市盈率配置'),
        elevation: 0,
      ),
      body: Container(
        child: ListView(
          padding: EdgeInsets.only(
            top: 10,
          ),
          shrinkWrap: true,
          children: items,
        ),
      ),
    );
  }
}
