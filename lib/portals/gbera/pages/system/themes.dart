import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class Themes extends StatefulWidget {
  PageContext context;
  List<ThemeStyle> themes;

  Themes({this.context});

  @override
  _ThemesState createState() => _ThemesState(selectedTheme: context.currentTheme());
}

class _ThemesState extends State<Themes> {
  List<ThemeStyle> themes;
  String selectedTheme = '';

  _ThemesState({this.selectedTheme});

  @override
  Widget build(BuildContext context) {
    var names = widget.context.site.getService("@.theme.names");
    themes = [];
    names?.forEach((url) {
      var theme=widget.context.site.getService('@.theme:$url');
      if(theme==null) {
        return;
      }
      themes.add(theme);
    });
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
      body: Container(
        child: ListView.separated(
          itemBuilder: _itemBuilder,
          separatorBuilder: _separatorBuilder,
          itemCount: themes?.length,
          shrinkWrap: true,
        ),
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

  Widget _itemBuilder(BuildContext context, int index) {
    var theme = this.themes[index];
    var isSelectedItem = theme.url == selectedTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          var selected = theme;
          this.selectedTheme = selected.url;
          widget.context.switchTheme(selected.url);

        });
      },
      child: Container(
        padding: EdgeInsets.only(
          top: 15,
          bottom: 15,
          left: 10,
          right: 10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Icon(
                      widget.context.findPage('/system/themes').icon,
                      size: 30,
                      color: theme.iconColor,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Text(
                          theme.title,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        theme.desc,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            isSelectedItem
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.red[400],
                  )
                : Container(width: 0,height: 0,),
          ],
        ),
      ),
    );
  }

  Widget _separatorBuilder(BuildContext context, int index) {
    return Divider(
      height: 1,
      indent: 50,
    );
  }
}
