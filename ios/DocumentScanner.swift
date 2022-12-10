@available(iOS 13.0, *)
@objc(DocumentScanner)
class DocumentScanner: NSObject {

    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    /** @property  documentScanner the document scanner */
    let documentScanner = DocScanner()

    @objc(scanDocument:withResolver:withRejecter:)
    func scanDocument(
      _ options: NSDictionary,
      resolve: @escaping RCTPromiseResolveBlock,
      reject: @escaping RCTPromiseRejectBlock
    ) -> Void {
        DispatchQueue.main.async {
            // launch the document scanner
            self.documentScanner.startScan(
                RCTPresentedViewController(),
                successHandler: { (scannedDocumentImages: [String]) in
                    // document scan success
                    resolve([
                        "status": "success",
                        "scannedImages": scannedDocumentImages
                    ])
                },
                errorHandler: { (errorMessage: String) in
                    // document scan error
                    reject("document scan error", errorMessage, nil)
                },
                cancelHandler: {
                    // when user cancels document scan
                    resolve([
                        "status": "cancel"
                    ])
                },
                responseType: options["responseType"] as? String,
                croppedImageQuality: options["croppedImageQuality"] as? Int
            )
        }
    }

}
