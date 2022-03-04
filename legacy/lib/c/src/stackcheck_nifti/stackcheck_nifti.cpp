/***************************************************************************
 * Copyright 2007 Harvard University / HHMI
 * Cognitive Neuroscience Laboratory / Martinos Center for BiomedicalImaging
 ***************************************************************************/
/****************************************************************************
 * $Id: stackcheck_nifti.c,v 1.7 2009/02/13 18:10:17 mtt24 Exp $
 *
 * Description  : stackcheck_nifti.c is a data quality control program.
 * Author       : Tanveer Talukdar <mtt24@nmr.mgh.harvard.edu>
 *
 * Purpose : see CNLwiki page at http://www.nmr.mgh.harvard.edu/nexus/
 *
 *****************************************************************************/

/************************************************************************************
 * To compile:
 * cc -O -I. -c stackcheck_nifti.c
 * cc -O -I. -o stackcheck_nifti stackcheck_nifti.o nifti1_io.o znzlib.o fslio.o  -lm
 ************************************************************************************/

#include "fslio.h"
#include "nifti1.h"
#include "nifti1_io.h"
#include "znzlib.h"
#include <float.h>
#include <math.h>
//#include <nifti/nifti1.h>
//#include <nifti/nifti1_io.h>
//#include <nifti/znzlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <unistd.h>

#define str_equals(s1,s2) (0 == strcmp(s1,s2))
#ifdef DEBUG_ON
#    define debug(x,y) if(opt_debug_on && opt_verbosity >= x) debug_out y
#else
#    define debug(x,y)
#endif
#define toggle(what)     ( (what) = (what) ? 0 : 1)
#define toggle_on(what)  ( (what) = 1)
#define toggle_off(what) ( (what) = 0)
#define on_or_off(what)  ( (what) ? "ON" : "OFF")
#define yes_or_no(what)  ( (what) ? "YES" : "NO")

#define FL_NOWHERE      0
#define FL_IN_FIELDNAME 1
#define FL_IN_FIELDVAL  2

#define MIN_HEADER_SIZE 348
#define NII_HEADER_SIZE 352
#define MAXL  256
#define MAXF  16384   /*maximum number of frames */

#define ERROR_IS_FATAL 1
#define ERROR_IS_NOT_FATAL 0

#define SC_REPORT_TEXT_IDX     0
#define SC_REPORT_XML_IDX      1
#define SC_MEAN_SLICE_TEXT_IDX 2
#define SC_INPUT_IMAGE_IDX     3
#define SC_MEAN_IMAGE_IDX      4
#define SC_MASK_IMAGE_IDX      5
#define SC_SNR_IMAGE_IDX       6
#define SC_STDEV_IMAGE_IDX     7
#define SC_SLOPE_IMAGE_IDX  8
#define SC_NUM_FILES           9

#define eq(str1,str2) ( 0 == strcmp(str1,str2) )

typedef struct output_file_s {
  char * description;
  char * basename;
  char * desc_extension;
  char * type_extension;
  char * filename;
  FILE * fp;
  int create;
  nifti_image * nim;
  void *data_array;
  double min;
  double max;
  double mean;
  double sum;
  double variance;
  double snr;
  double stdev;
  double read_time;
  double write_time;
  unsigned long long data_length;
  unsigned long long nan_count;
  unsigned long long inf_count;
  unsigned long long zero_count;
  unsigned long long one_count;
  unsigned long long n_count;
} output_file_t;

static output_file_t **default_output_file_array;
static output_file_t **output_file_array;

/********************/
/* global variables */
/********************/
/* =============================================================================
 * VERSION Variables, intended to be replaced on checkout
 * ========================================================================== */
static char version_string[]   = "<REPLACE:VERSION>";
static char revision_string[]  = "<REPLACE:HG_REVISION>";
static char sha256sum_string[] = "<REPLACE:CODE_SHA256>";
static char md5sum_string[]    = "<REPLACE:CODE_MD5>";
static char program[MAXL];
float scale_factor = 1.0;
float factor = 1.0;   /* multiplier for output image values */
float opt_threshold = 150.0;  /*image masking threshold */
float stdev_out = 2.5;    /*threshold for standard deviation */
int nifti_datatype;

static char *output_nii_ext = ".nii";
static char *output_basename = NULL;

/******************/
/*image processing*/
/******************/
char *opt_format = NULL;         /* pattern of frames to count */
double *fptr;                    /* general float pointer */
double *image_variance_data;     /* variance over all frames */
double *image_mean_data;         /* multivolume average over all frames */
double *image_mask_data;
double *image_stdev_data;        /*pointer to standard deviation image */
double *image_sSNR_data;         /*pointer to snr image */
double *slice_mean_data, *slice_min_data, *slice_max_data, *slice_stdev_data,  *slice_snr;
double sum_mean, sum_stdev, sum_min, sum_max, sum_snr;
double **tempimgt, **plotimgt;
int *slice_voxel_count_data, *slice_out, sum_voxel, sum_out;
int nvox_in_3d_vol, slice, nslices, nvox_in_2d_slice, nf_func;
double *tempimage_mask_data;
int xnum, ynum, znum, number_of_timepoints, total_data_count;
double diff;
char control = '\0';
double temp_data;
static double *input_data_as_double = NULL;

static int opt_skip;
static char *opt_input_mask_filename = NULL;
static int opt_debug_on = 0;
static int opt_output_report_text = 0;
static int opt_create_report_xml = 1;
static int opt_create_mean_slice_txt = 0;
static int opt_create_mean_nii = 0;
static int opt_create_mask_nii = 0;
static int opt_create_stdev_nii = 0;
static int opt_create_snr_nii = 0;
static int opt_verbosity = 1;
static int opt_zip_output_nii = 0;
static int opt_threshold_all_data = 0;
static int opt_use_uint8_mask = 0;
static int opt_create_slope_nii = 0;
static char *opt_default_report_extension = ".report";
static char *opt_default_mean_slice_data_extension = ".mean.dat";
static char *opt_default_snr_extension = "_snr";
static char *opt_default_stdev_extension = "_sd";
static char *opt_new_report_extension = "_slice_report.txt";
static char *opt_new_mean_slice_data_extension = "_slice_data.txt";
static char *opt_new_snr_extension = "_snr";
static char *opt_new_stdev_extension = "_stdev";
static char *opt_report_extension = ".report";
static char *opt_mean_slice_data_extension = ".mean.dat";
static char *opt_snr_extension = "_snr";
static char *opt_stdev_extension = "_sd";
static char *opt_slope_extension = "_slope";

static int glob_argc = 0; /* used to generate XML files that include the argc/argv information */
static char **glob_argv = NULL; /* used to generate XML files that include the argc/argv information */

#define timeval2double(x) ((double)x.tv_sec + ((double)(x.tv_usec)/1000000))
/**
 * Set time (t0) for the next call to tock();
 *
 * @author Gabriele Fariello
 *
 */
static struct timeval _tick_t0;
void tick() {
  gettimeofday(&_tick_t0,NULL);
}
/**
 * Get the number of seconds that have elapsed since the last
 * tick() was called.
 *
 * Calling this without having ever called tick() will result in undefined
 * results.
 *
 * @author Gabriele Fariello
 *
 * @return number of seconds
 */
double tock() {
  struct timeval t1;
  gettimeofday(&t1,NULL);
  return timeval2double(t1) - timeval2double(_tick_t0);
}
/**
 * Replace '<' with '&lt;', '>' with '&gt;' and '&' with '&amp;' in a string.
 *
 * @author Gabriele Fariello
 *
 * @param new_str_ptr pointer to string to replace.
 *        NOTE: MUST be a string that was malloc'ed or NULL, as non-NULL
 *        string swill be free()ed
 * @return string which was replaced. May be the same pointer.
 */
char * xmlify(char * str, char ** new_str_ptr) {
  unsigned int more = 0, len = 0, newlen;
  char *new_str,*cur, *end;
  if(*new_str_ptr != NULL) free(*new_str_ptr);
  new_str = NULL;
  if(NULL == str) {
    debug(3,("xmlify() called with NULL string.\n"));
    return *new_str_ptr = NULL;
  }
  for(cur=str ; '\0' != *cur ; cur++) {
    len ++;
    switch(*cur) {
    case '<':
    case '>':
      more += 3;
      break;
    case '&':
      more += 4;
      break;
    }
  }
  newlen = len + more + 1;
  new_str = (char *)malloc(newlen);
  if(! more) {
    strcpy(new_str,str);
    *new_str_ptr = new_str;
    return *new_str_ptr;
  }
  *new_str = 'Z';
  end = new_str + newlen;
  *(end --) = '\0';
  for(; end > new_str; end --)
    *end = 'Z';
  if(NULL == str) { fprintf(stderr,"Allocating memory in xmlify failed.");exit(1);}
  for(end = new_str + newlen -1;cur >= str;cur --, end --) {
    switch(*cur) {
    case '<':
      *(end --) = ';';
      *(end --) = 't';
      *(end --) = 'l';
      *(end) = '&';
      break;
    case '>':
      *(end --) = ';';
      *(end --) = 't';
      *(end --) = 'g';
      *(end) = '&';
      break;
    case '&':
      *(end --) = ';';
      *(end --) = 'p';
      *(end --) = 'm';
      *(end --) = 'a';
      *(end) = '&';
      break;
    default:
      *(end) = *(cur);
      break;
    }
  }
  *new_str_ptr = new_str;
  return *new_str_ptr;
}
/**
 * Print a WARNING message to stderr which contains the name of the
 * program printing the warning, and "WARNING: "
 *
 * @author Gabriele Fariello
 *
 * @param format the format string
 * @param ... All the other stuff
 */
void warn(const int verbosity, const char *format, ...)
{
  if (opt_verbosity >= verbosity) {
    fprintf(stderr, "%s: WARNING: ", program);
    va_list attribs;
    va_start(attribs, format);
    vfprintf(stderr, format, attribs);
    va_end(attribs);
  }
}

/**
 * Print an ERROR message to stderr which contains the name of the
 * program printing the error, and "ERROR: " and exit non-zero
 *
 * @author Gabriele Fariello
 *
 * @param format the format string
 * @param ... All the other stuff
 */
void fatal(const char *format, ...)
{
  fprintf(stderr, "%s: FATAL ERROR: ", program);
  va_list attribs;
  va_start(attribs, format);
  vfprintf(stderr, format, attribs);
  va_end(attribs);
  exit(1);
}

/**
 * Try to open a file for writing or else print a somewhat useful message and
 * exit program non-zero
 *
 * @author Gabriele Fariello
 *
 * @param filename the filename of the file to open.
 *
 * @return a FILE pointer on success.
 */
FILE * fatal_open_write(char * filename) {
  FILE *file_ptr = fopen(filename,"w");
  int *i;
  i=i-4094000;
  if(NULL == file_ptr) {
    *i = 876;
    fatal("Unable to open file '%s' for writing.\n", filename);
  }
  return file_ptr;
}

void _print_version(FILE *fp) {
  fprintf(fp," Release Version: %s\n", version_string);
}
void _print_revision(FILE *fp) {
  fprintf(fp,"   Code Revision: %s\n", revision_string);
}
void _print_md5sum(FILE *fp) {
  fprintf(fp,"        Code MD5: %s\n", md5sum_string);
}
void _print_sha256sum(FILE *fp) {
  fprintf(fp,"    Code SHA-256: %s\n", sha256sum_string);
}
void _print_all_version_info(FILE *fp) {
  _print_version(fp);
  _print_revision(fp);
  _print_md5sum(fp);
  _print_sha256sum(fp);
}

