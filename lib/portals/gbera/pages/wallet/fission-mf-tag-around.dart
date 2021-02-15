import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:framework/core_lib/_page_context.dart';

class FissionMFAroundDialog extends StatefulWidget {
  PageContext context;

  FissionMFAroundDialog({this.context});

  @override
  _FissionMFAroundDialogState createState() => _FissionMFAroundDialogState();
}

class _FissionMFAroundDialogState extends State<FissionMFAroundDialog> {
  List<AroundRange> _ranges = [];

  @override
  void initState() {
    _ranges.addAll([
      AroundRange(
        id: '500',
        radius: 500,
        label: '500米',
      ),
      AroundRange(
        id: '1000',
        radius: 1000,
        label: '1公里',
      ),
      AroundRange(
        id: '2000',
        radius: 2000,
        label: '2公里',
      ),
      AroundRange(
        id: '5000',
        radius: 5000,
        label: '5公里',
      ),
      AroundRange(
        id: '10000',
        radius: 10000,
        label: '10公里',
      ),
      AroundRange(
        id: '15000',
        radius: 15000,
        label: '15公里',
      ),
    ]);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选择范围'),
        elevation: 0,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _ranges.map((e) {
                  return InkWell(
                    onTap: (){
                      widget.context.backward(result: e);
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 15,
                            bottom: 15,
                          ),
                          child: Text('${e.label}'),
                        ),
                        Divider(
                          height: 1,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          InkWell(
            onTap: (){
              widget.context.backward();
            },
            child: Container(
              height: 70,
              color: Colors.white,
              alignment: Alignment.center,
              child: Text('取消'),
            ),
          ),
        ],
      ),
    );
  }
}

class AroundRange {
  String id;
  String label;
  double radius;

  AroundRange({this.id, this.label, this.radius});
}
