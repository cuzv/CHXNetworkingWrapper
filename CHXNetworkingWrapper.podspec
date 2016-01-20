Pod::Spec.new do |s|
  s.name         = "CHXNetworkingWrapper"
  s.version      = "1.5"
  s.summary      = "CHXNetworkingWrapper is a AFNetworking wrapper"

  s.homepage     = "https://github.com/cuzv/CHXNetworkingWrapper"
  s.license      = "MIT"
  s.author             = { "Moch Xiao" => "cuzval@gmail.com" }
  s.platform     = :ios, "7.0"
  s.requires_arc  = true
  s.source       = { :git => "https://github.com/cuzv/CHXNetworkingWrapper.git",
:tag => s.version.to_s }
  s.source_files  = "CHXNetworkingWrapper/Sources/*.{h,m}"
  s.frameworks = 'Foundation', 'UIKit'
  s.dependency "AFNetworking", "~> 2.6"
end
