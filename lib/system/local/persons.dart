import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:framework/framework.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/system/local/cache/person_cache.dart';
import 'package:netos_app/system/remote/persons.dart';
import 'package:synchronized/synchronized.dart' as syn_lock;

import '../../portals/gbera/store/services.dart';
import 'dao/daos.dart';
import 'dao/database.dart';
import 'entities.dart';

class PersonService implements IPersonService, IServiceBuilder {
  IPersonDAO personDAO;
  IServiceProvider site;

  Dio get _dio => site.getService('@.http');

  String get _personUrl => site.getService('@.prop.ports.uc.person');

  UserPrincipal get principal => site.getService('@.principal');
  IPersonRemote personRemote;
  IPersonCache personCache;

  @override
  builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    personDAO = db.upstreamPersonDAO;
    personRemote = site.getService('/remote/persons');
    personCache = site.getService('/cache/persons');
    return null;
  }

  @override
  Future<int> count() async {
    var list = await this.personDAO.countPersons(principal?.person);
    return list.length;
  }

  @override
  Future<Person> getPerson(official, {bool isDownloadAvatar = false}) async {
    Person person = await this.personDAO.getPerson(official, principal?.person);
    if (person == null) {
      person = await personCache.get(official);
      if (person == null) {
        person =
            await fetchPerson(official, isDownloadAvatar: isDownloadAvatar);
      }
    }
    return person;
  }

  @override
  Future<Function> updateRights(String official, rights) async {
    await personDAO.updateRights(rights, principal.person, official);
  }

  @override
  Future<Person> fetchPerson(official, {bool isDownloadAvatar = false}) async {
    var response = await _dio.get(
      _personUrl,
      options: Options(
        headers: {
          'Rest-Command': 'findPerson',
          'cjtoken': principal.accessToken,
        },
      ),
      queryParameters: {
        'person': official,
      },
    );
    if (response.statusCode >= 400) {
      throw FlutterError('${response.statusCode} ${response.statusMessage}');
    }
    var data = response.data;
    var content = jsonDecode(data);
    if (content['status'] >= 400) {
      throw FlutterError('${content['status']} ${content['message']}');
    }
    var dataText = content['dataText'];
    var obj = jsonDecode(dataText);
    var lavatar = obj['avatar'];
    if (isDownloadAvatar) {
      lavatar = '${obj['avatar']}?accessToken=${principal.accessToken}';
      lavatar = await downloadPersonAvatar(dio: _dio, avatarUrl: lavatar);
    }
    return Person(
      obj['person'],
      obj['uid'],
      obj['accountCode'],
      obj['appid'],
      lavatar,
      null,
      obj['nickName'],
      obj['signature'],
      PinyinHelper.getPinyin(obj['nickName']),
      principal.person,
    );
  }

  @override
  Future<Person> getPersonByUID(String uid) async {
    return await this.personDAO.getPersonByUID(principal?.person, uid);
  }

  @override
  Future<void> removePerson(String person) async {
    await this.personDAO.removePerson(person, this.principal.person);
    await personRemote.removePerson(person);
  }

  @override
  Future<List<Person>> getAllPerson() async {
    return await this.personDAO.getAllPerson(principal?.person);
  }

  @override
  Future<List<Person>> pagePersonLikeName(
      String name, int limit, int offset) async {
    return await this
        .personDAO
        .pagePersonLikeName(principal?.person, name, name, name, limit, offset);
  }

  @override
  Future<List<Person>> pagePerson(int limit, int offset) async {
    return await this.personDAO.pagePerson(principal?.person, limit, offset);
  }

  @override
  Future<List<Person>> listPersonWith(List<String> personList) async {
    return await this.personDAO.listPersonWith(principal?.person, personList);
  }

  @override
  Future<List<Person>> pagePersonWith(
      List<String> personList, int persons_limit, int persons_offset) async {
    syn_lock.Lock lock = syn_lock.Lock();
    return await lock.synchronized(() async {
      List<String> officials = [];
      for (String p in personList) {
        Person person = await lock.synchronized(() async {
          return await personDAO.getPerson(p, principal?.person);
        });
        if (person == null) {
          person = await lock.synchronized(() async {
            return await fetchPerson(p, isDownloadAvatar: true);
          });
          if (person != null) {
            await lock.synchronized(() async {
              await personDAO.addPerson(person);
            });
            officials.add(person.official);
          }
          continue;
        }
        officials.add(person.official);
      }
      return await lock.synchronized(() async {
        return await personDAO.pagePersonWith(
            principal?.person, officials, persons_limit, persons_offset);
      });
    });
  }

  @override
  Future<List<Person>> pagePersonWithout(
      List<String> personList, int persons_limit, int persons_offset) async {
    List<String> officials = [];
    for (String p in personList) {
      Person person = await personDAO.getPerson(p, principal?.person);
      if (person == null) {
        continue;
      }
      officials.add(person.official);
    }
    return await this.personDAO.pagePersonWithout(
        principal?.person, officials, persons_limit, persons_offset);
  }

  @override
  Future<void> addPerson(Person person, {bool isOnlyLocal = false}) async {
    await personDAO.addPerson(person);
    if (!isOnlyLocal) {
      await personRemote.addPerson(person);
    }
  }

  @override
  Future<void> empty() async {
    await this.personDAO.empty(principal?.person);
  }

  @override
  Future<bool> existsPerson(official) async {
    var person = await personDAO.getPerson(official, principal?.person);
    return person == null ? false : true;
  }
}
