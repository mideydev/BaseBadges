#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "BBCustomListController.h"
#import "../BBPreferences.h"

#define BBLocalizedStringForKey(key) [self.tweakBundle localizedStringForKey:key value:@"" table:nil]

@interface BBCustomListController : PSListController
@property (nonatomic,retain,readonly) NSMutableDictionary *tweakSettings;
@property (nonatomic,retain,readonly) NSBundle *tweakBundle;
@end

// vim:ft=objc
