import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
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
  GeoChannelPortalOR _portal;

  @override
  void initState() {
    _onload().then((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onload() async {
    IGeoCategoryRemote categoryService =
        widget.context.site.getService('/remote/geo/categories');
    _portal = await categoryService.getGeoPortal();
  }

  _select(GeoChannelOR channel, GeoCategoryOR geoCategory, GeoBrandOR brand) {
    widget.context.backward(result: [
      channel,
      geoCategory,
      brand,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '选择',
        ),
        titleSpacing: 0,
        centerTitle: true,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: Icon(
                Icons.clear,
              ),
              onPressed: () {
                widget.context.backward();
              }),
        ],
      ),
      body: Column(
        children: <Widget>[
         Expanded(child:  Container(
           color: Colors.white,
           constraints: BoxConstraints.expand(),
           padding: EdgeInsets.only(
             left: 15,
             right: 15,
             top: 10,
             bottom: 10,
           ),
           child: _renderChannelPortal(),
         ),),
          SizedBox(height: 1,),
          GestureDetector(
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
        ],
      ),
    );
  }

  Widget _renderChannelPortal() {
    if (_portal == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '加载中...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          _renderHots(),
          SizedBox(
            height: 10,
          ),
          _renderChannels(),
        ],
      ),
    );
  }

  Widget _renderHots() {
    var hotsCategories = _portal.hotCategories;
    var items = <Widget>[];
    for (var c in hotsCategories) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _select(_findChannel(c.channel),c,null);
          },
          child: Text(
            '${c.title}',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    var hotsBrands = _portal.hotBrands;
    for (var c in hotsBrands) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _select(_findChannel(c.channel),_findCategory(c.channel, c.category),c);
          },
          child: Text(
            '${c.title}',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Icon(
                FontAwesomeIcons.fire,
                color: Colors.red,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              '热门',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Wrap(
            spacing: 15,
            runSpacing: 15,
            children: items,
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget _renderChannels() {
    var channels = _portal.channels;
    var channelItems = <Widget>[];
    for (var ch in channels) {
      channelItems.add(_renderChannel(ch));
    }
    return Column(
      children: channelItems,
    );
  }

  Widget _renderChannel(GeoChannelOR ch) {
    var categories = ch.categories;
    var brands = <GeoBrandOR>[];
    var map = <String, List>{};
    var items = <Widget>[];
    for (var c in categories) {
      items.add(
        Padding(
          padding: EdgeInsets.only(
            left: 5,
            right: 5,
            top: 2,
            bottom: 2,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _select(ch, c,null);
            },
            child: Text(
              '${c.title}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
      var blist = c.brands;
      for (var item in blist) {
        brands.add(item);
        map[item.id] = [ch, c];
      }
    }
    for (var b in brands) {
      items.add(
        Padding(
          padding: EdgeInsets.only(
            left: 5,
            right: 5,
            top: 2,
            bottom: 2,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              var list = map[b.id];
              _select(list[0], list[1],b);
            },
            child: Text(
              '${b.title}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: getAvatarWidget(
                ch.leading,
                widget.context,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              '${ch.title}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Wrap(
            spacing: 15,
            runSpacing: 15,
            children: items,
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  GeoChannelOR _findChannel(String channel) {
    for (var ch in _portal.channels) {
      if (ch.id == channel) {
        return ch;
      }
    }
  }

  GeoCategoryOR _findCategory(String channel, String category) {
    for (var ch in _portal.channels) {
      if (ch.id != channel) {
        continue;
      }
      for (var cat in ch.categories) {
        if (cat.id == category) {
          return cat;
        }
      }
    }
  }
}
