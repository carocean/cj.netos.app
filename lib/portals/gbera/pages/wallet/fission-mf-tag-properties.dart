import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';

class FissionMFTagPropertiesPage extends StatefulWidget {
  PageContext context;

  FissionMFTagPropertiesPage({this.context});

  @override
  _FissionMFTagPropertiesPageState createState() =>
      _FissionMFTagPropertiesPageState();
}

class _FissionMFTagPropertiesPageState
    extends State<FissionMFTagPropertiesPage> {
  List<FissionMFTagOR> _selected = [];
  List<FissionMFTagOR> _tags = [];

  @override
  void initState() {
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
    var tags = await cashierRemote.listAllTag();
    _tags.addAll(tags);
    var selected = await cashierRemote.listMyPropertyTag();
    _selected.addAll(selected);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _addPropertyTag(String tagId) async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    await cashierRemote.addPropertyTag(tagId);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _removePropertyTag(String tagId) async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    await cashierRemote.removePropertyTag(tagId);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('兴趣标签'),
        elevation: 0,
        titleSpacing: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Wrap(
              spacing: 15,
              runSpacing: 10,
              alignment: WrapAlignment.start,
              children: _selected.map((e) {
                return _renderTagPanel(e, true);
              }).toList(),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: 10,
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 15,
                  runSpacing: 10,
                  children: _tags.map((e) {
                    return _renderTagPanel(e, false);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderTagPanel(FissionMFTagOR tag, bool isSel) {
    if (isSel) {
      return InkWell(
        onTap: () {
          for (var i = 0; i < _selected.length; i++) {
            var selTag = _selected[i];
            if (selTag.id == tag.id) {
              _removePropertyTag(tag.id).then((value) {
                _selected.removeAt(i);
              });
              break;
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300], width: 1),
            borderRadius: BorderRadius.circular(4),
            color: Colors.green,
          ),
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            top: 2,
            bottom: 2,
          ),
          child: Text(
            '${tag.name ?? ''}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    return InkWell(
      onTap: () {
        bool exists = false;
        for (var i = 0; i < _selected.length; i++) {
          var selTag = _selected[i];
          if (selTag.id == tag.id) {
            _removePropertyTag(tag.id).then((value) {
              _selected.removeAt(i);
            });
            exists = true;
            break;
          }
        }
        if (!exists) {
          _addPropertyTag(tag.id).then((value) {
            _selected.add(tag);
          });
        }
        if (mounted) {
          setState(() {});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300], width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.only(
          left: 8,
          right: 8,
          top: 2,
          bottom: 2,
        ),
        child: Text(
          '${tag.name ?? ''}',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
