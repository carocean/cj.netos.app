import 'dart:ui' as ui;

import 'package:flutter/material.dart';

///系统出错页

class OpenportsException implements Exception {
  String message;
  int state;
  String cause;

  OpenportsException({
    this.message,
    this.state,
    this.cause,
  });

  @override
  String toString() {
    return "Openports [$state]: " + (message ?? "") + '\r\n' + (cause ?? "");
  }
}

class ErrorPage404 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '404啦!',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(
                ModalRoute.of(context).settings.name,
                style: TextStyle(
                  color: Colors.red,
                ),
                maxLines: 4,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RuntimeErrorWidget extends LeafRenderObjectWidget {
  FlutterErrorDetails flutterErrorDetails;

  RuntimeErrorWidget({this.flutterErrorDetails});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderErrorBox(flutterErrorDetails);
  }
}

class RenderErrorBox extends RenderBox {
  double _kMaxWidth = 100000.0;
  double _kMaxHeight = 100000.0;

  /// Creates a RenderErrorBox render object.
  ///
  /// A message can optionally be provided. If a message is provided, an attempt
  /// will be made to render the message when the box paints.
  RenderErrorBox([this.flutterErrorDetails]) {
    try {
      var message = flutterErrorDetails.exceptionAsString();
      if (message != '') {
        // This class is intentionally doing things using the low-level
        // primitives to avoid depending on any subsystems that may have ended
        // up in an unstable state -- after all, this class is mainly used when
        // things have gone wrong.
        //
        // Generally, the much better way to draw text in a RenderObject is to
        // use the TextPainter class. If you're looking for code to crib from,
        // see the paragraph.dart file and the RenderParagraph class.
        final ui.ParagraphBuilder builder = ui.ParagraphBuilder(paragraphStyle);
        builder.pushStyle(textStyle);
//        String _kLine = '\n\n────────────────────\n\n';
//        var arr = message.split('\r\n');
        builder.addText('NetOS系统错误：\r\n');
//        for (var msg in arr) {
//          var text='$msg$_kLine';
//          builder.addText(text);
//        }
        builder.addText(message);

        _paragraph = builder.build();
      }
    } catch (e) {
      // Intentionally left empty.
    }
  }

  /// The message to attempt to display at paint time.
  final FlutterErrorDetails flutterErrorDetails;

  ui.Paragraph _paragraph;

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _kMaxWidth;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _kMaxHeight;
  }

  @override
  bool get sizedByParent => true;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void performResize() {
    size = constraints.constrain(Size(_kMaxWidth, _kMaxHeight));
  }

  /// The color to use when painting the background of [RenderErrorBox] objects.
  static Color backgroundColor = const Color(0xF0900000);

  /// The text style to use when painting [RenderErrorBox] objects.
  static ui.TextStyle textStyle = ui.TextStyle(
    color: const Color(0xFFFFFF66),
    fontFamily: 'monospace',
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
  );

  /// The paragraph style to use when painting [RenderErrorBox] objects.
  static ui.ParagraphStyle paragraphStyle = ui.ParagraphStyle(
    height: 1.0,
    ellipsis: '...',
    maxLines: 8,
  );

  @override
  void paint(PaintingContext context, Offset offset) {
    var newOffset = Offset(offset.dx + 10, offset.dy + 10);
    try {
      context.canvas.drawRect(offset & size, Paint()..color = backgroundColor);
      double width;
      if (_paragraph != null) {
        // See the comment in the RenderErrorBox constructor. This is not the
        // code you want to be copying and pasting. :-)
        if (parent is RenderBox) {
          final RenderBox parentBox = parent;
          width = parentBox.size.width;
        } else {
          width = size.width;
        }
        _paragraph.layout(ui.ParagraphConstraints(width: width));

        context.canvas.drawParagraph(_paragraph, newOffset);
      }
    } catch (e) {
      // Intentionally left empty.
    }
  }
}