void _usage(FILE *fp) {
  fprintf(fp,"--------------------------------------------------------------------------------\n");
  fprintf(fp,"\n Copyright 2007-2011 Harvard University / HHMI\n");
  fprintf(fp,"--------------------------------------------------------------------------------\n");
  fprintf(fp,"\n");
  fprintf(fp,"%s reads and creates NiFTI1 format .nii/.nii.gz files.\n", program);
  fprintf(fp,"\n");
  fprintf(fp,"Purpose: This program is designed to take in a 4D or 3D NiFTI1 stack of fMRI\n");
  fprintf(fp,"images with single or multiple time points (aka frames or slices) and evaluate\n");
  fprintf(fp,"the stability of the data by making several basic measurements. This program\n");
  fprintf(fp,"will optionally create a number of new NiFTI1 files as enumerated below.\n");
  fprintf(fp,"\n");
  _print_all_version_info(fp);
  fprintf(fp,"\n");
  fprintf(fp,"--------------------------------------------------------------------------------\n");
  fprintf(fp,"REPORT TEXT FILE: Columns in the report text file are:\n");
  fprintf(fp,"  snr    = signal to noise ratio (i.e., the ratio of mean to stdev)\n");
  fprintf(fp,"  min    = slice minimum\n");
  fprintf(fp,"  max    = slice maximum\n");
  fprintf(fp,"  voxels = the number of voxels being considered (> --threshold) per slice\n");
  fprintf(fp,"           (and then total in last line)\n");
  fprintf(fp,"  #out   = is the number of images > 2.5 stdev from the mean.\n");
  fprintf(fp,"--------------------------------------------------------------------------------\n");
  fprintf(fp,"MEAN SLICE DATA TEXT FILE:\n");
  fprintf(fp,"contains the mean slice intensity for each time point. This file can be viewed\n");
  fprintf(fp,"using a text editor graphed graphed using xvgr (e.g., xvgr S120r42.mean).\n");
  fprintf(fp,"\n");
  fprintf(fp,"--------------------------------------------------------------------------------\n");
  fprintf(fp,"Additional Notes:\n");
  fprintf(fp,"\n");
  fprintf(fp,"--skip  This option will cause stackcheck_nifti to skip the first n images in\n");
  fprintf(fp,"   all statistical calculations (e.g., -skip 4). this is good when\n");
  fprintf(fp,"   the first images are bad due to t1 stabiliation or other factors.\n");
  fprintf(fp,"\n");
  fprintf(fp,"For further information on how to use stackcheck_nifti, please visit CNLwiki\n");
  fprintf(fp,"page at http://www.nmr.mgh.harvard.edu/nexus\n");
  fprintf(fp,"--------------------------------------------------------------------------------\n");
  fprintf(fp,"Usage:    %s -i \"input NiFTI file\"\n", program);
  fprintf(fp,"--------------------------------------------------------------------------------\n");
  fprintf(fp,"OPTIONS:\n");
  fprintf(fp,"  -a               = Same as --all.\n");
  fprintf(fp,"  -c float         = Same as --scale.\n");
  fprintf(fp,"  -d               = Same as --debug.\n");
  fprintf(fp,"  -f string        = Same as --format.\n");
  fprintf(fp,"  -i file          = Same as --input.\n");
  fprintf(fp,"  -o file          = Same as --output-basname.\n");
  fprintf(fp,"  -R               = Same as --code-revision.\n");
  fprintf(fp,"  -t float         = Same as --threshold.\n");
  fprintf(fp,"  -v               = Same as --verbose.\n");
  fprintf(fp,"  -V               = Same as --all-version.\n");
  fprintf(fp," --basename file   = Same as --output-basename\n");
  fprintf(fp," --code-md5sum     = Print the source code MD5 checksum and exit 0.\n");
  fprintf(fp," --code-sha256sum  = Print the source code SHA256 checksum checksum and exit 0.\n");
  fprintf(fp," --code-revision   = Print the source code revision number and exit 0.\n");
  fprintf(fp," --debug           = Turn on debugging output (if compiled).\n");
  fprintf(fp," --no-debug        = Turn off debugging output (if compiled).\n");
  fprintf(fp," --format string   = Specify frames to count, e.g., \"4x120+4x76+\".\n");
  fprintf(fp,"                     WARNING: Untested in this version.\n");
  fprintf(fp," --help, -h or -?  = print this message.\n");
  fprintf(fp," --input file      = [REQUIRED] Input NiFTI file name.\n");
  fprintf(fp," --input-mask file = Input region NiFTI mask file name.\n");
  fprintf(fp," --mask            = Create a mask \"BASENAME_mask.nii\" created with the\n");
  fprintf(fp,"                     --threshold value.\n");
  fprintf(fp," --no-mask         = Do not create a mask \"BASENAME_mask.nii\".\n");
  fprintf(fp," --mean            = Create a mean \"BASENAME_mean.nii\" file.\n");
  fprintf(fp," --no-mean         = Do not create a mean \"BASENAME_mean.nii\" file.\n");
  fprintf(fp," --new             = Use the new file naming convention:\n");
  fprintf(fp,"                       report = \"BASENAME%s\"\n",opt_new_report_extension);
  fprintf(fp,"                       plot =   \"BASENAME%s\"\n",opt_new_mean_slice_data_extension);
  fprintf(fp,"                       stdev =  \"BASENAME%s\"\n",opt_new_snr_extension);
  fprintf(fp,"                       snr =    \"BASENAME%s\"\n",opt_new_stdev_extension);
  fprintf(fp," --old             = Use the old file naming convention (default):\n");
  fprintf(fp,"                       report = \"BASENAME%s\"\n",opt_default_report_extension);
  fprintf(fp,"                       plot =   \"BASENAME%s\"\n",opt_default_mean_slice_data_extension);
  fprintf(fp,"                       stdev =  \"BASENAME%s\"\n",opt_default_snr_extension);
  fprintf(fp,"                       snr =    \"BASENAME%s\"\n",opt_default_stdev_extension);
  fprintf(fp," --output-basename file\n");
  fprintf(fp,"                     Basename used for all of the created files.\n");
  fprintf(fp,"                     If file ends in \".nii\" or \".nii.gz\" extensions, they\"\n");
  fprintf(fp,"                     are removed for \"foo.nii\" will result in a basename of\n");
  fprintf(fp,"                     \"foo\".\n");
  fprintf(fp," --plot            = Create a \"BASENAME.mean.dat\" text file with mean\n");
  fprintf(fp,"                     slice intensity data.\n");
  fprintf(fp," --no-plot         = Do not create a \"BASENAME.mean.dat\"\n");
  fprintf(fp," --quiet           = Decrease verbosity (the more the quieter).\n");
  fprintf(fp," --reg file        = Input region NiFTI mask file name.\n");
  fprintf(fp," --report          = Create report statistics text for image slices.\n");
  fprintf(fp," --no-report       = Do not create report statistics text for image slices.\n");
  fprintf(fp," --report-xml      = Create a comprehensive XML report file.\n");
  fprintf(fp,"                     (default on).\n");
  fprintf(fp," --no-report-xml   = Do not create a comprehensive XML report file.\n");
  fprintf(fp," --scale float     = Scale created image values by specified factor.\n");
  fprintf(fp,"                     WARNING: Untested in this version.\n");
  fprintf(fp," --skip int        = Number of frams (aka volumes, aka time-points) to skip\n");
  fprintf(fp,"                     (default = 0).\n");
  fprintf(fp," --snr             = Create a slice-based mean SNR NiFTI-1 file.\n");
  fprintf(fp," --no-snr          = Do not create a slice-based mean SNR NiFTI-1 file.\n");
  fprintf(fp," --ts-slope        = Create a time-series best-fit slope (linear regression)\n");
  fprintf(fp,"                     NiFTI-1 file.\n");
  fprintf(fp," --no-ts-slope     = Do not create time-series best-fit slope NiFTI-1 file.\n");
  fprintf(fp," --thresh float    = Same as --threshold.\n");
  fprintf(fp," --threshold float = Threshold value for masking image (default = 150.0).\n");
  fprintf(fp," --threshold-input = Apply threshold to all images on first read (all values\n");
  fprintf(fp,"                     below --threshold are set to zero). By default --threshold\n");
  fprintf(fp,"                     is only used to create the --mask file\n");
  fprintf(fp," --stdev           = Create a standard deviation NiFTI-1 file.\n");
  fprintf(fp," --no-stdev        = Do not create a standard deviation NiFTI-1 file.\n");
  fprintf(fp," --verbose         = Increase verbosity (the more the louder).\n");
  fprintf(fp," --version         = Print vesion number and exit 0.\n");
  fprintf(fp," --all-version     = Print vesion, revision, md5sum and sha256sum and exit 0.\n");
  fprintf(fp," --all             = Same as --skip 4 [turn on --report-xml] --report --plot\n");
  fprintf(fp,"                      --mean --mask --snr --stdev --new [turn on --zip].\n");
  fprintf(fp," --use-float32-mask= Use FLOAT32 data type for the mask (which contains only 1's\n");
  fprintf(fp,"                     and 0's. This is the default for backwards compatability.\n");
  fprintf(fp," --use-uint8-mask  = Use the more appropriate UNIT8 data type for the mask.\n");
  fprintf(fp," --zip             = Create compressed \"BASENAME_something.nii.gz\" files.\n");
  fprintf(fp," --no-zip          = Create uncompressed \"BASENAME_something.nii\" files.\n");
  fprintf(fp,"--------------------------------------------------------------------------------\n");
  fprintf(fp,"Recommended usage:\n");
  fprintf(fp," %s --all --old --input nifti_file   # For pre 2012 compatability.\n", program);
  fprintf(fp," %s --all --input nifti_file         # For pre 2012 compatability.\n", program);
  fprintf(fp," %s --all --new --input nifti_file   # For improvements.\n", program);
  fprintf(fp,"--------------------------------------------------------------------------------\n");
  fprintf(fp,"NOTE: All options may be specified with one \"-\" or two \"--\" leading dashes.\n");
  // fprintf(fp,"SEE ALSO \"%s help ITEM\" for more information where ITEM is:\n");
  // fprintf(fp,"  report     = slice data report text file.\n\n");
  // fprintf(fp,"  report_xml = comprehensive report XML file.\n");
  // fprintf(fp,"  plot       = mean slice intensity plot data.\n");
  // fprintf(fp,"  stdev      = stdev image file.\n");
  // fprintf(fp,"  snr        = snr image file\n");
  fprintf(fp,"--------------------------------------------------------------------------------\n");
}       /* END usage */

void help_report(FILE *fp) {
  fprintf(fp,"--------------------------------------------------------------------------------\n");
  fprintf(fp,"The BASENAME%s file:\n",opt_default_report_extension);
  fprintf(fp,"--------------------------------------------------------------------------------\n");
  fprintf(fp,"\n");
  fprintf(fp,"--------------------------------------------------------------------------------\n");
  fprintf(fp,
          "This is a text file which has the following format:\n"
          "stackcheck_nifti version = \"0.9.0.1\"\n"
          "Input .nii root: \"/cluster/nrg/Pipeline/EMBARC/ExtendedBOLDQC/EMBARC/MGPH01MGMR1R1/5/nifti/MGPH01MGMR1R1_BOLD_5_EQC\"\n"
          "z = 39, x = 64, y = 64 images per slice = 397\n"
          "\n"
          "Timepoints = 397 skip = 0 count = 397\n"
          "\n"
          "Threshold value for mask: 200.00\n"
          "\n"
          "slice	voxels	mean	stdev	snr	min	max	#out\n"
          "001       1143	847.40	1.31	647.77	844.31	850.72	1\n"
          "002       1252	877.46	1.33	657.86	874.03	881.01	2\n"
          "003       1360	907.14	1.44	631.28	903.68	910.94	2\n"
          "[...]\n"
          "n-1       1266	1319.94	1.22	1084.28	1316.49	1323.43	4\n"
          "n         1154	1321.02	1.23	1073.99	1317.90	1324.47	3\n"
          "\n"
          "VOXEL	72369	1251.95	1.67	762.93	1248.08	1256.22	49/15483\n");
  fprintf(fp,"--------------------------------------------------------------------------------\n");
  fprintf(fp,
          "For each 2D slice (xdim by ydim)in a 4 or more dimensional NiFTI-1 image, the voxel\n"
          "count, mean, standard deviation, snr (mean/stdev), maximum value, minimum value,\n"
          "and the number of voxels > 1 stdev from the mean are calculated using every data\n"
          "point for the voxel (i.e., for every value of x,y and z, use every data point for\n"
          "all higher dimensions - usually only the t time dimension in 4D images) for all\n"
          "values >= --threshold (default 150.0).\n");
}

void usage() {
  _usage(stdout);
  exit(0);
}

/**
 * Print an ERROR message to stderr which contains the name of the
 * program printing the error, and "ERROR: " and exit non-zero
 *
 * @author Gabriele Fariello
 *
 * @param format the format string
 * @param ... All the other stuff
 */
void usage_error(const char *format, ...)
{
  _usage(stderr);
  fprintf(stderr, "%s: USAGE ERROR: ", program);
  va_list attribs;
  va_start(attribs, format);
  vfprintf(stderr, format, attribs);
  va_end(attribs);
  exit(1);
}
/**
 * Same as malloc, but on failure prints a meaningful error and exits
 * program non-zero
 *
 * @author Gabriele Fariello
 *
 * @param size resize to which size?
 *
 * @return a pointer of type void * to the memory allocated.
 */
void * fatal_malloc(size_t size) {
  void * ptr = (void *)malloc(size);
  if(NULL == ptr) {
    fatal("Out of memory. Failed to allocate %u bytes or RAM.\n",size);
  }
  return ptr;
}

/**
 * Same as realloc, but on failure prints a meaningful error and exits
 * program non-zero
 *
 * NOTE: One difference is that sending a size=0 will result in the
 * program exiting.
 *
 * @author Gabriele Fariello
 *
 * @param ptr A pointer to the memory to reallocate
 * @param size resize to which size?
 *
 * @return a pointer of type void * to the memory re-allocated. May be
 *         the same as ptr.
 */
void * fatal_realloc(void * ptr,size_t size) {
  ptr = (void *)realloc(ptr,size);
  if(NULL == ptr) {
    fatal("Out of memory. Failed to allocate %u bytes or RAM.\n",size);
  }
  return ptr;
}

