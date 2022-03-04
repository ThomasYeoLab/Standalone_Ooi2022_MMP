#!/bin/bash

## --- some vars we will use later
full_path=`which $0`
program_start_secs=`date +%s`
# echo "program_start_secs='$program_start_secs'"
program_start_dir=`pwd`
# echo "program_start_dir='$program_start_dir'"
datatype_label="ExtendedBOLDQC"
# echo "datatype_label='$datatype_label'"
program_name="$0"
# echo "program_name='$program_name'"
program_basename=`basename "$full_path"`
# echo "program_basename='$program_basename'"
program_abspath=`readlink -f "$full_path"`
# echo "program_abspath='$program_abspath'"
program_parameters="$@"
# echo "program_parameters='$program_parameters'"
program_version="1.0"
# echo "program_version='$program_version'"
program_start_date=`date +%Y-%m-%d`
# echo "program_start_date='$program_start_date'"
program_start_time=`date +%H:%M:%S`
# echo "program_start_time='$program_start_time'"
program_username=`whoami`
# echo "program_username='$program_username'"
program_hostname=`hostname -f`
# echo "program_username='$program_username'"
program_os=`uname -a`
# echo "program_os='$program_os'"
program_sha256sum=`sha256sum "$program_abspath" | cut -c-64`
# echo "program_sha256sum='$program_sha256sum'"
program_mtime=`stat -c %y "$program_abspath" | sed -re 's@^([0-9]+-[0-9]+-[0-9]+)\s([0-9]+:[0-9]+:[0-9]+).*$@\1T\2@g'`
# echo "program_mtime='$program_mtime'"
program_size=`stat -c '%s' "$program_abspath"`
# echo "program_size='$program_size'"
. $_HVD_LIB_DIR/shell/helpers.sh || exit 1;

## --- defaults
mosaics=1
outdir="./extended-qc"
plot=1
skip=0
thresh=150
verbose=0

## --- check for dependencies
check nifti1_test "nifti-c lib"
check stackcheck_nifti "buckner lab"
check mcflirt "fsl"
check fslorient "fsl"
#loading FSL 4.1.7 because swapdim is broken in FSL prior to 4.1.7 is broken (according to Tim)
load_fsl 4.1.7
check fslswapdim "fsl"

## --- usage function
function usage {
  [ -n "$1" ] && echo -e "$1\n"
  cat << EOF
Usage: stackcheck_ext.sh [-f nifti] [-s skip] [-t threshold] [-o outdir] [-v]

Required Arguments:
  -f = NIFTI-1 file
  -s = Number of volumes to skip before computation

Optional Arguments:
  -M = Don't create mosaics
  -N = Scan ID (scan number)
  -o = Output directory [default ./qc]
  -p = Save provenance information in report file
  -P = XNAT Project
  -S = MR Session ID
  -t = Intensity threshold to apply before computation
  -T = Do not plot anything
  -v = verbose
  -X = Skip to after stackcheck_nifti

EOF
  exit 1
}

project="Not provided"
scan_id="Not provided"
session_id="Not provided"

## --- parse command line arguments
while getopts "f:N:o:pP:s:S:t:vXTM" opt; do
  case $opt in
    f)
      nifti_file="$OPTARG"
      echo nifti_file="$OPTARG"
      ;;
    o)
      outdir="$OPTARG"
      ;;
    s)
      skip="$OPTARG"
      ;;
    t)
      thresh="$OPTARG"
      ;;
    v)
      verbose=1
      ;;
    p)
      provenance=1
      ;;
    P)
      project="$OPTARG"
      ;;
    M)
      mosaics=0
      ;;
    N)
      scan_id="$OPTARG"
      ;;
    S)
      session_id="$OPTARG"
      ;;
    T)
      plot=0
      ;;
    X)
      skip_stackcheck=1
      ;;
    \?)
      usage
      ;;
  esac
done

