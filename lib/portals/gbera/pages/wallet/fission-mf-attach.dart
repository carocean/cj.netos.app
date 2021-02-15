import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/store/remotes/fission_mf_cashier.dart';
import 'package:video_compress/video_compress.dart';

class FissionMFAttachPage extends StatefulWidget {
  PageContext context;

  FissionMFAttachPage({this.context});

  @override
  _FissionMFAttachPageState createState() => _FissionMFAttachPageState();
}

class _FissionMFAttachPageState extends State<FissionMFAttachPage> {
  FissionMFAttachmentOR _attachmentOR;
  String _progress;
  bool _isAdvertEditor = false;
  TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _noteController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    _attachmentOR = await cashierRemote.getAttachment();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _setAttachment(String src, String type) async {
    var map = await widget.context.ports.upload('/app/fission/mf', [src],
        onSendProgress: (i, j) {
      _progress = '${((i / j * 1.0) * 100.00).toStringAsFixed(2)}%';
      if (mounted) {
        setState(() {});
      }
    });
    var remoteUrl = map[src];
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    await cashierRemote.setAttachment(remoteUrl, type);
    _attachmentOR = await cashierRemote.getAttachment();
    if (mounted) {
      setState(() {
        _progress = null;
      });
    }
  }

  Future<void> _emptyAttachment() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    await cashierRemote.emptyAttachment();
    _attachmentOR = await cashierRemote.getAttachment();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _setAdvert() async {
    IFissionMFCashierRemote cashierRemote =
        widget.context.site.getService('/wallet/fission/mf/cashier');
    await cashierRemote.setAdvert(_noteController.text);
    _attachmentOR = await cashierRemote.getAttachment();
    _isAdvertEditor = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('广告附件'),
        elevation: 0,
        titleSpacing: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
              right: 10,
            ),
            child: IconButton(
              onPressed: () {
                _emptyAttachment();
              },
              icon: Icon(
                Icons.clear,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
              right: 10,
            ),
            child: IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (ctx) {
                      return ImagePickerDialog();
                    });
              },
              icon: Icon(
                Icons.camera_enhance,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: _renderAttach(),
            ),
          ),
          StringUtil.isEmpty(_progress)
              ? SizedBox.shrink()
              : Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                    top: 5,
                    bottom: 10,
                  ),
                  child: Text('$_progress'),
                ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '说明',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _isAdvertEditor = !_isAdvertEditor;
                        setState(() {});
                      },
                      child: Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.black54,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              _renderAdvert(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _renderAttach() {
    if (_attachmentOR == null) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '没有附件,请',
                  ),
                  TextSpan(
                    text: '点此设置',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        showModalBottomSheet(
                            context: context,
                            builder: (ctx) {
                              return ImagePickerDialog();
                            });
                      },
                  ),
                ],
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return MediaWidget(
      <MediaSrc>[
        MediaSrc(
          id: '${_attachmentOR.person}',
          text: '${_attachmentOR.note ?? ''}',
          src: '${_attachmentOR.src}',
          type: '${_attachmentOR.type}',
        )
      ],
      widget.context,
    );
  }

  Widget ImagePickerDialog() {
    return Scaffold(
      appBar: AppBar(
        title: Text('请选择'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    var image = await ImagePicker().getImage(
                      source: ImageSource.gallery,
                      // imageQuality: 80,
                    );
                    widget.context.backward();
                    if (image == null) {
                      return;
                    }
                    var path = image.path;
                    await _setAttachment(
                      path,
                      'image',
                    );
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                    ),
                    child: Text('照片'),
                  ),
                ),
                Divider(
                  height: 1,
                ),
                InkWell(
                  onTap: () async{
                    var image = await ImagePicker().getVideo(
                      source: ImageSource.gallery,
                    );
                    widget.context.backward();
                    if (image == null) {
                      return;
                    }
                    var path = image.path;
                    if(!Platform.isIOS) {
                      if(mounted){
                        setState(() {
                          _progress='正在压缩视频...';
                        });
                      }
                      var info= await VideoCompress.compressVideo(
                        image.path,
                        quality: VideoQuality.HighestQuality,
                        // deleteOrigin: true, // It's false by default
                      );
                      var newfile=await copyVideoCompressFile(info.file);
                      path=newfile;
                      if(mounted){
                        setState(() {
                          _progress=null;
                        });
                      }
                    }
                    await _setAttachment(
                        path,
                        'video',
                    );
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                    ),
                    child: Text('视频'),
                  ),
                ),
                Divider(
                  height: 1,
                ),
                InkWell(
                  onTap: () async{
                    var image = await ImagePicker().getImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    widget.context.backward();
                    if (image == null) {
                      return;
                    }
                    var path = image.path;
                    await _setAttachment(
                        path,
                        'image',
                    );
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                    ),
                    child: Text('拍照'),
                  ),
                ),
                Divider(
                  height: 1,
                ),
                InkWell(
                  onTap: () async{
                    var image = await ImagePicker().getVideo(
                      source: ImageSource.camera,
                      maxDuration: Duration(seconds: 15,),
                    );
                    widget.context.backward();
                    if (image == null) {
                      return;
                    }
                    var path = image.path;
                    if(!Platform.isIOS) {
                      if(mounted){
                        setState(() {
                          _progress='正在压缩视频...';
                        });
                      }
                      var info= await VideoCompress.compressVideo(
                        image.path,
                        quality: VideoQuality.HighestQuality,
                        // deleteOrigin: true, // It's false by default
                      );
                      var newfile=await copyVideoCompressFile(info.file);
                      path=newfile;
                      if(mounted){
                        setState(() {
                          _progress=null;
                        });
                      }
                    }
                    await _setAttachment(
                        path,
                        'video',
                    );
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                    ),
                    child: Text('录像'),
                  ),
                ),
                Divider(
                  height: 1,
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            color: Colors.white,
            height: 70,
            child: InkWell(
              onTap: () {
                widget.context.backward();
              },
              child: Text('取消'),
            ),
          )
        ],
      ),
    );
  }

  Widget _renderAdvert() {
    if (_isAdvertEditor) {
      return Container(
        padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 20),
        color: Colors.white,
        constraints: BoxConstraints.tightForFinite(
          width: double.maxFinite,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _noteController,
                maxLines: 4,
                autofocus: true,
                onChanged: (v) {
                  if (mounted) {
                    setState(() {});
                  }
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: '输入内容',
                ),
              ),
            ),
            InkWell(
              onTap: StringUtil.isEmpty(_noteController.text)
                  ? null
                  : () {
                      _setAdvert();
                    },
              child: Container(
                padding:
                    EdgeInsets.only(top: 30, left: 20, right: 10, bottom: 30),
                child: Icon(
                  Icons.check,
                  size: 20,
                  color: StringUtil.isEmpty(_noteController.text)
                      ? Colors.grey[300]
                      : Colors.red,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 20),
      color: Colors.white,
      constraints: BoxConstraints.tightForFinite(
        width: double.maxFinite,
      ),
      child: Text(
        '${_attachmentOR?.note ?? '无'}',
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
