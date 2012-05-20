#!/bin/sh
nosy "npm test" --glob-patterns "specs/** assets/js/**" --exclude-patterns "node_modules/**"
