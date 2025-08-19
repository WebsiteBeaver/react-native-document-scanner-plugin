require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-document-scanner-plugin"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  # Include git submodules (ios/DocScanner) so DocScanner.swift is available when installing via CocoaPods
  s.source       = { :git => "https://github.com/websitebeaver/react-native-document-scanner-plugin.git", :tag => "#{s.version}", :submodules => true }

  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.private_header_files = "ios/**/*.h"


  install_modules_dependencies(s)
end
