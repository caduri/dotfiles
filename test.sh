#!/usr/bin/env bash

printf '%s\n' "Fetching github username from lastpass"
GITHUB_USER="$(lpass show -u Github)"
printf '%s\n' "Fetching github password from lastpass"
GITHUB_TOKEN="$(lpass show Github --field=Token)"

SSH_RSA="$(cat ~/.ssh/id_rsa.pub)"
curl -u "$GITHUB_USER:$GITHUB_TOKEN" --data '{"title":"DevMachine","key":"'"$SSH_RSA"'"}' https://api.github.com/user/keys