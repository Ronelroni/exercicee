# config valid only for current version of Capistrano
lock '3.16.0'
# Nom de l'application à déployer
set :application, 'exercice'
# dépôt git à cloner
# (Xxxxxxxx: nom d'utilisateur, yyyyyyyy: nom de l'application)
set :repo_url, 'https://github.com/Ronelroni/exercicee.git'
# deployするブランチ。デフォルトでmainを使用している場合、masterをmainに変更してください。
set :branch, ENV['BRANCH'] || 'master'
# Le répertoire dans lequel effectuer le déploiement.
set :deploy_to, '/var/www/exercie'
# Dossiers / fichiers avec liens symboliques
set :linked_files, %w{.env config/secrets.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets public/uploads}
# Nombre de versions à conserver (* décrit plus loin)
set :keep_releases, 5
# Version rubis
set :rbenv_ruby, '3.0.2'
set :rbenv_type, :system
# Le niveau de journalisation à sortir. Si vous voulez voir le journal des erreurs en détail, définissez-le sur: debug.
# 本番環境用のものであれば、 :info程度が普通。
# Cependant, si vous souhaitez confirmer le comportement, définissez-le sur: debug.
set :log_level, :info
namespace :deploy do
  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
  end
  desc 'Create database'
  task :db_create do
    on roles(:db) do |host|
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, 'db:create'
        end
      end
    end
  end
  desc 'Run seed'
  task :seed do
    on roles(:app) do
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, 'db:seed'
        end
      end
    end
  end
  after :publishing, :restart
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end
end