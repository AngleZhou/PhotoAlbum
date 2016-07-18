Pod::Spec.new do |s|
  s.name             = 'PhotoAlbum'
  s.version          = '0.0.1'
  s.summary          = 'A PhotoAlbum which supports multi-Photo selection, single-Photo selection, video.'
  s.homepage         = 'https://github.com/AngleZhou/PhotoAlbum'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZhouQian' => 'zhouq87724@163.com' }
  s.source           = { :git => 'https://github.com/AngleZhou/PhotoAlbum.git'}
  s.ios.deployment_target = '8.0'
  s.source_files = 'PhotoAlbum/Classes/**/*'
  s.resource_bundles = {
    'PhotoAlbum' => ['PhotoAlbum/Assets/*.png']
  }
  s.frameworks = 'UIKit'
  s.requires_arc = true
end
