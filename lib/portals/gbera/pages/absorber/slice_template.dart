import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SliceTemplatePage extends StatefulWidget {
  PageContext context;

  SliceTemplatePage({this.context});

  @override
  _SliceTemplatePageState createState() => _SliceTemplatePageState();
}

class _SliceTemplatePageState extends State<SliceTemplatePage> {
  SliceTemplateOR _selectSliceTemplate;
  bool _fitted = false;

  @override
  void initState() {
    _selectSliceTemplate =
        widget.context.partArgs['selectedSliceTemplate'];
    _fitted = widget.context.partArgs['fitted'];
    _fitted = _fitted ?? false;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(SliceTemplatePage oldWidget) {
    oldWidget.context = widget.context;
    _selectSliceTemplate =
    widget.context.partArgs['selectedSliceTemplate'];
    _fitted = widget.context.partArgs['fitted'];
    _fitted = _fitted ?? false;

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectSliceTemplate == null) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('正在加载...'),
          ],
        ),
      );
    }

    var template = _getTemplate();
    if (!_fitted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/robot/editor/template/', arguments: {
                'sliceTemplate': _selectSliceTemplate
              }).then((value) {
                if (value == null) {
                  return;
                }
                var modifiedProps = value as Map;
                var props = _selectSliceTemplate.props;
                for (var key in modifiedProps.keys) {
                  var p = props[key];
                  p.value = modifiedProps[key].value;
                }
                if (mounted) {
                  setState(() {});
                }
              });
            },
            child: FittedBox(
              fit: BoxFit.cover,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Adapt.screenW(),
                  maxHeight: Adapt.screenH() - 60,
                ),
                child: template,
              ),
            ),
          ),
        ],
      );
    }
    return Scaffold(
      body: FittedBox(
        fit: BoxFit.cover,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Adapt.screenW(),
            maxHeight: Adapt.screenH() - 60,
          ),
          child: template,
        ),
      ),
    );
  }

  _getTemplate() {
    switch (_selectSliceTemplate.id) {
      case 'normal':
        return widget.context.part('/robot/slice/template/normal', context,
            arguments: {'sliceTemplate': _selectSliceTemplate});
      case 'official':
        return widget.context.part('/robot/slice/template/official', context,
            arguments: {'sliceTemplate': _selectSliceTemplate});
      case 'official2':
        return widget.context.part('/robot/slice/template/official2', context,
            arguments: {'sliceTemplate': _selectSliceTemplate});
      case 'happiness':
        return widget.context.part('/robot/slice/template/happiness', context,
            arguments: {'sliceTemplate': _selectSliceTemplate});
      case 'xibao':
        return widget.context.part('/robot/slice/template/xibao', context,
            arguments: {'sliceTemplate': _selectSliceTemplate});
      case 'caisheng':
        return widget.context.part('/robot/slice/template/caisheng', context,
            arguments: {'sliceTemplate': _selectSliceTemplate});
      case 'minxinpian':
        return widget.context.part('/robot/slice/template/minxinpian', context,
            arguments: {'sliceTemplate': _selectSliceTemplate});
      case 'chiji':
        return widget.context.part('/robot/slice/template/chiji', context,
            arguments: {'sliceTemplate': _selectSliceTemplate});
      case 'wangzherongyao':
        return widget.context.part('/robot/slice/template/wangzherongyao', context,
            arguments: {'sliceTemplate': _selectSliceTemplate});
      case 'love':
        return widget.context.part('/robot/slice/template/love', context,
            arguments: {'sliceTemplate': _selectSliceTemplate});
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('不支持的模板:${_selectSliceTemplate.id}'),
          ],
        );
    }
  }
}
