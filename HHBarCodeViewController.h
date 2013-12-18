//
//  HHBarCodeViewController.h
//  Modified version of igViewController.h
//  Modified by Harlan Haskins
//
//  igViewController.h
//  ScanBarCodes
//
//  Created by Torrey Betts on 10/10/13.
//  Copyright (c) 2013 Infragistics. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HHBarCodeViewControllerDelegate <NSObject>

- (void) barCodeViewController:(UIViewController*)barCodeViewController didDetectBarCode:(NSString*)barCode;

@end

@interface HHBarCodeViewController : UIViewController

@property id<HHBarCodeViewControllerDelegate> delegate;

- (void) dismiss;

@end