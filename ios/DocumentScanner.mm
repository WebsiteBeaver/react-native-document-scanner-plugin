#import "DocumentScanner.h"
#import <VisionKit/VisionKit.h>

#import "react_native_document_scanner_plugin-Swift.h"

@implementation DocumentScanner
RCT_EXPORT_MODULE()

// Legacy bridge (old architecture): expose JS method name `scanDocument`
RCT_REMAP_METHOD(scanDocument,
                 scanDocumentBridge:(NSDictionary *)options
                 resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject)
{
  // Forward to Swift implementation
  [[[DocumentScannerImpl alloc] init] scanDocument:options resolve:resolve reject:reject];
}

- (void)scanDocument:(JS::NativeDocumentScanner::ScanDocumentOptions &)options
             resolve:(RCTPromiseResolveBlock)resolve
              reject:(RCTPromiseRejectBlock)reject
{
  NSMutableDictionary *dict = [NSMutableDictionary new];

  if (options.responseType() != nil) {
    dict[@"responseType"] = options.responseType();
  }
  if (options.croppedImageQuality().has_value()) {
    dict[@"croppedImageQuality"] = @(options.croppedImageQuality().value());
  }
  if (options.maxNumDocuments().has_value()) {
    dict[@"maxNumDocuments"] = @(options.maxNumDocuments().value());
  }

  [[[DocumentScannerImpl alloc] init] scanDocument:dict resolve:resolve reject:reject];
}


- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeDocumentScannerSpecJSI>(params);
}
@end