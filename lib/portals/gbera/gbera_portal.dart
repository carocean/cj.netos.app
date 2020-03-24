import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/avatar.dart';
import 'package:netos_app/portals/gbera/desklets/chats/avatar.dart';
import 'package:netos_app/portals/gbera/errors/errors.dart';
import 'package:netos_app/portals/gbera/pages/desktop.dart';
import 'package:netos_app/portals/gbera/pages/desktop/desklets_settings.dart';
import 'package:netos_app/portals/gbera/pages/desktop/desktop_settings.dart';
import 'package:netos_app/portals/gbera/pages/desktop/portlet_list.dart';
import 'package:netos_app/portals/gbera/pages/geosphere.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_create_receptor.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_select_category.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_discovery.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_fountain.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_publish_article.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_receptor.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_region.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_settings.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_yuanbao.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geosphere_portal.dart';
import 'package:netos_app/portals/gbera/pages/market.dart';
import 'package:netos_app/portals/gbera/pages/market/go_gogo.dart';
import 'package:netos_app/portals/gbera/pages/market/go_shopping_cart.dart';
import 'package:netos_app/portals/gbera/pages/market/select_gogogo_category.dart';
import 'package:netos_app/portals/gbera/pages/market/ty_exchange.dart';
import 'package:netos_app/portals/gbera/pages/market/ty_land_agent.dart';
import 'package:netos_app/portals/gbera/pages/market/ty_list.dart';
import 'package:netos_app/portals/gbera/pages/market/tz_exchange.dart';
import 'package:netos_app/portals/gbera/pages/market/tz_land_agent.dart';
import 'package:netos_app/portals/gbera/pages/market/tz_list.dart';
import 'package:netos_app/portals/gbera/pages/netflow.dart';
import 'package:netos_app/portals/gbera/pages/netflow/activies_channels.dart';
import 'package:netos_app/portals/gbera/pages/netflow/activies_gateway_settings.dart';
import 'package:netos_app/portals/gbera/pages/netflow/activies_microapps.dart';
import 'package:netos_app/portals/gbera/pages/netflow/activies_sites.dart';
import 'package:netos_app/portals/gbera/pages/netflow/article_buywy.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel_gateway.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel_popularize.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel_portal.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel_qrcode.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel_rename.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channels_of_user.dart';
import 'package:netos_app/portals/gbera/pages/netflow/create_channel.dart';
import 'package:netos_app/portals/gbera/pages/netflow/document_path.dart';
import 'package:netos_app/portals/gbera/pages/netflow/insite_approval.dart';
import 'package:netos_app/portals/gbera/pages/netflow/insite_messages.dart';
import 'package:netos_app/portals/gbera/pages/netflow/insite_persons.dart';
import 'package:netos_app/portals/gbera/pages/netflow/insite_persons_settings.dart';
import 'package:netos_app/portals/gbera/pages/netflow/outsite_persons.dart';
import 'package:netos_app/portals/gbera/pages/netflow/outsite_persons_settings.dart';
import 'package:netos_app/portals/gbera/pages/netflow/publish_article.dart';
import 'package:netos_app/portals/gbera/pages/netflow/scan_channel.dart';
import 'package:netos_app/portals/gbera/pages/netflow/search_channel.dart';
import 'package:netos_app/portals/gbera/pages/netflow/search_person.dart';
import 'package:netos_app/portals/gbera/pages/netflow/see_channelpin_persons.dart';
import 'package:netos_app/portals/gbera/pages/netflow/service_menu.dart';
import 'package:netos_app/portals/gbera/pages/netflow/settings_main.dart';
import 'package:netos_app/portals/gbera/pages/netflow/settings_persons.dart';
import 'package:netos_app/portals/gbera/pages/profile.dart';
import 'package:netos_app/portals/gbera/pages/profile/edit_nickname.dart';
import 'package:netos_app/portals/gbera/pages/profile/edit_realname.dart';
import 'package:netos_app/portals/gbera/pages/profile/edit_sex.dart';
import 'package:netos_app/portals/gbera/pages/profile/edit_signature.dart';
import 'package:netos_app/portals/gbera/pages/profile/editor.dart';
import 'package:netos_app/portals/gbera/pages/profile/more.dart';
import 'package:netos_app/portals/gbera/pages/profile/qrcode.dart';
import 'package:netos_app/portals/gbera/pages/site/friend_site.dart';
import 'package:netos_app/portals/gbera/pages/site/insite_request.dart';
import 'package:netos_app/portals/gbera/pages/site/marchant_site.dart';
import 'package:netos_app/portals/gbera/pages/site/micro_app.dart';
import 'package:netos_app/portals/gbera/pages/site/person_rights.dart';
import 'package:netos_app/portals/gbera/pages/site/personal_site.dart';
import 'package:netos_app/portals/gbera/pages/site/site_channelsite.dart';
import 'package:netos_app/portals/gbera/pages/system/about.dart';
import 'package:netos_app/portals/gbera/pages/system/contract.dart';
import 'package:netos_app/portals/gbera/pages/system/themes.dart';
import 'package:netos_app/portals/gbera/pages/tests/test_insite_messages.dart';
import 'package:netos_app/portals/gbera/pages/tests/test_persons.dart';
import 'package:netos_app/portals/gbera/pages/tests/test_services.dart';
import 'package:netos_app/portals/gbera/pages/users/account_login.dart';
import 'package:netos_app/portals/gbera/pages/users/accounts.dart';
import 'package:netos_app/portals/gbera/pages/users/add_account.dart';
import 'package:netos_app/portals/gbera/pages/users/app_accounts.dart';
import 'package:netos_app/portals/gbera/pages/users/edit_password.dart';
import 'package:netos_app/portals/gbera/pages/users/roles.dart';
import 'package:netos_app/portals/gbera/pages/users/user_list.dart';
import 'package:netos_app/portals/gbera/pages/viewers/channel_viewer.dart';
import 'package:netos_app/portals/gbera/pages/viewers/image_viewer.dart';
import 'package:netos_app/portals/gbera/pages/wallet.dart';
import 'package:netos_app/portals/gbera/pages/wallet/amount_settings.dart';
import 'package:netos_app/portals/gbera/pages/wallet/card_details.dart';
import 'package:netos_app/portals/gbera/pages/wallet/cards.dart';
import 'package:netos_app/portals/gbera/pages/wallet/cashout.dart';
import 'package:netos_app/portals/gbera/pages/wallet/change.dart';
import 'package:netos_app/portals/gbera/pages/wallet/change_bill.dart';
import 'package:netos_app/portals/gbera/pages/wallet/change_details.dart';
import 'package:netos_app/portals/gbera/pages/wallet/deposit.dart';
import 'package:netos_app/portals/gbera/pages/wallet/payables.dart';
import 'package:netos_app/portals/gbera/pages/wallet/receivables.dart';
import 'package:netos_app/portals/gbera/pages/wallet/ty.dart';
import 'package:netos_app/portals/gbera/pages/wallet/wy.dart';
import 'package:netos_app/portals/gbera/scaffolds.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_categories.dart';
import 'package:netos_app/portals/gbera/store/services.dart';
import 'package:netos_app/portals/gbera/store/services/channel_extra.dart';
import 'package:netos_app/portals/gbera/store/services/channel_messages.dart';
import 'package:netos_app/portals/gbera/store/services/channel_pin.dart';
import 'package:netos_app/portals/gbera/store/services/channels.dart';
import 'package:netos_app/portals/gbera/store/services/chat_rooms.dart';
import 'package:netos_app/portals/gbera/store/services/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/services/insite_messages.dart';
import 'package:netos_app/system/local/local_principals.dart';
import 'package:netos_app/system/local/persons.dart';
import 'package:netos_app/system/local/principals.dart';
import 'package:netos_app/common/icons.dart';
import 'package:netos_app/system/local/dao/database.dart';
import '../../system/entrypoint.dart';
import '../../system/register.dart';
import 'desklets/chats/add_friend.dart';
import 'desklets/chats/chat_talk.dart';
import 'desklets/chats/friend_page.dart';
import 'desklets/chats/import_persons.dart';
import 'desklets/chats/room_settings.dart';
import 'desklets/desklets.dart';
import 'pages/desktop/wallpappers.dart';
import 'pages/system/gbera_settings.dart';
import 'pages/users/account_viewer.dart';
import 'pages/wallet/ReceivablesRecord.dart';
import 'pages/wallet/receivables_details.dart';
import 'store/remotes/channels.dart';
import 'styles/green-styles.dart';
import 'styles/grey-styles.dart';

