import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:framework/framework.dart';
import 'package:netos_app/common/avatar.dart';
import 'package:netos_app/common/icons.dart';
import 'package:netos_app/common/location_map.dart';
import 'package:netos_app/common/media_watcher.dart';
import 'package:netos_app/portals/gbera/contants/cardcases.dart';
import 'package:netos_app/portals/gbera/contants/friend_list.dart';
import 'package:netos_app/portals/gbera/contants/person_selector.dart';
import 'package:netos_app/portals/gbera/contants/public_persons.dart';
import 'package:netos_app/portals/gbera/desklets/chats/around_friends.dart';
import 'package:netos_app/portals/gbera/desklets/chats/friends_selector.dart';
import 'package:netos_app/portals/gbera/desklets/chats/members_remove.dart';
import 'package:netos_app/portals/gbera/desklets/chats/publish_notice.dart';
import 'package:netos_app/portals/gbera/desklets/chats/show_selected.dart';
import 'package:netos_app/portals/gbera/desklets/chats/trans_to.dart';
import 'package:netos_app/portals/gbera/desklets/chats/view_licence.dart';
import 'package:netos_app/portals/gbera/errors/errors.dart';
import 'package:netos_app/portals/gbera/pages/absorber/create_slices.dart';
import 'package:netos_app/portals/gbera/pages/absorber/create_progress.dart';
import 'package:netos_app/portals/gbera/pages/absorber/geo_absorber_settings.dart';
import 'package:netos_app/portals/gbera/pages/absorber/geo_absorber_details.dart';
import 'package:netos_app/portals/gbera/pages/absorber/geo_apply.dart';
import 'package:netos_app/portals/gbera/pages/absorber/absorber_invest_records.dart';
import 'package:netos_app/portals/gbera/pages/absorber/my_absorbers.dart';
import 'package:netos_app/portals/gbera/pages/absorber/qrcode_image.dart';
import 'package:netos_app/portals/gbera/pages/absorber/qrcode_slices.dart';
import 'package:netos_app/portals/gbera/pages/absorber/recipients_selector.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/caisheng_slice.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/caisheng_template.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/chiji_slice.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/chiji_template.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/happiness_slice.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/happiness_template.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/love_slice.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/love_template.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/minxinpian_slice.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/minxinpian_template.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/normal_slice.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/normal_template.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/official_slice.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/official_template.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/wangzheruyao_slice.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/wangzheruyao_template.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/xibao_slice.dart';
import 'package:netos_app/portals/gbera/pages/absorber/render/xibao_template.dart';
import 'package:netos_app/portals/gbera/pages/absorber/simple_absorber_settings.dart';
import 'package:netos_app/portals/gbera/pages/absorber/select_persons.dart';
import 'package:netos_app/portals/gbera/pages/absorber/simple_absorber_details.dart';
import 'package:netos_app/portals/gbera/pages/absorber/simple_apply.dart';
import 'package:netos_app/portals/gbera/pages/absorber/recipients_records.dart';
import 'package:netos_app/portals/gbera/pages/absorber/recipients_view.dart';
import 'package:netos_app/portals/gbera/pages/absorber/slice_absorbers.dart';
import 'package:netos_app/portals/gbera/pages/absorber/slice_batch.dart';
import 'package:netos_app/portals/gbera/pages/absorber/slice_template.dart';
import 'package:netos_app/portals/gbera/pages/absorber/slice_templates.dart';
import 'package:netos_app/portals/gbera/pages/absorber/slice_view.dart';
import 'package:netos_app/portals/gbera/pages/absorber/slice_webview.dart';
import 'package:netos_app/portals/gbera/pages/absorber/template_editor.dart';
import 'package:netos_app/portals/gbera/pages/chasechain.dart';
import 'package:netos_app/portals/gbera/pages/chasechain/box_view.dart';
import 'package:netos_app/portals/gbera/pages/chasechain/content_box.dart';
import 'package:netos_app/portals/gbera/pages/chasechain/content_provider.dart';
import 'package:netos_app/portals/gbera/pages/chasechain/person_view.dart';
import 'package:netos_app/portals/gbera/pages/chasechain/pool_view.dart';
import 'package:netos_app/portals/gbera/pages/chasechain/profile.dart';
import 'package:netos_app/portals/gbera/pages/chasechain/traffic_pools.dart';
import 'package:netos_app/portals/gbera/pages/desktop.dart';
import 'package:netos_app/portals/gbera/pages/desktop/desklets_settings.dart';
import 'package:netos_app/portals/gbera/pages/desktop/desktop_settings.dart';
import 'package:netos_app/portals/gbera/pages/desktop/portlet_list.dart';
import 'package:netos_app/portals/gbera/pages/geosphere.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/GeoNearByAmap.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_create_receptor.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_filter.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_fountain.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_publish_article.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_receptor_background.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_receptor_fans.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_receptor_lord.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_receptor_mines.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_region.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_select_category.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_set_update_rate.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_settings_fans.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_settings_lord.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_settings_mines.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_settings_receptor_discovery.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_settings_receptor_fans.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_settings_receptor_netflow.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_settings_viewer.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_view_mobile.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_view_person.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_view_receptor.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geo_yuanbao.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geosphere_histories.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geosphere_portal_owner.dart';
import 'package:netos_app/portals/gbera/pages/geosphere/geosphere_portal_person.dart';
import 'package:netos_app/portals/gbera/pages/market.dart';
import 'package:netos_app/portals/gbera/pages/market/go_gogo.dart';
import 'package:netos_app/portals/gbera/pages/market/go_shopping_cart.dart';
import 'package:netos_app/portals/gbera/pages/market/request_isp.dart';
import 'package:netos_app/portals/gbera/pages/market/request_landagent.dart';
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
import 'package:netos_app/portals/gbera/pages/netflow/outsite_person_rights.dart';
import 'package:netos_app/portals/gbera/pages/netflow/outsite_persons.dart';
import 'package:netos_app/portals/gbera/pages/netflow/outsite_persons.removes.dart';
import 'package:netos_app/portals/gbera/pages/netflow/outsite_persons_add.dart';
import 'package:netos_app/portals/gbera/pages/netflow/portal/channel_router_path.dart';
import 'package:netos_app/portals/gbera/pages/netflow/portal/portal_netflow_channel.dart';
import 'package:netos_app/portals/gbera/pages/netflow/portal/portal_netflow_person.dart';
import 'package:netos_app/portals/gbera/pages/netflow/channel_publish_article.dart';
import 'package:netos_app/portals/gbera/pages/netflow/scan_channel.dart';
import 'package:netos_app/portals/gbera/pages/netflow/search_channel.dart';
import 'package:netos_app/portals/gbera/pages/netflow/see_channelpin_persons.dart';
import 'package:netos_app/portals/gbera/pages/netflow/service_menu.dart';
import 'package:netos_app/portals/gbera/pages/netflow/settings_main.dart';
import 'package:netos_app/portals/gbera/pages/netflow/settings_persons.dart';
import 'package:netos_app/portals/gbera/pages/netflow/show_selected.dart';
import 'package:netos_app/portals/gbera/pages/profile.dart';
import 'package:netos_app/portals/gbera/pages/profile/edit_nickname.dart';
import 'package:netos_app/portals/gbera/pages/profile/edit_realname.dart';
import 'package:netos_app/portals/gbera/pages/profile/edit_sex.dart';
import 'package:netos_app/portals/gbera/pages/profile/edit_signature.dart';
import 'package:netos_app/portals/gbera/pages/profile/editor.dart';
import 'package:netos_app/portals/gbera/pages/profile/more.dart';
import 'package:netos_app/portals/gbera/pages/profile/person_more.dart';
import 'package:netos_app/portals/gbera/pages/profile/person_profile.dart';
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
import 'package:netos_app/portals/gbera/pages/users/account_login.dart';
import 'package:netos_app/portals/gbera/pages/users/accounts.dart';
import 'package:netos_app/portals/gbera/pages/users/add_account.dart';
import 'package:netos_app/portals/gbera/pages/users/app_accounts.dart';
import 'package:netos_app/portals/gbera/pages/users/edit_password.dart';
import 'package:netos_app/portals/gbera/pages/users/roles.dart';
import 'package:netos_app/portals/gbera/pages/users/user_list.dart';
import 'package:netos_app/portals/gbera/pages/viewers/channel_viewer.dart';
import 'package:netos_app/portals/gbera/pages/viewers/view_licence.dart';
import 'package:netos_app/portals/gbera/pages/wallet.dart';
import 'package:netos_app/portals/gbera/pages/wallet/absorb.dart';
import 'package:netos_app/portals/gbera/pages/wallet/absorb_bill.dart';
import 'package:netos_app/portals/gbera/pages/wallet/add_card.dart';
import 'package:netos_app/portals/gbera/pages/wallet/amount_settings.dart';
import 'package:netos_app/portals/gbera/pages/wallet/card_details.dart';
import 'package:netos_app/portals/gbera/pages/wallet/cards.dart';
import 'package:netos_app/portals/gbera/pages/wallet/cashout.dart';
import 'package:netos_app/portals/gbera/pages/wallet/change.dart';
import 'package:netos_app/portals/gbera/pages/wallet/change_bill.dart';
import 'package:netos_app/portals/gbera/pages/wallet/deposit.dart';
import 'package:netos_app/portals/gbera/pages/wallet/deposit_absorb_details.dart';
import 'package:netos_app/portals/gbera/pages/wallet/deposit_hubtails_details.dart';
import 'package:netos_app/portals/gbera/pages/wallet/exchange_details.dart';
import 'package:netos_app/portals/gbera/pages/wallet/onorder.dart';
import 'package:netos_app/portals/gbera/pages/wallet/onorder_bill.dart';
import 'package:netos_app/portals/gbera/pages/wallet/p2p_details.dart';
import 'package:netos_app/portals/gbera/pages/wallet/pay_details.dart';
import 'package:netos_app/portals/gbera/pages/wallet/payables.dart';
import 'package:netos_app/portals/gbera/pages/wallet/person_cards.dart';
import 'package:netos_app/portals/gbera/pages/wallet/purchase_details.dart';
import 'package:netos_app/portals/gbera/pages/wallet/receivables.dart';
import 'package:netos_app/portals/gbera/pages/wallet/recharge_details.dart';
import 'package:netos_app/portals/gbera/pages/wallet/recharge_result.dart';
import 'package:netos_app/portals/gbera/pages/wallet/trans_absorb_details.dart';
import 'package:netos_app/portals/gbera/pages/wallet/trans_profit_details.dart';
import 'package:netos_app/portals/gbera/pages/wallet/trans_shunter_details.dart';
import 'package:netos_app/portals/gbera/pages/wallet/ty.dart';
import 'package:netos_app/portals/gbera/pages/wallet/weny.dart';
import 'package:netos_app/portals/gbera/pages/wallet/weny_account_freezen.dart';
import 'package:netos_app/portals/gbera/pages/wallet/weny_account_profit.dart';
import 'package:netos_app/portals/gbera/pages/wallet/weny_account_stock.dart';
import 'package:netos_app/portals/gbera/pages/wallet/weny_bill_Freezen.dart';
import 'package:netos_app/portals/gbera/pages/wallet/weny_bill_Profit.dart';
import 'package:netos_app/portals/gbera/pages/wallet/weny_bill_stock.dart';
import 'package:netos_app/portals/gbera/pages/wallet/withdraw_cancel.dart';
import 'package:netos_app/portals/gbera/pages/wallet/withdraw_details.dart';
import 'package:netos_app/portals/gbera/pages/wallet/withdraw_result.dart';
import 'package:netos_app/portals/gbera/scaffolds.dart';
import 'package:netos_app/portals/gbera/store/remotes/chasechain_recommender.dart';
import 'package:netos_app/portals/gbera/store/remotes/chat_rooms.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_categories.dart';
import 'package:netos_app/portals/gbera/store/remotes/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/remotes/org.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_accounts.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_bills.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_records.dart';
import 'package:netos_app/portals/gbera/store/remotes/wallet_trades.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_prices.dart';
import 'package:netos_app/portals/gbera/store/remotes/wybank_purchaser.dart';
import 'package:netos_app/portals/gbera/store/services/channel_extra.dart';
import 'package:netos_app/portals/gbera/store/services/channel_messages.dart';
import 'package:netos_app/portals/gbera/store/services/channel_pin.dart';
import 'package:netos_app/portals/gbera/store/services/channels.dart';
import 'package:netos_app/portals/gbera/store/services/chat_rooms.dart';
import 'package:netos_app/portals/gbera/store/services/geo_categories.dart';
import 'package:netos_app/portals/gbera/store/services/geo_messages.dart';
import 'package:netos_app/portals/gbera/store/services/geo_receptors.dart';
import 'package:netos_app/portals/gbera/store/services/insite_messages.dart';
import 'package:netos_app/portals/gbera/styles/blue-styles.dart';
import 'package:netos_app/portals/gbera/styles/blueGrey-styles.dart';
import 'package:netos_app/portals/gbera/styles/lime-styles.dart';
import 'package:netos_app/portals/gbera/styles/orange-styles.dart';
import 'package:netos_app/portals/gbera/styles/pink-styles.dart';
import 'package:netos_app/portals/gbera/styles/purple-styles.dart';
import 'package:netos_app/portals/gbera/styles/teal-styles.dart';
import 'package:netos_app/portals/landagent/remote/robot.dart';
import 'package:netos_app/portals/landagent/remote/wybank.dart';
import 'package:netos_app/portals/nodepower/remote/workflow_remote.dart';
import 'package:netos_app/system/local/entities.dart';

