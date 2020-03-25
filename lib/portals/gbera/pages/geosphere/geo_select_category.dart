import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class GeoSelectGeoCategory extends StatefulWidget {
  PageContext context;

  GeoSelectGeoCategory({this.context});

  @override
  _GeoSelectGeoCategoryState createState() => _GeoSelectGeoCategoryState();
}

class _GeoSelectGeoCategoryState extends State<GeoSelectGeoCategory> {
  EasyRefreshController _controller;
  List<GeoCategory> _categories = [];
  GeoCategory _selected;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _onload().then((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onload() async {
    IGeoCategoryRemote categoryService =
        widget.context.site.getService('/remote/geo/categories');
    _categories = await categoryService.listCategory();
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[];
    if (_categories.isEmpty) {
      items.add(
        Center(
          child: Text('正在加载...'),
        ),
      );
    } else {
      for (var cate in _categories) {
        bool isSelected = false;
        if (_selected != null && _selected.id == cate.id) {
          isSelected = true;
        }
        items.add(
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _selected = _selected != null
                  ? _selected.id == cate.id ? null : cate
                  : cate;
              setState(() {});
            },
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: CardItem(
                    title: cate.title,
                    paddingBottom: 20,
                    paddingTop: 20,
                    tail: isSelected
                        ? Icon(
                            Icons.check,
                            color: Colors.red,
                            size: 14,
                          )
                        : Icon(
                            Icons.remove,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                  ),
                ),
                Divider(
                  height: 1,
                ),
              ],
            ),
          ),
        );
      }
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('选择类别'),
        actions: <Widget>[
          Builder(
            builder: (ctx) {
              return FlatButton(
                onPressed: () {
                  if (_selected == null) {
                    Scaffold.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text('没有选中分类'),
                      ),
                    );
                    return;
                  }
                  widget.context.forward('/geosphere/receptor/create',
                      arguments: {'category': _selected});
                },
                child: Text('下一步'),
              );
            },
          ),
        ],
      ),
      body: EasyRefresh(
        controller: _controller,
        onLoad: _onload,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(0),
          children: items,
        ),
      ),
    );
  }
}
