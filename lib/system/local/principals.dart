import 'package:framework/framework.dart';

import 'dao/daos.dart';
import 'dao/database.dart';
import 'entities.dart';
import '../../portals/gbera/store/services.dart';

class PrincipalService implements IPrincipalService, IServiceBuilder {
  IPrincipalDAO principalDAO;
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  @override
  OnReadyCallback builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    principalDAO = db.principalDAO;
    return null;
  }

  @override
  Future<Function> updateAvatar(
      String person, localAvatar, String remoteAvatar) async {
    await principalDAO.updateAvatar(localAvatar, remoteAvatar, person);
  }

  @override
  Future<Function> emptyRefreshToken(String person) async {
    await principalDAO.emptyRefreshToken(person);
  }

  @override
  Future<List<Principal>> getAll() async {
    return await principalDAO.getAll();
  }

  @override
  Future<Principal> get(String person) async {
    return await principalDAO.get(person);
  }

  @override
  Future<Function> updateToken(
      String refreshToken, String accessToken, String person) async {
    await principalDAO.updateToken(refreshToken, accessToken, person);
  }

  @override
  Future<Function> updateNickName(String person, nickName) async {
    await principalDAO.updateNickname(nickName, person);
  }

  @override
  Future<Function> updateSignature(String person, String signature) async {
    await principalDAO.updateSignature(signature, person);
  }

  @override
  Future<Function> remove(String person) async {
    await principalDAO.remove(person);
  }

  @override
  Future<Function> add(Principal principal) async {
    await principalDAO.add(principal);
  }
}
