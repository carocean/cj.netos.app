package cj.netos.netos_app;

import android.content.ClipData;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.ArrayList;

import cj.netos.accept_share.AcceptSharePlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener;

public class AcceptShareActivity extends FlutterActivity {
    FlutterUiDisplayListener flutterUiDisplayListener;

    @NonNull
    @Override
    public String getInitialRoute() {
        return "/system/share/main";
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (flutterUiDisplayListener != null) {
            getFlutterEngine().getRenderer().removeIsDisplayingFlutterUiListener(flutterUiDisplayListener);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //判断界面是否显示完onFlutterUiDisplayed，因为flutter界面的initState方法执行在activity.onCreate之后。所以在界面执行完后再发送事件给flutter
        flutterUiDisplayListener = new FlutterUiDisplayListener() {
            @Override
            public void onFlutterUiDisplayed() {
                Log.i("'--------'", "onFlutterUiDisplayed");
                _send();
            }

            @Override
            public void onFlutterUiNoLongerDisplayed() {
                Log.i("'--------'", "onFlutterUiNoLongerDisplayed");
            }
        };
        getFlutterEngine().getRenderer().addIsDisplayingFlutterUiListener(flutterUiDisplayListener);

//下面是flutter的原生跳转
        //        Intent indent =new Intent(this,MainActivity2.class);
//        Intent indent = MainActivity2
//                .withNewEngine()
//                .initialRoute("one_page")
//                .build(this);
//        startActivity(
//                indent
//        );
    }

    private void _send() {
        Intent intent = getIntent();
        String action = intent.getAction();
        String type = intent.getType();
        AcceptSharePlugin testPlugin = (AcceptSharePlugin) getFlutterEngine().getPlugins().get(AcceptSharePlugin.class);
        if (Intent.ACTION_SEND.equals(action) && type != null) {
//            Uri uri = intent.getParcelableExtra(Intent.EXTRA_STREAM);

            if ("audio/".equals(type)) {
                // 处理发送来音频
//                ToastUtils.showToast(getContext(),"");
            } else if (type.startsWith("video/")) {
                // 处理发送来的视频
            } else if (type.startsWith("text/plain")) {
                //处理浏览器分享
                ClipData clipData = intent.getClipData();
                if (clipData != null) {
                    for (int i = 0; i < clipData.getItemCount(); i++) {
                        ClipData.Item item = clipData.getItemAt(i);
                        CharSequence sequence = item.getText();
                        testPlugin.sendShare(sequence == null ? null : sequence.toString());
                    }
                }
            } else if (type.startsWith("*/")) {
                //处理发送过来的其他文件
            } else if (type.startsWith("image/")) {
                //处理发送过来的其他文件
            }
        } else if (Intent.ACTION_SEND_MULTIPLE.equals(action) && type != null) {
            ArrayList<Uri> arrayList = intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM);
            if ("audio/".equals(type)) {
                // 处理发送来音频
//                ToastUtils.showToast(getContext(),"");
            } else if (type.startsWith("video/")) {
                // 处理发送来的视频
            } else if (type.startsWith("text/plain")) {
                //处理发送过来的其他文件
            } else if (type.startsWith("*/")) {
                //处理发送过来的其他文件
            } else if (type.startsWith("image/")) {
                //处理发送过来的其他文件
            }
        }
    }
}
