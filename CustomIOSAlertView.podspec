Pod::Spec.new do |s|
  s.name = 'CustomIOSAlertView'
  s.version = '0.1.1'
  s.license = 'Unlicensed'
  s.summary = 'Custom iOS alert views'
  s.homepage = 'https://github.com/jensgrud/CustomIOSAlertView'
  s.authors = { 'Jens Grud' => 'jens@heapsapp.com' }
  s.source = { :git => 'https://github.com/jensgrud/CustomIOSAlertView.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.source_files = '*.{h,m}'
  s.requires_arc = true

  s.dependency 'SDWebImage'
end