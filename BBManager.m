#import <objc/runtime.h>
#import "SpringBoard.h"
#import "BBManager.h"
#import "BBPreferences.h"

@implementation BBManager

- (BBManager *)init
{
	self = [super init];

	if (self)
	{
	}

	return self;
}

+ (BBManager *)sharedInstance
{
	static BBManager *sharedInstance = nil;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[BBManager alloc] init];
		// Do any other initialization stuff here
	});

	return sharedInstance;
}

- (void)refreshBadges
{
	for (SBLeafIcon *icon in [[[objc_getClass("SBIconController") sharedInstance] model] leafIcons])
	{
		if ([icon isKindOfClass:NSClassFromString(@"SBFolderIcon")])
			continue;

		id badgeNumberOrString = [icon badgeNumberOrString];

		if (!badgeNumberOrString)
			continue;

		HBLogDebug(@"refreshBadges: refreshing: %@", [icon applicationBundleID]);

		[icon setBadge:nil];
		[icon setBadge:badgeNumberOrString];
	}
}

- (NSInteger)nonNegativeIntegerValue:(id)badgeNumberOrString
{
	if (!badgeNumberOrString)
		return -1;

	if ([badgeNumberOrString isKindOfClass:[NSNumber class]])
	{
		if ([badgeNumberOrString integerValue] < 0)
			return -1;

		return [badgeNumberOrString integerValue];
	}

	if (![badgeNumberOrString isKindOfClass:[NSString class]])
		return -1;

	NSString *badgeString = (NSString *)badgeNumberOrString;

	if ([badgeString isEqualToString:@""])
		return -1;

	// only want non-negative integers

	NSScanner *scanner;
	NSInteger badgeValue;
	BOOL isNumeric;

	// 1. check string as-is

	scanner = [NSScanner scannerWithString:badgeString];
	isNumeric = [scanner scanInteger:&badgeValue] && [scanner isAtEnd];

	if ((isNumeric) && (badgeValue >= 0))
		return badgeValue;

	// 2. check string without localized separators

	NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
	NSString *delocalizedBadgeString = [badgeString stringByReplacingOccurrencesOfString:groupingSeparator withString:@""];

	scanner = [NSScanner scannerWithString:delocalizedBadgeString];
	isNumeric = [scanner scanInteger:&badgeValue] && [scanner isAtEnd];

	if ((isNumeric) && (badgeValue >= 0))
	{
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setGroupingSeparator:groupingSeparator];

		NSString *relocalizedBadgeString = [numberFormatter stringFromNumber:@(badgeValue)];

		if ([badgeString isEqualToString:relocalizedBadgeString])
			return badgeValue;
	}

	// unknown format, must be special

	HBLogDebug(@"nonNegativeIntegerValue: nope (weird)");

	return -1;
}

