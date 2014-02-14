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

@interface HHBarCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>
    @property (nonatomic) AVCaptureSession *session;
    @property (nonatomic) AVCaptureDevice *device;
    @property (nonatomic) AVCaptureDeviceInput *input;
    @property (nonatomic) AVCaptureMetadataOutput *output;
    @property (nonatomic) AVCaptureVideoPreviewLayer *prevLayer;

    @property (nonatomic) UIView *highlightView;
    @property (nonatomic) UILabel *label;
    @property (nonatomic) UIButton *cancelButton;
    @property (nonatomic) UIButton *flashButton;
@end

@implementation HHBarCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.highlightView = [[UIView alloc] init];
    self.highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    self.highlightView.layer.borderWidth = 3;
    [self.view addSubview:self.highlightView];

    self.label = [[UILabel alloc] init];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    self.label.textColor = [UIColor whiteColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.text = @"(none)";
    [self.view addSubview:self.label];
    
    self.cancelButton = [[UIButton alloc] init];
    self.cancelButton.frame = CGRectMake(0, 0, 80, 40);
    [self.cancelButton setTitleColor:self.label.textColor forState:UIControlStateNormal];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton setBackgroundColor:self.label.backgroundColor];
    [self.cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    
    self.session = [[AVCaptureSession alloc] init];
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;

    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (self.input) {
        [self.session addInput:self.input];
    } else {
        NSLog(@"Error: %@", error);
    }

    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.session addOutput:self.output];

    self.output.metadataObjectTypes = [self.output availableMetadataObjectTypes];

    self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.prevLayer.frame = self.view.bounds;
    self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.prevLayer];

    [self.session startRunning];

    [self.view bringSubviewToFront:self.highlightView];
    [self.view bringSubviewToFront:self.label];
    [self.view bringSubviewToFront:self.cancelButton];
    
    if ([self.device hasTorch]) {
        
        self.flashButton = [[UIButton alloc] init];
        self.flashButton.frame = CGRectMake(0, 0, 80, 40);
        [self.flashButton setTitleColor:self.label.textColor forState:UIControlStateNormal];
        [self.flashButton setTitle:@"Flash" forState:UIControlStateNormal];
        [self.flashButton setBackgroundColor:self.label.backgroundColor];
        [self.flashButton addTarget:self action:@selector(toggleFlash) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.flashButton];
        [self.view bringSubviewToFront:self.flashButton];
        
        [self.device lockForConfiguration:nil];
        [self.device setTorchMode:AVCaptureTorchModeOff];
        [self.device unlockForConfiguration];
    }
}

- (void) toggleFlash {
    [self.device lockForConfiguration:nil];
    if (self.device.torchMode == AVCaptureTorchModeOff) {
        [self.device setTorchMode:AVCaptureTorchModeOn];
        [self.flashButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    }
    else {
        [self.device setTorchMode:AVCaptureTorchModeOff];
        [self.flashButton setTitleColor:self.label.textColor forState:UIControlStateNormal];
    }
    [self.device unlockForConfiguration];
}

- (void) setHighlightColor:(UIColor*)highlightColor {
    self.highlightView.layer.backgroundColor = highlightColor.CGColor;
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
    CGRect labelFrame = CGRectMake(self.cancelButton.frame.size.width, self.view.bounds.size.height - 40, self.view.bounds.size.width - self.cancelButton.frame.size.width, 40);
    
    CGRect cancelButtonFrame = self.cancelButton.frame;
    cancelButtonFrame.origin.y = self.view.frame.size.height - self.cancelButton.frame.size.height;
    
    if ([self.device hasTorch]) {
        labelFrame.size.width -= self.flashButton.frame.size.width;
        CGRect flashButtonFrame = self.flashButton.frame;
        flashButtonFrame.origin.y = cancelButtonFrame.origin.y;
        flashButtonFrame.origin.x = labelFrame.origin.x + labelFrame.size.width;
        self.flashButton.frame = flashButtonFrame;
    }
    
    self.label.frame = labelFrame;
    
    self.cancelButton.frame = cancelButtonFrame;
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
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[self.prevLayer transformedMetadataObjectForMetadataObject:metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }

        if (detectionString != nil) {
            self.label.text = detectionString;
            if (self.delegate) {
                [self.delegate barCodeViewController:self didDetectBarCode:detectionString];
            }
            if (self.detectedBarCodeBlock) {
                self.detectedBarCodeBlock(self, detectionString);
            }
            break;
        }
        else {
            self.label.text = @"(none)";
        }
    }

    self.highlightView.frame = highlightViewRect;
}

@end