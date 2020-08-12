#!/bin/bash

# Title: Build Tools
# Source this file to have handy scripts to build desired projects.
# To build the Hello World project follow these steps.
#
# --- Bash 
# $: source scripts/build_tools.sh
# $: build hello_world
# ...
# $: run hello_world
# Hello, world!!!
# ---
# To build docs simply run the following after sourcing the build_tools.sh.
# --- Bash
# $: docs
# ---
# Afterwards you can open docs/index.html in a browser to view generated documentation.
# 
# Variables:
# 
# project - What project in the projects directory will be built.
# tag     - Docker tag to be used while building an image.
# target  - What multistage docker target to use.
# TB_TAG  - The base tag for all images produced by this project.
# TB_DIR  - Hold the absolute path to the root directory of this repo.

export TB_DIR=$(cd \
    $(dirname \
        $(dirname "${BASH_SOURCE[0]}") \
    ) \
    && pwd);

export TB_TAG="the-basics";

# Function: Build
# Build a given project
#
# Args:
#
# $1 - project - This is the project you are looking to build 
build() {
    local project=${1:-"hello_world"};
    local tag="${TB_TAG}:${project}";
    local build_arg="project=${project}";
    local target="builder";
    docker build --target ${target} -t ${tag} -f ${TB_DIR}/Dockerfile --build-arg ${build_arg} ${TB_DIR};
}

# Function: Run
# Run a built project
#
# Args:
#
# $1 - project - Run this project
run() {
    local project=${1:-"hello_world"};
    local tag="${TB_TAG}:${project}";
    docker run --rm -it ${tag};
}

# Function:  Docs
# Build documentation via <Natural Docs:https://naturaldocs.org/>.
# Documentation is generated and placed into the docs folder.
# Whever this function runs it will delete the docs folder and recreate it
# with fresh documentation.
docs(){
    # clean up docs dir
    local tag="${TB_TAG}:docs";
    rm -r ${TB_DIR}/docs;
    docker build -t ${tag} -f ${TB_DIR}/Dockerfile --target docs ${TB_DIR};
    docker run --rm  ${tag} | tar  -xvC ${TB_DIR};
}

# Function: List
# List all available projects to build
list() {
    local HR="\u2500";
    local header="Projects to select from.";
    local projects_dir="projects";
    printf '  %s\n ' "$header";
    eval "for i in {1..$(wc -c <<< $header)}; do printf '$HR'; done;";
    echo;
    printf '  %s\n' $(ls ${TB_DIR}/${projects_dir});
}
