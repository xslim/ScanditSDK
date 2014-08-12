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


#import "OtherExamplesViewController.h"
#import "ScanditSDKBarcodePicker.h"
#import "ScanditSDKDemoAppDelegate.h"
#import "ScanditSDKRotatingBarcodePicker.h"
#import <UIKit/UIKit.h>


@implementation OtherExamplesViewController

@synthesize appKey;
@synthesize scanditSDKBarcodePicker;
@synthesize pickerSubviewButton;
@synthesize frozenLabel;
@synthesize tapRecognizer;
@synthesize modalStartAnimationDone;
@synthesize modalBufferedResult;


- (void)viewDidLoad {
    scaledSubviewActive = NO;
    
    self.modalStartAnimationDone = NO;
    self.modalBufferedResult = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
	if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
		[self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
	}
    
    [super viewWillAppear:animated];
}

- (void)dealloc {
	self.appKey = nil;
	self.scanditSDKBarcodePicker = nil;
	
	self.pickerSubviewButton = nil;
	
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    // Update the UI such that it fits the new dimension.
    [self adjustPickerToOrientation:toInterfaceOrientation];
}

/**
 * Makes different buttons visible for picker previews. Adjusts the overlaying picker's video
 * preview orientation and changes its dimensions to fit the screen in it's current orientation.
 */
- (void)adjustPickerToOrientation:(UIInterfaceOrientation)orientation {
    
    if (self.pickerSubviewButton && self.scanditSDKBarcodePicker) {
        // Adjust the picker's frame, bounds and the offset of the info banner to fit the new dimensions.
        CGRect screen = [[UIScreen mainScreen] bounds];
        CGRect subviewRect;
        if (orientation == UIInterfaceOrientationLandscapeLeft
            	|| orientation == UIInterfaceOrientationLandscapeRight) {
            if (scaledSubviewActive) {
                subviewRect = CGRectMake(0, 0, 2 * screen.size.height / 3, 2 * screen.size.width / 3);
                self.scanditSDKBarcodePicker.size = subviewRect.size;
                
            } else {
                subviewRect = CGRectMake(40, screen.size.width / 12, screen.size.height - 80,
                                         3 * screen.size.width / 4);
                self.scanditSDKBarcodePicker.size = CGSizeMake(screen.size.height, screen.size.width);
            }
            self.pickerSubviewButton.frame = CGRectMake(0, 0, screen.size.height, screen.size.width);
            
        } else {
            if (scaledSubviewActive) {
                subviewRect = CGRectMake(0, 0, 2 * screen.size.width / 3, 2 * screen.size.height / 3);
                self.scanditSDKBarcodePicker.size = subviewRect.size;
                
            } else {
                subviewRect = CGRectMake(0, screen.size.height / 6 + 20, screen.size.width,
                                         2 * screen.size.height / 3);
                self.scanditSDKBarcodePicker.size = CGSizeMake(screen.size.width, screen.size.height);
            }
            self.pickerSubviewButton.frame = CGRectMake(0, 0, screen.size.width, screen.size.height);
        }
        
        if (scaledSubviewActive) {
            // If the status bar is visible we have to move the subviews content up 20 pixels because
            // the preview automatically gives the status bar room.
            self.scanditSDKBarcodePicker.view.bounds = CGRectMake(0, 0, subviewRect.size.width,
                 	                                              subviewRect.size.height);
            self.scanditSDKBarcodePicker.view.frame = CGRectMake(subviewRect.size.width / 4, 50,
                 	                                             subviewRect.size.width,
                      	                                         subviewRect.size.height);
        } else {
            self.scanditSDKBarcodePicker.view.bounds = subviewRect;
            self.scanditSDKBarcodePicker.view.frame = subviewRect;
        }
    }
	if (self.scanditSDKBarcodePicker != nil) {
        if (orientation == UIInterfaceOrientationLandscapeLeft
				|| orientation == UIInterfaceOrientationLandscapeRight) {
			[self.scanditSDKBarcodePicker setScanningHotSpotToX:0.5 andY:0.4];
		} else {
			[self.scanditSDKBarcodePicker setScanningHotSpotToX:0.5 andY:0.5];
		}
	}
}


