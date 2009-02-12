//
//  DiceshakerAppDelegate.m
//  Diceshaker
//
//  Created by ∞ on 04/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "DiceshakerAppDelegate.h"
#import "UIAlertView+L0Alert.h"

#import "NSURL_L0URLParsing.h"

static BOOL L0AccelerationIsShaking(UIAcceleration* last, UIAcceleration* current, double threshold) {
	double
	deltaX = fabs(last.x - current.x),
	deltaY = fabs(last.y - current.y),
	deltaZ = fabs(last.z - current.z);
	
	return
	(deltaX > threshold && deltaY > threshold) ||
	(deltaX > threshold && deltaZ > threshold) ||
	(deltaY > threshold && deltaZ > threshold);
}

@implementation DiceshakerAppDelegate

@synthesize window, mainController, backSideController, currentDice, lastRoll, history, lastAcceleration, flippingBack, navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[[NSUserDefaults standardUserDefaults]
	 setVolatileDomain:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kL0DiceshakerShouldPlaySoundDefault] forName:NSRegistrationDomain];
	
	history = [NSMutableArray new];
	
	BOOL foundSavedData = NO;
	
	NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([dirs count] > 0) {
		NSString* dir = [dirs objectAtIndex:0];
		
		NSArray* a = [NSArray arrayWithContentsOfFile:[dir stringByAppendingPathComponent:@"History.plist"]];
		for (id d in a) {
			L0Dice* dice;
			if ([d isKindOfClass:[NSDictionary class]] && (dice = [L0Dice diceWithDictionary:d]))
				[history addObject:dice];
			
			foundSavedData = YES;
		}
	}
	
	if (AudioServicesCreateSystemSoundID((CFURLRef) [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"roll" ofType:@"aiff"]], &systemSound) == noErr)
		systemSoundAvailable = YES;
	
	[UIAccelerometer sharedAccelerometer].delegate = self;
	
	NSDictionary* d = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kL0DiceshakerLastDiceDefault];
	if (d)
		self.currentDice = [L0Dice diceWithDictionary:d];
	
	if (!self.currentDice)
		self.currentDice = [L0Dice diceWithNumberOfDice:3 faces:6];
	
	[self.window addSubview:self.mainController.navigationController.view];
    [window makeKeyAndVisible];
	
	// Do not nag previous customers.
	if (foundSavedData && ![[NSUserDefaults standardUserDefaults] objectForKey:kL0DiceshakerFirstLaunchDateDefault])
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kL0DiceshakerDidEndNaggingDefault];
	
	[self performSelector:@selector(showNagScreenIfNeeded) withObject:nil afterDelay:2.0];
}

- (BOOL) application:(UIApplication*) application handleOpenURL:(NSURL*) url {
//	volatile BOOL goOn = NO; while (!goOn) {
//		sleep(1);
//	}
	
	if ([[url scheme] isEqual:@"x-infinitelabs-diceshaker"] && [[url resourceSpecifier] isEqual:@"donations-off"]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kL0DiceshakerDidEndNaggingDefault];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showNagScreenIfNeeded) object:nil];
		
		[self performSelector:@selector(_showNagMessagesDisabled) withObject:nil afterDelay:1.0];
		return YES;
	}
	
	if (([[url scheme] isEqual:@"x-infinitelabs-diceshaker"] && [[url resourceSpecifier] hasPrefix:@"roll?"]) || ([[url scheme] isEqual:@"x-service-public.diceroll"] && [[url resourceSpecifier] hasPrefix:@"?"])) {
		if (handledCrossAppURL) return YES;
		
		NSDictionary* d = [url dictionaryByDecodingQueryString];
		id returnURL = [d objectForKey:@"returnURL"];
		if (returnURL && ![returnURL isEqual:[NSNull null]])
			returnCrossAppURL = [[NSURL URLWithString:returnURL] retain];
		
		NSString* title = [d objectForKey:@"sender"];
		if (!(title && ![title isEqual:[NSNull null]]))
			title = nil;
		
		if (title && returnCrossAppURL) {
			mainController.navigationItem.prompt = [NSString stringWithFormat:mainController.navigationItem.prompt, title];
			[self performSelector:@selector(_putIntoCrossApplicationCommunicationMode) withObject:nil afterDelay:0.5];
			handledCrossAppURL = YES;
			return YES;
		}
	}
	
	UIAlertView* alert = [UIAlertView alertNamed:@"L0DiceshakerUnknownURL"];
	alert.tag = kL0DiceshakerAlertTagUnknownURL;
	alert.cancelButtonIndex = 1; // Dismiss
	alert.delegate = self;
	[alert show];
	return NO;
}

