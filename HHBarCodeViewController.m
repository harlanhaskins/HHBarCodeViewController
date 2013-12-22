//
//  HHBarCodeViewController.m
//  Modified version of igViewController.m.
//  Modified by Harlan Haskins
//
//  igViewController.m
//  ScanBarCodes
//
//  Created by Torrey Betts on 10/10/13.
//  Copyright (c) 2013 Infragistics. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "HHBarCodeViewController.h"

@interface HHBarCodeViewController () <AVCaptureMetadataOutputObjectsDelegate> {
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;

    UIView *_highlightView;
    UILabel *_label;
    UIButton *_cancelButton;
    UIButton *_flashButton;
}
@end

@implementation HHBarCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.view addSubview:_highlightView];

    _label = [[UILabel alloc] init];
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"(none)";
    [self.view addSubview:_label];
    
    _cancelButton = [[UIButton alloc] init];
    _cancelButton.frame = CGRectMake(0, 0, 80, 40);
    [_cancelButton setTitleColor:_label.textColor forState:UIControlStateNormal];
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelButton setBackgroundColor:_label.backgroundColor];
    [_cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;

    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }

    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];

    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];

    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.view.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];

    [_session startRunning];

    [self.view bringSubviewToFront:_highlightView];
    [self.view bringSubviewToFront:_label];
    [self.view bringSubviewToFront:_cancelButton];
    
    if ([_device hasTorch]) {
        
        _flashButton = [[UIButton alloc] init];
        _flashButton.frame = CGRectMake(0, 0, 80, 40);
        [_flashButton setTitleColor:_label.textColor forState:UIControlStateNormal];
        [_flashButton setTitle:@"Flash" forState:UIControlStateNormal];
        [_flashButton setBackgroundColor:_label.backgroundColor];
        [_flashButton addTarget:self action:@selector(toggleFlash) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_flashButton];
        [self.view bringSubviewToFront:_flashButton];
        
        [_device lockForConfiguration:nil];
        [_device setTorchMode:AVCaptureTorchModeOff];
        [_device unlockForConfiguration];
    }
}

- (void) toggleFlash {
    [_device lockForConfiguration:nil];
    if (_device.torchMode == AVCaptureTorchModeOff) {
        [_device setTorchMode:AVCaptureTorchModeOn];
        [_flashButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    }
    else {
        [_device setTorchMode:AVCaptureTorchModeOff];
        [_flashButton setTitleColor:_label.textColor forState:UIControlStateNormal];
    }
    [_device unlockForConfiguration];
}

- (void) setHighlightColor:(UIColor*)highlightColor {
    _highlightView.layer.backgroundColor = highlightColor.CGColor;
}

- (void) dismiss {
    if (self.navigationController) {
        if ([self.navigationController.viewControllers lastObject] == self) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) viewDidLayoutSubviews {
    CGRect labelFrame = CGRectMake(_cancelButton.frame.size.width, self.view.bounds.size.height - 40, self.view.bounds.size.width - _cancelButton.frame.size.width, 40);
    
    CGRect cancelButtonFrame = _cancelButton.frame;
    cancelButtonFrame.origin.y = self.view.frame.size.height - _cancelButton.frame.size.height;
    
    if ([_device hasTorch]) {
        labelFrame.size.width -= _flashButton.frame.size.width;
        CGRect flashButtonFrame = _flashButton.frame;
        flashButtonFrame.origin.y = cancelButtonFrame.origin.y;
        flashButtonFrame.origin.x = labelFrame.origin.x + labelFrame.size.width;
        _flashButton.frame = flashButtonFrame;
    }
    
    _label.frame = labelFrame;
    
    _cancelButton.frame = cancelButtonFrame;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeCode39Code,
                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeCode93Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code,
                              AVMetadataObjectTypeQRCode,
                              AVMetadataObjectTypeAztecCode];

    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type]) {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }

        if (detectionString != nil) {
            _label.text = detectionString;
            [_delegate barCodeViewController:self didDetectBarCode:detectionString];
            break;
        }
        else {
            _label.text = @"(none)";
        }
    }

    _highlightView.frame = highlightViewRect;
}

@end