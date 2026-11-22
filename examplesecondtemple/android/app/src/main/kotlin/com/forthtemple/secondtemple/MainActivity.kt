package com.forthtemple.secondtemple
// this was added by claude so can close the game
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "secondtemple/restart")
            .setMethodCallHandler { call, result ->
                if (call.method == "restart") {
                    val intent = packageManager.getLaunchIntentForPackage(packageName)!!
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
                    startActivity(intent)
                    result.success(null)
                    Runtime.getRuntime().exit(0)
                } else {
                    result.notImplemented()
                }
            }
    }
}