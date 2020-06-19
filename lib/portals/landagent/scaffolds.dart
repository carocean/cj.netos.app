import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';

class LandagentScaffold extends StatefulWidget {
  PageContext context;

  LandagentScaffold({this.context});

  @override
  _LandagentScaffoldState createState() => _LandagentScaffoldState();
}

class _LandagentScaffoldState extends State<LandagentScaffold> {
  int _selectedIndex = 0;
  List<Widget> _parts = [];

  @override
  void initState() {
    _parts.add(
      widget.context.part('/desktop', context),
    );
    _parts.add(
      widget.context.part('/market', context),
    );
    _parts.add(
      widget.context.part('/mine', context),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _parts[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            title: Text('桌面'),
            icon: Icon(Icons.dashboard),
          ),
          BottomNavigationBarItem(
            title: Text('纹银'),
            icon: Icon(FontAwesomeIcons.wonSign,size: 20,),
          ),
          BottomNavigationBarItem(
            title: Text('我'),
            icon: Icon(Icons.person),
          ),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.black26,
        selectedItemColor: Colors.blue[700],
        showUnselectedLabels: true,
        showSelectedLabels: true,
        iconSize: 24,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          _selectedIndex = index;
          setState(() {});
        },
      ),
    );
  }
}
