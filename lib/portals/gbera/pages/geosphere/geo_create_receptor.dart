import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/system/local/entities.dart';

class GeoCreateReceptor extends StatefulWidget {
  PageContext context;

  GeoCreateReceptor({this.context});

  @override
  _GeoCreateReceptorState createState() => _GeoCreateReceptorState();
}

class _GeoCreateReceptorState extends State<GeoCreateReceptor> {
  TextEditingController _titleController;
  TextEditingController _radiusController;

  @override
  void initState() {
    _titleController = TextEditingController();
    _radiusController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GeoCategory category = widget.context.parameters['category'];
    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
        elevation: 0.0,
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            onPressed: () {},
            child: Text('完成'),
          ),
        ],
      ),
      body: CustomScrollView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _LocationSettingWidget(
              category: category,
              context: widget.context,
            ),
          ),
          SliverFillRemaining(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                top: 10,
                left: 15,
                right: 15,
                bottom: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 30,
                        left: 15,
                        right: 15,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 5,
                            ),
                            child: Text(
                              '感知器名',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Flexible(
                            //解决了无法计算边界问题
                            fit: FlexFit.loose,
                            child: TextField(
                              controller: _titleController,
                              autofocus: true,
                              onSubmitted: (v) {
                                print(v);
                              },
                              onEditingComplete: () {
                                print('----');
                              },
                              style: TextStyle(
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: '输入地理感应器名',
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                ),
                                contentPadding: EdgeInsets.all(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  category.moveMode == GeoCategoryMoveableMode.moveableDependon
                      ? Container(
                          width: 0,
                          height: 0,
                        )
                      : Flexible(
                          fit: FlexFit.loose,
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: 10,
                              left: 15,
                              right: 15,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 5,
                                  ),
                                  child: Text(
                                    '感知半径',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  //解决了无法计算边界问题
                                  fit: FlexFit.loose,
                                  child: TextField(
                                    controller: _radiusController,
                                    autofocus: true,
                                    onSubmitted: (v) {
                                      print(v);
                                    },
                                    onEditingComplete: () {
                                      print('----');
                                    },
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '输入感知半径',
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                      ),
                                      contentPadding: EdgeInsets.all(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
}

class _LocationSettingWidget extends StatefulWidget {
  GeoCategory category;
  PageContext context;

  _LocationSettingWidget({this.category, this.context});

  @override
  _LocationSettingWidgetState createState() => _LocationSettingWidgetState();
}

class _LocationSettingWidgetState extends State<_LocationSettingWidget> {
  GeoPoi _geoPoi;

  @override
  void initState() {
    geoLocation.listen('locationSettings', 0, _setLocation);
    super.initState();
  }

  @override
  void dispose() {
    geoLocation.unlisten('locationSettings');
    super.dispose();
  }

  _setLocation(Location location) async {
    var address = await location.address;
    if (StringUtil.isEmpty(address)) {
      return;
    }
    _geoPoi = GeoPoi(
      latLng: await location.latLng,
      address: address,
      title: await location.poiName,
    );
    geoLocation.unlisten('locationSettings');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.category.moveMode) {
      case GeoCategoryMoveableMode.unmoveable:
        return _unmoveableWidget();
      case GeoCategoryMoveableMode.moveableSelf:
        return _moveableSelfWidget();
      case GeoCategoryMoveableMode.moveableDependon:
        return _moveableDependonWidget();
    }
    return Container();
  }

  Widget _unmoveableWidget() {
    return Container(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 30,
        bottom: 30,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
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
                    child: Text(
                      _geoPoi?.address ?? '',
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/geosphere/amap/near', arguments: {
                'latLng': _geoPoi?.latLng,
                'address': _geoPoi?.address,
              }).then((result) {
                if (result == null) {
                  return;
                }
                var map = result as Map;
                _geoPoi = map['poi'];
                setState(() {});
              });
            },
            child: Row(
              children: <Widget>[
                Text(
                  '选择',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _moveableSelfWidget() {
    return Container(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 30,
        bottom: 30,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
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
                    child: Text(
                      '实时定位',
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/geosphere/receptor/setUpdateRate');
            },
            child: Row(
              children: <Widget>[
                Text(
                  '离开距离',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _moveableDependonWidget() {
    return Container(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 30,
        bottom: 30,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
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
                    child: Text(
                      '位置依赖于',
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/geosphere/receptor/viewMobile');
            },
            child: Row(
              children: <Widget>[
                Text(
                  '我的地圈',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
