include_recipe 'apt'

# update list of available packages
apt_update

# GeoIP data
apt_repository 'geoipupdate' do
  uri 'ppa:maxmind/ppa'
end

# install dependencies
package 'geoipupdate'
package 'libmaxminddb-dev'

# get geoip2 nginx connector
remote_file "#{node[cookbook_name]['geoip2']['nginx_connector']['path']}/ngx_http_geoip2_module.so" do
    source "#{node[cookbook_name]['geoip2']['repo']}/releases/download/#{node[cookbook_name]['geoip2']['nginx_connector']['version']}/ngx_http_geoip2_module.so"
    owner 'root'
    group 'root'
    mode 0644
    only_if { ! File.exists? "#{node[cookbook_name]['geoip2']['nginx_connector']['path']}/ngx_http_geoip2_module.so" }
end
