package cj.netos.accept_share;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;
import com.google.gson.Gson;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * AcceptSharePlugin
 */
public class AcceptSharePlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Context context;
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "accept_share");
        channel.setMethodCallHandler(this);
        context= flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.startsWith("forward")) {//跳转到主activity
            Intent intent =context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
//            intent.setAction(call.method);
            String json=new Gson().toJson(call.arguments);
            intent.putExtra("share_action",call.method);
            intent.putExtra("share_content",json);
//            intent.setClipData(call.arguments);
            //说明：让导向的主activity重新创建，现象：分享中的网流和地圈界面中的购买功能处理一直搜索当地服务商状态。原因是：高德导航的api如果在shareactivity消毁后而导出同一个主activity接收，则定位失败
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intent);
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    public void sendShareCapture(String content) {
        channel.invokeMethod("shareCapture", content, new MethodChannel.Result() {
            @Override
            public void success(Object o) {
                // 这里就会输出 "Hello from Flutter"
                Log.i("--r-----", o + "");
            }

            @Override
            public void error(String s, String s1, Object o) {
                System.out.println("!!!" + s + "  " + s1 + " " + o);
            }

            @Override
            public void notImplemented() {
                System.out.println("------notImplemented");
            }
        });
    }

    public void sendShareEvent(String action, Map<String, Object> map) {
        channel.invokeMethod(action, map, new MethodChannel.Result() {
            @Override
            public void success(Object o) {
                // 这里就会输出 "Hello from Flutter"
                Log.i("--r-----", o + "");
            }

            @Override
            public void error(String s, String s1, Object o) {
                System.out.println("!!!" + s + "  " + s1 + " " + o);
            }

            @Override
            public void notImplemented() {
                System.out.println("------notImplemented");
            }
        });
    }
}
