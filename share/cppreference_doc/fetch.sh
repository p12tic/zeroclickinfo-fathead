#!/bin/bash
mkdir -p download

pushd download > /dev/null
wget http://upload.cppreference.com/mwiki/images/a/a5/cppreference-doc-20130627.tar.gz
tar -xzf cppreference-doc-20130627.tar.gz
popd > /dev/null
