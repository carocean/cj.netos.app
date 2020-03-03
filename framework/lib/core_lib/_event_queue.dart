import 'package:framework/core_lib/_frame.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:objectdb/objectdb.dart';

typedef OnQueueCount=void Function(int count);

class DefaultEventQueue implements IEventQueue {
  ObjectDB _db;
  OnQueueCount _onQueueCount;
  @override
  Future<void> open(String path) async {
    final db = ObjectDB(path);
    _db = await db.open();
    if(_onQueueCount!=null) {
      _onQueueCount(await count());
    }
  }

  @override
  Future<void> close() async {
    return await _db.close();
  }

  @override
  Future<void> add(Frame frame) async{
    Map doc = frame.toMap();
    var person = frame.head('to-person');
    if (!StringUtil.isEmpty(person)) {
      int pos = person.lastIndexOf('@');
      var appid = person.substring(pos + 1);
      doc['appid'] = appid;
    }
    await _db.insert(doc);
    if(_onQueueCount!=null) {
      _onQueueCount(await count());
  }
  }

  @override
  Future<List<Frame>> find(String person, String path) async {
    while (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    var query = {'headers.to-person': '$person', 'path': '$path'};
    List<Map<dynamic, dynamic>> list = await _db.find(query);
    List<Frame> retlist = [];
    for (var obj in list) {
      retlist.add(Frame.build(obj));
    }
    return retlist;
  }

  @override
  Future<void> removeWhere(Frame frame) async {
    var query = {
      'headers.command': '${frame.head('command')}',
      'headers.protocol': '${frame.head('protocol')}',
      'headers.url': '${frame.head('url')}',
    };
    await _db.remove(query);
    if(_onQueueCount!=null) {
      _onQueueCount(await count());
    }
  }

  @override
  Future<void> remove(Frame frame) async {
    var path = frame.path;
    while (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    var query = {
      'headers.to-person': '${frame.head('to-person')}',
      'path': '$path'
    };
    await _db.remove(query);
    if(_onQueueCount!=null) {
      _onQueueCount(await count());
    }
  }

  @override
  Future<List<Frame>> findAll() async {
    var query = {};
    List<Map<dynamic, dynamic>> list = await _db.find(query);
    List<Frame> retlist = [];
    for (var obj in list) {
      retlist.add(Frame.build(obj));
    }
    return retlist;
  }

  @override
  Future<int> count() async{
    var query = {};
    List<Map<dynamic, dynamic>> list = await _db.find(query);
    return list.length;
  }

  @override
  set onQueueCount(OnQueueCount onQueueCount) {
    _onQueueCount=onQueueCount;
  }
}


mixin IEventQueue {
  set onQueueCount(OnQueueCount onQueueCount);
  Future<void> open(String path);

  Future<void> close();

  Future<void> add(Frame frame) {}

  Future<List<Frame>> find(String person, String path) {}

  Future<void> remove(Frame frame) {}

  Future<void> removeWhere(Frame frame);

  Future<List<Frame>> findAll() {}

  Future<int>  count() {}

}
