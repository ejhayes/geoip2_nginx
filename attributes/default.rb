cookbook_name = 'geoip2_nginx'

# geoip2 configuration
default[cookbook_name]['geoip2']['enabled'] = true
default[cookbook_name]['geoip2']['account_id'] = '0'
default[cookbook_name]['geoip2']['license_key'] = '000000000000'
default[cookbook_name]['geoip2']['edition_ids'] = 'GeoLite2-Country GeoLite2-City'
default[cookbook_name]['geoip2']['auto_reload_duration'] = '60m'

# update schedule
default[cookbook_name]['geoip2']['update_schedule']['hour'] = '0'
default[cookbook_name]['geoip2']['update_schedule']['minute'] = '0'
default[cookbook_name]['geoip2']['update_schedule']['day'] = '1'

default[cookbook_name]['geoip2']['repo'] = 'https://github.com/ejhayes/geoip2_nginx'
default[cookbook_name]['geoip2']['config_file'] = '/etc/GeoIP.conf'
default[cookbook_name]['geoip2']['module_file'] = '/etc/nginx/conf.d/geoip2.conf'
default[cookbook_name]['geoip2']['country_file'] = '/usr/share/GeoIP/GeoLite2-Country.mmdb'
default[cookbook_name]['geoip2']['city_file'] = '/usr/share/GeoIP/GeoLite2-City.mmdb'
default[cookbook_name]['geoip2']['nginx_connector']['version'] = '1.0.0'
default[cookbook_name]['geoip2']['nginx_connector']['path'] = '/usr/share/nginx/modules'

# overwrite nginx configuration
default['nginx']['load_modules'] += ['modules/ngx_http_geoip2_module.so']