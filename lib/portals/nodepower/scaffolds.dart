import 'package:flutter/material.dart';
import 'package:framework/framework.dart';

class NodePowerScaffold extends StatefulWidget {
  PageContext context;

  NodePowerScaffold({this.context});

  @override
  _NodePowerScaffoldState createState() => _NodePowerScaffoldState();
}

class _NodePowerScaffoldState extends State<NodePowerScaffold> {
  int _selectedIndex = 0;
  List<Widget> _parts = [];

  @override
  void initState() {
    _parts.add(
      widget.context.part('/desktop', context),
    );
    _parts.add(
      widget.context.part('/workbench', context),
    );
    _parts.add(
      widget.context.part('/colleagues', context),
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
            title: Text('工作台'),
            icon: Icon(Icons.apps),
          ),
          BottomNavigationBarItem(
            title: Text('同事'),
            icon: Icon(Icons.group),
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
