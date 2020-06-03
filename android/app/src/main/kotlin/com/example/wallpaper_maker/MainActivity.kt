package com.example.wallpaper_maker

import android.app.WallpaperManager
import android.graphics.BitmapFactory
import android.widget.Toast
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "example.wallpaper_maker/wallpaper";

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler(MethodChannel.MethodCallHandler { call, result ->
            if (call.method.equals("setAsWallpaper")) {
                result.success(setAsWallpaper(call.argument<String>("path")))
            }
        })
    }

    private fun setAsWallpaper(path: String?) {
        val wm = WallpaperManager.getInstance(this)
        try {
            var bitmap = BitmapFactory.decodeFile(path)
            wm.setBitmap(bitmap)
            Toast.makeText(this, "set success", Toast.LENGTH_LONG)
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }


}
