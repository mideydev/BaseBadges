#import "BBRomanNumeralsListController.h"

@implementation BBRomanNumeralsListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"BaseBadgesRomanNumeralsPrefs" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
