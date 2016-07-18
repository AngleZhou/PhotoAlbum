#
# Be sure to run `pod lib lint PhotoAlbum.podspec' to ensure this is a
# valid spec before submitting.


Pod::Spec.new do |s|
  s.name             = 'PhotoAlbum'
  s.version          = '0.1.0'
  s.summary          = 'A PhotoAlbum which supports multi-Photo selection, single-Photo selection, video.'

  s.homepage         = 'https://github.com/AngleZhou/PhotoAlbum'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZhouQian' => 'zhouq87724@163.com' }
  s.source           = { :git => 'https://github.com/AngleZhou/PhotoAlbum.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'PhotoAlbum/Classes/**/*'
  
  s.resource_bundles = {
    'PhotoAlbum' => ['PhotoAlbum/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'

end
