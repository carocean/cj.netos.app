#import "AcceptSharePlugin.h"
#if __has_include(<accept_share/accept_share-Swift.h>)
#import <accept_share/accept_share-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "accept_share-Swift.h"
#endif

@implementation AcceptSharePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAcceptSharePlugin registerWithRegistrar:registrar];
}
@end
