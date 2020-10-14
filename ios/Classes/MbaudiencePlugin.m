#import "MbaudiencePlugin.h"
#if __has_include(<mbaudience/mbaudience-Swift.h>)
#import <mbaudience/mbaudience-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "mbaudience-Swift.h"
#endif

@implementation MbaudiencePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMbaudiencePlugin registerWithRegistrar:registrar];
}
@end
