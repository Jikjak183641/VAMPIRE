#!/bin/bash
# Install Elixir and Erlang
apt-get update
apt-get install -y wget gnupg

# Install Erlang
wget -O- https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | apt-key add -
echo "deb https://packages.erlang-solutions.com/ubuntu focal contrib" | tee /etc/apt/sources.list.d/erlang.list

apt-get update
apt-get install -y esl-erlang

# Install Elixir
apt-get install -y elixir

# Verify installation
elixir --version
