import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

import 'gis_navigation.dart';

class LocationMapPage extends StatefulWidget {
  PageContext context;

  LocationMapPage({this.context});

  @override
  _LocationMapPageState createState() => _LocationMapPageState();
}

class _LocationMapPageState extends State<LocationMapPage> {
  LatLng _location;
  String _label;
  bool _hasNavigationAction = false;
  GlobalKey<ScaffoldState> _globalKey=GlobalKey();
  @override
  void initState() {
    _location = widget.context.parameters['location'];
    _label = widget.context.parameters['label'];
    _hasNavigationAction = widget.context.parameters['hasNavigationAction'];
    _hasNavigationAction = _hasNavigationAction ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text('位置'),
        elevation: 0,
        centerTitle: true,
        actions: _renderActions(),
      ),
      body: Container(
        child: AmapView(
          centerCoordinate: _location,
          showCompass: true,
          zoomLevel: 18,
          markers: [
            MarkerOption(
              coordinate: _location,
              title: '${_label ?? ''}',
              visible: true,
              widget: Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                spacing: 2,
                children: <Widget>[
                  Icon(
                    Icons.my_location,
                    size: 30,
                    color: Colors.red,
                  ),
                  Text(
                    '${_label ?? ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _renderActions() {
    var actions = <Widget>[];
    if (_hasNavigationAction) {
      actions.add(
        FlatButton(
          onPressed: () {
            showNavigationDialog2(
                key: _globalKey, latLng: _location);
          },
          child: Text('导航'),
        ),
      );
    }
    return actions;
  }

}
