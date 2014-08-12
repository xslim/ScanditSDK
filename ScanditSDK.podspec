Pod::Spec.new do |s|
  s.name         = "ScanditSDK"
  s.version      = "4.1.2"
  s.summary      = 'ScanditSDK'
  s.description  = "Barcode Scanner SDK"
  s.homepage     = "http://www.scandit.com"
  s.license      = { :type => "Commercial", :file => 'ScanditSDK/LICENSE-2.0.txt' }
  s.author       = "Scandit"
  s.source       = { :git => "https://github.com/xslim/ScanditSDK.git", :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'
  s.requires_arc = false

  s.source_files = 'ScanditSDK/*.{h,cpp}'
  s.resources = 'ScanditSDK/*.{png,wav,lproj}' 

  s.preserve_paths = 'ScanditSDK/libscanditsdk-iphone-4.1.2.a'
  s.library = 'scanditsdk-iphone-4.1.2.a','z', 'iconv', 'c++'
  
  s.xcconfig  =  { 'LIBRARY_SEARCH_PATHS' => '"$(PODS_ROOT)/ScanditSDK/ScanditSDK"' }

end
