#!/bin/bash

# Ensure the gh CLI tool is installed
if ! command -v gh &> /dev/null; then
  echo "The gh CLI tool is not installed. Please install it and try again."
  exit 1
fi

# Load .env file if it exists
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Check if PyPI credentials are set in the environment or .env file
if [ -z "$PYPI_USERNAME" ] || [ -z "$PYPI_PASSWORD" ]; then
  # If not, prompt the user for PyPI credentials using Zenity dialogs
  PYPI_USERNAME=$(zenity --entry --title="PyPI Username" --text="Please enter your PyPI username:")
  PYPI_PASSWORD=$(zenity --entry --title="PyPI Password" --text="Please enter your PyPI password:" --hide-text)
fi

# List all repositories and allow the user to select one or create a new one
REPO=$(gh repo list --limit 200 | awk '{print $1}' | zenity --list --title="Select a repository" --column="Repositories" --extra-button="Create new")

# Create a new repository if the user selected "Create new"
if [ "$REPO" == "Create new" ]; then
  REPO_NAME=$(zenity --entry --title="New Repository" --text="Please enter the name of the new repository:")
  REPO=$(gh repo create "$REPO_NAME" --public -y)
fi

# Clone the selected repository
git clone "https://github.com/$REPO.git"
cd "$(basename "$REPO")"

# Prompt the user for the tag
TAG=$(zenity --entry --title="Tag" --text="Please enter the tag to be pushed:")

# Set up Git and push the tag
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_USERNAME"
git tag "$TAG"
git push origin "$TAG"

# Create and execute the GitHub Actions workflow to publish to PyPI
cat > .github/workflows/publish-to-pypi.yml << EOL
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
EOL

# Run the publish.sh script
bash publish.sh
