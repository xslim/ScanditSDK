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
//
//  DemoViewController shows how to use the Mirasense Scandit SDK. 
//
//  Any view controller that triggers the ScanditSDK barcode scanning, needs to instantiate the
//  ScanditSDKBarcodePicker. The picker is a UIViewController and can therefor be used like any 
//  other view controller. It can be shown modally, directly as the starting view, in a tab bar
//  controller, pushed on a navigation controller etc. The class that wants to listen to the 
//  picker's events needs to implement the ScanditSDKOverlayControllerDelegate protocol. 
//  Examples for the most common usage scenarios are shown below.
//


#import "DemoViewController.h"
#import "ScanditSDKBarcodePicker.h"
#import "ScanditSDKDemoAppDelegate.h"
#import "ScanditSDKRotatingBarcodePicker.h"
#import <UIKit/UIKit.h>


@implementation DemoViewController

@synthesize appKey;
@synthesize scanditSDKBarcodePicker;
@synthesize frozenLabel;
@synthesize tapRecognizer;


- (void)viewDidLoad {
    // Prepare the picker such that it can be loaded faster
    [ScanditSDKBarcodePicker prepareWithAppKey:self.appKey
                        cameraFacingPreference:CAMERA_FACING_BACK];
}

- (void)viewWillAppear:(BOOL)animated {
    // Location tracking to demonstrate Scandit's Scanalytics feature (optional)
	// Scandit SDK will only gather the location if the user already allowed
	// the app using the SDK to gather it.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    [super viewWillAppear:animated];
}

- (void)dealloc {
	self.appKey = nil;
	self.scanditSDKBarcodePicker = nil;
	
	self.frozenLabel = nil;
    self.tapRecognizer = nil;
}


#pragma -
#pragma Methods for Auto Rotation
/**
 * The methods below are only needed to have the picker (when used as an overlay in a simple view)
 * rotate with the screen and change its dimensions accordingly. If the app
 * is solely used in portrait mode, these methods can be ignored.
 * If you use a tab layout, check out the 'tab' example. It shows how to make the ScanditSDKBarcodePicker
 * rotate itself.
 */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    // We allow rotation in any direction to be able to show how the overlayed picker acts.
    return YES;
}


#pragma mark -
#pragma mark Showing the ScanditSDKBarcodePicker in a UITabBarController
//! [ScanditSDKBarcodePicker in its own tab]
/**
 * This is a simple example of how one can start the ScanditSDKBarcodePicker in its own tab.
 */
- (IBAction)showScanViewInTab {
	// Instantiate the barcode picker. We are using the ScanditSDKRotatingBarcodePicker which
	// inherits from the ScanditSDKBarcodePicker to be able to adjust the position of the
	// UI elements depending on the orientation of the picker.
	// To change the allowed orientations you will have to set those in the TabBarController
	// (which contains the picker as a tab) for iOS 6.0+. For previous iOS versions it needs
	// to be allowed in the willRotateToInterfaceOrientation:duration: function in the
	// ScanditSDKRotatingBarcodePicker class.
	self.scanditSDKBarcodePicker = [[ScanditSDKRotatingBarcodePicker alloc]
									 initWithAppKey:self.appKey
									 cameraFacingPreference:CAMERA_FACING_BACK];

	// Set all the settings as they were set in the settings tab.
    [self setAllSettingsOnPicker:scanditSDKBarcodePicker];
	
	// Set the delegate to receive callbacks.
	scanditSDKBarcodePicker.overlayController.delegate = self;
    //[scanditSDKBarcodePicker.overlayController setSearchBarKeyboardType:UIKeyboardTypeAlphabet];
    // Create a tab item for the picker, possibly with an icon.
    UITabBarItem *tabItem = [[UITabBarItem alloc] initWithTitle:@"Scan" 
                                                          image:[UIImage imageNamed:@"icon_barcode.png"]
                                                            tag:3];
    self.scanditSDKBarcodePicker.tabBarItem = tabItem;
	
    // Add the picker to the array of view controllers that make up the tabs.
    NSMutableArray *tabControllers = (NSMutableArray *) [[self tabBarController] viewControllers];
    [tabControllers addObject:self.scanditSDKBarcodePicker];
    // And set the array as the tab bar controllers source of tabs again.
    [[self tabBarController] setViewControllers:tabControllers];
    
    // Switch to the second tab, where the picker is located and start scanning.
    [[self tabBarController] setSelectedIndex:3];
	[self.scanditSDKBarcodePicker startScanning];
}
//! [ScanditSDKBarcodePicker in its own tab]


- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController {
	
    if (tabBarController.selectedIndex != 3) {
        // We close the scan tab whenever the user goes bto any other tab because we can at no point
		// have two pickers up at once (as only one camera instance can run).
        NSMutableArray *tabControllers = (NSMutableArray *) tabBarController.viewControllers;
        if ([tabControllers count] > 3) {
            [tabControllers removeLastObject];
            self.scanditSDKBarcodePicker = nil;
            tabBarController.viewControllers = tabControllers;
        }
    }
}

