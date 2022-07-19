#!/bin/bash

mkdir arch
cp --parents -r $(git status | grep -v " " | awk '{print $1}') arch/
cd arch
tar -cvf ../python-libs.tar.gz *
cd ..
rm -rf arch

