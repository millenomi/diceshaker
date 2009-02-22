//
//  L0AboutPane.h
//  Diceshaker
//
//  Created by ∞ on 04/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface L0AboutPane : UIViewController <UIActionSheetDelegate> {
	IBOutlet UILabel* versionLabel;
	IBOutlet UILabel* soundSwitchLabel;
	IBOutlet UISwitch* soundSwitch;
}

@property(assign) UILabel* versionLabel;
@property(assign) UISwitch* soundSwitch;

- (IBAction) goToInfiniteLabsDotNet;
- (IBAction) soundSwitchChanged;

- (IBAction) eraseRollHistory;

@end
