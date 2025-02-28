Pod::Spec.new do |s|
  s.name         = 'AnyThinkPTGAdSDKAdapter'
  s.version      = '1.0.8'
  s.summary      = 'A simple library for FancyAd and AnyThinkPTGAdSDKAdapter.'
  
  s.description  = <<-DESC
                     AnyThinkPTGAdSDKAdapter is a lightweight library providing
                   advertising functionality with AnyThinkPTGAdSDKAdapter.
                   DESC

  s.homepage     = 'https://github.com/PTGAd/AnyThinkPTGAdSDKAdapter'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "fancy" => "ptg_all@fancydigital.com.cn" }
  s.source       = { :git => 'https://github.com/PTGAd/AnyThinkPTGAdSDKAdapter.git', :tag => s.version }

  s.static_framework = true
  s.ios.deployment_target = '11.0'
  s.vendored_frameworks = 'AnyThinkPTGAdSDKAdapter.framework'
  s.framework     = 'UIKit'
  valid_archs = ['armv7', 'armv7s', 'x86_64', 'arm64']
  s.xcconfig = {
    'VALID_ARCHS' =>  valid_archs.join(' '),
  }
  s.dependency 'AnyThinkiOS', '6.4.27'
  s.dependency 'PTGAdFramework', '2.2.40'
  
end
