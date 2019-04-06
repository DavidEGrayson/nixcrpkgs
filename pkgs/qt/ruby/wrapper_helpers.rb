require 'pathname'
require 'fileutils'
include FileUtils

Os = ENV.fetch('os')
QtVersionString = ENV.fetch('version')
QtVersionMajor = QtVersionString.split('.').first.to_i

RawDir = Pathname(ENV.fetch('raw'))

OutDir = Pathname(ENV.fetch('out'))
OutPcDir = OutDir + 'lib' + 'pkgconfig'
CMakeDir = OutDir + 'lib' + 'cmake'
OutIncDir = OutDir + 'include'
BinDir = OutDir + 'bin'

DepGraph = {}
DepGraphBack = {}

case Os
when "windows"
  PrlPrefix = ''
else
  PrlPrefix = 'lib'
end

# Qt depends on some system libraries with .pc files.  It tends to only depend
# on these things at link time, not compile time.  So use pkg-config with --libs
# to get those dependencies, for use in .cmake files.
def add_deps_of_pc_files
  DepGraph.keys.each do |dep|
    next if determine_dep_type(dep) != :pc
    name = dep.chomp('.pc')
    new_deps = `pkg-config-cross --libs #{name}`.split(' ')
    raise "Failed to #{dep} libs" if $?.exitstatus != 0
    new_deps.each do |new_dep|
      add_dep dep, new_dep
    end
  end
end

def add_dep(library, *deps)
  a = DepGraph[library] ||= []
  DepGraphBack[library] ||= []
  deps.each do |dep|
    DepGraph[dep] ||= []
    a << dep unless a.include? dep
    (DepGraphBack[dep] ||= []) << library
  end
end

# Given a name of a dep in the graph, figure out what kind of dep
# it use.
def determine_dep_type(name)
  extension = Pathname(name).extname
  case
  when extension == '.a' then :a
  when extension == '.pc' then :pc
  when extension == '.x' then :x
  when name.start_with?('-I') then :incdirflag
  when name.start_with?('-L') then :libdirflag
  when name.start_with?('-l') then :ldflag
  when name.start_with?('-framework') then :ldflag
  end
end

def find_pc_file(name)
  ENV.fetch('PKG_CONFIG_CROSS_PATH').split(':').each do |dir|
    path = Pathname(dir) + name
    return path if path.exist?
  end
  nil
end

def find_file(search_dirs, name)
  search_dirs.each do |dir|
    lib = dir + name
    return lib if lib.exist?
  end
  nil
end

def find_qt_library(name)
  debug_name = Pathname(name).sub_ext("d.a").to_s
  search_dirs = [ OutDir + 'lib' ] + (OutDir + 'plugins').children
  find_file(search_dirs, name) || find_file(search_dirs, debug_name)
end

# Given an array of dependencies and a block for retrieving dependencies of an
# dependency, returns an array of dependencies with three guarantees:
#
# 1) Contains all the listed dependencies.
# 2) Has no duplicates.
# 3) For any dependency in the list, all of its dependencies are before it.
#
# Guarantee 3 only holds if the underlying graph has no circul dependencies.  If
# there is a circular dependency, it will not be detected, but it will not cause
# an infinite loop either.
def flatten_deps(deps)
  work = [].concat(deps)
  expanded = {}
  output = {}
  while !work.empty?
    dep = work.last
    if expanded[dep]
      output[dep] = true
      work.pop
    else
      expanded[dep] = true
      deps = yield dep
      work.concat(deps)
    end
  end
  output.keys  # relies on Ruby's ordered hashes
end

def canonical_x_file(dep)
  return nil if determine_dep_type(dep) != :a
  x_files = DepGraphBack.fetch(dep).select do |name|
    determine_dep_type(name) == :x
  end
  if x_files.size > 2
    raise "There is more than one .x file #{dep}."
  end
  x_files.first
end

# Note: It would be nice to find some solution so that Qt5Widgets.pc does not
# require Qt5GuiNoPlugins, since it already requires Qt5Gui.
def flatten_deps_for_pc_file(pc_file)
  flatten_deps(DepGraph.fetch(pc_file)) do |dep|
    deps = case determine_dep_type(dep)
           when :x, :pc then
             # Don't expand dependencies for a .pc file because we can just
             # refer to them with the Requires line in our .pc file.
             []
           else DepGraph.fetch(dep)
           end

    # Replace .a files with a canonical .x file if there is one.
    deps.map do |name|
      substitute = canonical_x_file(name)
      substitute = nil if substitute == pc_file
      substitute || name
    end
  end
end

def flatten_deps_for_cmake_file(cmake_file)
  flatten_deps(DepGraph.fetch(cmake_file)) do |dep|
    DepGraph.fetch(dep)
  end
end

