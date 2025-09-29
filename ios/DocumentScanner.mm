#import <VisionKit/VisionKit.h>
#import "DocumentScanner.h"

#if __has_include(<DocumentScanner/DocumentScanner-Swift.h>)
#import <DocumentScanner/DocumentScanner-Swift.h>
#elif __has_include("DocumentScanner-Swift.h")
#import "DocumentScanner-Swift.h"
#else
#warning "DocumentScanner-Swift.h not found at build time"
#endif

@implementation DocumentScanner
RCT_EXPORT_MODULE()

- (void)scanDocument:(JS::NativeDocumentScanner::ScanDocumentOptions &)options
            resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject
{
  NSMutableDictionary *scanDocumentOptions = [NSMutableDictionary new];

  scanDocumentOptions[@"responseType"] = options.responseType();
  
  if (options.croppedImageQuality().has_value()) {
    scanDocumentOptions[@"croppedImageQuality"] = @(options.croppedImageQuality().value());
  }

  RNDocumentScanner *documentScanner = [RNDocumentScanner new];
  [documentScanner scanDocument:scanDocumentOptions resolve:resolve reject:reject];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeDocumentScannerSpecJSI>(params);
}

@end
