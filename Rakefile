require "bundler/gem_tasks"
#
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => [:spec]

require 'cucumber'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format pretty --strict"
end

task :pre_commit => [:spec, :features]

namespace :ci do
  require 'ci/reporter/rake/rspec'
  require 'ci/reporter/rake/cucumber'
  task :all => ['ci:setup:rspec', 'spec', 'ci:setup:cucumber', 'features']
end