while [ $# -gt 0 ]; do
  program_arguments="$program_arguments<argument>$1</argument>";
  shift;
done;

## --- check parameters
[ -n "$nifti_file" ] || usage "Must define input NIFTI-1 file."
[ -e "$nifti_file" ] || error "Input NIFTI-1 file does not exist."
[ -r "$nifti_file" ] || error "Cannot read input NIFTI-1 file."
[ -n "$skip" ] || usage "Must define number of skipped volumes."
[ -n "$thresh" ] || usage "Must define threshold."
[ -n "$outdir" ] || error "Must define output directory."

## --- check that skip and thresh are numbers
if isInt "$skip" -ne 1; then
  error "-s value must be an integer"
fi

if isFloat "$thresh" -ne 1; then
  error "-t value must be an integer or float"
fi

## --- get basename of NIFTI-1 file without extension
base=`basename $nifti_file | sed -re 's@\.nii(\.gz)*$@@i'`
[ -n "$base" ] || error "Could not get a basename from NIFTI-1 file"
echo "File basename... $base"


if [ "$skip_stackcheck" = "" ]; then
    ## --- check that NIFTI-1 file is a NIFTI-1 file
    echo -n "Testing NIFTI-1 file... "
    cmd="nifti1_test \"$nifti_file\"" 
    execute "$cmd" "$verbose" || error "Input file does not appear to be a NIFTI-1 file"
    echo "Done."

    ## --- backup existing output directory if necessary
    if [ -d "$outdir" ]; then 
      dirBackup "$outdir"
    fi

    ## --- create output directory
    if [ ! -e "$outdir" ]; then
      checkMode "$outdir" "c"
      mkdir "$outdir" || error "Failed to create output directory $outdir"
    fi

    # Reorient image as needed
    orientation=`fslorient -getorient "$nifti_file"`;
    if test "NEUROLOGICAL" = "$orientation"; then
        echo "NOTE: Image is in NEUROLOGICAL, flipping to RADIOLOGICAL.\n";
      execute "fslorient -swaporient '$nifti_file'" || error "flsorient failed";
    else
        if test "RADIOLOGICAL" = "$orientation"; then
        echo "NOTE: Image is in RADIOLOGICAL. It's all good.";
        else
        error "ERROR: Unable to determine orientation of '$nifti_file'!";
        fi
    fi
    echo "Enforcing LPI dimensions on '$nifti_file'\n";
    execute "fslswapdim '$nifti_file' RL PA IS '$nifti_file'" || error "fslswapdim failed";

    ## --- Replacing the .nii image with the new .nii.gz (inflated)
    if [ -f "$nifti_file.gz" ]; then
        if [ -f "$nifti_file" ]; then
            rm -fv "$nifti_file" || exit 1
        fi

        gunzip -v "$nifti_file.gz" || exit 1
    fi

    ## --- run stackcheck_nifti
    cmd="stackcheck_nifti --threshold $thresh --skip $skip --report --mean --mask --stdev --snr --plot --input $nifti_file --output-basename ${outdir}/${base}"
    execute "$cmd" $verbose || error "stackcheck_nifti failed."
    echo "Done."
fi

if [ $mosaics -eq 1 ]; then
    ## --- create image Mosaics
    list=`ls -1 "$outdir"/*nii*`
    [ ${#list[*]} -gt 0 ] || echo "List of NIFTI-1 files is empty. Cannot create mosaics."
    for file in `ls -1 $list`; do
      echo -n "Creating snapshot for '$file'... "

      file_base=`basename $file | sed -re 's@\.nii(\.gz)*$@@i'`
      cmd="slicer \"$file\" -u -A 600 \"$outdir/${file_base}.png\"" 
      execute "$cmd" $verbose || error "slicer failed."

      ## --- looks like slicer is smart enough to make png images
      #cmd="montage -geometry +0+0 -background white \"$outdir/$file_base\" \"$outdir/$file_base.png\""
      #execute "$cmd" $verbose || error "montage failed."
      #rm "$outdir/$file_base" || warn "Failed to remove slicer output"
      echo "Done."
    done
fi

if [ $plot -eq 1 ]; then
    ## --- plot .dat file
    echo -n "Plotting DAT file... "
    python << EOF
import matplotlib as mpl
mpl.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
fname = "$outdir/${base}.mean.dat"
h = open(fname, "rb")
data = np.array([], dtype=float)
for line in h.readlines():
  row = line.strip().split("\t")
  if(data.size == 0):
    data = np.append(data, row[1:])
  else:
    data = np.vstack([data, row[1:]]) 
h.close()
## --- customize plot
mpl.rc("lines", antialiased=True, linewidth=0.5)
mpl.rc("legend", fontsize=10)
## --- plot data, tighten axes, set axis titles
plt.plot(data[:])
plt.autoscale(enable=True, axis="both", tight=True)
plt.xlabel("Volumes (N)")
plt.ylabel("Signal Intensity")
plt.title("Mean Slice Intensity")
## --- save figure
plt.savefig("$outdir/${base}_mean_slice.png", format="png")
EOF

    if [ $? -ne 0 ]; then
      error "plotting mean data file failed"
    fi

echo "Done."

fi

## --- perform rough motion correction calculation
echo -n "Calculating between volume motion (roughly)... "
cmd="mcflirt -in \"$nifti_file\" -report -plots -mats -rmsrel -rmsabs -refvol 0 -out \"$outdir/moco\""
execute "$cmd" $verbose || error "mcflirt failed."
echo "Done."

## --- plot motion parameters
echo -n "Plotting motion parameters... "
python <<EOF
import matplotlib as mpl
mpl.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import csv
import sys
## --- file
fname = "$outdir/moco.par"
h = open(fname, "rb")
data = np.array([], dtype=float)
for line in h.readlines():
    row = line.strip().split("  ")
    #row = [float(i) for i in row]
    if(data.size == 0):
        data = np.append(data, row)
    else:
        data = np.vstack([data, row])
h.close()
## --- customize plot
mpl.rc("lines", antialiased=True, linewidth=0.5)
mpl.rc("legend", fontsize=10)
## --- plot data, tighten axes, set axis titles
plt.subplot(211)
plt.plot(data[:,0:3])
plt.legend(["pitch", "roll", "yaw"])
plt.title("Rotations")
plt.xlabel("Volumes (N)")
plt.ylabel("radians")
plt.autoscale(enable=True, axis="both", tight=True)
plt.subplot(212)
plt.plot(data[:,3:])
plt.legend(["x", "y", "z"])
plt.title("Translations")
plt.xlabel("Volumes (N)")
plt.ylabel("mm")
plt.autoscale(enable=True, axis="both", tight=True)
## --- adjust space between subplots
plt.subplots_adjust(hspace=.5)
## --- save figure
plt.savefig("$outdir/${base}_motion.png", format="png")
EOF

if [ $? -ne 0 ]; then
  error "plotting motion correction data failed"
fi

echo "Done."

## --- get number of volumes and timepoints
numof_vols="`fslnvols $nifti_file`"
if [ $? -ne 0 -o $numof_vols -lt 1 ]; then
  error "fslnvols command failed"
fi
echo "Number of volumes... $numof_vols"

numof_tps="`expr $numof_vols - $skip`"
if [ $numof_tps -lt 1 ]; then
  error "number of timepoints less than 1"
fi
echo "Number of time points... $numof_tps"

## --- create .dat files
echo -n "Creating dat files... "
checkMode "$outdir/moco.par" "r"
checkMode "$outdir/$base.rdat" "c"

tail -n $numof_tps $outdir/moco.par | awk 'BEGIN {n=0; init=0;} ($1 !~/#/) { ncol = NF; init = 1; } (init == 1 && $1 !~/#/) { if (NF != ncol) { print "format error"; exit -1;} for (j=1;j<=ncol;j++) data[n,int((j+2)%6) + 1] = $j; n++;} END { for (i = 0; i < n; i++) { printf("%d", i+1); for (j = 1;j <=ncol; j++) printf ("%10.6f", data[i,j]); printf("%10.6f\n",1);}}' > $outdir/$base.dat
tail -n $numof_tps $outdir/moco.par | awk 'BEGIN {n=0; init=0;} ($1 !~/#/) { ncol = NF; if (init == 0) {for (j = 1; j <= ncol; j++) { data_average[j] = 0;}; }; init = 1; } (init == 1 && $1 !~/#/) { if (NF != ncol) { print "format error"; exit -1;} for (j=1;j<=ncol;j++) {data[n,int((j+2)%6)+1] = $j; data_average[int((j+2)%6)+1] = (data[n,int((j+2)%6+1)] + data_average[int((j+2)%6+1)]*(n+1) ) / (n+2);} n++;} END { for (i = 0; i < n; i++) { printf("%d", i+1); for (j = 1;j <=ncol; j++) printf ("%10.6f", data[i,j] - data_average[j]); printf("%10.6f\n", 1);}}' > $outdir/$base.rdat
tail -n $numof_tps $outdir/moco.par | awk 'BEGIN {n=0; init=0;} ($1 !~/#/) { ncol = NF; if (init == 0) {printf ("%d",1); for (j = 1; j <= ncol; j++) { printf("%10.6f", 0)}; printf("%10.6f\n",1); }; init = 1; } (init == 1 && $1 !~/#/) { if (NF != ncol) { print "format error"; exit -1;} for (j=1;j<=ncol;j++) data[n,int((j+2)%6)+1] = $j; n++;} END { for (i = 1; i < n; i++) { printf("%d", i+1); for (j = 1;j <=ncol; j++) printf ("%10.6f", data[i,j] - data[i-1,j]); printf("%10.6f\n", 0);}}' > $outdir/$base.ddat
echo "Done."

echo -n "Calculating motion parameters... "
## --- column headers (koene's addition)
#motion_rel_x_mean motion_rel_x_sd motion_rel_x_max motion_rel_x_gt_pt1mm motion_rel_x_gt_pt5mm motion_rel_y_mean motion_rel_y_sd motion_rel_y_max motion_rel_y_gt_pt1mm motion_rel_y_gt_pt5mm motion_rel_z_mean motion_rel_z_sd motion_rel_z_max motion_rel_z_gt_pt1mm motion_rel_z_gt_pt5mm motion_rel_xyz_mean motion_rel_xyz_sd motion_rel_xyz_max motion_rel_xyz_gt_pt1mm motion_rel_xyz_gt_pt5mm motion_rel_rot_x_mean motion_rel_rot_x_sd motion_rel_rot_x_max motion_rel_rot_y_mean motion_rel_rot_y_sd motion_rel_rot_y_max motion_rel_rot_z_mean motion_rel_rot_z_sd motion_rel_rot_z_max_abs motion_abs_x_mean motion_abs_x_sd motion_abs_x_max motion_abs_y_mean motion_abs_y_sd motion_abs_y_max motion_abs_z_mean motion_abs_z_sd motion_abs_z_max motion_abs_xyz_mean motion_abs_xyz_sd motion_abs_xyz_max motion_abs_rot_x_mean motion_abs_rot_x_sd motion_abs_rot_x_max motion_abs_rot_y_mean motion_abs_rot_y_sd motion_abs_rot_y_max motion_abs_rot_z_mean motion_abs_rot_z_sd motion_abs_rot_z_max_abs

if [ ! -e temp ]; then 
  mkdir temp; 
fi

#COUNT NUMBER OF VOLUMES
awk 'END {print NR}' $outdir/${base}.ddat > temp/column_01.txt

####
##RELATIVE DISPLACEMENT
####

####
#GRAB COLUMN WITH MOTION PARAMETER AND SAVE TO TEMP FILE
# GET MEAN
# GET SD
# GET MAX
# GET NUMBER OF TIMES THAT MOTION WAS GREATER THAN 0.1 MM
# GET NUMBER OF TIMES THAT MOTION WAS GREATER THAN 0.5 MM

# X DIRECTION from second column (and make absolute (i.e. make all postive: |x|))
awk '{ print ($2>= 0) ? $2 : 0 - $2}' $outdir/${base}.ddat > temp/column_temp1.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count}' temp/column_temp1.txt > temp/column_02.txt
awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}' temp/column_temp1.txt > temp/column_03.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}' temp/column_temp1.txt > temp/column_04.txt
awk '$1>=0.1{print}' temp/column_temp1.txt | awk 'END {print NR}' > temp/column_05.txt
awk '$1>=0.5{print}' temp/column_temp1.txt | awk 'END {print NR}' > temp/column_06.txt

# Y DIRECTION from third column (and make absolute (i.e. make all postive: |x|))
awk '{ print ($3>= 0) ? $3 : 0 - $3}' $outdir/${base}.ddat > temp/column_temp2.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count}' temp/column_temp2.txt > temp/column_07.txt
awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}' temp/column_temp2.txt > temp/column_08.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}' temp/column_temp2.txt > temp/column_09.txt
awk '$1>=0.1{print}' temp/column_temp2.txt | awk 'END {print NR}' > temp/column_10.txt
awk '$1>=0.5{print}' temp/column_temp2.txt | awk 'END {print NR}' > temp/column_11.txt

