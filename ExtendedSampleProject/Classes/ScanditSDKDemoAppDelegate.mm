//
//  Copyright 2010 Mirasense AG
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import "ScanditSDKDemoAppDelegate.h"
#import "DemoViewController.h"
#import "OtherExamplesViewController.h"
#import "Reachability.h"
#import "AutoRotatingViewController.h"

#import <MessageUI/MessageUI.h>

#import "IASKAppSettingsViewController.h"
#import "IASKSettingsReader.h"

// Enter your Scandit SDK App key here.
// Note: Your app key is available from your Scandit SDK web account.
#define kScanditSDKAppKey    @"--- ENTER YOUR SDK KEY FROM SCANDIT.COM HERE ---"

@implementation ScanditSDKDemoAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize otherExamplesController;
@synthesize tabController;
@synthesize navController;
@synthesize settingsController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	[self registerDefaultsFromSettingsBundle];
	
    // Setup UI
    // Setting up the tab and navigation controller.
    tabController = [[UITabBarController alloc] init];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        viewController = [[DemoViewController alloc] initWithNibName:@"DemoView_iPad" bundle:nil];
    } else {
        viewController = [[DemoViewController alloc] initWithNibName:@"DemoView" bundle:nil];
    }
	viewController.appKey = kScanditSDKAppKey;
    
    UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:@"Main" 
                                                          image:[UIImage imageNamed:@"icon_lists.png"]
                                                            tag:0];
	viewController.tabBarItem = tabItem;
    
    [[navController navigationBar] setBarStyle:UIBarStyleBlack];
	settingsController = [[IASKAppSettingsViewController alloc] init];
    settingsController.showDoneButton = NO;
    UITabBarItem *tabItem1 = [[UITabBarItem alloc] initWithTitle:@"Settings"
                                                           image:[UIImage imageNamed:@"icon_history.png"]
                                                             tag:1];
	
    UINavigationController *settingsNavController = [[UINavigationController alloc]
													 initWithRootViewController:settingsController];
    settingsNavController.tabBarItem = tabItem1;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        otherExamplesController = [[OtherExamplesViewController alloc] initWithNibName:@"OtherExamplesView_iPad" bundle:nil];
    } else {
        otherExamplesController = [[OtherExamplesViewController alloc] initWithNibName:@"OtherExamplesView" bundle:nil];
    }
	otherExamplesController.appKey = kScanditSDKAppKey;
	
    navController = [[UINavigationController alloc] initWithRootViewController:otherExamplesController];
    [[navController navigationBar] setBarStyle:UIBarStyleBlack];
	
    UITabBarItem *tabItem2 = [[UITabBarItem alloc] initWithTitle:@"Other Examples" 
                                                           image:[UIImage imageNamed:@"icon_history.png"]
                                                             tag:2];
    navController.tabBarItem = tabItem2;
    
    NSMutableArray *tabControllers = [[NSMutableArray alloc] init];
    [tabControllers addObject:viewController];
    [tabControllers addObject:settingsNavController];
    [tabControllers addObject:navController];
    [tabController setViewControllers:tabControllers];
    tabController.delegate = self;
    [window setRootViewController:tabController];
    [window makeKeyAndVisible];
	
	[self updateHiddenSettings];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(settingChanged:)
												 name:kIASKAppSettingChanged
											   object:nil];
}

- (void)dealloc {
    self.viewController = nil;
    self.tabController = nil;
    self.navController = nil;
    self.window = nil;
	self.settingsController = nil;
	self.otherExamplesController = nil;
}

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)vController {
	
    [self.viewController tabBarController:tabBarController didSelectViewController:vController];
    [self.otherExamplesController tabBarController:tabBarController didSelectViewController:vController];
}

- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
	
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
	
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