#pragma mark -
#pragma mark Showing the ScanditSDKBarcodePicker overlayed as a view
//! [ScanditSDKBarcodePicker overlayed as a view]
/**
 * A simple example of how the barcode picker can be used in a simple view of various dimensions
 * and how it can be added to any other view.
 */
- (IBAction)overlayAsView {
    self.scanditSDKBarcodePicker = [[ScanditSDKBarcodePicker alloc]
									initWithAppKey:self.appKey];
    
    // Customize the scan ui by removing the torch icon from this view
    [self.scanditSDKBarcodePicker.overlayController setTorchEnabled:NO];
    
    // Add a button behind the subview to close the barcode picker view.
    self.pickerSubviewButton = [[UIButton alloc] init];
    [self.pickerSubviewButton addTarget:self
								 action:@selector(closePickerSubview)
					   forControlEvents:UIControlEventTouchUpInside];
    
    // add the button and the picker as a subview
    [self.view addSubview:self.pickerSubviewButton];
    [self.view addSubview:self.scanditSDKBarcodePicker.view];
    
    // Update the UI such that it fits the new dimension.
    [self adjustPickerToOrientation:self.interfaceOrientation];
    
    // Set the delegate to receive callbacks.
    // This is commented out here in the demo app since the result view with the scan results
    // is not suitable for this overlay view
	
    // self.scanditSDKBarcodePicker.overlayController.delegate = self;
    
	[self.scanditSDKBarcodePicker startScanning];
}
//! [ScanditSDKBarcodePicker overlayed as a view]

/**
 * A simple example of how the barcode picker can be used in a simple view of various dimensions
 * and how it can be added to any other view. This example scales the view instead of cropping it.
 */
- (IBAction)overlayAsScaledView {
    self.scanditSDKBarcodePicker = [[ScanditSDKBarcodePicker alloc]
									initWithAppKey:self.appKey];
    
    // Add a button behind the subview to close it.
    self.pickerSubviewButton = [[UIButton alloc] init];
    [self.pickerSubviewButton addTarget:self
          	                     action:@selector(closePickerSubview)
               		   forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.pickerSubviewButton];
    [self.view addSubview:self.scanditSDKBarcodePicker.view];
    scaledSubviewActive = YES;
    
    // Update the UI such that it fits the new dimension.
    [self adjustPickerToOrientation:self.interfaceOrientation];
    
    // Set the delegate to receive callbacks.
    // This is commented out here in the demo app since the result view with the scan results
    // is not suitable for this overlay view
	
    // self.scanditSDKBarcodePicker.overlayController.delegate = self;
    
	[self.scanditSDKBarcodePicker startScanning];
}

- (void)closePickerSubview {
    if (self.scanditSDKBarcodePicker) {
        [self.scanditSDKBarcodePicker.view removeFromSuperview];
        self.scanditSDKBarcodePicker = nil;
    }
	if (self.pickerSubviewButton) {
		[self.pickerSubviewButton removeFromSuperview];
		self.pickerSubviewButton = nil;
	}
    
    scaledSubviewActive = NO;
}


#pragma mark -
#pragma mark Showing the ScanditSDKBarcodePicker as a modal UIViewController
//! [ScanditSDKBarcodePicker as a modal view]
/**
 * Configures and triggers ScanditSDK Scan View by presenting it modally
 */
