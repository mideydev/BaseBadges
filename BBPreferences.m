#import "BBPreferences.h"
#import "BBManager.h"

@implementation BBPreferences

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	[[BBPreferences sharedInstance] refreshSettings];
	[[BBPreferences sharedInstance] loadSettings];

	[[BBManager sharedInstance] refreshBadges];
}

- (BBPreferences *)init
{
	self = [super init];

	if (self)
	{
	}

	return self;
}

/*
- (void)dealloc
{
	if (settings)
		[settings release];

	[super dealloc];
}
*/

+ (BBPreferences *)sharedInstance
{
	static BBPreferences *sharedInstance = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[BBPreferences alloc] init];
		// Do any other initialisation stuff here

		[sharedInstance loadInitialSettings];

		CFNotificationCenterAddObserver(
			CFNotificationCenterGetDarwinNotifyCenter(),
			NULL,
			settingsChanged,
			CFSTR(BB_RELOAD_PREFS_NOTIFICATION),
			NULL,
			CFNotificationSuspensionBehaviorCoalesce
		);
	});

	return sharedInstance;
}

- (void)logSettings
{
	HBLogDebug(@"[logSettings] ----------------------------------------------");
	HBLogDebug(@"[logSettings] self.tweakEnabled                            = %@", self.tweakEnabled ? @"YES" : @"NO");
	HBLogDebug(@"[logSettings] self.conversionType                          = %ld", (long)self.conversionType);
	HBLogDebug(@"[logSettings] self.formatTypeCustomFormatString            = [%@]", self.formatTypeCustomFormatString);
	HBLogDebug(@"[logSettings] self.formatTypeUnary                         = %ld", (long)self.formatTypeUnary);
	HBLogDebug(@"[logSettings] self.formatTypeBinary                        = %ld", (long)self.formatTypeBinary);
	HBLogDebug(@"[logSettings] self.formatTypeOctal                         = %ld", (long)self.formatTypeOctal);
	HBLogDebug(@"[logSettings] self.formatTypeDecimal                       = %ld", (long)self.formatTypeDecimal);
	HBLogDebug(@"[logSettings] self.formatTypeHexadecimal                   = %ld", (long)self.formatTypeHexadecimal);
	HBLogDebug(@"[logSettings] self.formatTypeRomanNumerals                 = %ld", (long)self.formatTypeRomanNumerals);
	HBLogDebug(@"[logSettings] self.formatTypePrimeFactorization            = %ld", (long)self.formatTypePrimeFactorization);
	HBLogDebug(@"[logSettings] self.formatTypeScientificNotation            = %ld", (long)self.formatTypeScientificNotation);
	HBLogDebug(@"[logSettings] self.formatTypeEngineeringNotation           = %ld", (long)self.formatTypeEngineeringNotation);
	HBLogDebug(@"[logSettings] self.formatTypeBinaryEngineeringNotation     = %ld", (long)self.formatTypeBinaryEngineeringNotation);
	HBLogDebug(@"[logSettings] self.useLowercaseHexadecimalCharacters       = %@", self.useLowercaseHexadecimalCharacters ? @"YES" : @"NO");
	HBLogDebug(@"[logSettings] self.randomIncludesCustomFormat              = %@", self.randomIncludesCustomFormat ? @"YES" : @"NO");
	HBLogDebug(@"[logSettings] self.randomIncludesUnary                     = %@", self.randomIncludesUnary ? @"YES" : @"NO");
	HBLogDebug(@"[logSettings] self.randomIncludesBinary                    = %@", self.randomIncludesBinary ? @"YES" : @"NO");
	HBLogDebug(@"[logSettings] self.randomIncludesOctal                     = %@", self.randomIncludesOctal ? @"YES" : @"NO");
	HBLogDebug(@"[logSettings] self.randomIncludesDecimal                   = %@", self.randomIncludesDecimal ? @"YES" : @"NO");
	HBLogDebug(@"[logSettings] self.randomIncludesHexadecimal               = %@", self.randomIncludesHexadecimal ? @"YES" : @"NO");
	HBLogDebug(@"[logSettings] self.randomIncludesRomanNumerals             = %@", self.randomIncludesRomanNumerals ? @"YES" : @"NO");
	HBLogDebug(@"[logSettings] self.randomIncludesPrimeFactorization        = %@", self.randomIncludesPrimeFactorization ? @"YES" : @"NO");
	HBLogDebug(@"[logSettings] self.randomIncludesScientificNotation        = %@", self.randomIncludesScientificNotation ? @"YES" : @"NO");
	HBLogDebug(@"[logSettings] self.randomIncludesEngineeringNotation       = %@", self.randomIncludesEngineeringNotation ? @"YES" : @"NO");
	HBLogDebug(@"[logSettings] self.randomIncludesBinaryEngineeringNotation = %@", self.randomIncludesBinaryEngineeringNotation ? @"YES" : @"NO");
}

