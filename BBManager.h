@interface BBManager : NSObject
+ (instancetype)sharedInstance;
- (id)convertBadgeNumberOrString:(id)badgeNumberOrString;
- (void)refreshBadges;
@end

// vim:ft=objc
