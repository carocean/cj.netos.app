import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_helper.dart';
import 'package:netos_app/portals/gbera/store/remotes/feedback_woflow.dart';

class HelpFeedbackPage extends StatefulWidget {
  PageContext context;

  HelpFeedbackPage({this.context});

  @override
  _HelpFeedbackPageState createState() => _HelpFeedbackPageState();
}

class _HelpFeedbackPageState extends State<HelpFeedbackPage> {
  EasyRefreshController _controller;
  List<HelpFormOR> _helpForms = [];
  int _limit = 20, _offset = 0;

  @override
  void initState() {
    _controller = EasyRefreshController();
    _load();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    IHelperRemote helperRemote =
        widget.context.site.getService('/feedback/helper');
    var helpers = await helperRemote.pageHelpForm(_limit, _offset);
    if (helpers.isEmpty) {
      _controller.finishLoad(success: true, noMore: true);
      if (mounted) {
        setState(() {});
      }
    }
    _offset += helpers.length;
    _helpForms.addAll(helpers);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _removeHelpForm(HelpFormOR form) async {
    IHelperRemote helperRemote =
        widget.context.site.getService('/feedback/helper');
    await helperRemote.removeHelpForm(form.id);
    _helpForms.removeWhere((element) => element.id == form.id);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('帮助'),
        elevation: 0,
        titleSpacing: 0,
        actions: [
          FlatButton(
            onPressed: () {
              widget.context.forward('/feedback/helper/create').then((value) {
                _offset = 0;
                _helpForms.clear();
                _load();
              });
            },
            child: Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: EasyRefresh(
                controller: _controller,
                onLoad: _load,
                child: ListView(
                  shrinkWrap: true,
                  children: _renderHelps(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _renderHelps() {
    var items = <Widget>[];
    if (_helpForms.isEmpty) {
      items.add(
        SizedBox(
          height: 20,
        ),
      );
      items.add(
        Center(
          child: Text(
            '没有帮助',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      );
      return items;
    }
    for (var form in _helpForms) {
      items.add(
        Slidable(
          actionPane: SlidableDrawerActionPane(),
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: '删除',
              icon: Icons.delete,
              onTap: () {
                _removeHelpForm(form);
              },
            ),
          ],
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.context
                  .forward('/feedback/helper/view', arguments: {'form': form});
            },
            child: Padding(
              padding: EdgeInsets.only(
                top: 15,
                bottom: 15,
                left: 20,
                right: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${form.title}'),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      items.add(
        Divider(
          height: 1,
          indent: 20,
        ),
      );
    }
    return items;
  }
}
