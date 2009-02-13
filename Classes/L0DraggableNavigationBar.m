//
//  L0DraggableNavigationBar.m
//  Diceshaker
//
//  Created by ∞ on 13/02/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L0DraggableNavigationBar.h"


@implementation L0DraggableNavigationBar


- (void) touchesBegan:(NSSet*) touches withEvent:(UIEvent*) event;
{
	UITouch* t = [touches anyObject];
	if ([t view] != self || !self.touchTarget || !self.touchAction) {
		[super touchesBegan:touches withEvent:event];
		return;
	}
	
	NSString* selName = NSStringFromSelector(self.touchAction);
	
	unichar chars[ [selName length] ];
	[selName getCharacters:chars];
	int counted = 0;
	
	int i; for (i = 0; i < [selName length]; i++) {
		if (chars[i] == ':')
			counted++;
	}
	
	switch (counted) {
		case 0:
			[self.touchTarget performSelector:self.touchAction];
			break;
		case 1:
			[self.touchTarget performSelector:self.touchAction withObject:self];
			break;
			
		default:
			[self.touchTarget performSelector:self.touchAction withObject:self withObject:event];
			break;
	}
}

@synthesize touchTarget, touchAction;

@end
