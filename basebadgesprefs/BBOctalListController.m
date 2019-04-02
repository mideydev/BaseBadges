#import "BBOctalListController.h"

@implementation BBOctalListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"BaseBadgesOctalPrefs" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
