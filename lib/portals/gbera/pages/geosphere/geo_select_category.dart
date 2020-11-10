import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
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
  GeoChannelPortalOR _portal;
  GeoChannelOR _selectedChannel;
  GeoCategoryOR _selectedCategory;
  GeoBrandOR _selectedBrand;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('选择类别'),
        titleSpacing: 0,
        actions: <Widget>[
          Builder(
            builder: (ctx) {
              return FlatButton(
                onPressed: _selectedChannel == null || _selectedCategory == null
                    ? null
                    : () {
                        widget.context
                            .forward('/geosphere/receptor/create', arguments: {
                          'category': _selectedCategory,
                          'channel': _selectedChannel,
                          'brand': _selectedBrand
                        });
                      },
                child: Text(
                  '下一步',
                  style: TextStyle(
                    color: _selectedChannel == null || _selectedCategory == null
                        ? null
                        : Colors.green,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _renderSelected(),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              constraints: BoxConstraints.expand(),
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                top: 10,
                bottom: 10,
              ),
              child: _renderChannelPortal(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderSelected() {
    if (_selectedChannel == null) {
      return SizedBox(
        height: 0,
        width: 0,
      );
    }
    var items = <Widget>[
      SizedBox(
        height: 30,
        width: 30,
        child: getAvatarWidget('${_selectedChannel.leading}', widget.context),
      ),
      Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          '${_selectedChannel.title}',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    ];
    if (_selectedCategory != null) {
      items.add(
        Padding(
          padding: EdgeInsets.only(
            left: 5,
            right: 5,
          ),
          child: Icon(
            Icons.arrow_right,
            size: 16,
          ),
        ),
      );
      items.add(
        Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            '${_selectedCategory.title}',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    if (_selectedBrand != null) {
      items.add(
        Padding(
          padding: EdgeInsets.only(
            left: 5,
            right: 5,
          ),
          child: Icon(
            Icons.arrow_right,
            size: 16,
          ),
        ),
      );
      items.add(
        Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            '${_selectedBrand.title}',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 10,
        top: 10,
      ),
      color: Colors.white,
      child: Row(
        children: items,
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
            _selectedChannel = _findChannel(c.channel);
            _selectedCategory = c;
            _selectedBrand = null;
            if (mounted) {
              setState(() {});
            }
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
            _selectedChannel = _findChannel(c.channel);
            _selectedCategory = _findCategory(c.channel, c.category);
            _selectedBrand = c;
            if (mounted) {
              setState(() {});
            }
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
              _selectedChannel = ch;
              _selectedCategory = c;
              _selectedBrand = null;
              if (mounted) {
                setState(() {});
              }
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
              _selectedChannel = list[0];
              _selectedCategory = list[1];
              _selectedBrand = b;
              if (mounted) {
                setState(() {});
              }
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
