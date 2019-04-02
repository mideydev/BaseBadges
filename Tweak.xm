#import <libkern/OSAtomic.h>
#import "SpringBoard.h"
#import "BBPreferences.h"
#import "BBManager.h"

static volatile int64_t configuringBadgeView = 0;
static volatile int64_t checkingOutAccessoryImages = 0;
static volatile int64_t requestingRealBadgeValue = 0;
static volatile int64_t requestingFakeBadgeValue = 0;

static BOOL shouldConvertValue(NSString *caller)
{
	int64_t configuring = configuringBadgeView;
	int64_t checking = checkingOutAccessoryImages;
	int64_t requesting_real = requestingRealBadgeValue;
	int64_t requesting_fake = requestingFakeBadgeValue;

	BOOL convertValue = (configuring || checking || requesting_fake) && !requesting_real;

	HBLogDebug(@"shouldConvertValue: %@: { configuring = %lld; checking = %lld; requesting_real = %lld; requesting_fake = %lld } => convert: %@",
		caller, configuring, checking, requesting_real, requesting_fake, convertValue ? @"YES" : @"NO");

	return convertValue;
}

#if 0
static SBIconListView *IDWListViewForIcon(SBIcon *icon)
{
//	SBIconController *controller = [objc_getClass("SBIconController") sharedInstance];
//	SBRootFolder *rootFolder = [controller valueForKeyPath:@"rootFolder"];
	SBRootFolder *rootFolder = [[[objc_getClass("SBIconController") sharedInstance] _currentFolderController] valueForKeyPath:@"rootFolder"];
	NSIndexPath *indexPath = [rootFolder indexPathForIcon:icon];
	SBIconListView *listView = nil;
	[controller getListView:&listView folder:NULL relativePath:NULL forIndexPath:indexPath createIfNecessary:YES];
	return listView;
}
#endif

#if 0
%hook SBIconListView

-(double)horizontalIconPadding
{
	double retval = %orig();

	HBLogDebug(@"horizontalIconPadding: %0.2f", retval);

	return retval;
}

%end
#endif

%hook SBApplication

%group SBApplication_iOS11OrLess

- (id)badgeNumberOrString
{
	if (![[BBPreferences sharedInstance] tweakEnabled])
	{
		return %orig();
	}

	id retval = %orig();

	if (!retval)
		return retval;

	NSString *func = @"[SBApplication] badgeNumberOrString";

	if (shouldConvertValue(func))
	{
		id newval = [[BBManager sharedInstance] convertBadgeNumberOrString:retval];

		HBLogDebug(@"%@: %@: [%@] => [%@]", func, [self bundleIdentifier], retval, newval);

		return newval;
	}

	return retval;
}

%end /* group SBApplication_iOS11OrLess */

%group SBApplication_iOS12OrGreater

- (id)badgeValue
{
	if (![[BBPreferences sharedInstance] tweakEnabled])
	{
		return %orig();
	}

	id retval = %orig();

	if (!retval)
		return retval;

	NSString *func = @"[SBApplication] badgeValue";

	if (shouldConvertValue(func))
	{
		id newval = [[BBManager sharedInstance] convertBadgeNumberOrString:retval];

#if 0
		if ([[self bundleIdentifier] isEqualToString:@"com.apple.MobileSMS"]) // binary
			newval = @"1101\u2082";
		else if ([[self bundleIdentifier] isEqualToString:@"com.apple.mobilemail"]) // prime factorization
			newval = @"2\u22C53\u00B2\u22C55";
		else if ([[self bundleIdentifier] isEqualToString:@"com.apple.mobilecal"]) // roman numerals
			newval = @"XVII";
		else if ([[self bundleIdentifier] isEqualToString:@"com.google.Gmail"]) // hexadecimal
			newval = @"0x4c";
		else if ([[self bundleIdentifier] isEqualToString:@"com.nintendo.znma"]) // unary
			newval = @"111\u2081";
		else if ([[self bundleIdentifier] isEqualToString:@"com.burbn.instagram"]) // scientific
			newval = @"3\u1D070";
		else if ([[self bundleIdentifier] isEqualToString:@"com.weather.TWCRadar"]) // custom 
			newval = @"\U0001F974";
		else if ([[self bundleIdentifier] isEqualToString:@"com.google.GVDialer"]) // octal
			newval = @"17\u2088";
		else if ([[self bundleIdentifier] isEqualToString:@"com.apple.AppStore"]) // binary engineering
			newval = @"1.101B4";
#endif

		HBLogDebug(@"%@: %@: [%@] => [%@]", func, [self bundleIdentifier], retval, newval);

		return newval;
	}

	return retval;
}

%end /* group SBApplication_iOS12OrGreater */

