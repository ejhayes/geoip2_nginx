def get_platform_specific(platform)
  platform_specific = {}
  case platform
  when 'ubuntu'
    platform_specific['config_file'] = '/etc/chrony/chrony.conf'
    platform_specific['service'] = 'chrony'
  end
  platform_specific
end