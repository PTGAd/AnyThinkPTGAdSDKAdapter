Pod::Spec.new do |s|
  s.name         = 'AnyThinkPTGAdSDKAdapter'
  s.version      = '6.4.11'
  s.summary      = 'A simple library for FancyAd and AnyThinkPTGAdSDKAdapter.'
  
  s.description  = <<-DESC
                     AnyThinkPTGAdSDKAdapter is a lightweight library providing
                   advertising functionality with AnyThinkPTGAdSDKAdapter.
                   DESC

  s.homepage     = 'https://github.com/PTGAd/AnyThinkPTGAdSDKAdapter'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "fancy" => "ptg_all@fancydigital.com.cn" }
  s.source       = { :git => 'https://github.com/PTGAd/AnyThinkPTGAdSDKAdapter.git', :tag => s.version }
  

  s.ios.deployment_target = '13.0'
  s.source_files  = 'Classes/**/*.{h,m}' 
  s.framework     = 'UIKit'
  s.dependency 'AnyThinkiOS', '6.4.11'
  
end
