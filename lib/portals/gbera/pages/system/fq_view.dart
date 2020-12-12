import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/medias_widget.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_helper.dart';
import 'package:uuid/uuid.dart';

class FQView extends StatefulWidget {
  PageContext context;

  FQView({this.context});

  @override
  _FQViewState createState() => _FQViewState();
}

class _FQViewState extends State<FQView> {
  HelpFormOR _form;
  bool _isHelpful = false;
  bool _isHelpless = false;

  @override
  void initState() {
    _form = widget.context.parameters['form'];
    _load();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _load() async {
    IHelperRemote helperRemote =
        widget.context.site.getService('/feedback/helper');
    _isHelpful = await helperRemote.isHelpful(_form.id);
    _isHelpless = await helperRemote.isHelpless(_form.id);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _setHelpful() async {
    IHelperRemote helperRemote =
        widget.context.site.getService('/feedback/helper');
    await helperRemote.setHelpfull(_form.id);
    await _load();
  }

  Future<void> _setHelpless() async {
    IHelperRemote helperRemote =
        widget.context.site.getService('/feedback/helper');
    await helperRemote.setHelpless(_form.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
      ),
      // resizeToAvoidBottomPadding: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Text(
                '${_form.title ?? ''}',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: '',
                        children: [
                          TextSpan(
                            text: '${_form.content ?? ''}',
                          ),
                        ],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _renderAttachs(),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RaisedButton(
                      onPressed: () {
                        _setHelpful();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.thumb_up,
                            size: 14,
                            color: _isHelpful ? Colors.green : Colors.grey[700],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '有帮助',
                            style: TextStyle(
                              color:
                                  _isHelpful ? Colors.green : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: RaisedButton(
                      onPressed: () {
                        _setHelpless();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.thumb_down,
                            size: 14,
                            color:
                                _isHelpless ? Colors.green : Colors.grey[700],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '没帮助',
                            style: TextStyle(
                              color:
                              _isHelpless ? Colors.green : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
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

  Widget _renderAttachs() {
    var attachs = _form.attachments;
    if (attachs == null) {
      return SizedBox(
        width: 0,
        height: 0,
      );
    }
    var items = <Widget>[];
    items.add(
      SizedBox(
        height: 20,
      ),
    );
    items.add(
      Container(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        alignment: Alignment.bottomLeft,
        child: Text(
          '用法',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
    );
    items.add(
      SizedBox(
        height: 20,
        child: Divider(
          height: 1,
        ),
      ),
    );
    attachs.forEach((attach) {
      items.add(
        Padding(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(attach.text ?? ''),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              MediaWidget(
                [
                  MediaSrc(
                    id: Uuid().v1(),
                    type: 'image',
                    text: '',
                    sourceType: 'image',
                    src: attach.url,
                  ),
                ],
                widget.context,
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
    });
    return Column(
      children: items,
    );
  }
}
