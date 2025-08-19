import Foundation
import UIKit
import React

#if RCT_NEW_ARCH_ENABLED
@objc
protocol DocumentScannerSpec: RCTBridgeModule {
  @objc
  func scanDocument(
    _ options: [AnyHashable: Any],
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  )
}
#endif

#if RCT_NEW_ARCH_ENABLED
extension DocumentScanner: DocumentScannerSpec {
  func scanDocument(
    _ options: [AnyHashable: Any],
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    scanInternal(
      options: options as? [String: Any] ?? [:],
      resolve: resolve,
      reject: reject
    )
  }
}
#endif

@objc(DocumentScanner)
class DocumentScanner: NSObject {
  private var docScanner: DocScanner?

  @objc static func moduleName() -> String! { "DocumentScanner" }
  @objc static func requiresMainQueueSetup() -> Bool { true }

  #if !RCT_NEW_ARCH_ENABLED
  // Old arch (Bridging). for .m file (RCT_EXTERN)
  @objc(scanDocument:resolve:reject:)
  func scanDocumentObjC(
    _ options: NSDictionary,
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    scanInternal(options: options as? [String: Any] ?? [:], resolve: resolve, reject: reject)
  }
  #endif

  private func scanInternal(
    options: [String: Any],
    resolve: @escaping RCTPromiseResolveBlock,
    reject: @escaping RCTPromiseRejectBlock
  ) {
    guard #available(iOS 13.0, *) else {
      reject("unsupported_ios", "iOS 13.0 or higher required", nil)
      return
    }

    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      self.docScanner = DocScanner()

      let responseType = options["responseType"] as? String
      let quality = options["croppedImageQuality"] as? Int

      self.docScanner?.startScan(
        RCTPresentedViewController(),
        successHandler: { images in
          resolve([
            "status": "success",
            "scannedImages": images
          ])
          self.docScanner = nil
        },
        errorHandler: { msg in
          reject("document_scan_error", msg, nil)
          self.docScanner = nil
        },
        cancelHandler: {
          resolve(["status": "cancel"])
          self.docScanner = nil
        },
        responseType: responseType,
        croppedImageQuality: quality
      )
    }
  }
}

