import 'dart:convert';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_utils.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

class GeoCreateReceptor extends StatefulWidget {
  PageContext context;

  GeoCreateReceptor({this.context});

  @override
  _GeoCreateReceptorState createState() => _GeoCreateReceptorState();
}

class _GeoCreateReceptorState extends State<GeoCreateReceptor> {
  TextEditingController _titleController;
  TextEditingController _radiusController;
  bool _enableFinishButton = false;
  GeoChannelOR _channel;
  GeoCategoryOR _category;
  GeoBrandOR _brand;
  var _key = GlobalKey<_LocationSettingWidgetState>();

  @override
  void initState() {
    _channel = widget.context.parameters['channel'];
    _category = widget.context.parameters['category'];
    _brand = widget.context.parameters['brand'];
    _titleController = TextEditingController();
    _radiusController = TextEditingController(
        text:
            '${_category.defaultRadius == null || _category.defaultRadius == 0 ? 5000 : _category.defaultRadius}');
    super.initState();
  }

  @override
  void dispose() {
    _enableFinishButton = false;
    _titleController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _saveReceptor() async {
    _enableFinishButton = false;
    setState(() {});
    IGeoReceptorService receptorService =
        widget.context.site.getService('/geosphere/receptors');
    var _geoPoi = _key.currentState._geoPoi;
    var _udistance = _key.currentState._distanceUpdateRate;
    var moveMode;
    switch (_category.moveMode) {
      case GeoCategoryMoveableMode.unmoveable:
        moveMode = 'unmoveable';
        break;
      case GeoCategoryMoveableMode.moveableDependon:
        moveMode = 'moveableDependon';
        break;
      case GeoCategoryMoveableMode.moveableSelf:
        moveMode = 'moveableSelf';
        break;
    }
    await receptorService.add(
      GeoReceptor(
        MD5Util.MD5(Uuid().v1()),
        _titleController.text,
        _channel.id,
        _category.id,
        _brand?.id,
        moveMode,
        _category.leading,
        widget.context.principal.person,
        jsonEncode(_geoPoi.latLng.toJson()),
        double.parse(_radiusController.text),
        _udistance,
        DateTime.now().millisecondsSinceEpoch,
        DateTime.now().millisecondsSinceEpoch,
        'false',
        'none',
        null,
        'false',
        widget.context.principal.device,
        'true',
        widget.context.principal.person,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    GeoCategoryOR category = _category;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
        elevation: 0.0,
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            onPressed: !_enableFinishButton
                ? null
                : () {
                    _saveReceptor().then((v) {
                      widget.context.backward(
                          clearHistoryPageUrl: '/geosphere/',
                          result: {'refresh': true});
                    });
                  },
            child: Text(
              '完成',
              style: TextStyle(
                color: _enableFinishButton ? Colors.green : Colors.grey[400],
              ),
            ),
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
              key: _key,
              onSelected: () {
                var poi = _key.currentState._geoPoi;
                if (!StringUtil.isEmpty(poi?.title)) {
                  _titleController.text = poi.title;
                  _enableFinishButton =
                      !StringUtil.isEmpty(_titleController.text) &&
                          !StringUtil.isEmpty(_radiusController.text);
                  setState(() {});
                }
              },
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
                              onChanged: (v) {
                                _enableFinishButton = !StringUtil.isEmpty(
                                        _titleController.text) &&
                                    !StringUtil.isEmpty(_radiusController.text);
                                setState(() {});
                              },
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
                                    onChanged: (v) {
                                      _enableFinishButton = !StringUtil.isEmpty(
                                              _titleController.text) &&
                                          !StringUtil.isEmpty(
                                              _radiusController.text);
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      hintText: '输入感知半径，单位米',
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
  GeoCategoryOR category;
  PageContext context;
  Key key;
  Function() onSelected;

  _LocationSettingWidget({
    this.category,
    this.context,
    this.key,
    this.onSelected,
  }) : super(key: key);

  @override
  _LocationSettingWidgetState createState() => _LocationSettingWidgetState();
}

class _LocationSettingWidgetState extends State<_LocationSettingWidget> {
  AmapPoi _geoPoi;
  int _distanceUpdateRate = 10;

  @override
  void initState() {
    _loadLocation();
    super.initState();
  }

  @override
  void dispose() {
    geoLocation.unlisten('locationSettings');
    super.dispose();
  }

  _loadLocation() async {
    var location =
        await AmapLocation.fetchLocation(mode: LocationAccuracy.High);
    var address = await location.address;
    if (StringUtil.isEmpty(address)) {
      return;
    }
    _geoPoi = AmapPoi(
      latLng: await location.latLng,
      address: address,
      title: await location.poiName,
    );
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _geoPoi?.title ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        StringUtil.isEmpty(_geoPoi?.address)
                            ? Container(
                                width: 0,
                                height: 0,
                              )
                            : Text(
                                _geoPoi?.address ?? '',
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/geosphere/amap/near', arguments: {
                'poi': _geoPoi,
              }).then((result) {
                if (result == null) {
                  return;
                }
                var map = result as Map;
                _geoPoi = map['poi'];
                if (widget.onSelected != null) {
                  widget.onSelected();
                }
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
              widget.context
                  .forward('/geosphere/receptor/setUpdateRate')
                  .then((result) {
                if (result == null) {
                  return;
                }
                _distanceUpdateRate = (result as Map)['distance'];
                if (widget.onSelected != null) {
                  widget.onSelected();
                }
                setState(() {});
              });
            },
            child: Row(
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    text: '更新距离: ',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: '${_distanceUpdateRate}米',
                      ),
                    ],
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
