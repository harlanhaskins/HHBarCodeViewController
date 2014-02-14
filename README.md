# HHBarCodeViewController

HHBarCodeViewController is a quick modal Bar Code reader using the iOS 7 native bar code scanning APIs.

This was originally for me to use because the only implementations I could find were code snippets on [blog posts](http://www.infragistics.com/community/blogs/torrey-betts/archive/2013/10/10/scanning-barcodes-with-ios-7-objective-c.aspx), so I consolidated that code and made it into a handy modal view controller that can be easily presented and has fancy delegate callbacks and blocks.

Woohoo.

# Installation

Installation is easiest through [CocoaPods](http://www.cocoapods.org). Just add this line to your Podfile
`pod 'HHBarCodeViewController'`

# Usage

Usage is pretty simple. Just instantiate an HHBarCodeViewController using `[HHBarCodeViewController new]` and present it or push it. Upon recognizing a bar code, the delegate method `barCodeViewController:didDetectBarCode:` or the block `detectedBarCodeBlock()` will be called.

I'd highly recommend if you use the returned bar code that you do it in a completion after dismissing the ViewController. This will prevent repeated actions since `HHBarCodeViewController` calls that delegate method multiple times in its lifetime.

Like this:

    - (void) barCodeViewController:(UIViewController *)barCodeViewController didDetectBarCode:(NSString *)barCode {
        [self dismissViewControllerAnimated:YES completion:^{
            dataTextView.text = barCode;
        }];
    }

# Author

Harlan Haskins ([@harlanhaskins](http://github.com/harlanhaskins))

# License

HHBarCodeViewController is available under the MIT license, a copy of which is in the file called `LICENSE`.
