#! /bin/csh -f

make clean_all
make all
find . -name "*.o" -print | xargs rm
