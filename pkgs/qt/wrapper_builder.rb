STDOUT.sync = true
ENV['PATH'] = ENV.fetch('_PATH')
require 'wrapper_helpers'

def make_dep_graph
  # High-level dependencies.
  add_dep 'Qt5OpenGL.x', 'libQt5OpenGL.a'
  add_dep 'Qt5OpenGL.x', 'Qt5WidgetsNoPlugins.x'
  add_dep 'Qt5Network.x', 'libQt5Network.a'
  add_dep 'Qt5Network.x', 'Qt5Core.x'
  add_dep 'Qt5Concurrent.x', 'libQt5Concurrent.a'
  add_dep 'Qt5Concurrent.x', 'Qt5Core.x'
  add_dep 'Qt5Xml.x', 'libQt5Xml.a'
  add_dep 'Qt5Xml.x', 'Qt5Xml.x'
  add_dep 'Qt5Test.x', 'libQt5Test.a'
  add_dep 'Qt5Test.x', 'Qt5Text.x'
  add_dep 'Qt5Widgets.x', 'Qt5WidgetsNoPlugins.x'
  add_dep 'Qt5WidgetsNoPlugins.x', 'libQt5Widgets.a'
  add_dep 'Qt5WidgetsNoPlugins.x', 'Qt5Gui.x'
  add_dep 'Qt5Gui.x', 'Qt5GuiNoPlugins.x'
  add_dep 'Qt5GuiNoPlugins.x', 'libQt5Gui.a'
  add_dep 'Qt5GuiNoPlugins.x', 'Qt5Core.x'
  add_dep 'Qt5Core.x', 'libQt5Core.a'

  # Include directories.
  add_dep 'Qt5Core.x', '-I' + OutIncDir.to_s
  add_dep 'Qt5Core.x', '-I' + (OutIncDir + 'QtCore').to_s
  add_dep 'Qt5GuiNoPlugins.x', '-I' + (OutIncDir + 'QtGui').to_s
  add_dep 'Qt5WidgetsNoPlugins.x', '-I' + (OutIncDir + 'QtWidgets').to_s

  # Libraries that Qt depends on.
  add_dep 'libQt5Widgets.a', 'libQt5Gui.a'
  add_dep 'libQt5FontDatabaseSupport.a', 'libqtfreetype.a'
  add_dep 'libQt5Gui.a', 'libQt5Core.a'
  add_dep 'libQt5Gui.a', 'libqtlibpng.a'
  add_dep 'libQt5Gui.a', 'libqtharfbuzz.a'
  add_dep 'libQt5Core.a', 'libqtpcre2.a'

  if Os == 'windows'
    add_dep 'Qt5Gui.x', 'qwindows.x'

    add_dep 'qwindows.x', 'libqwindows.a'

    add_dep 'libqwindows.a', '-ldwmapi'
    add_dep 'libqwindows.a', '-limm32'
    add_dep 'libqwindows.a', '-loleaut32'
    add_dep 'libqwindows.a', '-lwtsapi32'
    add_dep 'libqwindows.a', 'libQt5Gui.a'
    add_dep 'libqwindows.a', 'libQt5EventDispatcherSupport.a'
    add_dep 'libqwindows.a', 'libQt5FontDatabaseSupport.a'
    add_dep 'libqwindows.a', 'libQt5ThemeSupport.a'
    add_dep 'libqwindows.a', 'libQt5WindowsUIAutomationSupport.a'

    add_dep 'Qt5Widgets.x', 'qwindowsvistastyle.x'
    add_dep 'qwindowsvistastyle.x', 'libqwindowsvistastyle.a'

    add_dep 'libqwindowsvistastyle.a', '-luxtheme'
    add_dep 'libqwindowsvistastyle.a', 'libQt5Widgets.a'

    add_dep 'libQt5Core.a', '-lnetapi32'
    add_dep 'libQt5Core.a', '-lole32'
    add_dep 'libQt5Core.a', '-luserenv'
    add_dep 'libQt5Core.a', '-luuid'
    add_dep 'libQt5Core.a', '-lversion'
    add_dep 'libQt5Core.a', '-lwinmm'
    add_dep 'libQt5Core.a', '-lws2_32'

    add_dep 'libQt5Gui.a', '-lopengl32'
  end

  if Os == 'linux'
    add_dep 'Qt5Gui.x', 'qlinuxfb.x'
    add_dep 'Qt5Gui.x', 'qxcb.x'
    add_dep 'qlinuxfb.x', 'libqlinuxfb.a'
    add_dep 'qxcb.x', 'libqxcb.a'

    add_dep 'libqlinuxfb.a', 'libQt5FbSupport.a'
    add_dep 'libqlinuxfb.a', 'libQt5InputSupport.a'

    add_dep 'libqxcb.a', 'libQt5XcbQpa.a'

    add_dep 'libQt5DBus.a', 'libQt5Core.a'
    add_dep 'libQt5DBus.a', 'libQt5Gui.a'
    add_dep 'libQt5DeviceDiscoverySupport.a', 'libudev.pc'
    add_dep 'libQt5InputSupport.a', 'libQt5DeviceDiscoverySupport.a'
    add_dep 'libQt5LinuxAccessibilitySupport.a', 'libQt5AccessibilitySupport.a'
    add_dep 'libQt5LinuxAccessibilitySupport.a', 'libQt5DBus.a'
    add_dep 'libQt5LinuxAccessibilitySupport.a', 'xcb-aux.pc'
    add_dep 'libQt5ThemeSupport.a', 'libQt5DBus.a'

    add_dep 'libQt5XcbQpa.a', 'libQt5EdidSupport.a'
    add_dep 'libQt5XcbQpa.a', 'libQt5EventDispatcherSupport.a'
    add_dep 'libQt5XcbQpa.a', 'libQt5FontDatabaseSupport.a'
    add_dep 'libQt5XcbQpa.a', 'libQt5Gui.a'
    add_dep 'libQt5XcbQpa.a', 'libQt5LinuxAccessibilitySupport.a'
    add_dep 'libQt5XcbQpa.a', 'libQt5ServiceSupport.a'
    add_dep 'libQt5XcbQpa.a', 'libQt5ThemeSupport.a'
    add_dep 'libQt5XcbQpa.a', 'x11.pc'
    add_dep 'libQt5XcbQpa.a', 'x11-xcb.pc'
    add_dep 'libQt5XcbQpa.a', 'xcb.pc'
    add_dep 'libQt5XcbQpa.a', 'xcb-icccm.pc'
    add_dep 'libQt5XcbQpa.a', 'xcb-image.pc'
    add_dep 'libQt5XcbQpa.a', 'xcb-keysyms.pc'
    add_dep 'libQt5XcbQpa.a', 'xcb-randr.pc'
    add_dep 'libQt5XcbQpa.a', 'xcb-renderutil.pc'
    add_dep 'libQt5XcbQpa.a', 'xcb-shape.pc'
    add_dep 'libQt5XcbQpa.a', 'xcb-shm.pc'
    add_dep 'libQt5XcbQpa.a', 'xcb-sync.pc'
    add_dep 'libQt5XcbQpa.a', 'xcb-xfixes.pc'
    add_dep 'libQt5XcbQpa.a', 'xcb-xinerama.pc'
    add_dep 'libQt5XcbQpa.a', 'xcb-xinput.pc'
    add_dep 'libQt5XcbQpa.a', 'xcb-xkb.pc'
    add_dep 'libQt5XcbQpa.a', 'xi.pc'
    add_dep 'libQt5XcbQpa.a', 'xkbcommon.pc'
    add_dep 'libQt5XcbQpa.a', 'xkbcommon-x11.pc'
  end

  if Os == 'macos'
    add_dep 'Qt5Gui.x', 'qcocoa.x'
    add_dep 'qcocoa.x', 'libqcocoa.a'

    add_dep 'libqcocoa.a', 'libcocoaprintersupport.a'
    add_dep 'libqcocoa.a', 'libQt5AccessibilitySupport.a'
    add_dep 'libqcocoa.a', 'libQt5ClipboardSupport.a'
    add_dep 'libqcocoa.a', 'libQt5GraphicsSupport.a'
    add_dep 'libqcocoa.a', 'libQt5FontDatabaseSupport.a'
    add_dep 'libqcocoa.a', 'libQt5ThemeSupport.a'
    add_dep 'libqcocoa.a', 'libQt5PrintSupport.a'
    add_dep 'libqcocoa.a', '-lcups'  # Also available: -lcups.2
    add_dep 'libqcocoa.a', '-framework IOKit'
    add_dep 'libqcocoa.a', '-framework CoreVideo'
    add_dep 'libqcocoa.a', '-framework Metal'
    add_dep 'libqcocoa.a', '-framework QuartzCore'

    add_dep 'libqtlibpng.a', '-lz'

    add_dep 'libQt5Core.a', '-lobjc'
    add_dep 'libQt5Core.a', '-framework CoreServices'
    add_dep 'libQt5Core.a', '-framework CoreText'
    add_dep 'libQt5Core.a', '-framework Security'
    add_dep 'libQt5Gui.a', '-framework CoreGraphics'
    add_dep 'libQt5Gui.a', '-framework OpenGL'
    add_dep 'libQt5Widgets.a', '-framework Carbon'
    add_dep 'libQt5Widgets.a', '-framework AppKit'
  end

  add_deps_of_pc_files
