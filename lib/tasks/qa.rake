# lib/tasks/qa.rake
namespace :qa do
  desc "Fail if rubycritic score >= 20"
  task :rubycritic do
    sh "bundle exec rubycritic app lib --no-browser --format json -p tmp/rubycritic"
    require "json"
    score = JSON.parse(File.read("tmp/rubycritic/report.json"))["score"]
    abort "❌ RubyCritic score #{score} >= 20" if score >= 20
    puts "✅ RubyCritic score #{score}"
  end
end