- (void) _putIntoCrossApplicationCommunicationMode {
	[self roll];
	[mainController.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) _sendToOtherApp:(NSDictionary*) d;
{
	NSString* q = [d queryString];
	NSString* url = [returnCrossAppURL absoluteString];
	
	if ([url rangeOfString:@"?"].location == NSNotFound)
		url = [NSString stringWithFormat:@"%@?%@", url, q];
	else
		url = [NSString stringWithFormat:@"%@&%@", url, q];
	
	L0Log(@"Will send IPC result via URL = %@", url);
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (IBAction) sendToOtherApp;
{
	NSString* numberOfDice = [NSString stringWithFormat:@"%d", self.currentDice.numberOfDice];
	NSString* numberOfFacesPerDie = [NSString stringWithFormat:@"%d", self.currentDice.numberOfFacesPerDie];
	NSString* roll = [NSString stringWithFormat:@"%d", [lastRoll totalOfDieRoll]];
	
	[self _sendToOtherApp:[NSDictionary dictionaryWithObjectsAndKeys:
						   numberOfDice, @"numberOfDice",
						   numberOfFacesPerDie, @"numberOfFacesPerDie",
						   roll, @"roll",
						   nil]];
}

- (IBAction) sendCancelToOtherApp;
{
	[self _sendToOtherApp:[NSDictionary dictionaryWithObjectsAndKeys:
						   @"YES", @"canceled",
						   nil]];
}

- (void) _showNagMessagesDisabled {
	UIAlertView* alert = [UIAlertView alertNamed:@"L0DiceshakerNagDisabled"];
	[alert show];
}

- (void)applicationWillTerminate:(UIApplication *)application {	
	NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([dirs count] > 0) {
		NSString* dir = [dirs objectAtIndex:0];
		
		NSMutableArray* a = [NSMutableArray array];
		for (L0Dice* dice in history)
			[a addObject:[dice asDictionary]];
			
		[a writeToFile:[dir stringByAppendingPathComponent:@"History.plist"] atomically:YES];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:[self.currentDice asDictionary] forKey:kL0DiceshakerLastDiceDefault];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)dealloc {
	if (systemSoundAvailable)
		AudioServicesDisposeSystemSoundID(systemSound);
	
	[history release];
	
	[lastRoll release];
	self.window = nil;
	self.mainController = nil;
	self.lastAcceleration = nil;
	self.navigationController = nil;
	[super dealloc];
}

- (void) playRollSound {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:kL0DiceshakerShouldPlaySoundDefault])
		return;
	
	AudioServicesPlayAlertSound(kSystemSoundID_Vibrate); // tweets on iPod touch
	
	if (systemSoundAvailable)
		AudioServicesPlayAlertSound(systemSound);
}

- (IBAction) roll {
	[self playRollSound];
	
	[self willChangeValueForKey:@"lastRoll"];
	[lastRoll release];
	lastRoll = [[self.currentDice rollEachDie] retain];
	[self didChangeValueForKey:@"lastRoll"];
	
	if ([history indexOfObject:self.currentDice] == NSNotFound)
		[[self mutableArrayValueForKey:@"history"] addObject:self.currentDice];
}

- (IBAction) flipToBackSide {
	self.backSideController.view;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:window cache:NO];
	[UIView setAnimationDuration:0.7];
	
	[self.mainController.view removeFromSuperview];
	[window addSubview:self.backSideController.view];
	
	[UIView commitAnimations];
}

- (IBAction) flipToFrontSide {
	self.mainController.view;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:window cache:NO];
	[UIView setAnimationDuration:0.7];
	
	flippingBack = YES;
	[self performSelector:@selector(_resetFlipBack) withObject:nil afterDelay:0.5];
	[self.backSideController.view removeFromSuperview];
	[window addSubview:self.mainController.view];
	
	[UIView commitAnimations];
}

- (void) _resetFlipBack { self.flippingBack = NO; }

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	
	if (self.lastAcceleration) {
		if (!histeresisExcited && L0AccelerationIsShaking(self.lastAcceleration, acceleration, 0.7)) {
			histeresisExcited = YES;
			[self roll];
		} else if (histeresisExcited && !L0AccelerationIsShaking(self.lastAcceleration, acceleration, 0.2)) {
			histeresisExcited = NO;
		}
	}
	
	self.lastAcceleration = acceleration;
}

