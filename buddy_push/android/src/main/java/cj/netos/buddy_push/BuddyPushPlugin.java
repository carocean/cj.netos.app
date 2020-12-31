package cj.netos.buddy_push;

import android.app.Application;
import android.content.Context;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;

import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * BuddyPushPlugin
 */
public class BuddyPushPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "buddy_push");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("supportsDriver")) {//注意：onMethodCall方法必须以result返回，否则会导致flutter调用方堵塞
            Map<String, Object> driverMap = new HashMap<>();
            String driver = null;
            if (isBrandHuawei()) {
                driver = "huawei";
            }
            if (isBrandOppo()) {
                driver = "oppo";
            }
            if (isBrandVivo()) {
                driver = "vivo";
            }
            if (isBrandXiaomi()) {
                driver = "xiaomi";
            }
            driverMap.put("isSupports", (driver != null));
            driverMap.put("driver", driver == null ? "unknown" : driver);
            result.success(driverMap);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }


    public void onFlutterUiDisplayed(Map<String, String> waitEvent) {
        if (waitEvent == null) {
            waitEvent = new HashMap<>();
            waitEvent.put("driver","huawei");
            waitEvent.put("error","获取regId失败");
        }
        if (waitEvent.containsKey("regId")){
            channel.invokeMethod("onToken", waitEvent);
        }else{
            channel.invokeMethod("onError", waitEvent);
        }
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