- (void)setAllSettingsOnPicker:(ScanditSDKBarcodePicker *)picker {
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	
	if ([settings boolForKey:@"disableStandbyState"]) {
		[picker disableStandbyState];
	}
	
	[picker setEan13AndUpc12Enabled:[settings boolForKey:@"ean13AndUpc12Enabled"]];
	[picker setEan8Enabled:[settings boolForKey:@"ean8Enabled"]];
	[picker setUpceEnabled:[settings boolForKey:@"upceEnabled"]];
	[picker setCode39Enabled:[settings boolForKey:@"code39Enabled"]];
	[picker setCode128Enabled:[settings boolForKey:@"code128Enabled"]];
	[picker setMsiPlesseyEnabled:[settings boolForKey:@"msiPlesseyEnabled"]];
    [picker setItfEnabled:[settings boolForKey:@"itfEnabled"]];
	
	int checksum = [settings integerForKey:@"msiPlesseyChecksum"];
	MsiPlesseyChecksumType checksumType = CHECKSUM_MOD_10;
	if (checksum == 0) {
		checksumType = NONE;
	} else if (checksum == 2) {
		checksumType = CHECKSUM_MOD_11;
	} else if (checksum == 3) {
		checksumType = CHECKSUM_MOD_1010;
	} else if (checksum == 4) {
		checksumType = CHECKSUM_MOD_1110;
	}
	[picker setMsiPlesseyChecksumType:checksumType];
    
    [picker setGS1DataBarEnabled:[settings boolForKey:@"dataBarEnabled"]];
    [picker setGS1DataBarExpandedEnabled:[settings boolForKey:@"dataBarExpandedEnabled"]];
	
	[picker setQrEnabled:[settings boolForKey:@"qrEnabled"]];
	[picker setDataMatrixEnabled:[settings boolForKey:@"dataMatrixEnabled"]];
	if ([settings boolForKey:@"dataMatrixEnabled"]) {
		[picker setMicroDataMatrixEnabled:[settings boolForKey:@"microDataMatrixEnabled"]];
		[picker setInverseDetectionEnabled:[settings boolForKey:@"inverseDetectionEnabled"]];
	}
	[picker setPdf417Enabled:[settings boolForKey:@"pdf417Enabled"]];
	
	[picker restrictActiveScanningArea:[settings boolForKey:@"restrictActiveScanningArea"]];
	[picker setScanningHotSpotToX:[settings floatForKey:@"scanningHotSpotX"]
							 andY:[settings floatForKey:@"scanningHotSpotY"]];
	[picker setScanningHotSpotHeight:[settings floatForKey:@"scanningHotSpotHeight"]];
	
	[picker.overlayController drawViewfinder:[settings boolForKey:@"drawViewfinder"]];
	[picker.overlayController setViewfinderHeight:[settings floatForKey:@"viewfinderHeight"]
											width:[settings floatForKey:@"viewfinderWidth"]
								  landscapeHeight:[settings floatForKey:@"viewfinderLandscapeHeight"]
								   landscapeWidth:[settings floatForKey:@"viewfinderLandscapeWidth"]];
	
	[picker.overlayController setBeepEnabled:[settings boolForKey:@"beepEnabled"]];
	[picker.overlayController setVibrateEnabled:[settings boolForKey:@"vibrateEnabled"]];
	
	[picker.overlayController showSearchBar:[settings boolForKey:@"searchBar"]];
	[picker.overlayController setSearchBarActionButtonCaption:
	 	[settings stringForKey:@"searchBarActionButtonCaption"]];
	[picker.overlayController setSearchBarPlaceholderText:
	 	[settings stringForKey:@"searchBarPlaceholderText"]];
	
	int keyboard = [settings integerForKey:@"searchBarKeyboardType"];
	UIKeyboardType keyboardType = UIKeyboardTypeNumberPad;
	if (keyboard == 1) {
		keyboardType = UIKeyboardTypeDecimalPad;
	} else if (keyboard == 2) {
		keyboardType = UIKeyboardTypeAlphabet;
	} else if (keyboard == 3) {
		keyboardType = UIKeyboardTypeURL;
	}
	[picker.overlayController setSearchBarKeyboardType:keyboardType];
	
	[picker.overlayController setTorchEnabled:[settings boolForKey:@"torchEnabled"]];
	[picker.overlayController setTorchButtonRelativeX:[settings floatForKey:@"torchButtonX"]
											relativeY:[settings floatForKey:@"torchButtonY"]
												width:67
											   height:33];
	
	CameraSwitchVisibility cameraSwitchVisibility = CAMERA_SWITCH_NEVER;
	if ([settings integerForKey:@"cameraSwitchVisibility"] == 1) {
		cameraSwitchVisibility = CAMERA_SWITCH_ON_TABLET;
	} else if ([settings integerForKey:@"cameraSwitchVisibility"] == 2) {
		cameraSwitchVisibility = CAMERA_SWITCH_ALWAYS;
	}
	[picker.overlayController setCameraSwitchVisibility:cameraSwitchVisibility];
	[picker.overlayController
	 	setCameraSwitchButtonRelativeInverseX:[settings floatForKey:@"cameraSwitchButtonX"]
	 	relativeY:[settings floatForKey:@"cameraSwitchButtonY"]
	 	width:67
	 	height:33];
}
	

