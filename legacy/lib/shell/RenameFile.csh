#! /bin/csh -f

# checks!
if($#argv < 2) then
    echo "usage: RenameFile.csh file from_str to_str"
    exit
endif

set from_str = $2
set to_str = $3
set input_file = $1
set output_file = `echo $input_file | sed -e "s/$from_str/$to_str/"`

set cmd = "mv $input_file $output_file"
echo $cmd
eval $cmd
