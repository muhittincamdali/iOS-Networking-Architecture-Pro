Pod::Spec.new do |s|
  s.name             = 'iOSNetworkingArchitecturePro'
  s.version          = '1.0.0'
  s.summary          = 'Professional networking architecture with advanced caching and offline support.'
  s.description      = <<-DESC
    iOSNetworkingArchitecturePro provides professional networking architecture
    for enterprise iOS applications. Features include advanced caching, offline
    support, real-time synchronization, request retry, and comprehensive error handling.
  DESC

  s.homepage         = 'https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muhittin Camdali' => 'contact@muhittincamdali.com' }
  s.source           = { :git => 'https://github.com/muhittincamdali/iOS-Networking-Architecture-Pro.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'

  s.swift_versions = ['5.9', '5.10', '6.0']
  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'Foundation', 'Combine'
end
