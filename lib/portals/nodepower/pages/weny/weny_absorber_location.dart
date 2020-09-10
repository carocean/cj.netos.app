import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';

class AbsorberLocationPage extends StatefulWidget {
  PageContext context;

  AbsorberLocationPage({this.context});

  @override
  _AbsorberLocationPageState createState() => _AbsorberLocationPageState();
}

class _AbsorberLocationPageState extends State<AbsorberLocationPage> {
  AbsorberResultOR _absorberOR;

  @override
  void initState() {
    _absorberOR = widget.context.page.parameters['absorber'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var absorber=_absorberOR.absorber;
    return Scaffold(
      appBar: AppBar(
        title: Text('位置'),
        elevation: 0,
      ),
      body: Container(
        child: AmapView(
          centerCoordinate: absorber.location,
          showCompass: true,
          zoomLevel: 18,
          markers: [
            MarkerOption(
              latLng: absorber.location,
              title: '${absorber.title}',
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
                    '${absorber.title}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    '半径: ${absorber.radius}米',
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
