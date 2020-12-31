package cj.netos.netos_app;

import android.net.Uri;

import com.huawei.hms.push.HmsMessageService;

import java.util.HashMap;
import java.util.Map;

public class HuaweiHmsMessageService extends HmsMessageService {

    @Override
    public void onNewToken(String s) {
        super.onNewToken(s);
        android.util.Log.d("-----test", s);
        MicrogeoApplication application= (MicrogeoApplication) getApplication();
        Map<String, String> map = new HashMap<>();
        map.put("driver","huawei");
        map.put("regId",s);
        application.setCurrentPusherDriver(map);
    }

    /***
     * 清掉角标放在此处似乎在切换应用到后台时并没有清掉，因此可通过侦听类来实现前后台切换时清掉
     * https://www.cnblogs.com/baiyi168/p/8252825.html
     */
    @Override
    public void onDestroy() {
        super.onDestroy();

        android.util.Log.d("-----test", "onDestroy");
        android.os.Bundle extra = new android.os.Bundle();
        extra.putString("package", "cj.netos.netos_app");
        extra.putString("class", "cj.netos.netos_app.MainActivity");
        extra.putInt("badgenumber", 0);//清掉角标
        this.getContentResolver().call(Uri.parse("content://com.huawei.android.launcher.settings/badge/"), "change_badge", null, extra);
    }
    /*
    //华为透传消费
    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);
        Log.d("-----test",remoteMessage.getData());
        Bundle extra = new Bundle();
        extra.putString("package", "cj.netos.netos_app");
        extra.putString("class", "cj.netos.netos_app.MainActivity");
        i=i+1;
        extra.putInt("badgenumber", i);//经测试，如果应用是关闭状态并没有提示。因此要使用华为的非透传消息，通过消息体自带角标字段来显示
        this.getContentResolver().call(Uri.parse("content://com.huawei.android.launcher.settings/badge/"), "change_badge", null, extra);

    }

 */
}
