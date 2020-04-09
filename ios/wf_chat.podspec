Pod::Spec.new do |s|
  s.name             = 'wf_chat'
  s.version          = '0.0.1'
  s.summary          = '新湃野火Flutter插件'
  s.description      = '新湃野火Flutter插件'
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  s.preserve_paths = 'WFChatClient.framework'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework WFChatClient' }
  s.vendored_frameworks = 'WFChatClient.framework'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  # s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