#pragma mark -
#pragma mark ScanditSDKOverlayControllerDelegate methods

/**
 * This delegate method of the ScanditSDKOverlayController protocol needs to be implemented by 
 * every app that uses the ScanditSDK and this is where the custom application logic goes.
 * In the example below, we are just showing an alert view that asks the user whether he 
 * wants to continue scanning.
 */
- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)scanditSDKOverlayController1 
                     didScanBarcode:(NSDictionary *)barcodeResult {

	[self.scanditSDKBarcodePicker stopScanning];
	
	if (barcodeResult == nil) return;

    NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:barcodeResult];
    // Slightly delaying the frozen overlay to show the indicator around the barcode.
    [self performSelector:@selector(showFrozenLabel:) withObject:dic afterDelay:0.1];
}


- (void)showFrozenLabel:(NSDictionary *)barcodeResult {
    NSString *symbology = [barcodeResult objectForKey:@"symbology"];
	NSString *barcode = [barcodeResult objectForKey:@"barcode"];
	NSString *title = [NSString stringWithFormat:@"Scanned %@ code: %@", symbology, barcode];
    
    // Hide any frozen label that is still
    [self hideFrozenLabel];
    UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                         self.scanditSDKBarcodePicker.view.bounds.size.width,
                         self.scanditSDKBarcodePicker.view.bounds.size.height)];
    self.frozenLabel = tmpLabel;
    self.frozenLabel.text = [NSString stringWithFormat:@"%@\n\n\nTap to continue", title];
    self.frozenLabel.numberOfLines = 8;
    self.frozenLabel.textColor = [UIColor whiteColor];
    self.frozenLabel.font = [UIFont systemFontOfSize:25];
    self.frozenLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.frozenLabel.textAlignment = NSTextAlignmentCenter;
    self.frozenLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.frozenLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    self.frozenLabel.isAccessibilityElement = YES;
    self.frozenLabel.accessibilityIdentifier = @"scan_result";
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hideFrozenLabelAndStart)];
    self.tapRecognizer = tap;
    [self.scanditSDKBarcodePicker.view addGestureRecognizer:self.tapRecognizer];
    [self.scanditSDKBarcodePicker.overlayController.view addSubview:self.frozenLabel];
}

- (void)hideFrozenLabel {
    if (self.scanditSDKBarcodePicker && self.frozenLabel) {
        // If the picker exist, we remove the view before releasing it and also remove the tap
        // recognizer.
        [self.frozenLabel removeFromSuperview];
        self.frozenLabel = nil;
        [self.scanditSDKBarcodePicker.view removeGestureRecognizer:self.tapRecognizer];
		self.tapRecognizer = nil;
    } else {
        self.frozenLabel = nil;
    }
}

- (void)hideFrozenLabelAndStart {
	[self hideFrozenLabel];
	[self.scanditSDKBarcodePicker performSelector:@selector(startScanning)
									   withObject:nil
									   afterDelay:0.01];
}

/**
 * This delegate method of the ScanditSDKOverlayController protocol needs to be implemented by 
 * every app that uses the ScanditSDK and this is where the custom application logic goes.
 * In the example below, we are just showing an alert view that asks the user whether he 
 * wants to continue scanning.
 */
- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)scanditSDKOverlayController1 
                didCancelWithStatus:(NSDictionary *)status {
	[[self tabBarController] setSelectedIndex:0];
}

/**
 * This delegate method of the ScanditSDKOverlayController protocol needs to be implemented by 
 * every app that uses the ScanditSDK and this is where the custom application logic goes.
 * In the example below, we are just showing an alert view that asks the user whether he 
 * wants to continue scanning.
 */
- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)scanditSDKOverlayController 
                    didManualSearch:(NSString *)input {
	
    [self.scanditSDKBarcodePicker.overlayController resetUI];
	// Stop the scanning process:
	[self.scanditSDKBarcodePicker stopScanningAndKeepTorchState];
	
	NSString *title = [NSString stringWithFormat:@"User entered: %@", input];
    
    // Hide any frozen label that is still
    [self hideFrozenLabel];
    UILabel *tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                         scanditSDKBarcodePicker.view.bounds.size.width,
                         scanditSDKBarcodePicker.view.bounds.size.height)];
    self.frozenLabel = tmpLabel;
    self.frozenLabel.text = [NSString stringWithFormat:@"%@\n\n\nTap to continue", title];
    self.frozenLabel.numberOfLines = 8;
    self.frozenLabel.textColor = [UIColor whiteColor];
    self.frozenLabel.font = [UIFont systemFontOfSize:25];
    self.frozenLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.frozenLabel.textAlignment = NSTextAlignmentCenter;
    self.frozenLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(hideFrozenLabelAndStart)];
    self.tapRecognizer = tap;
    [self.scanditSDKBarcodePicker.view addGestureRecognizer:self.tapRecognizer];
    [self.scanditSDKBarcodePicker.overlayController.view addSubview:self.frozenLabel];
}


#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {
	[manager stopUpdatingLocation];
}

@end
