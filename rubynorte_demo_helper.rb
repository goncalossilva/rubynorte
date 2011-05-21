require 'colorize'
require 'pty'

def execute(cmd)
  begin
    PTY.spawn(cmd) do |r, w, pid|
      begin
        r.each { |line| print line }
      rescue Errno::EIO
      end
   end
  rescue PTY::ChildExited
  end
end

def copy_to_clipboard(cmd)
  
  IO.popen("xsel --clipboard", "w") { |clipboard| clipboard.print cmd }
end

commands =
  ["rvm 1.9.2-gcdata",

  "=== Editing the Gemfile ===",
  "g Gemfile",
  "gem 'ruby-prof', :git => 'git://github.com/wycats/ruby-prof.git'\n\
gem 'rails', :git => 'git://github.com/rails/rails.git'\n\
gem 'rack', :git => 'git://github.com/rack/rack.git'\n\
gem 'arel', :git => 'git://github.com/rails/arel.git'\n\
gem 'sprockets', :git => 'git://github.com/sstephenson/sprockets.git'",
  "bundle install",

  "=== Generating the scaffold test ===",
  "script/rails generate performance_test homepage",
  "g test/performance/homepage_test.rb",
  "# all good - no need to edit",

  "=== Let's try benchmarking ===",
  "rake test:benchmark",

  "=== Now for a more complex test ===",
  "script/rails generate performance_test submission",
  "g test/performance/submission_test.rb # change test_homepage to test_submission",
  "post '/talks', :talk => { :person => 'RubyNorte', :title => 'Test', :summary => 'Performance test' }",
  "rake test:benchmark",

  "=== Both very lightweight. Let's add garbage ===",
  "g app/controllers/content_controller.rb",
  "500000.times { a = Hash.new }",
  "rake test:benchmark",

  "=== All results are stored ===",
  "ls tmp/performance",
  "g tmp/performance/HomepageTest#test_homepage_objects.csv",
  "# just an overview",
  "rm tmp/performance/*",

  "=== Let's try profiling ===",
  "rake test:profile",
  "ls tmp/performance",
  "google-chrome file:///home/goncalossilva/Projects/Development/rubynorte/tmp/performance/SubmissionTest%23test_homepage_process_time_graph.html file:///home/goncalossilva/Projects/Development/rubynorte/tmp/performance/SubmissionTest%23test_homepage_process_time_stack.html",

  "=== Let's look at Rails' utilities ===",
  "script/rails benchmarker --help",
  "script/rails benchmarker 'Talk.all' 'Admission.all' --runs 1",
  "script/rails profiler 'Talk.first' 'Admission.first' --formats flat,call_stack",

  "=== And all of this works under Rubinius and JRuby! ===",
  "rvm rubinius",
  "g Gemfile # comment ruby-prof",
  "# just comment ruby-prof",
  "bundle install",
  "script/rails benchmarker 'Talk.all' 'Admission.all' --runs 1",
  "=== Thanks! Bye! ==="]

enumerator = commands.to_enum
loop do
  begin
    cmd = enumerator.next
  rescue StopIteration
    break
  end
  
  if cmd =~ /^===/
    print "# #{cmd.underline}"
  else
    print "$ #{cmd}"
    copy_to_clipboard cmd
    if cmd =~ /^g /
      copy_to_clipboard enumerator.next
    end
    if cmd =~ /^g |google-chrome/
      execute cmd
    end
  end
  
  gets
end