/**
 * Print "verbose" output. Basically a rewritten fprintf that "knows"
 * where to print and if it should encapsulate output in comments.
 *
 * @author Gabriele Fariello
 *
 * @param verbosity opt_verbose must be >= verbosity in order for anything to
 *        be printed to the user.
 * @param format formatting string, like printf
 * @param ... other arguments like printf
 */
void verbose(int verbosity, const char *format, ...)
{
  if (opt_verbosity >= verbosity) {
    va_list attribs;
    va_start(attribs, format);
    vfprintf(stderr, format, attribs);
    va_end(attribs);
  }
}

/**
 * An sprintf version you can use lin-line because it returns a char* in
 * stead of the mostly useless int.
 *
 * @author Gabriele Fariello
 *
 * @param format formatting string, like printf
 * @param ... other arguments like printf
 */
char *bsprintf(char * buff, const char *format, ...) {
  int ret;
  va_list attribs;
  va_start(attribs, format);
  ret = vsprintf(buff, format, attribs);
  va_end(attribs);
  if(ret < 0) {
    strcpy("[error bsprintf() failed]",buff);
  }
  return buff;
}

/**
 * Print "debugging" output. Basically a rewritten fprintf that "knows"
 * where to print and if it should encapsulate output in comments. Also
 * prepends output with "progname: DEBUG: " to make it clear what's going on.
 *
 * @author Gabriele Fariello
 *
 * @param format formatting string, like printf
 * @param ... other arguments like printf
 */
void debug_out(const char *format, ...)
{
  if (opt_debug_on) {
    va_list attribs;
    fprintf(stderr, "%s: DEBUG: ", program);
    va_start(attribs, format);
    vfprintf(stderr, format, attribs);
    va_end(attribs);
  }
}

/**
 * Tests if a string ends with another string.
 *
 * @author Gabriele Fariello
 *
 * @param string the string to check
 * @param ending the string which the previous string should end with
 *
 * @return 1 if string ends with ending, 0 otherwise.
 */
int str_ends_with(char *string, char *ending) {
  int string_len = strlen(string);
  int ending_len = strlen(ending);
  char *string_ending = string + ending_len;
  if(ending_len > string_len) return 0;
  return str_equals(string_ending,ending);
}

/**
 * Removes a trailing string from another string.
 *
 * @author Gabriele Fariello
 *
 * @param string the string to check
 * @param ending the string to remove from the ending (if it exists)
 *
 * @return 1 if ending was removed from strin, 0 otherwise
 */
int str_remove_end(char *string, char *ending) {
  int string_len = strlen(string);
  int ending_len = strlen(ending);
  char *string_ending = string + (string_len - ending_len);
  debug(4,("str_remove_end(\"%s\",\"%s\");\n",string,ending));
  if(ending_len > string_len) {
    debug(4,("str_remove_end: Nothing changed. String too short.\n"));
    return 0;
  }
  debug(4,("str_remove_end: string_ending =\"%s\");\n",string_ending));
  if( str_equals(string_ending,ending) ) {
    /* Realloc, so that we don't have memory leaks */
    string = (char *)fatal_realloc(string,(string_len - ending_len + 1));
    *string_ending = '\0';
    debug(4,("str_remove_end: New string =\"%s\");\n",string));
    return 1;
  }
  debug(4,("str_remove_end: Nothing changed. Ending not present.\n"));
  return 0;
}

/**
 * Removes a trailing ".nii" or ".nii.gz" string from another string.
 *
 * @author Gabriele Fariello
 *
 * @param string the string from which to remove
 *
 * @return 1 if ending was removed from strin, 0 otherwise
 */
int str_remove_nii(char *string) {
  return str_remove_end(string,".nii") ||
    str_remove_end(string,".nii.gz");
}

/**
 * Create a new copy (clone) of a string.
 *
 * @author Gabriele Fariello
 *
 * @param string to clone
 *
 * @return a pointer to the new string copy
 */
char * str_clone(char *string) {
  char * new_str = NULL;
  new_str = (char *)fatal_malloc(strlen(string) + 1);
  strcpy(new_str,string);
  return new_str;
}

/**
 * Concatenate string2 to string1, reallocating memory as needed. Note that
 * this will alter string1
 *
 * @author Gabriele Fariello
 *
 * @param string1 string to which to concatenate string1
 * @param string2 string to concatenate to string2
 *
 * @return a pointer new string, may be same pointer as string1
 */
char * str_concat(char *string1, char * string2) {
  int new_length = strlen(string1) + strlen(string2) + 1;
  string1 = (char *)fatal_realloc(string1,new_length);
  strcat(string1,string2);
  return string1;
}

/**
 * Concatenate string2 to a clone of string1
 *
 * @author Gabriele Fariello
 *
 * @param string1 string clone and to whose clone to concatenate string1
 * @param string2 string to concatenate to the clone of string1
 *
 * @return a pointer new string
 */
char * str_new_concat(char *string1, char * string2) {
  return str_concat(str_clone(string1),string2);
}

/**
 * Return a filename conforming the the program's specification and the
 * user's requests for a given output file.
 *
 * @author Gabriele Fariello
 *
 * @param output_file a pointer to the output_file_t type in question
 *
 * @return the new filename
 */
void set_output_filename(output_file_t * ofile) {
  if( eq(".nii",ofile->type_extension) ||
      eq(".nii.gz",ofile->type_extension) ) {
    ofile->type_extension = output_nii_ext;
  }
  char *filename = str_concat(str_new_concat(ofile->basename,ofile->desc_extension),ofile->type_extension);
  if(NULL != ofile->filename) {
    /* 
    printf("WARNING: Filename was '%s' changing to '%s'. This should not happen.\n"
           , ofile->filename, filename);
    */
    free(ofile->filename);
  }
  ofile->filename = filename;
}

/**
 * Check if a file is a valid NiFTI1 file. If it is not, it prints an error
 * message and exits the program non-zero
 *
 * @author Gabriele Fariello
 *
 * @param filename the file name to check
 * @param error_is_fatal if set to ERROR_IS_FATAL will exit program if filename
 *        is not a valid NiFTI1 file.
 *
 * @return 1 if filename is a valid NiFTI1 file, 0 otherwise
 */
int is_nifti(char *filename, int error_is_fatal) {
  nifti_image *nim ;
  FILE * bogus;
  struct stat tmp;
  if(0 != stat ( filename, &tmp )) {
    if(ERROR_IS_FATAL == error_is_fatal)
      fatal("File '%s' does not exist.\n",filename);
    return 0;
  }
  /* Proved to be easier just to try and open it than to check the various
   * stat values for the current guid() and ggid() */
  bogus = fopen(filename,"r");
  if(NULL == bogus) {
    if(ERROR_IS_FATAL == error_is_fatal)
      fatal("File '%s' is not readable.\n",filename);
    return 0;
  }
  fclose(bogus);
  nim = nifti_image_read( filename, 0 ) ;
  if( nim == NULL ) {
    if(ERROR_IS_FATAL == error_is_fatal)
      fatal("File '%s' is not a NiFTI1 file.\n",filename);
    return 0;
  }
  return 1;
}

/**
 * Attempt to get the full name of the NiFTI file (assuming that filename
 * may just be the prefix and filename.nii or filename.nii.gz may be the
 * "real" NiFTI file name).
 *
 * @author Gabriele Fariello
 *
 * @param filename the file name to check
 * @param error_is_fatal if set to ERROR_IS_FATAL will exit program none of
 *        filename, filename.nii or filename.nii.gz are a valid NiFTI1 file.
 *
 * @return The filename of the valid file if one was found, NULL otherwise
 */
char * get_nifti_filename(char *filename, int error_is_fatal) {
  char *new_filename = str_clone(filename);
  if(is_nifti(new_filename,ERROR_IS_NOT_FATAL))
    return new_filename;
  new_filename = str_concat(new_filename,".nii");
  if(is_nifti(new_filename,ERROR_IS_NOT_FATAL))
    return new_filename;
  new_filename = str_concat(new_filename,".gz");
  if(is_nifti(new_filename,ERROR_IS_NOT_FATAL))
    return new_filename;
  if(ERROR_IS_FATAL == error_is_fatal) {
    fatal("Could not locate a valid NiFTI1 file by the name \"%s\",  \"%s.nii\", or \"%s.nii.gz\". Giving up.\n",
          filename, filename, filename);
  }
  free(new_filename);
  return NULL;
}

/**
 * Get the argument from the command-line arguments at index, if any
 *
 * @author Gabriele Fariello
 *
 * @param index the index of the command-line argument to get
 *
 * @return The argument if one was found, NULL otherwise
 */
static char * opt_get_arg(int index) {
  const int argc = glob_argc;
  char **argv;
  argv = glob_argv;
  if(index >= argc) return NULL;
  return str_clone(argv[index]);
}

/**
 * Get the argument from the command-line arguments at index, if any
 *
 * @author Gabriele Fariello
 *
 * @param index the index of the command-line argument to get
 *
 * @return The argument if one was found, NULL otherwise
 */
static char * opt_get_if_match(char **aliases,int index) {
  char *arg_name = opt_get_arg(index);
  if(NULL == arg_name)
    fatal("Internal program error while parsing command-line arguments. Index beyond end of list.\n");
  while(*aliases) {
    if(str_equals(*aliases, arg_name)) {
      return arg_name;
    }
  }
  free(arg_name);
  return NULL;
}

/**
 * Set a value based on the argument from the command-line argument at index,
 * if is is one of the aliases.
 *
 * If index is past the end of the command-line agrument list, or if the current
 * command-line argument matches an alias but the next index is past the end of
 * the list, will produce a fatal error.
 *
 * NOTE: This function is used internally and is called by other functions. Use
 * opt_set_as_string() in stead.
 *
 * @author Gabriele Fariello
 *
 * @param aliases a NULL terminated array of strings. If the current argument
 *        matches any of the strings, *opt_val is set to the next argument.
 * @param index the index of the command-line agrument to check
 * @param opt_val a pointer to the string to set
 *
 * @return 1 if the current command-line argument matched one of the aliases,
 *         0 otherwise.
 */
static int _opt_set_as_string(char **aliases, int *index, char **opt_val) {
  char *arg_name = opt_get_if_match(aliases,*index);
  if(arg_name) {
    (*index)++;
    (*opt_val) = opt_get_arg(*index);
    if(NULL == (*opt_val))
      usage_error("Option: \"--%s\" requires a parameter, but none was provided.\n",arg_name);
    return 1;
  }
  return 0;
}

/**
 * Set a value based on the argument from the command-line argument at index,
 * if is is one of the aliases.
 *
 * If index is past the end of the command-line agrument list, or if the current
 * command-line argument matches an alias but the next index is past the end of
 * the list, will produce a fatal error.
 *
 * @author Gabriele Fariello
 *
 * @param aliases a NULL terminated array of strings. If the current argument
 *        matches any of the strings, *opt_val is set to the next argument.
 * @param index the index of the command-line agrument to check
 * @param opt_val a pointer to the string to set
 *
 * @return 1 if the current command-line argument matched one of the aliases,
 *         0 otherwise.
 */
int opt_set_as_string(char **aliases, int *index, char **opt_val) {
  char *arg_name = opt_get_arg(*index);
  if(_opt_set_as_string(aliases,index,opt_val)) {
    if('-' == (**opt_val) && '\0' != (*(*(opt_val)+1)) ) {
      warn(1,"Option: \"--%s\" was set to \"%s\", which has a leading '-'.\n",arg_name,*opt_val);
    } else {
      debug(4,("Option: \"--%s\" was set to \"%s\".\n",arg_name,*opt_val));
    }
    return 1;
  }
  return 0;
}

/**
 * Set a value based on the argument from the command-line argument at index,
 * if is is one of the aliases. Checks for leading '-' in file name exists.
 *
 * If index is past the end of the command-line agrument list, or if the current
 * command-line argument matches an alias but the next index is past the end of
 * the list, will produce a fatal error.
 *
 * @author Gabriele Fariello
 *
 * @param aliases a NULL terminated array of strings. If the current argument
 *        matches any of the strings, *opt_val is set to the next argument.
 * @param index the index of the command-line agrument to check
 * @param opt_val a pointer to the string to set
 *
 * @return 1 if the current command-line argument matched one of the aliases,
 *         0 otherwise.
 */
int opt_set_as_filename(char **aliases, int *index, char **opt_val) {
  char *arg_name = opt_get_arg(*index);
  if(_opt_set_as_string(aliases,index,opt_val)) {
    if('-' == (**opt_val) && '\0' != (*(*(opt_val)+1)) ) {
      usage_error("Option: \"--%s\" requires a file name. \"%s\" has a leading '-'. "
                  "If you really want to use the file name \"%s\" "
                  "try using \"./%s\" in stead.\n",
                  arg_name,*opt_val,*opt_val,*opt_val);
    }
    debug(4,("Option: \"--%s\" was set to \"%s\".\n",arg_name,**opt_val));
    return 1;
  }
  return 0;
}

