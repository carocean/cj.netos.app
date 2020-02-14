import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:yaml/yaml.dart';

class Wallpappers extends StatefulWidget {
  PageContext context;

  Wallpappers({this.context});

  @override
  _WallpappersState createState() => _WallpappersState();
}

class _WallpappersState extends State<Wallpappers> {
  static final KEY = '@.wallpaper';

  @override
  Widget build(BuildContext context) {
    var bb = widget.context.parameters['back_button'];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: bb == null ? true : false,
        leading: getLeading(bb),
      ),
      body: FutureBuilder(
        future: _getWallpappers(context),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            throw FlutterError(snapshot.error.toString());
          }
          if (!snapshot.hasData &&
              snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          var setted = widget.context.sharedPreferences().getString(KEY,
              scene: widget.context.currentScene(),
              person: widget.context.principal.person);
          var widgets = <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  widget.context.sharedPreferences().setString(KEY, '',
                      person: widget.context.principal.person,
                      scene: widget.context.currentScene());
                });
              },
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                  width: 1,
                  color: Colors.grey[200],
                )),
                padding: EdgeInsets.all(10),
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: <Widget>[
                    Center(
                      child: Text(
                        '无墙纸',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: !StringUtil.isEmpty(setted)
                          ? Container(
                              width: 0,
                              height: 0,
                            )
                          : Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.red,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ];
          var items = snapshot.data;
          for (var item in items) {
            widgets.add(
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    widget.context.sharedPreferences().setString(KEY, item,
                        scene: widget.context.currentScene(),
                        person: widget.context.principal.person);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                    width: 1,
                    color: Colors.grey[200],
                  )),
                  padding: EdgeInsets.all(10),
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: <Widget>[
                      Center(
                        child: Image.asset(
                          item,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: item != setted
                            ? Container(
                                width: 0,
                                height: 0,
                              )
                            : Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.red,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Container(
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              children: widgets,
            ),
          );
        },
      ),
    );
  }

  Future _getWallpappers(context) async {
    var yaml = await DefaultAssetBundle.of(context)
        .loadString('lib/portals/gbera/wallpapers/wallpapper.yaml');
    var map = loadYaml(yaml);
    var wallpapers = map['wallpapers'];
    return wallpapers;
  }

  getLeading(bb) {
    if (bb == null) return null;
    return IconButton(
      onPressed: () {
        widget.context.backward();
      },
      icon: Icon(
        Icons.clear,
        size: 18,
      ),
    );
  }
}
