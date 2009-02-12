//
//  L0AboutPane.m
//  Diceshaker
//
//  Created by ∞ on 04/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "L0AboutPane.h"
#import "DiceshakerAppDelegate.h"

@implementation L0AboutPane

@synthesize versionLabel, soundSwitch;

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

- (void) viewWillAppear:(BOOL) ani {
	self.soundSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kL0DiceshakerShouldPlaySoundDefault];
}

- (void) viewDidLoad {
	self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	
	versionLabel.text = [NSString stringWithFormat:versionLabel.text, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
	if ([[UIDevice currentDevice].model rangeOfString:@"iPhone" options:NSCaseInsensitiveSearch].location != NSNotFound)
		soundSwitchLabel.text = NSLocalizedString(@"Sound & Vibration", @"Sound switch label on iPhone");
	else
		soundSwitchLabel.text = NSLocalizedString(@"Sound", @"Sound switch label on iPod (without 'vibration')");
}

- (IBAction) soundSwitchChanged {
	[[NSUserDefaults standardUserDefaults] setBool:self.soundSwitch.on forKey:kL0DiceshakerShouldPlaySoundDefault];
}

- (IBAction) goToInfiniteLabsDotNet {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://infinite-labs.net/"]];
}

- (IBAction) eraseRollHistory {
	UIActionSheet* sheet = [[[UIActionSheet alloc]
							 initWithTitle:nil
							 delegate:self
							 cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button title")
							 destructiveButtonTitle:NSLocalizedString(@"Erase", @"Erase button title")
							 otherButtonTitles:nil]
							autorelease];
	[sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.destructiveButtonIndex == buttonIndex) { // erase
		DiceshakerAppDelegate* delegate = (DiceshakerAppDelegate*) [[UIApplication sharedApplication] delegate];
		[delegate eraseRollHistory];
	}
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
	[super dealloc];
}


@end