/**
 * Set a value based on the argument from the command-line argument at index,
 * if is is one of the aliases.
 *
 * If index is past the end of the command-line agrument list, or if the current
 * command-line argument matches an alias but the next index is past the end of
 * the list, will produce a fatal error.
 *
 * @author Gabriele Fariello
 *
 * @param aliases a NULL terminated array of strings. If the current argument
 *        matches any of the strings, *opt_val is set to the next argument.
 * @param index the index of the command-line agrument to check
 * @param opt_val a pointer to the float to set
 *
 * @return 1 if the current command-line argument matched one of the aliases,
 *         0 otherwise.
 */
int opt_set_as_double(char **aliases, int *index, double *opt_val) {
  char *string,*end;
  char *arg_name = opt_get_arg(*index);
  if(_opt_set_as_string(aliases,index,&string)) {
    *opt_val = strtod(string,&end);
    if (string == end || *end != '\0') {
      *opt_val = (double)strtol(string,&end,10);
      if (string == end || *end != '\0') {
        usage_error("Option: \"--%s\" expects a float (e.g., 1.23) but received \"%s\".\n",arg_name,string);
      }
    }
    debug(4,("Option: \"--%s\" was set to \"%g\".\n",arg_name,*opt_val));
    return 1;
  }
  return 0;
}

/**
 * Set a value based on the argument from the command-line argument at index,
 * if is is one of the aliases.
 *
 * If index is past the end of the command-line agrument list, or if the current
 * command-line argument matches an alias but the next index is past the end of
 * the list, will produce a fatal error.
 *
 * @author Gabriele Fariello
 *
 * @param aliases a NULL terminated array of strings. If the current argument
 *        matches any of the strings, *opt_val is set to the next argument.
 * @param index the index of the command-line agrument to check
 * @param opt_val a pointer to the float to set
 *
 * @return 1 if the current command-line argument matched one of the aliases,
 *         0 otherwise.
 */
int opt_set_as_int(char **aliases, int *index, int *opt_val) {
  char *string,*end;
  char *arg_name = opt_get_arg(*index);
  if(_opt_set_as_string(aliases,index,&string)) {
    *opt_val = (int)strtol(string,&end,10);
    if (string == end || *end != '\0') {
      usage_error("Option: \"--%s\" expects a integer (e.g., 234) but received \"%s\".\n",arg_name,string);
    }
    debug(4,("Option: \"--%s\" was set to \"%d\".\n",arg_name,*opt_val));
    return 1;
  }
  return 0;
}

/**
 * Toggle a value based on the argument from the command-line argument at index,
 * if is is one of the aliases.
 *
 * @author Gabriele Fariello
 *
 * @param aliases a NULL terminated array of strings. If the current argument
 *        matches any of the strings, *opt_val is set to the next argument.
 * @param index the index of the command-line agrument to check
 * @param opt_val a pointer to the float to set
 *
 * @return 1 if the current command-line argument matched one of the aliases,
 *         0 otherwise.
 */
int opt_toggle(char **aliases, int *index, int *opt_val) {
  char *arg_name = opt_get_if_match(aliases,*index);
  if(arg_name) {
    *opt_val = *opt_val ? 0 : 1;
    debug(4,("Option: \"--%s\" was toggled to %s.\n",arg_name,(*opt_val ? "ON": "OFF")));
    return 1;
  }
  return 0;
}

/**
 * Returm a "new" initialized output_file_t type struct.
 *
 * @author Gabriele Fariello
 *
 * @param desc a human-readable description of the file.
 * @param basename the basename of the file (basename + desc_ext + type_desc
 *        is the file name)
 * @param desc_ext the "descriptive" extension, e.g. "_mean" or "_report"
 * @param type_ext the "file type" extension, e.g. ".txt", ".nii" or ".xml"
 *
 * @return a pointer to a output_file_t
 */
output_file_t * new_inited_output_file(char * desc,char * basename, char *desc_ext, char *type_ext) {
  output_file_t *ofile = (output_file_t *)fatal_malloc(sizeof(output_file_t));
  ofile->description = desc;
  ofile->basename = basename;
  ofile->desc_extension = desc_ext;
  ofile->type_extension = type_ext;
  ofile->filename = (char *)fatal_malloc(strlen(basename)+strlen(desc_ext)+strlen(type_ext) + 4);
  strcpy(ofile->filename,basename);
  strcat(ofile->filename,desc_ext);
  strcat(ofile->filename,type_ext);
  ofile->create = 0;
  ofile->data_array = NULL;
  ofile->min = 0.0;
  ofile->max = 0.0;
  ofile->mean = 0.0;
  ofile->sum = 0.0;
  ofile->variance = 0.0;
  ofile->snr = 0.0;
  ofile->stdev = 0.0;
  ofile->data_length = 0;
  ofile->nan_count = 0;
  ofile->inf_count = 0;
  ofile->zero_count = 0;
  ofile->one_count = 0;
  ofile->n_count = 0;
  return ofile;
}
/**
 * Returm a "new" array of initialized output_file_t type structs.
 *
 * @author Gabriele Fariello
 *
 * @param basename the basename of the file (basename + desc_ext + type_desc
 *        is the file name)
 *
 * @return an array of pointers to output_file_t type structs
 */
static output_file_t ** _init_output_files(char * basename) {
  output_file_t **ofile_array = (output_file_t **)fatal_malloc(SC_NUM_FILES * sizeof(output_file_t *));
  ofile_array[SC_INPUT_IMAGE_IDX]
    = new_inited_output_file("Input NiFTI-1 Image File"
                             , basename, "", ".nii");
  ofile_array[SC_REPORT_TEXT_IDX]
    = new_inited_output_file("QC Text-Based Report Summary File"
                             , basename, "_report", ".txt");
  ofile_array[SC_REPORT_XML_IDX]
    = new_inited_output_file("QC Comlete Report XML File"
                             , basename, "_report", ".xml");
  ofile_array[SC_MEAN_SLICE_TEXT_IDX]
    = new_inited_output_file("Per-Slice Summary Statistics Text File"
                             , basename, ".mean", ".dat");
  ofile_array[SC_MEAN_IMAGE_IDX]
    = new_inited_output_file("Mean Intensity NiFTI-1 Image File"
                             , basename, "_mean", ".nii");
  ofile_array[SC_MASK_IMAGE_IDX]
    = new_inited_output_file("Mask Intensity NiFTI-1 Image File"
                             , basename, "_mask", ".nii");
  ofile_array[SC_SNR_IMAGE_IDX]
    = new_inited_output_file("Signal-to-Noise Ration (SNR) NiFTI-1 Image File"
                             , basename, "_snr", ".nii");
  ofile_array[SC_STDEV_IMAGE_IDX]
    = new_inited_output_file("Standard Deviation (StDev) NiFTI-1 Image File"
                             , basename, "_stdev", ".nii");
  ofile_array[SC_SLOPE_IMAGE_IDX]
    = new_inited_output_file("Time Series Best-Fit Slope (Linear Regression) NiFTI-1 Image File"
                             , basename, "_slope", ".nii");
  return ofile_array;
}
/**
 * Initialize two identical arrays of output_file_t type structs.
 *
 * One is used solely to display default information, the other is changed by
 * the provided command-line arguments as needed.
 *
 * @author Gabriele Fariello
 *
 * @return nothin'
 */
void init_output_files() {
  default_output_file_array = _init_output_files("BASENAME");
  output_file_array = _init_output_files("BASENAME");
}

/**
 * Calculate some quick, sanity checking stats before outputting the file
 *
 * In these statistics, any voxels that are not a number, or positive or
 * negative infinity are excluded. All values that are exactly equal to
 * zero are considered masked and excluded as well EXCEPT when only values
 * equal to exactly zero or one are present (as in a mask image) in
 * which case, all are counted.
 *
 * @author Gabriele Fariello
 *
 * @return nothin'
 */
template<typename inType>
void output_file_quick_stats(output_file_t * ofile, inType *data, unsigned long long data_length, double scale) {
  double  min      = 0.0;
  double  max      = 0.0;
  double  mean     = 0.0;
  double  sum      = 0.0;
  double  variance = 0.0;
  unsigned long long nan_count  = 0;
  unsigned long long inf_count  = 0;
  unsigned long long zero_count = 0;
  unsigned long long one_count  = 0;
  unsigned long long n_count  = 0;
  unsigned long long i;
  int skip_zeros = 1;
  int do_scale = (0.0 == scale || 1.0 == scale) ? 0 : 1;
  if(NULL == data || 0 == data_length)
    return;
  min = *data;
  max = *data;
  ofile->data_length = data_length;
  ofile->data_array = (void *)data;
  for(i=0;i<data_length;i++) {
    if(do_scale) data[i] = data[i] * (inType)scale;
    double value = (double)(data[i]);
    if(isnan(value)) {
      data[i] = (inType)(0.0);
      nan_count++;
    } else if(isinf(value)) {
      data[i] = (inType)(0.0);
      inf_count++;
    } else {
      if(isnan(min) || isinf(min) || value < min)
        min = value;
      if(isnan(max) || isinf(max) || value > max)
        max = value;
      if(0.0 == value)
        zero_count ++;
      else {
        if(1.0 == value)
          one_count ++;
        sum += value;
      }
    }
  }
  if(zero_count + one_count == data_length) {
    n_count = data_length;
    skip_zeros = 0;
  } else {
    n_count = data_length - nan_count - inf_count - zero_count;
  }
  mean = (sum / (double)n_count);
  for(i=0;i<data_length;i++) {
    double value = (double)(data[i]);
    if (skip_zeros && 0.0 == value) {
      continue;
    } else {
      value = value - mean;
      variance += (value * value);
    }
  }
  variance = variance / n_count;
  ofile->min = min;
  ofile->max = max;
  ofile->mean = mean;
  ofile->sum = sum;
  ofile->nan_count = nan_count;
  ofile->inf_count = inf_count;
  ofile->zero_count = zero_count;
  ofile->one_count = one_count;
  ofile->n_count = n_count;
  ofile->variance = variance;
  ofile->stdev = sqrt(variance);
  ofile->snr = mean / ofile->stdev;
}

/**
 * Pupose not entirely clear.
 *
 * @author Unknown
 *
 * @param n1 an int of some sort
 * @param n1 an int of some sort
 * @return a pointer to and array of pointer to floats
 */
double **calloc_float2(int n1, int n2)
{
  int i;
  double **a;
  if (!(a = (double **)malloc(n1 * sizeof(double *))))
    fatal("Out of memory while allocating data buffer for temp_imgt\n");
  if (!(a[0] = (double *)calloc(n1 * n2, sizeof(double))))
    fatal("Out of memory while allocating data buffer for plot_imgt\n");
  for (i = 1; i < n1; i++)
    a[i] = a[0] + i * n2;
  return a;
}

/**
 * Pupose not entirely clear.
 *
 * @author Unknown
 *
 * @param a a point to an array of pointers to doubles
 */
void free_float2(double **a)
{
  free(a[0]);
  free(a);
}

/**********************************************************************
 *
 * read_nifti_file
 *
 **********************************************************************/
