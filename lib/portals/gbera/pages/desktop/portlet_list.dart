import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/portlet_market.dart';
class PortletList extends StatefulWidget {
  PageContext context;

  PortletList({this.context});

  @override
  _PortletListState createState() => _PortletListState();
}

class _PortletListState extends State<PortletList> {
  @override
  Widget build(BuildContext context) {
    Desklet desklet = widget.context.parameters['desklet'];
    debugPrint('-----${desklet?.title}');
    widget.context.sharedPreferences().setString('test', '我很好');
    debugPrint('------${widget.context.sharedPreferences().getString('test')}');

    _getPortlets() async {
      var alllets =
          await market.fetchPortletsByDeskletUrl(desklet.url, widget.context);
      var installlets =
          await desktopManager.getInstalledPortlets(widget.context);
      var ids = [];
      for (var let in installlets) {
        ids.add(let.id);
      }
      return {'portlets': alllets, 'ids': ids};
    }

    var bb = widget.context.parameters['back_button'];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          desklet?.title,
        ),
        titleSpacing: 0,
        elevation: 1.0,
        automaticallyImplyLeading: bb == null ? true : false,
        leading: getLeading(bb),
      ),
      body: FutureBuilder(
        future: _getPortlets(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            throw FlutterError(snapshot.error.toString());
          }
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                widget.context.forward('/error',
                    arguments: {'error': 'Error: ${snapshot.error}'});
              }
              return _getPortletListView(snapshot, desklet);
            default:
              return null;
          }
        },
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

  Widget _getPortletListView(AsyncSnapshot snapshot, Desklet desklet) {
    List<Portlet> portlets = snapshot.data['portlets'];
    List ids = snapshot.data['ids'];
    return MyListView(
      portlets: portlets,
      ids: ids,
      context: widget.context,
    );
  }
}

class MyListView extends StatefulWidget {
  List<Portlet> portlets;
  List ids;
  PageContext context;
  MyListView({this.portlets, this.ids,this.context});

  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  @override
  Widget build(BuildContext context) {
    List<Portlet> portlets = widget.portlets;
    List ids = widget.ids;
    return ListView.separated(
        itemBuilder: (context, index) {
          Portlet let = portlets[index];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (await desktopManager.isInstalledPortlet(
                  let.id, widget.context)) {
                if (await desktopManager.isDefaultPortlet(
                    let.id, widget.context)) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('为系统栏目，不可取消'),
                  ));
                  return;
                }
                await desktopManager.unInstalledPortlet(let.id, widget.context);
                ids.remove(let.id);
              } else {
                await desktopManager.installPortlet(let, widget.context);
                ids.add(let.id);
              }
              setState(() {});
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
                          child: Image.network(
                            let?.imgSrc,
                            fit: BoxFit.contain,
                            width: 30,
                            height: 30,
                            color: widget.context
                                .style('/desktop/desklets/settings.icon'),
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
                                let?.title,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              let?.desc,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ids.contains(let.id)
                      ? Icon(
                          Icons.check,
                          size: 20,
                          color: Colors.red,
                        )
                      : Container(
                          width: 0,
                          height: 0,
                        ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 1,
            indent: 40,
          );
        },
        itemCount: portlets.length);
  }
}
