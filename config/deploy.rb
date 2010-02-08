set :application, "djconseil"
set :repository,  "git@github.com:igreg/djconseil.git"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :use_sudo, false

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :user, "djconseil"
set :deploy_via, :remote_cache
set :deploy_to, "/home/#{fetch(:application)}"

role :app, "baal.igreg.info"
role :web, "baal.igreg.info"
role :db,  "baal.igreg.info", :primary => true

before "deploy:symlink", "deploy:symlinks"
before "deploy:symlink", "deploy:migrate"

namespace :deploy do
  task :symlinks do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  task :restart, :roles => :web do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  task :start, :roles => :web do
    deploy.restart
  end
end