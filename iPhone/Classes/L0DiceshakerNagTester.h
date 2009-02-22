//
//  L0DiceshakerNagTester.h
//  Diceshaker
//
//  Created by ∞ on 27/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiceshakerAppDelegate.h"

#if DEBUG

@interface DiceshakerAppDelegate (L0DiceshakerNagTester)

- (void) testFirstNag;
- (void) testLastNag;
- (void) testNagsOff;

@end

#endif
