import 'package:framework/framework.dart';
import 'package:lpinyin/lpinyin.dart';

import 'dao/daos.dart';
import 'dao/database.dart';
import 'entities.dart';
import '../../portals/gbera/store/services.dart';

class PrincipalService implements IPrincipalService, IServiceBuilder {
  IPrincipalDAO principalDAO;
  IPersonService personService;
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  @override
   builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    principalDAO = db.principalDAO;
    personService=site.getService('/gbera/persons');
    return null;
  }

  @override
  Future<Function> updateAvatar(
      String person, localAvatar, String remoteAvatar) async {
    await principalDAO.updateAvatar(localAvatar, remoteAvatar, person);
    await personService.updateAvatar(person, localAvatar);
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
    await personService.updateNickName(person, nickName);
    String pinyin = PinyinHelper.getPinyinE(nickName);
    await personService.updatePyname(person, pinyin);
  }

  @override
  Future<Function> updateSignature(String person, String signature) async {
    await principalDAO.updateSignature(signature, person);
    await personService.updateSignature(person, signature);
  }

  @override
  Future<Function> updateDevice(String person, String device) async{
    await principalDAO.updateDevice(device,person);
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
