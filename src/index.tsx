import DocumentScanner, {
  ResponseType,
  ScanDocumentResponseStatus,
  type ScanDocumentOptions,
  type ScanDocumentResponse,
} from './NativeDocumentScanner';

export function scanDocument(
  options: ScanDocumentOptions = {}
): Promise<ScanDocumentResponse> {
  if (!options.responseType) {
    options.responseType = ResponseType.ImageFilePath;
  }
  return DocumentScanner.scanDocument(options);
}

export { ResponseType, ScanDocumentResponseStatus };

export type { ScanDocumentOptions, ScanDocumentResponse };

export default {
  scanDocument,
};
