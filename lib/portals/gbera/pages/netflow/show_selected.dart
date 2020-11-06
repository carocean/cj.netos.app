import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';

class ShowPersonelectedPage extends StatefulWidget {
  PageContext context;

  ShowPersonelectedPage({this.context});

  @override
  _ShowPersonelectedPageState createState() => _ShowPersonelectedPageState();
}

class _ShowPersonelectedPageState extends State<ShowPersonelectedPage> {
  List<Person> _persons = [];

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _load() async {
    var selected = widget.context.parameters['selected'];
    if (selected == null) {
      return;
    }
    IPersonService friendService =
        widget.context.site.getService('/gbera/persons');
    for (var official in selected) {
      var friend = await friendService.getPerson(official);
      if (friend != null) {
        _persons.add(friend);
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('已选公众'),
        titleSpacing: 0,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          child: Column(
            children: _persons.map((e) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: getAvatarWidget(
                              e.avatar,
                              widget.context,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            '${e.nickName}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            List<String> selected =
                                widget.context.parameters['selected'];
                            for (var i = 0; i < selected.length; i++) {
                              var f = selected[i];
                              if (f == null) {
                                continue;
                              }
                              if (f == e.official) {
                                selected.remove(f);
                                _persons.clear();
                                _load();
                                if (mounted) {
                                  setState(() {});
                                }
                                break;
                              }
                            }
                          },
                          child: Icon(
                            Icons.remove,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 50,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
