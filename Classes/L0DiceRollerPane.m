//
//  L0DiceRollerPane.m
//  Diceshaker
//
//  Created by ∞ on 04/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "L0DiceRollerPane.h"
#import "DiceshakerAppDelegate.h"
#import "L0Dice.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

@interface L0DiceRollerPane ()

- (void) selectCurrentDice:(BOOL) animated;

@end


@implementation L0DiceRollerPane

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

- (void) viewDidLoad {
	sides = [[NSArray alloc] initWithObjects:
			 [NSNumber numberWithInt:2],
			 [NSNumber numberWithInt:3],
			 [NSNumber numberWithInt:4],
			 [NSNumber numberWithInt:6],
			 [NSNumber numberWithInt:8],
			 [NSNumber numberWithInt:10],
			 [NSNumber numberWithInt:12],
			 [NSNumber numberWithInt:20],
			 [NSNumber numberWithInt:30],
			 [NSNumber numberWithInt:100],
			 nil];
	
	dicePickerHidden = NO;
	
	[controller addObserver:self forKeyPath:@"currentDice" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
	[controller addObserver:self forKeyPath:@"lastRoll" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
	[controller addObserver:self forKeyPath:@"history" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
	
	dicePicker.dataSource = self;
	dicePicker.delegate = self;
	
	historyTable.separatorColor = [UIColor colorWithWhite:0.25 alpha:1.0];
	
	dicePickerHidden = [[NSUserDefaults standardUserDefaults] boolForKey:kL0DiceshakerDrawerHiddenDefault];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[dicePicker release];
	[container release];
	[historyTable release];
	[resultLabel release];
	
	[controller removeObserver:self forKeyPath:@"currentRoll"];
	
	[sides release];
	[super dealloc];
}

- (IBAction) toggleDicePicker {
	dicePickerHidden = !dicePickerHidden;
	[[NSUserDefaults standardUserDefaults] setBool:dicePickerHidden forKey:kL0DiceshakerDrawerHiddenDefault];
	
	[self repositionDicePicker:YES];
}

- (void) repositionDicePicker:(BOOL) ani {
	BOOL prevAnimationsEnabled = [UIView areAnimationsEnabled];
	if (!ani) [UIView setAnimationsEnabled:NO];
	
	if (dicePickerHidden) {
		if (ani) [UIView beginAnimations:nil context:NULL];
		
//			[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.view.window cache:YES];
		if (ani) {
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(_didStopDicePickerHideAnimation:finished:context:)];
		}
		
		CGRect newPickerFrame = dicePicker.frame; newPickerFrame.origin.y += newPickerFrame.size.height;
		dicePicker.frame = newPickerFrame;
		container.frame = self.view.bounds;

		if (ani) [UIView commitAnimations];
		
	} else {

		if (ani) [UIView beginAnimations:nil context:NULL];
			
		
		CGRect newPickerFrame;
		newPickerFrame.size = dicePicker.frame.size;
		newPickerFrame.origin = CGPointMake(0, self.view.frame.size.height);
		dicePicker.frame = newPickerFrame;
		[self.view addSubview:dicePicker];
		
		if (ani) [UIView commitAnimations];
		
		if (ani) [UIView beginAnimations:nil context:NULL];

//			[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view.window cache:YES];
		if (ani) [UIView setAnimationDuration:0.3];			
		
		CGRect newContainerFrame = self.view.bounds;
		newContainerFrame.size.height -= dicePicker.frame.size.height;
		container.frame = newContainerFrame;
		
		newPickerFrame.origin.y -= newPickerFrame.size.height;
		dicePicker.frame = newPickerFrame;
		
		if (ani) [UIView commitAnimations];
	}
	
	if (!ani) [UIView setAnimationsEnabled:prevAnimationsEnabled];
}

- (void) _didStopDicePickerHideAnimation:(NSString*) ani finished:(BOOL) end context:(void*) nothing {
	[dicePicker removeFromSuperview];
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView*) pickerView {
	return 2;
}

- (NSInteger) pickerView:(UIPickerView*) pickerView numberOfRowsInComponent:(NSInteger) component {
	if (component == 0) // number of dice
		return 40;
	else if (component == 1) // number of sides
		return [sides count];
	else
		return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	switch (component) {
		case 0:
			return [NSString stringWithFormat:@"%d", row + 1];

		case 1:
			return [NSString stringWithFormat:@"d%@", [sides objectAtIndex:row]];
			
		default:
			return nil;
	}
	
}

- (void) observeValueForKeyPath:(NSString*) keyPath ofObject:(id) object change:(NSDictionary*)change context:(void*) context {

	if ([keyPath isEqual:@"currentDice"]) {
		bottomBar.topItem.title = [[object currentDice] description];
		[self selectCurrentDice:YES];
	} else if ([keyPath isEqual:@"lastRoll"]) {
		if (controller.lastRoll) {
			resultLabel.text = [NSString stringWithFormat:@"%d", [controller.lastRoll totalOfDieRoll]];
			
			NSMutableString* str = [NSMutableString string];
			BOOL first = YES;
			for (NSNumber* n in controller.lastRoll) {
				if (!first) [str appendString:@" + "];
				[str appendFormat:@"%@", n];
				first = NO;
			}
			eachDieLabel.text = str;
			
			if (controller.history) {
				NSInteger idx = [controller.history indexOfObject:controller.currentDice];
				if (idx != NSNotFound) {
					[historyTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
				}
			}
		} else {
			resultLabel.text = @"0";
			eachDieLabel.text = @"";
		}
		
	} else if ([keyPath isEqual:@"history"])
		[historyTable reloadData];
	
}

- (void) viewWillAppear:(BOOL) ani {
	[historyTable reloadData];
	[self repositionDicePicker:ani && !L0DiceshakerDelegate.flippingBack];
	[self selectCurrentDice:ani];
	
	L0DiceshakerDelegate.flippingBack = NO;
}

- (void) viewDidAppear:(BOOL) ani {
	[historyTable flashScrollIndicators];
}

- (void) selectCurrentDice:(BOOL) ani {
	L0Dice* roll = controller.currentDice;
	[dicePicker selectRow:roll.numberOfDice - 1 inComponent:0 animated:ani];
	[dicePicker selectRow:[sides indexOfObject:[NSNumber numberWithInteger:roll.numberOfFacesPerDie]] inComponent:1 animated:!dicePickerHidden];
}

- (void) pickerView:(UIPickerView*) pickerView didSelectRow:(NSInteger) row inComponent:(NSInteger) component {
	
	L0Dice* d = [[controller.currentDice copy] autorelease];

	if (component == 0)
		d.numberOfDice = row + 1;
	else
		d.numberOfFacesPerDie = [[sides objectAtIndex:row] intValue];
	
	controller.currentDice = d;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	if (component == 0)
		return 44;
	else
		return 70;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [controller.history count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"L0HistoryCell"];
	if (!cell)
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
	
	cell.text = [[controller.history objectAtIndex:[indexPath row]] description];
	cell.textColor = [UIColor whiteColor];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	L0Dice* d = [controller.history objectAtIndex:[indexPath row]];
	controller.currentDice = d;
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[controller roll];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return bottomBar.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, bottomBar.frame.size.height / 2)];
	v.opaque = NO;
	v.backgroundColor = [UIColor clearColor];
	v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	return [v autorelease];
}

@end
