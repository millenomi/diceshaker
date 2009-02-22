//
//  DiceshakerAppDelegate.h
//  Diceshaker
//
//  Created by ∞ on 04/08/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "L0Dice.h"

#import <AudioToolbox/AudioToolbox.h>

#define kL0CurrentDiceRollDidChangeNotification @"L0CurrentDiceRollDidChange"
#define kL0DiceshakerShouldPlaySoundDefault @"L0DiceshakerShouldPlaySoundDefault"
#define kL0DiceshakerDrawerHiddenDefault @"L0DiceshakerDrawerHiddenDefault"
#define kL0DiceshakerLastDiceDefault @"L0DiceshakerLastDiceDefault"

#define kL0DiceshakerFirstLaunchDateDefault @"L0DiceshakerFirstLaunchDate"
#define kL0DiceshakerFirstNagDateDefault @"L0DiceshakerFirstNagDate"
#define kL0DiceshakerDidEndNaggingDefault @"L0DiceshakerDidEndNagging"
#define kL0DiceshakerDonationsURLKey @"L0DiceshakerDonationsURL"

enum {
	kL0DiceshakerAlertTagUnknownURL = 1001,
};
#define kL0DiceshakerAppStoreURLKey @"L0DiceshakerAppStoreURL"

@class DiceshakerViewController;

@interface DiceshakerAppDelegate : NSObject <UIApplicationDelegate, UIAccelerometerDelegate, UIAlertViewDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UIViewController* mainController;
	IBOutlet UIViewController* backSideController;
	
	IBOutlet UINavigationController* navigationController;
	
	L0Dice* currentDice;
	NSArray* lastRoll;
	
	NSMutableArray* history;
	
	BOOL histeresisExcited;
	UIAcceleration* lastAcceleration;
	
	BOOL flippingBack;
	
	BOOL systemSoundAvailable;
	SystemSoundID systemSound;
	
	BOOL handledCrossAppURL;
	NSURL* returnCrossAppURL;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UIViewController* mainController;
@property (nonatomic, retain) UINavigationController* navigationController;
@property (nonatomic, retain) UIViewController* backSideController;
@property (nonatomic, retain) L0Dice* currentDice;

@property (readonly) NSMutableArray* history;
@property (readonly) NSArray* lastRoll;

@property (assign) BOOL flippingBack;

@property(retain) UIAcceleration* lastAcceleration;

- (IBAction) roll;
- (void) playRollSound;
- (IBAction) flipToBackSide;
- (IBAction) flipToFrontSide;

- (void) eraseRollHistory;

- (void) showNagScreenIfNeeded;
- (void) showFirstNag;
- (void) showLastNag;

- (IBAction) donate;

- (IBAction) sendToOtherApp;
- (IBAction) sendCancelToOtherApp;

@end

@interface L0Dice (L0DiceshakerSavingAndLoading)

- (NSDictionary*) asDictionary;
+ (id) diceWithDictionary:(NSDictionary*) d;

@end
