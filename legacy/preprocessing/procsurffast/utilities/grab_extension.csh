#! /bin/csh -f 

set f = $1
set basef = `basename $f`
set ext = `echo $basef | awk -F . '{print $NF}'`
if($ext == gz) then
    set basef2 = `basename $f .gz`
    set ext = .`echo $basef2 | awk -F . '{print $NF}'`.gz
else
    set ext = .$ext
endif
echo $ext
