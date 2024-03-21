import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-document-scanner-plugin' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

const DocumentScanner = NativeModules.DocumentScanner
  ? NativeModules.DocumentScanner
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export default {
  /**
   * Opens the camera, and starts the document scan
   */
  scanDocument(
    options: ScanDocumentOptions = {}
  ): Promise<ScanDocumentResponse> {
    return DocumentScanner.scanDocument(options);
  },
};

export interface ScanDocumentOptions {
  /**
   * The quality of the cropped image from 0 - 100. 100 is the best quality.
   * @default: 100
   */
  croppedImageQuality?: number;

  /**
   * Android only: The maximum number of photos an user can take (not counting photo retakes)
   * @default: undefined
   */
  maxNumDocuments?: number;

  /**
   * The response comes back in this format on success. It can be the document
   * scan image file paths or base64 images.
   * @default: ResponseType.ImageFilePath
   */
  responseType?: ResponseType;
}

export enum ResponseType {
  /**
   * Use this response type if you want document scan returned as base64 images.
   */
  Base64 = 'base64',

  /**
   * Use this response type if you want document scan returned as inmage file paths.
   */
  ImageFilePath = 'imageFilePath',
}

export interface ScanDocumentResponse {
  /**
   * This is an array with either file paths or base64 images for the
   * document scan.
   */
  scannedImages?: string[];

  /**
   * The status lets you know if the document scan completes successfully,
   * or if the user cancels before completing the document scan.
   */
  status?: ScanDocumentResponseStatus;
}

export enum ScanDocumentResponseStatus {
  /**
   * The status comes back as success if the document scan completes
   * successfully.
   */
  Success = 'success',

  /**
   * The status comes back as cancel if the user closes out of the camera
   * before completing the document scan.
   */
  Cancel = 'cancel',
}
