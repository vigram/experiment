# For complete deployment instructions, see the following support guide:
# http://www.engineyard.com/support/guides/deploying_your_application_with_capistrano

require "eycap/recipes"

# =================================================================================================
# ENGINE YARD REQUIRED VARIABLES
# =================================================================================================
# You must always specify the application and repository for every recipe. The repository must be
# the URL of the repository you want this recipe to correspond to. The :deploy_to variable must be
# the root of the application.

set :keep_releases,       5
set :user,                "system-user-name"
set :password,            "system-pwd"
set :runner,              "system-user-name"
set :repository,          "git@github.com:vigram/experiment.git"
set :branch,              "master" #Here you can specify any branch, tag or a specific SHA existing on remote
set :scm,                 :git
set :git_enable_submodules, 1
# This will execute the Git revision parsing on the *remote* server rather than locally
set :real_revision,       lambda { source.query_revision(revision) { |cmd| capture(cmd) } }


set :dbuser,              "db-user"
set :dbpass,              "db-pass"

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false

# =================================================================================================
# ROLES
# =================================================================================================
# You can define any number of roles, each of which contains any number of machines. Roles might
# include such things as :web, or :app, or :db, defining what the purpose of each machine is. You
# can also specify options that can be used to single out a specific subset of boxes in a
# particular role, like :primary => true.

# Production Machine tm29-s00021 and tm29-s00022
# ===============================================================================
task :experiment_production do
  set :use_sudo, true
  set :application,         "test"
  set :branch,              "master"
  set :deploy_to,           "app_path/#{application}"
  set :production_database, "db-name"
  set :production_dbhost,   "deploy-server-host"
  role :web, "deploy-server-host" # test1 [mongrel] [ndssystems-mysql-production-master]
  role :app, "deploy-server-host"
  role :db , "db-server-host", :primary => true
  set :rails_env, "production"
  set :environment_database, defer { production_database }
  set :environment_dbhost, defer { production_dbhost }
end

# Do not change below unless you know what you are doing!
after "deploy", "deploy:cleanup"
after "deploy:long", "deploy:cleanup"
after "deploy:migrations" , "deploy:cleanup"
after "deploy:update_code", "deploy:symlink_configs"
#after "deploy:symlink_configs", "deploy:update_swf"
#after "deploy:update_swf", "deploy:rsync_swf"
#after "passenger:restart", "dj:restart"
#after "deploy", "passenger:restart"
#after "deploy:long", "passenger:restart"
#after "deploy:symlink_configs", "deploy:custom_symlink"
after "deploy", "installed_version:update"

namespace :deploy do
  desc "Symlink necessary directories"
  task :custom_symlink, :roles => :app, :except => {:no_release => true} do
    run "ln -nfs #{shared_path}/images/ #{release_path}/public/"
    run "ln -nfs #{shared_path}/uploads #{release_path}/public/"
    run "ln -nfs #{shared_path}/images/favicon.ico #{release_path}/public/favicon.ico"
  end

end

namespace :nginx do
  desc "Restart the Nginx processes on the app slices."
  task :restart , :roles => :app, :except => {:nginx => false} do
    sudo "/etc/init.d/nginx restart"
  end
end

namespace :pending do
  desc <<-DESC
      Displays the `diff' since your last deploy. This is useful if you want \
      to examine what changes are about to be deployed. Note that this might \
      not be supported on all SCM's.
  DESC
  task :diff, :except => { :no_release => true } do
    system(source.local.diff(current_revision))
  end

  desc <<-DESC
      Displays the commits since your last deploy. This is good for a summary \
      of the changes that have occurred since the last deploy. Note that this \
      might not be supported on all SCM's.
  DESC
  task :default, :except => { :no_release => true } do
    from = source.next_revision(current_revision)
    system(source.local.log(from))
  end
end

namespace :installed_version do
 task :update, :roles => :app, :except => { :no_release => true } do
   puts "###################### updating version##################"
   run "cd #{current_path} && RAILS_ENV=#{rails_env} rake update:version"
 end
end

# uncomment the following to have a database backup done before every migration
before "deploy:migrate", "db:dump"
