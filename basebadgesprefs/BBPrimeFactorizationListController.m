#import "BBPrimeFactorizationListController.h"

@implementation BBPrimeFactorizationListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"BaseBadgesPrimeFactorizationPrefs" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