# Z DIRECTION from fourth column (and make absolute (i.e. make all postive: |x|))
awk '{ print ($4>= 0) ? $4 : 0 - $4}' $outdir/${base}.ddat > temp/column_temp3.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count}' temp/column_temp3.txt > temp/column_12.txt
awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}' temp/column_temp3.txt > temp/column_13.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}' temp/column_temp3.txt > temp/column_14.txt
awk '$1>=0.1{print}' temp/column_temp3.txt | awk 'END {print NR}' > temp/column_15.txt
awk '$1>=0.5{print}' temp/column_temp3.txt | awk 'END {print NR}' > temp/column_16.txt

# 3D DIRECTION from mc_rel file -- used to be from concatenated /qc/mc_rel.rms file
cp $outdir/moco_rel.rms temp/column_temp4.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count}' temp/column_temp4.txt > temp/column_17.txt
awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}' temp/column_temp4.txt > temp/column_18.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}' temp/column_temp4.txt > temp/column_19.txt
awk '$1>=0.1{print}' temp/column_temp4.txt | awk 'END {print NR}' > temp/column_20.txt
awk '$1>=0.5{print}' temp/column_temp4.txt | awk 'END {print NR}' > temp/column_21.txt

####
#RELATIVE ROTATION (and make absolute (i.e. make all postive: |x|))
####
awk '{ print ($5>= 0) ? $5 : 0 - $5}' $outdir/${base}.ddat > temp/column_temp9.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count}' temp/column_temp9.txt > temp/column_22.txt
awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}' temp/column_temp9.txt > temp/column_23.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}' temp/column_temp9.txt > temp/column_24.txt

