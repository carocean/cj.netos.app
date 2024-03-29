import 'package:flutter/material.dart';
import 'package:framework/core_lib/_page_context.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/portals/gbera/parts/CardItem.dart';

class GeoSetUpdateRate extends StatefulWidget {
  PageContext context;

  GeoSetUpdateRate({this.context});

  @override
  _GeoSetUpdateRateState createState() => _GeoSetUpdateRateState();
}

class _GeoSetUpdateRateState extends State<GeoSetUpdateRate> {
  TextEditingController _distanceController;
  bool _enableCheckButton = false;

  @override
  void initState() {
    _distanceController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('更新距离'),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            onPressed: !_enableCheckButton
                ? null
                : () {
                    _enableCheckButton = false;
                    widget.context.backward(result: {
                      'distance': int.parse(_distanceController.text),
                    });
                  },
            icon: Icon(
              Icons.check,
              color: _enableCheckButton ? Colors.green : Colors.grey[400],
            ),
          ),
        ],
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                top: 10,
                bottom: 10,
              ),
              child: Text(
                '更新距离指离开前次位置多少米才通知更新。移动速度越快，距离越短更新就越频繁，太频繁比较耗能，一般建议10米',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 15,
                  top: 10,
                  right: 15,
                ),
                constraints: BoxConstraints.expand(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Text(
                        '更新距离',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Flexible(
                      //解决了无法计算边界问题
                      fit: FlexFit.loose,
                      child: TextField(
                        controller: _distanceController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true,signed: true),
                        autofocus: true,
                        onSubmitted: (v) {
                          print(v);
                        },
                        onEditingComplete: () {
                          print('----');
                        },
                        onChanged: (v) {
                          if (StringUtil.isEmpty(_distanceController.text)) {
                            _enableCheckButton = false;
                          } else {
                            _enableCheckButton = true;
                          }
                          setState(() {});
                        },
                        style: TextStyle(
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: '输入更新距离，单位米',
                          hintStyle: TextStyle(
                            fontSize: 15,
                          ),
                          contentPadding: EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
