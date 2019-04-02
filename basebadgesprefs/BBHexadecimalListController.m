#import "BBHexadecimalListController.h"

@implementation BBHexadecimalListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"BaseBadgesHexadecimalPrefs" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
