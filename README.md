# github-action-pypi-bash-script-creator
This script prompts the user for the PyPI credentials, project folder, and tag using Zenity dialogs. It also reads from a .env file if it exists. The script sets up Git, pushes the tag, and creates and runs the GitHub Actions workflow to publish the package to PyPI.
a simple GitHub Actions workflow that you can use to publish a Python package to PyPI using a bash script. Create a file named .github/workflows/publish-to-pypi.yml in your repository with the following content:

yaml

name: Publish to PyPI

on:
  push:
    tags:
      - '*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.x'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install setuptools wheel twine

      - name: Build and publish
        env:
          TWINE_USERNAME: ${{ secrets.PYPI_USERNAME }}
          TWINE_PASSWORD: ${{ secrets.PYPI_PASSWORD }}
        run: |
          bash publish.sh

Create a bash script named publish.sh in your repository root directory with the following content:

bash

#!/bin/bash

set -e

python setup.py sdist bdist_wheel

twine check dist/*
twine upload dist/*

Make sure your publish.sh script is executable by running:

bash

chmod +x publish.sh

This GitHub Actions workflow is triggered when you push a new tag to your repository. It checks out the repository, sets up Python, installs the required dependencies, and runs the publish.sh script. The script builds the package using setup.py and uploads it to PyPI using twine.

For this to work, you'll need to store your PyPI username and password as secrets in your GitHub repository. Go to the "Settings" tab of your repository, click "Secrets" on the left sidebar, and add two secrets: PYPI_USERNAME and PYPI_PASSWORD. Use your PyPI account credentials for these values.

Now, when you push a new tag to your repository, the GitHub Actions workflow will be triggered, and your package will be published to PyPI.
User

To create a comprehensive bash script that uses graphical input dialogs for user prompts and pulls information from a .env file if available, we can use a tool called Zenity. Zenity provides graphical dialogs for shell scripts, allowing you to create user-friendly interfaces for your scripts.

First, make sure Zenity is installed on your system:

For Ubuntu or Debian-based systems, use:

bash

sudo apt-get install zenity

For Fedora-based systems, use:

bash

sudo dnf install zenity
