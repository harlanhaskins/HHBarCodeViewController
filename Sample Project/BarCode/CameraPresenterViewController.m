//
//  CameraPresenterViewController.m
//  BarCode
//
//  Created by Harlan Haskins on 12/21/13.
//  Copyright (c) 2013 haskins. All rights reserved.
//

#import "CameraPresenterViewController.h"

@interface CameraPresenterViewController ()

@end

@implementation CameraPresenterViewController {
    UIButton *openCameraButton;
    UITextView *dataTextView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    openCameraButton = [[UIButton alloc] init];
    [openCameraButton setTitle:@"Open Bar Code Scanner" forState:UIControlStateNormal];
    [openCameraButton sizeToFit];
    [openCameraButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [openCameraButton addTarget:self action:@selector(openBarCodeScanner) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openCameraButton];
    
    dataTextView = [UITextView new];
    dataTextView.width = round(self.view.width * 0.9);
    dataTextView.height = round(self.view.height * 0.9);
    dataTextView.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
    [self.view addSubview:dataTextView];
    // Do any additional setup after loading the view.
}

- (void) viewDidLayoutSubviews {
    [openCameraButton centerToParent];
    openCameraButton.y = self.topLayoutGuide.length;
    [dataTextView centerToParent];
    dataTextView.y = openCameraButton.bottom;
}

- (void) openBarCodeScanner {
    HHBarCodeViewController *barCodeVC = [[HHBarCodeViewController alloc] init];
    barCodeVC.delegate = self;
    [self presentViewController:barCodeVC animated:YES completion:nil];
}

- (void) barCodeViewController:(UIViewController *)barCodeViewController didDetectBarCode:(NSString *)barCode {
    [self dismissViewControllerAnimated:YES completion:^{
        dataTextView.text = [dataTextView.text stringByAppendingString:[barCode stringByAppendingString:@"\n"]];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
