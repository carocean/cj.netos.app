import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/framework.dart';

///显示程序的一般错误信息
class GberaError extends StatefulWidget {
  final PageContext context;

  GberaError({this.context});

  @override
  _GberaErrorState createState() => _GberaErrorState();
}

class _GberaErrorState extends State<GberaError> {
  @override
  Widget build(BuildContext context) {
    var params = this.widget.context.parameters;
    var error = params['error'];
    var massage = '';
    int status = 500;
    var cause = '';
    if (error is OpenportsException) {
      status = error.state;
      massage = error.message;
      cause = error.cause;
    } else {
      massage = error?.toString();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.context.page?.title,
        ),
        titleSpacing: 0,
        elevation: 0.0,
        automaticallyImplyLeading: true,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        constraints: BoxConstraints.expand(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('$status $massage',style: TextStyle(fontSize: 16,color: Colors.red,),),
          ],
        ),
      ),
    );
  }
}
