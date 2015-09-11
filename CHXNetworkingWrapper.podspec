Pod::Spec.new do |s|
  s.name         = "CHXNetworkingWrapper"
  s.version      = "1.4.0"
  s.summary      = "CHXNetworkingWrapper is a AFNetworking wrapper"

  s.homepage     = "https://github.com/cuzv/CHXNetworkingWrapper"
  s.license      = "MIT"
  s.author             = { "Moch Xiao" => "cuzval@gmail.com" }
  s.platform     = :ios, "7.0"
  s.requires_arc  = true
  s.source       = { :git => "https://github.com/cuzv/CHXNetworkingWrapper.git",
:tag => s.version.to_s }
  s.source_files  = "CHXNetworkingWrapper/Classess/*"
  s.frameworks = 'Foundation', 'UIKit'
  s.dependency "AFNetworking"
end
