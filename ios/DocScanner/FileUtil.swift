import UIKit

/**
 This class contains utility functions for processing files
 */
public class FileUtil {
    public init() {
        
    }
    
    /**
     create a file path meant for saving document scan image
     
     @param pageNumber  the document page number
     
     @return the file path url
     */
    public func createImageFile(_ pageNumber: Int) -> URL {
        // create a file path with page number and date time to avoid
        // repeating file names
        return FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent(
            "DOCUMENT_SCAN_\(pageNumber)_\(getCurrentDateTime()).jpg"
        )
    }
    
    /**
     get current date and time
     
     @return current date and time
     */
    private func getCurrentDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        return dateFormatter.string(from: Date())
    }
    
    /**
     get file path url from file path string
     
     @param imageFilePath   the image file path string
     
     @return the file path url
     */
    private func getImageUrl(_ imageFilePath: String) throws -> URL {
        guard let imageUrl: URL = NSURL(string: imageFilePath) as URL? else {
            throw RuntimeError.message("Unable to get image from file")
        }
        return imageUrl
    }
    
    /**
     get image in base64
     
     @param imageFilePath   the image file path
     
     @return the image in base64
     */
    public func getBase64Image(imageFilePath: String) throws -> String {
        guard let imageData: Data = NSData(contentsOf: try getImageUrl(imageFilePath)) as Data? else {
            throw RuntimeError.message("Unable to get image from file")
        }
        return imageData.base64EncodedString()
    }
    
    /**
     delete image
     
     @param imageFilePath   the image file path to delete
     */
    public func deleteImage(imageFilePath: String) throws {
        try FileManager.default.removeItem(at: getImageUrl(imageFilePath))
    }
}
