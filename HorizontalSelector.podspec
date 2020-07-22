#
# Be sure to run `pod lib lint HorizontalSelector.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HorizontalSelector'
  s.version          = '0.1.1'
  s.summary          = 'A short description of HorizontalSelector.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/LorTos/HorizontalSelector'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LorTos' => 'lorenzotoscanidc@gmail.com' }
  s.source           = { :git => 'https://github.com/LorTos/HorizontalSelector.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'HorizontalSelector/Classes/**/*'
end
