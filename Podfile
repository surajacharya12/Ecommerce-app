# Uncomment this line to define a global platform for your project
platform :ios, '13.0'

# Disable CocoaPods analytics
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# Method to locate the Flutter SDK
def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. Run 'flutter pub get' first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig and run 'flutter pub get'"
end

# Include Flutter's pod helper
require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

# Setup Flutter iOS pods
flutter_ios_podfile_setup

# Define your app target
target 'Runner' do
  # Use static frameworks for Flutter plugins
  use_frameworks! :linkage => :static

  # Install all Flutter pods
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  # Define test target
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

# Post-install script to fix Swift version & build settings
post_install do |installer|
  installer.pods_project.targets.each do |target|
    # Add Flutter additional build settings
    flutter_additional_ios_build_settings(target)

    # Set Swift version and disable library evolution for all targets
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.7'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'NO'
    end
  end
end

