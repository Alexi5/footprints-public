[![Build Status](https://travis-ci.org/mongeeses/footprints-public.svg?branch=develop)](https://travis-ci.org/mongeeses/footprints-public)
# Footprints

This program is an applicant tracking tool that allows users to manage the employee hiring process from start to finish.

To run this program, first copy the repository url from github, then run
`git clone [url]` in your terminal to make a local copy of the repo.

## Running Footprints using Docker

Using Docker to run Footprints will allow you to avoid the annoying step of
managing multiple versions of Ruby on your host OS, and will hopefully also
make it easier to run on a non-Mac environment.

1. Local Footprints is configured to be accessed at [https://footprints.localdev](https://footprints.localdev).
In order to do this, you'll need to first update your `/etc/hosts` file:

```bash
sudo vim /etc/hosts

# enter your password
# at the end of the file, insert:

127.0.0.1    footprints.localdev
```

Then follow the "Connecting Locally via HTTPS" instructions below.

2. [Install the appropriate version of Docker](https://www.docker.com/get-started) for your host OS

3. Once your local Docker agent is running, [use Docker Compose](https://docs.docker.com/compose/) to bring up the Rails environment:

```bash
cd /path/to/footprints-public

docker-compose up
```

4. Next, you'll need to seed your DB:

```bash
cd /path/to/footprints-public

docker-compose exec ruby bash

bin/rake db:reset
```

This step should run the Rails application, **which may fail if you have not run the migrations yet**. Browse to [https://footprints.localdev](https://footprints.localdev) and you should see a web application running.

5. To manage gems, or run Rails, Bundler, or Rake commands, you will want to do that from inside of the running Ruby container:

```bash
cd /path/to/footprints-public

docker-compose exec ruby bash
```

6. To run the migrations, use the instructions from the previous step to open a bash session inside of the running `ruby` container, and then execute the command `bin/rake db:migrate` to run all of the migrations.

7. To see logs from the application, use this command:

```bash
cd /path/to/footprints-public

docker-compose logs -f ruby
```

8. To bring the application back down, run `docker-compose down`

## Running Footprints using Docker Machine

If you are running Docker Machine instead of Docker for Mac, it may be necesssary
to manually define an NFS volume mount using `docker-machine-nfs`. This is more
likely to be the case if you are an ActiveCampaign employee.

You will know that this step is necessary if you see an error stating that an
OCI runtime error has occurred due to a file not existing, most likely the file
`/app/docker-entry.sh`.

```bash
cd /path/to/footprints-public

docker-machine-nfs default -f --shared-folder=$(pwd) --mount-opts="async,noatime,actimeo=1,nolock,vers=3,udp"
```

## Connecting Locally via HTTPS

The cert files needed by Nginx live in this repository under `docker/nginx`. They were generated using the command:

```bash
openssl req -x509 -out footprints.crt -keyout footprints.key \
  -newkey rsa:2048 -nodes -sha256 -days 365 \
  -subj '/CN=footprints.localdev' -extensions EXT -config <( \
   printf "[dn]\nCN=footprints.localdev\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=@alt_names\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth\n[alt_names]\nDNS.1 = footprints.localdev\nIP.1 = 127.0.0.1")
```

This alone is enough to power SSL connections, however, our browsers will not trust the cert
as it was self-signed by an 'untrusted' signer (our own machine). To fix this, we need to tell
our machines that they can trust the signer:

  * Open Keychain Access on you mac
  * Select System and go to File -> Import Items
  * Navigate to footprints-public/docker/nginx and select the file footprints.key. You will be asked for your password.
  * Find the footprints.localdev certificate in the list and double click to edit
  * Select Trust and set When using this certificate to Always trust
  * Close the window and enter your password when asked

You should now be able to access footprints at [https://footprints.localdev](https://footprints.localdev).

#### Note

Footprints requires anybody who logs in to also be a crafter. You will have to manually add a person to the system as a crafter in order to log into Footprints.

## Running Capistrano deploy commands

Footprints is deployed using Capistrano. Generally speaking, deploying the app
should be limited to an automated task run by our CI/CD pipeline, but there may
be scenarios where it is useful to run a deploy from your local environment.

To deploy, take the following steps:

1. Copy `.cap_env.example` to `.cap_env`

```bash
cp .cap_env.example .cap_env
```

2. Edit `.cap_env` and update the env var definitions to be correct for the deploy target (the correct values may change as we refine our provisioning scripts)

```bash
vim .cap_env
```

3. Set the environment variables from `.cap_env` in your shell

```bash
source .cap_env
```

4. Run the desired Capistrano commands

```bash
cap production deploy
```

5. To run the deploy command AND include migrating the DB, include the `RUN_MIGRATIONS` env var

```bash
RUN_MIGRATIONS=1 cap production deploy
```

## Travis Secrets

To generate an encrypted rsa key, run this command:

```bash
export DEPLOY_KEY="some secret key"
openssl aes-256-cbc -k $DEPLOY_KEY -in ~/.ssh/mongeese-footprints -out config/deploy_id_rsa_enc_travis -a
```

And then add the deploy key to travis:

```bash
travis encrypt DEPLOY_KEY=$DEPLOY_KEY
```

## Trello
https://trello.com/b/GuywdyDX/footprints
