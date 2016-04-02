require "bundler/gem_tasks"

desc 'Run tests'
task :test=>:preload do
  require "minitest/autorun"

  Dir.glob('./test/*.rb'){|f| require f}
end

desc 'Store root certificates to disk'
task :preload do
  system "rake", chdir: "ext"
end

task default: :test
