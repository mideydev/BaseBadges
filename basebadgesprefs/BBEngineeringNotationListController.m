#import "BBEngineeringNotationListController.h"

@implementation BBEngineeringNotationListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"BaseBadgesEngineeringNotationPrefs" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
