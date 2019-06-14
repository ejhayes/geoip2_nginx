# Nginx GeoIP2 Module
Supports setting up and configuring GeoIP2 module for Nginx. These instructions are for:

- Nginx 1.15.8
- Ubuntu 16.04
- GeoIP2 module from: https://github.com/leev/ngx_http_geoip2_module

## Building the module
To build the module, do this (on Ubuntu 16.04):

    cd /tmp

    # install dependencies
    apt-get install build-essential libmaxminddb-dev libpcre3-dev zlib1g-dev libperl-dev libxslt-dev libssl-dev libgeoip-dev libgd2-dev git -y

    # get the geoip2 module
    git clone https://github.com/leev/ngx_http_geoip2_module.git

    # get nginx source
    curl -O http://nginx.org/download/nginx-1.15.8.tar.gz
    tar -xvzf nginx-1.15.8.tar.gz
    cd nginx-1.15.8

    # get config options with `nginx -V` and pass to `configure`
    ./configure --add-dynamic-module=../ngx_http_geoip2_module --with-cc-opt='-g -O2 -fPIC -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-z,relro -Wl,-z,now' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/^Cinx/uwsgi --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_dav_module --with-http_flv_module --with-http_geoip_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_mp4_module --with-http_perl_module --with-http_random_index_module --with-http_secure_link_module --with-http_v2_module --with-http_sub_module --with-http_xslt_module --with-mail --with-mail_ssl_module --with-stream --with-stream_ssl_module --with-threads

    make

The module will then be available at: `./objs/ngx_http_geoip2_module.so`

## Using the built module

### Install dependencies
To use the module you'll need to install some stuff:

    apt-get update
    apt-get install -y software-properties-common
    apt-add-repository ppa:maxmind/ppa
    apt-get update
    apt-get install geoipupdate libmaxminddb-dev -y 

    # grab data files
    geoipupdate

If you want to use the `mmdblookup` tool you'll need to also install `mmdb-bin`. Example usage looks like this:

    mmdblookup --ip xx.yy.zz.aa --file /usr/share/GeoIP/GeoLite2-City.mmdb city names en

If you have a paid subscription, you'll need to update `/etc/GeoIP.conf` to use your license key, etc. The populated data files are located at `/usr/share/GeoIP/*.mmdb`.

### Update cron
Data files need to be refreshed periodically. Add the following cron (`crontab -e`):

    0 0 * * 1 /usr/bin/geoipupdat

### Update Nginx
Add `ngx_http_geoip2_module.so` to `/usr/share/nginx/modules`.

Then update `/etc/nginx/nginx.conf` to include:

    ...
    load_module modules/ngx_http_geoip2_module.so;
    ...

If you're behind a load balancer you'll also want to specify the correct IP address (forwarded in the `X-Forwarded-For` header):

    set_real_ip_from 127.0.0.1;
    real_ip_header X-Forwarded-For;
    real_ip_recursive off;

And add the following configuration to `/etc/nginx/conf.d/geoip2.conf`:

    geoip2 /usr/share/GeoIP/GeoLite2-Country.mmdb {
        auto_reload 60m;
        $geoip2_metadata_country_build metadata build_epoch;
        $geoip2_data_country_code country iso_code;
        $geoip2_data_country_name country names en;
    }
    geoip2 /usr/share/GeoIP/GeoLite2-City.mmdb {
        auto_reload 60m;
        $geoip2_metadata_city_build metadata build_epoch;
        $geoip2_data_state_code subdivisions 0 iso_code;
        $geoip2_data_city_name city names en;
    }

### Dummy site configuration
Here's a dummy site configuration you can use (assuming use of `X-Forwarded-For` header):

    server {
        listen 8090;
        server_name _;

        # include geo headers (testing purposes only)
        add_header X-GeoCountry $geoip2_data_country_name;
        add_header X-GeoCode $geoip2_data_country_code;
        add_header X-GeoCode $geoip2_data_state_code;
        add_header X-GeoCity $geoip2_data_city_name;

        location / {
            stub_status on;
            access_log off;
        }
    }

### Test it out
Then curl to see the result:

    $ curl localhost:8090 -v -H 'X-Forwarded-For: xx.yy.zz.aa'
    *   Trying 127.0.0.1...
    * Connected to localhost (127.0.0.1) port 8090 (#0)
    > GET /nginx_status HTTP/1.1
    > Host: localhost:8090
    > User-Agent: curl/7.47.0
    > Accept: */*
    > X-Forwarded-For: 127.0.0.1
    > 
    < HTTP/1.1 200 OK
    < Date: Thu, 13 Jun 2019 23:29:30 GMT
    < Content-Type: text/plain
    < Content-Length: 100
    < Connection: keep-alive
    < Keep-Alive: timeout=5
    < X-GeoCountry: United States
    < X-GeoCode: US
    < X-GeoCity: San Francisco
    < X-GeoState: CA
    < 
    ...


