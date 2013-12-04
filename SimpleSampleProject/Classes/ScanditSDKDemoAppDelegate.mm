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
#import "Reachability.h"

#define kScanditSDKAppKey    @"--- ENTER YOUR SDK KEY FROM SCANDIT.COM HERE ---"


@implementation ScanditSDKDemoAppDelegate

@synthesize window;
@synthesize picker;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Scandit Integration
    // The following method calls illustrate how the Scandit can be integrated into your app.
    
    // Hide the status bar to get a bigger area of the video feed. (optional)
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    // Initialize the barcode picker - make sure you set the app key above
	picker = [[ScanditSDKBarcodePicker alloc] initWithAppKey:kScanditSDKAppKey];
	
    // Customize the Scan UI by adding a search bar and a camera switch button (optional)
	[picker.overlayController showSearchBar:YES];
	[picker.overlayController setCameraSwitchVisibility:CAMERA_SWITCH_ON_TABLET];
    
	// Set the delegate to receive callbacks.
	picker.overlayController.delegate = self;
	
    // Start the scanning
	[picker startScanning];
	
    // Show the barcode picker view
    [window setRootViewController:picker];
    [window makeKeyAndVisible];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

/**
 * This delegate method of the ScanditSDKOverlayController protocol needs to be implemented by
 * every app that uses the ScanditSDK and this is where the custom application logic goes.
 * In the example below, we are just showing an alert view with the result.
 */
- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)scanditSDKOverlayController1
                     didScanBarcode:(NSDictionary *)barcodeResult {
	
	[picker stopScanningAndKeepTorchState];
	
    NSString *symbology = [barcodeResult objectForKey:@"symbology"];
	NSString *barcode = [barcodeResult objectForKey:@"barcode"];
    UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:[NSString stringWithFormat:@"Scanned %@", symbology]
						  message:barcode
						  delegate:self
						  cancelButtonTitle:@"OK"
					      otherButtonTitles:nil];
	[alert show];
}

/**
 * This delegate method of the ScanditSDKOverlayController protocol needs to be implemented by
 * every app that uses the ScanditSDK and this is where the custom application logic goes.
 * In the example below, we are not doing anything because the app only consists of the scan screen.
 */
- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)scanditSDKOverlayController1
                didCancelWithStatus:(NSDictionary *)status {
}

/**
 * This delegate method of the ScanditSDKOverlayController protocol needs to be implemented by
 * every app that uses the ScanditSDK and this is where the custom application logic goes.
 * In the example below, we are just showing an alert view with the result.
 */
- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)scanditSDKOverlayController
                    didManualSearch:(NSString *)input {
	
	[picker stopScanningAndKeepTorchState];
	
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Manual input"]
							   message:input
							  delegate:self
					 cancelButtonTitle:@"OK"
					 otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self.picker startScanning];
}


#pragma mark -
#pragma mark Network Check

- (BOOL)isNetworkAvailable {
	Reachability * reachability = [Reachability reachabilityForInternetConnection];
	if ([reachability currentReachabilityStatus] == NotReachable) {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"No Network"
															message:@"The trial version of Scandit requires network access. Connect and try again."
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
		return NO;
	}
	return YES;
}

@end
