package cj.netos.open_file;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import java.io.File;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * OpenFilePlugin
 */
public class OpenFilePlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Context context;

    public OpenFilePlugin() {
    }

    private OpenFilePlugin(Context context) {
        this.context = context;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "open_file");
        this.context = flutterPluginBinding.getApplicationContext();
        channel.setMethodCallHandler(this);
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "open_file");
        channel.setMethodCallHandler(new OpenFilePlugin(registrar.context()));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("installApk")) {
            String path = (String) call.arguments;
            Log.d("OpenFilePlugin", "install apk plugin :" + path);
            File file = new File(path);
//            Log.d("OpenFilePlugin", "-------" + context);
            installApk(file);
        } else {
            result.notImplemented();
        }
    }

    private void installApk(File apkFile) {
        Intent installApkIntent = new Intent();
        installApkIntent.setAction(Intent.ACTION_VIEW);
        installApkIntent.addCategory(Intent.CATEGORY_DEFAULT);
        installApkIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//        Log.d("OpenFilePlugin", "------1");
        Uri apkUri = null;
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.M) {
//            Log.d("OpenFilePlugin", "------2");
            apkUri = FileProvider.getUriForFile(context, context.getPackageName() + ".fileprovider", apkFile);
            installApkIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        } else {
//            Log.d("OpenFilePlugin", "------3");
            apkUri = Uri.fromFile(apkFile);
        }
//        Log.d("OpenFilePlugin", "------4");
        installApkIntent.setDataAndType(apkUri, "application/vnd.android.package-archive");
//        Log.d("OpenFilePlugin", "------5");
        if (context.getPackageManager().queryIntentActivities(installApkIntent, 0).size() > 0) {
//            Log.d("OpenFilePlugin", "------6");
            context.startActivity(installApkIntent);
        }
//        Log.d("OpenFilePlugin", "------7");
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