def create_pc_file(name)
  requires = []
  libdirs = []
  ldflags = []
  cflags = []

  deps = flatten_deps_for_pc_file(name)

  deps.each do |dep|
    dep = dep.dup
    case determine_dep_type(dep)
    when :a then
      full_path = find_qt_library(dep)
      raise "Could not find library: #{dep}" if !full_path
      libdir = full_path.dirname.to_s
      libdir.sub!((OutDir + 'lib').to_s, '${libdir}')
      libdir.sub!(OutDir.to_s, '${prefix}')
      libname = full_path.basename.to_s
      libname.sub!(/\Alib/, '')
      libname.sub!(/.a\Z/, '')
      libdirs << "-L#{libdir}"
      ldflags << "-l#{libname}"
    when :x then
      dep.chomp!('.x')
      requires << dep
    when :pc then
      dep.chomp!('.pc')
      requires << dep
    when :ldflag then
      ldflags << dep
    when :libdirflag then
      libdirs << dep
    when :incdirflag then
      dep.sub!(OutIncDir.to_s, '${includedir}')
      cflags << dep
    end
  end

  pkg_name = Pathname(name).sub_ext('').to_s

  r = ""
  r << "prefix=#{OutDir}\n"
  r << "libdir=${prefix}/lib\n"
  r << "includedir=${prefix}/include\n"
  r << "Name: #{pkg_name}\n"
  r << "Version: #{QtVersionString}\n"
  if !libdirs.empty? || !ldflags.empty?
    r << "Libs: #{libdirs.reverse.uniq.join(' ')} #{ldflags.reverse.join(' ')}\n"
  end
  if !cflags.empty?
    r << "Cflags: #{cflags.join(' ')}\n"
  end
  if !requires.empty?
    r << "Requires: #{requires.sort.join(' ')}\n"
  end

  path = OutPcDir + (pkg_name + ".pc")
  File.open(path, 'w') do |f|
    f.write r
  end
end

# For .pc files we depend on, add symlinks to the .pc file and any other .pc
# files in the same directory which might be transitive dependencies.
def symlink_pc_file_closure(name)
  dep_pc_dir = find_pc_file(name).dirname
  dep_pc_dir.each_child do |target|
    link = OutPcDir + target.basename

    # Skip it if we already made this link.
    next if link.symlink?

    # Link directly to the real PC file.
    target = target.realpath

    ln_s target, link
  end
end

def create_pc_files
  mkdir OutPcDir
  DepGraph.each_key do |name|
    case determine_dep_type(name)
    when :x then create_pc_file(name)
    when :pc then symlink_pc_file_closure(name)
    end
  end
end

def set_property(f, target_name, property_name, value)
  if value.is_a?(Array)
    value = value.map do |entry|
      if entry.to_s.include?(' ')
        "\"#{entry}\""
      else
        entry
      end
    end.join(' ')
  end

  f.puts "set_property(TARGET #{target_name} " \
         "PROPERTY #{property_name} #{value})"
end

def set_properties(f, target_name, properties)
  properties.each do |property_name, value|
    set_property(f, target_name, property_name, value)
  end
end

def import_static_lib(f, target_name, properties)
  f.puts "add_library(#{target_name} STATIC IMPORTED)"
  set_properties(f, target_name, properties)
end

def create_cmake_core_files
  File.open(CMakeDir + 'core.cmake', 'w') do |f|
    f.puts "include_guard()"
    f.puts

    f.puts "set(QT_VERSION_MAJOR #{QtVersionMajor})"
    f.puts

    f.puts "add_executable(Qt5::moc IMPORTED)"
    f.puts "set_target_properties(Qt5::moc PROPERTIES"
    f.puts "  IMPORTED_LOCATION \"#{BinDir + 'moc'}\")"
    f.puts "set(Qt5Core_MOC_EXECUTABLE Qt5::moc)"

    f.puts "add_executable(Qt5::qmake IMPORTED)"
    f.puts "set_target_properties(Qt5::qmake PROPERTIES "
    f.puts "  IMPORTED_LOCATION \"#{BinDir + 'qmake'}\")"
    f.puts "set(Qt5Core_QMAKE_EXECUTABLE Qt5::qmake)"

    f.puts "add_executable(Qt5::rcc IMPORTED)"
    f.puts "set_target_properties(Qt5::rcc PROPERTIES "
    f.puts "  IMPORTED_LOCATION \"#{BinDir + 'rcc'}\")"
    f.puts "set(Qt5Core_RCC_EXECUTABLE Qt5::rcc)"

    f.write File.read(ENV.fetch('core_macros'))
  end
end

def create_cmake_config(subname)
  name = "Qt5#{subname}"

  mkdir CMakeDir + name

  a_file = find_qt_library("lib#{name}.a") || raise

  deps = flatten_deps_for_cmake_file("#{name}.x")

  incdirs = []
  libdirflags = []
  ldflags = []
  deps.each do |dep|
    dep = dep.dup
    case determine_dep_type(dep)
    when :a then
      full_path = find_qt_library(dep)
      raise "Could not find library: #{dep}" if !full_path
      libdir = full_path.dirname.to_s
      libname = full_path.basename.to_s
      libname.sub!(/\Alib/, '')
      libname.sub!(/.a\Z/, '')
      libdirflags << "-L#{libdir}"
      ldflags << "-l#{libname}"
    when :ldflag then
      ldflags << dep
    when :libdirflag then
      libdirflags << dep
    when :incdirflag then
      incdir = dep.sub(/\A-I/, '')
      incdirs << incdir
    end
  end

  File.open(CMakeDir + name + "#{name}Config.cmake", 'w') do |f|
    f.puts "include_guard()"

    import_static_lib f, "Qt5::#{subname}",
      IMPORTED_LOCATION: a_file,
      IMPORTED_LINK_INTERFACE_LANGUAGES: 'CXX',
      INTERFACE_LINK_LIBRARIES: libdirflags.reverse.uniq + ldflags.reverse,
      INTERFACE_INCLUDE_DIRECTORIES: incdirs,
      INTERFACE_COMPILE_DEFINITIONS: 'QT_STATIC'

    f.puts "include(#{CMakeDir + 'core.cmake'})"
  end
end
