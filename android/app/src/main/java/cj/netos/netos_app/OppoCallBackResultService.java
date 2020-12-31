package cj.netos.netos_app;

import com.heytap.msp.push.callback.ICallBackResultService;

import java.util.HashMap;
import java.util.Map;

import cj.netos.buddy_push.BuddyPushPlugin;

public class OppoCallBackResultService implements ICallBackResultService {
   MicrogeoApplication application;
    public OppoCallBackResultService(MicrogeoApplication application) {
        this.application=application;
    }

    @Override
    public void onRegister(int code, String s) {
        if (code == 0) {
            android.util.Log.d("注册成功", "registerId:" + s);
            Map<String, String> map = new HashMap<>();
            map.put("driver","oppo");
            map.put("regId",s);
            application.setCurrentPusherDriver(map);
        } else {
            android.util.Log.d("注册失败", "code=" + code + ",msg=" + s);
            Map<String, String> map = new HashMap<>();
            map.put("driver","oppo");
            map.put("error","code=" + code + ",msg=" + s);
            application.setCurrentPusherDriver(map);
        }

    }

    @Override
    public void onUnRegister(int code) {
        if (code == 0) {
            android.util.Log.d("注销成功", "code=" + code);
        } else {
            android.util.Log.d("注销失败", "code=" + code);
        }
    }

    @Override
    public void onGetPushStatus(final int code, int status) {
        if (code == 0 && status == 0) {
            android.util.Log.d("Push状态正常", "code=" + code + ",status=" + status);
        } else {
            android.util.Log.d("Push状态错误", "code=" + code + ",status=" + status);
        }
    }

    @Override
    public void onGetNotificationStatus(final int code, final int status) {
        if (code == 0 && status == 0) {
            android.util.Log.d("通知状态正常", "code=" + code + ",status=" + status);
        } else {
            android.util.Log.d("通知状态错误", "code=" + code + ",status=" + status);
        }
    }

    @Override
    public void onSetPushTime(final int code, final String s) {
        android.util.Log.d("SetPushTime", "code=" + code + ",result:" + s);
    }
}
