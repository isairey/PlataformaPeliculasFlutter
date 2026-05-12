package com.example.moviesync

import android.app.PictureInPictureParams
import android.content.res.Configuration
import android.os.Build
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.moviesync/pip"
    private var isPipRequested = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enterPip" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            val aspectRatio = Rational(16, 9)
                            val params = PictureInPictureParams.Builder()
                                .setAspectRatio(aspectRatio)
                                .build()
                            isPipRequested = true
                            enterPictureInPictureMode(params)
                            result.success(true)
                        } else {
                            result.error("UNSUPPORTED", "PiP requires Android 8+", null)
                        }
                    }
                    "isPipSupported" -> {
                        result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, CHANNEL).invokeMethod(
                "pipChanged",
                isInPictureInPictureMode
            )
        }
    }
}
