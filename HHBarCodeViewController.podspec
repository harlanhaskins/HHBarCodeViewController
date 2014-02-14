#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "HHBarCodeViewController"
  s.version          = "1.0.0"
  s.summary          = "HHBarCodeViewController is a quick modal Bar Code reader using the iOS 7 native bar code scanning APIs."
  s.homepage         = "http://github.com/harlanhaskins/HHBarCodeViewController"
  s.license          = 'MIT'
  s.author           = { "Harlan Haskins" => "harlan@harlanhaskins.com" }
  s.source           = { :git => "http://github.com/harlanhaskins/HHBarCodeViewController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/harlanhaskins'

  s.requires_arc = true

  s.source_files = 'Classes/*.{h,m}'

end
