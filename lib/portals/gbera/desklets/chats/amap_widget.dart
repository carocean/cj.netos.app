import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';

class GisMapWidget extends StatefulWidget {
  PageContext context;

  GisMapWidget({this.context});

  @override
  _GisMapWidgetState createState() => _GisMapWidgetState();
}

class _GisMapWidgetState extends State<GisMapWidget> {
  LatLng _location;
  String _label;

  @override
  void initState() {
    _location = widget.context.partArgs['location'];
    () async {
      var recode =
          await AmapSearch.instance.searchReGeocode(_location, radius: 1000);
      if (recode == null) {
        return;
      }
      _label = recode.formatAddress;
      if (mounted) {
        setState(() {});
      }
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 100,
              child: AmapView(
                centerCoordinate: _location,
                showCompass: true,
                zoomLevel: 18,
                markers: [
                  MarkerOption(
                    coordinate: _location,
                    title: '',
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
                          '',
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
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Color(0x00FFFFFF),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                '${_label ?? ''}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
