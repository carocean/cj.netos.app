import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:city_pickers/city_pickers.dart';
import 'package:city_pickers/meta/province.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';

import 'fission-mf-tag-around.dart';

class FissionMFTagConditionPage extends StatefulWidget {
  PageContext context;

  FissionMFTagConditionPage({this.context});

  @override
  _FissionMFTagConditionPageState createState() =>
      _FissionMFTagConditionPageState();
}

class _FissionMFTagConditionPageState extends State<FissionMFTagConditionPage> {
  List<FissionMFTagOR> _tags = [];
  List<FissionMFTagOR> _propTags = [];
  List<FissionMFTagOR> _selectedTags = [];
  Location _location;
  String _provinceCode;
  String _provinceName;
  String _cityCode;
  String _cityName;
  FissionMFLimitAreaOR _settedArea;
  String _direct;
  @override
  void initState() {
    _direct=widget.context.parameters['direct'];
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
    var propTags = await cashierRemote.listMyPropertyTag();
    for (var tag in propTags) {
      if (!StringUtil.isEmpty(tag.opposite)) {
        var opposite = await cashierRemote.getTag(tag.opposite);
        if (opposite != null) {
          _propTags.add(opposite);
          continue;
        }
      }
      _propTags.add(tag);
    }
    var selected = await cashierRemote.listLimitTag(_direct);
    _selectedTags.addAll(selected);
    _location = await geoLocation.location;
    _provinceName = _location.province;
    _provinceCode = findProvinceCode(_location.province);
    _cityName = _location.city;
    _cityCode = findCityCode(_provinceCode, _location.city);
    _settedArea = await cashierRemote.getLimitArea(_direct);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _setLimitArea(String direct,
      {areaType, areaTitle, areaCode}) async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    await cashierRemote.setLimitArea(direct, areaType, areaTitle, areaCode);
    _settedArea = await cashierRemote.getLimitArea(direct);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _emptyLimitArea() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    await cashierRemote.emptyLimitArea(_settedArea.direct);
    _settedArea = await cashierRemote.getLimitArea(_settedArea.direct);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _addLimitTag(FissionMFTagOR tag) async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    await cashierRemote.addLimitTag(tag.id, _direct);
    var selected = await cashierRemote.listLimitTag(_direct);
    _selectedTags.clear();
    _selectedTags.addAll(selected);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _removeLimitTag(String tagId) async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    await cashierRemote.removeLimitTag(tagId, _direct);
    var selected = await cashierRemote.listLimitTag(_direct);
    _selectedTags.clear();
    _selectedTags.addAll(selected);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('条件设置'),
        elevation: 0,
        titleSpacing: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300],
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(10),
            child: Stack(
              overflow: Overflow.visible,
              children: [
                Column(
                  children: [
                    ...renderSettedArea(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FlatButton(
                          textColor: Colors.blueGrey,
                          onPressed: () async {
                            var result = await showModalBottomSheet(
                                context: context,
                                builder: (ctx) {
                                  return FissionMFAroundDialog(
                                    context: widget.context,
                                  );
                                });
                            if (result == null) {
                              return;
                            }
                            var range = result as AroundRange;
                            _setLimitArea(_direct,
                                areaCode: range.id,
                                areaTitle: range.label,
                                areaType: 'around');
                          },
                          child: Text(
                            '周边',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        FlatButton(
                          textColor: Colors.blueGrey,
                          onPressed: () async {
                            var result = await CityPickers.showCityPicker(
                              context: context,
                              confirmWidget: FlatButton(
                                child: Text(
                                  '确认',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              cancelWidget: FlatButton(
                                child: Text(
                                  '取消',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              showType: ShowType.p,
                              locationCode: _provinceCode,
                            );
                            if (result == null) {
                              return;
                            }
                            _provinceName = result.provinceName;
                            _provinceCode = result.provinceId;
                            _cityName = null;
                            _cityCode = null;
                            if (mounted) {
                              setState(() {});
                            }
                            _setLimitArea(_direct,
                                areaCode: result.provinceId,
                                areaTitle: result.provinceName,
                                areaType: 'province');
                          },
                          child: Text(
                            '省',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        FlatButton(
                          textColor: Colors.blueGrey,
                          onPressed: () async {
                            var result = await CityPickers.showCityPicker(
                              context: context,
                              confirmWidget: FlatButton(
                                child: Text(
                                  '确认',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              cancelWidget: FlatButton(
                                child: Text(
                                  '取消',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              showType: ShowType.pc,
                              locationCode: _cityCode ?? _provinceCode,
                            );
                            if (result == null) {
                              return;
                            }
                            _provinceName = result.provinceName;
                            _provinceCode = result.provinceId;
                            _cityName = result.cityName;
                            _cityCode = result.cityId;
                            if (mounted) {
                              setState(() {});
                            }
                            _setLimitArea(_direct,
                                areaCode:
                                    '${result.provinceId}·${result.cityId}',
                                areaTitle:
                                    '${result.provinceName}·${result.cityName}',
                                areaType: 'city');
                          },
                          child: Text(
                            '市',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  left: 5,
                  top: -20,
                  child: Text(
                    '限定到指定区域',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '限定兴趣',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                ..._renderSelectedTagsBox(),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                top: 10,
                bottom: 10,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('推荐：'),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Wrap(
                          runSpacing: 10,
                          spacing: 10,
                          children: _propTags.map((e) {
                            return _renderTagPanel(e);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('更多：'),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              runSpacing: 10,
                              spacing: 10,
                              alignment: WrapAlignment.start,
                              children: _renderMoreTags(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _renderMoreTags() {
    var items = <Widget>[];
    for (var tag in _tags) {
      var found = false;
      for (var exists in _propTags) {
        if (tag.id == exists.id) {
          found = true;
          break;
        }
      }
      if (!found) {
        items.add(_renderTagPanel(tag));
      }
    }
    return items;
  }

  Widget _renderTagPanel(FissionMFTagOR tag) {
    return InkWell(
      onTap: () {
        _addLimitTag(tag);
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

  List<Widget> _renderSelectedTagsBox() {
    if (_selectedTags.isEmpty) {
      return [];
    }
    var items = <Widget>[];
    for (var tag in _selectedTags) {
      items.add(_renderSelectedTagPanel(tag));
    }
    return <Widget>[
      SizedBox(
        height: 10,
      ),
      Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 20,
        ),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items,
        ),
      ),
    ];
  }

  Widget _renderSelectedTagPanel(FissionMFTagOR tag) {
    return InkWell(
      onTap: () {
        _removeLimitTag(tag.id);
      },
      child: Stack(
        overflow: Overflow.visible,
        children: [
          Container(
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
          Positioned(
            right: -5,
            top: -5,
            child: Icon(
              Icons.close,
              color: Colors.red,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> renderSettedArea() {
    if (_settedArea == null) {
      return <Widget>[];
    }
    String label;
    switch (_settedArea.areaType) {
      case 'around':
        label = '周边';
        break;
      case 'province':
        label = '省';
        break;
      case 'city':
        label = '市';
        break;
    }
    var title = _settedArea.areaTitle;
    return <Widget>[
      Padding(
        padding: EdgeInsets.only(
          left: 15,
          right: 15,
          top: 15,
        ),
        child: Row(
          children: [
            Text('$label：'),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                '$title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                _emptyLimitArea();
              },
              child: Icon(
                Icons.close,
                size: 18,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 10,
      ),
    ];
  }
}
