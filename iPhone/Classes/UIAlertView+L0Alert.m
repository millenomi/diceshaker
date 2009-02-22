//
//  NSAlert+L0Alert.m
//  Alerts
//
//  Created by ∞ on 09/11/07.
//  Copyright 2007 Emanuele Vulcano (infinite-labs.net). All rights reserved.
//

#import "UIAlertView+L0Alert.h"
#import <stdarg.h>

const NSString* kL0AlertFileExtension = @"alert";
const NSString* kL0AlertInconsistencyException = @"L0AlertInconsistencyException";

const NSString* kL0AlertMessage = @"L0AlertMessage";
const NSString* kL0AlertInformativeText = @"L0AlertInformativeText";
const NSString* kL0AlertButtons = @"L0AlertButtons";
const NSString* kL0AlertShowsSuppressionButton = @"L0AlertShowsSuppressionButton";
const NSString* kL0AlertSuppressionButtonTitle = @"L0AlertSuppressionButtonTitle";
const NSString* kL0AlertHelpAnchor = @"L0AlertHelpAnchor";
const NSString* kL0AlertIconName = @"L0AlertIconName";

#import <stdarg.h>

@implementation UIAlertView (L0Alert)

+ (id) alertWithContentsOfDictionary:(NSDictionary*) dict name:(NSString*) name bundle:(NSBundle*) bundle {
	
	L0Log(@"%@, %@, %@", name, bundle, dict);
	
	NSArray* buttons = [dict objectForKey:kL0AlertButtons];
	if (buttons && ![buttons isKindOfClass:[NSArray class]])
		[NSException raise:(NSString*) kL0AlertInconsistencyException format:@"Alert dictionary unreadable: %@", dict];
	
	UIAlertView* alert = [[[UIAlertView alloc] initWithFrame:CGRectZero] autorelease];
	NSString* messageText = [[dict objectForKey:kL0AlertMessage] description];
	if (bundle) messageText = [bundle localizedStringForKey:messageText value:messageText table:name];
	alert.title = messageText;
	
	
	NSString* informativeText = [[dict objectForKey:kL0AlertInformativeText] description];
	if (bundle) informativeText = [bundle localizedStringForKey:informativeText value:informativeText table:name];
	alert.message = informativeText;
	
	NSEnumerator* enu = [buttons objectEnumerator];
	NSString* button;
	while (button = [enu nextObject]) {
		if (bundle) button = [bundle localizedStringForKey:button value:button table:name];
		[alert addButtonWithTitle:button];
	}

	return alert;
}

+ (id) alertNamed:(NSString*) name inBundle:(NSBundle*) bundle directory:(NSString*) directory {
	NSString* path = [bundle pathForResource:name ofType:(NSString*) kL0AlertFileExtension inDirectory:directory];
	
	if (!path)
		[NSException raise:(NSString*) kL0AlertInconsistencyException format:@"Can't find alert named '%@' in bundle '%@', directory '%@'", name, bundle, directory];
	
	NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
	if (!dict)
		[NSException raise:(NSString*) kL0AlertInconsistencyException format:@"Alert file unreadable for alert named named '%@' in bundle '%@', directory '%@'", name, bundle, directory];
	
	return [self alertWithContentsOfDictionary:dict name:name bundle:bundle];
}

+ (id) alertNamed:(NSString*) name inBundle:(NSBundle*) bundle {
	return [self alertNamed:name inBundle:bundle directory:nil];
}

+ (id) alertNamed:(NSString*) name {
	return [self alertNamed:name inBundle:[NSBundle mainBundle]];
}

- (void) setTitleFormat:(id) setMeToNil,... {
	va_list arguments;
	va_start(arguments, setMeToNil);
	NSString* str = [[NSString alloc] initWithFormat:self.title arguments:arguments];
	va_end(arguments);
	self.title = [str autorelease];
}

- (void) setMessageFormat:(id) setMeToNil,... {
	va_list arguments;
	va_start(arguments, setMeToNil);
	NSString* str = [[NSString alloc] initWithFormat:self.message arguments:arguments];
	va_end(arguments);
	self.message = [str autorelease];
}

// -- -- -- -- -- -- -- --

@end