int read_nifti_file(char* input_nifti_filename)
{

  /*********************************/
  /*Reading using FSL read function*/
  /*********************************/

  FSLIO *fslio;
  void *buffer;
  verbose(2,"Reading in NiFTI file \"%s\".\n",input_nifti_filename);
  is_nifti(input_nifti_filename, ERROR_IS_FATAL);
  fslio = FslInit();
  buffer = FslReadAllVolumes(fslio, input_nifti_filename);
  if(NULL == buffer)
    fatal("Unable to open file '%s' for reading.\n", input_nifti_filename);

  /***********************************/
  /* get input nifti image dimensions */
  /***********************************/
  xnum = fslio->niftiptr->nx;
  ynum = fslio->niftiptr->ny;
  znum = fslio->niftiptr->nz;
  number_of_timepoints = fslio->niftiptr->nt;
  nvox_in_3d_vol = xnum * ynum * znum;
  total_data_count = number_of_timepoints * nvox_in_3d_vol;
  nvox_in_2d_slice = xnum * ynum;
  nslices = znum;

  /* Convert Data to double */
  input_data_as_double = (double *)fatal_malloc(total_data_count * sizeof(double));
  convertBufferToScaledDouble(input_data_as_double, fslio->niftiptr->data,
                              total_data_count, 1, 0,
                              fslio->niftiptr->datatype);
  /* Apply mask image to data, if asked to do so */
  if ( opt_input_mask_filename ) {
    FSLIO *msk;
    char *mskbuffer;
    unsigned mskbpp = 0;
    double *mskvol;
    short mskdim[4];
    short x_dimmsk, y_dimmsk, z_dimmsk, v_dimmsk, t;
    int ifile;
    int voxel_idx;
    verbose(2,"Applying NiFTI Mask file \"%s\" to \"%s\" on read.\n",opt_input_mask_filename,input_nifti_filename);
    msk = FslOpen(FslMakeBaseName(opt_input_mask_filename), "r");
    if(NULL == msk)
      fatal("Unable to open input mask file '%s' for reading.\n", opt_input_mask_filename);
    ifile = 0;
    FslGetDim(msk, &x_dimmsk, &y_dimmsk, &z_dimmsk, &v_dimmsk);
    mskdim[0] = x_dimmsk;
    mskdim[1] = y_dimmsk;
    mskdim[2] = z_dimmsk;
    mskdim[3] = v_dimmsk;
    mskbpp = FslGetDataType(msk, &t) / 8;
    mskbuffer =
      (char *)fatal_malloc(mskdim[0] * mskdim[1] * mskdim[2] *
                           mskdim[3] * mskbpp * sizeof(char));
    FslReadVolumes(msk, mskbuffer, mskdim[3]);
    mskvol =
      (double *)fatal_malloc(mskdim[0] * mskdim[1] * mskdim[2] *
                             mskdim[3] * sizeof(double));
    convertBufferToScaledDouble(mskvol, mskbuffer,
                                mskdim[0] * mskdim[1] * mskdim[2] *
                                mskdim[3], 1.0, 0.0,
                                msk->niftiptr->datatype);
    for (voxel_idx = 0; voxel_idx < nvox_in_3d_vol; voxel_idx++) {
      if (0 == mskvol[voxel_idx]) {
        /* Zero out this whole time series */
        int timepoint_idx;
        for (timepoint_idx = 0; timepoint_idx < number_of_timepoints; timepoint_idx++) {
          input_data_as_double[timepoint_idx] = 0;
        }
      }
    }
  }

  /***********/
  /* utility */
  /***********/

  int i, j, k;
  double q;

  /***********************************/
  /* allocate buffer for stats info  */
  /***********************************/
  image_variance_data = (double *)fatal_malloc(nvox_in_3d_vol * sizeof(double));
  image_mean_data = (double *)fatal_malloc(nvox_in_3d_vol * sizeof(double));
  image_mask_data = (double *)fatal_malloc(nvox_in_3d_vol * sizeof(double));
  slice_max_data = (double *)fatal_malloc(nvox_in_3d_vol * sizeof(double));
  slice_voxel_count_data = (int *)fatal_malloc(nvox_in_3d_vol * sizeof(int));
  slice_min_data = (double *)fatal_malloc(nvox_in_3d_vol * sizeof(double));
  slice_stdev_data = (double *)fatal_malloc(nvox_in_3d_vol * sizeof(double));
  slice_mean_data = (double *)fatal_malloc(nvox_in_3d_vol * sizeof(double));
  slice_snr = (double *)fatal_malloc(nvox_in_3d_vol * sizeof(double));
  slice_out = (int *)fatal_malloc(nvox_in_3d_vol * sizeof(int));
  tempimgt = calloc_float2(number_of_timepoints, nvox_in_3d_vol);
  plotimgt = calloc_float2(number_of_timepoints, nslices);

  /***********************************/
  /* set up frames to count (format) */
  /***********************************/

  verbose(1,"stackcheck_nifti: opt_skip=%d\n", opt_skip);
  nf_func = number_of_timepoints - opt_skip;
  if (nf_func < 0) {
    fatal("%s has more skip than total frames\n",input_nifti_filename);
  }
  if(NULL == opt_format) {
    opt_format = (char *)fatal_malloc(opt_skip + nf_func);
    for (j = k = 0; j < opt_skip; j++)
      opt_format[k++] = 'x';
    for (j = 0; j < nf_func; j++)
      opt_format[k++] = '+';
  }
  verbose(1,"%s\n", opt_format);
  for (nf_func = j = 0; j < number_of_timepoints; j++)
    if (opt_format[j] == '+')
      nf_func++;
  verbose(1,"frames total = %d counted = %d skip = %d\n", number_of_timepoints, nf_func,
          number_of_timepoints - nf_func);
  verbose(1,"%s: opt_skip = %d\n", program, opt_skip);
  nf_func = number_of_timepoints - opt_skip;
  if (nf_func < 0) {
    fatal("--skip %s is more than total frames in '%s'\n",
          opt_skip,input_nifti_filename);
  }

  /********************************/
  /* compute mean and logical and */
  /********************************/

  verbose(1,"Reading: %s", input_nifti_filename);
  verbose(1,"\t%d frames\n", nf_func);
  verbose(1,"Please wait...This may take a few minutes\n");

  { // START Scoped Block 1
    int timepoint_idx = 0, voxel_idx = 0, count = 0;
    double tmp_sum;
    for (timepoint_idx = 0; timepoint_idx < number_of_timepoints; timepoint_idx++) {
      if (opt_format[timepoint_idx] != '+')
        continue;
      for (voxel_idx = 0; voxel_idx < nvox_in_3d_vol; voxel_idx++) {
        tempimgt[timepoint_idx][voxel_idx] = (input_data_as_double[voxel_idx + timepoint_idx * nvox_in_3d_vol]);  /*holds image data for each frame */
        if (opt_threshold_all_data) {
          if (input_data_as_double[voxel_idx + timepoint_idx * nvox_in_3d_vol] > opt_threshold) {
            temp_data = (input_data_as_double[voxel_idx + timepoint_idx * nvox_in_3d_vol]);
            image_mean_data[voxel_idx] += temp_data;
          } else
            image_mean_data[voxel_idx] = 0;
        } else {
          image_mean_data[voxel_idx] += (input_data_as_double[voxel_idx + timepoint_idx * nvox_in_3d_vol]);
        }
        if (input_data_as_double[voxel_idx + timepoint_idx * nvox_in_3d_vol] > opt_threshold) {
          tmp_sum += (input_data_as_double[voxel_idx + timepoint_idx * nvox_in_3d_vol]);
          count++;
        }

      }

    }

    scale_factor = tmp_sum / count; /*used for normalizing image */
    for (i = 0; i < nvox_in_3d_vol; i++) {
      image_mean_data[i] /= k; /*mean image in a run */
      if (isnan(image_mean_data[i]))
        image_mean_data[i] = 0.0;
    }
  } // END Scoped Block 1

  /********************/
  /* compute variance */
  /********************/

  for (k = j = 0; j < number_of_timepoints; j++) {
    if (opt_format[j] != '+')
      continue;
    k++;
    for (i = 0; i < nvox_in_3d_vol; i++) {
      if (opt_threshold_all_data) {
        if (input_data_as_double[i + j * nvox_in_3d_vol] > opt_threshold) {
          temp_data = (input_data_as_double[i + j * nvox_in_3d_vol]);
          q = temp_data - image_mean_data[i];
        } else
          q = 0;
        image_variance_data[i] += q * q;
      } else {
        q = (input_data_as_double[i + j * nvox_in_3d_vol]) - image_mean_data[i];
        image_variance_data[i] += q * q;
      }
    }
  }

  for (i = 0; i < nvox_in_3d_vol; i++) {
    image_variance_data[i] /= (k - 1);
    if (isnan(image_variance_data[i]))
      image_variance_data[i] = 0.0;
  }     /*computing variance */

  /************************************************************************/
  /* make mask around mean volume brain and calculate mean slice intensity*/
  /************************************************************************/
  sum_voxel = 0;
  sum_mean = 0.;
  for (slice = 0; slice < nslices; slice++) {
    double sum = 0.;
    int count = 0;

    for (count = i = 0; i < nvox_in_2d_slice; i++) {
      if (image_mean_data[i + (slice * nvox_in_2d_slice)] > opt_threshold) {
        image_mask_data[i + (slice * nvox_in_2d_slice)] = 1;
        sum += image_mean_data[i + (slice * nvox_in_2d_slice)];
        count += 1;
      } else
        image_mask_data[i + (slice * nvox_in_2d_slice)] = 0;

    }

    slice_mean_data[slice] = sum / count;  /*mean slice intensity */
    slice_voxel_count_data[slice] = count; /*sum of inbrain voxels per slice */
    sum_voxel += slice_voxel_count_data[slice];  /*sum of inbrain voxel values for all slices */
    if (slice_voxel_count_data[slice] != 0)  /*check for zero voxel count & exclude from calculation */
      sum_mean += ((slice_mean_data[slice]) * (slice_voxel_count_data[slice])); /*sum of all mean intensities */
    slice_max_data[slice] = 0.;
    slice_min_data[slice] = 10000.;

  }

  /**********************************************************************************************/
  /* compute mean intensity for inbrain voxels, slice standard deviation slice snr and slice out*/
  /**********************************************************************************************/
  sum_max = 0.;
  sum_min = 0.;
  sum_stdev = 0.;
  sum_snr = 0.;
  sum_out = 0;
  { /* END BLOCK to Scope some variables */
    double * image_mean = (double *)fatal_malloc(number_of_timepoints * sizeof(double));
  for (slice = 0; slice < nslices; slice++) {
    for (j = 0; j < number_of_timepoints; j++) {
      if (opt_format[j] != '+') continue;
      double tmp_sum = 0.;
      int count1 = 0;
      for (i = 0; i < nvox_in_2d_slice; i++) {
        if (image_mask_data[i + (slice * nvox_in_2d_slice)]) {
          count1++;
          tmp_sum += tempimgt[j][i + (slice * nvox_in_2d_slice)];  /*sum of inbrain voxels per slice */
        }
      }

      image_mean[j] = tmp_sum / (count1);

      plotimgt[j][slice] = image_mean[j];
      if (image_mean[j] > slice_max_data[slice])
        slice_max_data[slice] = image_mean[j];
      if (image_mean[j] < slice_min_data[slice])
        slice_min_data[slice] = image_mean[j];

    }
    if (slice_voxel_count_data[slice] == 0) {  /*outputting "nan" for zero voxel count */
      verbose(2,"Deliberately setting NaNs on slice number %d\n",slice);
      slice_min_data[slice] = NAN;
      slice_max_data[slice] = NAN;
    }

    if (slice_voxel_count_data[slice] != 0)
      sum_min += ((slice_min_data[slice]) * (slice_voxel_count_data[slice]));

    if (slice_voxel_count_data[slice] != 0)
      sum_max += ((slice_max_data[slice]) * (slice_voxel_count_data[slice]));

    double sum_diff = 0.;
    diff = 0.;
    for (j = 0; j < number_of_timepoints; j++) {
      if (opt_format[j] != '+')
        continue;
      diff = image_mean[j] - slice_mean_data[slice];
      sum_diff += fabs(diff * diff);
    }
    slice_stdev_data[slice] = sqrt(sum_diff / (number_of_timepoints - opt_skip - 1));
    slice_snr[slice] = slice_mean_data[slice] / slice_stdev_data[slice];

    if (slice_voxel_count_data[slice] != 0)
      sum_stdev +=
        ((slice_stdev_data[slice]) * (slice_voxel_count_data[slice]));

    if (slice_voxel_count_data[slice] != 0)
      sum_snr += ((slice_snr[slice]) * (slice_voxel_count_data[slice]));

    for (j = 0; j < number_of_timepoints; j++) {
      if (opt_format[j] != '+')
        continue;
      if ((fabs(image_mean[j] - slice_mean_data[slice])) >
          (stdev_out * slice_stdev_data[slice])) {
        slice_out[slice]++;
      }
    }

    sum_out += slice_out[slice];

    if (opt_verbosity > 0) {
      printf
        ("%d\t%d\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%d\n",
         slice + 1, slice_voxel_count_data[slice], slice_mean_data[slice],
         slice_stdev_data[slice], slice_snr[slice],
         slice_min_data[slice], slice_max_data[slice],
         slice_out[slice]);
    }

  }
  } /* END BLOCK to Scope some variables */

  return (0);
}

void verbose_toggle(char * description, int *value) {
  *value = *value ? 0 : 1;
  verbose(2,"Option: Set %s to %s.\n",description, (*value ? "ON" : "OFF"));
}

void verbose_toggle_on(char * description, int *value) {
  if(! *value) verbose_toggle(description, value);
}

void verbose_toggle_off(char * description, int *value) {
  if(*value) verbose_toggle(description, value);
}

void set_opt_new() {
  opt_report_extension = opt_new_report_extension;
  opt_mean_slice_data_extension = opt_new_mean_slice_data_extension;
  opt_snr_extension = opt_new_snr_extension;
  opt_stdev_extension = opt_new_stdev_extension;
  opt_output_report_text = 1;
  verbose(2,"Option: Set file extension for report text file to \"%s\".\n", opt_report_extension);
  verbose(2,"Option: Set file extension for mean slice data text file to \"%s\".\n", opt_mean_slice_data_extension);
  verbose(2,"Option: Set file extension for SNR NiFTI to \"%s\".\n", opt_snr_extension);
  verbose(2,"Option: file extension for Set standard devation NiFTI to \"%s\".\n", opt_stdev_extension);
}
void set_opt_old() {
  opt_report_extension = opt_default_report_extension;
  opt_mean_slice_data_extension = opt_default_mean_slice_data_extension;
  opt_snr_extension = opt_default_snr_extension;
  opt_stdev_extension = opt_default_stdev_extension;
  opt_output_report_text = 1;
  verbose(2,"Option: Set file extension for report text file to \"%s\".\n", opt_report_extension);
  verbose(2,"Option: Set file extension for mean slice data text file to \"%s\".\n", opt_mean_slice_data_extension);
  verbose(2,"Option: Set file extension for SNR NiFTI to \"%s\".\n", opt_snr_extension);
  verbose(2,"Option: file extension for Set standard devation NiFTI to \"%s\".\n", opt_stdev_extension);
}

