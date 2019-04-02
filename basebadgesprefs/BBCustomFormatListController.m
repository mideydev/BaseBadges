#import "BBCustomFormatListController.h"

@implementation BBCustomFormatListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"BaseBadgesCustomFormatPrefs" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
