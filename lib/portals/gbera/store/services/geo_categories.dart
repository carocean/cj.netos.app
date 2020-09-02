import 'package:framework/core_lib/_principal.dart';
import 'package:framework/core_lib/_utimate.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';
import 'package:netos_app/system/local/entities.dart';
import 'package:synchronized/synchronized.dart';

import '../services.dart';

class GeoCategoryLocal implements IGeoCategoryLocal, IServiceBuilder {
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');
  IGeoCategoryRemote categoryRemote;
  IGeoCategoryDAO geoCategoryDAO;

  @override
  Future<void> builder(IServiceProvider site) async {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    geoCategoryDAO = db.geoCategoryDAO;
    categoryRemote = site.getService('/remote/geo/categories');
  }

  @override
  Future<GeoCategoryOL> get(String category) async {
    Lock lock = Lock();
    return await lock.synchronized(() async {
      GeoCategoryOL categoryLocal = await lock.synchronized(() async {
        return await geoCategoryDAO.get(category, principal.person);
      });
      if (categoryLocal == null) {
        GeoCategoryOR categoryOnRemote = await lock.synchronized(() async {
          return await categoryRemote.getCategory(category);
        });
        categoryLocal = categoryOnRemote.toLocal(principal.person);
        await lock.synchronized(() async {
          await geoCategoryDAO.add(categoryLocal);
        });
      }
      return categoryLocal;
    });
  }

  @override
  Future<void> remove(String category) async {
    await geoCategoryDAO.remove(category, principal.person);
  }
}
