Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "HILoginManager"
s.module_name = "HILoginManager"
s.summary = "Halcyon Innovation login manager."
s.requires_arc = true
s.version = "2.0.7"
s.author = { "Vlad Getman" => "ibrightsider@gmail.com" }

s.license = { :type => "MIT", :file => "LICENSE" }
s.homepage = "https://github.com/HalcyonLA/HILoginManager"
s.source = { :git => "https://github.com/HalcyonLA/HILoginManager.git", :tag => "#{s.version}"}

s.framework = "UIKit"

s.dependency 'KeychainSwift', '~> 11.0.0'
s.dependency 'SwiftyUserDefaults', '~> 3.0.0'

s.source_files = "Source/**/*.{swift}"

end