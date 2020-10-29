#import "OpenFilePlugin.h"
#if __has_include(<open_file/open_file-Swift.h>)
#import <open_file/open_file-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "open_file-Swift.h"
#endif

@implementation OpenFilePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftOpenFilePlugin registerWithRegistrar:registrar];
}
@end
