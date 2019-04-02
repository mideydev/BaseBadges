// preference definitions
#define BB_BUNDLE_ID						"org.midey.basebadges"
#define BB_PREFS_DIRECTORY					"/var/mobile/Library/Preferences"
#define BB_PREFS_FILE						BB_PREFS_DIRECTORY "/" BB_BUNDLE_ID ".plist"
#define BB_RELOAD_PREFS_NOTIFICATION		BB_BUNDLE_ID "/reloadPreferences"
#define BB_UPDATE_SWITCH_NOTIFICATION		BB_BUNDLE_ID "/updateSwitch"
#define BB_UPDATE_SETTINGS_NOTIFICATION		BB_BUNDLE_ID "/updateSettings"

// localization definitions
#define BB_TWEAK_BUNDLE						"/Library/Application Support/BaseBadges.bundle"

// preference defaults
#define BB_DEFAULT_TWEAK_ENABLED								YES
#define BB_DEFAULT_CONVERSION_TYPE								kConversionRomanNumerals
#define BB_DEFAULT_FORMAT_TYPE_CUSTOM_FORMAT_STRING				@"\u221E"
#define BB_DEFAULT_FORMAT_TYPE_UNARY							kUnaryOnes
#define BB_DEFAULT_FORMAT_TYPE_BINARY							kBinaryAsIs 
#define BB_DEFAULT_FORMAT_TYPE_OCTAL							kOctalAsIs
#define BB_DEFAULT_FORMAT_TYPE_DECIMAL							kDecimalAsIs
#define BB_DEFAULT_FORMAT_TYPE_HEXADECIMAL						kHexadecimalAsIs
#define BB_DEFAULT_FORMAT_TYPE_ROMAN_NUMERALS					kRomanNumeralClassic
#define BB_DEFAULT_FORMAT_TYPE_PRIME_FACTORIZATION				kPrimeFactorizationWithoutSinglePowersWithSeparators
#define BB_DEFAULT_FORMAT_TYPE_SCIENTIFIC_NOTATION				kScientificNotationShorthandUppercaseE
#define BB_DEFAULT_FORMAT_TYPE_ENGINEERING_NOTATION				kEngineeringNotationShorthandUppercaseE
#define BB_DEFAULT_FORMAT_TYPE_BINARY_ENGINEERING_NOTATION		kBinaryEngineeringNotationShorthandUppercaseB
#define BB_DEFAULT_USE_LOWERCASE_HEXADECIMAL_CHARACTERS			NO
#define BB_DEFAULT_RANDOM_INCLUDES_CUSTOM_FORMAT				YES
#define BB_DEFAULT_RANDOM_INCLUDES_UNARY						YES
#define BB_DEFAULT_RANDOM_INCLUDES_BINARY						YES
#define BB_DEFAULT_RANDOM_INCLUDES_OCTAL						YES
#define BB_DEFAULT_RANDOM_INCLUDES_DECIMAL						YES
#define BB_DEFAULT_RANDOM_INCLUDES_HEXADECIMAL					YES
#define BB_DEFAULT_RANDOM_INCLUDES_ROMAN_NUMERALS				YES
#define BB_DEFAULT_RANDOM_INCLUDES_PRIME_FACTORIZATION			YES
#define BB_DEFAULT_RANDOM_INCLUDES_SCIENTIFIC_NOTATION			YES
#define BB_DEFAULT_RANDOM_INCLUDES_ENGINEERING_NOTATION			YES
#define BB_DEFAULT_RANDOM_INCLUDES_BINARY_ENGINEERING_NOTATION	YES

typedef NS_ENUM(NSUInteger,ConversionType)
{
	kConversionCustomFormat = 0,
	kConversionUnary,
	kConversionBinary,
	kConversionOctal,
	kConversionDecimal,
	kConversionHexadecimal,
	kConversionRomanNumerals,
	kConversionPrimeFactorization,
	kConversionScientificNotation,
	kConversionEngineeringNotation,
	kConversionBinaryEngineeringNotation,
	kConversionRandom = 99
};

typedef NS_ENUM(NSUInteger,UnaryFormatType)
{
	kUnaryOnes = 0,
	kUnaryVerticalLines,
	kUnaryOnesPostfixSubscript1,
	kUnaryVerticalLinesPostfixSubscript1
};

typedef NS_ENUM(NSUInteger,BinaryFormatType)
{
	kBinaryAsIs = 0,
	kBinaryPostfixSubscript2,
	kBinaryPostfixUppercaseB,
	kBinaryPostfixLowercaseB,
	kBinaryPrefixZeroLowercaseB,
	kBinaryPrefixPercentSign
};

