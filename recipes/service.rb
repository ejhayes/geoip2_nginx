# pull in data files
execute 'Get GeoIP data' do
    command "/usr/bin/geoipupdate"
    creates "#{node[cookbook_name]['geoip2']['country_file']}"
end

cron 'geoipupdate' do
  action node[cookbook_name]['geoip2']['enabled'] ? :create : :delete
  minute node[cookbook_name]['geoip2']['update_schedule']['minute']
  hour node[cookbook_name]['geoip2']['update_schedule']['hour']
  weekday node[cookbook_name]['geoip2']['update_schedule']['day']
  command '/usr/bin/geoipupdate'
end