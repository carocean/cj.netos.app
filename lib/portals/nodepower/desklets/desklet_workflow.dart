import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:framework/core_lib/_desklet.dart';
import 'package:framework/core_lib/_page_context.dart';

class WorkflowDesklet extends StatefulWidget {
  PageContext context;
  Portlet portlet;
  Desklet desklet;

  WorkflowDesklet({this.context, this.portlet, this.desklet});

  @override
  _WorkflowDeskletState createState() => _WorkflowDeskletState();
}

class _WorkflowDeskletState extends State<WorkflowDesklet> {
  EasyRefreshController _controller;

  @override
  void initState() {
    _controller = EasyRefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onload() async {}

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 600,
        minHeight: 200,
      ),
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 5,
              left: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Image.network(
                  '${widget.portlet.imgSrc}?accessToken=${widget.context.principal.accessToken}',
                  width: 16,
                  height: 16,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 4,
                  ),
                  child: Text(
                    '${widget.portlet.title ?? ''}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(15),
              child: EasyRefresh.custom(
                controller: _controller,
                onLoad: _onload,
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: Center(
                                  child: Text('1'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        'xx',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '2:20',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text('xx'),
                                      Text.rich(
                                        TextSpan(
                                          text: '',
                                          children: [
                                            TextSpan(
                                              text: 'xx',
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                          child: Divider(
                            height: 1,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
