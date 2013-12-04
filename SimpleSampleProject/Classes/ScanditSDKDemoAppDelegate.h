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


#import <UIKit/UIKit.h>
#import "ScanditSDKBarcodePicker.h"
#import "ScanditSDKOverlayController.h"

#define kAppDelegate (ScanditSDKDemoAppDelegate *)[[UIApplication sharedApplication] delegate]
#define kIsNetworkAvailableCheck [kAppDelegate isNetworkAvailable]


@interface ScanditSDKDemoAppDelegate : NSObject
		<UIApplicationDelegate, ScanditSDKOverlayControllerDelegate, UIAlertViewDelegate> {
			
    UIWindow *window;
	ScanditSDKBarcodePicker *picker;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) ScanditSDKBarcodePicker *picker;

- (BOOL)isNetworkAvailable;

@end

