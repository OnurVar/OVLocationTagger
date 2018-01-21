Pod::Spec.new do |s|
s.name             = 'OVLocationTagger'
s.version          = '1.2.1'
s.summary          = 'Simple Location Tagger'
s.description      = <<-DESC
Simple Location Tagger returns last known User's location.
DESC
s.homepage         = 'https://github.com/OnurVar/OVLocationTagger.git'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Onur Var' => 'var.onur@hotmail.com' }
s.source           = { :git => 'https://github.com/OnurVar/OVLocationTagger.git', :tag => s.version.to_s }
s.ios.deployment_target = '8.0'
s.source_files = 'OVLocationTagger/Classes/**/*'
s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
end

