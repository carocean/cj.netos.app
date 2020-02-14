import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class ShoppingCartPage extends StatefulWidget {
  PageContext context;

  ShoppingCartPage({this.context});

  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            widget.context.backward();

          },
          icon: Icon(
            Icons.clear,
          ),
        ),
        title: Text(
          widget.context.page.title,
        ),
      ),
      body: Container(),
    );
  }
}
