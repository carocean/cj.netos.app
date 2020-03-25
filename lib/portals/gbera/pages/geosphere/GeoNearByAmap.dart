import 'package:amap_search_fluttify/amap_search_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';

class GeoNearByAmapPOI extends StatefulWidget {
  PageContext context;

  GeoNearByAmapPOI({this.context});

  @override
  _GeoNearByAmapPOIState createState() => _GeoNearByAmapPOIState();
}

class _GeoNearByAmapPOIState extends State<GeoNearByAmapPOI> {
  List<GeoPoi> _poiList = [];
  GeoPoi _selectedPoi;

  @override
  void initState() {
    _searchPOI().then((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _poiList.clear();
    super.dispose();
  }

//type: '汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施',
  Future<void> _searchPOI() async {
    _selectedPoi = widget.context.parameters['poi'];

    /// 搜索周边poi
    final poiList = await AmapSearch.searchAround(
      _selectedPoi.latLng,
      type:
          '汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施',
      radius: 20000,
    );
    for (var poi in poiList) {
      var address = await poi.address;
      var distance = await poi.distance;
      var title = await poi.title;
      var poiId = await poi.poiId;
      var lat = await poi.latLng;
      _poiList.add(
        GeoPoi(
          title: title,
          distance: distance,
          address: address,
          latLng: lat,
          poiId: poiId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选择'),
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 20,
              bottom: 20,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[500],
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 5,
                      right: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _selectedPoi?.title ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        StringUtil.isEmpty(_selectedPoi?.address)
                            ? Container(
                                width: 0,
                                height: 0,
                              )
                            : Text(
                                _selectedPoi?.address ?? '',
                                softWrap: true,
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 0,
                  bottom: 0,
                ),
                children: _items(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _items() {
    List<Widget> items = [];
    if (_poiList.isEmpty) {
      items.add(Center(
        child: Text('加载中...'),
      ));
    } else {
      for (var item in _poiList) {
        items.add(
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.backward(result: {'poi': item});
            },
            child: Column(
              children: <Widget>[
                CardItem(
                  title: item.title,
                  tipsText:
                      '${item.distance < 1000 ? '${item.distance}米' : '${(item.distance / 1000.0).toStringAsFixed(3)}公里'}',
                  subtitle: StringUtil.isEmpty(item.address)
                      ? null
                      : Padding(
                          padding: EdgeInsets.only(
                            left: 0,
                          ),
                          child: Text(
                            item.address,
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
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
    return items;
  }
}
