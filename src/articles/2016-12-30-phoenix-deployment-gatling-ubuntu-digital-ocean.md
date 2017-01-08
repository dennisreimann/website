---
title: Deploying Phoenix on Ubuntu with Gatling
subtitle: How To for an automated Phoenix deployment on Digital Ocean
ogImage: phoenix
lang: en
tags:
  - Phoenix
  - Elixir
  - Deployment
  - Gatling
  - Distillery
  - Tutorial
  - How To
  - Digital Ocean
  - Ubuntu
  - Ubuntu 16
  - Postgres
  - Nginx
  - Heroku
  - edeliver
  - Erlang
  - Hot Upgrade
---

There aren't many detailed posts on how to deploy Phoenix apps to production, yet.
This article is a step by step description of what I did to ship my first Phoenix app.
I hope it will be a handy resource if you are searching for an easy way to achieve an *automated deployment to a single server and leverage hot upgrades*.

<!-- more -->

<div class="note">
  <p>**TL;DR** My goal was finding a good and easily manageable way to ship my first Phoenix app.
  To keep the setup easy I am making a few assumptions:</p>

  <ul>
    <li>The build happens on the production system, no CI or separate build server involved.</li>
    <li>We deploy to a single server that hosts the app, nginx as a reverse proxy and the postgres database.
    The target server is an [Ubuntu 16.04 Digital Ocean droplet](http://www.digitalocean.com/?refcode=63eb025a3190).</li>
    <li>Achieve a Heroku-style `git push` based deployment by using [Gatling](https://github.com/hashrocket/gatling).</li>
  </ul>
</div>

The basic approach is outlined in the [official Phoenix deployment guide](http://www.phoenixframework.org/docs/advanced-deployment).
The guide offers a good introduction and gives you a basic understanding of the steps involved.
Though it describes the manual way to deploy, there are some options for automating the deployment,
like [edeliver](https://github.com/boldpoker/edeliver) (Capistrano style) or [Gatling](https://github.com/hashrocket/gatling) (Heroku style).

There are many options to go beyond this kind of setup, i.e. using a Docker-based deployment;
They all seemed to complex for getting my first app out there and Gatling offered a pragmatic way to deploy and leverage hot upgrading – that's why I have chosen it.
During the setup I came across a few rough edges what might be due to the fact that Gatling is roughly half a year old.
But before I get down to the nitty-gritty of how to deploy with Gatling, let's get the server set up …
if you already have your box up and running you can skip to the [Phoenix deployment](#phoenix-deployment) part.

## Configuring a Digital Ocean Ubuntu 16.04 droplet for Phoenix

I like Digital Ocean for its ease of use and their documentation:
You can have your server running in a performant and secure way within half a day and you do not need to be a sysadmin for that.
For a more in-depth version of what I am describing I've attached links to the Digital Ocean setup resources.
Their docs and this guide work for other hosting providers offering Ubuntu 16.04 as well –
nevertheless I was really satisfied with the smoothness of the setup process on Digital Ocean.

I assume you have followed their instructions for the
[Initial Server Setup with Ubuntu](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-14-04) and applied the
[Additional Recommended Steps for New Ubuntu Servers](https://www.digitalocean.com/community/tutorials/additional-recommended-steps-for-new-ubuntu-14-04-servers).
Though these resources target Ubuntu 14.04 they work perfectly fine with the successor version.

If you have not configured the domain and DNS for it yet, now is right time to do so.

### The deploy user

With the basic setup you have a non-root/deployment user with sudo privileges and ssh-key authentication.
**This guide refers to this user named `deploy`.**

This user currently needs password authentication when issuing `sudo` commands.
We need to change this as Gatling has some administrative tasks that are performed in non-terminal mode,
like rolling out new releases based on the post-receive git hook.

Add a new sudoers config for this particular user using the `visudo` command:

```bash
sudo visudo -f /etc/sudoers.d/deploy
```

This line will allow the `deploy` user to run `sudo` commands without password prompt:

```
deploy  ALL=(ALL) NOPASSWD:ALL
```

To learn more about this, see the guide for
[How To Edit the Sudoers File on Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file-on-ubuntu-and-centos).

## Server Prerequisites

Next up we will set up everything we need to build and run the app, namely Erlang, Elixir, Node, nginx and Postgres.
To keep it short and easy this guide sticks to system packages where possible.

### Erlang and Elixir

Install Erlang and Elixir using the commands stated in the
[official Elixir installation docs](http://elixir-lang.org/install.html#unix-and-unix-like):
This adds the Erlang Solutions repo, installs the OTP platform and Elixir.

```bash
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb && rm erlang-solutions_1.0_all.deb
sudo apt-get update
sudo apt-get install -y esl-erlang elixir
```

### Node.js

As we will build everything on the production system, we also need Node.js to compile the app assets.
This adds the official Node repo and installs the current development version of Node.js as well as the build-essential package.
The latter is needed to later on install npm packages that require compiling code from source.

```bash
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
sudo apt-get install -y nodejs build-essential
```

If you want to use the stable LTS version, you can do so by installing v6 instead of v7.
For details refer to the
[Node.js distributions guide](https://github.com/nodesource/distributions#debmanual) and
[How To Install Node.js on Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-16-04).

### Nginx

We need nginx as a reverse proxy for the Phoenix app.
In an extended setup nginx can also provide load balancing and SSL termination.
You can install it via the official package as Ubuntu 16.04 ships with a relatively up-to-date version of nginx:

```bash
sudo apt-get install nginx
```

Alternatively you can use the latest and greatest versions by using PPAs, but Gatling assumes configuration and paths that match the official distribution versions.
Keep this in mind because i.e. the
[nginx version from the Ubuntu PPA](https://www.nginx.com/resources/wiki/start/topics/tutorials/install/#ubuntu-ppa)
does not adhere to the usual paths structure and misses `sites-available` and `sites-enabled`.

### Postgres

This gives you Postgres 9.5 which is not the latest and greatest but perfectly fine for now:

```bash
sudo apt-get install postgresql
```

#### Postgres user

We also create a new user for our application.
This user needs a superuser role to create the app database and migrate its schema.
Again this user is named `deploy`:

```bash
sudo -u postgres createuser -s -P deploy
```

As postgres also expects a database with the users login name, let's create it:

```bash
sudo -u postgres createdb deploy
```

Afterwards we can verify that the login works.
Open the postgres console as deploy user executing the command `psql`
(or `psql -W` to force the password prompt and check the password).
If this works you can then leave the postgres console by typing `\q`.

## Phoenix Deployment

We are getting closer: The server has everything set up so that we can prepare our Phoenix application for deployment.
The official guide uses Exrm to build the releases, but we will use its successor [Distillery](https://github.com/bitwalker/distillery) which is required by Gatling.

**First off: This guide naively assumes the app being named `MyApp`.**<br>
Change this to your liking, your mileage may vary ;)

### Preparing the Distillery release

Whether or not you are using Phoenix or Gatling, Distillery is a good tool for building Elixir releases and it offers detailed documentation.
This guide assumes you are familiar with the basic process outlined in the [Getting Started](https://hexdocs.pm/distillery/getting-started.html) docs.
You have installed and initialized Distillery in your project and we can skip to [Using Distillery with Phoenix](https://hexdocs.pm/distillery/use-with-phoenix.html).

In you Phoenix project you have a `rel/config.exs` file which contains your release configuration.
You can use it as-is, but we need to add the `output_dir` setting for the production environment.
The reason for that: Gatling assumes the release in the `rel` directory instead of the Distillery default `_build`.

```elixir
environment :prod do
  # We need to include the Erlang Run-Time System even though
  # we deploy on the same machine that builds the release.
  # This has to be enabled to support hot upgrades.
  set include_erts: true
  # ...
  set output_dir: "rel/myapp"
end
```

Being curious about the reasoning for that setting [I opened an issue](https://github.com/hashrocket/gatling/issues/29).

### Preparing the app

We will configure the production env using environment variables.
I prefer this approach to the Phoenix' standard of a separate `prod.secret.exs` file.
Read about the details in the
[How to config environment variables with Elixir](http://blog.plataformatec.com.br/2016/05/how-to-config-environment-variables-with-elixir-and-exrm/)
post by Plataformatec to get an idea of why you might want to do that.

Without further ado, here are the relevant `config/prod.exs` parts:

```elixir
config :my_app, MyApp.Endpoint,
  # the PORT env variable will be set by Gatling in the
  # init script of the service that (re)starts the app
  http: [port: {:system, "PORT"}],
  url: [scheme: "http", host: "myapp.com", port: 80],
  cache_static_manifest: "priv/static/manifest.json",
  # configuration for the Distillery release
  root: ".",
  server: true,
  version: Mix.Project.config[:version]

config :my_app, MyApp.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :my_app, MyApp.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_DATABASE"),
  hostname: System.get_env("DB_HOSTNAME"),
  pool_size: 20

# This line appears further down. Do not forget to uncomment it!
config :phoenix, :serve_endpoints, true

# Remove the prod secret import as we configure via environment variables
# import_config "prod.secret.exs"
```

Commit this, there is some more work to do on the server …

### Setting the environment on the server

To have these environment variables available on the server, we will append them to the `/etc/environment` file.
So logged in as the `deploy` user perform these commands adjusted to your needs:

```bash
echo 'MIX_ENV=prod' | sudo tee -a /etc/environment
echo 'SECRET_KEY_BASE=TheSecretKeyBaseFromTheProdSecretFile' | sudo tee -a /etc/environment
echo 'DB_HOSTNAME=localhost' | sudo tee -a /etc/environment
echo 'DB_DATABASE=myapp_prod' | sudo tee -a /etc/environment
echo 'DB_USERNAME=deploy' | sudo tee -a /etc/environment
echo 'DB_PASSWORD=password_for_myapp_prod' | sudo tee -a /etc/environment

source /etc/environment
```

Note that we do not need to set the `PORT` environment variable as it will be set by Gatling in the init script of the service that (re)starts the app.
A propos Gatling …

### Preparing the server for Gatling

Maybe I should spend some words on [Gatling](https://github.com/hashrocket/gatling) in general first:
It is a deployment tool developed by Hashrocket and you can read more about the ideas involved in [their introduction post about Gatling](https://hashrocket.com/blog/posts/how-i-built-my-own-heroku-for-phoenix-apps-part-1).
It is an opinionated tool, but I like the assumptions and the pragmatic approach it offers.

Using Gatling we can automate the deployment and automatically build new releases triggered by a `git push` to a repository on the production server.
This comes with the prerequisite that the server needs a Git version greater than 2.0, but Ubuntu 16.04 has you covered.

First off we must install Gatling on the server.
We also need hex and rebar installed locally to fetch and install the app dependencies.
To do so, log in as the `deploy` user on the production server and execute these commands to
[install Gatling](https://github.com/hashrocket/gatling#instructions):

```bash
mix archive.install https://github.com/hashrocket/gatling_archives/raw/master/gatling.ez
mix local.hex
mix local.rebar
```

Afterwards we can initialize the app using the `load` task provided by Gatling.
This creates and sets up the Git repository we will push to later.

```bash
mix gatling.load myapp
```

The repository resides in the home directory of our `deploy` user.
Let's go back to our local development machine and do the remaining bits there …

### Configuring Gatling

First we add the newly created repository as production remote:

```bash
git remote add production deploy@myapp.com:myapp
```

Gatling requires a `domains` file in the root of the repo.
This is read by Gatlings deploy task and used to configure the server names nginx responds to:

```nohighlight
myapp.com
www.myapp.com
```

#### Deployment hooks

Gatling has hooks for every deployment step.
We add two files to the root of our project that take care of compiling the assets before they get digested.

This first file is named `deploy.exs`.
It is used for the initial deployment:

```elixir
defmodule MyApp.DeployCallbacks do
  import Gatling.Bash

  def before_mix_digest(env) do
    # mkdir prevents complains about this directory not existing
    bash("mkdir", ~w[-p priv/static], cd: env.build_dir)
    bash("npm", ~w[install], cd: env.build_dir)
    bash("npm", ~w[run deploy], cd: env.build_dir)
  end
end
```

The second file called `upgrade.exs` also performs migrations before hot upgrading the app.
It will be used every time we push to the repo after the initial deployment has happened and the app gets upgraded:

```elixir
defmodule MyApp.UpgradeCallbacks do
  import Gatling.Bash

  def before_mix_digest(env) do
    bash("npm", ~w[install], cd: env.build_dir)
    bash("npm", ~w[run deploy], cd: env.build_dir)
  end

  def before_upgrade_service(env) do
    bash("mix", ~w[ecto.migrate], cd: env.build_dir)
  end
end
```

These files look a bit different than the examples from the Gatling README.
Their examples did not work for me and I submitted a [pull request](https://github.com/hashrocket/gatling/pull/30) for that.

#### Deploying the app

You have to increase the version number in your `mix.exs` file every time you want to roll out a new release.
We are explicit about releasing by pushing to our production repository though.
In case you want a simple push based roll out, you can [have your version number set based on the commit date](https://github.com/hashrocket/gatling/blob/master/mix.example.exs).

Now we can commit, push this state to the production remote and run the initial deployment – finally!

```bash
git push production master
```

Logged in as the deploy user on our production server we need to perform the initial deployment manually by executing the Gatling deploy task:

```bash
sudo mix gatling.deploy
```

This builds the initial release, looks up an available port and configures nginx to proxy to the app and containing [the necessary settings for using websockets](https://www.nginx.com/blog/websocket-nginx/).
It also creates a `init.d` script that is used to manage the app process.
You can see the available commands for this service by running `sudo service myapp`.

If all of that worked you now have your app deployed and every successive push to the production remote will upgrade the app – congratulations!

## Recap

Wow, that seems like a heck of a lot to get a Phoenix app running in production.
Nevertheless I think it seems more complex than it actually is.
It is well worth to take on the deployment early on as afterwards you can enjoy the benefits of an automated deployment.

I hope this guide helps you and provides useful information so that you do not have to spend as much time as I did figuring out the details.
There are many options to go beyond this setup and there is also a very detailed guide on
[deploying into a multi-server load balanced setup on Digital Ocean](http://www.akitaonrails.com/2016/12/23/elixir-phoenix-app-deployed-into-a-load-balanced-digitalocean-setup)
by Fabio Akita.

In case you want to try all of this for yourself you can use my
[Digital Ocean referrer link](http://www.digitalocean.com/?refcode=63eb025a3190) to sign up there.
It will give you $10 credit to start with, which is worth two months of the lowest price droplet.
I used this type of droplet to figure out the details described in this article too.