import 'desklets/chats/add_friend.dart';
import 'desklets/chats/chat_talk.dart';
import 'desklets/chats/friend_page.dart';
import 'desklets/chats/import_persons.dart';
import 'desklets/chats/members_plus.dart';
import 'desklets/chats/members_view.dart';
import 'desklets/chats/room_settings.dart';
import 'desklets/chats/settings_nickname.dart';
import 'desklets/chats/settings_notice.dart';
import 'desklets/chats/settings_qrcode.dart';
import 'desklets/chats/settings_show_nickname.dart';
import 'desklets/chats/settings_title.dart';
import 'desklets/desklets.dart';
import 'pages/absorber/org_licence.dart';
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
      title: '地微官方框架',
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
          '/remote/chat/rooms': ChatRoomRemote(),
          '/remote/geo/categories': GeoCategoryRemote(),
          '/remote/geo/receptors': GeoReceptorRemote(),
          '/geosphere/receptors': GeoReceptorService(),
          '/geosphere/categories': GeoCategoryLocal(),
          '/geosphere/receptor/messages': GeosphereMessageService(),
          '/geosphere/receptor/messages/medias': GeosphereMediaService(),
          '/cache/geosphere/receptor': GeoReceptorCache(),
          '/wallet/payChannels': PayChannelRemote(),
          '/wallet/accounts': WalletAccountRemote(),
          '/wallet/records': WalletRecordRemote(),
          '/wallet/trades': WalletTradeRemote(),
          '/wallet/bills': WalletBillRemote(),
          '/wybank/bill/prices': PriceRemote(),
          '/remote/wybank': WybankRemote(),
          '/remote/purchaser': DefaultWyBankPurchaserRemote(),
          '/remote/org/isp': IspRemote(),
          '/remote/org/la': LaRemote(),
          '/remote/org/licence': LicenceRemote(),
          '/remote/org/receivingBank': ReceivingBankRemote(),
          '/remote/org/workflow': WorkflowRemote(),
          '/remote/chasechain/recommender': ChasechainRecommenderRemote(),
          '/remote/robot': RobotRemote(),
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
                  50: Color(0xFFFAFAFA),
                  100: Color(0xFF5F5F5),
                  200: Color(0xFFEEEEEE),
                  300: Color(0xFFE0E0E0),
                  400: Color(0xFFBDBDBD),
                  500: Color(0xFF9E9E9E),
                  600: Color(0xFF757575),
                  700: Color(0xFF616161),
                  800: Color(0xFF424242),
                  900: Color(0xFF212121),
                },
              ),
            );
          },
        ),
        ThemeStyle(
          title: '绿色',
          desc: '呈现淡绿',
          url: '/green',
          iconColor: Colors.greenAccent,
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
        ThemeStyle(
          title: '蓝色',
          desc: '呈现淡蓝，接近白',
          url: '/blue',
          iconColor: Colors.blueAccent,
          buildStyle: buildBlueStyles,
          buildTheme: (context) => ThemeData(
            backgroundColor: Color(0xFFE1f5fe),
            scaffoldBackgroundColor: Color(0xFFE1f5fe),
            brightness: Brightness.light,
            appBarTheme: AppBarTheme.of(context).copyWith(
              color: Color(0xFFE1f5fe),
              textTheme: TextTheme(
                title: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actionsIconTheme: IconThemeData(
                color: Colors.blue[700],
                opacity: 1,
                size: 20,
              ),
              brightness: Brightness.light,
              iconTheme: IconThemeData(
                color: Colors.blue[700],
                opacity: 1,
                size: 20,
              ),
              elevation: 1.0,
            ),
            primarySwatch: MaterialColor(
              0xFFE1f5fe,
              {
                50: Color(0xFFE1f5fe),
                100: Color(0xffb3e5fc),
                200: Color(0xff81d4fa),
                300: Color(0xff4fc3f7),
                400: Color(0xff29b6f6),
                500: Color(0xff03a9f4),
                600: Color(0xff039be5),
                700: Color(0xFF0288d1),
                800: Color(0xFF0277bd),
                900: Color(0xff01579b),
              },
            ),
          ),
        ),
        ThemeStyle(
          title: '橙色',
          desc: '淘宝色',
          url: '/orange',
          iconColor: Colors.deepOrangeAccent,
          buildStyle: buildOrangeStyles,
          buildTheme: (context) => ThemeData(
            backgroundColor: Color(0xFFFBE9E7),
            scaffoldBackgroundColor: Color(0xFFFBE9E7),
            brightness: Brightness.light,
            appBarTheme: AppBarTheme.of(context).copyWith(
              color: Color(0xFFFBE9E7),
              textTheme: TextTheme(
                title: TextStyle(
                  color: Colors.orange[800],
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actionsIconTheme: IconThemeData(
                color: Colors.orange[700],
                opacity: 1,
                size: 20,
              ),
              brightness: Brightness.light,
              iconTheme: IconThemeData(
                color: Colors.orange[700],
                opacity: 1,
                size: 20,
              ),
              elevation: 1.0,
            ),
            primarySwatch: MaterialColor(
              0xFFFBE9E7,
              {
                50: Color(0xFFFBE9E7),
                100: Color(0xFFFFCCBC),
                200: Color(0xFFFFAB91),
                300: Color(0xFFFF8A65),
                400: Color(0xFFFF7043),
                500: Color(0xFFFF5722),
                600: Color(0xFFF4511E),
                700: Color(0xFFE64A19),
                800: Color(0xFFD84315),
                900: Color(0xFFBF360C),
              },
            ),
          ),
        ),
        ThemeStyle(
          title: '粉色',
          desc: '玫瑰色',
          url: '/pink',
          iconColor: Colors.pinkAccent,
          buildStyle: buildPinkStyles,
          buildTheme: (context) => ThemeData(
            backgroundColor: Color(0xFFFCE4EC),
            scaffoldBackgroundColor: Color(0xFFFCE4EC),
            brightness: Brightness.light,
            appBarTheme: AppBarTheme.of(context).copyWith(
              color: Color(0xFFFCE4EC),
              textTheme: TextTheme(
                title: TextStyle(
                  color: Colors.pink[800],
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actionsIconTheme: IconThemeData(
                color: Colors.pink[700],
                opacity: 1,
                size: 20,
              ),
              brightness: Brightness.light,
              iconTheme: IconThemeData(
                color: Colors.pink[700],
                opacity: 1,
                size: 20,
              ),
              elevation: 1.0,
            ),
            primarySwatch: MaterialColor(
              0xFFFCE4EC,
              {
                50: Color(0xFFFCE4EC),
                100: Color(0xFFF8BBD0),
                200: Color(0xFFF48FB1),
                300: Color(0xFFF06292),
                400: Color(0xFFEC407A),
                500: Color(0xFFE91E63),
                600: Color(0xFFD81B60),
                700: Color(0xFFC2185B),
                800: Color(0xFFAD1457),
                900: Color(0xFF880E4F),
              },
            ),
          ),
        ),
        ThemeStyle(
          title: '蓝灰',
          desc: '庄重厚实感',
          url: '/blueGrey',
          iconColor: Colors.blueGrey,
          buildStyle: buildBlueGreyStyles,
          buildTheme: (context) => ThemeData(
            backgroundColor: Color(0xFFECEFF1),
            scaffoldBackgroundColor: Color(0xFFECEFF1),
            brightness: Brightness.light,
            appBarTheme: AppBarTheme.of(context).copyWith(
              color: Color(0xFFECEFF1),
              textTheme: TextTheme(
                title: TextStyle(
                  color: Colors.blueGrey[800],
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actionsIconTheme: IconThemeData(
                color: Colors.blueGrey[700],
                opacity: 1,
                size: 20,
              ),
              brightness: Brightness.light,
              iconTheme: IconThemeData(
                color: Colors.blueGrey[700],
                opacity: 1,
                size: 20,
              ),
              elevation: 1.0,
            ),
            primarySwatch: MaterialColor(
              0xFFECEFF1,
              {
                50: Color(0xFFECEFF1),
                100: Color(0xFFCFD8DC),
                200: Color(0xFFB0BEC5),
                300: Color(0xFF90A4AE),
                400: Color(0xFF78909C),
                500: Color(0xFF607D8B),
                600: Color(0xFF546E7A),
                700: Color(0xFF455A64),
                800: Color(0xFF37474F),
                900: Color(0xFF263238),
              },
            ),
          ),
        ),
        ThemeStyle(
          title: '紫色',
          desc: '紫色象征着尊贵;浪漫;一种强烈的感情',
          url: '/purple',
          iconColor: Colors.purple,
          buildStyle: buildPurpleStyles,
          buildTheme: (context) => ThemeData(
            backgroundColor: Color(0xFFF3E5F5),
            scaffoldBackgroundColor: Color(0xFFF3E5F5),
            brightness: Brightness.light,
            appBarTheme: AppBarTheme.of(context).copyWith(
              color: Color(0xFFF3E5F5),
              textTheme: TextTheme(
                title: TextStyle(
                  color: Colors.purple[800],
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actionsIconTheme: IconThemeData(
                color: Colors.purple[700],
                opacity: 1,
                size: 20,
              ),
              brightness: Brightness.light,
              iconTheme: IconThemeData(
                color: Colors.purple[700],
                opacity: 1,
                size: 20,
              ),
              elevation: 1.0,
            ),
            primarySwatch: MaterialColor(
              0xFFF3E5F5,
              {
                50: Color(0xFFF3E5F5),
                100: Color(0xFFE1BEE7),
                200: Color(0xFFCE93D8),
                300: Color(0xFFBA68C8),
                400: Color(0xFFAB47BC),
                500: Color(0xFF9C27B0),
                600: Color(0xFF8E24AA),
                700: Color(0xFF7B1FA2),
                800: Color(0xFF6A1B9A),
                900: Color(0xFF4A148C),
              },
            ),
          ),
        ),
        ThemeStyle(
          title: '蓝绿',
          desc: '蓝绿色有令人平和恬静的效果',
          url: '/teal',
          iconColor: Colors.teal,
          buildStyle: buildTealStyles,
          buildTheme: (context) => ThemeData(
            backgroundColor: Color(0xFFE0F2F1),
            scaffoldBackgroundColor: Color(0xFFE0F2F1),
            brightness: Brightness.light,
            appBarTheme: AppBarTheme.of(context).copyWith(
              color: Color(0xFFE0F2F1),
              textTheme: TextTheme(
                title: TextStyle(
                  color: Colors.teal[800],
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actionsIconTheme: IconThemeData(
                color: Colors.teal[700],
                opacity: 1,
                size: 20,
              ),
              brightness: Brightness.light,
              iconTheme: IconThemeData(
                color: Colors.teal[700],
                opacity: 1,
                size: 20,
              ),
              elevation: 1.0,
            ),
            primarySwatch: MaterialColor(
              0xFFE0F2F1,
              {
                50: Color(0xFFE0F2F1),
                100: Color(0xFFB2DFDB),
                200: Color(0xFF80CBC4),
                300: Color(0xFF4DB6AC),
                400: Color(0xFF26A69A),
                500: Color(0xFF009688),
                600: Color(0xFF00897B),
                700: Color(0xFF00786B),
                800: Color(0xFF00695C),
                900: Color(0xFF004D40),
              },
            ),
          ),
        ),
        ThemeStyle(
          title: '柠檬色',
          desc: '年轻人的世界色彩',
          url: '/lime',
          iconColor: Colors.lime,
          buildStyle: buildLimeStyles,
          buildTheme: (context) => ThemeData(
            backgroundColor: Color(0xFFF9FBE7),
            scaffoldBackgroundColor: Color(0xFFF9FBE7),
            brightness: Brightness.light,
            appBarTheme: AppBarTheme.of(context).copyWith(
              color: Color(0xFFF9FBE7),
              textTheme: TextTheme(
                title: TextStyle(
                  color: Colors.lime[800],
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actionsIconTheme: IconThemeData(
                color: Colors.lime[700],
                opacity: 1,
                size: 20,
              ),
              brightness: Brightness.light,
              iconTheme: IconThemeData(
                color: Colors.lime[700],
                opacity: 1,
                size: 20,
              ),
              elevation: 1.0,
            ),
            primarySwatch: MaterialColor(
              0xFFF9FBE7,
              {
                50: Color(0xFFF9FBE7),
                100: Color(0xFFF0F4C3),
                200: Color(0xFFE6EE9C),
                300: Color(0xFFDCE775),
                400: Color(0xFFD4E157),
                500: Color(0xFFCDDC39),
                600: Color(0xFFC0CA33),
                700: Color(0xFFAFB42B),
                800: Color(0xFF9E9D24),
                900: Color(0xFF827717),
              },
            ),
          ),
        ),
      ],
      buildDesklets: buildDesklets,
      buildPages: (IServiceProvider site) => [
        LogicPage(
          title: '控件，截取头像',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/widgets/avatar',
          buildPage: (PageContext pageContext) => GberaAvatar(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '出错啦',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/error',
          buildPage: (PageContext pageContext) => GberaError(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '地微',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/',
          buildPage: (PageContext pageContext) => WithBottomScaffold(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '桌面',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/desktop',
          buildPage: (PageContext pageContext) => Desktop(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '网流',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/netflow',
          buildPage: (PageContext pageContext) => Netflow(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '管道',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/netflow/channel',
          buildPage: (PageContext pageContext) => ChannelPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '购买服务',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/channel/article/buywy',
          buildPage: (PageContext pageContext) => BuyWYArticle(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '重命名',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/netflow/channel/rename',
          buildPage: (PageContext pageContext) => RenameChannel(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '二维码',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/netflow/channel/qrcode',
          buildPage: (PageContext pageContext) => ChannelQrcode(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '推广',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/netflow/channel/popularize',
          buildPage: (PageContext pageContext) => PopularizeChannel(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '新建管道',
          subtitle: '',
          icon: Icons.add,
          url: '/netflow/manager/create_channel',
          buildPage: (PageContext pageContext) => CreateChannel(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '管道信息',
          subtitle: '',
          icon: FontAwesomeIcons.qrcode,
          url: '/netflow/manager/scan_channel',
          buildPage: (PageContext pageContext) => ScanChannel(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '搜索管道',
          subtitle: '',
          icon: FontAwesomeIcons.search,
          url: '/netflow/manager/search_channel',
          buildPage: (PageContext pageContext) => SearchChannel(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '网关管道',
          subtitle: '',
          icon: Icons.settings_input_composite,
          url: '/netflow/manager/channel_gateway',
          buildPage: (PageContext pageContext) => ChannelGateway(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '活动设置',
          subtitle: '',
          icon: Icons.settings_input_composite,
          url: '/netflow/manager/settings',
          buildPage: (PageContext pageContext) => SettingsMain(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '管道进口公众',
          subtitle: '覆盖我的管道的公众管道、查看他人的管道都是此页面，以权限控制显示',
          icon: Icons.settings_input_composite,
          url: '/netflow/channel/insite/persons',
          buildPage: (PageContext pageContext) => InsitePersons(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '管道出口公众',
          subtitle: '覆盖我的管道的公众管道、查看他人的管道都是此页面，以权限控制显示',
          icon: Icons.settings_input_composite,
          url: '/netflow/channel/outsite/persons',
          buildPage: (PageContext pageContext) => OutsitePersons(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '公众',
          subtitle: '',
          icon: Icons.settings_input_composite,
          url: '/netflow/channel/settings/persons',
          buildPage: (PageContext pageContext) => SettingsPersons(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '公众',
          subtitle: '',
          icon: null,
          url: '/contacts/person/public',
          buildPage: (PageContext pageContext) => PublicPersonsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '公众选择器',
          subtitle: '',
          icon: null,
          url: '/contacts/person/selector',
          buildPage: (PageContext pageContext) => PersonsSelector(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '好友选择器',
          subtitle: '',
          icon: null,
          url: '/contacts/friend/selector',
          buildPage: (PageContext pageContext) => FriendsSelector(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '显示已选好友',
          subtitle: '',
          icon: null,
          url: '/contacts/friend/selected',
          buildPage: (PageContext pageContext) => ShowFriendSelectedPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '附近的人建群',
          subtitle: '',
          icon: null,
          url: '/chat/friend/around',
          buildPage: (PageContext pageContext) => AroundFriendsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '查看成员',
          subtitle: '',
          icon: null,
          url: '/contacts/friend/viewMembers',
          buildPage: (PageContext pageContext) => ChatMemberViewPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '移除成员',
          subtitle: '',
          icon: null,
          url: '/contacts/friend/removeMembers',
          buildPage: (PageContext pageContext) => ChatMemberRemovePage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '添加成员',
          subtitle: '',
          icon: null,
          url: '/contacts/friend/addMembers',
          buildPage: (PageContext pageContext) => ChatMemberPlusPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '朋友',
          subtitle: '',
          icon: null,
          url: '/contacts/person/private',
          buildPage: (PageContext pageContext) => FriendsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '名片夹',
          subtitle: '',
          icon: null,
          url: '/cardcases',
          buildPage: (PageContext pageContext) => CardcasesPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '公众活动',
          subtitle: '',
          icon: Icons.settings_input_composite,
          url: '/netflow/publics/activities',
          buildPage: (PageContext pageContext) => InsiteMessagePage(
            pageContext: pageContext,
          ),
        ),
        LogicPage(
          title: '发布文章',
          subtitle: '',
          icon: Icons.art_track,
          url: '/netflow/channel/publish_article',
          buildPage: (PageContext pageContext) => ChannelPublishArticle(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '管道活动门户',
          subtitle: '',
          icon: Icons.art_track,
          url: '/netflow/portal/channel',
          buildPage: (PageContext pageContext) => ChannelPortal(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '服务清单',
          subtitle: '',
          desc: '为个人站点或商户站点提供的服务列表',
          icon: Icons.art_track,
          url: '/netflow/channel/serviceMenu',
          buildPage: (PageContext pageContext) => ServiceMenu(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '微站的绑定管道',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/site/output',
          buildPage: (PageContext pageContext) => SiteChannelBinder(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '网流用户门户',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/portal/person',
          buildPage: (PageContext pageContext) => NetflowPersonPortal(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '网流管道门户',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/portal/channel',
          buildPage: (PageContext pageContext) => NetflowChannelPortal(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '管道路由路径切换',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/router',
          buildPage: (PageContext pageContext) => ChannelRouter(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '微应用',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/micro/app',
          buildPage: (PageContext pageContext) => MicroAppWidget(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '商户站点',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/site/marchant',
          buildPage: (PageContext pageContext) => MarchantSite(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '个人站点',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/site/personal',
          buildPage: (PageContext pageContext) => PersonalSite(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '公众网流权限',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/site/personal/rights',
          buildPage: (PageContext pageContext) => PersonRights(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '朋友站点',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/site/friend',
          buildPage: (PageContext pageContext) => FriendSite(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '入站申请',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/site/insite/request',
          buildPage: (PageContext pageContext) => InSiteRequest(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '入站审批',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/site/insite/approvals',
          buildPage: (PageContext pageContext) => InsiteApprovals(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '微站',
          subtitle: '用于活动设置中查看我的微站列表',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/activies/sites',
          buildPage: (PageContext pageContext) => ActivitiesSites(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '管道',
          subtitle: '用于活动设置中查看我的管道列表',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/activies/channels',
          buildPage: (PageContext pageContext) => ActivitiesChannels(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '文档传播路径',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/document/path',
          buildPage: (PageContext pageContext) => DocumentPath(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '已选公众',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/outsite/persons_select',
          buildPage: (PageContext pageContext) => ShowPersonelectedPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '添加输出公众',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/outsite/persons_adds',
          buildPage: (PageContext pageContext) => OutsitePersonsAddsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '移除输出公众',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/outsite/persons_removes',
          buildPage: (PageContext pageContext) => OutsitePersonsRemovesPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '公众输出权限',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/outsite/persons_rights',
          buildPage: (PageContext pageContext) => OutsitePersonsRightsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '进口公众权限设置',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/insite/persons_settings',
          buildPage: (PageContext pageContext) => InsitePersonsSettings(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '管道端口用户查看器',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/channel/pin/see_persons',
          buildPage: (PageContext pageContext) => SeeChannelPinPersons(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '微应用',
          subtitle: '用于活动设置中查看我的微应用列表',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/activies/microapps',
          buildPage: (PageContext pageContext) => ActivitiesMicroapps(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '网关',
          subtitle: '用于活动设置中拒绝接收用户或管道发来的信息',
          desc: '',
          icon: Icons.art_track,
          url: '/netflow/activities/gateway_settings',
          buildPage: (PageContext pageContext) => ActivitiesGatewaySettings(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '图片查看器',
          subtitle: '',
          desc: '',
          icon: Icons.image,
          url: '/images/viewer',
          buildRoute:
              (RouteSettings settings, LogicPage page, IServiceProvider site) {
            return MaterialPageRoute(
              settings: settings,
              builder: (context) {
                PageContext pageContext = PageContext(
                  page: page,
                  site: site,
                  context: context,
                );
                return MediaWatcher(
                  pageContext: pageContext,
                );
              },
              fullscreenDialog: true,
            );
          },
        ),
        LogicPage(
          title: '管道看版',
          subtitle: '',
          desc: '',
          icon: Icons.art_track,
          url: '/channel/viewer',
          buildPage: (PageContext pageContext) => ChannelViewer(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '他的管道',
          subtitle: '用于活动网关中查看他的管道列表',
          desc: '',
          icon: Icons.art_track,
          url: '/channel/list_of_user',
          buildPage: (PageContext pageContext) => ChannelsOfUser(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '市场',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/market',
          buildPage: (PageContext pageContext) => Market(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '追链',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/chasechain',
          buildPage: (PageContext pageContext) => Chasechain(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '地微',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere',
          buildPage: (PageContext pageContext) => Geosphere(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '主地理感知器',
          subtitle: '即我的地圈',
          icon: GalleryIcons.shrine,
          url: '/geosphere/receptor.lord',
          buildPage: (PageContext pageContext) => GeoReceptorLordWidget(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '我的地理感知器',
          subtitle: '即非我的地圈的其它类型感知器',
          icon: GalleryIcons.shrine,
          url: '/geosphere/receptor.mines',
          buildPage: (PageContext pageContext) => GeoReceptorMineWidget(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '粉丝的地理感知器',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/receptor.fans',
          buildPage: (PageContext pageContext) => GeoReceptorFansWidget(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '感知器查看器',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/view/receptor',
          buildPage: (PageContext pageContext) => GeoViewReceptor(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '地理用户查看器',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/view/person',
          buildPage: (PageContext pageContext) => GeoViewPerson(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '选择地理感知器分类',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/category/select',
          buildPage: (PageContext pageContext) => GeoSelectGeoCategory(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '新创地理感知器',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/receptor/create',
          buildPage: (PageContext pageContext) => GeoCreateReceptor(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '更新频率',
          subtitle: '实时定位地理更新通知变化',
          icon: GalleryIcons.shrine,
          url: '/geosphere/receptor/setUpdateRate',
          buildPage: (PageContext pageContext) => GeoSetUpdateRate(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '选择附近地物',
          subtitle: '由近及远列出高德地圈周边地物',
          icon: GalleryIcons.shrine,
          url: '/geosphere/amap/near',
          buildPage: (PageContext pageContext) => GeoNearByAmapPOI(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '查看我的地圈的信息',
          subtitle: '地圈的感知半径、更新频率',
          icon: GalleryIcons.shrine,
          url: '/geosphere/receptor/viewMobile',
          buildPage: (PageContext pageContext) => GeoViewMobile(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '发布文章',
          subtitle: '',
          icon: Icons.art_track,
          url: '/geosphere/publish_article',
          buildPage: (PageContext pageContext) => GeospherePublishArticle(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '背景设置',
          subtitle: '',
          icon: Icons.art_track,
          url: '/geosphere/receptor/settings/background',
          buildPage: (PageContext pageContext) => GeosphereReceptorBackground(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '实时感知发现',
          subtitle: '',
          icon: Icons.art_track,
          url: '/geosphere/receptor/settings/links/discovery_receptors',
          buildPage: (PageContext pageContext) => GeosphereReceptorDiscovery(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '粉丝',
          subtitle: '',
          icon: Icons.art_track,
          url: '/geosphere/receptor/settings/links/fans',
          buildPage: (PageContext pageContext) => GeosphereReceptorFans(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '网流消息网关',
          subtitle: '',
          icon: Icons.art_track,
          url: '/geosphere/receptor/settings/links/netflow_gateway',
          buildPage: (PageContext pageContext) =>
              GeosphereReceptorNetflowGateway(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '地圈动态门户',
          subtitle: '感知器创建者的',
          icon: Icons.art_track,
          url: '/geosphere/portal.owner',
          buildPage: (PageContext pageContext) => GeospherePortalOfOwner(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '地圈动态门户',
          subtitle: '指定用户',
          icon: Icons.art_track,
          url: '/geosphere/portal.person',
          buildPage: (PageContext pageContext) => GeospherePortalOfPerson(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '地方市场',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/region',
          buildPage: (PageContext pageContext) => GeoRegion(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '实时发现',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/filter',
          buildPage: (PageContext pageContext) => GeoFilter(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '历史活动',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/hostories',
          buildPage: (PageContext pageContext) => GeosphereHistories(
            context: pageContext,
          ),
        ),
        LogicPage(
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
        LogicPage(
          title: '我的二维码',
          subtitle: '',
          icon: FontAwesomeIcons.qrcode,
          url: '/profile/qrcode',
          buildPage: (PageContext pageContext) => Qrcode(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '个人信息视图',
          subtitle: '',
          icon: FontAwesomeIcons.edit,
          url: '/profile/view',
          buildPage: (PageContext pageContext) => PersonProfile(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '个人信息视图',
          subtitle: '',
          icon: FontAwesomeIcons.edit,
          url: '/profile/view/more',
          buildPage: (PageContext pageContext) => PersonProfileViewMore(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '个人信息',
          subtitle: '',
          icon: FontAwesomeIcons.edit,
          url: '/profile/editor',
          buildPage: (PageContext pageContext) => ProfileEditor(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '修改昵称',
          subtitle: '',
          icon: FontAwesomeIcons.edit,
          url: '/profile/editor/nickname',
          buildPage: (PageContext pageContext) => EditNickName(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '修改实名',
          subtitle: '',
          icon: FontAwesomeIcons.edit,
          url: '/profile/editor/realname',
          buildPage: (PageContext pageContext) => EditRealName(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '修改个人签名',
          subtitle: '',
          icon: FontAwesomeIcons.edit,
          url: '/profile/editor/signature',
          buildPage: (PageContext pageContext) => EditSignature(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '修改性别',
          subtitle: '',
          icon: FontAwesomeIcons.edit,
          url: '/profile/editor/sex',
          buildPage: (PageContext pageContext) => EditSex(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '其它属性',
          subtitle: '',
          icon: FontAwesomeIcons.edit,
          url: '/profile/editor/more',
          buildPage: (PageContext pageContext) => ProfileMore(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '钱包',
          subtitle: '',
          icon: Icons.account_balance_wallet,
          url: '/wallet',
          buildPage: (PageContext pageContext) => Wallet(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '银行卡',
          subtitle: '',
          icon: Icons.account_balance_wallet,
          url: '/wallet/cards',
          buildPage: (PageContext pageContext) => PersonCardPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '银行卡',
          subtitle: '',
          icon: Icons.account_balance_wallet,
          url: '/wallet/addCard',
          buildPage: (PageContext pageContext) => AddPersonCardPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '充值结果',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/rechargeResult',
          buildPage: (PageContext pageContext) => RechargeResultPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '提现结果',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/withdrawResult',
          buildPage: (PageContext pageContext) => WithdrawResultPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '银行卡',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/card',
          buildPage: (PageContext pageContext) => BankCards(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '零钱',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/change',
          buildPage: (PageContext pageContext) => Change(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '洇金',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/absorb',
          buildPage: (PageContext pageContext) => Absorb(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '在订单',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/onorder',
          buildPage: (PageContext pageContext) => Onorder(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '收款',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/receivables',
          buildPage: (PageContext pageContext) => Receivables(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '付款',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/payables',
          buildPage: (PageContext pageContext) => Payables(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '设置金额',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/receivables/settings',
          buildPage: (PageContext pageContext) => AmountSettings(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '收款记录',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/receivables/record',
          buildPage: (PageContext pageContext) => ReceivablesRecord(
            context: pageContext,
          ),
        ),
        LogicPage(
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
        LogicPage(
          title: '帑银',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/ty',
          buildPage: (PageContext pageContext) => TY(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '纹银',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/weny',
          buildPage: (PageContext pageContext) => Weny(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '充值',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/change/deposit',
          buildPage: (PageContext pageContext) => Deposit(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '提现',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/change/cashout',
          buildPage: (PageContext pageContext) => Cashout(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '零钱明细',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/change/bill',
          buildPage: (PageContext pageContext) => ChangeBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '在订单明细',
          subtitle: '',
          desc: '在订单账单',
          icon: GalleryIcons.shrine,
          url: '/wallet/onorder/bill',
          buildPage: (PageContext pageContext) => OnorderBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '洇金明细',
          subtitle: '',
          desc: '在订单账单',
          icon: GalleryIcons.shrine,
          url: '/wallet/absorb/bill',
          buildPage: (PageContext pageContext) => AbsorbBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '转账',
          subtitle: '',
          desc: 'p2p转账',
          icon: GalleryIcons.shrine,
          url: '/wallet/receipt/transTo',
          buildPage: (PageContext pageContext) => TranslateToPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '纹银账户',
          subtitle: '',
          desc: '存量账户',
          icon: GalleryIcons.shrine,
          url: '/wybank/account/stock',
          buildPage: (PageContext pageContext) => StockWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '纹银账单',
          subtitle: '',
          desc: '纹银账单',
          icon: GalleryIcons.shrine,
          url: '/wybank/bill/stock',
          buildPage: (PageContext pageContext) => StockWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '冻结账户',
          subtitle: '',
          desc: '纹银冻结账户',
          icon: GalleryIcons.shrine,
          url: '/wybank/account/freezen',
          buildPage: (PageContext pageContext) => FreezenWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '冻结账单',
          subtitle: '',
          desc: '冻结账单',
          icon: GalleryIcons.shrine,
          url: '/wybank/bill/freezen',
          buildPage: (PageContext pageContext) => FreezenWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '收益账户',
          subtitle: '',
          desc: '纹银收益账户',
          icon: GalleryIcons.shrine,
          url: '/wybank/account/profit',
          buildPage: (PageContext pageContext) => ProfitWenyAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '收益账单',
          subtitle: '',
          desc: '收益账单',
          icon: GalleryIcons.shrine,
          url: '/wybank/bill/profit',
          buildPage: (PageContext pageContext) => ProfitWenyBill(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '',
          subtitle: '',
          desc: '充值单查看',
          icon: GalleryIcons.shrine,
          url: '/wallet/recharge/details',
          buildPage: (PageContext pageContext) => RechargeDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '',
          subtitle: '',
          desc: '提现单查看',
          icon: GalleryIcons.shrine,
          url: '/wallet/withdraw/details',
          buildPage: (PageContext pageContext) => WithdrawDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '',
          subtitle: '',
          desc: '提现撤销单',
          icon: GalleryIcons.shrine,
          url: '/wallet/withdraw/cancel',
          buildPage: (PageContext pageContext) => WithdrawCancel(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '',
          subtitle: '',
          desc: '申购单明细',
          icon: GalleryIcons.shrine,
          url: '/wybank/purchase/details',
          buildPage: (PageContext pageContext) => PurchaseDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '',
          subtitle: '',
          desc: '承兑单明细',
          icon: GalleryIcons.shrine,
          url: '/wybank/exchange/details',
          buildPage: (PageContext pageContext) => ExchangeDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '',
          subtitle: '',
          desc: '转账洇金单明细',
          icon: GalleryIcons.shrine,
          url: '/wallet/trans_absorb/details',
          buildPage: (PageContext pageContext) => TransAbsorbDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '',
          subtitle: '',
          desc: '存入洇金单明细',
          icon: GalleryIcons.shrine,
          url: '/wallet/deposit_absorb/details',
          buildPage: (PageContext pageContext) => DepositAbsorbDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '',
          subtitle: '',
          desc: '收益单明细',
          icon: GalleryIcons.shrine,
          url: '/wybank/trans_profit/details',
          buildPage: (PageContext pageContext) => TransProfitDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '',
          subtitle: '',
          desc: '账金入账明细',
          icon: GalleryIcons.shrine,
          url: '/wybank/trans_shunter/details',
          buildPage: (PageContext pageContext) => TransShunterDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '',
          subtitle: '',
          desc: '经营尾金入账明细',
          icon: GalleryIcons.shrine,
          url: '/wybank/deposit_hubtails/details',
          buildPage: (PageContext pageContext) => DepositHubTailsDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '',
          subtitle: '',
          desc: '支付明细',
          icon: GalleryIcons.shrine,
          url: '/wallet/pay/details',
          buildPage: (PageContext pageContext) => PayDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '',
          subtitle: '',
          desc: '转账明细',
          icon: GalleryIcons.shrine,
          url: '/wallet/p2p/details',
          buildPage: (PageContext pageContext) => P2PDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '桌面设置',
          subtitle: '',
          icon: Icons.dashboard,
          url: '/desktop/settings',
          buildPage: (PageContext pageContext) => DesktopSettings(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '栏目',
          subtitle: '',
          icon: Icons.apps,
          url: '/desktop/lets/settings',
          buildPage: (PageContext pageContext) => DeskletsSettings(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '墙纸',
          subtitle: '',
          icon: Icons.wallpaper,
          url: '/desktop/wallpappers/settings',
          buildPage: (PageContext pageContext) => Wallpappers(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '系统设置',
          subtitle: '',
          icon: Icons.settings,
          url: '/system/settings',
          buildPage: (PageContext pageContext) => GberaSettings(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '主题',
          subtitle: '',
          icon: FontAwesomeIcons.themeisle,
          url: '/system/themes',
          buildPage: (PageContext pageContext) => Themes(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '用户协议',
          subtitle: '',
          icon: FontAwesomeIcons.fileContract,
          url: '/system/user/contract',
          buildPage: (PageContext pageContext) => UserContract(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '关于',
          subtitle: '',
          icon: Icons.info_outline,
          url: '/system/about',
          buildPage: (PageContext pageContext) => About(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '用户与账号',
          subtitle: '',
          icon: Icons.person_outline,
          url: '/users/list',
          buildPage: (PageContext pageContext) => UserAndAccountList(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '账号',
          subtitle: '',
          icon: Icons.person_outline,
          url: '/users/accounts/viewer',
          buildPage: (PageContext pageContext) => AccountViewer(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '应用账号列表',
          subtitle: '',
          icon: Icons.person_outline,
          url: '/users/accounts/app',
          buildPage: (PageContext pageContext) => AppAccounts(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '新建账号',
          subtitle: '',
          icon: Icons.person_outline,
          url: '/users/accounts/addAccount',
          buildPage: (PageContext pageContext) => AddAccount(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '修改密码',
          subtitle: '',
          icon: Icons.person_outline,
          url: '/users/accounts/editPassword',
          buildPage: (PageContext pageContext) => EditPassword(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '登录',
          subtitle: '',
          icon: Icons.person_outline,
          url: '/users/accounts/login',
          buildPage: (PageContext pageContext) => AccountLogin(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '我的角色',
          subtitle: '',
          icon: Icons.recent_actors,
          url: '/users/roles',
          buildPage: (PageContext pageContext) => Roles(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '登录账号',
          subtitle: '',
          icon: Icons.account_box,
          url: '/users/accounts',
          buildPage: (PageContext pageContext) => Accounts(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '金证喷泉',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/fountain',
          buildPage: (PageContext pageContext) => Geofountain(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '元宝',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/yuanbao',
          buildPage: (PageContext pageContext) => GeoYuanbao(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '地圈设置',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/settings.lord',
          buildPage: (PageContext pageContext) => GeoSettingsLord(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '地圈设置',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/settings.mines',
          buildPage: (PageContext pageContext) => GeoSettingsMines(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '地圈设置',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/geosphere/settings.fans',
          buildPage: (PageContext pageContext) => GeoSettingsFans(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '地圈设置',
          subtitle: '感知器查看器的设置',
          icon: GalleryIcons.shrine,
          url: '/geosphere/settings.viewer',
          buildPage: (PageContext pageContext) => GeoSettingsViewer(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '银行卡',
          subtitle: '',
          icon: GalleryIcons.shrine,
          url: '/wallet/card/details',
          buildPage: (PageContext pageContext) => BankCardDetails(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '栏目列表',
          subtitle: '',
          desc: '列出门户栏目',
          icon: GalleryIcons.shrine,
          url: '/desktop/portlets',
          buildPage: (PageContext pageContext) => PortletList(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '成为地商',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/market/request/landagent',
          buildPage: (PageContext pageContext) => RequestLandagent(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '成为运营商',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/market/request/isp',
          buildPage: (PageContext pageContext) => RequestISP(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: 'goGOGO',
          subtitle: '',
          desc: '平台购物商城',
          icon: GalleryIcons.shrine,
          url: '/market/goGOGO',
          buildPage: (PageContext pageContext) => Gogogo(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '购物车',
          subtitle: '',
          desc: '平台购物商城',
          icon: GalleryIcons.shrine,
          url: '/market/shopping_cart',
          buildPage: (PageContext pageContext) => ShoppingCartPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '帑指交易所',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/market/tz_list',
          buildPage: (PageContext pageContext) => TZList(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '帑银交易所',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/market/ty_list',
          buildPage: (PageContext pageContext) => TYList(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '帑指交易所',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/market/exchange/tz',
          buildPage: (PageContext pageContext) => TZExchange(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '期货·地商',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/market/exchange/tz/land_agent',
          buildPage: (PageContext pageContext) => LandAgentFutrue(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '帑银交易所',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/market/exchange/ty',
          buildPage: (PageContext pageContext) => TYExchange(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '股市·地商',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/market/exchange/ty/land_agent',
          buildPage: (PageContext pageContext) => LandAgentStock(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '选择分类',
          subtitle: '',
          desc: '平台购物商城',
          icon: GalleryIcons.shrine,
          url: '/goGOGO/category/filter',
          buildPage: (PageContext pageContext) => SelectGoGoGoCategory(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '对话框',
          subtitle: '',
          desc: '聊天对话',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/talk',
          buildPage: (PageContext pageContext) => ChatTalk(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '查看地商运营证书',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/room/view_licence',
          buildPage: (PageContext pageContext) => ViewLicencePage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '会话设置',
          subtitle: '',
          desc: '对话、群设置',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/room/settings',
          buildPage: (PageContext pageContext) => ChatRoomSettings(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '添加朋友',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/add_friend',
          buildPage: (PageContext pageContext) => AddFriend(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '导入公众',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/imports/persons',
          buildPage: (PageContext pageContext) => ImportPersons(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '好友',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/friends',
          buildPage: (PageContext pageContext) => FriendPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '设置聊天室名',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/room/settings/setTitle',
          buildPage: (PageContext pageContext) => ChatroomSetTitle(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '设置聊天室公告',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/room/settings/setNotice',
          buildPage: (PageContext pageContext) => ChatroomSetNotice(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '发布公告',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/room/publishNotice',
          buildPage: (PageContext pageContext) => PublishNotice(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '显示聊天室二维码',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/room/qrcode',
          buildPage: (PageContext pageContext) => ChatroomQrcode(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '设置在聊天室的昵称',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/room/setNickName',
          buildPage: (PageContext pageContext) => ChatroomSetNickName(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '显示聊天室成员昵称',
          subtitle: '',
          desc: '',
          icon: GalleryIcons.shrine,
          url: '/portlet/chat/room/showNickName',
          buildPage: (PageContext pageContext) => ChatroomShowNickName(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '查看运营证书',
          subtitle: '',
          icon: Icons.business,
          url: '/viewer/licence',
          buildPage: (PageContext pageContext) => ViewLicence(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '查看运营证书',
          subtitle: '',
          icon: Icons.business,
          url: '/viewer/licenceById',
          buildPage: (PageContext pageContext) => OrgLicenceByIdPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '扫码付款结果',
          subtitle: '',
          icon: Icons.business,
          url: '/receivables/result',
          buildPage: (PageContext pageContext) => ReceivableResultPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '扫码收款结果',
          subtitle: '',
          icon: Icons.business,
          url: '/payables/result',
          buildPage: (PageContext pageContext) => PayableResultPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '流量中国',
          subtitle: '',
          icon: Icons.business,
          url: '/chasechain/traffic/pools',
          buildPage: (PageContext pageContext) => TrafficPoolsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '内容盒',
          subtitle: '',
          icon: Icons.business,
          url: '/chasechain/box',
          buildPage: (PageContext pageContext) => ContentBoxPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '内容提供商',
          subtitle: '',
          icon: Icons.business,
          url: '/chasechain/provider',
          buildPage: (PageContext pageContext) => ContentProviderPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '推荐个人偏好设置',
          subtitle: '',
          icon: Icons.business,
          url: '/chasechain/recommender/profile',
          buildPage: (PageContext pageContext) => RecommenderProfilePage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '流量池信息',
          subtitle: '',
          icon: Icons.business,
          url: '/chasechain/pool/view',
          buildPage: (PageContext pageContext) => PoolViewPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '位置地图',
          subtitle: '',
          icon: Icons.business,
          url: '/gbera/location',
          buildPage: (PageContext pageContext) => LocationMapPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '用户视图',
          subtitle: '',
          icon: Icons.business,
          url: '/person/view',
          buildPage: (PageContext pageContext) => PersonViewPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '内容盒信息',
          subtitle: '',
          icon: Icons.business,
          url: '/chasechain/box/view',
          buildPage: (PageContext pageContext) => ContentBoxViewPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '申请洇取器',
          subtitle: '',
          icon: Icons.business,
          url: '/absorber/apply/geosphere',
          buildPage: (PageContext pageContext) => AbsorberGeoApplyPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '申请洇取器',
          subtitle: '',
          icon: Icons.business,
          url: '/absorber/apply/simple',
          buildPage: (PageContext pageContext) => AbsorberSimpleApplyPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '洇取器',
          subtitle: '',
          icon: Icons.business,
          url: '/absorber/details/geo',
          buildPage: (PageContext pageContext) => GeoAbsorberDetailsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '洇取器',
          subtitle: '',
          icon: Icons.business,
          url: '/absorber/details/simple',
          buildPage: (PageContext pageContext) => SimpleAbsorberDetailsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '投资记录',
          subtitle: '',
          icon: Icons.business,
          url: '/absorber/invest/details',
          buildPage: (PageContext pageContext) => AbsorberInvestRecordsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '设置',
          subtitle: '',
          icon: Icons.business,
          url: '/absorber/settings/geo',
          buildPage: (PageContext pageContext) => GeoAbsorberSettingsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '设置',
          subtitle: '',
          icon: Icons.business,
          url: '/absorber/settings/simple',
          buildPage: (PageContext pageContext) => SimpleAbsorberSettingsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '洇取人视图',
          subtitle: '',
          icon: Icons.business,
          url: '/absorber/recipient/view',
          buildPage: (PageContext pageContext) => AbsorberRecipientsViewPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '公众洇取记录',
          subtitle: '',
          icon: Icons.business,
          url: '/absorber/recipient/records',
          buildPage: (PageContext pageContext) => AbsorberRecipientsRecordsPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '选择公众',
          subtitle: '',
          icon: Icons.business,
          url: '/absorber/details/selectRecipients',
          buildPage: (PageContext pageContext) => SelectPersons(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '选择洇取成员',
          subtitle: '',
          icon: Icons.business,
          url: '/absorber/details/recipients_selector',
          buildPage: (PageContext pageContext) => AbsorberRecipientsSelector(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '招财猫',
          subtitle: '',
          icon: IconData(
            0xe6b2,
            fontFamily: 'absorber',
          ),
          url: '/myabsorbers',
          buildPage: (PageContext pageContext) => MyAbsorbersPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '码片列表',
          subtitle: '',
          icon: null,
          url: '/robot/qrcodeSlices',
          buildPage: (PageContext pageContext) => QrcodeSlicePage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '码片批次',
          subtitle: '',
          icon: null,
          url: '/robot/sliceBatchPage',
          buildPage: (PageContext pageContext) => SliceBatchPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '码片视图',
          subtitle: '',
          icon: null,
          url: '/robot/slice/view',
          buildPage: (PageContext pageContext) => QrcodeSliceView(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '码片',
          subtitle: '',
          icon: null,
          url: '/robot/slice/image',
          buildPage: (PageContext pageContext) => QrcodeSliceImagePage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '创建码片',
          subtitle: '',
          icon: null,
          url: '/robot/createSlices',
          buildPage: (PageContext pageContext) => CreateSlicesPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '码片生成过程',
          subtitle: '',
          icon: null,
          url: '/robot/createSlices/progress',
          buildPage: (PageContext pageContext) => CreateSlicesProgressPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '码片模板',
          subtitle: '',
          icon: null,
          url: '/robot/slice/template',
          buildPage: (PageContext pageContext) => SliceTemplatePage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '码片模板市场',
          subtitle: '',
          icon: null,
          url: '/robot/slice/templates',
          buildPage: (PageContext pageContext) => SliceTemplatesPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '码片浏览器',
          subtitle: '',
          icon: null,
          url: '/robot/slice/webview',
          buildPage: (PageContext pageContext) => SliceWebViewPage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '码片模板编辑器',
          subtitle: '',
          icon: null,
          url: '/robot/editor/template/',
          buildPage: (PageContext pageContext) => SliceTemplateEditor(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '常规码片模板',
          subtitle: '',
          icon: null,
          url: '/robot/slice/template/normal',
          buildPage: (PageContext pageContext) => NormalSliceTemplate(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '常规码片图片',
          subtitle: '',
          icon: null,
          url: '/robot/slice/image/normal',
          buildPage: (PageContext pageContext) => NormalSliceImage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '官方码片模板',
          subtitle: '',
          icon: null,
          url: '/robot/slice/template/official',
          buildPage: (PageContext pageContext) => OfficialTemplate(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '小确幸码片图片',
          subtitle: '',
          icon: null,
          url: '/robot/slice/image/official',
          buildPage: (PageContext pageContext) => OfficialSliceImage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '小确幸码片模板',
          subtitle: '',
          icon: null,
          url: '/robot/slice/template/happiness',
          buildPage: (PageContext pageContext) => HappinessTemplate(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '小确幸码片图片',
          subtitle: '',
          icon: null,
          url: '/robot/slice/image/happiness',
          buildPage: (PageContext pageContext) => HappinessSliceImage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '喜报码片模板',
          subtitle: '',
          icon: null,
          url: '/robot/slice/template/xibao',
          buildPage: (PageContext pageContext) => XibaoSliceTemplate(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '喜报码片图片',
          subtitle: '',
          icon: null,
          url: '/robot/slice/image/xibao',
          buildPage: (PageContext pageContext) => XibaoSliceImage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '财神码片模板',
          subtitle: '',
          icon: null,
          url: '/robot/slice/template/caisheng',
          buildPage: (PageContext pageContext) => CaishengTemplate(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '财神码片图片',
          subtitle: '',
          icon: null,
          url: '/robot/slice/image/caisheng',
          buildPage: (PageContext pageContext) => CaishengSliceImage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '明信片码片模板',
          subtitle: '',
          icon: null,
          url: '/robot/slice/template/minxinpian',
          buildPage: (PageContext pageContext) => MinXinPianTemplate(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '明信片码片图片',
          subtitle: '',
          icon: null,
          url: '/robot/slice/image/minxinpian',
          buildPage: (PageContext pageContext) => MinXinPianSliceImage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '吃鸡码片模板',
          subtitle: '',
          icon: null,
          url: '/robot/slice/template/chiji',
          buildPage: (PageContext pageContext) => ChijiTemplate(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '吃鸡码片图片',
          subtitle: '',
          icon: null,
          url: '/robot/slice/image/chiji',
          buildPage: (PageContext pageContext) => ChijiSliceImage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '王者荣耀码片模板',
          subtitle: '',
          icon: null,
          url: '/robot/slice/template/wangzherongyao',
          buildPage: (PageContext pageContext) => WangzheruyaoTemplate(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '王者荣耀码片图片',
          subtitle: '',
          icon: null,
          url: '/robot/slice/image/wangzherongyao',
          buildPage: (PageContext pageContext) => WangzheruyaoSliceImage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '爱情耀码片模板',
          subtitle: '',
          icon: null,
          url: '/robot/slice/template/love',
          buildPage: (PageContext pageContext) => LoveTemplate(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '爱情荣耀码片图片',
          subtitle: '',
          icon: null,
          url: '/robot/slice/image/love',
          buildPage: (PageContext pageContext) => LoveSliceImage(
            context: pageContext,
          ),
        ),
        LogicPage(
          title: '展示发现的猫',
          subtitle: '展示发现的猫',
          icon: null,
          url: '/robot/slice/showAbsorbers',
          buildPage: (PageContext pageContext) => ShowSliceAbsorbersPage(
            context: pageContext,
          ),
        ),
      ],
    );
  }
}
