#!/usr/bin/env ruby

require 'fileutils'
require 'optparse'

options = {}
parser = OptionParser.new do |opts|
  opts.banner = 'pkgbuild [options] OUTPUT_PATH'
  opts.on('-h', '--help', 'Show this screen') do
    options[:help] = true
  end
  opts.on('--identifier ID') do |id|
    options[:id] = id
  end
  opts.on('--version VER') do |version|
    options[:version] = version
  end
  opts.on('--root PATH') do |path|
    options[:root_path] = path
  end
  opts.on('--install-location PATH') do |path|
    options[:install_path] = path
  end
  opts.on('--component-plist FILE') do |filename|
    options[:component_plist] = filename
  end
end

extra_args = parser.parse!(ARGV)
if extra_args.size != 1 || options[:help]
  puts parser.help
  exit 1
end
output_path = extra_args[0]

identifier = options.fetch(:id)
version = options.fetch(:version)
root_path = options.fetch(:root_path)
install_path = options.fetch(:install_path)

if options[:component_plist] && options[:component_plist] != 'nocomponents.plist'
  puts 'Note: This utility ignores --component-plist and assumes no components.'
end

FileUtils.rm_rf(output_path)
FileUtils.mkdir(output_path)

success = system("find '#{root_path}' | cpio --format odc -o | gzip > #{output_path}/Payload")
if !success
  $stderr.puts "Failed to create Payload."
  exit 1
end

success = system("mkbom '#{root_path}' #{output_path}/Bom")
if !success
  $stderr.puts "Failed to create Bom."
  exit 1
end

du_output = `du --bytes -s '#{root_path}'`
if !$?.success?
  $stderr.puts "Failed to run 'du' to get install size."
  exit 1
end
install_bytes = Integer(du_output.split(' ').fetch(0))
install_kb = install_bytes/1024

number_of_files = `find '#{root_path}' | wc -l`
if !$?.success?
  $stderr.puts "Failed to run 'find' and 'wc' to get the number of files."
  exit 1
end

File.open("#{output_path}/PackageInfo", "w").write <<END
<?xml version="1.0" encoding="utf-8"?>
<pkg-info overwrite-permissions="true" relocatable="false"
  identifier="#{identifier}" postinstall-action="none"
  version="#{version}" format-version="2" generator-version=""
  install-location="#{install_path}" auth="root">
    <payload numberOfFiles="#{number_of_files}" installKBytes="#{install_kb}"/>
    <bundle-version/>
    <upgrade-bundle/>
    <update-bundle/>
    <atomic-update-bundle/>
    <strict-identifier/>
    <relocate/>
</pkg-info>
END
