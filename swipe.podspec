Pod::Spec.new do |s|
  s.name = "swipe"
  s.version = "1.0.0"
  s.summary = "Swipe & Swipe Engine"
  s.homepage = "https://github.com/swipe-org/swipe"
  s.license = { :type => "MIT", :file => "LICENSE.txt" }

  s.author = "swipe-org"

  s.platforms = {
    :ios => "9.0"
  }

  s.source = {
      :git => "https://github.com/swipe-org/swipe.git",
      :tag => "#{s.version}",
  }

  s.source_files = "core/*.swift", "browser/*.swift", "network/*.swift"
  s.resources = "browser/ios/*.xib", "network/**/*.xcdatamodeld"
end
