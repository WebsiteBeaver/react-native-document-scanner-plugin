@available(iOS 13.0, *)
@objc(DocumentScanner)
class DocumentScanner: NSObject {

    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    /** @property  documentScanner the document scanner */
    private var documentScanner: DocScanner?

    @objc(scanDocument:withResolver:withRejecter:)
    func scanDocument(
      _ options: NSDictionary,
      resolve: @escaping RCTPromiseResolveBlock,
      reject: @escaping RCTPromiseRejectBlock
    ) -> Void {
        DispatchQueue.main.async {
            self.documentScanner = DocScanner()

            // launch the document scanner
            self.documentScanner?.startScan(
                RCTPresentedViewController(),
                successHandler: { (scannedDocumentImages: [String]) in
                    // document scan success
                    resolve([
                        "status": "success",
                        "scannedImages": scannedDocumentImages
                    ])
                    self.documentScanner = nil
                },
                errorHandler: { (errorMessage: String) in
                    // document scan error
                    reject("document scan error", errorMessage, nil)
                    self.documentScanner = nil
                },
                cancelHandler: {
                    // when user cancels document scan
                    resolve([
                        "status": "cancel"
                    ])
                    self.documentScanner = nil
                },
                responseType: options["responseType"] as? String,
                croppedImageQuality: options["croppedImageQuality"] as? Int
            )
        }
    }

}
