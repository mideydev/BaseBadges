#import "BBDecimalListController.h"

@implementation BBDecimalListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"BaseBadgesDecimalPrefs" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
