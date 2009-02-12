//
//  L0DiceshakerNagTester.m
//  Diceshaker
//
//  Created by ∞ on 27/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "L0DiceshakerNagTester.h"

#if DEBUG

@implementation DiceshakerAppDelegate (L0DiceshakerNagTester)

- (void) testFirstNag {
	[self performSelector:@selector(showFirstNag) withObject:nil afterDelay:0.01];
}

- (void) testLastNag {
	[self performSelector:@selector(showLastNag) withObject:nil afterDelay:0.01];
}

- (void) testNagsOff {
	[self performSelector:@selector(_showNagMessagesDisabled) withObject:nil afterDelay:0.01];
}

@end

#endif
