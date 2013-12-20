HHBarCodeViewController
======

HHBarCodeViewController is a quick modal Bar Code reader using the iOS 7 native bar code scanning APIs.

This was originally for me to use because the only implementations I could find were code snippets on [blog posts](http://www.infragistics.com/community/blogs/torrey-betts/archive/2013/10/10/scanning-barcodes-with-ios-7-objective-c.aspx), so I consolidated that code and made it into a handy modal view controller that can be easily presented and has fancy delegate callbacks.

Woohoo.

Usage
===

Usage is pretty simple. Just instantiate an HHBarCodeViewController using `[HHBarCodeViewController new]` and present it or push it. Upon recognizing a bar code, the delegate method `barCodeViewController:didDetectBarCode:` will be called and you can choose to dismiss the View Controller or not
