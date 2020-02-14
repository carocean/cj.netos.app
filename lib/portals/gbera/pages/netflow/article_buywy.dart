import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class BuyWYArticle extends StatefulWidget {
  PageContext context;

  BuyWYArticle({this.context});

  @override
  _BuyWYArticleState createState() => _BuyWYArticleState();
}

class _BuyWYArticleState extends State<BuyWYArticle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.context.page.title,),
      ),
      body: Container(),
    );
  }
}
