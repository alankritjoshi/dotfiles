#!/bin/bash

echo "Running Ansible..."

ansible-playbook ~/.bootstrap/main.yml --ask-become-pass