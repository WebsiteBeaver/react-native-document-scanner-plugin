import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

/**
 * Options for document scanning.
 */
export interface ScanDocumentOptions {
  /**
   * The quality of the cropped image from 0 - 100. 100 is the best quality.
   * @default 100
   */
  croppedImageQuality?: number;

  /**
   * Android only: The maximum number of photos a user can take (not counting retakes).
   * @default undefined (no limit enforced by module)
   */
  maxNumDocuments?: number;

  /**
   * The response format on success. Either file paths or base64 images.
   * @default ResponseType.ImageFilePath
   */
  responseType?: ResponseType;
}

/**
 * Response type for scanned images.
 */
export enum ResponseType {
  /**
   * Return scanned images as base64 strings.
   */
  Base64 = 'base64',

  /**
   * Return scanned images as image file paths.
   */
  ImageFilePath = 'imageFilePath',
}

/**
 * Scan result payload.
 */
export interface ScanDocumentResponse {
  /**
   * Array of scanned images (file paths or base64 strings depending on responseType).
   */
  scannedImages?: string[];

  /**
   * The final status of the scan flow.
   */
  status?: ScanDocumentResponseStatus;
}

/**
 * Status of the scan flow.
 */
export enum ScanDocumentResponseStatus {
  /**
   * Scan completed successfully.
   */
  Success = 'success',

  /**
   * User canceled the scan.
   */
  Cancel = 'cancel',
}

/**
 * TurboModule spec.
 */
export interface Spec extends TurboModule {
  /**
   * Opens the camera UI and starts document scanning.
   * @param options Scan options.
   * @returns Promise with scan result.
   */
  scanDocument(options: ScanDocumentOptions): Promise<ScanDocumentResponse>;
}

const DocumentScanner =
  TurboModuleRegistry.getEnforcing<Spec>('DocumentScanner');

export default DocumentScanner;
