#
#  Be sure to run `pod spec lint PhotoAlbum.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "PhotoAlbum"
  s.version      = "0.0.1"
  s.summary      = "PhotoAlbum for iOS"
  s.description  = "A photo browser supporting multi-Photo selection, single photo selection, video, crop."
  s.homepage     = "https://github.com/AngleZhou/PhotoAlbum"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "AngleZhou" => "zhouq87724@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/AngleZhou/PhotoAlbum.git", :tag => "0.0.1" }
  s.source_files  = "PhotoAlbum", "PhotoAlbum/Classes/**/*.{h,m}"
  s.resources = "Assets"
  s.requires_arc = true

  
end
