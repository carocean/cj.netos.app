import 'package:flutter/material.dart';
import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';

class PoolLocationMapPage extends StatefulWidget {
  PageContext context;

  PoolLocationMapPage({this.context});

  @override
  _PoolLocationMapPageState createState() => _PoolLocationMapPageState();
}

class _PoolLocationMapPageState extends State<PoolLocationMapPage> {
  TrafficPool _trafficPool;
  LatLng _location;

  @override
  void initState() {
    _trafficPool = widget.context.parameters['pool'];
    _location = widget.context.parameters['location'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('位置'),
        elevation: 0,
      ),
      body: Container(
        child: AmapView(
          centerCoordinate: _location,
          showCompass: true,
          zoomLevel: _getLevel(),
          markers: [
            MarkerOption(
              latLng: _location,
              title: '${_trafficPool.title}',
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
                    '${_trafficPool.title}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.black54,
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

  _getLevel() {
    double level;
    switch(_trafficPool.level) {
      case 0:
        level=3;
        break;
      case 1:
        level=6;
        break;
      case 2:
        level=8;
        break;
      case 3:
        level=10;
        break;
      case 4:
        level=15;
        break;
      default:
        level=18;
        break;
    }
    return level;
  }

}
