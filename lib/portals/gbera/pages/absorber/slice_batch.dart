import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:intl/intl.dart' as intl;

class SliceBatchPage extends StatefulWidget {
  PageContext context;

  SliceBatchPage({this.context});

  @override
  _SliceBatchPageState createState() => _SliceBatchPageState();
}

class _SliceBatchPageState extends State<SliceBatchPage> {
  EasyRefreshController _controller;
  int _limit = 10, _offset = 0;
  List<SliceBatchOR> _templates = [];
  bool _isLoading = false;

  @override
  void initState() {
    _controller = EasyRefreshController();
    () async {
      setState(() {
        _isLoading = false;
      });
      await _load();
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
    }();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    var items = await robotRemote.pageQrcodeSliceBatch(_limit, _offset);
    if (items.isEmpty) {
      _controller.finishLoad();
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _templates.addAll(items);
    _offset += items.length;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选择批次'),
        elevation: 0,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: EasyRefresh(
              onLoad: _load,
              child: ListView(
                children: _templates.map((e) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          widget.context.backward(result: e);
                        },
                        child: Container(
                          constraints: BoxConstraints.tightForFinite(
                            width: double.maxFinite,
                          ),
                          color: Colors.white,
                          padding: EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 20,
                            bottom: 20,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                    '${intl.DateFormat('yyyy年MM月dd日 hh:mm:ss').format(parseStrTime(
                                  e.ctime,
                                  len: 17,
                                ))}'),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: (){
              widget.context.backward(result: 'all');
            },
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: 15, bottom: 15),
              constraints: BoxConstraints.tightForFinite(
                width: double.maxFinite,
              ),
              alignment: Alignment.center,
              child: Text(
                '全部',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
