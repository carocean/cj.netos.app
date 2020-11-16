package cj.netos.netos_app;

import com.heytap.msp.push.callback.ICallBackResultService;

import java.util.Map;

public class OppoCallBackResultService implements ICallBackResultService {
    private final Map<String, String> currentPusherDriver;

    public OppoCallBackResultService(Map<String, String> currentPusherDriver) {
        this.currentPusherDriver=currentPusherDriver;
    }

    @Override
    public void onRegister(int code, String s) {
        if (code == 0) {
            android.util.Log.d("注册成功", "registerId:" + s);
            currentPusherDriver.put("driver", "oppo");
            currentPusherDriver.put("regId", s);
        } else {
            android.util.Log.d("注册失败", "code=" + code + ",msg=" + s);
        }

    }

    @Override
    public void onUnRegister(int code) {
        if (code == 0) {
            currentPusherDriver.put("driver", "oppo");
            currentPusherDriver.put("regId", "");
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
