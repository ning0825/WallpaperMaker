package com.tanhuan.wallpaper_maker

import android.app.WallpaperManager
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import com.avos.avoscloud.feedback.FeedbackAgent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "tanhuan.wallpaper_maker/wallpaper"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler(MethodChannel.MethodCallHandler { call, result ->
            if (call.method == "setAsWallpaper") {
                result.success(setAsWallpaper(call.argument<String>("path")))
            }
            if (call.method == "refreshMedia") {
                result.success(call.argument<String>("path")?.let { refreshMedia(it) })
            }
        })
    }

    override fun onResume() {
        super.onResume()
        Log.e("TAG", "onResume: " );
    }

    private fun setAsWallpaper(path: String?): Boolean {
       // set wallpaper directly without prompt.
        // val wm = WallpaperManager.getInstance(this)
        // try {
        //     var bitmap = BitmapFactory.decodeFile(path)
        //     wm.setBitmap(bitmap)
        //     Toast.makeText(this, "set success", Toast.LENGTH_LONG)
        // } catch (e: IOException) {
        //     e.printStackTrace()
        // }

        // Prompt user to select a wallpaper, then crop and set wallpaper.
//        var chooseIntent = Intent(Intent.ACTION_SET_WALLPAPER);
//
//        var intent = Intent(Intent.ACTION_CHOOSER);
//        intent.putExtra(Intent.EXTRA_INTENT, chooseIntent);
//        intent.putExtra(Intent.EXTRA_TITLE, "选择壁纸");
//        startActivity(intent);

        // pass image to system wallpaper setter
        var uri = FileProvider.getUriForFile(context.applicationContext, "com.tanhuan.wallpaper_maker.fileprovider", File(path))
        var intent = WallpaperManager.getInstance(this).getCropAndSetWallpaperIntent(uri)
        startActivity(intent)
        return true
    }

    private fun refreshMedia(path: String): Boolean {
        var intent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
        var uri = Uri.fromFile(File(path))
        intent.setData(uri)
        sendBroadcast(intent)
        return true
    }
}