end

def create_cmake_main_config
  mkdir CMakeDir + 'Qt5'

  File.open(CMakeDir + 'Qt5' + 'Qt5Config.cmake', 'w') do |f|
    f.puts <<END
include_guard()

if (NOT Qt5_FIND_COMPONENTS)
  set (Qt5_NOT_FOUND_MESSAGE "The Qt5 package requires at least one component")
  set (Qt5_FOUND False)
  return ()
endif ()

set (_Qt5_FIND_PARTS_REQUIRED)
if (Qt5_FIND_REQUIRED)
  set (_Qt5_FIND_PARTS_REQUIRED REQUIRED)
endif ()
set (_Qt5_FIND_PARTS_QUIET)
if (Qt5_FIND_QUIETLY)
  set (_Qt5_FIND_PARTS_QUIET QUIET)
endif ()

set (_qt5_install_prefix "#{OutDir}")

set (_Qt5_NOTFOUND_MESSAGE)

foreach (module ${Qt5_FIND_COMPONENTS})
  find_package (Qt5${module}
    ${_Qt5_FIND_PARTS_QUIET}
    ${_Qt5_FIND_PARTS_REQUIRED}
    PATHS ${_qt5_install_prefix} NO_DEFAULT_PATH
  )
  if (NOT Qt5${module}_FOUND)
    if (Qt5_FIND_REQUIRED_${module})
      set (_Qt5_NOTFOUND_MESSAGE "${_Qt5_NOTFOUND_MESSAGE}Failed to find Qt5 component \\"${module}\\" config file.\\n")
    elseif (NOT Qt5_FIND_QUIETLY)
      message(WARNING "Could not find Qt5 component \\"${module}\\" config file.")
    endif ()
  endif()
endforeach()

if (_Qt5_NOTFOUND_MESSAGE)
  set(Qt5_NOT_FOUND_MESSAGE "${_Qt5_NOTFOUND_MESSAGE}")
  set(Qt5_FOUND False)
endif()
END
  end
end

make_dep_graph

generate_output

create_cmake_core_files
create_cmake_config('Core')
create_cmake_config('Concurrent')
create_cmake_config('Gui')
create_cmake_config('Network')
create_cmake_config('OpenGL')
create_cmake_config('Test')
create_cmake_config('Widgets')
create_cmake_config('Xml')
create_cmake_main_config

