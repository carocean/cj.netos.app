import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:framework/framework.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/util.dart';

class GberaAvatar extends StatefulWidget {
  PageContext context;
  bool useBackButton;

  GberaAvatar({this.context, this.useBackButton = false});

  @override
  _GberaAvatarState createState() => _GberaAvatarState();
}

class _GberaAvatarState extends State<GberaAvatar> {
  File _image;
  var _background;
  File _crop_image;
  var _cropKey = GlobalKey<CropState>();

  //长宽比
  double aspectRatio;

  @override
  void initState() {
    aspectRatio = widget.context.parameters['aspectRatio'];
    var fileName = widget.context.parameters['file'];
    if (!StringUtil.isEmpty(fileName)) {
      _image = File(fileName);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var bb = widget.useBackButton;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0,
        automaticallyImplyLeading: bb == null ? true : false,
        leading: getLeading(bb),
        actions: <Widget>[
          _crop_image != null
              ? Container(
                  width: 0,
                  height: 0,
                )
              : IconButton(
                  onPressed: () async {
                    var image = await ImagePicker().getImage(
                        source: ImageSource.gallery,imageQuality: 80,maxHeight: Adapt.screenH(),);
                    setState(() {
                      _image = File(image.path);
                      _background = Colors.black;
                    });
                  },
                  icon: Icon(
                    Icons.insert_photo,
                    size: 20,
                  ),
                ),
          _crop_image != null
              ? Container(
                  width: 0,
                  height: 0,
                )
              : IconButton(
                  onPressed: () async {
                    var image =
                        await ImagePicker().getImage(source: ImageSource.camera,imageQuality: 80,maxHeight: Adapt.screenH(),);
                    setState(() {
                      _image = File(image.path);
                      _background = Colors.black;
                    });
                  },
                  icon: Icon(
                    Icons.add_a_photo,
                    size: 20,
                  ),
                ),
          _image == null
              ? Container(
                  width: 0,
                  height: 0,
                )
              : IconButton(
                  onPressed: () async {
                    var crop = _cropKey.currentState;
                    var scale = crop.scale; //用户选择的缩放比
                    if (scale == null) {
                      throw FlutterError('剪图失败');
                    }
                    var area = crop.area; //选中的区域截图
                    if (area == null) {
                      throw FlutterError('剪图失败');
                    }
                    final permissionsGranted =
                        await ImageCrop.requestPermissions();
                    final options =
                        await ImageCrop.getImageOptions(file: _image);
                    final sampledFile = await ImageCrop.sampleImage(
                      file: _image,
                      preferredWidth: (options.width / crop.scale).round(),
                      preferredHeight: (options.height / crop.scale).round(),
                    );
                    _crop_image = await ImageCrop.cropImage(
                      file: sampledFile,
                      area: crop.area,
                    );
                    _image = null;
                    setState(() {
                      widget.context.backward(result: _crop_image.path);
                    });
                  },
                  icon: Icon(Icons.check),
                ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: 20,
          bottom: 20,
          left: 20,
          right: 20,
        ),
        alignment: Alignment.center,
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: _image == null ? null : _background,
        ),
        //RepaintBoundary截图
        child: _crop_image != null
            ? SizedBox(width: 100, height: 100, child: Image.file(_crop_image))
            : _renderMainRegion(),
      ),
    );
  }

  _renderMainRegion() {
    if (_image == null) {
      return Text('请拍照或选相册选择');
    }
    var _crop;
    if (aspectRatio == null) {
      aspectRatio = 1;
    }
    if (aspectRatio == -1) {
      _crop = Crop(
        key: _cropKey,
        image: FileImage(
          _image,
        ),
//                    aspectRatio: aspectRatio,
      );
    } else {
      _crop = Crop(
        key: _cropKey,
        image: FileImage(
          _image,
        ),
        aspectRatio: aspectRatio,
      );
    }
    return (_image != null ? _crop : Text('请拍照或选相册选择'));
  }

  getLeading(bb) {
    if (bb == null) return null;
    return IconButton(
      onPressed: () async {
        widget.context.backward();
      },
      icon: Icon(
        Icons.clear,
        size: 18,
      ),
    );
  }
}
