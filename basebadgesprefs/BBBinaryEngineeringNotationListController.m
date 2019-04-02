#import "BBBinaryEngineeringNotationListController.h"

@implementation BBBinaryEngineeringNotationListController

- (NSArray *)specifiers
{
	if (!_specifiers)
	{
		_specifiers = [self loadSpecifiersFromPlistName:@"BaseBadgesBinaryEngineeringNotationPrefs" target:self];
	}

	return _specifiers;
}

@end

// vim:ft=objc
