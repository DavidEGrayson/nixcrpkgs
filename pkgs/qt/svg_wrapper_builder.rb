STDOUT.sync = true
ENV['PATH'] = ENV.fetch('_PATH')
require 'wrapper_helpers'

add_dep 'Qt5Svg.x', 'libQt5Svg.a'

generate_output
