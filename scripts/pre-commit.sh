#!/bin/bash

if git rev-parse --verify HEAD >/dev/null 2>&1
then
        against=HEAD
else
        # Initial commit: diff against an empty tree object
        against=$(git hash-object -t tree /dev/null)
fi

# Redirect output to stderr.
exec 1>&2

# If the project does not compile, print error message and fail.
if ! zola build --drafts && zola check
then
    cat <<\EOF
Error: Website build failed or has warnings!
EOF
    exit 1
fi

# verify that the html files are correct
if ! fd --base-directory public -e html --exec fish -c 'validate_html $argv' {}
then
    cat <<\EOF
Error: could not validate HTML
EOF
    exit 1
fi

# If there are whitespace errors, print the offending file names and fail.
exec git diff-index --check --cached $against --
