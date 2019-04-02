#import "BBBinaryListController.h"

@implementation BBBinaryListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"BaseBadgesBinaryPrefs" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
