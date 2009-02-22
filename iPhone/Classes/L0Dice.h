//
//  L0DiceRoll.h
//  Diceshaker
//
//  Created by ∞ on 04/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (L0Dice)

- (long) totalOfDieRoll;

@end



@interface L0Dice : NSObject <NSCopying> {
	NSUInteger numberOfDice;
	NSUInteger numberOfFacesPerDie;
}

@property NSUInteger numberOfDice;
@property NSUInteger numberOfFacesPerDie;

+ diceWithNumberOfDice:(NSUInteger) dice faces:(NSUInteger) faces;

- (long) roll;
- (NSArray*) rollEachDie; // returns a NSArray of NSNumbers, each the result of a rolled die.

@end
