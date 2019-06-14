name 'geoip2_nginx'
maintainer 'Eric Hayes'
maintainer_email 'eric@deployfx.com'
description 'Installs/configures GeoIP2 for Ubuntu 16.04'
long_description 'Installs and configures GeoIP2 for Nginx 1.15.8 on Ubuntu 16.04.'
version '1.0.0'
chef_version '>= 12.14' if respond_to?(:chef_version)

depends 'apt'
depends 'nginx'
