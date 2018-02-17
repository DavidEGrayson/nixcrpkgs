#!/usr/bin/env ruby

require 'open3'
require 'pathname'
require 'sqlite3'  # gem install sqlite3

class AnticipatedError < RuntimeError
end

# Don't automatically change directory because maybe people want to test one
# nixcrpkgs repository using the test script from another one.  But do give an
# early, friendly warning if they are running in the wrong directory.
def check_directory!
  return if File.directory?('pretend_stdenv')
  $stderr.puts "You should run this script from the nixcrpkgs directory."
  dir = Pathname(__FILE__).parent.parent
  $stderr.puts "Try running these commands:\n  cd #{dir}\n  test/test.rb"
  exit 1
end

def substitute_definitions(defs, str)
  str.gsub(/\$([\w-]+)/) do |x|
    defs.fetch($1).join(",")
  end
end

def expand_brackets_core(str, depth)
  finished_parts = []
  active_parts = [+'']
  while true
    if str.empty?
      raise AnticipatedError, "Unmatched opening brace" if depth > 0
      break
    elsif str.start_with?('}')
      str.slice!(0)
      raise AnticipatedError, "Unmatched closing brace" if depth == 0
      break
    elsif str.start_with?('{')
      # Recurse, which removes everything up to and
      # including the matching closing brace.
      str.slice!(0)
      options = expand_brackets_core(str, depth + 1)
      raise if options.empty?
      active_parts = active_parts.flat_map { |p1|
        options.map { |p2| p1 + p2 }
      }
    elsif str.start_with?(',')
      raise AnticipatedError, "Comma at top level" if depth == 0
      # Remove the comma, mark the parts we are working
      # on as finished, and start a new part.
      str.slice!(0)
      finished_parts += active_parts
      active_parts = ['']
    else
      part_length = str.index(/[{},]|$/)
      raise if part_length < 1
      part = str.slice!(0, part_length)
      active_parts.each do |s|
        s.insert(-1, part)
      end
    end
  end
  finished_parts + active_parts
end

# Expands something like "{a,b}{,.x}" to ["a", "a.x", "b", "b.x"]
def expand_brackets(str)
  expand_brackets_core(str.dup, 0)
end

def parse_derivation_list(filename)
  defs = {}
  paths = []
  File.foreach(filename).with_index do |line, line_index|
    line_num = line_index + 1
    line.strip!
    next if line.empty?
    next if line.start_with?('#')

    if line.start_with?('define')
      md = line.match(/^define\s+([\w-]+)\s*=\s*(.*)$/)
      raise "Invalid definition syntax at line #{n}" if !md
      name, value = md[1], md[2]
      list = value.split(',').map(&:strip)
      defs[name] = list
      next
    end

    line = substitute_definitions(defs, line)
    paths += expand_brackets(line)
  rescue AnticipatedError => e
    raise AnticipatedError, "#{filename}:#{line_num}: error: #{e}"
  end

  paths.each do |path|
    if !path.match?(/^[\w.-]+$/)
      raise "Invalid characters in path name: #{path}"
    end
  end

  { defs: defs, paths: paths }
end

def instantiate_drvs(paths)
  cmd = 'nix-instantiate ' + paths.map { |p| "-A #{p}" }.join(' ')
  stdout_str, stderr_str, status = Open3.capture3(cmd)
  if !status.success?
    $stderr.puts stderr_str
    raise AnticipatedError, "Failed to instantiate derivations."
  end

  paths.zip(stdout_str.split).to_h
end

def nix_db
  return $db if $db
  $db = SQLite3::Database.new '/nix/var/nix/db/db.sqlite', readonly: true
end

def get_build_status(drvs)
  drv_list_str = drvs.map { |d| "\"#{d}\"" }.join(", ")
  query = <<END
select d.path, v.id
from ValidPaths d
left join DerivationOutputs o on d.id == o.drv
left join ValidPaths v on o.path == v.path
where d.path in (#{drv_list_str});
END
  r = {}
  nix_db.execute(query)
  nix_db.execute(query)
  nix_db.execute(query) do |drv, output_id|
    output_built = !output_id.nil?
    r[drv] = r.fetch(drv, true) && output_built
  end
  r
end

def print_drv_stats(built_map)
  built_count = 0
  not_built_count = 0
  built_map.each do |drv, built|
    if built
      built_count += 1
    else
      not_built_count += 1
    end
  end

  puts "Derivations built: #{built_count} out of #{built_map.size}"
end

begin
  check_directory!
  settings = parse_derivation_list('test/derivations.txt')
  path_drv_map = instantiate_drvs(settings.fetch(:paths))
  drvs = path_drv_map.values.uniq
  drv_built_map = get_build_status(drvs)
  print_drv_stats(drv_built_map)
rescue AnticipatedError => e
  puts e
end