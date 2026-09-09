#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mbaudience.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mbaudience'
  s.version          = '2.1.7'
  s.summary          = 'MBAudience plugin for the MBurger platform.'
  s.description      = <<-DESC
MBAudience is a plugin library for MBurger that lets you track user data and
behavior to target messages only to specific users or groups of users.
                       DESC
  s.homepage         = 'https://web.mburger.cloud/engagement-platform'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mumble' => 'info@mumbleideas.it' }
  s.source           = { :git => 'https://github.com/Mumble-SRL/MBAudience-Flutter.git', :tag => s.version.to_s }
  s.source_files     = 'mbaudience/Sources/mbaudience/**/*.swift'
  s.resource_bundles = { 'mbaudience_privacy' => ['mbaudience/Sources/mbaudience/PrivacyInfo.xcprivacy'] }
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'
end
