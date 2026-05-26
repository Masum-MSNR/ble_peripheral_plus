#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ble_peripheral_plus.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ble_peripheral_plus'
  s.version          = '2.5.4'
  s.summary          = 'A maintained fork of the ble_peripheral Flutter plugin.'
  s.description      = <<-DESC
A maintained fork of the ble_peripheral Flutter plugin.
                       DESC
  s.homepage         = 'https://github.com/Masum-MSNR/ble_peripheral_plus'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Masum MSNR' => 'support@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'ble_peripheral_plus/Sources/ble_peripheral_plus/**/*.swift'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.14'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
