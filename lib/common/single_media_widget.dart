import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:framework/framework.dart';

class SingleMediaWidget extends StatefulWidget {
  PageContext context;
  String image;

  SingleMediaWidget({
    this.context,
    this.image,
  });

  @override
  _SingleMediaWidgetState createState() => _SingleMediaWidgetState();
}

class _SingleMediaWidgetState extends State<SingleMediaWidget> {
  @override
  Widget build(BuildContext context) {
    var src = widget.image;
    if (StringUtil.isEmpty(src)) {
      return Image.asset(
        'lib/portals/gbera/images/default_watting.gif',
        fit: BoxFit.cover,
      );
    }
    if (src.startsWith('/')) {
      return Image.file(
        File(src),
        fit: BoxFit.cover,
      );
    }
    if (src.startsWith('http')) {
      return FadeInImage.assetNetwork(
        placeholder: 'lib/portals/gbera/images/default_watting.gif',
        image: src,
        fit: BoxFit.cover,
      );
    }
    return Container();
  }
}
