#
# Cookbook:: base
# Recipe:: default
#

include_recipe "#{cookbook_name}::package"
include_recipe "#{cookbook_name}::config"
include_recipe "#{cookbook_name}::service"