- (NSString *)buildCustomString:(NSString *)formatString value:(NSInteger)value
{
	// empty strings prevent badges.  use a space so there is a badge
	if ([formatString isEqualToString:@""])
		return @" ";

#if 0
	// check for excessively long space-only strings, which expand badges infinitely (iOS does not truncate them with '...').
	// 16 characters seems to be the sweet spot (at least on a 6s) to give icons symmetric hats
	NSInteger maxBlankLength = 16;
	NSString *trimmedString = [formatString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

	if ([trimmedString isEqualToString:@""] && [formatString length] > maxBlankLength)
		return [[NSString string] stringByPaddingToLength:maxBlankLength withString:@" " startingAtIndex:0];
#endif

	// if no format string character, no need to check for each one
	if (![formatString containsString:@"%"])
		return formatString;

	NSString *customString = formatString;

	if ([customString containsString:@"%n"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%n" withString:[NSString stringWithFormat:@"%ld", (long)value]];

	if ([customString containsString:@"%u"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%u" withString:(NSString *)[self convertToUnaryByPreference:value]];

	if ([customString containsString:@"%U"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%U" withString:(NSString *)[self convertToUnary:value formatType:kUnaryOnes]];

	if ([customString containsString:@"%b"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%b" withString:(NSString *)[self convertToBinaryByPreference:value]];

	if ([customString containsString:@"%B"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%B" withString:(NSString *)[self convertToBinary:value formatType:kBinaryAsIs]];

	if ([customString containsString:@"%o"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%o" withString:(NSString *)[self convertToOctalByPreference:value]];

	if ([customString containsString:@"%O"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%O" withString:(NSString *)[self convertToOctal:value formatType:kOctalAsIs]];

	if ([customString containsString:@"%d"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%d" withString:(NSString *)[self convertToDecimalByPreference:value]];

	if ([customString containsString:@"%D"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%D" withString:(NSString *)[self convertToDecimal:value formatType:kDecimalAsIs]];

	if ([customString containsString:@"%h"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%h" withString:(NSString *)[self convertToHexadecimalByPreference:value]];

	if ([customString containsString:@"%H"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%H" withString:(NSString *)[self convertToHexadecimal:value formatType:kHexadecimalAsIs]];

	if ([customString containsString:@"%r"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%r" withString:(NSString *)[self convertToRomanNumeralsByPreference:value]];

	if ([customString containsString:@"%p"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%p" withString:(NSString *)[self convertToPrimeFactorizationByPreference:value]];

	if ([customString containsString:@"%c"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%c" withString:(NSString *)[self convertToScientificNotationByPreference:value]];

	if ([customString containsString:@"%e"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%e" withString:(NSString *)[self convertToEngineeringNotationByPreference:value]];

	if ([customString containsString:@"%i"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%i" withString:(NSString *)[self convertToBinaryEngineeringNotationByPreference:value]];

	if ([customString containsString:@"%s"])
		customString = [customString stringByReplacingOccurrencesOfString:@"%s" withString:[NSString stringWithFormat:@"%@", (value == 1) ? @"" : @"s"]];

	return customString;
}

- (id)convertToCustomFormat:(NSInteger)value
{
	NSString *customString = [self buildCustomString:[[BBPreferences sharedInstance] formatTypeCustomFormatString] value:value];

	id convertedValue = [NSString stringWithFormat:@"%@", customString];

	return convertedValue;
}

- (id)convertToUnary:(NSInteger)value symbol:(NSString *)symbol postfix:(NSString *)postfix
{
	NSString *unaryValue = [[NSString string] stringByPaddingToLength:(value * [symbol length]) withString:symbol startingAtIndex:0];

	id convertedValue = [NSString stringWithFormat:@"%@%@", unaryValue, postfix];

	return convertedValue;
}

- (id)convertToUnary:(NSInteger)value formatType:(NSInteger)formatType
{
	NSString *symbol = @"|";
	NSString *postfix = @"";

	switch (formatType)
	{
		case kUnaryOnes:
			symbol = @"1";
			postfix = @"";
			break;

		case kUnaryVerticalLines:
			symbol = @"|";
			postfix = @"";
			break;

		case kUnaryOnesPostfixSubscript1:
			symbol = @"1";
			postfix = @"\u2081";
			break;

		case kUnaryVerticalLinesPostfixSubscript1:
			symbol = @"|";
			postfix = @"\u2081";
			break;
	}

	return [self convertToUnary:value symbol:symbol postfix:postfix];
}

- (id)convertToUnaryByPreference:(NSInteger)value
{
	return [self convertToUnary:value formatType:[[BBPreferences sharedInstance] formatTypeUnary]];
}

- (id)convertToBinary:(NSInteger)value prefix:(NSString *)prefix postfix:(NSString *)postfix
{
	NSMutableString *binaryValue = [NSMutableString stringWithFormat:@""];

	for(NSInteger i = value; i > 0; i >>= 1)
		[binaryValue insertString:((i & 1) ? @"1" : @"0") atIndex:0];

	id convertedValue = [NSString stringWithFormat:@"%@%@%@", prefix, binaryValue, postfix];

	return convertedValue;
}

- (id)convertToBinary:(NSInteger)value formatType:(NSInteger)formatType
{
	NSString *prefix = @"";
	NSString *postfix = @"";

	switch (formatType)
	{
		case kBinaryAsIs:
			prefix = @"";
			postfix = @"";
			break;

		case kBinaryPostfixSubscript2:
			prefix = @"";
			postfix = @"\u2082";
			break;

		case kBinaryPostfixUppercaseB:
			prefix = @"";
			postfix = @"B";
			break;

		case kBinaryPostfixLowercaseB:
			prefix = @"";
			postfix = @"b";
			break;

		case kBinaryPrefixZeroLowercaseB:
			prefix = @"0b";
			postfix = @"";
			break;

		case kBinaryPrefixPercentSign:
			prefix = @"%";
			postfix = @"";
			break;
	}

	return [self convertToBinary:value prefix:prefix postfix:postfix];
}

- (id)convertToBinaryByPreference:(NSInteger)value
{
	return [self convertToBinary:value formatType:[[BBPreferences sharedInstance] formatTypeBinary]];
}

- (id)convertToOctal:(NSInteger)value prefix:(NSString *)prefix postfix:(NSString *)postfix
{
	id convertedValue = [NSString stringWithFormat:@"%@%lo%@", prefix, (long)value, postfix];

	return convertedValue;
}

- (id)convertToOctal:(NSInteger)value formatType:(NSInteger)formatType
{
	NSString *prefix = @"";
	NSString *postfix = @"";

	switch (formatType)
	{
		case kOctalAsIs:
			prefix = @"";
			postfix = @"";
			break;

		case kOctalPostfixSubscript8:
			prefix = @"";
			postfix = @"\u2088";
			break;

		case kOctalPostfixLowercaseO:
			prefix = @"";
			postfix = @"o";
			break;

		case kOctalPrefixZero:
			prefix = @"0";
			postfix = @"";
			break;

		case kOctalPrefixBackslash:
			prefix = @"\u29F5";
			postfix = @"";
			break;

		case kOctalPrefixLowercaseO:
			prefix = @"o";
			postfix = @"";
			break;

		case kOctalPrefixLowercaseQ:
			prefix = @"q";
			postfix = @"";
			break;

		case kOctalPrefixZeroLowercaseO:
			prefix = @"0o";
			postfix = @"";
			break;

		case kOctalPrefixAmpersand:
			prefix = @"&";
			postfix = @"";
			break;

		case kOctalPrefixDollarSign:
			prefix = @"$";
			postfix = @"";
			break;
	}

	return [self convertToOctal:value prefix:prefix postfix:postfix];
}

- (id)convertToOctalByPreference:(NSInteger)value
{
	return [self convertToOctal:value formatType:[[BBPreferences sharedInstance] formatTypeOctal]];
}

- (id)convertToDecimal:(NSInteger)value postfix:(NSString *)postfix
{
	id convertedValue = [NSString stringWithFormat:@"%ld%@", (long)value, postfix];

	return convertedValue;
}

- (id)convertToDecimal:(NSInteger)value formatType:(NSInteger)formatType
{
	NSString *postfix = @"";

	switch (formatType)
	{
		case kDecimalAsIs:
			postfix = @"";
			break;

		case kDecimalPostfixSubscript10:
			postfix = @"\u2081\u2080";
			break;
	}

	return [self convertToDecimal:value postfix:postfix];
}

- (id)convertToDecimalByPreference:(NSInteger)value
{
	return [self convertToDecimal:value formatType:[[BBPreferences sharedInstance] formatTypeDecimal]];
}

- (id)convertToHexadecimal:(NSInteger)value prefix:(NSString *)prefix postfix:(NSString *)postfix useLowercase:(BOOL)useLowercase
{
	NSString *formatString = (useLowercase) ? @"%@%lx%@" : @"%@%lX%@";

	id convertedValue = [NSString stringWithFormat:formatString, prefix, (long)value, postfix];

	return convertedValue;
}

- (id)convertToHexadecimal:(NSInteger)value formatType:(NSInteger)formatType
{
	NSString *prefix = @"";
	NSString *postfix = @"";
	BOOL useLowercase = [[BBPreferences sharedInstance] useLowercaseHexadecimalCharacters];

	switch (formatType)
	{
		case kHexadecimalAsIs:
			prefix = @"";
			postfix = @"";
			break;

		case kHexadecimalPostfixSubscript16:
			prefix = @"";
			postfix = @"\u2081\u2086";
			break;

		case kHexadecimalPostfixUppercaseH:
			prefix = @"";
			postfix = @"H";
			break;

		case kHexadecimalPostfixLowercaseH:
			prefix = @"";
			postfix = @"h";
			break;

		case kHexadecimalPrefixZero:
			prefix = @"0";
			postfix = @"";
			break;

		case kHexadecimalPrefixZeroLowercaseX:
			prefix = @"0x";
			postfix = @"";
			break;

		case kHexadecimalPrefixZeroLowercaseH:
			prefix = @"0h";
			postfix = @"";
			break;

		case kHexadecimalPrefixZeroPostfixUppercaseH:
			prefix = @"0";
			postfix = @"H";
			break;

		case kHexadecimalPrefixZeroPostfixLowercaseH:
			prefix = @"0";
			postfix = @"h";
			break;

		case kHexadecimalPrefixDollarSign:
			prefix = @"$";
			postfix = @"";
			break;
	}

	return [self convertToHexadecimal:value prefix:prefix postfix:postfix useLowercase:useLowercase];
}

- (id)convertToHexadecimalByPreference:(NSInteger)value
{
	return [self convertToHexadecimal:value formatType:[[BBPreferences sharedInstance] formatTypeHexadecimal]];
}

- (id)convertToRomanNumerals:(NSInteger)value useOverbars:(BOOL)useOverbars
{
	NSArray *m0 = [NSArray arrayWithObjects:@"", @"I", @"II", @"III", @"IV", @"V", @"VI", @"VII", @"VIII", @"IX", nil];
	NSArray *m1 = [NSArray arrayWithObjects:@"", @"X", @"XX", @"XXX", @"XL", @"L", @"LX", @"LXX", @"LXXX", @"XC", nil];
	NSArray *m2 = [NSArray arrayWithObjects:@"", @"C", @"CC", @"CCC", @"CD", @"D", @"DC", @"DCC", @"DCCC", @"CM", nil];

	id convertedValue;

	if (useOverbars)
	{
		NSArray *m3 = [NSArray arrayWithObjects:@"", @"M", @"MM", @"MMM",@"I\u0305V\u0305", @"V\u0305", @"V\u0305I\u0305",
			@"V\u0305I\u0305I\u0305", @"V\u0305I\u0305I\u0305I\u0305", @"I\u0305X\u0305", nil];
		NSArray *m4 = [NSArray arrayWithObjects:@"", @"X\u0305", @"X\u0305X\u0305", @"X\u0305X\u0305X\u0305", @"X\u0305L\u0305",
			@"L\u0305", @"L\u0305X\u0305", @"L\u0305X\u0305X\u0305", @"L\u0305X\u0305X\u0305X\u0305", @"X\u0305C\u0305", nil];
		NSArray *m5 = [NSArray arrayWithObjects:@"", @"C\u0305", @"C\u0305C\u0305", @"C\u0305C\u0305C\u0305", @"C\u0305D\u0305",
			@"D\u0305", @"D\u0305C\u0305", @"D\u0305C\u0305C\u0305", @"D\u0305C\u0305C\u0305C\u0305", @"C\u0305M\u0305", nil];

		convertedValue = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",
			[[NSString string] stringByPaddingToLength:((value / 1000000) * [@"M\u0305" length]) withString:@"M\u0305" startingAtIndex:0],
			[m5 objectAtIndex:((value % 1000000) / 100000)],
			[m4 objectAtIndex:((value % 100000) / 10000)],
			[m3 objectAtIndex:((value % 10000) / 1000)],
			[m2 objectAtIndex:((value % 1000) / 100)],
			[m1 objectAtIndex:((value % 100) / 10)],
			[m0 objectAtIndex:(value % 10)]
		];
	}
	else
	{
		convertedValue = [NSString stringWithFormat:@"%@%@%@%@",
			[[NSString string] stringByPaddingToLength:((value / 1000) * [@"M" length]) withString:@"M" startingAtIndex:0],
			[m2 objectAtIndex:((value % 1000) / 100)],
			[m1 objectAtIndex:((value % 100) / 10)],
			[m0 objectAtIndex:(value % 10)]
		];
	}

	return convertedValue;
}

- (id)convertToRomanNumerals:(NSInteger)value formatType:(NSInteger)formatType
{
	BOOL useOverbars = NO;

	switch (formatType)
	{
		case kRomanNumeralClassic:
			useOverbars = NO;
			break;

		case kRomanNumeralOverbar:
			useOverbars = YES;
			break;
	}

	return [self convertToRomanNumerals:value useOverbars:useOverbars];
}

- (id)convertToRomanNumeralsByPreference:(NSInteger)value
{
	return [self convertToRomanNumerals:value formatType:[[BBPreferences sharedInstance] formatTypeRomanNumerals]];
}

- (id)convertToPrimeFactorization:(NSInteger)value singlePowers:(BOOL)singlePowers separator:(NSString *)separator
{
	NSMutableDictionary *factorCounts = [NSMutableDictionary dictionary];
	NSMutableArray *factorKeys = [NSMutableArray array];
	NSInteger n = value;

	if (n == 1)
	{
		[factorKeys addObject:@(1)];
		[factorCounts setObject:@(1) forKey:@(1)];
	}
	else
	{
		// Divide by 2:
		while (n > 1 && n % 2 == 0)
		{
			id count = [factorCounts objectForKey:@(2)];

			if (count)
			{
				[factorCounts setObject:@([count integerValue] + 1) forKey:@(2)];
			}
			else
			{
				[factorKeys addObject:@(2)];
				[factorCounts setObject:@(1) forKey:@(2)];
			}

			n /= 2;
		}

		// Divide by 3, 5, 7, ...
		//
		// i is a possible *smallest* factor of the (remaining) number n.
		// If i * i > n then n is either 1 or a prime number.
		for (long i = 3; i * i <= n; i += 2)
		{
			while (n > 1 && n % i == 0)
			{
				id count = [factorCounts objectForKey:@(i)];

				if (count)
				{
					[factorCounts setObject:@([count integerValue] + 1) forKey:@(i)];
				}
				else
				{
					[factorKeys addObject:@(i)];
					[factorCounts setObject:@(1) forKey:@(i)];
				}

				n /= i;
			}
		}

		if (n > 1)
		{
			// Append last prime factor:
			[factorKeys addObject:@(n)];
			[factorCounts setObject:@(1) forKey:@(n)];
		}
	}

	NSMutableArray *values = [NSMutableArray array];

	for(id key in factorKeys)
	{
		NSNumber *count = [factorCounts objectForKey:key];

		NSString *exponent = @"";

		if (singlePowers || ([count integerValue] > 1))
		{
			exponent = [count stringValue];

			exponent = [exponent stringByReplacingOccurrencesOfString:@"0" withString:@"\u2070"];
			exponent = [exponent stringByReplacingOccurrencesOfString:@"1" withString:@"\u00B9"];
			exponent = [exponent stringByReplacingOccurrencesOfString:@"2" withString:@"\u00B2"];
			exponent = [exponent stringByReplacingOccurrencesOfString:@"3" withString:@"\u00B3"];
			exponent = [exponent stringByReplacingOccurrencesOfString:@"4" withString:@"\u2074"];
			exponent = [exponent stringByReplacingOccurrencesOfString:@"5" withString:@"\u2075"];
			exponent = [exponent stringByReplacingOccurrencesOfString:@"6" withString:@"\u2076"];
			exponent = [exponent stringByReplacingOccurrencesOfString:@"7" withString:@"\u2077"];
			exponent = [exponent stringByReplacingOccurrencesOfString:@"8" withString:@"\u2078"];
			exponent = [exponent stringByReplacingOccurrencesOfString:@"9" withString:@"\u2079"];

		}

		NSString *value = [NSString stringWithFormat:@"%@%@", [key stringValue], exponent];

		[values addObject:value];
	}

	NSString *convertedValue = [values componentsJoinedByString:separator];

	return convertedValue;
}

- (id)convertToPrimeFactorization:(NSInteger)value formatType:(NSInteger)formatType
{
	NSString *separator = @"\u22C5";
	BOOL singlePowers = NO;

	switch (formatType)
	{
		case kPrimeFactorizationWithoutSinglePowersWithSeparators:
			singlePowers = NO;
			separator = @"\u22C5";
			break;

		case kPrimeFactorizationWithSinglePowersWithSeparators:
			singlePowers = YES;
			separator = @"\u22C5";
			break;

		case kPrimeFactorizationWithSinglePowersWithoutSeparators:
			singlePowers = YES;
			separator = @"";
			break;
	}

	return [self convertToPrimeFactorization:value singlePowers:singlePowers separator:separator];
}

- (id)convertToPrimeFactorizationByPreference:(NSInteger)value
{
	return [self convertToPrimeFactorization:value formatType:[[BBPreferences sharedInstance] formatTypePrimeFactorization]];
}

- (id)convertToExponentialNotation:(NSInteger)value base:(NSInteger)base grouping:(NSInteger)grouping shorthand:(NSString *)shorthand
{
	if (value < 1)
		return [NSString stringWithFormat:@"%ld", (long)value];

	NSInteger mod = 1;

	for (NSInteger i = 0; i < grouping; i++)
		mod *= base;

	NSInteger significand = value;
	NSInteger modulus = 0;
	NSInteger magnitude = 1;
	NSInteger exponent = 0;

	while (significand >= mod)
	{
		magnitude *= mod;
		exponent += grouping;
		significand = value / magnitude;
		modulus = value % magnitude;
	}

	NSString *significandFractional = @"";

	if (modulus > 0)
	{
		switch (base)
		{
			case 2:
			{
				significandFractional = (NSString *)[self convertToBinary:modulus prefix:@"" postfix:@""];
				break;
			}

			case 10:
			{
				NSString *maxFractional = [NSString stringWithFormat:@"%ld", (long)(magnitude - 1)];
				NSString *formatFractional = [NSString stringWithFormat:@"%%0%ldld", (long)[maxFractional length]];

				significandFractional = [NSString stringWithFormat:formatFractional, (long)modulus];

				HBLogDebug(@"convertToExponentialNotation: formatFractional: [%@] <= %ld (%ld %% %ld) => significandFractional: [%@]",
					formatFractional, (long)modulus, (long)value, (long)magnitude, significandFractional);

				while ([[significandFractional substringFromIndex:[significandFractional length] - 1] isEqualToString:@"0"])
					significandFractional = [significandFractional substringToIndex:[significandFractional length] - 1];

				break;
			}

			default:
				significandFractional = @"?";
				break;

		}

		significandFractional = [NSString stringWithFormat:@".%@", significandFractional];
	}

	id convertedValue = [NSString stringWithFormat:@"%ld%@%@%ld", (long)significand, significandFractional, shorthand, (long)exponent];

	return convertedValue;
}

- (id)convertToScientificNotation:(NSInteger)value shorthand:(NSString *)shorthand
{
	id convertedValue = [self convertToExponentialNotation:value base:10 grouping:1 shorthand:shorthand];

	return convertedValue;
}

- (id)convertToScientificNotation:(NSInteger)value formatType:(NSInteger)formatType
{
	NSString *shorthand = @"e";

	switch (formatType)
	{
		case kScientificNotationShorthandUppercaseE:
			shorthand = @"E";
			break;

		case kScientificNotationShorthandLowercaseE:
			shorthand = @"e";
			break;

		case kScientificNotationShorthandSmallCapitalE:
			shorthand = @"\u1d07";
			break;

		case kScientificNotationShorthandWolframLanguage:
			shorthand = @"*^";
			break;
	}

	return [self convertToScientificNotation:value shorthand:shorthand];
}

- (id)convertToScientificNotationByPreference:(NSInteger)value
{
	return [self convertToScientificNotation:value formatType:[[BBPreferences sharedInstance] formatTypeScientificNotation]];
}

- (id)convertToEngineeringNotation:(NSInteger)value shorthand:(NSString *)shorthand
{
	id convertedValue = [self convertToExponentialNotation:value base:10 grouping:3 shorthand:shorthand];

	return convertedValue;
}

- (id)convertToEngineeringNotation:(NSInteger)value formatType:(NSInteger)formatType
{
	NSString *shorthand = @"e";

	switch (formatType)
	{
		case kEngineeringNotationShorthandUppercaseE:
			shorthand = @"E";
			break;

		case kEngineeringNotationShorthandLowercaseE:
			shorthand = @"e";
			break;

		case kEngineeringNotationShorthandSmallCapitalE:
			shorthand = @"\u1d07";
			break;

		case kEngineeringNotationShorthandWolframLanguage:
			shorthand = @"*^";
			break;
	}

	return [self convertToEngineeringNotation:value shorthand:shorthand];
}

- (id)convertToEngineeringNotationByPreference:(NSInteger)value
{
	return [self convertToEngineeringNotation:value formatType:[[BBPreferences sharedInstance] formatTypeEngineeringNotation]];
}

- (id)convertToBinaryEngineeringNotation:(NSInteger)value shorthand:(NSString *)shorthand
{
	id convertedValue = [self convertToExponentialNotation:value base:2 grouping:1 shorthand:shorthand];

	return convertedValue;
}

- (id)convertToBinaryEngineeringNotation:(NSInteger)value formatType:(NSInteger)formatType
{
	NSString *shorthand = @"b";

	switch (formatType)
	{
		case kBinaryEngineeringNotationShorthandUppercaseB:
			shorthand = @"B";
			break;

		case kBinaryEngineeringNotationShorthandLowercaseB:
			shorthand = @"b";
			break;

		case kBinaryEngineeringNotationShorthandSmallCapitalB:
			shorthand = @"\u0299";
			break;
	}

	return [self convertToBinaryEngineeringNotation:value shorthand:shorthand];
}

- (id)convertToBinaryEngineeringNotationByPreference:(NSInteger)value
{
	return [self convertToBinaryEngineeringNotation:value formatType:[[BBPreferences sharedInstance] formatTypeBinaryEngineeringNotation]];
}

- (id)convertUsingRandomConversionType:(NSInteger)value
{
	NSMutableArray *randomOptions = [[NSMutableArray alloc] init];

	if ([[BBPreferences sharedInstance] randomIncludesCustomFormat])
		[randomOptions addObject:@(kConversionCustomFormat)];

	if ([[BBPreferences sharedInstance] randomIncludesUnary])
		[randomOptions addObject:@(kConversionUnary)];

	if ([[BBPreferences sharedInstance] randomIncludesBinary])
		[randomOptions addObject:@(kConversionBinary)];

	if ([[BBPreferences sharedInstance] randomIncludesOctal])
		[randomOptions addObject:@(kConversionOctal)];

	if ([[BBPreferences sharedInstance] randomIncludesDecimal])
		[randomOptions addObject:@(kConversionDecimal)];

	if ([[BBPreferences sharedInstance] randomIncludesHexadecimal])
		[randomOptions addObject:@(kConversionHexadecimal)];

	if ([[BBPreferences sharedInstance] randomIncludesRomanNumerals])
		[randomOptions addObject:@(kConversionRomanNumerals)];

	if ([[BBPreferences sharedInstance] randomIncludesPrimeFactorization])
		[randomOptions addObject:@(kConversionPrimeFactorization)];

	if ([[BBPreferences sharedInstance] randomIncludesScientificNotation])
		[randomOptions addObject:@(kConversionScientificNotation)];

	if ([[BBPreferences sharedInstance] randomIncludesEngineeringNotation])
		[randomOptions addObject:@(kConversionEngineeringNotation)];

	if ([[BBPreferences sharedInstance] randomIncludesBinaryEngineeringNotation])
		[randomOptions addObject:@(kConversionBinaryEngineeringNotation)];

	if ([randomOptions count] == 0)
		return nil;

	NSInteger conversionType = [randomOptions[arc4random_uniform([randomOptions count])] integerValue];

	return [self convertBadgeValue:value conversionType:conversionType];
}

- (id)convertBadgeValue:(NSInteger)value conversionType:(NSInteger)conversionType
{
	id convertedValue = nil;

	switch (conversionType)
	{
		case kConversionCustomFormat:
			convertedValue = [self convertToCustomFormat:value];
			break;

		case kConversionUnary:
			convertedValue = [self convertToUnaryByPreference:value];
			break;

		case kConversionBinary:
			convertedValue = [self convertToBinaryByPreference:value];
			break;

		case kConversionOctal:
			convertedValue = [self convertToOctalByPreference:value];
			break;

		case kConversionDecimal:
			convertedValue = [self convertToDecimalByPreference:value];
			break;

		case kConversionHexadecimal:
			convertedValue = [self convertToHexadecimalByPreference:value];
			break;

		case kConversionRomanNumerals:
			convertedValue = [self convertToRomanNumeralsByPreference:value];
			break;

		case kConversionPrimeFactorization:
			convertedValue = [self convertToPrimeFactorizationByPreference:value];
			break;

		case kConversionScientificNotation:
			convertedValue = [self convertToScientificNotationByPreference:value];
			break;

		case kConversionEngineeringNotation:
			convertedValue = [self convertToEngineeringNotationByPreference:value];
			break;

		case kConversionBinaryEngineeringNotation:
			convertedValue = [self convertToBinaryEngineeringNotationByPreference:value];
			break;

		case kConversionRandom:
			convertedValue = [self convertUsingRandomConversionType:value];
			break;
	}

	return convertedValue;
}

- (id)convertBadgeNumberOrString:(id)badgeNumberOrString conversionType:(NSInteger)conversionType
{
	NSInteger value = [self nonNegativeIntegerValue:badgeNumberOrString];

	if (value < 0)
		return badgeNumberOrString;

	id convertedValue = [self convertBadgeValue:value conversionType:conversionType];

	if (!convertedValue)
		convertedValue = badgeNumberOrString;

	HBLogDebug(@"convertBadgeNumberOrString: [%@] => [%@]", badgeNumberOrString, convertedValue);

	return convertedValue;
}

- (id)convertBadgeNumberOrString:(id)badgeNumberOrString
{
	return [self convertBadgeNumberOrString:badgeNumberOrString conversionType:[[BBPreferences sharedInstance] conversionType]];
}

@end

// vim:ft=objc
