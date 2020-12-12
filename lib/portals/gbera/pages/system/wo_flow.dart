import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/parts/timeline_listview.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_woflow.dart';
import 'package:intl/intl.dart' as intl;
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:uuid/uuid.dart';

class WOFlow extends StatefulWidget {
  PageContext context;

  WOFlow({this.context});

  @override
  _WOFlowState createState() => _WOFlowState();
}

class _WOFlowState extends State<WOFlow> {
  WOFormOR _form;
  List<WOFlowActivityOR> _activities = [];
  bool _isLoading = true;
  TextEditingController _contentController;
  String _attachRemote;
  String _attachLocal;
  double _progress = 0.00;

  @override
  void initState() {
    _contentController = TextEditingController();
    _form = widget.context.parameters['form'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _contentController?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    IWOFlowRemote flowRemote =
        await widget.context.site.getService('/feedback/woflow');
    var all = await flowRemote.listActivities(_form.id);
    _activities.addAll(all);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _send(bool _isEnd) async {
    IWOFlowRemote flowRemote =
        await widget.context.site.getService('/feedback/woflow');
    var activity;
    if (!_isEnd) {
      activity = await flowRemote.send(
          _form.id, _contentController.text, _attachRemote);
      _form.state = 1;
    } else {
      activity = await flowRemote.sendAndCloseFlow(
          _form.id, _contentController.text, _attachRemote);
      _form.state = -1;
    }
    _activities.add(activity);
    _contentController.text = '';
    _attachRemote = null;
    _attachLocal = null;
    if (mounted) {
      setState(() {});
    }
    if (_isEnd) {
      widget.context.backward(result: _form.state == -1 ? _form.id : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('处理'),
        elevation: 0,
        titleSpacing: 0,
      ),
      body: Container(
        constraints: BoxConstraints.tightForFinite(
          width: double.maxFinite,
        ),
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.context
                    .forward('/system/wo/view', arguments: {'form': _form});
              },
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${_form.typeTitle ?? ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('状态:'),
                      SizedBox(
                        width: 10,
                      ),
                      Text('${_getFormState()}'),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('反馈编号:'),
                      SizedBox(
                        width: 10,
                      ),
                      Text('${_form.id}'),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 10,
                  ),
                  child: Column(
                    children: _renderFlowPanel(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _renderFlowPanel() {
    var items = <Widget>[];
    if (_isLoading) {
      items.add(
        Center(
          child: Text(
            '正在加载流程',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
      return items;
    }
    for (var activity in _activities) {
      items.add(
        rendTimelineListRow(
          title: Container(
            child: Row(
              children: [
                Text(
                  '${intl.DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(activity.ctime))}',
                ),
              ],
            ),
          ),
          paddingLeft: 12,
          paddingContentLeft: 40,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _renderParticipant(activity.participant),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(
                  left: 10,
                ),
                constraints: BoxConstraints.tightForFinite(
                  width: double.maxFinite,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${activity.content ?? ''}'),
                    StringUtil.isEmpty(activity.attachment)
                        ? SizedBox(
                            width: 0,
                            height: 0,
                          )
                        : Padding(
                            padding: EdgeInsets.all(10),
                            child: MediaWidget(
                              [
                                MediaSrc(
                                  id: Uuid().v1(),
                                  type: 'image',
                                  text: '',
                                  sourceType: 'image',
                                  src: activity.attachment,
                                ),
                              ],
                              widget.context,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_form.state != -1) {
      items.add(
        SizedBox(
          height: 20,
          child: Divider(
            height: 1,
          ),
        ),
      );
      items.add(
        _SendButton(
          onTap: (bool _isEnd) {
            _send(_isEnd);
          },
          context: widget.context,
          controller: _contentController,
        ),
      );
      items.add(
        SizedBox(
          height: 10,
        ),
      );
      items.add(
        Row(
          children: [
            Expanded(
                child: StringUtil.isEmpty(_attachLocal)
                    ? Text('无')
                    : Column(
                        children: [
                          MediaWidget(
                            [
                              MediaSrc(
                                id: Uuid().v1(),
                                type: 'image',
                                text: '',
                                sourceType: 'image',
                                src: _attachLocal,
                              ),
                            ],
                            widget.context,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          _progress > 0.00
                              ? Text('${_progress.toStringAsFixed(2)}%')
                              : StringUtil.isEmpty(_attachRemote)
                                  ? SizedBox(
                                      width: 0,
                                      height: 0,
                                    )
                                  : Text(
                                      '已上传',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    )
                        ],
                      )),
            SizedBox(
              width: 10,
            ),
            OutlineButton(
              onPressed: () async {
                var image = await ImagePicker().getImage(
                  source: ImageSource.gallery,
                  maxHeight: Adapt.screenH(),
                  imageQuality: 80,
                );
                _attachLocal = image.path;
                if (mounted) {
                  setState(() {});
                }
                var map = await widget.context.ports.upload(
                    '/app/feedback/', [_attachLocal], onSendProgress: (i, j) {
                  _progress = ((i * 1.0) / j) * 100.00;
                  if (mounted) {
                    setState(() {});
                  }
                });
                _attachRemote = map[_attachLocal];
                _progress = 0.00;
                if (mounted) {
                  setState(() {});
                }
                await _send(false);
              },
              child: Text('上传'),
            ),
          ],
        ),
      );
    }

    items.add(
      SizedBox(
        height: 20,
      ),
    );
    return items;
  }

  _getFormState() {
    switch (_form.state) {
      case 0:
        return '已提交';
      case 1:
        return '处理中';
      case -1:
        return '已关闭';
    }
  }

  Future<Person> _loadPerson(participant) async {
    IPersonService personService =
        widget.context.site.getService('/gbera/persons');
    return await personService.fetchPerson(participant);
  }

  Widget _renderParticipant(String participant) {
    if (widget.context.principal.person == participant) {
      return Text(
        '${widget.context.principal.nickName}：',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return FutureBuilder<Person>(
      future: _loadPerson(participant),
      builder: (cxt, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data == null) {
          return SizedBox(
            width: 0,
            height: 0,
          );
        }
        return Text(
          '${snapshot.data.nickName}：',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}

class _SendButton extends StatefulWidget {
  PageContext context;
  Function(bool isEnd) onTap;
  TextEditingController controller;

  _SendButton({this.context, this.onTap, this.controller});

  @override
  __SendButtonState createState() => __SendButtonState();
}

class __SendButtonState extends State<_SendButton> {
  bool _isEnd = false;

  @override
  Widget build(BuildContext context) {
    var _contentController = widget.controller;
    var items = <Widget>[];
    if (widget.context.principal.roles.contains('platform:administrators')) {
      items.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 16,
              width: 28,
              child: Checkbox(
                value: _isEnd,
                onChanged: (v) {
                  _isEnd = v;
                  setState(() {});
                },
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _isEnd = !_isEnd;
                });
              },
              child: Text(
                '？是否结束该问题',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }
    items.add(
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: '发表你的意见和建议',
                hintStyle: TextStyle(
                  fontSize: 14,
                ),
                border: InputBorder.none,
                fillColor: Colors.white,
              ),
              maxLines: 4,
              style: TextStyle(
                fontSize: 14,
              ),
              onChanged: (value) {
                if (mounted) {
                  setState(() {});
                }
              },
            ),
          ),
          SizedBox(
            width: 10,
          ),
          OutlineButton(
            onPressed: StringUtil.isEmpty(_contentController.text)
                ? null
                : () {
                    widget.onTap(_isEnd);
                  },
            child: Text('发送'),
          ),
        ],
      ),
    );
    return Column(
      children: items,
    );
  }
}
