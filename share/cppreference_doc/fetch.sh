#!/bin/bash
mkdir -p download

pushd download > /dev/null
wget http://upload.cppreference.com/mwiki/images/3/3b/cppreference-doc-20130510.tar.gz
tar -xzf cppreference-doc-20130510.tar.gz
popd > /dev/null
