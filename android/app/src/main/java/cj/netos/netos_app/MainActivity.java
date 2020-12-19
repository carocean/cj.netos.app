package cj.netos.netos_app;

import android.content.Intent;

import androidx.annotation.NonNull;

import com.google.gson.Gson;

import java.util.HashMap;
import java.util.Map;

import cj.netos.accept_share.AcceptSharePlugin;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    Intent currentIntent;

    @Override
    public void onFlutterUiDisplayed() {
        super.onFlutterUiDisplayed();
        Intent intent = null;
        if (currentIntent != null) {
            intent = currentIntent;
            currentIntent = null;
        } else {
            intent = getIntent();
        }
        String action = intent.getStringExtra("share_action");
        if ((action != null && !"".equals(action)) && action.startsWith("forward")) {
            String json = intent.getStringExtra("share_content");
            Map<String, Object> map = new Gson().fromJson(json, HashMap.class);
            AcceptSharePlugin sharePlugin = (AcceptSharePlugin) getFlutterEngine().getPlugins().get(AcceptSharePlugin.class);
            sharePlugin.sendShareEvent(action, map);
        }
    }

    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        currentIntent = intent;
    }
}
