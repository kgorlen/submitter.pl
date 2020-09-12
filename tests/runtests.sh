#!/bin/bash
set -x #echo on
rm -rf submit-test
mkdir submit-test
cp acktemplate.html submit-test
mkdir submit-test/9999-01-01
mkdir submit-test/9999-01-01/OS
mkdir submit-test/9999-01-01/Pic2
mkdir submit-test/9999-01-01/TN
for email in ./test_*.eml
do
    perl $HOME/perl/src/Photochrome/submitter.pl -submitdir $PWD/submit-test -user submit -debug 2>./`basename ${email} .eml`.log <${email}
done
