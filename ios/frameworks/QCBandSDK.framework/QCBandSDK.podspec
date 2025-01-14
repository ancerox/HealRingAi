Pod::Spec.new do |s|
    s.name             = 'QCBandSDK'
    s.version          = '1.0.0'
    s.summary          = 'QCBandSDK Framework'
    s.description      = 'QCBandSDK Framework for iOS'
    s.homepage         = 'https://example.com'
    s.license          = { :type => 'Commercial', :text => 'Proprietary' }
    s.author           = { 'Author' => 'author@example.com' }
    s.source           = { :path => '.' }
    s.ios.deployment_target = '12.0'
    
    s.vendored_frameworks = 'QCBandSDK.framework'
    s.framework = 'Foundation'
    s.requires_arc = true
  end