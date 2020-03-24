import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class CreateReceptor extends StatefulWidget {
  PageContext context;

  CreateReceptor({this.context});

  @override
  _CreateReceptorState createState() => _CreateReceptorState();
}

class _CreateReceptorState extends State<CreateReceptor> {
  @override
  Widget build(BuildContext context) {
    var category = widget.context.parameters['category'];
    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
        elevation: 0.0,
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            onPressed: () {},
            child: Text('完成'),
          ),
        ],
      ),
      body: Container(),
    );
  }
}
