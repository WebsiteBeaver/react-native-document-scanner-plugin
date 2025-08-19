package com.reactnativedocumentscanner

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Base64
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.IntentSenderRequest
import androidx.activity.result.contract.ActivityResultContracts
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap
import com.facebook.react.module.annotations.ReactModule
import com.google.mlkit.vision.documentscanner.GmsDocumentScanner
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions
import com.google.mlkit.vision.documentscanner.GmsDocumentScanning
import com.google.mlkit.vision.documentscanner.GmsDocumentScanningResult
import java.io.ByteArrayOutputStream
import java.io.FileNotFoundException

@ReactModule(name = DocumentScannerModule.NAME)
class DocumentScannerModule(reactContext: ReactApplicationContext) :
  NativeDocumentScannerSpec(reactContext) {

  companion object {
    const val NAME = "DocumentScanner"
  }

  override fun getName(): String = NAME

  private var launcher: ActivityResultLauncher<IntentSenderRequest>? = null
  private var pendingPromise: Promise? = null
  private var pendingOptions: ReadableMap? = null
  private var pendingQuality: Int = 100
  private var scanner: GmsDocumentScanner? = null

  override fun scanDocument(options: ReadableMap, promise: Promise) {
    val activity = currentActivity
    if (activity == null) {
      promise.reject("no_activity", "Activity not available")
      return
    }
    val componentActivity = activity as? ComponentActivity
    if (componentActivity == null) {
      promise.reject("invalid_activity", "Activity is not a ComponentActivity")
      return
    }
    if (pendingPromise != null) {
      promise.reject("scan_in_progress", "Scan already in progress")
      return
    }

    pendingPromise = promise
    pendingOptions = options
    pendingQuality = if (options.hasKey("croppedImageQuality")) options.getInt("croppedImageQuality") else 100

    initLauncher(componentActivity)
    initScanner(options)

    startScan(activity)
  }

  private fun initScanner(options: ReadableMap) {
    val builder = GmsDocumentScannerOptions.Builder()
      .setResultFormats(GmsDocumentScannerOptions.RESULT_FORMAT_JPEG)
      .setScannerMode(GmsDocumentScannerOptions.SCANNER_MODE_FULL)

    if (options.hasKey("maxNumDocuments")) {
      builder.setPageLimit(options.getInt("maxNumDocuments"))
    }
    scanner = GmsDocumentScanning.getClient(builder.build())
  }

  private fun initLauncher(activity: ComponentActivity) {
    if (launcher != null) return
    launcher = activity.activityResultRegistry.register(
      "document-scanner",
      ActivityResultContracts.StartIntentSenderForResult()
    ) { result ->
      val promise = pendingPromise ?: return@register
      val options = pendingOptions
      val response = WritableNativeMap()

      if (result.resultCode == Activity.RESULT_OK) {
        val docResult = GmsDocumentScanningResult.fromActivityResultIntent(result.data)
        val arr = WritableNativeArray()

        docResult?.pages?.forEach { page ->
          val uri = page.imageUri
          val value = if (
            options?.hasKey("responseType") == true &&
            options.getString("responseType") == "base64"
          ) {
            try {
              uriToBase64(activity, uri, pendingQuality)
            } catch (e: FileNotFoundException) {
              promise.reject("document_scan_error", e.message)
              clearPending()
              return@register
            }
          } else {
            uri.toString()
          }
          arr.pushString(value)
        }

        response.putArray("scannedImages", arr)
        response.putString("status", "success")
        promise.resolve(response)
      } else if (result.resultCode == Activity.RESULT_CANCELED) {
        response.putString("status", "cancel")
        promise.resolve(response)
      }

      clearPending()
    }
  }

  private fun startScan(activity: Activity) {
    val currentScanner = scanner
    if (currentScanner == null) {
      pendingPromise?.reject("scanner_init_error", "Scanner not initialized")
      clearPending()
      return
    }

    currentScanner.getStartScanIntent(activity)
      .addOnSuccessListener { intentSender ->
        launcher?.launch(IntentSenderRequest.Builder(intentSender).build())
          ?: run {
            pendingPromise?.reject("launcher_error", "Launcher not available")
            clearPending()
          }
      }
      .addOnFailureListener { e ->
        pendingPromise?.reject("document_scan_error", e.message)
        clearPending()
      }
  }

  @Throws(FileNotFoundException::class)
  private fun uriToBase64(activity: Activity, uri: Uri, quality: Int): String {
    val bmp = activity.contentResolver.openInputStream(uri).use { input ->
      BitmapFactory.decodeStream(input)
    }
    val baos = ByteArrayOutputStream()
    bmp.compress(Bitmap.CompressFormat.JPEG, quality, baos)
    return Base64.encodeToString(baos.toByteArray(), Base64.DEFAULT)
  }

  private fun clearPending() {
    pendingPromise = null
    pendingOptions = null
    pendingQuality = 100
  }
}