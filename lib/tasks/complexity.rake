# lib/tasks/complexity.rake
namespace :qa do
  desc "Fail if any method has cyclomatic complexity >= 10"
  task :saikuro do
    require "json"
    sh "saikuro -c -p app lib -o tmp/saikuro"
    # saikuro doesn't emit JSON; parse its text output:
    output = `saikuro -c -p app lib 2>&1`
    bad = output.scan(/Complexity:\s*(\d+).*?Method:\s*(\S+)/).select { |c, _| c.to_i >= 10 }
    abort "❌ High complexity: #{bad.inspect}" if bad.any?
    puts "✅ All methods < 10"
  end
end