- (void) eraseRollHistory {
	[[self mutableArrayValueForKey:@"history"] removeAllObjects];
}

- (void) showNagScreenIfNeeded {
	// Infinite Labs Naggin' Policy: (as seen in Afloat 2)
	// should show nag screen if: donate wasn't clicked; and either the screen was never shown and 24 or more hours have elapsed since first launch, or the screen was shown exactly once and 7 or more days have elapsed since then.
	// first nag screen has Maybe Later as default button, second has Donate.
	
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	
	// bail out quickly if we stopped nagging.
	if ([ud boolForKey:kL0DiceshakerDidEndNaggingDefault])
		return;
	
	// have we ever been launched?
	NSDate* firstLaunch = [ud objectForKey:kL0DiceshakerFirstLaunchDateDefault];
	if (!firstLaunch) {
		// mark this as first launch and return.
		firstLaunch = [NSDate date];
		[ud setObject:firstLaunch forKey:kL0DiceshakerFirstLaunchDateDefault];
		[ud synchronize];
		return;
	} else {
		// have we shown the first nag?
		NSDate* firstNag = [ud objectForKey:kL0DiceshakerFirstNagDateDefault];
		if (!firstNag) {
			// have 24 hours passed since the first launch? if so, show the first nag.
			if ([firstLaunch timeIntervalSinceNow] < -(24 * 60 * 60)) {
				firstNag = [NSDate date];
				[ud setObject:firstNag forKey:kL0DiceshakerFirstNagDateDefault];
				[ud synchronize];
				
				[self showFirstNag]; return;
			}
		} else {
			
			// have 7 days passed since the first nag? if so, show the last nag (and mark it as stopped nagging.)
			if ([firstNag timeIntervalSinceNow] < -(7 * 24 * 60 * 60)) {
				[ud setBool:YES forKey:kL0DiceshakerDidEndNaggingDefault];
				[ud synchronize];
				
				[self showLastNag];
				return;
			}
			
		}
	}
}

- (void) showFirstNag {
	UIAlertView* firstNagAlert = [UIAlertView alertNamed:@"L0DiceshakerFirstNag"];
	// buttons: 0 is Donate, 1 is Maybe Later
	firstNagAlert.cancelButtonIndex = 1;
	firstNagAlert.delegate = self;
	[firstNagAlert show];
}

- (void) showLastNag {
	UIAlertView* firstNagAlert = [UIAlertView alertNamed:@"L0DiceshakerLastNag"];
	// buttons: 0 is No, Thanks; 1 is Donate
	firstNagAlert.cancelButtonIndex = 0;
	firstNagAlert.delegate = self;
	[firstNagAlert show];
}

- (void) alertView:(UIAlertView*) alertView clickedButtonAtIndex:(NSInteger) buttonIndex {
	if (alertView.tag == kL0DiceshakerAlertTagUnknownURL) {
		if (buttonIndex != alertView.cancelButtonIndex) {
			NSString* URLString = [[NSBundle mainBundle] objectForInfoDictionaryKey:kL0DiceshakerAppStoreURLKey];
			NSURL* URL = [NSURL URLWithString:URLString];
			[[UIApplication sharedApplication] openURL:URL];
		}
	} else if (buttonIndex != alertView.cancelButtonIndex) {
		[self donate];		
	}
}

- (IBAction) donate {
	// if the user touches Donate we stop nagging him
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kL0DiceshakerDidEndNaggingDefault];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	NSString* donateURLString = [[NSBundle mainBundle] objectForInfoDictionaryKey:kL0DiceshakerDonationsURLKey];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:donateURLString]];
}

@end

@implementation L0Dice (L0DiceshakerSavingAndLoading)

- (NSDictionary*) asDictionary {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithUnsignedInteger:self.numberOfDice], @"numberOfDice",
			[NSNumber numberWithUnsignedInteger:self.numberOfFacesPerDie], @"numberOfFacesPerDie",
			nil];
			
}

+ (id) diceWithDictionary:(NSDictionary*) d {
	NSNumber* dice = [d objectForKey:@"numberOfDice"], * faces = [d objectForKey:@"numberOfFacesPerDie"];
	if (![dice isKindOfClass:[NSNumber class]] || ![faces isKindOfClass:[NSNumber class]])
		return nil;
	
	return [self diceWithNumberOfDice:[dice unsignedIntegerValue] faces:[faces unsignedIntegerValue]];
}

@end