class GberaPortal {
  Portal buildPortal(IServiceProvider site) {
    return Portal(
      id: 'gbera',
      icon: GalleryIcons.shrine,
      title: '金证时代官方框架',
      defaultTheme: '/grey',
      builderSceneServices: (site) async {
        return <String, dynamic>{
          "/gbera/friends": FriendService(),
          '/netflow/channels': ChannelService(),
          '/insite/messages': InsiteMessageService(),
          '/channel/pin': ChannelPinService(),
          '/channel/messages': ChannelMessageService(),
          '/channel/messages/medias': ChannelMediaService(),
          '/channel/messages/likes': ChannelLikeService(),
          '/channel/messages/comments': ChannelCommentService(),
          '/chat/rooms': ChatRoomService(),
          '/chat/p2p/messages': P2PMessageService(),
          '/remote/channels': ChannelRemote(),
          '/remote/geo/categories': GeoCategoryRemote(),
          '/geosphere/receptors': GeoReceptorService(),
        };
      },
      builderShareServices: (site) async {
        return <String, dynamic>{};
      },
      buildThemes: (IServiceProvider site) => [
        ThemeStyle(
          title: '灰色',
          desc: '呈现淡灰色，接近白',
          url: '/grey',
          iconColor: Colors.grey[500],
          buildStyle: buildGreyStyles,
          buildTheme: (BuildContext context) {
            return ThemeData(
              backgroundColor: Color(0xFFF5F5f5),
              scaffoldBackgroundColor: Color(0xFFF5F5f5),
              brightness: Brightness.light,
              appBarTheme: AppBarTheme.of(context).copyWith(
                color: Color(0xFFF5F5f5),
                textTheme: TextTheme(
                  title: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                actionsIconTheme: IconThemeData(
                  color: Colors.grey[700],
                  opacity: 1,
                  size: 20,
                ),
                brightness: Brightness.light,
                iconTheme: IconThemeData(
                  color: Colors.grey[700],
                  opacity: 1,
                  size: 20,
                ),
                elevation: 1.0,
              ),
              primarySwatch: MaterialColor(
                0xFFF5F5f5,
                {
                  50: Color(0xFFE8F5E9),
                  100: Color(0xFFC8E6C9),
                  200: Color(0xFFA5D6A7),
                  300: Color(0xFF81C784),
                  400: Color(0xFF66BB6A),
                  500: Color(0xFF4CAF50),
                  600: Color(0xFF43A047),
                  700: Color(0xFF388E3C),
                  800: Color(0xFF2E7D32),
                  900: Color(0xFF1B5E20),
                },
              ),
            );
          },
        ),
        ThemeStyle(
          title: '绿色',
          desc: '呈现淡绿',
          url: '/green',
          iconColor: Colors.green[500],
          buildStyle: buildGreenStyles,
          buildTheme: (BuildContext context) {
            return ThemeData(
              backgroundColor: Color(0xFFE8F5E9),
              scaffoldBackgroundColor: Color(0xFFE8F5E9),
              appBarTheme: AppBarTheme.of(context).copyWith(
                color: Color(0xFFE8F5E9),
                textTheme: TextTheme(
                  title: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                actionsIconTheme: IconThemeData(
                  color: Colors.green,
                  opacity: 1,
                  size: 20,
                ),
                brightness: Brightness.light,
                iconTheme: IconThemeData(
                  color: Colors.green,
                  opacity: 1,
                  size: 20,
                ),
                elevation: 1.0,
              ),
              primarySwatch: MaterialColor(
                0xFF4CAF50,
                {
                  50: Color(0xFFE8F5E9),
                  100: Color(0xFFC8E6C9),
                  200: Color(0xFFA5D6A7),
                  300: Color(0xFF81C784),
                  400: Color(0xFF66BB6A),
                  500: Color(0xFF4CAF50),
                  600: Color(0xFF43A047),
                  700: Color(0xFF388E3C),
                  800: Color(0xFF2E7D32),
                  900: Color(0xFF1B5E20),
                },
              ),
            );
          },
        ),
      ],
      buildDesklets: buildDesklets,
      buildPages: (IServiceProvider site) => [
        Page(
          title: '控件，截取头像',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/widgets/avatar',
          buildPage: (PageContext pageContext) => GberaAvatar(
            context: pageContext,
          ),
        ),
        Page(
          title: '出错啦',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/error',
          buildPage: (PageContext pageContext) => GberaError(
            context: pageContext,
          ),
        ),
        Page(
          title: '金证时代',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/scaffold/withbottombar',
          buildPage: (PageContext pageContext) => WithBottomScaffold(
            context: pageContext,
          ),
        ),
        Page(
          title: '测试服务',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/test/services',
          buildPage: (PageContext pageContext) => TestServices(
            context: pageContext,
          ),
        ),
        Page(
          title: '测试公众',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/test/services/gbera/persons',
          buildPage: (PageContext pageContext) => TestUpstreamPersonService(
            context: pageContext,
          ),
        ),
        Page(
          title: '摸拟消息入站',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/test/services/insite/messages',
          buildPage: (PageContext pageContext) => TestInsiteMessages(
            context: pageContext,
          ),
        ),
        Page(
          title: '桌面',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/desktop',
          buildPage: (PageContext pageContext) => Desktop(
            context: pageContext,
          ),
        ),
        Page(
          title: '网流',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/netflow',
          buildPage: (PageContext pageContext) => Netflow(
            context: pageContext,
          ),
        ),
        Page(
          title: '管道',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/netflow/channel',
          buildPage: (PageContext pageContext) => ChannelPage(
            context: pageContext,
          ),
        ),
        Page(
          title: '购买服务',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/channel/article/buywy',
          buildPage: (PageContext pageContext) => BuyWYArticle(
            context: pageContext,
          ),
        ),
        Page(
          title: '重命名',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/netflow/channel/rename',
          buildPage: (PageContext pageContext) => RenameChannel(
            context: pageContext,
          ),
        ),
        Page(
          title: '二维码',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/netflow/channel/qrcode',
          buildPage: (PageContext pageContext) => ChannelQrcode(
            context: pageContext,
          ),
        ),
        Page(
          title: '推广',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/netflow/channel/popularize',
          buildPage: (PageContext pageContext) => PopularizeChannel(
            context: pageContext,
          ),
        ),
        Page(
          title: '新建管道',
          subtitle: '',
          icon: Icons.add,
          url: '/netflow/manager/create_channel',
          buildPage: (PageContext pageContext) => CreateChannel(
            context: pageContext,
          ),
        ),
        Page(
          title: '管道信息',
          subtitle: '',
          icon: FontAwesomeIcons.qrcode,
          url: '/netflow/manager/scan_channel',
          buildPage: (PageContext pageContext) => ScanChannel(
            context: pageContext,
          ),
        ),
        Page(
          title: '搜索管道',
          subtitle: '',
          icon: FontAwesomeIcons.search,
          url: '/netflow/manager/search_channel',
          buildPage: (PageContext pageContext) => SearchChannel(
            context: pageContext,
          ),
        ),
        Page(
          title: '网关管道',
          subtitle: '',
          icon: Icons.settings_input_composite,
          url: '/netflow/manager/channel_gateway',
          buildPage: (PageContext pageContext) => ChannelGateway(
            context: pageContext,
          ),
        ),
        Page(
          title: '活动设置',
          subtitle: '',
          icon: Icons.settings_input_composite,
          url: '/netflow/manager/settings',
          buildPage: (PageContext pageContext) => SettingsMain(
            context: pageContext,
          ),
        ),
        Page(
          title: '管道进口公众',
          subtitle: '覆盖我的管道的公众管道、查看他人的管道都是此页面，以权限控制显示',
          icon: Icons.settings_input_composite,
          url: '/netflow/channel/insite/persons',
          buildPage: (PageContext pageContext) => InsitePersons(
            context: pageContext,
          ),
        ),
        Page(
          title: '管道出口公众',
          subtitle: '覆盖我的管道的公众管道、查看他人的管道都是此页面，以权限控制显示',
          icon: Icons.settings_input_composite,
          url: '/netflow/channel/outsite/persons',
          buildPage: (PageContext pageContext) => OutsitePersons(
            context: pageContext,
          ),
        ),
        Page(
          title: '公众',
          subtitle: '',
          icon: Icons.settings_input_composite,
          url: '/netflow/channel/settings/persons',
          buildPage: (PageContext pageContext) => SettingsPersons(
            context: pageContext,
          ),
        ),
        Page(
          title: '公众活动',
          subtitle: '',
          icon: Icons.settings_input_composite,
          url: '/netflow/publics/activities',
          buildPage: (PageContext pageContext) => InsiteMessagePage(
            pageContext: pageContext,
          ),
        ),
        Page(
          title: '发布文章',
          subtitle: '',
          icon: Icons.art_track,
          url: '/netflow/channel/publish_article',
          buildPage: (PageContext pageContext) => ChannelPublishArticle(
            context: pageContext,
          ),
        ),
        Page(
          title: '管道活动门户',
          subtitle: '',
          icon: Icons.art_track,
          url: '/netflow/portal/channel',
          buildPage: (PageContext pageContext) => ChannelPortal(
            context: pageContext,
          ),
        ),
        Page(
          title: '服务清单',
          subtitle: '',
          desc: '为个人站点或商户站点提供的服务列表',
          icon: Icons.art_track,
          url: '/netflow/channel/serviceMenu',
          buildPage: (PageContext pageContext) => ServiceMenu(
            context: pageContext,
          ),
        ),
        Page(
          title: '微站的绑定管道',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/site/output',
          buildPage: (PageContext pageContext) => SiteChannelBinder(
            context: pageContext,
          ),
        ),
        Page(
          title: '微应用',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/micro/app',
          buildPage: (PageContext pageContext) => MicroApp(
            context: pageContext,
          ),
        ),
        Page(
          title: '商户站点',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/site/marchant',
          buildPage: (PageContext pageContext) => MarchantSite(
            context: pageContext,
          ),
        ),
        Page(
          title: '个人站点',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/site/personal',
          buildPage: (PageContext pageContext) => PersonalSite(
            context: pageContext,
          ),
        ),
        Page(
          title: '公众网流权限',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/site/personal/rights',
          buildPage: (PageContext pageContext) => PersonRights(
            context: pageContext,
          ),
        ),
        Page(
          title: '朋友站点',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/site/friend',
          buildPage: (PageContext pageContext) => FriendSite(
            context: pageContext,
          ),
        ),
        Page(
          title: '入站申请',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/site/insite/request',
          buildPage: (PageContext pageContext) => InSiteRequest(
            context: pageContext,
          ),
        ),
        Page(
          title: '入站审批',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/site/insite/approvals',
          buildPage: (PageContext pageContext) => InsiteApprovals(
            context: pageContext,
          ),
        ),
        Page(
          title: '微站',
          subtitle: '用于活动设置中查看我的微站列表',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/activies/sites',
          buildPage: (PageContext pageContext) => ActivitiesSites(
            context: pageContext,
          ),
        ),
        Page(
          title: '管道',
          subtitle: '用于活动设置中查看我的管道列表',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/activies/channels',
          buildPage: (PageContext pageContext) => ActivitiesChannels(
            context: pageContext,
          ),
        ),
        Page(
          title: '文档传播路径',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/document/path',
          buildPage: (PageContext pageContext) => DocumentPath(
            context: pageContext,
          ),
        ),
        Page(
          title: '出口公众权限设置',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/outsite/persons_settings',
          buildPage: (PageContext pageContext) => OutsitePersonsSettings(
            context: pageContext,
          ),
        ),
        Page(
          title: '进口公众权限设置',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/insite/persons_settings',
          buildPage: (PageContext pageContext) => InsitePersonsSettings(
            context: pageContext,
          ),
        ),
        Page(
          title: '管道端口用户查看器',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/pin/see_persons',
          buildPage: (PageContext pageContext) => SeeChannelPinPersons(
            context: pageContext,
          ),
        ),
        Page(
          title: '微应用',
          subtitle: '用于活动设置中查看我的微应用列表',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/activies/microapps',
          buildPage: (PageContext pageContext) => ActivitiesMicroapps(
            context: pageContext,
          ),
        ),
        Page(
          title: '网关',
          subtitle: '用于活动设置中拒绝接收用户或管道发来的信息',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/activities/gateway_settings',
          buildPage: (PageContext pageContext) => ActivitiesGatewaySettings(
            context: pageContext,
          ),
        ),
        Page(
          title: '图片查看器',
          subtitle: '',
          desc: '',
          icon: Icons.image,
          url: '/images/viewer',
          buildRoute:
              (RouteSettings settings, Page page, IServiceProvider site) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) {
                PageContext pageContext = PageContext(
                  page: page,
                  site: site,
                  context: context,
                );
                return new ImageViewer(
                  context: pageContext,
                );
              },
              fullscreenDialog: true,
            );
          },
        ),
        Page(
          title: '管道看版',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/channel/viewer',
          buildPage: (PageContext pageContext) => ChannelViewer(
            context: pageContext,
          ),
        ),
        Page(
          title: '他的管道',
          subtitle: '用于活动网关中查看他的管道列表',
          desc: '',
          icon: Icons.art_track,
          url: '/channel/list_of_user',
          buildPage: (PageContext pageContext) => ChannelsOfUser(
            context: pageContext,
          ),
        ),
        Page(
          title: '市场',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/market',
          buildPage: (PageContext pageContext) => Market(
            context: pageContext,
          ),
        ),
        Page(
          title: '地微',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere',
          buildPage: (PageContext pageContext) => Geosphere(
            context: pageContext,
          ),
        ),
        Page(
          title: '地理感知器',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/receptor',
          buildPage: (PageContext pageContext) => GeoReceptorWidget(
            context: pageContext,
          ),
        ),
        Page(
          title: '选择地理感知器分类',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/category/select',
          buildPage: (PageContext pageContext) => SelectGeoCategory(
            context: pageContext,
          ),
        ),
        Page(
          title: '新创地理感知器',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/receptor/create',
          buildPage: (PageContext pageContext) => CreateReceptor(
            context: pageContext,
          ),
        ),
        Page(
          title: '发布文章',
          subtitle: '',
          icon: Icons.art_track,
          url: '/geosphere/publish_article',
          buildPage: (PageContext pageContext) => GeospherePublishArticle(
            context: pageContext,
          ),
        ),
        Page(
          title: '地圈动态门户',
          subtitle: '',
          icon: Icons.art_track,
          url: '/geosphere/portal',
          buildPage: (PageContext pageContext) => GeospherePortal(
            context: pageContext,
          ),
        ),
        Page(
          title: '地方市场',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/region',
          buildPage: (PageContext pageContext) => GeoRegion(
            context: pageContext,
          ),
        ),
        Page(
          title: '实时发现',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/discovery',
          buildPage: (PageContext pageContext) => GeoDiscovery(
            context: pageContext,
          ),
        ),
        Page(
          title: '偏好设置',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/profile',
          buildPage: (PageContext pageContext) => Profile(
            context: pageContext,
          ),
//              buildRoute:
//                  (RouteSettings settings, Page page, IServiceProvider site) {
//                SlideTransition createTransition(
//                    Animation<double> animation, Widget child) {
//                  return new SlideTransition(
//                    position: new Tween<Offset>(
//                      begin: const Offset(1.0, 0.0),
//                      end: const Offset(0.0, 0.0),
//                    ).animate(animation),
//                    child: child,
//                  );
//                }
//
//                return PageRouteBuilder(
//                  settings: settings,
//                  pageBuilder: (BuildContext context,
//                      Animation<double> animation,
//                      Animation<double> secondaryAnimation) {
//                    // 跳转的路由对象
//                    PageContext pageContext = PageContext(
//                      page: page,
//                      site: site,
//                      context: context,
//                    );
//                    return new Profile(
//                      context: pageContext,
//                    );
//                  },
//                  transitionsBuilder: (
//                    BuildContext context,
//                    Animation<double> animation,
//                    Animation<double> secondaryAnimation,
//                    Widget child,
//                  ) {
//                    return createTransition(animation, child);
//                  },
//                );
//              },
        ),
        Page(
          title: '我的二维码',
          subtitle: '',
          icon: FontAwesomeIcons.qrcode,
          url: '/profile/qrcode',
          buildPage: (PageContext pageContext) => Qrcode(
            context: pageContext,
          ),
        ),
        Page(
          title: '个人信息',
          subtitle: '',
          icon: FontAwesomeIcons.edit,
          url: '/profile/editor',
          buildPage: (PageContext pageContext) => ProfileEditor(
            context: pageContext,
          ),
        ),
        Page(
          title: '修改昵称',
          subtitle: '',
          icon: FontAwesomeIcons.edit,
          url: '/profile/editor/nickname',
          buildPage: (PageContext pageContext) => EditNickName(
            context: pageContext,
          ),
        ),
        Page(
          title: '修改实名',
          subtitle: '',
          icon: FontAwesomeIcons.edit,
          url: '/profile/editor/realname',
          buildPage: (PageContext pageContext) => EditRealName(
            context: pageContext,
          ),
        ),
        Page(
          title: '修改个人签名',
          subtitle: '',
          icon: FontAwesomeIcons.edit,
          url: '/profile/editor/signature',
          buildPage: (PageContext pageContext) => EditSignature(
            context: pageContext,
          ),
        ),
        Page(
          title: '修改性别',
          subtitle: '',
          icon: FontAwesomeIcons.edit,
          url: '/profile/editor/sex',
          buildPage: (PageContext pageContext) => EditSex(
            context: pageContext,
          ),
        ),
        Page(
          title: '其它属性',
          subtitle: '',
          icon: FontAwesomeIcons.edit,
          url: '/profile/editor/more',
          buildPage: (PageContext pageContext) => ProfileMore(
            context: pageContext,
          ),
        ),
        Page(
          title: '钱包',
          subtitle: '',
          icon: Icons.account_balance_wallet,
          url: '/wallet',
          buildPage: (PageContext pageContext) => Wallet(
            context: pageContext,
          ),
        ),
        Page(
          title: '银行卡',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/card',
          buildPage: (PageContext pageContext) => BankCards(
            context: pageContext,
          ),
        ),
        Page(
          title: '零钱',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/change',
          buildPage: (PageContext pageContext) => Change(
            context: pageContext,
          ),
        ),
        Page(
          title: '收款',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/receivables',
          buildPage: (PageContext pageContext) => Receivables(
            context: pageContext,
          ),
        ),
        Page(
          title: '付款',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/payables',
          buildPage: (PageContext pageContext) => Payables(
            context: pageContext,
          ),
        ),
        Page(
          title: '设置金额',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/receivables/settings',
          buildPage: (PageContext pageContext) => AmountSettings(
            context: pageContext,
          ),
        ),
        Page(
          title: '收款记录',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/receivables/record',
          buildPage: (PageContext pageContext) => ReceivablesRecord(
            context: pageContext,
          ),
        ),
        Page(
          title: '收款单',
          subtitle: '',
          previousTitle: '收款记录',
          desc: '收款记录详情',
          icon: GalleryIcons.shrine,
          url: '/wallet/receivables/details',
          buildPage: (PageContext pageContext) => ReceivablesDetails(
            context: pageContext,
          ),
        ),
        Page(
          title: '帑银',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/ty',
          buildPage: (PageContext pageContext) => TY(
            context: pageContext,
          ),
        ),
        Page(
          title: '纹银',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/wy',
          buildPage: (PageContext pageContext) => WY(
            context: pageContext,
          ),
        ),
        Page(
          title: '充值',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/change/deposit',
          buildPage: (PageContext pageContext) => Deposit(
            context: pageContext,
          ),
        ),
        Page(
          title: '提现',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/change/cashout',
          buildPage: (PageContext pageContext) => Cashout(
            context: pageContext,
          ),
        ),
        Page(
          title: '零钱明细',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/change/bill',
          buildPage: (PageContext pageContext) => ChangeBill(
            context: pageContext,
          ),
        ),
        Page(
          title: '',
          subtitle: '',
          desc: '零钱明细项的详细页',
          icon: GalleryIcons.shrine,
          url: '/wallet/change/bill/details',
          buildPage: (PageContext pageContext) => ChangeDetails(
            context: pageContext,
          ),
        ),
        Page(
          title: '桌面设置',
          subtitle: '',
          icon: Icons.dashboard,
          url: '/desktop/settings',
          buildPage: (PageContext pageContext) => DesktopSettings(
            context: pageContext,
          ),
        ),
        Page(
          title: '栏目',
          subtitle: '',
          icon: Icons.apps,
          url: '/desktop/lets/settings',
          buildPage: (PageContext pageContext) => DeskletsSettings(
            context: pageContext,
          ),
        ),
        Page(
          title: '墙纸',
          subtitle: '',
          icon: Icons.wallpaper,
          url: '/desktop/wallpappers/settings',
          buildPage: (PageContext pageContext) => Wallpappers(
            context: pageContext,
          ),
        ),
        Page(
          title: '系统设置',
          subtitle: '',
          icon: Icons.settings,
          url: '/system/settings',
          buildPage: (PageContext pageContext) => GberaSettings(
            context: pageContext,
          ),
        ),
        Page(
          title: '主题',
          subtitle: '',
          icon: FontAwesomeIcons.themeisle,
          url: '/system/themes',
          buildPage: (PageContext pageContext) => Themes(
            context: pageContext,
          ),
        ),
        Page(
          title: '用户协议',
          subtitle: '',
          icon: FontAwesomeIcons.fileContract,
          url: '/system/user/contract',
          buildPage: (PageContext pageContext) => UserContract(
            context: pageContext,
          ),
        ),
        Page(
          title: '关于',
          subtitle: '',
          icon: Icons.info_outline,
          url: '/system/about',
          buildPage: (PageContext pageContext) => About(
            context: pageContext,
          ),
        ),
        Page(
          title: '用户与账号',
          subtitle: '',
          icon: Icons.person_outline,
          url: '/users/list',
          buildPage: (PageContext pageContext) => UserAndAccountList(
            context: pageContext,
          ),
        ),
        Page(
          title: '账号',
          subtitle: '',
          icon: Icons.person_outline,
          url: '/users/accounts/viewer',
          buildPage: (PageContext pageContext) => AccountViewer(
            context: pageContext,
          ),
        ),
        Page(
          title: '应用账号列表',
          subtitle: '',
          icon: Icons.person_outline,
          url: '/users/accounts/app',
          buildPage: (PageContext pageContext) => AppAccounts(
            context: pageContext,
          ),
        ),
        Page(
          title: '新建账号',
          subtitle: '',
          icon: Icons.person_outline,
          url: '/users/accounts/addAccount',
          buildPage: (PageContext pageContext) => AddAccount(
            context: pageContext,
          ),
        ),
        Page(
          title: '修改密码',
          subtitle: '',
          icon: Icons.person_outline,
          url: '/users/accounts/editPassword',
          buildPage: (PageContext pageContext) => EditPassword(
            context: pageContext,
          ),
        ),
        Page(
          title: '登录',
          subtitle: '',
          icon: Icons.person_outline,
          url: '/users/accounts/login',
          buildPage: (PageContext pageContext) => AccountLogin(
            context: pageContext,
          ),
        ),
        Page(
          title: '我的角色',
          subtitle: '',
          icon: Icons.recent_actors,
          url: '/users/roles',
          buildPage: (PageContext pageContext) => Roles(
            context: pageContext,
          ),
        ),
        Page(
          title: '登录账号',
          subtitle: '',
          icon: Icons.account_box,
          url: '/users/accounts',
          buildPage: (PageContext pageContext) => Accounts(
            context: pageContext,
          ),
        ),
        Page(
          title: '金证喷泉',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/fountain',
          buildPage: (PageContext pageContext) => Geofountain(
            context: pageContext,
          ),
        ),
        Page(
          title: '元宝',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/yuanbao',
          buildPage: (PageContext pageContext) => GeoYuanbao(
            context: pageContext,
          ),
        ),
        Page(
          title: '地圈设置',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/settings',
          buildPage: (PageContext pageContext) => GeoSettings(
            context: pageContext,
          ),
        ),
        Page(
          title: '银行卡',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/card/details',
          buildPage: (PageContext pageContext) => BankCardDetails(
            context: pageContext,
          ),
        ),
        Page(
          title: '栏目列表',
          subtitle: '',
          desc: '列出门户栏目',
          icon: GalleryIcons.shrine,
          url: '/desktop/portlets',
          buildPage: (PageContext pageContext) => PortletList(
            context: pageContext,
          ),
        ),
        Page(
          title: 'goGOGO',
          subtitle: '',
          desc: '平台购物商城',
          icon: GalleryIcons.shrine,
          url: '/market/goGOGO',
          buildPage: (PageContext pageContext) => Gogogo(
            context: pageContext,
          ),
        ),
        Page(
          title: '购物车',
          subtitle: '',
          desc: '平台购物商城',
          icon: GalleryIcons.shrine,
          url: '/market/shopping_cart',
          buildPage: (PageContext pageContext) => ShoppingCartPage(
            context: pageContext,
          ),
        ),
        Page(
          title: '帑指交易所',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/market/tz_list',
          buildPage: (PageContext pageContext) => TZList(
            context: pageContext,
          ),
        ),
        Page(
          title: '帑银交易所',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/market/ty_list',
          buildPage: (PageContext pageContext) => TYList(
            context: pageContext,
          ),
        ),
        Page(
          title: '帑指交易所',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/market/exchange/tz',
          buildPage: (PageContext pageContext) => TZExchange(
            context: pageContext,
          ),
        ),
        Page(
          title: '期货·地商',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/market/exchange/tz/land_agent',
          buildPage: (PageContext pageContext) => LandAgentFutrue(
            context: pageContext,
          ),
        ),
        Page(
          title: '帑银交易所',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/market/exchange/ty',
          buildPage: (PageContext pageContext) => TYExchange(
            context: pageContext,
          ),
        ),
        Page(
          title: '股市·地商',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/market/exchange/ty/land_agent',
          buildPage: (PageContext pageContext) => LandAgentStock(
            context: pageContext,
          ),
        ),
        Page(
          title: '选择分类',
          subtitle: '',
          desc: '平台购物商城',
          icon: GalleryIcons.shrine,
          url: '/goGOGO/category/filter',
          buildPage: (PageContext pageContext) => SelectGoGoGoCategory(
            context: pageContext,
          ),
        ),
        Page(
          title: '对话框',
          subtitle: '',
          desc: '聊天对话',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/talk',
          buildPage: (PageContext pageContext) => ChatTalk(
            context: pageContext,
          ),
        ),
        Page(
          title: '会话设置',
          subtitle: '',
          desc: '对话、群设置',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/room/settings',
          buildPage: (PageContext pageContext) => ChatRoomSettings(
            context: pageContext,
          ),
        ),
        Page(
          title: '添加朋友',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/add_friend',
          buildPage: (PageContext pageContext) => AddFriend(
            context: pageContext,
          ),
        ),
        Page(
          title: '导入公众',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/imports/persons',
          buildPage: (PageContext pageContext) => ImportPersons(
            context: pageContext,
          ),
        ),
        Page(
          title: '好友',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/friends',
          buildPage: (PageContext pageContext) => FriendPage(
            context: pageContext,
          ),
        ),
        Page(
          title: '聊天室头像',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/room/avatar',
          buildPage: (PageContext pageContext) => ChatRoomAvatar(
            context: pageContext,
          ),
        ),
      ],
    );
  }
}
