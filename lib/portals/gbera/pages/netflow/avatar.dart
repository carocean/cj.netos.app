import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:framework/framework.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:netos_app/portals/gbera/store/services.dart';

class Avatar extends StatefulWidget {
  PageContext context;

  Avatar({this.context});

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  File _image;
  var _background;
  File _crop_image;
  var _cropKey = GlobalKey<CropState>();

  @override
  Widget build(BuildContext context) {
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
        actions: <Widget>[
          _crop_image != null
              ? Container(
                  width: 0,
                  height: 0,
                )
              : IconButton(
                  onPressed: () async {
                    var image = await ImagePicker.pickImage(
                        source: ImageSource.gallery);
                    setState(() {
                      _image = image;
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
                        await ImagePicker.pickImage(source: ImageSource.camera);
                    setState(() {
                      _image = image;
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
                    IChannelService channelService =
                        widget.context.site.getService('/netflow/channels');
                    Channel channel = widget.context.parameters['channel'];
                    await channelService.updateLeading(
                        _crop_image.path, channel?.id);
                    setState(() {
                      widget.context.backward();
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
            : (_image != null
                ? Crop(
                    key: _cropKey,
                    image: FileImage(
                      _image,
                    ),
                    aspectRatio: 1,
                  )
                : Text('请拍照或选相册选择')),
      ),
    );
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
