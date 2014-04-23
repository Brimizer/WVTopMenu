#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "WVTopMenu"
  s.version          = "0.1.0"
  s.summary          = "A short description of WVTopMenu."
  s.description      = <<-DESC
                       An optional longer description of WVTopMenu

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/Brimizer/WVTopMenu"
  s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Daniel Brim" => "brimizer@gmail.com" }
  s.source           = { :git => "https://github.com/Brimizer/WVTopMenu.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/brimizer'

  s.platform     = :ios, '7.1'
  s.ios.deployment_target = '7.1'
  s.requires_arc = true

  s.source_files = 'WVTopMenu'

  # s.public_header_files = 'Classes/**/*.h'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'
  # s.dependency 'JSONKit', '~> 1.4'
end
