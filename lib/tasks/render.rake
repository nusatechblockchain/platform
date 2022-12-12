
require_relative '../nagaexchange/renderer'

namespace :render do
  desc 'Render configuration and compose files and keys'
  task :config do
    renderer = Nagaexchange::Renderer.new
    renderer.render_keys
    renderer.render
  end
end
