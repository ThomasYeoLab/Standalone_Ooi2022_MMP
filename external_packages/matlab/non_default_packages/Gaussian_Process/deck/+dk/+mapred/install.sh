#!/bin/bash

# Create bin dir
if [ $# -lt 1 ]; then
    bindir="${HOME}/.local/bin"
else
    bindir="$1"
fi

[ ! -d $bindir ] && mkdir -p $bindir

# Move things to bindir
cd python
for f in *.py; do
    cp $f "${bindir}/$f"
    chmod +x "${bindir}/$f"
done 
cd ..

# Print message about PATH
echo ""
echo "Installation complete. All python files were copied to folder '$bindir' and made executable."
echo "If not already done, you should add this directory to your PATH so you can use these routines from the terminal."
echo "To do so, simply add the following line to the file ~/.bash_profile:"
echo "     export PATH=\"${bindir}\":\${PATH}"
echo ""
