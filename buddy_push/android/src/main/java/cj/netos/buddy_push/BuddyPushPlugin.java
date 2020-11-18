package cj.netos.buddy_push;

import android.app.Application;
import android.content.Context;
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
        if (call.method.equals("currentPushDriver")) {//注意：onMethodCall方法必须以result返回，否则会导致flutter调用方堵塞
            try {
                Field field = context.getClass().getDeclaredField("__currentPusherDriver");//注意：必须避免对MicrogeoApplication类中的该属性名__currentPusherDriver的混淆
                field.setAccessible(true);
                Map<String, String> pushDriver = (Map<String, String>) field.get(context);
                result.success(pushDriver);
            } catch (NoSuchFieldException e) {
                result.error("404",e.getMessage(),e);
            } catch (IllegalAccessException e) {
                result.error("500",e.getMessage(),e);
            }
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}