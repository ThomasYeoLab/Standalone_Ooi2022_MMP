#!/usr/bin/csh

foreach item (*)
if (-x $item) echo $item 
end