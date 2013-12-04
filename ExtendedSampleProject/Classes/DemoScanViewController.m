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
//  DemoScanViewController inherits from the ScanDKOverlayController and is
//  included to illustrate how developer can customize the scan screen user 
//  interface. 
//7c66092295f916c97fc787a862c9c36678bcd2e2

#import "DemoScanViewController.h"


@implementation DemoScanViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
	}
    return self;
}

/**
 *	customizes the Scandit SDK scan screen. Due to the reduced space, we  
 *  disable optional features such as the toolbar and searchbar, move the scandit logo
 *  and reduce the size of the viewfinder slightly.
 *
 *  Note that we also moved the scanning hotspot to the top half of the camera image
 *  in the DemoViewController.
 */

- (void)viewDidLoad {
	
    [super viewDidLoad];
	// disable the following (optional) Scandit SDK Scan Screen elements
	// since there is not enough space in this custom scan screen
	[self showToolBar:YES];
	[self showSearchBar:NO];
	[self showMostLikelyBarcodeUIElement:NO];
	[self setTorchEnabled:NO];
	
	// reduce the size of the view finder box to 20% (default is 25%)
    [self setViewfinderHeight:0.2 width:0.6];
	
	// reduce the size of the font (default is 16)
	[self setViewfinderFontSize:14];
	
	// disable the scan flash because it is applied to the entire screen
	[self setScanFlashEnabled:NO];

}

- (IBAction) buttonPressed{
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Demo"
													 message:@"Dummy Button Pressed"
													delegate:nil 
										   cancelButtonTitle:@"OK" 
										   otherButtonTitles:nil];
	[alert show];
}


@end
