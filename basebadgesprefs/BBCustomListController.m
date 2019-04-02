#import "BBCustomListController.h"

@implementation BBCustomListController

- (id)init
{
	self = [super init];

	if (self)
	{
		_tweakBundle = [NSBundle bundleWithPath:@BB_TWEAK_BUNDLE];
		[self loadSettings];
	}

	return self;
}

- (void)loadSettings
{
	HBLogDebug(@"loadSettings:");

	_tweakSettings = ([NSMutableDictionary dictionaryWithContentsOfFile:@BB_PREFS_FILE] ?: [NSMutableDictionary dictionary]);

#ifdef DEBUG
	for (id key in _tweakSettings)
		HBLogDebug(@"loadSettings: key: %@  =>  value: %@", key, [_tweakSettings objectForKey:key]);
#endif
}

- (void)saveSettings
{
	HBLogDebug(@"saveSettings:");

	[_tweakSettings writeToFile:@BB_PREFS_FILE atomically:YES];

#ifdef DEBUG
	for (id key in _tweakSettings)
		HBLogDebug(@"saveSettings: key: %@  =>  value: %@", key, [_tweakSettings objectForKey:key]);
#endif
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
	NSString *key = [specifier propertyForKey:@"key"];

	[self loadSettings];

	[_tweakSettings setObject:value forKey:key];

	[self saveSettings];

	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(BB_RELOAD_PREFS_NOTIFICATION), NULL, NULL, TRUE);
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
	NSString *key = [specifier propertyForKey:@"key"];

	HBLogDebug(@"readPreferenceValue: key = %@", key);

	id defaultValue = [specifier propertyForKey:@"default"];
	HBLogDebug(@"readPreferenceValue: defaultValue = %@", defaultValue);

	id plistValue = [_tweakSettings objectForKey:key];
	HBLogDebug(@"readPreferenceValue: plistValue = %@", plistValue);

	if (!plistValue)
	{
		[_tweakSettings setObject:defaultValue forKey:key];
		[self saveSettings];
		plistValue = defaultValue;
	}

	return plistValue;
}

@end

// vim:ft=objc