awk '{ print ($6>= 0) ? $6 : 0 - $6}' $outdir/${base}.ddat > temp/column_temp10.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count}' temp/column_temp10.txt > temp/column_25.txt
awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}' temp/column_temp10.txt > temp/column_26.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}' temp/column_temp10.txt > temp/column_27.txt

awk '{ print ($7>= 0) ? $7 : 0 - $7}' $outdir/${base}.ddat > temp/column_temp11.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count}' temp/column_temp11.txt > temp/column_28.txt
awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}' temp/column_temp11.txt > temp/column_29.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}' temp/column_temp11.txt > temp/column_30.txt

#####
##ABSOLUTE DISPLACEMENT
####
# X DIRECTION from second column
awk '{ print ($2>= 0) ? $2 : 0 - $2}' $outdir/${base}.dat > temp/column_temp5.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count}' temp/column_temp5.txt > temp/column_31.txt
awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}' temp/column_temp5.txt > temp/column_32.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}' temp/column_temp5.txt > temp/column_33.txt

# Y DIRECTION from third column
awk '{ print ($3>= 0) ? $3 : 0 - $3}' $outdir/${base}.dat > temp/column_temp6.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count}' temp/column_temp6.txt > temp/column_34.txt
awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}' temp/column_temp6.txt > temp/column_35.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}' temp/column_temp6.txt > temp/column_36.txt

