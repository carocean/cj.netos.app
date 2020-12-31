package cj.netos.netos_app;

import android.app.ActivityManager;
import android.content.Context;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;

import com.heytap.msp.push.HeytapPushManager;
import com.huawei.agconnect.config.AGConnectServicesConfig;
import com.huawei.hms.aaid.HmsInstanceId;
import com.huawei.hms.aaid.init.AutoInitHelper;
import com.huawei.hms.common.ApiException;
import com.huawei.hms.utils.StringUtil;
import com.vivo.push.IPushActionListener;
import com.vivo.push.PushClient;
import com.xiaomi.mipush.sdk.MiPushClient;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import cj.netos.buddy_push.BuddyPushPlugin;
import io.flutter.app.FlutterApplication;

public class MicrogeoApplication extends FlutterApplication {
    final static String _TAG = "microgeo native";
    final static String _XIAOMI_APPID = "2882303761518779570";
    final static String _XIAOMI_APPKEY = "5891877941570";
    final static String _OPPO_APPKEY = "7084cbae35cf4f6f9c4456ab733bf866";
    final static String _OPPO_APPSECRET = "659df70611a345f4be34b6623852a21c";
    Map<String, String> waitEvent;

    @Override
    public void onCreate() {
        super.onCreate();

        if (BuddyPushPlugin.isBrandHuawei()) {
            huawei();
        }
        if (BuddyPushPlugin.isBrandVivo()) {
            vivo();
        }
        if (BuddyPushPlugin.isBrandOppo()) {
            oppo();
        }
        if (BuddyPushPlugin.isBrandXiaomi()) {
            xiaomi();
        }
    }

    public void setCurrentPusherDriver(Map<String, String> waitEvent) {
        this.waitEvent = waitEvent;
    }


    private void xiaomi() {
        //初始化push推送服务
        if (shouldInit()) {
            MiPushClient.registerPush(this, _XIAOMI_APPID, _XIAOMI_APPKEY);
            String regId = MiPushClient.getRegId(this);
            if (regId != null && !"".equals(regId)) {
                Map<String, String> map = new HashMap<>();
                map.put("driver", "xiaomi");
                map.put("regId", regId);
                waitEvent = map;
            }
            Log.d("---------3", regId == null ? "null" : regId);
        }

    }

    private boolean shouldInit() {
        ActivityManager am = ((ActivityManager) getSystemService(Context.ACTIVITY_SERVICE));
        List<ActivityManager.RunningAppProcessInfo> processInfos = am.getRunningAppProcesses();
        String mainProcessName = getApplicationInfo().processName;
        int myPid = android.os.Process.myPid();
        for (ActivityManager.RunningAppProcessInfo info : processInfos) {
            if (info.pid == myPid && mainProcessName.equals(info.processName)) {
                return true;
            }
        }
        return false;
    }

    private void oppo() {
        //初始化push，调用注册接口
        try {
            HeytapPushManager.init(this, true);
            HeytapPushManager.register(this, _OPPO_APPKEY, _OPPO_APPSECRET, new OppoCallBackResultService(this));//setPushCallback接口也可设置callback
            HeytapPushManager.requestNotificationPermission();
//            String regId = HeytapPushManager.getRegisterID();
//            Log.d("---------4",regId==null?"null":regId);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void vivo() {
        // 在当前工程入口函数，建议在Application的onCreate函数中，添加以下代码
        Context the = this;
        PushClient.getInstance(getApplicationContext()).initialize();
// 打开push开关, 关闭为turnOffPush，详见api接入文档
        PushClient.getInstance(getApplicationContext()).turnOnPush(new IPushActionListener() {
            @Override
            public void onStateChanged(int state) {
                // TODO: 开关状态处理， 0代表成功
                if (waitEvent != null) {
                    return;
                }
                if (state != 0) {
                    Log.d(_TAG, "vivo打开失败");
                    Map<String, String> map = new HashMap<>();
                    map.put("driver", "vivo");
                    map.put("error", "打开失败");
                    waitEvent = map;
                } else {
                    Log.d(_TAG, "vivo打开成功");
                    String regId = PushClient.getInstance(the).getRegId();
                    if (regId != null && !"".equals(regId)) {
                        Map<String, String> map = new HashMap<>();
                        map.put("driver", "vivo");
                        map.put("regId", regId);
                        waitEvent = map;
                    } else {
                        Map<String, String> map = new HashMap<>();
                        map.put("driver", "vivo");
                        map.put("error", "获取regId失败");
                        waitEvent = map;
                    }
                }
            }
        });
//        Log.d(_TAG, "---- regID = " + regId);

    }

    private void huawei() {
        Context the = this;
        AutoInitHelper.setAutoInitEnabled(the, true);
        new Thread(new Runnable() {
            @Override
            public void run() {
                if (waitEvent != null) {
                    return;
                }
                try {
                    // read from agconnect-services.json
                    String appId = AGConnectServicesConfig.fromContext(the).getString("client/app_id");
                    String token = HmsInstanceId.getInstance(the).getToken(appId, "HCM");
                    Log.i(_TAG, "get token:" + token);

                    if (!TextUtils.isEmpty(token)) {
                        Map<String, String> map = new HashMap<>();
                        map.put("driver","huawei");
                        map.put("regId",token);
                        waitEvent=map;
                    } else {
                        Map<String, String> map = new HashMap<>();
                        map.put("driver","huawei");
                        map.put("error","获取regId失败");
                        waitEvent=map;
                    }
                } catch (ApiException e) {
                    Log.e(_TAG, "get token failed, " + e);
                    Map<String, String> map = new HashMap<>();
                    map.put("driver","huawei");
                    map.put("error","获取regId失败:"+e);
                    waitEvent=map;
                }
            }
        });
    }

}
