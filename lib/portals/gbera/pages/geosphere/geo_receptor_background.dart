import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_entities.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';
import 'package:netos_app/portals/gbera/store/services.dart';

class GeosphereReceptorBackground extends StatefulWidget {
  PageContext context;

  GeosphereReceptorBackground({this.context});

  @override
  _GeosphereReceptorBackgroundState createState() =>
      _GeosphereReceptorBackgroundState();
}

class _GeosphereReceptorBackgroundState
    extends State<GeosphereReceptorBackground> {
  ReceptorInfo _receptor;

  @override
  void initState() {
    _receptor = widget.context.parameters['receptor'];
    if (_receptor.backgroundMode == null) {
      _receptor.backgroundMode = BackgroundMode.none;
    }
    if (_receptor.foregroundMode == null) {
      _receptor.foregroundMode = ForegroundMode.original;
    }
    super.initState();
  }

  @override
  void dispose() {
    _receptor = null;
    super.dispose();
  }

  Future<void> _setNoneBackground() async {
    IGeoReceptorService receptorService =
    widget.context.site.getService('/geosphere/receptors');
    await receptorService.emptyBackground(_receptor.id);
    _receptor.backgroundMode = BackgroundMode.none;
    _receptor.background = null;
    if (_receptor.onSettingsChanged != null) {
     await _receptor.onSettingsChanged(
          OnReceptorSettingsChangedEvent(action: 'setNoneBackground'));
    }
    await _setOriginalForeground();
  }

  Future<void> _setHorizontalBackground(file) async {
    IGeoReceptorService receptorService =
    widget.context.site.getService('/geosphere/receptors');
    await receptorService.updateBackground(
        _receptor.id, BackgroundMode.horizontal, file);
    _receptor.backgroundMode = BackgroundMode.horizontal;
    _receptor.background = file;
    if (_receptor.onSettingsChanged != null) {
    await  _receptor.onSettingsChanged(OnReceptorSettingsChangedEvent(
          action: 'setHorizontalBackground', args:{'file':file}));
    }
  }

  Future<void> _setVerticalBackground(file) async {
    IGeoReceptorService receptorService =
    widget.context.site.getService('/geosphere/receptors');
    await receptorService.updateBackground(
        _receptor.id, BackgroundMode.vertical, file);
    _receptor.backgroundMode = BackgroundMode.vertical;
    _receptor.background = file;
    if (_receptor.onSettingsChanged != null) {
     await _receptor.onSettingsChanged(OnReceptorSettingsChangedEvent(
          action: 'setVerticalBackground', args:{'file':file}));
    }
  }

  Future<void> _setWhiteForeground() async {
    IGeoReceptorService receptorService =
    widget.context.site.getService('/geosphere/receptors');
    await receptorService.updateForeground(_receptor.id, ForegroundMode.white);
    _receptor.foregroundMode = ForegroundMode.white;
    if (_receptor.onSettingsChanged != null) {
      await _receptor.onSettingsChanged(OnReceptorSettingsChangedEvent(
          action: 'setWhiteForeground'));
    }
  }

  Future<void> _setOriginalForeground() async {
    IGeoReceptorService receptorService =
    widget.context.site.getService('/geosphere/receptors');
    await receptorService.updateForeground(
        _receptor.id, ForegroundMode.original);
    _receptor.foregroundMode = ForegroundMode.original;
    if (_receptor.onSettingsChanged != null) {
      await _receptor.onSettingsChanged(OnReceptorSettingsChangedEvent(
          action: 'setOriginalForeground'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: <Widget>[
          SliverAppBar(
            title: Text('背景设置'),
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 20,
                  right: 0,
                  top: 0,
                  bottom: 0,
                ),
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _setNoneBackground().then((v) {
                        setState(() {});
                      });
                    },
                    child: CardItem(
                      title: '无背景',
                      tipsText: '',
                      paddingRight: 20,
                      tail: Icon(
                        _receptor.backgroundMode == BackgroundMode.none
                            ? Icons.check
                            : Icons.remove,
                        color: _receptor.backgroundMode == BackgroundMode.none
                            ? Colors.red
                            : Colors.grey[500],
                        size: 20,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.context.forward('/widgets/avatar', arguments: {
                        'aspectRatio': -1.0,
                        'file': _receptor.backgroundMode ==
                            BackgroundMode.horizontal
                            ? _receptor.background
                            : null,
                      }).then((result) {
                        if (result == null) {
                          return;
                        }
                        _setHorizontalBackground(result).then((v) {
                          setState(() {});
                        });
                      });
                    },
                    child: CardItem(
                      title: '使用横幅背景',
                      tipsText: '如用作店头',
                      paddingRight: 20,
                      tail: _getBackgroudTail(BackgroundMode.horizontal),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.context.forward('/widgets/avatar', arguments: {
                        'aspectRatio': -1.0,
                        'file':
                        _receptor.backgroundMode == BackgroundMode.vertical
                            ? _receptor.background
                            : null,
                      }).then((result) {
                        if (result == null) {
                          return;
                        }
                        _setVerticalBackground(result).then((v) {
                          setState(() {});
                        });
                      });
                    },
                    child: CardItem(
                      title: '使用竖幅背景',
                      tipsText: '一般用于我的地圈',
                      paddingRight: 20,
                      tail: _getBackgroudTail(BackgroundMode.vertical),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                bottom: 2,
                top: 10,
                left: 15,
              ),
              child: Text.rich(
                TextSpan(
                  text: '感知器前景色',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(text: '\r\n'),
                    TextSpan(
                      text: '如背景图太浓会导致字体不清，可设定白色主题',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 20,
                  right: 0,
                  top: 0,
                  bottom: 0,
                ),
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _setWhiteForeground().then((v) {
                        setState(() {});
                      });
                    },
                    child: CardItem(
                      title: '白色',
                      tipsText: '',
                      paddingRight: 20,
                      tail: Icon(
                        _receptor.foregroundMode == ForegroundMode.white
                            ? Icons.check
                            : Icons.remove,
                        color: _receptor.foregroundMode == ForegroundMode.white
                            ? Colors.red
                            : Colors.grey[500],
                        size: 20,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _setOriginalForeground().then((v) {
                        setState(() {});
                      });
                    },
                    child: CardItem(
                      title: '原色',
                      tipsText: '',
                      paddingRight: 20,
                      tail: Icon(
                        _receptor.foregroundMode == ForegroundMode.original
                            ? Icons.check
                            : Icons.remove,
                        color:
                        _receptor.foregroundMode == ForegroundMode.original
                            ? Colors.red
                            : Colors.grey[500],
                        size: 20,
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

  _getBackgroudTail(BackgroundMode mode) {
    var childs = <Widget>[];
    if (_receptor.backgroundMode != BackgroundMode.none &&
        !StringUtil.isEmpty(_receptor.background) &&
        _receptor.backgroundMode == mode) {
      childs.add(
        Image.file(
          File(_receptor.background),
          width: 30,
          height: 30,
        ),
      );
    } else {
      childs.add(
        Icon(
          Icons.photo_camera,
          color: Colors.grey[500],
          size: 20,
        ),
      );
    }
    childs.add(
      Padding(
        padding: EdgeInsets.only(
          left: 4,
        ),
        child: Icon(
          _receptor.backgroundMode == mode ? Icons.check : Icons.remove,
          color:
          _receptor.backgroundMode == mode ? Colors.red : Colors.grey[500],
          size: 20,
        ),
      ),
    );
    return Row(
      children: childs,
    );
  }
}
