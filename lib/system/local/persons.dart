import 'package:flutter/cupertino.dart';
import 'package:framework/framework.dart';
import 'dao/daos.dart';
import 'dao/database.dart';
import 'entities.dart';
import '../../portals/gbera/store/services.dart';

class PersonService implements IPersonService,IServiceBuilder {
  IPersonDAO personDAO;
  IServiceProvider site;

  UserPrincipal get principal => site.getService('@.principal');

  @override
  OnReadyCallback builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    personDAO = db.upstreamPersonDAO;
    return null;
  }

  @override
  Future<int> count() async {
    var list = await this.personDAO.countPersons(principal?.person);
    return list.length;
  }

  @override
  Future<Person> getPerson(official) async {
    return await this.personDAO.getPerson(official, principal?.person);
  }

  @override
  Future<Person> getPersonByUID(String uid) async {
    return await this.personDAO.getPersonByUID(principal?.person, uid);
  }

  @override
  Future<Person> getPersonFullName(String p) async {
    int pos = p.indexOf('@');
    String accountName = p.substring(0, pos);
    String remain = p.substring(pos + 1, p.length);
    pos = remain.lastIndexOf('.');
    String appid = remain.substring(0, pos);
    String tenantid = remain.substring(pos + 1, remain.length);
    return await personDAO.findPerson(
        principal?.person, accountName, appid, tenantid);
  }

  @override
  Future<List<Person>> getAllPerson() async {
    return await this.personDAO.getAllPerson(principal?.person);
  }

  @override
  Future<List<Person>> pagePersonLikeName(
      String name, int limit, int offset) async {
    return await this.personDAO.pagePersonLikeName(
        principal?.person, name, name, name, limit, offset);
  }

  @override
  Future<List<Person>> pagePerson(int limit, int offset) async {
    return await this
        .personDAO
        .pagePerson(principal?.person, limit, offset);
  }

  @override
  Future<List<Person>> listPersonWith(List<String> personList) async {
    List<String> officials = [];
    for (String p in personList) {
      int pos = p.indexOf('@');
      String accountName = p.substring(0, pos);
      String remain = p.substring(pos + 1, p.length);
      pos = remain.lastIndexOf('.');
      String appid = remain.substring(0, pos);
      String tenantid = remain.substring(pos + 1, remain.length);
      Person person = await personDAO.findPerson(
          principal?.person, accountName, appid, tenantid);
      if (person == null) {
        continue;
      }
      officials.add(person.official);
    }
    return await this
        .personDAO
        .listPersonWith(principal?.person, officials);
  }

  @override
  Future<List<Person>> pagePersonWithout(
      List<String> personList, int persons_limit, int persons_offset) async {
    List<String> officials = [];
    for (String p in personList) {
      int pos = p.indexOf('@');
      String accountName = p.substring(0, pos);
      String remain = p.substring(pos + 1, p.length);
      pos = remain.lastIndexOf('.');
      String appid = remain.substring(0, pos);
      String tenantid = remain.substring(pos + 1, remain.length);
      Person person = await personDAO.findPerson(
          principal?.person, accountName, appid, tenantid);
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
