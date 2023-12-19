#!/bin/bash

if ! command -v brew &>/dev/null; then
	echo "Brew not found, installing..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
	echo "Brew found, updating..."
	brew update
	exit
fi
