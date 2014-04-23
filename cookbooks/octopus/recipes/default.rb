#
# Cookbook Name:: octopus
# Recipe:: default
#

# variables
current_path = "/data/#{app_name}/current"

if ['solo', 'app_master', 'app', 'util'].include?(node[:instance_role])
  # for each application
  node[:engineyard][:environment][:apps].each do |app|

    # create new shards.yml for octopus
    template "#{current_path}/config/shards.yml" do
      source 'shards.yml.erb'
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
        :slaves => node.environment.instances.select{|i| i["role"] =="db_slave"},
      })
    end
  end
end

ey_cloud_report "nginx" do 
  message "create file, #{current_path}/config/shards.yml" 
end