double * rescale_data(double factor, double *data, int length) {
  double *current = data;
  double * end = data + length;
  for(;current < end;current++) {
    // Faster if not dereferencing a pointer
    double tmp = *current;
    tmp = tmp * factor;
    if(isnan(tmp) || isinf(tmp))
      tmp = 0.0;
    // Remember to put it back
    *current = tmp;
  }
  return data;
}

output_file_t *output_file_prepare(int idx, double *data, unsigned long long data_length, double scale) {
  output_file_t *ofile = output_file_array[idx];
  if(! ofile->create) return ofile;
  set_output_filename(ofile);
  printf("Creating %s ('%s')\n", ofile->filename, ofile->description);
  output_file_quick_stats<double>(ofile, data, data_length,scale);
  return ofile;
}

/**********************************************************************
 *
 * write_nifti_file
 *
 * write a nifti1 (.nii) data file
 *
 * using nifti_image structure from nifti1_io.h
 ***********************************************************************/
template<typename oldType, typename newType>
void * convert_data(oldType *old_data, long long len) {
  long long i;
  newType * new_data = (newType *)fatal_malloc(len * sizeof(oldType));
  for(i = 0; i < len; i++) {
    oldType old = old_data[i];
    new_data[i] = (newType)old;
  }
  return new_data;
}

//int write_nifti_file(char *input_nifti_filename, char*outfile, double *fptr, int nvox_in_3d_vol)
//{
void save_nii(int idx, double *data, unsigned long long data_length, double scale, FSLIO *input_fslio, int output_type) {
  void * new_data;
  FSLIO *output_fslio;
  output_file_t *ofile = output_file_prepare(idx,data,data_length,scale);
  if(! ofile->create) return;

  FslSetDataType(input_fslio, output_type);

  output_fslio = FslOpen(ofile->filename, "wb");
  if(NULL == output_fslio)
    fatal("Unable to open file '%s' for writing.\n", ofile->filename);
  FslCloneHeader(output_fslio, input_fslio);
  output_fslio->niftiptr->nt = 1;
  FslSetDataType(output_fslio, input_fslio->niftiptr->datatype);
  FslSetDimensionality(output_fslio, 4);

  switch (input_fslio->niftiptr->datatype) {
  case NIFTI_TYPE_UINT8:
    new_data = convert_data<double,THIS_UINT8>(data,data_length);
    break;
  case NIFTI_TYPE_INT8:
    new_data = convert_data<double,THIS_INT8>(data,data_length);
    break;
  case NIFTI_TYPE_UINT16:
    new_data = convert_data<double,THIS_UINT16>(data,data_length);
    break;
  case NIFTI_TYPE_INT16:
    new_data = convert_data<double,THIS_INT16>(data,data_length);
    break;
  case NIFTI_TYPE_UINT64:
    new_data = convert_data<double,THIS_UINT64>(data,data_length);
    break;
  case NIFTI_TYPE_INT64:
    new_data = convert_data<double,THIS_INT64>(data,data_length);
    break;
  case NIFTI_TYPE_UINT32:
    new_data = convert_data<double,THIS_UINT32>(data,data_length);
    break;
  case NIFTI_TYPE_INT32:
    new_data = convert_data<double,THIS_INT32>(data,data_length);
    break;
  case NIFTI_TYPE_FLOAT32:
    new_data = convert_data<double,THIS_FLOAT32>(data,data_length);
    break;
  case NIFTI_TYPE_FLOAT64:
    new_data = convert_data<double,THIS_FLOAT64>(data,data_length);
    break;
  case NIFTI_TYPE_FLOAT128:
  case NIFTI_TYPE_COMPLEX128:
  case NIFTI_TYPE_COMPLEX256:
  case NIFTI_TYPE_COMPLEX64:
  default:
    fatal("Unsupported NiFTI data type '%s'.\n",
          nifti_datatype_string(input_fslio->niftiptr->datatype));
  }
  FslWriteHeader(output_fslio);
  FslWriteVolumes(output_fslio, new_data, 1);
  FslClose(output_fslio);
  return;
}

void save_mean_slice_text_data() {
  int j;
  output_file_t *ofile = output_file_prepare(SC_MEAN_SLICE_TEXT_IDX,NULL,0,0.0);
  if(! ofile->create) return;
  FILE * output_fp = fatal_open_write(ofile->filename);
  for (j = 0; j < number_of_timepoints; j++) {
    fprintf(output_fp, "%d\t", j);
    for (slice = 0; slice < nslices; slice++) {
      fprintf(output_fp, "%4.2f\t", plotimgt[j][slice]);
    }
    fprintf(output_fp, "\n");
  }
  fclose(output_fp);
}

void save_report_text_file() {
  output_file_t *ofile = output_file_prepare(SC_REPORT_TEXT_IDX,NULL,0,0.0);
  if(! ofile->create) return;
  FILE * fp = fatal_open_write(ofile->filename);
  int slice_idx;
  fprintf(fp, "%s version = \"%s\"\n", program, version_string);
  fprintf(fp, "Input .nii root: \"%s\"\n", output_file_array[SC_INPUT_IMAGE_IDX]->basename);
  fprintf(fp, "z = %d, x = %d, y = %d images per slice = %d\n\n", znum, xnum, ynum, number_of_timepoints);
  fprintf(fp, "Timepoints = %d skip = %d count = %d\n\n", number_of_timepoints, number_of_timepoints - nf_func, nf_func);
  fprintf(fp, "Threshold value for mask: %4.2f\n\n", opt_threshold);
  fprintf(fp, "slice\tvoxels\tmean\tstdev\tsnr\tmin\tmax\t#out\n");
  for (slice_idx = 0; slice_idx < nslices; slice_idx++) {
    fprintf(fp, "%-10.3d\%-d\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%d\n",
            slice_idx + 1, slice_voxel_count_data[slice_idx],
            slice_mean_data[slice_idx], slice_stdev_data[slice_idx],
            slice_snr[slice_idx], slice_min_data[slice_idx],
            slice_max_data[slice_idx], slice_out[slice_idx]);
  }
  fprintf(fp, "\nVOXEL\t%d\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%d/%d\n",
          sum_voxel, (sum_mean / sum_voxel),
          (sum_stdev / sum_voxel), (sum_snr / sum_voxel),
          (sum_min / sum_voxel), (sum_max / sum_voxel), (sum_out),
          (znum * number_of_timepoints));
  fclose(fp);
}

static char *indent_str = "  ";
void xml_simple_el(FILE *fp, char * indent,const char *element, char *text) {
  char *xml_text = NULL;
  xmlify(text, &xml_text);
  fprintf(fp,"%s<%s>%s</%s>\n", indent, element, xml_text, element);
  free(xml_text);
}
void xml_increase_indent(char *old_str) {
  if(strlen(old_str) < 1000) {
    strcat(old_str,indent_str);
  }
}
void xml_decrease_indent(char *old_str) {
  int len = strlen(old_str);
  if(strlen(old_str) > 2) {
    *(old_str + len - strlen(indent_str)) = '\0';
  }
}
void xml_start_el(FILE *fp, char * indent,const char *element) {
  fprintf(fp,"%s<%s>\n", indent, element);
  xml_increase_indent(indent);
}
void xml_end_el(FILE *fp, char * indent,const char *element) {
  xml_decrease_indent(indent);
  fprintf(fp,"%s</%s>\n", indent, element);
}
void xml_opt(FILE *fp, char * indent, char *name, char *value) {
  xml_start_el(fp,indent,"option");
  xml_simple_el(fp, indent, "name", name);
  xml_simple_el(fp, indent, "value", value);
  xml_end_el(fp,indent,"option");
}