- (void)loadInitialSettings
{
	self.tweakEnabled = BB_DEFAULT_TWEAK_ENABLED;
	self.conversionType = BB_DEFAULT_CONVERSION_TYPE;
	self.formatTypeCustomFormatString = BB_DEFAULT_FORMAT_TYPE_CUSTOM_FORMAT_STRING;
	self.formatTypeUnary = BB_DEFAULT_FORMAT_TYPE_UNARY;
	self.formatTypeBinary = BB_DEFAULT_FORMAT_TYPE_BINARY;
	self.formatTypeOctal = BB_DEFAULT_FORMAT_TYPE_OCTAL;
	self.formatTypeDecimal = BB_DEFAULT_FORMAT_TYPE_DECIMAL;
	self.formatTypeHexadecimal = BB_DEFAULT_FORMAT_TYPE_HEXADECIMAL;
	self.formatTypeRomanNumerals = BB_DEFAULT_FORMAT_TYPE_ROMAN_NUMERALS;
	self.formatTypePrimeFactorization = BB_DEFAULT_FORMAT_TYPE_PRIME_FACTORIZATION;
	self.formatTypeScientificNotation = BB_DEFAULT_FORMAT_TYPE_SCIENTIFIC_NOTATION;
	self.formatTypeEngineeringNotation = BB_DEFAULT_FORMAT_TYPE_ENGINEERING_NOTATION;
	self.formatTypeBinaryEngineeringNotation = BB_DEFAULT_FORMAT_TYPE_BINARY_ENGINEERING_NOTATION;
	self.useLowercaseHexadecimalCharacters = BB_DEFAULT_USE_LOWERCASE_HEXADECIMAL_CHARACTERS;
	self.randomIncludesCustomFormat = BB_DEFAULT_RANDOM_INCLUDES_CUSTOM_FORMAT;
	self.randomIncludesUnary = BB_DEFAULT_RANDOM_INCLUDES_UNARY;
	self.randomIncludesBinary = BB_DEFAULT_RANDOM_INCLUDES_BINARY;
	self.randomIncludesOctal = BB_DEFAULT_RANDOM_INCLUDES_OCTAL;
	self.randomIncludesDecimal = BB_DEFAULT_RANDOM_INCLUDES_DECIMAL;
	self.randomIncludesHexadecimal = BB_DEFAULT_RANDOM_INCLUDES_HEXADECIMAL;
	self.randomIncludesRomanNumerals = BB_DEFAULT_RANDOM_INCLUDES_ROMAN_NUMERALS;
	self.randomIncludesPrimeFactorization = BB_DEFAULT_RANDOM_INCLUDES_PRIME_FACTORIZATION;
	self.randomIncludesScientificNotation = BB_DEFAULT_RANDOM_INCLUDES_SCIENTIFIC_NOTATION;
	self.randomIncludesEngineeringNotation = BB_DEFAULT_RANDOM_INCLUDES_ENGINEERING_NOTATION;
	self.randomIncludesBinaryEngineeringNotation = BB_DEFAULT_RANDOM_INCLUDES_BINARY_ENGINEERING_NOTATION;

	[self logSettings];

	[self refreshSettings];
	[self loadSettings];

	[self logSettings];
}

