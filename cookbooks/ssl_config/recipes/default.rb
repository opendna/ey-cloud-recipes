#
# Cookbook Name:: ssl_config
# Recipe:: default
#

if ['solo', 'app_master', 'app', 'util'].include?(node[:instance_role])

  # nginx_https_port = (meta = node[:engineyard][:environment][:apps].detect {|a| a.metadata?(:nginx_https_port) } and meta.metadata?(:nginx_https_port)) || (node.solo? ? 443 : 444)

  # for each application
  node[:engineyard][:environment][:apps].each do |app|

    # create /data/nginx/servers/#{app.name}.ssl.custom.conf
    template "/data/nginx/servers/#{app[:name]}.ssl.custom.conf" do
      source 'ssl.conf.erb'
      owner node[:users][0][:username]
      group node[:users][0][:username]
      mode 0644
      variables({
        :node => node,
        :https_bind_port => 444,
        :server_names => app[:vhosts][1][:name].empty? ? [] : [app[:vhosts][1][:name]],
        :app_name => app[:name],
        :app_type => app[:app_type],
      })
    end
  end
end