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

import io.flutter.app.FlutterApplication;

public class MicrogeoApplication extends FlutterApplication {
    final static String _TAG = "microgeo native";
    final static String _XIAOMI_APPID = "2882303761518779570";
    final static String _XIAOMI_APPKEY = "5891877941570";
    final static String _OPPO_APPKEY = "7084cbae35cf4f6f9c4456ab733bf866";
    final static String _OPPO_APPSECRET = "659df70611a345f4be34b6623852a21c";
    private Map<String, String> __currentPusherDriver;//供buddy_push反射调用

    @Override
    public void onCreate() {
        super.onCreate();
        __currentPusherDriver = new HashMap<>();
        if (isBrandHuawei()) {
            huawei();
        }
        if (isBrandVivo()) {
            vivo();
        }
        if (isBrandOppo()) {
            oppo();
        }
        if (isBrandXiaomi()) {
            xiaomi();
        }
    }
    public void setCurrentPusherDriver(String driver,String regId){
        __currentPusherDriver.put("driver",driver);
        __currentPusherDriver.put("regId", regId);
    }
    private void xiaomi() {
        //初始化push推送服务
        if (shouldInit()) {
            MiPushClient.registerPush(this, _XIAOMI_APPID, _XIAOMI_APPKEY);
            String regId = MiPushClient.getRegId(this);
            __currentPusherDriver.put("driver", "xiaomi");
            __currentPusherDriver.put("regId", regId);
            Log.d("---------3",regId==null?"null":regId);
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
            HeytapPushManager.register(this, _OPPO_APPKEY, _OPPO_APPSECRET, new OppoCallBackResultService(__currentPusherDriver));//setPushCallback接口也可设置callback
            HeytapPushManager.requestNotificationPermission();
//            String regId = HeytapPushManager.getRegisterID();
//            Log.d("---------4",regId==null?"null":regId);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void vivo() {
        // 在当前工程入口函数，建议在Application的onCreate函数中，添加以下代码
        PushClient.getInstance(getApplicationContext()).initialize();
// 打开push开关, 关闭为turnOffPush，详见api接入文档
        PushClient.getInstance(getApplicationContext()).turnOnPush(new IPushActionListener() {
            @Override
            public void onStateChanged(int state) {
                // TODO: 开关状态处理， 0代表成功
                if (state != 0) {
                    Log.d(_TAG, "vivo打开失败");
                } else {
                    Log.d(_TAG, "vivo打开成功");
                }
            }
        });
        String regId = PushClient.getInstance(this).getRegId() ;
//        Log.d(_TAG, "---- regID = " + regId);
        if (regId != null && !"".equals(regId)) {
            __currentPusherDriver.put("driver", "vivo");
            __currentPusherDriver.put("regId", regId);
        }
    }

    private void huawei() {
        Context the = this;
        AutoInitHelper.setAutoInitEnabled(the, true);
        new Thread() {
            @Override
            public void run() {
                try {
                    // read from agconnect-services.json
                    String appId = AGConnectServicesConfig.fromContext(the).getString("client/app_id");
                    String token = HmsInstanceId.getInstance(the).getToken(appId, "HCM");
                    Log.i(_TAG, "get token:" + token);
                    if (!TextUtils.isEmpty(token)) {
                        __currentPusherDriver.put("driver", "huawei");
                        __currentPusherDriver.put("regId", token);
                    }
                } catch (ApiException e) {
                    Log.e(_TAG, "get token failed, " + e);
                }
            }
        }.start();
    }

    public static boolean isBrandHuawei() {
        return "huawei".equalsIgnoreCase(Build.BRAND) || "huawei".equalsIgnoreCase(Build.MANUFACTURER);
    }

    public static boolean isBrandVivo() {
        return "vivo".equalsIgnoreCase(Build.BRAND) || "vivo".equalsIgnoreCase(Build.MANUFACTURER);
    }

    public static boolean isBrandXiaomi() {
        return "Redmi".equalsIgnoreCase(Build.BRAND) || "Xiaomi".equalsIgnoreCase(Build.MANUFACTURER);
    }

    public static boolean isBrandOppo() {
        return "OPPO".equalsIgnoreCase(Build.BRAND) || "OPPO".equalsIgnoreCase(Build.MANUFACTURER);
    }

}
