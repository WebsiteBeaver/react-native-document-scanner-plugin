#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(DocumentScanner, NSObject)

RCT_EXTERN_METHOD(scanDocument:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

@end