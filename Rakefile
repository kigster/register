# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

def shell(*args)
  puts "running: #{args.join(' ')}"
  system(args.join(' '))
end

module Register
  DIST_DIRS = %w(lib).freeze
  BIN_DIRS = %w().freeze
end

task :permissions do
  shell('rm -rf pkg/')
  Register::BIN_DIRS.each do |dir|
    shell("chmod -v o+rx,g+rx #{dir}/*")
  end

  Register::DIST_DIRS.each do |dir|
    shell("chmod -v o+rx,g+rx #{dir}")
    shell("find #{dir} -name '[a-z]*' -type d -exec chmod o+rx,g+rx {} \\; -print")
    shell("find #{dir} -type f -exec chmod o+r,g+r {} \\; -print")
  end
end

task build: :permissions

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = %w(lib/**/*.rb exe/*.rb - README.md LICENSE.txt)
  t.options.unshift('--title', 'Register - An easy way to create Mudule-level accessors to global resources')
  t.after = -> { exec('open doc/index.html') }
end

RSpec::Core::RakeTask.new(:spec)

task default: :spec
