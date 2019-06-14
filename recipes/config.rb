# nginx modsecurity module
template node[cookbook_name]['geoip2']['module_file'] do
    source 'geoip2_module.conf.erb'
    mode '0644'
    action node[cookbook_name]['geoip2']['enabled'] ? :create : :delete
    notifies :reload, 'service[nginx]', :delayed
end

# modsecurity configuration
template node[cookbook_name]['geoip2']['config_file'] do
    source 'geoip.conf.erb'
end
