namespace :db do

  def mysql_cli
    return "mysql -u root -h db -P 3306 -pFMNe0SBi4CsA9A7B"
  end

  desc 'Create database'
  task :create do
    sh 'docker-compose run --rm exchange kaigara bundle exec rake db:create'
    sh 'docker-compose run --rm account kaigara bundle exec rake db:create'
  end

  desc 'Load database dump'
  task :load => :create do
    sh %Q{cat data/mysql/nagaexchange_exchange_production.sql | docker-compose run --rm db #{mysql_cli} nagaexchange_exchange_production}
    sh %Q{cat data/mysql/nagaexchange_account_production.sql | docker-compose run --rm db #{mysql_cli} nagaexchange_account_production}
    sh 'docker-compose run --rm exchange kaigara bundle exec rake db:migrate'
    sh 'docker-compose run --rm account kaigara bundle exec rake db:migrate'
  end

  desc 'Drop all databases'
  task :drop do
    sh %q(docker-compose run --rm db /bin/sh -c "mysql -u root -h db -P 3306 -pFMNe0SBi4CsA9A7B -e 'DROP DATABASE nagaexchange_exchange_production'")
    sh %q(docker-compose run --rm db /bin/sh -c "mysql -u root -h db -P 3306 -pFMNe0SBi4CsA9A7B -e 'DROP DATABASE nagaexchange_account_production'")
    sh %q(docker-compose run --rm db /bin/sh -c "mysql -u root -h db -P 3306 -pFMNe0SBi4CsA9A7B -e 'DROP DATABASE superset'")
  end

  desc 'Database Console'
  task :console do
    sh "docker-compose run --rm db #{mysql_cli}"
  end
end
