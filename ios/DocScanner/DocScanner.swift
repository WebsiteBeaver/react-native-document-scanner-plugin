import UIKit
import VisionKit

/**
 This class uses VisonKit to start a document scan. It either returns the cropped images in base64 or as file paths
 depending on the configuration.
 */
@available(iOS 13.0, *)
public class DocScanner: NSObject, VNDocumentCameraViewControllerDelegate {
    
    /** @property  viewController the document scanner gets called from this view controller */
    private var viewController: UIViewController?
    
    /** @property  successHandler a callback triggered when the user completes the document scan successfully */
    private var successHandler: ([String]) -> Void
    
    /** @property  errorHandler a callback triggered when there's an error */
    private var errorHandler: (String) -> Void
    
    /** @property  cancelHandler a callback triggered when the user cancels the document scan */
    private var cancelHandler: () -> Void
    
    /** @property  responseType determines the format response (base64 or file paths) */
    private var responseType: String

    /** @property  croppedImageQuality the 0 - 100 quality of the cropped image */
    private var croppedImageQuality: Int
    
    /**
     constructor for DocScanner

     @param     viewController      the ViewController that starts the document scan
     @param     successHandler      a callback triggered when the user completes the document scan successfully
     @param     errorHandler        a callback triggered when there's an error
     @param     cancelHandler       a callback triggered when the user cancels the document scan
     @param     responseType        determines the format response (base64 or file paths)
     @param     croppedImageQuality the 0 - 100 quality of the cropped image
     
     @return    Returns a DocScanner
     */
    public init(
        _ viewController: UIViewController? = nil,
        successHandler: @escaping ([String]) -> Void = {_ in },
        errorHandler: @escaping (String) -> Void = {_ in },
        cancelHandler: @escaping () -> Void = {},
        responseType: String = ResponseType.imageFilePath,
        croppedImageQuality: Int = 100
    ) {
        self.viewController = viewController
        self.successHandler = successHandler
        self.errorHandler = errorHandler
        self.cancelHandler = cancelHandler
        self.responseType = responseType
        self.croppedImageQuality = croppedImageQuality
    }
    
    /**
     constructor for DocScanner
     
     @return    Returns a DocScanner
     */
    public convenience override init() {
        self.init(nil)
    }
    
    /**
     opens the camera, and starts the document scan
     */
    public func startScan() {
        // make sure device has the ability to scan documents
        if (!VNDocumentCameraViewController.isSupported) {
            self.errorHandler("Document scanning is not supported on this device")
            return
        }
        
        DispatchQueue.main.async {
            // launch the document scanner
            let documentCameraViewController = VNDocumentCameraViewController()

            let photoFilterOption = VNDocumentCameraViewOption(rawValue: 2 << 0) 
            documentCameraViewController.preferredFilters = [photoFilterOption]
            
            documentCameraViewController.delegate = self
            self.viewController?.present(documentCameraViewController, animated: true)
        }
    }
    
    /**
     opens the camera, and starts the document scan

     @param     viewController      the ViewController that starts the document scan
     @param     successHandler      a callback triggered when the user completes the document scan successfully
     @param     errorHandler        a callback triggered when there's an error
     @param     cancelHandler       a callback triggered when the user cancels the document scan
     @param     responseType        determines the format response (base64 or file paths)
     @param     croppedImageQuality the 0 - 100 quality of the cropped image
     */
    public func startScan(
        _ viewController: UIViewController? = nil,
        successHandler: @escaping ([String]) -> Void = {_ in },
        errorHandler: @escaping (String) -> Void = {_ in },
        cancelHandler: @escaping () -> Void = {},
        responseType: String? = ResponseType.imageFilePath,
        croppedImageQuality: Int? = 100
    ) {
        self.viewController = viewController
        self.successHandler = successHandler
        self.errorHandler = errorHandler
        self.cancelHandler = cancelHandler
        self.responseType = responseType ?? ResponseType.imageFilePath
        self.croppedImageQuality = croppedImageQuality ?? 100
        
        self.startScan()
    }
    
    /**
     This gets called on document scan success. Either return an array with cropped images in base64 format, or save the cropped
     images and return an array with image file paths
     
     @param controller  the ViewController that starts the document scan
     @param scan        contains details like number of pages scanned and UIImages for all scanned pages
     */
    public func documentCameraViewController(
        _ controller: VNDocumentCameraViewController,
        didFinishWith scan: VNDocumentCameraScan
    ) {
        var results: [String] = []
        
        // loop through all scanned pages
        for pageNumber in 0...scan.pageCount - 1 {
            
            // convert scan UIImage to jpeg data
            guard let scannedDocumentImage: Data = scan
                .imageOfPage(at: pageNumber)
                .jpegData(compressionQuality: CGFloat(self.croppedImageQuality) / CGFloat(100)) else {
                goBackToPreviousView(controller)
                self.errorHandler("Unable to get scanned document in jpeg format")
                return
            }
            
            switch responseType {
                case ResponseType.base64:
                    // convert scan jpeg data to base64
                    let base64EncodedImage: String = scannedDocumentImage.base64EncodedString()
                    results.append(base64EncodedImage)
                case ResponseType.imageFilePath:
                    do {
                        // save scan jpeg
                        let croppedImageFilePath = FileUtil().createImageFile(pageNumber)
                        try scannedDocumentImage.write(to: croppedImageFilePath)
                        
                        // store image file path
                        results.append(croppedImageFilePath.absoluteString)
                    } catch {
                        goBackToPreviousView(controller)
                        self.errorHandler("Unable to save scanned image: \(error.localizedDescription)")
                        return
                    }
                default:
                    self.errorHandler(
                        "responseType must be \(ResponseType.base64) or \(ResponseType.imageFilePath)"
                    )
            }
            
        }
        
        // exit document scanner
        goBackToPreviousView(controller)
        
        // return scanned document results
        self.successHandler(results)
    }
    
    /**
     This gets called if the user cancels the document scan
     
     @param controller  the ViewController that starts the document scan
     */
    public func documentCameraViewControllerDidCancel(
        _ controller: VNDocumentCameraViewController
    ) {
        // exit document scanner
        goBackToPreviousView(controller)
        self.cancelHandler()
    }

    /**
     This gets called if there's an error during the document scan
     
     @param controller      the ViewController that starts the document scan
     @param error           the error
     */
    public func documentCameraViewController(
        _ controller: VNDocumentCameraViewController,
        didFailWithError error: Error
    ) {
        // exit document scanner
        goBackToPreviousView(controller)
        
        // return the error message
        self.errorHandler(error.localizedDescription)
    }
    
    /**
     returns the user back to the ViewController that starts the document scan
     
     @param controller      the ViewController that starts the document scan
     */
    private func goBackToPreviousView(_ controller: VNDocumentCameraViewController) {
        DispatchQueue.main.async {
            controller.dismiss(animated: true)
        }
    }
}
