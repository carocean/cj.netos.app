import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';

class RechargeResultPage extends StatelessWidget {
  PageContext context;

  RechargeResultPage({this.context});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('支付结果'),
        elevation: 0.0,
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              '${this.context.parameters['message'] ?? ''}',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