- (void)loadSettings
{
	if (settings)
	{
		id pref;

		if ((pref = [settings objectForKey:@"tweakEnabled"])) self.tweakEnabled = [pref boolValue];
		if ((pref = [settings objectForKey:@"conversionType"])) self.conversionType = [pref integerValue];
		if ((pref = [settings objectForKey:@"formatTypeCustomFormatString"])) self.formatTypeCustomFormatString = (NSString *)pref;
		if ((pref = [settings objectForKey:@"formatTypeUnary"])) self.formatTypeUnary = [pref integerValue];
		if ((pref = [settings objectForKey:@"formatTypeBinary"])) self.formatTypeBinary = [pref integerValue];
		if ((pref = [settings objectForKey:@"formatTypeOctal"])) self.formatTypeOctal = [pref integerValue];
		if ((pref = [settings objectForKey:@"formatTypeDecimal"])) self.formatTypeDecimal = [pref integerValue];
		if ((pref = [settings objectForKey:@"formatTypeHexadecimal"])) self.formatTypeHexadecimal = [pref integerValue];
		if ((pref = [settings objectForKey:@"formatTypeRomanNumerals"])) self.formatTypeRomanNumerals = [pref integerValue];
		if ((pref = [settings objectForKey:@"formatTypePrimeFactorization"])) self.formatTypePrimeFactorization = [pref integerValue];
		if ((pref = [settings objectForKey:@"formatTypeScientificNotation"])) self.formatTypeScientificNotation = [pref integerValue];
		if ((pref = [settings objectForKey:@"formatTypeEngineeringNotation"])) self.formatTypeEngineeringNotation = [pref integerValue];
		if ((pref = [settings objectForKey:@"formatTypeBinaryEngineeringNotation"])) self.formatTypeBinaryEngineeringNotation = [pref integerValue];
		if ((pref = [settings objectForKey:@"useLowercaseHexadecimalCharacters"])) self.useLowercaseHexadecimalCharacters = [pref boolValue];
		if ((pref = [settings objectForKey:@"randomIncludesCustomFormat"])) self.randomIncludesCustomFormat = [pref boolValue];
		if ((pref = [settings objectForKey:@"randomIncludesUnary"])) self.randomIncludesUnary = [pref boolValue];
		if ((pref = [settings objectForKey:@"randomIncludesBinary"])) self.randomIncludesBinary = [pref boolValue];
		if ((pref = [settings objectForKey:@"randomIncludesOctal"])) self.randomIncludesOctal = [pref boolValue];
		if ((pref = [settings objectForKey:@"randomIncludesDecimal"])) self.randomIncludesDecimal = [pref boolValue];
		if ((pref = [settings objectForKey:@"randomIncludesHexadecimal"])) self.randomIncludesHexadecimal = [pref boolValue];
		if ((pref = [settings objectForKey:@"randomIncludesRomanNumerals"])) self.randomIncludesRomanNumerals = [pref boolValue];
		if ((pref = [settings objectForKey:@"randomIncludesPrimeFactorization"])) self.randomIncludesPrimeFactorization = [pref boolValue];
		if ((pref = [settings objectForKey:@"randomIncludesScientificNotation"])) self.randomIncludesScientificNotation = [pref boolValue];
		if ((pref = [settings objectForKey:@"randomIncludesEngineeringNotation"])) self.randomIncludesEngineeringNotation = [pref boolValue];
		if ((pref = [settings objectForKey:@"randomIncludesBinaryEngineeringNotation"])) self.randomIncludesBinaryEngineeringNotation = [pref boolValue];

		[self logSettings];
	}
}

- (void)refreshSettings
{
/*
	if (settings)
	{
		[settings release];
		settings = nil;
	}
*/

	settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@BB_PREFS_FILE];
}

@end

// vim:ft=objc
