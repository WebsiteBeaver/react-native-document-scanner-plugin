#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(DocumentScanner, NSObject)

RCT_EXTERN_METHOD(scanDocument:(NSDictionary *)options
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

@end
