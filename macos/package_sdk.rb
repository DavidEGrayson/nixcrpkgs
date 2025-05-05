#!/usr/bin/ruby

# Ruby script meant to me run on a macOS that helps find and package macOS SDKs
# for the purposes of cross-compiling systems like nixcrpkgs.

# This utility is released into the Public Domain.

require 'fileutils'
require 'json'

def sdk_info(path)
  sdk_settings_path = File.join(path, 'SDKSettings.json')
  return nil if !File.exist?(sdk_settings_path)

  begin
    settings = JSON.load(File.read(sdk_settings_path))
    variant = settings.fetch('DefaultVariant')
    return nil if variant != 'macos'
    version = settings.fetch('Version')
  rescue
    raise
    return nil
  end

  { path: File.realpath(path), version: version }
end

def find_sdks
  paths_to_search = [
    ENV['SDKROOT'],
    `xcrun --show-sdk-path 2> /dev/null`.chomp,
    '/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs',
    '/Library/Developer/CommandLineTools'
  ]

  sdks = []
  paths_to_search.each do |path|
    next if path.nil? || path.empty?
    info = sdk_info(path)
    if info
      sdks << info
    else
      Dir.glob(File.join(path, '*')) do |child|
        info = sdk_info(child)
        sdks << info if info
      end
    end
  end
  sdks.uniq
end

def show_sdks
  sdks = find_sdks

  if sdks.empty?
    puts "No macOS SDKs found."
    return
  end

  puts "Found these SDKs:"
  sdks.each do |sdk|
    puts sdk.fetch(:path) + ' # ' + sdk.fetch(:version)
  end

  puts
  puts "You can run this script again and pass the path to the SDK you want to package."
end

def package_sdk(sdk_path_input)
  info = sdk_info(sdk_path_input) 
  sdk_path = info.fetch(:path)
  version = info.fetch(:version)
  tmp_path = 'MacOSX' + version + '.sdk'
  archive_path = tmp_path + '.tar.xz'
  
  if File.exist?(tmp_path)
    $stderr.puts "Please remove #{tmp_path}"
    exit 1
  elsif File.exist?(archive_path)
    $stderr.puts "Please remove #{archive_path}"
    exit 1
  end

  begin
    puts "Copying SDK files to temporary directory..."
    FileUtils.cp_r(sdk_path, tmp_path)
    puts "Archiving..."
    system("tar -cJf #{archive_path} #{tmp_path}")
  ensure
    FileUtils.remove_dir(tmp_path)
  end
  puts "SDK is packaged in #{archive_path}"
end

if ARGV.empty?
  show_sdks
else
  package_sdk(ARGV[0])
end

