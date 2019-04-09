#
#  Be sure to run `pod spec lint JPImagePicker.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "JPImagePicker"
  spec.version      = "0.0.1"
  spec.summary      = "image picker"
  spec.description  = <<-DESC
  simple image picker
                   DESC
  spec.homepage     = "https://github.com/zhongqing05/JPImagePicker"
  spec.license      = "MIT"
  spec.author             = { "zhongqing" => "zhongqing05@gmail.com" }
  spec.platform     = :ios
  spec.source       = { :git => "https://github.com/zhongqing05/JPImagePicker.git", :tag => "#{spec.version}" }
  spec.source_files = "Album/**/*"

# spec.source_files  = "Classes", "Classes/**/*.{h,m}"
# spec.exclude_files = "Classes/Exclude"

  spec.framework  = "Photos"

end