# Z DIRECTION from fourth column
awk '{ print ($4>= 0) ? $4 : 0 - $4}' $outdir/${base}.dat > temp/column_temp7.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count}' temp/column_temp7.txt > temp/column_37.txt
awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}' temp/column_temp7.txt > temp/column_38.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}' temp/column_temp7.txt > temp/column_39.txt

# 3D DIRECTION from mc_abs file -- used to be from concatenated /qc/mc_abs.rms file
cp $outdir/moco_abs.rms temp/column_temp8.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count}' temp/column_temp8.txt > temp/column_40.txt
awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}' temp/column_temp8.txt > temp/column_41.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}' temp/column_temp8.txt > temp/column_42.txt

####
#ABSOLUTE ROTATION (and make absolute (i.e. make all postive: |x|))
####
awk '{ print ($5>= 0) ? $5 : 0 - $5}' $outdir/${base}.dat > temp/column_temp9.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count}' temp/column_temp9.txt > temp/column_43.txt
awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}' temp/column_temp9.txt > temp/column_44.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}' temp/column_temp9.txt > temp/column_45.txt

awk '{ print ($6>= 0) ? $6 : 0 - $6}' $outdir/${base}.dat > temp/column_temp10.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count}' temp/column_temp10.txt > temp/column_46.txt
awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}' temp/column_temp10.txt > temp/column_47.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}' temp/column_temp10.txt > temp/column_48.txt

