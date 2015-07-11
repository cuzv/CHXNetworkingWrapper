Pod::Spec.new do |s|
  s.name         = "CHXNetworkingWrapper"
  s.version      = "1.1"
  s.summary      = "CHXNetworkingWrapper is a AFNetworking wrapper"

  s.homepage     = "https://github.com/atcuan/CHXNetworkingWrapper"
  s.license      = "MIT"
  s.author             = { "Moch Xiao" => "atcuan@gmail.com" }
  s.platform     = :ios, "7.0"
  s.requires_arc  = true
  s.source       = { :git => "https://github.com/atcuan/CHXNetworkingWrapper.git",
:tag => s.version.to_s }
  s.source_files  = "CHXNetworkingWrapper/Classess/*"
  s.frameworks = 'Foundation', 'UIKit'
  s.dependency "AFNetworking"
end
