#import "BBRandomListController.h"

@implementation BBRandomListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"BaseBadgesRandomPrefs" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