awk '{ print ($7>= 0) ? $7 : 0 - $7}' $outdir/${base}.dat > temp/column_temp11.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print total/count}' temp/column_temp11.txt > temp/column_49.txt
awk '{sum+=$1; sumsq+=$1*$1} END {print sqrt(sumsq/NR - (sum/NR)**2)}' temp/column_temp11.txt > temp/column_50.txt
awk '{if(min==""){min=max=$1}; if($1>max) {max=$1}; if($1<min) {min=$1}; total+=$1; count+=1} END {print max}' temp/column_temp11.txt > temp/column_51.txt

echo "Done."

## --- Calculate voxel-based SNR
echo -n "Calculating mean masked SNR (qc_vSNR)... "
qc_vSNR=`fslmeants -i ${outdir}/${base}_snr.nii -m ${outdir}/${base}_mask.nii`
echo "Done."

echo -n "Calculating mean masked StDev (qc_Stdev)... "
qc_Stdev=`fslmeants -i ${outdir}/${base}_stdev.nii -m ${outdir}/${base}_mask.nii`
echo "Done."

echo -n "Calculating mean masked Mean (qc_Mean)... "
qc_Mean=`fslmeants -i ${outdir}/${base}_mean.nii -m ${outdir}/${base}_mask.nii`
echo "Done."

## --- Calculate voxel-based SNR
echo -n "Calculating mean masked Slope (qc_slope)... "
qc_slope=`fslmeants -i ${outdir}/${base}_slope.nii -m ${outdir}/${base}_mask.nii`
echo "Done."

## --- create *_auto_report.txt
echo -n "Creating report file... "
report_file="$outdir/${base}_auto_report.txt"
report_xml="$outdir/${base}_auto_report.xml"

program_end_secs=`date +%s`
program_runtime_secs=`expr $program_end_secs - $program_start_secs`
nifti_file_size=`stat -c '%s' "$nifti_file"`

echo "
ReportFile        $report_file
StartDate         $program_start_date
InputFile         $nifti_file
InputFileSize     $nifti_file_size

N_Vols $numof_vols

Skip $skip

qc_N_Tps         $numof_tps
qc_thresh        $thresh
qc_nVox          `grep 'VOXEL' $outdir/${base}_slice_report.txt | cut -f 2`
qc_Mean_old      `grep 'VOXEL' $outdir/${base}_slice_report.txt | cut -f 3`
qc_Stdev_old     `grep 'VOXEL' $outdir/${base}_slice_report.txt | cut -f 4`
qc_Mean          $qc_Mean
qc_Stdev         $qc_Stdev
qc_sSNR          `grep 'VOXEL' $outdir/${base}_slice_report.txt | cut -f 5`
qc_vSNR          $qc_vSNR
qc_slope         $qc_slope

