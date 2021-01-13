import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:objectdb/objectdb.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';

class Wallpappers extends StatefulWidget {
  PageContext context;

  Wallpappers({this.context});

  @override
  _WallpappersState createState() => _WallpappersState();
}

class _WallpappersState extends State<Wallpappers> {
  static final KEY = '@.wallpaper';
  List<String> _wallpapers = [];
  bool _isLoading = true;
  ObjectDB _db;

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _db?.close();
    super.dispose();
  }

  Future<void> _load() async {
    await _openDb();
    var list = await _getWallpappers();
    for (var img in list) {
      _wallpapers.add(img);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    var localList = await _db.find({});
    for (var obj in localList) {
      var img = obj['wallpaper'];
      _wallpapers.add(img);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openDb() async {
    var home = await getApplicationDocumentsDirectory();
    var dir = '${home.path}/db';
    var dirFile = Directory(dir);
    if (!dirFile.existsSync()) {
      dirFile.createSync();
    }
    final path = '$dir/wallpapers.db';
    _db = ObjectDB(path);
    await _db.open();
  }

  Future _getWallpappers() async {
    var yaml = await DefaultAssetBundle.of(context)
        .loadString('lib/portals/gbera/wallpapers/wallpapper.yaml');
    var map = loadYaml(yaml);
    var wallpapers = map['wallpapers'];
    return wallpapers;
  }

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
      body: _renderBody(),
    );
  }

  Widget _renderBody() {
    if (_isLoading) {
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
    var items = _wallpapers;
    for (var item in items) {
      var wallpaper;
      if (item.startsWith('/')) {
        wallpaper = Image.file(
          File('$item'),
          fit: BoxFit.contain,
        );
      } else {
        wallpaper = Image.asset(
          item,
          fit: BoxFit.contain,
        );
      }
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
          onLongPress: !item.startsWith('/')
              ? null
              : () async {
                  var v = await showDialog(
                      context: context,
                      child: AlertDialog(
                        title: Text('请确认'),
                        content: Text('是否删除？'),
                        actions: [
                          FlatButton(
                            onPressed: () {},
                            child: Text(
                              '取消',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              widget.context.backward(result: 'yes');
                            },
                            child: Text(
                              '确认',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ));
                  if (v == null) {
                    return;
                  }
                  if (v == 'yes') {
                    var query = {'wallpaper': item};
                    await _db.remove(query);
                    _wallpapers.removeWhere((element) => element == item);
                    if (mounted) {
                      setState(() {});
                    }
                  }
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
                  child: wallpaper,
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
    widgets.add(InkWell(
      onTap: () async {
        var picker = ImagePicker();
        var image = await picker.getImage(
          source: ImageSource.gallery,
        );
        if (image == null) {
          return;
        }
        var src = image.path;
        var home = await getApplicationDocumentsDirectory();
        var dir = '${home.path}/wallpapers';
        var dirFile = Directory(dir);
        if (!dirFile.existsSync()) {
          dirFile.createSync();
        }
        var localFile = '$dir/${MD5Util.MD5(src)}.${fileExt(src)}';
        var file = File(localFile);
        if (file.existsSync()) {
          return;
        }
        file.writeAsBytesSync(File(src).readAsBytesSync());
        var query = {'wallpaper': localFile};
        var list = await _db.find(query);
        if (list.isNotEmpty) {
          await _db.remove(query);
        }
        await _db.insert(query);
        _wallpapers.add(localFile);
        if (mounted) {
          setState(() {});
        }
      },
      child: Container(
        constraints: BoxConstraints.expand(),
        child: Icon(
          Icons.add,
          size: 50,
          color: Colors.grey[700],
        ),
      ),
    ));
    return Container(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        children: widgets,
      ),
    );
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
