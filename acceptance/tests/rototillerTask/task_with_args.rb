require 'beaker/hosts'
require 'rakefile_tools'

test_name 'C97795: ensure RototillerTasks can use arguments' do
  extend Beaker::Hosts
  extend RakefileTools

  rake_task_name = 'sometask'
  rakefile_contents = <<-EOS
$LOAD_PATH.unshift('/root/rototiller/lib')
require 'rototiller'

rototiller_task :#{rake_task_name}, [:arg1, :arg2] do |t, args|
  if args[:arg2]
    t.add_command({:name => "echo 'task args: #\{args\}'"})
  else
    t.add_command({:name => "echo 'task arg1: #\{args[:arg1]\}'"})
  end
end
  EOS
  rakefile_path = create_rakefile_on(sut, rakefile_contents)

  step "Execute task defined in rake task '#{rake_task_name}'" do
    # DO NOT put a space btwn the args to rake!  boo
    on(sut, "rake #{rake_task_name}[1,3]") do |result|
      assert_match(/task args: {:arg1=>"1", :arg2=>"3"}/i, result.output, '2 int args not parsed properly')
    end
    on(sut, "rake #{rake_task_name}['val1','val2']") do |result|
      assert_match(/task args: {:arg1=>"val1", :arg2=>"val2"}/i, result.output, '2 string args not parsed properly')
    end
    on(sut, "rake #{rake_task_name}['val1']") do |result|
      assert_match(/task arg1: val1/i, result.output, '1 string arg not parsed properly')
    end
  end

end
