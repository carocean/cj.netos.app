import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoadIndicator extends StatefulWidget {
  Widget child;
  Future<void> Function() load;

  LoadIndicator({
    this.child,
    this.load,
  });

  @override
  _LoadIndicatorState createState() => _LoadIndicatorState();
}

class _LoadIndicatorState extends State<LoadIndicator> {
  ScrollController _controller;
  Widget _child;
  Future<void> Function() _load;
  bool _showMore = false;

  @override
  void initState() {
    _child = widget.child;
    _load = widget.load;
    _controller = ScrollController();
    _controller.addListener(() {
      if (_showMore) {
        return;
      }
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        print('滑动到了最底部${_controller.position.pixels}');
        if (mounted) {
          setState(() {
            _showMore = true;
          });
        }
        if (_load == null) {
          if (mounted) {
            setState(() {
              _showMore = false;
            });
          }
          return;
        }
        _load().then((value) {
          if (mounted) {
            setState(() {
              _showMore = false;
            });
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LoadIndicator oldWidget) {
    if (oldWidget.child != widget.child || oldWidget.load != widget.load) {
      _child = widget.child;
      _load = widget.load;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var items = <Widget>[
      _child,
    ];
    if (_showMore) {
      items.add(
        SizedBox(
          height: 20,
        ),
      );
      items.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '正在加载...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
      items.add(
        SizedBox(
          height: 20,
        ),
      );
    }
    return SingleChildScrollView(
      controller: _controller,
      child: Column(
        children: items,
      ),
    );
  }
}
