package cj.netos.netos_app;

import android.content.Context;

import com.vivo.push.model.UPSNotificationMessage;
import com.vivo.push.sdk.OpenClientPushMessageReceiver;

import java.util.HashMap;
import java.util.Map;

public class VivoPushMessageReceiverImpl extends OpenClientPushMessageReceiver {


    /***
     * 当首次turnOnPush成功或regId发生改变时，回调此方法
     * 如需获取regId，请使用PushClient.getInstance(context).getRegId()
     * @param context 应用上下文

     * @param regId 注册id
     */
    @Override
    public void onReceiveRegId(Context context, String regId) {
        MicrogeoApplication application = (MicrogeoApplication) context;
        Map<String, String> map = new HashMap<>();
        map.put("driver","vivo");
        map.put("regId",regId);
        application.setCurrentPusherDriver(map);
        android.util.Log.d("---------regId", regId);
    }

}