void xml_ofile_info(FILE *fp, char * indent, int idx) {
  output_file_t *ofile = output_file_array[idx];
  char *abspath_str = canonicalize_file_name(ofile->filename);
  if(NULL == abspath_str) abspath_str = ofile->filename;
  char *basename_str = basename(abspath_str);
  int is_nii = str_ends_with(basename_str, ".nii") || str_ends_with(basename_str, ".nii.gz");
  int is_txt = (
                str_ends_with(basename_str, ".txt") ||
                str_ends_with(basename_str, ".dat") ||
                str_ends_with(basename_str, ".report")
                );
  char str[1024];
  const char *extension_str = is_nii ? ".nii" : strrchr(basename_str,'.');
  if(NULL == extension_str) extension_str = "";
  if(! ofile->create) fprintf(fp,"<!-- file not created since option was not set, but documented here\n");
  xml_start_el(fp,indent,"file");
  xml_simple_el(fp,indent,"name",basename_str);
  if(is_nii) {
    xml_simple_el(fp,indent,"type","NiFTI-1");
    xml_simple_el(fp,indent,"mime-type","application/octet-stream");
  } else if(is_txt) {
    xml_simple_el(fp,indent,"type","text");
    xml_simple_el(fp,indent,"mime-type","text/plain");
  } else if( str_equals(".xml",extension_str) ) {
    xml_simple_el(fp,indent,"type","XML");
    xml_simple_el(fp,indent,"mime-type","text/xml");
  } else {
    xml_simple_el(fp,indent,"type","other/unkown");
    xml_simple_el(fp,indent,"mime-type","application/octet-stream");
  }
  xml_simple_el(fp,indent,"description",ofile->description);
  xml_simple_el(fp,indent,"abspath",abspath_str);
  xml_simple_el(fp,indent,"basename",basename_str);
  xml_simple_el(fp,indent,"extension",(char *)extension_str);
  xml_simple_el(fp,indent,"provided_name",ofile->filename);
  xml_simple_el(fp,indent,"provided_basename",ofile->basename);
  xml_simple_el(fp,indent,"provided_desc_extension",ofile->desc_extension);
  xml_simple_el(fp,indent,"provided_type_extension",ofile->type_extension);
  xml_simple_el(fp,indent,"created",(char *)(ofile->create ? "YES" : "NO"));
  if(is_nii || ofile->data_array || ofile->data_length) {
    xml_simple_el(fp,indent,"data_array", (char *)(ofile->data_array ? "PRESENT" : "MISSING") );
    xml_start_el(fp,indent,"stats");
    xml_simple_el(fp,indent,"min", bsprintf(str,"%lf",ofile->min));
    xml_simple_el(fp,indent,"max", bsprintf(str,"%lf", ofile->max));
    xml_simple_el(fp,indent,"mean", bsprintf(str,"%lf", ofile->mean));
    xml_simple_el(fp,indent,"sum", bsprintf(str,"%lf", ofile->sum));
    xml_simple_el(fp,indent,"variance", bsprintf(str,"%lf", ofile->variance));
    xml_simple_el(fp,indent,"snr", bsprintf(str,"%lf", ofile->snr));
    xml_simple_el(fp,indent,"stdev", bsprintf(str,"%lf", ofile->stdev));
    xml_simple_el(fp,indent,"data_length", bsprintf(str,"%ld", ofile->data_length));
    xml_simple_el(fp,indent,"nan_count", bsprintf(str,"%ld", ofile->nan_count));
    xml_simple_el(fp,indent,"inf_count", bsprintf(str,"%ld", ofile->inf_count));
    xml_simple_el(fp,indent,"zero_count", bsprintf(str,"%ld", ofile->zero_count));
    xml_simple_el(fp,indent,"one_count", bsprintf(str,"%ld", ofile->one_count));
    xml_simple_el(fp,indent,"n_count", bsprintf(str,"%ld", ofile->n_count));
    xml_end_el(fp,indent,"stats");
  }
  xml_end_el(fp,indent,"file");
  if(! ofile->create) fprintf(fp," -->\n");
}
void save_report_xml() {
  output_file_t *ofile = output_file_prepare(SC_REPORT_XML_IDX,NULL,0,0.0);
  char indent[1024] = "";
  char str[1024];
  if(! ofile->create) return;
  FILE * fp = fatal_open_write(ofile->filename);
  int i = 0, slice_idx;
  xml_start_el(fp, indent, "stackcheck-nifti xmlns=\"http://www.neuroinfo.org/neuroinfo\"");
  xml_start_el(fp, indent, "program");
  xml_simple_el(fp, indent, "name", program);
  xml_simple_el(fp, indent, "version", version_string);
  xml_simple_el(fp, indent, "revision", revision_string);
  xml_simple_el(fp, indent, "md5sum", md5sum_string);
  xml_simple_el(fp, indent, "sha256sum", sha256sum_string);
  xml_start_el(fp,indent,"command-line-arguments");
  for(i = 0; i < glob_argc; i++) {
    xml_simple_el(fp, indent, "argument",glob_argv[i]);
  }
  xml_end_el(fp,indent, "command-line-arguments");
  xml_start_el(fp, indent, "settings");
  xml_opt(fp, indent, "opt_input_mask_filename", opt_input_mask_filename);
  xml_opt(fp, indent, "opt_debug_on", bsprintf(str,"%ld", opt_debug_on));
  xml_opt(fp, indent, "opt_output_report_text", bsprintf(str,"%ld", opt_output_report_text));
  xml_opt(fp, indent, "opt_create_report_xml", bsprintf(str,"%ld", opt_create_report_xml));
  xml_opt(fp, indent, "opt_create_mean_slice_txt", bsprintf(str,"%ld", opt_create_mean_slice_txt));
  xml_opt(fp, indent, "opt_create_mean_nii", bsprintf(str,"%ld", opt_create_mean_nii));
  xml_opt(fp, indent, "opt_create_mask_nii", bsprintf(str,"%ld", opt_create_mask_nii));
  xml_opt(fp, indent, "opt_create_stdev_nii", bsprintf(str,"%ld", opt_create_stdev_nii));
  xml_opt(fp, indent, "opt_create_slope_nii", bsprintf(str,"%ld", opt_create_slope_nii));
  xml_opt(fp, indent, "opt_create_snr_nii", bsprintf(str,"%ld", opt_create_snr_nii));
  xml_opt(fp, indent, "opt_verbosity", bsprintf(str,"%ld", opt_verbosity));
  xml_opt(fp, indent, "opt_zip_output_nii", bsprintf(str,"%ld", opt_zip_output_nii));
  xml_opt(fp, indent, "opt_threshold_all_data", bsprintf(str,"%ld", opt_threshold_all_data));
  xml_opt(fp, indent, "opt_default_report_extension", opt_default_report_extension);
  xml_opt(fp, indent, "opt_default_mean_slice_data_extension", opt_default_mean_slice_data_extension);
  xml_opt(fp, indent, "opt_default_snr_extension", opt_default_snr_extension);
  xml_opt(fp, indent, "opt_default_stdev_extension", opt_default_stdev_extension);
  xml_opt(fp, indent, "opt_new_report_extension", opt_new_report_extension);
  xml_opt(fp, indent, "opt_new_mean_slice_data_extension", opt_new_mean_slice_data_extension);
  xml_opt(fp, indent, "opt_new_snr_extension", opt_new_snr_extension);
  xml_opt(fp, indent, "opt_new_stdev_extension", opt_new_stdev_extension);
  xml_opt(fp, indent, "opt_report_extension", opt_report_extension);
  xml_opt(fp, indent, "opt_mean_slice_data_extension", opt_mean_slice_data_extension);
  xml_opt(fp, indent, "opt_snr_extension", opt_snr_extension);
  xml_opt(fp, indent, "opt_stdev_extension", opt_stdev_extension);
  xml_opt(fp, indent, "opt_slope_extension", opt_slope_extension);
  xml_end_el(fp, indent, "settings");
  xml_end_el(fp, indent, "program");
  xml_start_el(fp, indent, "results");
  xml_start_el(fp, indent, "input-file");
  xml_simple_el(fp, indent, "name", output_file_array[SC_INPUT_IMAGE_IDX]->filename);
  xml_start_el(fp, indent, "dimensions");
  xml_simple_el(fp, indent, "x", bsprintf(str,"%ld", xnum));
  xml_simple_el(fp, indent, "y", bsprintf(str,"%ld", ynum));
  xml_simple_el(fp, indent, "z", bsprintf(str,"%ld", znum));
  xml_simple_el(fp, indent, "t", bsprintf(str,"%ld", number_of_timepoints));
  xml_end_el(fp, indent, "dimensions");
  xml_end_el(fp, indent, "input-file");
  xml_start_el(fp, indent, "output-files");
  for(i = 0; i < SC_NUM_FILES; i++) {
    xml_ofile_info(fp,indent,i);
  }
  xml_end_el(fp, indent, "output-files");
  fprintf(fp,"    <mask-threshold>%0.4f</mask-threshold>\n", opt_threshold);
  fprintf(fp,"    <slices>\n");
  fprintf(fp,"      <total>%d</total>\n", number_of_timepoints);
  fprintf(fp,"      <skipped>%d</skipped>\n",number_of_timepoints - nf_func);
  fprintf(fp,"      <count>%d</count>\n",nf_func);
  for (slice_idx = 0; slice_idx < nslices; slice_idx++) {
    fprintf(fp,
            "      <slice>\n"
            "        <number>%d</number>\n"
            "        <voxel-count>%d</voxel-count>\n"
            "        <mean>%f</mean>\n"
            "        <stdev>%f</stdev>\n"
            "        <snr>%f</snr>\n"
            "        <min>%f</min>\n"
            "        <max>%f</max>\n"
            "        <outliers>%d</outliers>\n"
            "      </slice>\n"
            , slice_idx + 1, slice_voxel_count_data[slice_idx],
            slice_mean_data[slice_idx], slice_stdev_data[slice_idx],
            slice_snr[slice_idx], slice_min_data[slice_idx],
            slice_max_data[slice_idx], slice_out[slice_idx]);
  }
  fprintf(fp,
          "      <slice-summary>\n"
          "        <voxel-count>%d</voxel-count>\n"
          "        <mean>%f</mean>\n"
          "        <stdev>%f</stdev>\n"
          "        <snr>%f</snr>\n"
          "        <min>%f</min>\n"
          "        <max>%f</max>\n"
          "        <outliers>%d</outliers>\n"
          "        <total>%d</total>\n"
          "      </slice-summary>\n"
          "    </slices>\n"
          ,sum_voxel, (sum_mean / sum_voxel),
          (sum_stdev / sum_voxel), (sum_snr / sum_voxel),
          (sum_min / sum_voxel), (sum_max / sum_voxel), (sum_out),
          (znum * number_of_timepoints));
  fprintf(fp,"  </results>\n");
  fprintf(fp,"</stackcheck-nifti>\n");
  fclose(fp);
}

/* Fit the data (x_i, y_i) to the linear relationship

   Y = c0 + c1 x

   returning,

   c0, c1  --  coefficients
   cov00, cov01, cov11  --  variance-covariance matrix of c0 and c1,
   sumsq   --   sum of squares of residuals

   This fit can be used in the case where the errors for the data are
   uknown, but assumed equal for all points. The resulting
   variance-covariance matrix estimates the error in the coefficients
   from the observed variance of the points around the best fit line.
*/

int
gsl_fit_linear (const double *x, const size_t xstride,
                const double *y, const size_t ystride,
                const size_t n,
                double *c0, double *c1,
                double *cov_00, double *cov_01, double *cov_11, double *sumsq)
{
  double m_x = 0, m_y = 0, m_dx2 = 0, m_dxdy = 0;

  size_t i;

  for (i = 0; i < n; i++)
    {
      m_x += (x[i * xstride] - m_x) / (i + 1.0);
      m_y += (y[i * ystride] - m_y) / (i + 1.0);
    }

  for (i = 0; i < n; i++)
    {
      const double dx = x[i * xstride] - m_x;
      const double dy = y[i * ystride] - m_y;

      m_dx2 += (dx * dx - m_dx2) / (i + 1.0);
      m_dxdy += (dx * dy - m_dxdy) / (i + 1.0);
    }

  /* In terms of y = a + b x */

  {
    double s2 = 0, d2 = 0;
    double b = m_dxdy / m_dx2;
    double a = m_y - m_x * b;

    *c0 = a;
    *c1 = b;

    /* Compute chi^2 = \sum (y_i - (a + b * x_i))^2 */

    for (i = 0; i < n; i++)
      {
        const double dx = x[i * xstride] - m_x;
        const double dy = y[i * ystride] - m_y;
        const double d = dy - b * dx;
        d2 += d * d;
      }

    s2 = d2 / (n - 2.0);        /* chisq per degree of freedom */

    *cov_00 = s2 * (1.0 / n) * (1 + m_x * m_x / m_dx2);
    *cov_11 = s2 * 1.0 / (n * m_dx2);

    *cov_01 = s2 * (-m_x) / (n * m_dx2);

    *sumsq = d2;
  }

  return 1;
}


