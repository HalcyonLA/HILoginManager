Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "HILoginManager"
s.module_name = "HILoginManager"
s.summary = "Halcyon Innovation login manager."
s.requires_arc = true
s.version = "1.0.0"
s.author = { "Vlad Getman" => "ibrightsider@gmail.com" }

s.license = { :type => "MIT", :file => "LICENSE" }
s.homepage = "https://github.com/HalcyonLA/HILoginManager"
s.source = { :git => "https://github.com/HalcyonLA/HILoginManager.git", :tag => "#{s.version}"}

s.framework = "UIKit"

s.dependency 'KeychainSwift', '~> 3.0.16'
s.dependency 'SwiftyUserDefaults', '~> 2.2.0'

s.source_files = "Source/**/*.{swift}"

end