- (void)settingChanged:(NSNotification *)notification {
	NSArray *sliders = [[NSArray alloc] initWithObjects:@"scanningHotSpotX", @"scanningHotSpotY",
						@"scanningHotSpotHeight", @"viewfinderWidth", @"viewfinderHeight",
						@"viewfinderLandscapeWidth", @"viewfinderLandscapeHeight",
						@"torchButtonX", @"torchButtonY", @"cameraSwitchButtonX",
						@"cameraSwitchButtonY", nil];
	if ([sliders containsObject:notification.object]) {
		float value = roundf([notification.userInfo[notification.object] doubleValue] * 100) / 100.0;
		if ([[NSUserDefaults standardUserDefaults] floatForKey:notification.object] != value) {
			[[NSUserDefaults standardUserDefaults] setFloat:value forKey:notification.object];
		}
		[[NSUserDefaults standardUserDefaults] setFloat:value
												 forKey:[NSString stringWithFormat:@"%@Label",
														 notification.object]];
		
	}
	
	NSArray *hideSettings = [[NSArray alloc] initWithObjects:@"msiPlesseyEnabled",
							 @"restrictActiveScanningArea", @"searchBar", @"drawViewfinder",
							 @"torchEnabled", @"cameraSwitchVisibility", @"dataMatrixEnabled", nil];
	if ([hideSettings containsObject:notification.object]) {
		[self updateHiddenSettings];
	}
}

- (void)updateHiddenSettings {
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	NSMutableSet *newHidden = [[NSMutableSet alloc] init];
	if (![settings boolForKey:@"msiPlesseyEnabled"]) {
		[newHidden addObject:@"msiPlesseyChecksum"];
	}
	if (![settings boolForKey:@"dataMatrixEnabled"]) {
		[newHidden addObject:@"microDataMatrixEnabled"];
		[newHidden addObject:@"inverseDetectionEnabled"];
	}
	if (![settings boolForKey:@"restrictActiveScanningArea"]) {
		[newHidden addObject:@"scanningHotSpotHeightLabel"];
		[newHidden addObject:@"scanningHotSpotHeight"];
	}
	if (![settings boolForKey:@"searchBar"]) {
		[newHidden addObject:@"searchBarActionButtonCaption"];
		[newHidden addObject:@"searchBarCancelButtonCaption"];
		[newHidden addObject:@"searchBarPlaceholderText"];
		[newHidden addObject:@"searchBarKeyboardType"];
	}
	if (![settings boolForKey:@"drawViewfinder"]) {
		[newHidden addObject:@"viewfinderWidthLabel"];
		[newHidden addObject:@"viewfinderWidth"];
		[newHidden addObject:@"viewfinderHeightLabel"];
		[newHidden addObject:@"viewfinderHeight"];
		[newHidden addObject:@"viewfinderLandscapeWidthLabel"];
		[newHidden addObject:@"viewfinderLandscapeWidth"];
		[newHidden addObject:@"viewfinderLandscapeHeightLabel"];
		[newHidden addObject:@"viewfinderLandscapeHeight"];
	}
	if (![settings boolForKey:@"torchEnabled"]) {
		[newHidden addObject:@"torchButtonXLabel"];
		[newHidden addObject:@"torchButtonX"];
		[newHidden addObject:@"torchButtonYLabel"];
		[newHidden addObject:@"torchButtonY"];
	}
	if ([settings integerForKey:@"cameraSwitchVisibility"] == 0) {
		[newHidden addObject:@"cameraSwitchButtonXLabel"];
		[newHidden addObject:@"cameraSwitchButtonX"];
		[newHidden addObject:@"cameraSwitchButtonYLabel"];
		[newHidden addObject:@"cameraSwitchButtonY"];
	}
	[settingsController setHiddenKeys:newHidden animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Network Check

- (BOOL)isNetworkAvailable {
	Reachability * reachability = [Reachability reachabilityForInternetConnection];
	if ([reachability currentReachabilityStatus] == NotReachable) {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"No Network"
															message:@"The development version of Scandit requires network access. Connect and try again."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
		return NO;
	}
	return YES;
}


@end