int main(int argc, char **argv)
{

  /***************************/
  /* variables used in main()*/
  /***************************/

  short do_read = 0;
  char *ptr;
  int i, k, do_exit = 0, exit_val = 0;
  char *input_nifti_basename=NULL, *input_nifti_filename=NULL;
  init_output_files();
  glob_argc = argc;
  glob_argv = argv;
  if (NULL != (ptr = strrchr(argv[0], '/'))) {
    ptr++;
  } else {
    ptr = argv[0];
  }
  strcpy(program, ptr);
  verbose(2,"%s version = \"%s\"\n", program, version_string);
  /************************/
  /* process command line */
  /************************/
  for (k = 0, i = 1; i < argc; i++) {

    char *this_arg = argv[i];
    if('-' == *this_arg) {
      /* allow --arg notation */
      if('-' == *(this_arg+1)) this_arg++;
      if (str_equals("-o",this_arg) ||
          str_equals("-output-basename",this_arg) ||
          str_equals("-basename",this_arg) ) {
        output_basename = str_clone(argv[(++i)]);
        str_remove_nii(output_basename);
        verbose(2,"Option: Ouput file basename set to \"%s\".\n",output_basename);
      } else if (str_equals("-code-md5sum",this_arg)) {
        _print_md5sum(stdout);
        do_exit = 1;
      } else if (str_equals("-code-sha256sum",this_arg)) {
        _print_sha256sum(stdout);
        do_exit = 1;
      } else if (str_equals("-R",this_arg) ||
                 str_equals("-code-revision",this_arg)) {
        _print_revision(stdout);
        do_exit = 1;
      } else if (str_equals("-d",this_arg) ||
                 str_equals("-debug",this_arg) ) {
        verbose_toggle_on("Debug",&opt_debug_on);
      } else if (str_equals("-nd",this_arg) ||
                 str_equals("-no-debug",this_arg) ) {
        verbose_toggle_off("Debug",&opt_debug_on);
      } else if (str_equals("-f",this_arg) ||
                 str_equals("-format",this_arg)) {
        opt_format = str_clone(argv[(++i)]);
        verbose(2,"Option: Format set to \"%s\".\n",opt_format);
      } else if (str_equals("-h",this_arg) ||
                 str_equals("-?",this_arg) ||
                 str_equals("-help",this_arg)) {
        usage();
      } else if (str_equals("-i",this_arg) ||
                 str_equals("-input",this_arg)) {
        do_read = 1;
        /* Get the fill file name of the NiFTI file */
        input_nifti_filename = str_clone(argv[(++i)]);
        input_nifti_basename = str_clone(input_nifti_filename);
        get_nifti_filename(input_nifti_filename,ERROR_IS_FATAL);
        /* Get the basename of the input NiFTI file */
        str_remove_nii(input_nifti_basename);
        verbose(2,"Input file set to \"%s\".\n",input_nifti_filename);
        verbose(2,"Input basename set to \"%s\".\n",input_nifti_basename);
      } else if (str_equals("-reg",this_arg) ||
                 str_equals("-input-mask",this_arg)) {
        /* next arg should be the filename, use and increment i */
        opt_input_mask_filename = str_clone(argv[(++i)]);
        /* remove any trailing ".nii" or ".nii.gz" */
        str_remove_nii(opt_input_mask_filename);
      } else if (str_equals("-mask",this_arg)) {
        verbose_toggle_on("create mask NiFTI image",&opt_create_mask_nii);
      } else if (str_equals("-mask",this_arg)) {
        verbose_toggle_off("create mask NiFTI image",&opt_create_mask_nii);
      } else if (str_equals("-mean",this_arg)) {
        verbose_toggle_on("create mean NiFTI image",&opt_create_mean_nii);
      } else if (str_equals("-no-mean",this_arg)) {
        verbose_toggle_off("create mean NiFTI image",&opt_create_mean_nii);
      } else if (str_equals("-new",this_arg)) {
        set_opt_new();
      } else if (str_equals("-old",this_arg)) {
        set_opt_old();
      } else if (str_equals("-plot",this_arg)) {
        verbose_toggle_on("output mean slice intensity text data",&opt_create_mean_slice_txt);
      } else if (str_equals("-no-plot",this_arg)) {
        verbose_toggle_off("output mean slice intensity text data",&opt_create_mean_slice_txt);
      } else if (str_equals("-quiet",this_arg)) {
        opt_verbosity --;
        verbose(2,"Option: Decreased verbosity to %d.\n", opt_verbosity);
      } else if (str_equals("-report",this_arg)) {
        verbose_toggle_on("Create report text file",&opt_output_report_text);
      } else if (str_equals("-no-report",this_arg)) {
        verbose_toggle_off("Create report text file",&opt_output_report_text);
      } else if (str_equals("-report-xml",this_arg)) {
        verbose_toggle_on("Create report text file",&opt_output_report_text);
      } else if (str_equals("-no-report-xml",this_arg)) {
        verbose_toggle_off("Create report text file",&opt_output_report_text);
      } else if (str_equals("-c",this_arg) ||
                 str_equals("-scale", this_arg)) {
        factor = atof(argv[(++i)]);
        verbose(2,"Option: Scaling factor set to %4.4f.\n",factor);
      } else if (str_equals("-skip",this_arg)) {
        /* next arg should be number ot skip */
        opt_skip = atoi(argv[(++i)]);
        verbose(2,"Option: Set skip to %d.\n",opt_skip);
      } else if (str_equals("-snr",this_arg)) {
        verbose_toggle_on("create SNR NiFTI image",&opt_create_snr_nii);
      } else if (str_equals("-no-snr",this_arg)) {
        verbose_toggle_off("create SNR NiFTI image",&opt_create_snr_nii);
      } else if (str_equals("-stdev",this_arg)) {
        verbose_toggle_on("create standard deviation NiFTI",&opt_create_stdev_nii);
      } else if (str_equals("-no-stdev",this_arg)) {
        verbose_toggle_off("create standard deviation NiFTI",&opt_create_stdev_nii);
      } else if (str_equals("-ts-slope",this_arg)) {
        verbose_toggle_on("create standard deviation NiFTI",&opt_create_slope_nii);
      } else if (str_equals("-no-ts-slope",this_arg)) {
        verbose_toggle_off("create standard deviation NiFTI",&opt_create_slope_nii);
      } else if (str_equals("-t",this_arg) ||
                 str_equals("-thresh",this_arg) ||
                 str_equals("-threshold",this_arg)) {
        /* next arg should be thresh hold value */
        opt_threshold = atof(argv[(++i)]);
        verbose(2,"Option: Set threshold to %4.2f.\n",opt_threshold);
      } else if (str_equals("-threshold-input",this_arg)) {
        verbose_toggle_on("apply thresholding to all data on first read",&opt_threshold_all_data);
      } else if (str_equals("-no-thresholdinput",this_arg)) {
        verbose_toggle_off("apply thresholding to all data on first read",&opt_threshold_all_data);
      } else if (str_equals("-v",this_arg) ||
                 str_equals("-verbose",this_arg)) {
        opt_verbosity ++;
        verbose(2,"Option: Increase verbosity to %d.\n", opt_verbosity);
      } else if (str_equals("-version",this_arg)) {
        _print_version(stdout);
        do_exit = 1;
      } else if (str_equals("-V",this_arg) ||
                 str_equals("-all-version",this_arg)) {
        _print_all_version_info(stdout);
        do_exit = 1;
      } else if (str_equals("-a",this_arg) ||
                 str_equals("-all",this_arg)) {
        opt_skip = 4;
        verbose(2,"Option: Set skip to %d.\n",opt_skip);
        verbose_toggle_on("Create report text file",&opt_output_report_text);
        verbose_toggle_on("output report XML file",&opt_create_report_xml);
        verbose_toggle_on("output mean slice intensity text data",&opt_create_mean_slice_txt);
        verbose_toggle_on("create mask NiFTI image",&opt_create_mask_nii);
        verbose_toggle_on("create mean NiFTI image",&opt_create_mean_nii);
        verbose_toggle_on("create SNR NiFTI image",&opt_create_snr_nii);
        verbose_toggle_on("create standard deviation NiFTI",&opt_create_stdev_nii);
        set_opt_new();
      } else if (str_equals("-use-uint8-mask",this_arg)) {
        verbose_toggle_on("Use UINT8 type for the mask NiFTI",&opt_use_uint8_mask);
      } else if (str_equals("-use-float32-mask",this_arg)) {
        verbose_toggle_off("Use UINT8 type for the mask NiFTI",&opt_use_uint8_mask);
      } else if (str_equals("-zip",this_arg)) {
        verbose_toggle_on("create zipped NiFTI files",&opt_zip_output_nii);
      } else if (str_equals("-no-zip",this_arg)) {
        verbose_toggle_off("create zipped NiFTI files",&opt_zip_output_nii);
      } else {
        usage_error("Did not understand \"%s\".\n",argv[i]);
      }
    }
  }
  if(do_exit)
    exit(exit_val);
  if (!input_nifti_basename || str_equals("",input_nifti_basename)) {
    usage_error("Must specify at least an input file with -i.\n");
  }

  /* output NiFTI file extension */
  if (opt_zip_output_nii == 1) output_nii_ext = ".nii.gz";

  /* if no output_basename was specified, use input_nifti_basename as the basename */
  if (NULL == output_basename) {
    output_basename = str_clone(input_nifti_basename);
  }

  output_file_t *ofile = NULL;
  ofile = output_file_array[SC_INPUT_IMAGE_IDX];
  ofile->basename = input_nifti_basename;
  ofile->desc_extension = "";
  ofile->type_extension = output_nii_ext;
  ofile->filename = input_nifti_filename;
  ofile->create = 1;

  FSLIO *input_fslio;
  input_fslio = FslInit();
  FslReadAllVolumes(input_fslio, output_file_array[SC_INPUT_IMAGE_IDX]->filename);

  unsigned long long data_length = input_fslio->niftiptr->nvox;

  switch (input_fslio->niftiptr->datatype) {
  case NIFTI_TYPE_UINT8:
    output_file_quick_stats<THIS_UINT8>(ofile, (THIS_UINT8 *)(input_fslio->niftiptr->data), data_length, (double)factor);
    break;
  case NIFTI_TYPE_INT8:
    output_file_quick_stats<THIS_INT8>(ofile, (THIS_INT8 *)(input_fslio->niftiptr->data), data_length, (double)factor);
    break;
  case NIFTI_TYPE_UINT16:
    output_file_quick_stats<THIS_UINT16>(ofile, (THIS_UINT16 *)(input_fslio->niftiptr->data), data_length, (double)factor);
    break;
  case NIFTI_TYPE_INT16:
    output_file_quick_stats<THIS_INT16>(ofile, (THIS_INT16 *)(input_fslio->niftiptr->data), data_length, (double)factor);
    break;
  case NIFTI_TYPE_UINT32:
    output_file_quick_stats<THIS_UINT32>(ofile, (THIS_UINT32 *)(input_fslio->niftiptr->data), data_length, (double)factor);
    break;
  case NIFTI_TYPE_INT32:
    output_file_quick_stats<THIS_INT32>(ofile, (THIS_INT32 *)(input_fslio->niftiptr->data), data_length, (double)factor);
    break;
  case NIFTI_TYPE_UINT64:
    output_file_quick_stats<THIS_UINT64>(ofile, (THIS_UINT64 *)(input_fslio->niftiptr->data), data_length, (double)factor);
    break;
  case NIFTI_TYPE_INT64:
    output_file_quick_stats<THIS_INT64>(ofile, (THIS_INT64 *)(input_fslio->niftiptr->data), data_length, (double)factor);
    break;
  case NIFTI_TYPE_FLOAT32:
    output_file_quick_stats<THIS_FLOAT32>(ofile, (THIS_FLOAT32 *)(input_fslio->niftiptr->data), data_length, (double)factor);
    break;
  case NIFTI_TYPE_FLOAT64:
    output_file_quick_stats<THIS_FLOAT64>(ofile, (THIS_FLOAT64 *)(input_fslio->niftiptr->data), data_length, (double)factor);
    break;
  case NIFTI_TYPE_FLOAT128:
  case NIFTI_TYPE_COMPLEX128:
  case NIFTI_TYPE_COMPLEX256:
  case NIFTI_TYPE_COMPLEX64:
  default:
    fatal("Unsupported NiFTI data type '%s'.\n",
          nifti_datatype_string(input_fslio->niftiptr->datatype));
  }

  ofile = output_file_array[SC_REPORT_TEXT_IDX];
  ofile->basename = output_basename;
  ofile->desc_extension = opt_report_extension;
  ofile->type_extension = "";
  ofile->create = opt_output_report_text;

  ofile = output_file_array[SC_REPORT_XML_IDX];
  ofile->basename = output_basename;
  ofile->desc_extension = "_report";
  ofile->type_extension = ".xml";
  ofile->create = opt_create_report_xml;

  ofile = output_file_array[SC_MEAN_SLICE_TEXT_IDX];
  ofile->basename = output_basename;
  ofile->desc_extension = opt_mean_slice_data_extension;
  ofile->type_extension = "";
  ofile->create = opt_create_mean_slice_txt;

  ofile = output_file_array[SC_MEAN_IMAGE_IDX];
  ofile->basename = output_basename;
  ofile->desc_extension = "_mean";
  ofile->type_extension = output_nii_ext;
  ofile->create = opt_create_mean_nii;

  ofile = output_file_array[SC_MASK_IMAGE_IDX];
  ofile->basename = output_basename;
  ofile->desc_extension = "_mask";
  ofile->type_extension = output_nii_ext;
  ofile->create = opt_create_mask_nii;

  ofile = output_file_array[SC_SNR_IMAGE_IDX];
  ofile->basename = output_basename;
  ofile->desc_extension = opt_snr_extension;
  ofile->type_extension = output_nii_ext;
  ofile->create = opt_create_snr_nii;

  ofile = output_file_array[SC_STDEV_IMAGE_IDX];
  ofile->basename = output_basename;
  ofile->desc_extension = opt_stdev_extension;
  ofile->type_extension = output_nii_ext;
  ofile->create = opt_create_stdev_nii;

  ofile = output_file_array[SC_SLOPE_IMAGE_IDX];
  ofile->basename = output_basename;
  ofile->desc_extension = opt_slope_extension;
  ofile->type_extension = output_nii_ext;
  ofile->create = opt_create_slope_nii;

  /********** do the simple read or write */
  if (do_read)
    read_nifti_file(input_nifti_filename);

  FSLIO * fslio_tmp_input = FslInit();
  FslReadAllVolumes(fslio_tmp_input, input_nifti_filename);

  save_nii(SC_MEAN_IMAGE_IDX,image_mean_data,nvox_in_3d_vol,factor,fslio_tmp_input,NIFTI_TYPE_FLOAT32);
  if(opt_use_uint8_mask) {
    save_nii(SC_MASK_IMAGE_IDX,image_mask_data,nvox_in_3d_vol,factor,fslio_tmp_input,NIFTI_TYPE_UINT8);
  } else {
    save_nii(SC_MASK_IMAGE_IDX,image_mask_data,nvox_in_3d_vol,factor,fslio_tmp_input,NIFTI_TYPE_FLOAT32);
  }
  /* Calculate the standard deviaton for each voxel timeseries */
  /* Reuse the data set, as we don't need image_variance_data any more */
  image_stdev_data = image_variance_data;
  for (k = 0; k < nvox_in_3d_vol; k++)
    image_stdev_data[k] = sqrt(image_variance_data[k]);
  image_variance_data = NULL; /* Make sure we don't re-use image_variance_data */
  save_nii(SC_STDEV_IMAGE_IDX,image_stdev_data,nvox_in_3d_vol,factor,fslio_tmp_input,NIFTI_TYPE_FLOAT32);

  double * image_slope_data = NULL;
  if(opt_create_slope_nii) { // START Calculate slope for each timeseries
    double intercept, covariance_00, covariance_01, covariance_11, sum_squares;
    double * ts_x_values = (double*)fatal_malloc(number_of_timepoints * sizeof(double));
    double * ts_y_values = (double*)fatal_malloc(number_of_timepoints * sizeof(double));
    image_slope_data = (double*)fatal_malloc(nvox_in_3d_vol * sizeof(double));
    int timepoint_idx,voxel_idx;
    /* Set "x" to timeseries of 1,2,3,.... N */
    for(timepoint_idx=0; timepoint_idx < number_of_timepoints; timepoint_idx++)
      ts_x_values[timepoint_idx] = timepoint_idx + 1;
    /* Loop through each voxel */
    for(voxel_idx=0; voxel_idx < nvox_in_3d_vol; voxel_idx++) {
      for(timepoint_idx=0; timepoint_idx < number_of_timepoints; timepoint_idx++)
        ts_y_values[timepoint_idx] = input_data_as_double[voxel_idx + nvox_in_3d_vol * timepoint_idx];
      gsl_fit_linear(
                     ts_x_values
                     , 1
                     , ts_y_values
                     , 1
                     , number_of_timepoints
                     , &intercept
                     , &image_slope_data[voxel_idx]
                     , &covariance_00
                     , &covariance_01
                     , &covariance_11
                     , &sum_squares
                     );
    }
  } // END Calculate slope for each timeseries
  /* Call this no matter what. I fixes the ofile structure and only writes if it's supposed to */
  save_nii(SC_SLOPE_IMAGE_IDX,image_slope_data,nvox_in_3d_vol,factor,fslio_tmp_input,NIFTI_TYPE_FLOAT32);

  /* Reuse the data set, as we don't need image_stdev_data any more */
  image_sSNR_data = image_stdev_data;
  for (k = 0; k < nvox_in_3d_vol; k++)
    image_sSNR_data[k] = image_mean_data[k] / image_stdev_data[k];
  image_stdev_data = NULL; /* Make sure we don't re-use image_variance_data */

  save_nii(SC_SNR_IMAGE_IDX,image_sSNR_data,nvox_in_3d_vol,factor,fslio_tmp_input,NIFTI_TYPE_FLOAT32);
  save_mean_slice_text_data();
  save_report_text_file();
  save_report_xml();
  exit(0);
}
