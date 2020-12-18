import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/common/single_media_widget.dart';

class AcceptSharePage extends StatefulWidget {
  PageContext context;

  AcceptSharePage({this.context});

  @override
  _AcceptSharePageState createState() => _AcceptSharePageState();
}

class _AcceptSharePageState extends State<AcceptSharePage> {
  String _href;
  String _title;
  String _summary;
  String _leading;
  @override
  void initState() {
    var args=widget.context.parameters;
    _href=args['href'];
    _title=args['title'];
    _summary=args['summary'];
    _leading=args['leading'];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('地微发布'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: _rendContentPanel(),
          ),
          Expanded(child: Column(
            children: [],
          ),),
        ],
      ),
    );
  }
  Widget _rendContentPanel() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: SingleMediaWidget(
            context: widget.context,
            image: _leading,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_title ?? ''}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '${_summary ?? ''}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
