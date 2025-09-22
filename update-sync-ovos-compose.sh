#!/usr/bin/env bash
set -euo pipefail

# Config
OVOS_DOCKER_DIR="../ovos-docker"
OVOS_REMOTE="ovos-docker-local"
SPLIT_BRANCH="ovos-compose-split"
PREFIX="ovos-compose"

# Clone ovos-docker if missing
if [ ! -d "$OVOS_DOCKER_DIR/.git" ]; then
    echo "Cloning ovos-docker..."
    git clone https://github.com/OpenVoiceOS/ovos-docker.git "$OVOS_DOCKER_DIR"
fi

# Update ovos-docker
echo "Updating ovos-docker..."
cd "$OVOS_DOCKER_DIR"
git fetch origin
git checkout dev
git pull origin dev

# Create split branch
echo "Splitting ovos-compose/ directory..."
git branch -D "$SPLIT_BRANCH" 2>/dev/null || true
git subtree split --prefix=$PREFIX origin/dev -b "$SPLIT_BRANCH"

# Go back to benedikta-ovos
cd - >/dev/null

# Add remote if not exists
if ! git remote | grep -q "$OVOS_REMOTE"; then
    git remote add "$OVOS_REMOTE" "$OVOS_DOCKER_DIR"
fi
git fetch "$OVOS_REMOTE"

# Check if ovos-compose/ already exists in benedikta-ovos
if [ ! -d "$PREFIX" ]; then
    echo "Adding ovos-compose/ for the first time..."
    git subtree add --prefix=$PREFIX "$OVOS_REMOTE" "$SPLIT_BRANCH" --squash
else
    echo "Updating existing ovos-compose/ directory..."
    git subtree pull --prefix=$PREFIX "$OVOS_REMOTE" "$SPLIT_BRANCH" --squash
fi

echo "✅ ovos-compose/ is synced with ovos-docker:dev"
