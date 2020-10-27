import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';

class WithdrawResultPage extends StatelessWidget {
  PageContext context;

  WithdrawResultPage({this.context});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('提现结果'),
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
