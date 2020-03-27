import 'dart:ui';

import 'package:flutter/material.dart';

import 'util.dart';

enum RenderStateAppBar {
  origin,
  showAppBar,
  expaned,
}

class GberaPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  double _appBarHeight;
  Function(GberaPersistentHeaderDelegate delegate,
      RenderStateAppBar renderStateAppBar) onRenderAppBar;
  double expandedHeight;
  bool isScale;
  Widget child;
  ImageProvider<dynamic> background;
  Widget leading;
  bool automaticallyImplyLeading;
  Widget title;
  List<Widget> actions;
  Widget flexibleSpace;
  PreferredSizeWidget bottom;
  double elevation;
  ShapeBorder shape;
  Color backgroundColor;
  bool isFixedBackgroundColor;
  Brightness brightness;
  IconThemeData iconTheme;
  IconThemeData actionsIconTheme;
  TextTheme textTheme;
  bool primary;
  bool centerTitle;
  double titleSpacing;
  double toolbarOpacity;
  double bottomOpacity;

  GberaPersistentHeaderDelegate({
    this.background,
    this.expandedHeight,
    this.child,
    this.isScale = false,
    this.onRenderAppBar,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.shape,
    this.backgroundColor,
    this.isFixedBackgroundColor = false,
    this.brightness,
    this.iconTheme,
    this.actionsIconTheme,
    this.textTheme,
    this.primary = true,
    this.centerTitle,
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
  }) {
    this._appBarHeight =
        kToolbarHeight + MediaQueryData.fromWindow(window).padding.top;
    if (expandedHeight == null || expandedHeight < this._appBarHeight) {
      this.expandedHeight = this._appBarHeight;
    }
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var remaining = expandedHeight - shrinkOffset;
//    int opacity = 0; //0-255
//    var regionHeight = this._appBarHeight +
//        MediaQueryData.fromWindow(window).padding.top; //补10开始渐变
    //开始计算透明度，渐变为1
//      opacity=(((regionHeight-remaining)/regionHeight)*255.0).round();
    bool showAppBar = remaining < _appBarHeight ? true : false;
    if (this.onRenderAppBar != null) {
      if (remaining < _appBarHeight) {
        this.onRenderAppBar(this, RenderStateAppBar.showAppBar);
      } else if (remaining > _appBarHeight) {
        this.onRenderAppBar(this, RenderStateAppBar.expaned);
      } else {
        this.onRenderAppBar(this, RenderStateAppBar.origin);
      }
    }
    var bkColor = this.backgroundColor ?? Theme.of(context).backgroundColor;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          decoration: background == null
              ? null
              : BoxDecoration(
                  image: DecorationImage(
                    image: background,
                    fit: BoxFit.fill,
                  ),
                ),
          child: OverflowBox(
            minHeight: expandedHeight,
            maxHeight: expandedHeight,
            child: isScale
                ? Transform(
                    child: child,
                    origin: Offset(Adapt.screenW() / 2, expandedHeight / 2),
                    transform: Matrix4.identity()
                      ..scale(remaining / expandedHeight,
                          remaining / expandedHeight),
                  )
                : child,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: this.isFixedBackgroundColor
                ? bkColor
                : bkColor.withAlpha(showAppBar ? 255 : 0),
            elevation: this.background == null ? this.elevation : 0.0,
            textTheme: this.textTheme,
            brightness: this.brightness,
            toolbarOpacity: this.toolbarOpacity,
            centerTitle: this.centerTitle,
            actions: this.actions,
            leading: this.leading,
            bottom: this.bottom,
            actionsIconTheme: this.actionsIconTheme,
            automaticallyImplyLeading: this.automaticallyImplyLeading,
            bottomOpacity: this.bottomOpacity,
            flexibleSpace: this.flexibleSpace,
            iconTheme: this.iconTheme,
            primary: this.primary,
            shape: this.shape,
            titleSpacing: this.titleSpacing,
            title: this.title,
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(GberaPersistentHeaderDelegate oldDelegate) {
    return expandedHeight != oldDelegate.expandedHeight ||
        _appBarHeight != oldDelegate._appBarHeight ||
        child != oldDelegate.child ||
        background != oldDelegate.background;
  }

  @override
  double get maxExtent {
    return expandedHeight;
  }

  @override
  double get minExtent {
    return _appBarHeight;
  }
}