typedef NS_ENUM(NSUInteger,OctalFormatType)
{
	kOctalAsIs = 0,
	kOctalPostfixSubscript8,
	kOctalPostfixLowercaseO,
	kOctalPrefixZero,
	kOctalPrefixBackslash,
	kOctalPrefixLowercaseO,
	kOctalPrefixLowercaseQ,
	kOctalPrefixZeroLowercaseO,
	kOctalPrefixAmpersand,
	kOctalPrefixDollarSign
};

typedef NS_ENUM(NSUInteger,DecimalFormatType)
{
	kDecimalAsIs = 0,
	kDecimalPostfixSubscript10
};

typedef NS_ENUM(NSUInteger,HexadecimalFormatType)
{
	kHexadecimalAsIs = 0,
	kHexadecimalPostfixSubscript16,
	kHexadecimalPostfixUppercaseH,
	kHexadecimalPostfixLowercaseH,
	kHexadecimalPrefixZero,
	kHexadecimalPrefixZeroLowercaseX,
	kHexadecimalPrefixZeroLowercaseH,
	kHexadecimalPrefixZeroPostfixUppercaseH,
	kHexadecimalPrefixZeroPostfixLowercaseH,
	kHexadecimalPrefixDollarSign
};

typedef NS_ENUM(NSUInteger,RomanNumeralFormatType)
{
	kRomanNumeralClassic = 0,
	kRomanNumeralOverbar
};

typedef NS_ENUM(NSUInteger,PrimeFactorizationFormatType)
{
	kPrimeFactorizationWithoutSinglePowersWithSeparators = 0,
	kPrimeFactorizationWithSinglePowersWithSeparators,
	kPrimeFactorizationWithSinglePowersWithoutSeparators
};

typedef NS_ENUM(NSUInteger,ScientificNotationFormatType)
{
	kScientificNotationShorthandUppercaseE = 0,
	kScientificNotationShorthandLowercaseE,
	kScientificNotationShorthandSmallCapitalE,
	kScientificNotationShorthandWolframLanguage
};

typedef NS_ENUM(NSUInteger,EngineeringNotationFormatType)
{
	kEngineeringNotationShorthandUppercaseE = 0,
	kEngineeringNotationShorthandLowercaseE,
	kEngineeringNotationShorthandSmallCapitalE,
	kEngineeringNotationShorthandWolframLanguage
};

typedef NS_ENUM(NSUInteger,BinaryEngineeringNotationFormatType)
{
	kBinaryEngineeringNotationShorthandUppercaseB = 0,
	kBinaryEngineeringNotationShorthandLowercaseB,
	kBinaryEngineeringNotationShorthandSmallCapitalB
};

@interface BBPreferences : NSObject
{
	NSMutableDictionary *settings;
}
@property(nonatomic) BOOL tweakEnabled;

@property(nonatomic) NSInteger conversionType;

@property(nonatomic,copy) NSString *formatTypeCustomFormatString;

@property(nonatomic) NSInteger formatTypeUnary;
@property(nonatomic) NSInteger formatTypeBinary;
@property(nonatomic) NSInteger formatTypeOctal;
@property(nonatomic) NSInteger formatTypeDecimal;
@property(nonatomic) NSInteger formatTypeHexadecimal;
@property(nonatomic) NSInteger formatTypeRomanNumerals;
@property(nonatomic) NSInteger formatTypePrimeFactorization;
@property(nonatomic) NSInteger formatTypeScientificNotation;
@property(nonatomic) NSInteger formatTypeEngineeringNotation;
@property(nonatomic) NSInteger formatTypeBinaryEngineeringNotation;

@property(nonatomic) BOOL useLowercaseHexadecimalCharacters;

@property(nonatomic) BOOL randomIncludesCustomFormat;
@property(nonatomic) BOOL randomIncludesUnary;
@property(nonatomic) BOOL randomIncludesBinary;
@property(nonatomic) BOOL randomIncludesOctal;
@property(nonatomic) BOOL randomIncludesDecimal;
@property(nonatomic) BOOL randomIncludesHexadecimal;
@property(nonatomic) BOOL randomIncludesRomanNumerals;
@property(nonatomic) BOOL randomIncludesPrimeFactorization;
@property(nonatomic) BOOL randomIncludesScientificNotation;
@property(nonatomic) BOOL randomIncludesEngineeringNotation;
@property(nonatomic) BOOL randomIncludesBinaryEngineeringNotation;

+ (instancetype)sharedInstance;
- (void)loadSettings;
- (void)refreshSettings;
@end

// vim:ft=objc
