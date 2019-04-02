#define SYSTEM_VERSION_EQUAL_TO(v)					([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)				([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)	([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)					([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)		([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

// springboard stuff

@interface SBIcon : NSObject
- (id)badgeNumberOrString;
- (void)setBadge:(id)arg1;
@end

@interface SBLeafIcon : SBIcon
- (id)applicationBundleID;
@end

@interface SBFolderIcon : SBIcon
-(id)folder;
@end

@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
@end

@interface SBIconModel : NSObject
- (id)leafIcons;
@end

@interface SBIconController : UIViewController
+ (id)sharedInstance;
- (id)model;
@end

// vim:ft=objc
