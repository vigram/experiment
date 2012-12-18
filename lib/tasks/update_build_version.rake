# rake "build:version[1.3.2]"
namespace "update" do
 desc "This will update the installed version no. in DB from the latest tag name"
 task :version, [:no] => :environment do |t, args|
    puts "################### Trying 1"
    tag_name = `git tag`.split("\n").last
    puts "Latest Tag No.#{tag_name}"
    version = Version.first
    version.update_attributes(:version => tag_name, :installed_dt => Time.now)
    puts "Build updated with Version No.\"#{tag_name}\""
 end
end
