#import "BBScientificNotationListController.h"

@implementation BBScientificNotationListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"BaseBadgesScientificNotationPrefs" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