%end /* hook SBApplication */

%hook SBFolderIcon

- (id)badgeNumberOrString
{
	if (![[BBPreferences sharedInstance] tweakEnabled])
	{
		return %orig();
	}

	id retval = %orig();

	if (!retval)
		return retval;

	NSString *func = @"[SBFolderIcon] badgeNumberOrString";

	if (shouldConvertValue(func))
	{
		id newval = [[BBManager sharedInstance] convertBadgeNumberOrString:retval];

		HBLogDebug(@"%@: %@: [%@] => [%@]", func, [[self folder] displayName], retval, newval);

		return newval;
	}

	return retval;
}

%end /* SBFolderIcon */

%hook SBIconBadgeView

%group SBIconBadgeView_iOS10OrLess

- (void)configureForIcon:(id)arg1 location:(int)arg2 highlighted:(_Bool)arg3
{
	OSAtomicIncrement64(&configuringBadgeView);

	%orig();

	OSAtomicDecrement64(&configuringBadgeView);
}

- (void)configureAnimatedForIcon:(id)arg1 location:(int)arg2 highlighted:(_Bool)arg3 withPreparation:(id)arg4 animation:(id)arg5 completion:(id)arg6
{
	OSAtomicIncrement64(&configuringBadgeView);

	%orig();

	OSAtomicDecrement64(&configuringBadgeView);
}

%end /* SBIconBadgeView_iOS10OrLess */

%group SBIconBadgeView_iOS11

- (void)configureForIcon:(id)arg1 infoProvider:(id)arg2
{
	OSAtomicIncrement64(&configuringBadgeView);

	%orig();

	OSAtomicDecrement64(&configuringBadgeView);
}

- (void)configureAnimatedForIcon:(id)arg1 infoProvider:(id)arg2 withPreparation:(id)arg3 animation:(id)arg4 completion:(id)arg5
{
	OSAtomicIncrement64(&configuringBadgeView);

	%orig();

	OSAtomicDecrement64(&configuringBadgeView);
}

%end /* SBIconBadgeView_iOS11 */

%group SBIconBadgeView_iOS12OrGreater

- (void)configureForIcon:(id)arg1 infoProvider:(id)arg2
{
	OSAtomicIncrement64(&configuringBadgeView);

	%orig();

	OSAtomicDecrement64(&configuringBadgeView);
}

- (void)configureAnimatedForIcon:(id)arg1 infoProvider:(id)arg2 animator:(id)arg3
{
	OSAtomicIncrement64(&configuringBadgeView);

	%orig();

	OSAtomicDecrement64(&configuringBadgeView);
}

%end /* SBIconBadgeView_iOS12OrGreater */

+ (id)checkoutAccessoryImagesForIcon:(id)arg1 location:(long long)arg2
{
	OSAtomicIncrement64(&checkingOutAccessoryImages);

	id retval = %orig();

	OSAtomicDecrement64(&checkingOutAccessoryImages);

	return retval;
}

+ (double)_maxTextWidth
{
	if (![[BBPreferences sharedInstance] tweakEnabled])
	{
		return %orig();
	}

	//     hs   ??  fld     badge
	// 6s: 27, -98, 36  _maxTextWidth:  65
	// 5s: 16, -91, 36  _maxTextWidth:  53

	double retval = %orig();

	double newval = 1.15 * retval;

	HBLogDebug(@"_maxTextWidth: %0.2f => %0.2f", retval, newval);

	return newval;
}

%end /* SBIconBadgeView */

%hook CMBIconInfo

- (id)realBadgeNumberOrString
{
	OSAtomicIncrement64(&requestingRealBadgeValue);

	id retval = %orig();

	OSAtomicDecrement64(&requestingRealBadgeValue);

	return retval;
}

- (id)fakeBadgeNumberOrString
{
	OSAtomicIncrement64(&requestingFakeBadgeValue);

	id retval = %orig();

	OSAtomicDecrement64(&requestingFakeBadgeValue);

	return retval;
}

%end /* CMBIconInfo */

%ctor
{
	dlopen("/Library/MobileSubstrate/DynamicLibraries/ColorMeBaddge.dylib", RTLD_LAZY);

	/* SBIconBadgeView conditional hooks */

	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0"))
	{
		%init(SBIconBadgeView_iOS12OrGreater);
	}
	else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0"))
	{
		%init(SBIconBadgeView_iOS11);
	}
	else
	{
		%init(SBIconBadgeView_iOS10OrLess);
	}

	/* SBApplication conditional hooks */

	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.0"))
	{
		%init(SBApplication_iOS12OrGreater);
	}
	else
	{
		%init(SBApplication_iOS11OrLess);
	}

	%init;
}

// vim:ft=objc
