import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';

class IspAbsorberLocationPage extends StatefulWidget {
  PageContext context;

  IspAbsorberLocationPage({this.context});

  @override
  _IspAbsorberLocationPageState createState() => _IspAbsorberLocationPageState();
}

class _IspAbsorberLocationPageState extends State<IspAbsorberLocationPage> {
  AbsorberOR _absorberOR;

  @override
  void initState() {
    _absorberOR = widget.context.page.parameters['absorber'];
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
          centerCoordinate: _absorberOR.location,
          showCompass: true,
          zoomLevel: 18,
          markers: [
            MarkerOption(
              latLng: _absorberOR.location,
              title: '${_absorberOR.title}',
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
                    '${_absorberOR.title}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    '半径: ${_absorberOR.radius}米',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
}
