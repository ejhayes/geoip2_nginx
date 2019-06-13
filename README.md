Building the module (assuming for Nginx 1.15.8):

    apt-get install build-essential libmaxminddb-dev libpcre3-dev zlib1g-dev libperl-dev libxslt-dev libssl-dev libgeoip-dev libgd2-dev -y

    git clone https://github.com/leev/ngx_http_geoip2_module.git

    curl -O http://nginx.org/download/nginx-1.15.8.tar.gz
    tar -xvzf nginx-1.15.8.tar.gz
    cd nginx-1.15.8

    # get config options with `nginx -V`
    ./configure --add-dynamic-module=../ngx_http_geoip2_module --with-cc-opt='-g -O2 -fPIC -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-z,relro -Wl,-z,now' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/^Cinx/uwsgi --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_dav_module --with-http_flv_module --with-http_geoip_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_mp4_module --with-http_perl_module --with-http_random_index_module --with-http_secure_link_module --with-http_v2_module --with-http_sub_module --with-http_xslt_module --with-mail --with-mail_ssl_module --with-stream --with-stream_ssl_module --with-threads

    make

Also need to install GeoIP2 data:

    apt-add-repository ppa:maxmind/ppa
    apt-get update
    apt-get install geoipupdate mmdb-bin -y 

Config file is at: `/etc/GeoIP.conf`

Data files are at: `/usr/share/GeoIP`

Need to add to crontab (can use `crontab -e`):

    # Chef Name: geoipupdate
    0 0 * * 1 /usr/bin/geoipupdat

Then copy to `/usr/share/nginx/modules`

Confirm with `nginx -t`

And load the module in `/etc/nginx/nginx.conf`

    ...
    load_module modules/ngx_http_geoip2_module.so;
    ...

And to configure the IP address....

Checking an IP address:

    mmdblookup --ip xx.yy.zz.aa --file /usr/share/GeoIP/GeoLite2-City.mmdb city names en

Should return city information.

Config file `/etc/nginx/conf.d/geoip.conf`:

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

And for any site you can add additional headers to show geo information:

    add_header X-GeoCountry $geoip2_data_country_name;
    add_header X-GeoCode $geoip2_data_country_code;
    add_header X-GeoCode $geoip2_data_state_code;
    add_header X-GeoCity $geoip2_data_city_name;

Then curl to see the result:

    $ curl localhost:8090/nginx_status -v -H 'X-Forwarded-For: 127.0.0.1'
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

Installing module on a new system:

    apt-get install -y 

Also need to install `geoipupdate` from `ppa:maxmind/ppa`.
