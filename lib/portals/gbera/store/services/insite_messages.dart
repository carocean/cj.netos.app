import 'package:framework/framework.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';

import '../../../../system/local/entities.dart';
import '../services.dart';

class InsiteMessageService implements IInsiteMessageService ,IServiceBuilder{
  IInsiteMessageDAO insiteMessageDAO;
  IServiceProvider site;

  UserPrincipal get principal=>site.getService('@.principal');
  @override
  OnReadyCallback builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    insiteMessageDAO = db.insiteMessageDAO;
  }

  @override
  Future<Function> empty() async {
    await insiteMessageDAO.empty(principal?.person);
  }

  @override
  Future<List<InsiteMessage>> getAllMessage() async {
    return await insiteMessageDAO.getAllMessage(principal?.person);
  }

  @override
  Future<List<InsiteMessage>> pageMessage(int pageSize, int currPage) async {
    return await insiteMessageDAO.pageMessage(principal?.person,pageSize, currPage);
  }

  @override
  Future<Function> addMessage(InsiteMessage message) async {
    await insiteMessageDAO.addMessage(message);
  }

  @override
  Future<bool> existsMessage(id) async {
    var msg = await insiteMessageDAO.getMessage(id,principal?.person);
    return msg == null ? false : true;
  }
}
