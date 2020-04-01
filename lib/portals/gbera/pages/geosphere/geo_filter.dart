import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class GeoFilter extends StatefulWidget {
  PageContext context;

  GeoFilter({this.context});

  @override
  _GeoFilterState createState() => _GeoFilterState();
}

class _GeoFilterState extends State<GeoFilter> {
  List<GeoCategoryOR> _categories = [];
  GeoCategoryOL _categoryOL;

  @override
  void initState() {
    _categoryOL = widget.context.page.parameters['category'];
    _loadCategories().then((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _categoryOL = null;
    _categories.clear();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    IGeoCategoryRemote categoryRemote =
        widget.context.site.getService('/remote/geo/categories');
    _categories = await categoryRemote.listCategory();
  }

  @override
  Widget build(BuildContext context) {
    var data = <_Category>[];
    for (var category in _categories) {
      data.add(
        _Category(
          id: category.id,
          title: '${category.title ?? ''}',
          count: 247,
          moveMode: category.moveMode,
          icon: Image.network(
            '${category.leading}?accessToken=${widget.context.principal.accessToken}',
            width: 20,
            height: 20,
          ),
        ),
      );
    }
    var slivers = <Widget>[];
    for (var v in data) {
      slivers.add(
        SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
//                      boxShadow: [
//                        BoxShadow(
//                          color: Colors.grey,
//                          offset: Offset(0, 10),
//                          blurRadius: 10,
//                          spreadRadius: -9,
//                        ),
//                      ],
//                      borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: CardItem(
                  title: v.title,
//                      tipsText: '${v.count}个',
                  leading: v.icon,
                  onItemTap: () {
                    widget.context.backward(result: {
                      'category': v.id,
                      'title': v.title,
                      'moveMode': v.moveMode,
                    });
                  },
                ),
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
              ),
              Container(
                height: 10,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '选择',
        ),
        titleSpacing: 0,
        centerTitle: true,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            widget.context.backward();
          },
          icon: Icon(
            Icons.clear,
            size: 18,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: slivers,
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.backward(result: 'clear');
              },
              child: Container(
                height: 60,
                color: Colors.white,
                alignment: Alignment.center,
                child: Text(
                  '清除选择',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

class _Category {
  String id;
  String title;
  int count;
  Widget icon;
  GeoCategoryMoveableMode moveMode;

  _Category({this.id, this.title, this.count, this.icon, this.moveMode});
}
