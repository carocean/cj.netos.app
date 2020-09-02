import 'package:framework/framework.dart';
import 'package:netos_app/system/local/dao/daos.dart';
import 'package:netos_app/system/local/dao/database.dart';
import 'package:uuid/uuid.dart';

import '../../../../system/local/entities.dart';
import '../remotes.dart';
import '../services.dart';

class ChannelPinService implements IChannelPinService, IServiceBuilder {
  IChannelPinDAO channelPinDAO;
  IChannelInputPersonDAO inputPersonDAO;
  IChannelOutputPersonDAO outputPersonDAO;
  IServiceProvider site;
  IChannelRemote channelRemote;

  UserPrincipal get principal => site.getService('@.principal');

  @override
  builder(IServiceProvider site) {
    this.site = site;
    AppDatabase db = site.getService('@.db');
    channelPinDAO = db.channelPinDAO;
    inputPersonDAO = db.channelInputPersonDAO;
    outputPersonDAO = db.channelOutputPersonDAO;
    channelRemote = site.getService('/remote/channels');
  }

  @override
  Future<Function> removePin(String channelid) async {
    await channelPinDAO.remove(channelid, principal?.person);
  }

  @override
  Future<List<ChannelOutputPerson>> pageOutputPerson(
      String channelid, int limit, int offset) async {
    return await this
        .outputPersonDAO
        .pageOutputPerson(channelid, principal?.person, limit, offset);
  }

  @override
  Future<List<ChannelOutputPerson>> listOutputPerson(String channelid) async {
    return await this
        .outputPersonDAO
        .listOutputPerson(channelid, principal?.person);
  }

  @override
  Future<List<ChannelInputPerson>> listInputPerson(String channelid) async {
    return await this
        .inputPersonDAO
        .listInputPerson(channelid, principal?.person);
  }

  @override
  Future<Function> removeOutputPerson(String person, String channelid) async {
    await this
        .outputPersonDAO
        .removeOutputPerson(person, channelid, principal?.person);
    await channelRemote.removeOutputPerson(person, channelid);
  }

  @override
  Future<Function> emptyOutputPersons(String channelid) async {
    await this.outputPersonDAO.emptyOutputPersons(channelid, principal?.person);
  }

  @override
  Future<Function> emptyInputPersons(String channelid) async {
    await this.inputPersonDAO.emptyInputPersons(channelid, principal?.person);
  }

  @override
  Future<Function> addOutputPerson(ChannelOutputPerson person) async {
    await this.outputPersonDAO.addOutputPerson(person);
    await channelRemote.addOutputPerson(person.person, person.channel);
  }

  @override
  Future<List<ChannelInputPerson>> pageInputPerson(
      String channelid, int limit, int offset) async {
    return await this
        .inputPersonDAO
        .pageInputPerson(channelid, principal?.person, limit, offset);
  }

  @override
  Future<Function> removeInputPerson(String person, String channelid) async {
    await this
        .inputPersonDAO
        .removeInputPerson(person, channelid, principal?.person);
    await channelRemote.removeInputPerson(person, channelid);
  }

  @override
  Future<Function> addInputPerson(ChannelInputPerson person) async {
    await this.inputPersonDAO.addInputPerson(person);
    await channelRemote.addInputPerson(person.person, person.channel);
  }

  @override
  Future<Function> updateInputPersonRights(
      String official, String channel, String rights) async {
    await inputPersonDAO.updateInputPersonRights(
        rights, official, channel, principal.person);
  }

  @override
  Future<ChannelInputPerson> getInputPerson(String official, channel) async {
    return await inputPersonDAO.getInputPerson(
        official, channel, principal.person);
  }

  @override
  Future<ChannelInputPerson> getLastInputPerson(String channel) async {
    return await inputPersonDAO.getLastInputPerson(channel, principal.person);
  }

  @override
  Future<bool> existsInputPerson(String person, String channel) async {
    var iperson =
        await inputPersonDAO.getInputPerson(person, channel, principal.person);
    return iperson == null ? false : true;
  }


  @override
  Future<ChannelOutputPerson> getLastOutputPerson(String channel) async{
    return await outputPersonDAO.getLastOutputPerson(channel,principal.person);
  }

  @override
  Future<bool> existsOutputPerson(String person, String channel) async {
    var operson = await outputPersonDAO.getOutputPerson(
        person, channel, principal.person);
    return operson == null ? false : true;
  }

  @override
  Future<Function> setOutputWechatHaoYouSelector(
      String channelid, bool isSet) async {}

  @override
  Future<Function> setOutputWechatCircleSelector(
      String channelid, bool isSet) async {}

  @override
  Future<Function> setOutputGeoSelector(String channelid, bool isSet) async {
    String v = isSet ? 'true' : 'false';
    await this
        .channelPinDAO
        .setOutputGeoSelector(v, channelid, principal?.person);
    await channelRemote.updateOutGeoSelector(channelid, v);
  }

  @override
  Future<Function> setOutputPersonSelector(String channelid,
      PinPersonsSettingsStrategy outsitePersonsSettingStrategy) async {
    var selector;
    switch (outsitePersonsSettingStrategy) {
      case PinPersonsSettingsStrategy.only_select:
        selector = 'only_select';
        break;
      case PinPersonsSettingsStrategy.all_except:
        selector = 'all_except';
        break;
    }
    await this
        .channelPinDAO
        .setOutputPersonSelector(selector, channelid, principal?.person);
    await channelRemote.updateOutPersonSelector(channelid, selector);
  }

  @override
  Future<bool> getOutputGeoSelector(String channelid) async {
    ChannelPin pin =
        await channelPinDAO.getChannelPin(channelid, principal?.person);
    if (pin == null) {
      return false;
    }
    if (StringUtil.isEmpty(pin.outGeoSelector)) {
      return false;
    }
    if (pin.outGeoSelector == 'true') {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<PinPersonsSettingsStrategy> getOutputPersonSelector(
      String channelid) async {
    ChannelPin pin =
        await channelPinDAO.getChannelPin(channelid, principal?.person);
    if (pin == null) {
      return PinPersonsSettingsStrategy.all_except;
    }
    if (StringUtil.isEmpty(pin.outPersonSelector)) {
      return PinPersonsSettingsStrategy.all_except;
    }
    switch (pin.outPersonSelector) {
      case 'all_except':
        return PinPersonsSettingsStrategy.all_except;
      case 'only_select':
        return PinPersonsSettingsStrategy.only_select;
    }
    return PinPersonsSettingsStrategy.all_except;
  }

  @override
  Future<PinPersonsSettingsStrategy> getInputPersonSelector(
      String channelid) async {
    // 输入用户选择策略永远是从指定管道的输入端的所有用户中排除
    return PinPersonsSettingsStrategy.only_select;
  }

  @override
  Future<Function> initChannelPin(String channelid) async {
    var pin =
        await this.channelPinDAO.getChannelPin(channelid, principal?.person);
    if (pin == null) {
      await this.channelPinDAO.addChannelPin(
            ChannelPin(
              '${Uuid().v1()}',
              channelid,
              'only_select',
              'only_select',
              null,
              null,
              null,
              null,
              null,
              null,
              principal?.person,
            ),
          );
    }
  }
}
