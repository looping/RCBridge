Pod::Spec.new do |s|
  s.name         = 'RCBridge'
  s.version      = '0.1'
  s.summary      = 'A bridge for sending messages between native iOS and JavaScript in UIWebView/WKWebView.'
  s.homepage     = 'https://github.com/looping/RCBridge'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'looping' => 'www.looping@gmail.com' }
  s.requires_arc = true
  s.source       = { :git => 'https://github.com/looping/RCBridge.git', :tag => s.version.to_s }
  s.platforms = { :ios => "7.0" }
  s.ios.source_files = 'RCBridge/*.{h,m}'
  s.ios.resources = 'RCBridge/*.{js}'
  s.ios.frameworks    = 'UIKit', 'JavaScriptCore'
  s.ios.weak_framework = 'WebKit'
end
