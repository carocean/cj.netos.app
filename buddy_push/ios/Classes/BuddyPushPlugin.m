#import "BuddyPushPlugin.h"
#if __has_include(<buddy_push/buddy_push-Swift.h>)
#import <buddy_push/buddy_push-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "buddy_push-Swift.h"
#endif

@implementation BuddyPushPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBuddyPushPlugin registerWithRegistrar:registrar];
}
@end
