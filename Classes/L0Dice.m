//
//  L0DiceRoll.m
//  Diceshaker
//
//  Created by ∞ on 04/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "L0Dice.h"
#import <stdlib.h>

@implementation L0Dice

@synthesize numberOfDice, numberOfFacesPerDie;

+ diceWithNumberOfDice:(NSUInteger) dice faces:(NSUInteger) faces {
	L0Dice* x = [self new];
	x.numberOfDice = dice;
	x.numberOfFacesPerDie = faces;
	return [x autorelease];
}

- (NSString*) description {
	return [NSString stringWithFormat:@"%dd%d", self.numberOfDice, self.numberOfFacesPerDie];
}

- (id) copyWithZone:(NSZone*) z {
	L0Dice* r = [[[self class] allocWithZone:z] init];
	r.numberOfDice = self.numberOfDice;
	r.numberOfFacesPerDie = self.numberOfFacesPerDie;
	return r;
}

- (BOOL) isEqual:(id) x {
	return [x isKindOfClass:[L0Dice class]] &&
		[x numberOfDice] == self.numberOfDice &&
		[x numberOfFacesPerDie] == self.numberOfFacesPerDie;
}

- (NSUInteger) hash {
	return [[self class] hash] ^ self.numberOfDice ^ self.numberOfFacesPerDie;
}

- (long) roll {
	return [[self rollEachDie] totalOfDieRoll];
}

- (NSArray*) rollEachDie {
	srandomdev();
	
	NSMutableArray* dice = [NSMutableArray array];
	
	for (NSUInteger i = 0; i < self.numberOfDice; i++) {
		double randomVar = random() / (double) LONG_MAX;
		
		long roll = (long) ceil(randomVar * self.numberOfFacesPerDie);
		
		[dice addObject:[NSNumber numberWithLong:roll]];
	}
	
	return dice;
}

@end

@implementation NSArray (L0Dice)

- (long) totalOfDieRoll {
	long i = 0;
	for (NSNumber* n in self)
		i += [n longValue];
	
	return i;
}

@end
