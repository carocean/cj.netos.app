import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';

class CreateSlicesProgressPage extends StatefulWidget {
  PageContext context;

  CreateSlicesProgressPage({this.context});

  @override
  _CreateSlicesProgressPageState createState() =>
      _CreateSlicesProgressPageState();
}

class _CreateSlicesProgressPageState extends State<CreateSlicesProgressPage> {
  String _progressTips = '';

  @override
  void initState() {
    _doCreate();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _doCreate() async {
    IRobotRemote robotRemote = widget.context.site.getService('/remote/robot');
    Map<String, dynamic> args = widget.context.parameters;
    SliceTemplateOR templateOR = args['template'];
    LatLng location = args['location'];
    int radius = args['radius'];
    AbsorberOR absorberOR = args['originAbsorber'];
    int count = args['count'];
    if (mounted) {
      setState(() {
        _progressTips += '正在生成码片...\r\n';
      });
    }
    List<QrcodeSliceOR> slices;
    try {
      slices = await robotRemote.createQrcodeSlice(templateOR.id, 0, location,
          radius, absorberOR?.id, widget.context.principal.person, count, null);
    } catch (e) {
      _progressTips = '$e';
      if (mounted) setState(() {});
      return;
    }
    if (mounted) {
      setState(() {
        _progressTips += '已成生码片:${slices.length}个\r\n';
        _progressTips += '准备装载招财猫...\r\n';
      });
    }
    Map<String, AbsorberResultOR> _absorbers = args['absorbers'];
    for (var slice in slices) {
      if (mounted) {
        setState(() {
          _progressTips += '正在装载码片:${slice.id}\r\n';
        });
      }
      for (var absorber in _absorbers.values) {
        await robotRemote.addQrcodeSliceRecipients(
            absorber.absorber.id, slice.id);
        if (mounted) {
          setState(() {
            _progressTips += '已装载招财猫：${absorber.absorber.title}\r\n';
          });
        }
      }
      if (mounted) {
        setState(() {
          _progressTips += '本码片装载完成\r\n';
        });
      }
    }
    if (mounted) {
      setState(() {
        _progressTips += '全部码片装载完成\r\n';
        _progressTips += '开始导出码片...\r\n';
      });
    }
    widget.context.forward('/robot/slice/image', arguments: {
      'slices': slices,
      'isShowAction': false,
      'isAutoExport': true,
    }).then((value) {
      if (mounted) {
        setState(() {
          _progressTips += '码片已全部导出到相册\r\n';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('进度'),
        elevation: 0,
        titleSpacing: 0.0,
      ),
      body: _renderBody(),
    );
  }

  Widget _renderBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Text('$_progressTips'),
        ),
      ],
    );
  }
}
