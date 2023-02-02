Pod::Spec.new do |spec|

  spec.name         = "PrecheckLibrary"
  spec.version      = "2.0.0"
  spec.summary      = "A CocoaPods library written in Swift"

  spec.description  = <<-DESC
Precheck
                   DESC

  spec.homepage     = "https://interbio.com"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "hasta ragil" => "hasta.ragil@interbio.com" }

  spec.ios.deployment_target = "11.0"
  spec.swift_version = "5.7"
  spec.source       = { :git => "https://github.com/kostiakoval/Seru.git", :tag => spec.version }

#  spec.source        = { :http => "https://interbio.com" }
  spec.source_files  = "PrecheckLibrary/**/*.{h,m,swift}"
  spec.dependency 'GoogleMLKit/FaceDetection', '3.2.0'
  spec.static_framework = true

end
