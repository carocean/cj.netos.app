import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:framework/framework.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:netos_app/common/util.dart';
import 'package:netos_app/system/remote/persons.dart';
import 'package:uuid/uuid.dart';
import 'dao/daos.dart';
import 'dao/database.dart';
import 'entities.dart';
import '../../portals/gbera/store/services.dart';

class PersonService implements IPersonService, IServiceBuilder {
  IPersonDAO personDAO;
  IServiceProvider site;

  Dio get _dio => site.getService('@.http');

  String get _personUrl => site.getService('@.prop.ports.uc.person');

  UserPrincipal get principal => site.getService('@.principal');
  IPersonRemote personRemote;
  @override
  OnReadyCallback builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    personDAO = db.upstreamPersonDAO;
    personRemote = site.getService('/remote/persons');
    return null;
  }

  @override
  Future<int> count() async {
    var list = await this.personDAO.countPersons(principal?.person);
    return list.length;
  }

  @override
  Future<Person> getPerson(official) async {
    var person = await this.personDAO.getPerson(official, principal?.person);
    if (person == null) {
      person = await _fetchPerson(official);
      await addPerson(person);
    }
    return person;
  }

  Future<Person> _fetchPerson(official) async {
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
    var lavatar = await downloadPersonAvatar(
        dio: _dio, avatarUrl: '${obj['avatar']}?accessToken=${principal.accessToken}');
    var pos=official.lastIndexOf('.');
    String tenantid=official.substring(pos+1);
    return Person(
      Uuid().v1(),
      obj['person'],
      obj['uid'],
      obj['person'],
      obj['accountCode'],
      obj['appid'],
      tenantid,
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
  Future<void> addPerson(Person person) async {
    await personDAO.addPerson(person);
    await personRemote.addPerson(person);
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
