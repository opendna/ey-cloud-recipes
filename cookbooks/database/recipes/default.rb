#
# Cookbook Name:: database
# Recipe:: default
#

if ['solo', 'app_master', 'app', 'util'].include?(node[:instance_role])
  # for each application
  node[:engineyard][:environment][:apps].each do |app|
 
    # create new database.yml
    template "/data/#{app[:name]}/shared/config/database.yml" do
      if ['loanrank'].include?(app[:name])
        source 'aws_database.yml.erb'
        owner node[:users][0][:username]
        group node[:users][0][:username]
        mode 0644
        variables({
                    :environment => node[:environment][:framework_env],
                    :adapter => 'mysql2',
                    :database => app[:database_name],
                    :username => node[:users][0][:username],
                    :password => node[:users][0][:password],
                    :host => node[:db_host],
                    :slaves => node[:engineyard][:environment][:instances].select{|i| i["role"] =="db_slave"},
                  })
      else
        source 'database.yml.erb'
        owner node[:users][0][:username]
        group node[:users][0][:username]
        mode 0644
        variables({
                    :environment => node[:environment][:framework_env],
                    :adapter => 'mysql2',
                    :database => app[:database_name],
                    :username => node[:users][0][:username],
                    :password => node[:users][0][:password],
                    :host => node[:db_host],
                    :slaves => node[:engineyard][:environment][:instances].select{|i| i["role"] =="db_slave"},
                  })
      end
    end
  end
end