mot_N_Tps        `cat temp/column_01.txt`
mot_rel_x_mean   `cat temp/column_02.txt`
mot_rel_x_sd     `cat temp/column_03.txt`
mot_rel_x_max    `cat temp/column_04.txt`
mot_rel_x_1mm    `cat temp/column_05.txt`
mot_rel_x_5mm    `cat temp/column_06.txt`
mot_rel_y_mean   `cat temp/column_07.txt`
mot_rel_y_sd     `cat temp/column_08.txt`
mot_rel_y_max    `cat temp/column_09.txt`
mot_rel_y_1mm    `cat temp/column_10.txt`
mot_rel_y_5mm    `cat temp/column_11.txt`
mot_rel_z_mean   `cat temp/column_12.txt`
mot_rel_z_sd     `cat temp/column_13.txt`
mot_rel_z_max    `cat temp/column_14.txt`
mot_rel_z_1mm    `cat temp/column_15.txt`
mot_rel_z_5mm    `cat temp/column_16.txt`
mot_rel_xyz_mean `cat temp/column_17.txt`
mot_rel_xyz_sd   `cat temp/column_18.txt`
mot_rel_xyz_max  `cat temp/column_19.txt`
mot_rel_xyz_1mm  `cat temp/column_20.txt`
mot_rel_xyz_5mm  `cat temp/column_21.txt`
rot_rel_x_mean   `cat temp/column_22.txt`
rot_rel_x_sd     `cat temp/column_23.txt`
rot_rel_x_max    `cat temp/column_24.txt`
rot_rel_y_mean   `cat temp/column_25.txt`
rot_rel_y_sd     `cat temp/column_26.txt`
rot_rel_y_max    `cat temp/column_27.txt`
rot_rel_z_mean   `cat temp/column_28.txt`
rot_rel_z_sd     `cat temp/column_29.txt`
rot_rel_z_max    `cat temp/column_30.txt`
mot_abs_x_mean   `cat temp/column_31.txt`
mot_abs_x_sd     `cat temp/column_32.txt`
mot_abs_x_max    `cat temp/column_33.txt`
mot_abs_y_mean   `cat temp/column_34.txt`
mot_abs_y_sd     `cat temp/column_35.txt`
mot_abs_y_max    `cat temp/column_36.txt`
mot_abs_z_mean   `cat temp/column_37.txt`
mot_abs_z_sd     `cat temp/column_38.txt`
mot_abs_z_max    `cat temp/column_39.txt`
mot_abs_xyz_mean `cat temp/column_40.txt`
mot_abs_xyz_sd   `cat temp/column_41.txt`
mot_abs_xyz_max  `cat temp/column_42.txt`
rot_abs_x_mean   `cat temp/column_43.txt`
rot_abs_x_sd     `cat temp/column_44.txt`
rot_abs_x_max    `cat temp/column_45.txt`
rot_abs_y_mean   `cat temp/column_46.txt`
rot_abs_y_sd     `cat temp/column_47.txt`
rot_abs_y_max    `cat temp/column_48.txt`
rot_abs_z_mean   `cat temp/column_49.txt`
rot_abs_z_sd     `cat temp/column_50.txt`
rot_abs_z_max    `cat temp/column_51.txt`

Command           $program_name $program_parameters
CWD               $program_start_dir
StartTime         $program_start_time
Username          $program_username
OS                $program_os
Hostname          $program_hostname
Program.Version   $program_version
Program.Name      $program_basename
Program.Path      $program_abspath
Program.SHA256Sum $program_sha256sum
Program.Size      $program_size
Program.MTime     $program_mtime
Program.Arguments $program_arguments
RuntimeSeconds    $program_runtime_secs
MRScan.Project    $project
MRScan.Id         $scan_id
MRScan.SessionId  $session_id
" >> $report_file || exit 1;

echo "Done."

if [ "$verbose" = "1" ]; then
  cat $report_file
fi

echo "Done."

## --- Remove temp directory
rm -rf temp
