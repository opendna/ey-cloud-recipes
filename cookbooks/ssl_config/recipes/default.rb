#
# Cookbook Name:: ssl_config
# Recipe:: default
#

if ['solo', 'app_master', 'app', 'util'].include?(node[:instance_role])

  nginx_https_port = (node[:instance_role] == 'solo' ? 443 : 444)

  # for each application
  node[:engineyard][:environment][:apps].each do |app|
    
    # create /data/nginx/servers/#{app[:name]}.ssl.custom.conf
    conf_file = "/data/nginx/servers/#{app[:name]}.ssl.custom.conf"
    
    # create include file
    # /etc/nginx/servers/#{app[:name]}/custom.ssl.conf
    inc_file = "/data/nginx/servers/#{app[:name]}/custom.ssl.conf"

    if File.exist?("/data/nginx/ssl/#{app[:name]}.crt") && File.exist?("/data/nginx/ssl/#{app[:name]}.key")
      template conf_file do
        source 'ssl.conf.erb'
        owner node[:users][0][:username]
        group node[:users][0][:username]
        mode 0644
        variables({
          :node => node,
          :https_bind_port => nginx_https_port,
          :server_names => app[:vhosts][0][:domain_name].empty? ? [] : [app[:vhosts][0][:domain_name]],
          :app_name => app[:name],
          :app_type => app[:app_type],
        })
      end
    else
      if File.exist?(conf_file)
        File.delete conf_file
      end
    end

    # custom.ssl.confは初回のみ作成
    unless File.exist?(inc_file)
      template inc_file do
        source 'custom.ssl.conf'
        owner node[:users][0][:username]
        group node[:users][0][:username]
        mode 0644
      end
    end
  end
end