import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/single_media_widget.dart';
import 'package:netos_app/portals/gbera/share/share_card.dart';

class GeosphereSharePage extends StatefulWidget {
  PageContext context;

  GeosphereSharePage({this.context});

  @override
  _GeosphereSharePageState createState() => _GeosphereSharePageState();
}

class _GeosphereSharePageState extends State<GeosphereSharePage> {
  String _href;
  String _title;
  String _summary;
  String _leading;
  @override
  void initState() {
    var args=widget.context.parameters;
    _href=args['href'];
    _title=args['title'];
    _summary=args['summary'];
    _leading=args['leading'];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('地圈发布'),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () async{
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: Column(
        children: [
          renderShareEditor(
            context: widget.context,
            title: _title,
            href: _href,
            leading: _leading,
            summary: _summary,
          ),
          Expanded(child: Column(
            children: [],
          ),),
        ],
      ),
    );
  }
}
