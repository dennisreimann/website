---
title: Configuring NGINX for Phoenix applications
subtitle: Setting up SSL and static assets delivery
ogImage: phoenix
lang: en
tags:
  - Phoenix
  - Elixir
  - Nginx
  - Deployment
  - Gatling
  - Distillery
  - Tutorial
  - Ubuntu
  - Ubuntu 16
  - How To
  - Digital Ocean
---

The previous article about [deploying Phoenix with Gatling](/articles/phoenix-deployment-gatling-ubuntu-digital-ocean.html) did not go into details for a proper NGINX configuration.
Using NGINX as a front-end proxy for web applications is a pretty standard setup.
There are some things to keep in mind concerning Phoenix, SSL, and asset delivery and this article sums up the details. 

<!-- more -->

<div class="note">
  <p>**TL;DR** The goal of this article is to highlight some important config parts.
  We will not cover the basic setup of NGINX, but what goes into the webapps configuration options to make it secure, performant and easy to maintain:</p>
  <ul>
    <li>Extend a basic configuration with SSL</li>
    <li>Directives for delivering static asset via NGINX</li>
    <li>(specifics when deploying with Gatling)</li>
  </ul>
</div>

## Basic configuration with websocket proxy directives

Let's start out with the basics:
This is the raw configuration file for Phoenix that [Gatling](https://github.com/hashrocket/gatling) provides when we set up an app.
This article is not Gatling specific, but there were some questions about how to extend the initial setup which triggered me to write this up.
What you find here is general advise on how to setup NGINX for a Phoenix app – the Gatling specific parts are covered at the end.


```nginx
server {
  listen 80;
  server_name myapp.com www.myapp.com;

  location / {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://localhost:34567;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }
}
```

Basically this is just NGINX listening for requests that hit the configured domains on port 80 and proxying them to the Phoenix app that in this case runs on port 34567.

The important thing to note here are the last two `proxy_set_header` directives that upgrade the client-server connection, which is needed to use websockets and Phoenix channels.
For details see the offical blog on using [NGINX as a WebSocket Proxy](https://www.NGINX.com/blog/websocket-NGINX/) and running [Phoenix Behind a Proxy](http://www.phoenixframework.org/docs/serving-your-application-behind-a-proxy).

## Securing the app with SSL

One of the first steps I take when setting up a new webserver is securing the connections. 
Nowadays this is pretty easy and does not involve any additional costs – thanks to the [Let's Encrypt](https://letsencrypt.org/) initiative.

This guide takes off from where you already got you certificates.
If you first need to obtain a SSL certificate, Digital Ocean has a great guide on [How To Secure Nginx with Let's Encrypt](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04?refcode=63eb025a3190).
Their guide covers obtaining a SSL certificate via Let's Encrypt and automating the renewal.
Most of the following configuration also resembles the general advise given in the mentioned guide. 
*The Digital Ocean docs are really good by the way and also applicable for similar setups, not just for their boxes.*

Enough of the praise, here comes the config …

```nginx
# extract Phoenix app upstream for better readability
upstream myapp {
  server localhost:34567;
}

# hide server information
http {
  server_tokens off;
}

# redirect all http requests to https
# and also listen on IPv6 addresses
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name myapp.com www.myapp.com;

  return 301 https://$server_name$request_uri;
}

# the main server directive for ssl connections
# where we also use http2 (see asset delivery)
server {
  listen 443 ssl http2 default_server;
  listen [::]:443 ssl http2 default_server;
  server_name myapp.com www.myapp.com;

  # paths to certificate and key provided by Let's Encrypt
  ssl_certificate /etc/letsencrypt/live/myapp.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/myapp.com/privkey.pem;

  # SSL settings that currently offer good results in the SSL check
  # and have a reasonable backwards-compatibility, taken from
  # - https://cipherli.st/
  # - https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
  ssl_ecdh_curve secp384r1;
  ssl_session_cache shared:SSL:10m;
  ssl_session_tickets off;
  ssl_stapling on;
  ssl_stapling_verify on;
  ssl_dhparam /etc/ssl/certs/dhparam.pem;

  # security enhancements
  add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
  add_header X-Frame-Options DENY;
  add_header X-Content-Type-Options nosniff;

  # Let's Encrypt keeps its files here
  location ~ /.well-known {
    root /var/www/html;
    allow all;
  }

  # besides referencing the extracted upstream this stays the same
  location / {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://myapp;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }
}
```

Noteworthy parts of this rather long config change:

- Personally I prefer to extract the upstream and have it at the top of the config file. 
  But this is totally optional and you can leave it as it was.
- We integrated the SSL certificates provided by Let's Encrypt and are redirecting all unencrypted traffic to the secured connection.
- Depending on your needs you might want to change some of the SSL settings:
  The ones shown here offer a good compromise between an A+ result in the [SSL check](https://www.ssllabs.com/ssltest/index.html)
  and a reasonable backwards-compatibility. (Support for IE >= 10 and Android >= 4)

Beyond that we have also enabled `http2` support via the `listen` directive.
This gives us benefits like [connection multiplexing and low-latency transport](https://http2.github.io/faq/#what-are-the-key-differences-to-http1x), which brings us to the next point …
   
## Static asset delivery

The `mix phoenix.digest` task already takes care of preparing the assets for efficient delivery.
It adds a unique hash to the filename, which is based on the file content.
This gives us static files that are cacheable by the client forever:
Whenever the content changes a new filename will be generated which forces the client to download the new file.

The task also outputs a gzip compressed version of the file.
The webserver can directly serve the compressed version without having to generate it itself.
NGINX could handle gzipping the assets via the [gzip module](https://www.digitalocean.com/community/tutorials/how-to-add-the-gzip-module-to-nginx-on-ubuntu-16-04?refcode=63eb025a3190), but we do not have to take care of that.

By default the assets get served by the Phoenix app. 
This is not much of a problem server performance wise, but I encountered these two problems that prevent efficient file delivery:
- The `Expires` header for browser-caching does not get set, forcing the client to (re)download the file with every request.
- Even though the gzipped file is present, the uncompressed file gets sent. This means wasted traffic for the client as well as the server.

Maybe it is just me not finding the correct settings:
I tried configuring [`Plug.Static`](https://github.com/elixir-lang/plug/blob/master/lib/plug/static.ex) with the `gzip` and `headers` options, but I did not succeed – feedback and pointers in the right direction are appreciated!

So let's turn to our trusted webserver to deliver the static files efficiently.
We need to add another `location` directive inside the existing one: 
This new `location` matches all types of static files we want to deliver with NGINX.
We suppress the `ETag` header as we will be setting the maximum `Expires` date, which instructs the client to cache the file almost forever.

The `root` path needs to be set and will depend on your deployment scenario and tools. 
It is the path where the static files are stored or copied to after the `mix phoenix.digest` task has run.
Depending on how you deploy (i.e. using Distillery releases) there are different ways to get the files to this path, see this [Elixir Forum post on using Phoenix behind a proxy](https://elixirforum.com/t/phoenix-behind-a-nginx/1313/6) for details.

```nginx
server {
  # …
  location / {
    # this part stays the same, no changes, just as a reference
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://myapp;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    # asset delivery using NGINX
    location ~* ^.+\.(css|cur|gif|gz|ico|jpg|jpeg|js|png|svg|woff|woff2)$ {
      root /path/to/myapp/priv/static;
      etag off;
      expires max;
      add_header Cache-Control public;
    }
  }
}
```

When you are deploying with Gatling you could set this to the `priv/static` directory inside the folder the project is build in, i.e `/home/deploy/myapp/priv/static`.

## Applying the changes

The last step is to reload the NGINX configuration so that the changes above get applied: 

```bash
sudo service nginx reload
```

That's it, your NGINX should be serving a secure and performant webapp 🎉

In case you are deploying with Gatling, the last part is relevant to you too – otherwise you can stop reading here and enjoy your day!

## Extending the Gatling NGINX config

There isn't anything specific to the NGINX config when you are deploying with Gatling.
Except the fact that setting up a project gives you a minimalistic config file there is no magic involved:
Once Gatling has deployed the config file it won't touch it anymore.
Same goes with the port, which is the only reason Gatling provides the config – so that you do not have to enter the port manually.

Having said this you can easily adapt you config following these steps:

- Get the current nginx.conf (deployed by Gatling)
- Change it, leaving the upstream port as it is
- Overwrite the existing nginx.conf
- Reload the NGINX configuration (see above)

There isn't anything more to it.
You can then check the `nginx.conf` into version control and also delete the `domains` file.
Right now there is no way to [start out with a custom nginx.conf](https://github.com/hashrocket/gatling/issues/10).
That might change in the future and maybe also offer a way to automatically update the config on deployment – stay tuned!
