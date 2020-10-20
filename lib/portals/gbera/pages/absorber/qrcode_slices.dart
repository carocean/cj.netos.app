import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart' as intl;

class QrcodeSlicePage extends StatefulWidget {
  PageContext context;

  QrcodeSlicePage({this.context});

  @override
  _QrcodeSlicePageState createState() => _QrcodeSlicePageState();
}

class _QrcodeSlicePageState extends State<QrcodeSlicePage> {
  EasyRefreshController _controller;
  SliceBatchOR _selectedBatch;
  int _limit = 10, _offset = 0;
  List<QrcodeSliceOR> _slices = [];
  bool _isLoading = false;

  @override
  void initState() {
    _controller = EasyRefreshController();
    () async {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
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
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    _slices.clear();
    await _load();
  }

  Future<void> _load() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    List<QrcodeSliceOR> list;
    if (_selectedBatch == null) {
      list = await robotRemote.pageQrcodeSlice(_limit, _offset);
    } else {
      list = await robotRemote.pageQrcodeSliceOfBatch(
          _selectedBatch.id, _limit, _offset);
    }
    if (list.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _slices.addAll(list);
    _offset += list.length;
    if (mounted) {
      setState(() {});
    }
  }

  Future<SliceTemplateOR> _loadTemplate(template) async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    return await robotRemote.getQrcodeSliceTemplate(template);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的码片'),
        elevation: 0.0,
        titleSpacing: 0,
        actions: [
          IconButton(
            onPressed: () {
              widget.context.forward('/robot/createSlices').then((value) {
                _onRefresh();
              });
            },
            icon: Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: 10,
              top: 20,
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (ctx) {
                        return widget.context
                            .part('/robot/sliceBatchPage', ctx);
                      }).then((value) {
                    if (value == null) {
                      return null;
                    }
                    if (value is String) {
                      _selectedBatch = null;
                      _onRefresh();
                      return;
                    }
                    SliceBatchOR batch = value as SliceBatchOR;
                    _selectedBatch = batch;
                    _onRefresh();
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_selectedBatch == null ? '全部批次' : intl.DateFormat(
                          'yyyy年MM月dd日 hh:mm',
                        ).format(parseStrTime(_selectedBatch.ctime, len: 17))}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Icon(
                      FontAwesomeIcons.filter,
                      size: 26,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
            child: EasyRefresh(
              controller: _controller,
              onLoad: _load,
              child: ListView(
                shrinkWrap: true,
                children: _renderSlices(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _renderSlices() {
    var items = <Widget>[];
    if (_isLoading) {
      items.add(
        Container(
          height: 50,
          alignment: Alignment.center,
          child: Text('正在加载...'),
        ),
      );
      return items;
    }
    if (_slices.isEmpty) {
      items.add(
        Container(
          height: 50,
          alignment: Alignment.center,
          child: Text('没有码片'),
        ),
      );
      return items;
    }
    for (var slice in _slices) {
      items.add(
        Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context.forward('/robot/slice/view',
                    arguments: {'slice': slice}).then((value) => _onRefresh());
              },
              child: Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: 10,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: RepaintBoundary(
                        child: QrImage(
                          ///二维码数据
                          data: '${slice.href}?id=${slice.id}',
                          version: QrVersions.auto,
                          gapless: false,
                          padding: EdgeInsets.all(0),
                          // embeddedImage:
                          // FileImage(File(widget.context.principal.avatarOnLocal)),
                          embeddedImageStyle: QrEmbeddedImageStyle(
                            size: Size(40, 40),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                '${_getSliceState(slice)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              slice.state != 1 ||
                                      StringUtil.isEmpty(slice.consumer)
                                  ? SizedBox(
                                      height: 0,
                                      width: 0,
                                    )
                                  : Expanded(
                                      child: FutureBuilder(
                                        future: _loadPerson(slice.consumer),
                                        builder: (ctx, snapshot) {
                                          if (snapshot.connectionState !=
                                              ConnectionState.done) {
                                            return SizedBox(
                                              height: 0,
                                              width: 0,
                                            );
                                          }
                                          Person person = snapshot.data;
                                          return Text(
                                            '${person.nickName}',
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.end,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${slice.id}',
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              FutureBuilder<SliceTemplateOR>(
                                future: _loadTemplate(slice.template),
                                builder: (ctx, snapshot) {
                                  if (snapshot.connectionState !=
                                      ConnectionState.done) {
                                    return SizedBox(
                                      height: 0,
                                      width: 0,
                                    );
                                  }
                                  var template = snapshot.data;
                                  return Text(
                                    '模板: ${template?.name ?? ''}',
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
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
        ),
      );
    }
    return items;
  }

  _getSliceState(QrcodeSliceOR slice) {
    switch (slice.state) {
      case -1:
        return '需要添加招财猫';
      case 0:
        return '等待扫码消费';
      case 1:
        return '已被消费';
      default:
        return '-';
    }
  }

  _loadPerson(String consumer) async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    return await personService.getPerson(consumer);
  }
}
