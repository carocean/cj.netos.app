import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';

class WorkflowDetails extends StatefulWidget {
  PageContext context;

  WorkflowDetails({this.context});

  @override
  _WorkflowDetailsState createState() => _WorkflowDetailsState();
}

class _WorkflowDetailsState extends State<WorkflowDetails> {
  @override
  Widget build(BuildContext context) {
    Workflow workflow = widget.context.parameters['workflow'];
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            title: Text(workflow.name),
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 20,
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Image.network(
                '${workflow.icon}?accessToken=${widget.context.principal.accessToken}',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 10,
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Text(
                '${workflow.id}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 5,
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Text(
                '${workflow.creator}',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 10,
            ),
          ),
          SliverFillRemaining(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Text(
                      '说明:',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  Text('${workflow.note}'),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
