package com.example.vibi

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
	private val instagramPackage = "com.instagram.android"
	private val channelName = "vibi/instagram_story"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			channelName,
		).setMethodCallHandler { call, result ->
			when (call.method) {
				"shareStickerToStory" -> shareStickerToStory(call, result)
				else -> result.notImplemented()
			}
		}
	}

	private fun shareStickerToStory(call: MethodCall, result: MethodChannel.Result) {
		val backgroundPath = call.argument<String>("backgroundImagePath")
		val stickerPath = call.argument<String>("stickerImagePath")
		val attributionUrl = call.argument<String>("attributionUrl")
		val topColor = call.argument<String>("topBackgroundColor") ?: "#121212"
		val bottomColor = call.argument<String>("bottomBackgroundColor") ?: "#1E1E1E"

		if (backgroundPath.isNullOrBlank() || stickerPath.isNullOrBlank()) {
			result.error("INVALID_ARGS", "Missing image path arguments.", null)
			return
		}

		val backgroundFile = File(backgroundPath)
		val stickerFile = File(stickerPath)

		if (!backgroundFile.exists() || !stickerFile.exists()) {
			result.error("FILE_NOT_FOUND", "Story assets not found.", null)
			return
		}

		val authority = "${applicationContext.packageName}.fileprovider"
		val backgroundUri = FileProvider.getUriForFile(this, authority, backgroundFile)
		val stickerUri = FileProvider.getUriForFile(this, authority, stickerFile)

		val intent = Intent("com.instagram.share.ADD_TO_STORY").apply {
			setDataAndType(backgroundUri, "image/png")
			setPackage(instagramPackage)
			addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
			putExtra("interactive_asset_uri", stickerUri)
			putExtra("top_background_color", topColor)
			putExtra("bottom_background_color", bottomColor)
			if (!attributionUrl.isNullOrBlank()) {
				putExtra("content_url", attributionUrl)
			}
		}

		grantUriPermission(
			instagramPackage,
			backgroundUri,
			Intent.FLAG_GRANT_READ_URI_PERMISSION,
		)
		grantUriPermission(
			instagramPackage,
			stickerUri,
			Intent.FLAG_GRANT_READ_URI_PERMISSION,
		)

		if (intent.resolveActivity(packageManager) != null) {
			startActivity(intent)
			result.success(true)
		} else {
			result.success(false)
		}
	}
}
