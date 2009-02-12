//
//  NSAlert+L0Alert.h
//  Alerts
//
//  Created by ∞ on 09/11/07.
//  Copyright 2007 Emanuele Vulcano (infinite-labs.net). All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef L0Log
#ifdef DEBUG

#define L0Log(x, args...) NSLog(@"<DEBUG: '%s'>: " x, __func__, args)
#define L0LogS(x) NSLog(@"<DEBUG: '%s'>: " x, __func__)

#else

#define L0Log(x, args...) do { {args;} } while(0)
#define L0LogS(x) do {} while(0)

#endif // DEBUG
#endif // L0Log

extern const NSString* kL0AlertFileExtension;
extern const NSString* kL0AlertInconsistencyException;

extern const NSString* kL0AlertMessage;
extern const NSString* kL0AlertInformativeText;
extern const NSString* kL0AlertButtons;
extern const NSString* kL0AlertShowsSuppressionButton;
extern const NSString* kL0AlertSuppressionButtonTitle;
extern const NSString* kL0AlertHelpAnchor;
extern const NSString* kL0AlertIconName;

@interface UIAlertView (L0Alert)

+ (id) alertNamed:(NSString*) name inBundle:(NSBundle*) bundle directory:(NSString*) directory;
+ (id) alertNamed:(NSString*) name inBundle:(NSBundle*) bundle;
+ (id) alertNamed:(NSString*) name;
+ (id) alertWithContentsOfDictionary:(NSDictionary*) dict name:(NSString*) name bundle:(NSBundle*) bundle;

- (void) setTitleFormat:(id) setMeToNil,...;
- (void) setMessageFormat:(id) setMeToNil,...;

@end
