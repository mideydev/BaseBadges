#import "BBUnaryListController.h"

@implementation BBUnaryListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"BaseBadgesUnaryPrefs" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
