import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';

class SliceTemplatesPage extends StatefulWidget {
  PageContext context;

  SliceTemplatesPage({this.context});

  @override
  _SliceTemplatesPageState createState() => _SliceTemplatesPageState();
}

class _SliceTemplatesPageState extends State<SliceTemplatesPage> {
  List<SliceTemplateOR> _templates = [];
  bool _isLoading = false;

  @override
  void initState() {
    () async {
      setState(() {
        _isLoading = true;
      });
      await _load();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _load() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    var items = await robotRemote.pageQrcodeSliceTemplate(9999999, 0);
    if (items.isNotEmpty) {
      _templates.addAll(items);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic body;
    if (_isLoading) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('正在加载...'),
        ],
      );
    } else if (_templates.isEmpty) {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('没有模板'),
        ],
      );
    } else {
      body = GridView.count(
        //水平子Widget之间间距
        crossAxisSpacing: 10.0,
        //垂直子Widget之间间距
        mainAxisSpacing: 30.0,
        //GridView内边距
        padding: EdgeInsets.all(10.0),
        //一行的Widget数量
        crossAxisCount: 2,
        //子Widget宽高比例
        childAspectRatio: 0.62,
        children: _renderTemplates(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('模板市场'),
        titleSpacing: 0,
        elevation: 0,
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: body,
      ),
    );
  }

  List<Widget> _renderTemplates() {
    var items = <Widget>[];
    for (var template in _templates) {
      items.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.context.backward(result: template);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 200,
                width: 100,
                alignment: Alignment.center,
                child: widget.context.part(
                  '/robot/slice/template',
                  context,
                  arguments: {
                    'selectedSliceTemplate': template,
                    'fitted': true,
                  },
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Column(
                children: [
                  Text('${template.name}'),
                  SizedBox(
                    height: 2,
                  ),
                  Container(
                    constraints: BoxConstraints.tightForFinite(
                      width: double.maxFinite,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              '${template.note ?? ''}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return items;
  }
}
