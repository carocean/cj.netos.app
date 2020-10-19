import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';

class SliceTemplateEditor extends StatefulWidget {
  PageContext context;

  SliceTemplateEditor({this.context});

  @override
  _SliceTemplateEditorState createState() => _SliceTemplateEditorState();
}

class _SliceTemplateEditorState extends State<SliceTemplateEditor> {
  SliceTemplateOR _sliceTemplate;
  Map<String, TextEditingController> _textEditingControllers = {};
  Map<String, String> _images = {};
  String _progress;

  @override
  void initState() {
    _sliceTemplate = widget.context.parameters['sliceTemplate'];
    _loadImages();
    super.initState();
  }

  void _loadImages() {
    var props = _sliceTemplate.props;
    for (var key in props.keys) {
      var p = props[key];
      if ('image' != p.type) {
        continue;
      }
      _images[key] = p.value;
    }
    if (mounted) {
      setState(() {});
    }
  }

  bool _checkEdit() {
    var props = _sliceTemplate.props;
    for (var key in _textEditingControllers.keys) {
      var newV = _textEditingControllers[key].text;
      var old = props[key].value;
      if (old != newV) {
        return true;
      }
    }
    for (var key in _images.keys) {
      var newV = _images[key];
      var old = props[key].value;
      if (old != newV) {
        return true;
      }
    }
    return false;
  }

  Future<void> _updateProperties() async {
    //求出变动的属性
    var modifiedProps = {};
    var props = _sliceTemplate.props;
    for (var key in _textEditingControllers.keys) {
      var newV = _textEditingControllers[key].text;
      var old = props[key].value;
      if (old != newV) {
        props[key].value = newV;
        modifiedProps[key] = props[key];
      }
    }
    for (var key in _images.keys) {
      var newV = _images[key];
      var old = props[key].value;
      if (old != newV) {
        props[key].value = newV;
        modifiedProps[key] = props[key];
      }
    }
    widget.context.backward(result: modifiedProps);
  }

  Future<void> _uploadImage(TemplatePropOR prop, String file) async {
    var map = await widget.context.ports
        .upload('/app/qrcodeslice/images/', [file], onSendProgress: (i, j) {
      _progress = '${((i * 1.0 / j) * 100.00).toStringAsFixed(0)}%';
      if (mounted) {
        setState(() {});
      }
    });
    _images[prop.id] = map[file];
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('码片属性'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: !_checkEdit() ? Colors.grey[400] : Colors.green,
            ),
            onPressed: !_checkEdit()
                ? null
                : () {
                    _updateProperties();
                  },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: _renderProperties(),
        ),
      ),
    );
  }

  List<Widget> _renderProperties() {
    var items = <Widget>[];
    var props = _sliceTemplate.props;
    Widget propControl;
    for (var prop in props.values) {
      switch (prop.type) {
        case 'text':
          var controller = _textEditingControllers[prop.id];
          if (controller == null) {
            controller = TextEditingController(text: prop.value ?? '');
            _textEditingControllers[prop.id] = controller;
          }
          propControl = TextField(
            controller: controller,
            keyboardType: TextInputType.text,
            autofocus: true,
            onChanged: (v) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: '请输入${prop.name ?? ''}',
              border: InputBorder.none,
            ),
          );
          break;
        case 'image':
          var file = _images[prop.id];
          if (StringUtil.isEmpty(file)) {
            propControl = Image.asset(
              'lib/portals/gbera/images/default_image.png',
              width: 40,
              height: 40,
            );
          } else {
            propControl = FadeInImage.assetNetwork(
              placeholder: 'lib/portals/gbera/images/default_watting.gif',
              image:
                  '$file?accessToken=${widget.context.principal.accessToken}',
              height: 40,
              width: 40,
            );
          }
          if (!StringUtil.isEmpty(_progress)) {
            propControl = Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                propControl,
                SizedBox(
                  height: 4,
                ),
                Text(
                  '$_progress',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            );
          }
          propControl = Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              propControl,
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          );
          propControl = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context.forward('/widgets/avatar').then((value) {
                if (StringUtil.isEmpty(value)) {
                  return;
                }
                _uploadImage(prop, value);
              });
            },
            child: propControl,
          );
          break;
        case 'href':
          break;
        case 'color':
          break;
        default:
          break;
      }
      if (propControl == null) {
        continue;
      }
      items.add(
        Container(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: 10,
            bottom: 10,
          ),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${prop.name}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              StringUtil.isEmpty(prop.note)
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : SizedBox(
                      height: 5,
                    ),
              StringUtil.isEmpty(prop.note)
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : Padding(
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '注:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(
                              '${prop.note ?? ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              SizedBox(
                height: 5,
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: propControl,
              ),
            ],
          ),
        ),
      );
      items.add(
        SizedBox(
          height: 10,
        ),
      );
    }
    return items;
  }
}