- (IBAction)modallyShowScanView {
	self.scanditSDKBarcodePicker = [[ScanditSDKRotatingBarcodePicker alloc]
									initWithAppKey:self.appKey];
	
	// Always show a toolbar (with cancel button) so we can navigate out of the scan view.
	[self.scanditSDKBarcodePicker.overlayController showToolBar:YES];
    
    // Customize the scan UI by adding a search bar
    [self.scanditSDKBarcodePicker.overlayController showSearchBar:YES];
	
	// Show a button to switch the camera from back to front and vice versa but only when using
	// a tablet.
	[self.scanditSDKBarcodePicker.overlayController setCameraSwitchVisibility:CAMERA_SWITCH_ON_TABLET];
    
	// Set the delegate to receive callbacks.
	self.scanditSDKBarcodePicker.overlayController.delegate = self;
	
	// Present the barcode picker modally and start scanning. We buffer the result if the code was
    // already recognized while the modal view is still animating.
    self.modalStartAnimationDone = NO;
	if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
		[self presentViewController:scanditSDKBarcodePicker animated:YES completion:^{
			self.modalStartAnimationDone = YES;
			if (self.modalBufferedResult != nil) {
				[self performSelector:@selector(returnBuffer) withObject:nil afterDelay:0.01];
			}
		}];
	} else {
		[self presentModalViewController:scanditSDKBarcodePicker animated:NO];
		self.modalStartAnimationDone = YES;
	}
	
	[scanditSDKBarcodePicker performSelector:@selector(startScanning) withObject:nil afterDelay:0.1];
}
//! [ScanditSDKBarcodePicker as a modal view]

- (void)returnBuffer {
	if (self.modalBufferedResult != nil) {
		[self scanditSDKOverlayController:scanditSDKBarcodePicker.overlayController
						   didScanBarcode:self.modalBufferedResult];
		self.modalBufferedResult = nil;
	}
}

#pragma mark -
#pragma mark Showing the ScanditSDKBarcodePicker in a UINavigationController
//! [ScanditSDKBarcodePicker in a navigation controller]
/**
 * This is a simple example of how one can push the ScanditSDKBarcodePicker in a navigation controller.
 */
- (IBAction)showScanViewInNav {
	// We allocate a picker without keeping a reference and don't set a delegate. The picker will
	// simply track barcodes that have been recognized.
    ScanditSDKBarcodePicker *barcodePicker = [[ScanditSDKBarcodePicker alloc]
											  initWithAppKey:self.appKey];
	
	// Shift the hot spot upwards since there are a lot of UI elements at the top.
    if ([self isMinOSVersion:@"7.0"]) {
        [barcodePicker setScanningHotSpotToX:0.5 andY:0.5];
    } else {
        [barcodePicker setScanningHotSpotToX:0.5 andY:0.35];
	}
    
	// Show the navigation bar such that we can press the back button.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Show a button to switch the camera from back to front and vice versa but only when using
	// a tablet.
	[self.scanditSDKBarcodePicker.overlayController setCameraSwitchVisibility:CAMERA_SWITCH_ON_TABLET];
	
    // Set the delegate to receive callbacks.
    // This is commented out here in the demo app since the result view with the scan results
    // is not suitable for this navigation view
	
    // self.scanditSDKBarcodePicker.overlayController.delegate = self;
    
    // Push the picker on the navigation stack and start scanning.
    [[self navigationController] pushViewController:barcodePicker animated:YES];
	[barcodePicker startScanning];
}
//! [ScanditSDKBarcodePicker in a navigation controller]

/**
 * Returns YES if the device runs at least the specified OS version.
 */
- (BOOL)isMinOSVersion:(NSString *)version {
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:version options:NSNumericSearch] == NSOrderedAscending) {
        return NO;
    } else {
        return YES;
    }
}


#pragma mark -
#pragma mark UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController {
	
	// Be sure to close all pickers that might still be open.
    if (tabBarController.selectedIndex != 2) {
		[self closePickerSubview];
		[self.navigationController popToRootViewControllerAnimated:NO];
    }
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
	if (!self.modalStartAnimationDone) {
		// If the initial animation hasn't finished yet we buffer the result and return it as soon
		// as the animation finishes.
		self.modalBufferedResult = barcodeResult;
		return;
	} else {
		self.modalBufferedResult = nil;
	}
	
	[self.scanditSDKBarcodePicker stopScanningAndKeepTorchState];
	
	if (barcodeResult == nil) return;
	
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
	
	// Stop the scanning process:
	[scanditSDKBarcodePicker stopScanning];
	
	[[self tabBarController] dismissModalViewControllerAnimated:YES];

    self.modalBufferedResult = nil;
	self.scanditSDKBarcodePicker = nil;
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
			self.scanditSDKBarcodePicker.view.bounds.size.width,
			self.scanditSDKBarcodePicker.view.bounds.size.height)];
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


@end
