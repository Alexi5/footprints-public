#!/bin/sh

openssl aes-256-cbc -k $DEPLOY_KEY \
  -in config/deploy_id_rsa_enc_travis \
  -out config/deploy_id_rsa -d -a

bundle install --without development test

bundle exec cap production deploy
