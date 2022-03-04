/*$Header: /autofs/space/nexus_001/users/nexus-tools/cvsrepository/nifti_tools/actmapf_nifti/actmapf_nifti.c,v 1.1 2008/08/10 20:09:43 mtt24 Exp $*/
/*$Log: actmapf_nifti.c,v $
/*Revision 1.1  2008/08/10 20:09:43  mtt24
/*revision one
/*
 * Revision 1.30  2006/09/24  00:25:39  avi
 * correct control initialization
 *
 * Revision 1.29  2006/09/23  23:03:44  avi
 * Solaris 10
 *
 * Revision 1.28  2006/09/21  19:52:02  avi
 * eliminate istart and istop variables
 * call #includes now use <> convention
 *
 * Revision 1.27  2005/12/02  06:35:02  avi
 * correct usage
 *
 * Revision 1.26  2005/09/05  01:07:29  justinv
 * MAXF increased to 16384
 *
 * Revision 1.25  2005/07/22  05:09:45  avi
 * accept conc file input
 * save mmppix and center in output map
 * MAXF 1024->4096
 *
 * Revision 1.24  2005/01/21  18:28:29  avi
 * allow comments in input profiles
 *
 * Revision 1.23  2004/05/23  04:05:30  avi
 * remove -b (baseline correct) option
 * add -R (relative modulation) option
 * run ifh2hdr
 *
 * Revision 1.22  2004/05/16  01:52:33  avi
 * -w option
 *
 * Revision 1.21  2000/09/04  00:33:20  avi
 * minor fix in input filename extension stripping
 *
 * Revision 1.20  1999/03/11  09:18:09  avi
 * compute sin images with correct (negative) sine
 * newer usage and utility programs
 *
 * Revision 1.19  1999/01/04  08:21:20  avi
 * remove #include <mri/mri.h>
 *
 * Revision 1.18  1999/01/04  08:14:45  avi
 * correct core dumps on ERRR and ERRW
 *
 * Revision 1.17  1998/11/16  20:54:17  avi
 * MAXF 520 -> 1024
 *
 * Revision 1.16  1998/10/09  03:49:51  avi
 * read one frame at a time
 *
 * Revision 1.15  1998/10/08  23:51:08  avi
 * MAXF -> 520
 * new rec calls
 *
 * Revision 1.14  1998/10/08  23:11:06  avi
 * before increasing MAXF
 *
 * Revision 1.13  1997/12/05  04:49:07  avi
 * compute cos and sin weights
 *
 * Revision 1.12  1997/05/23  02:37:50  yang
 * new rec macros
 *
 * Revision 1.11  1997/04/28  21:00:55  yang
 * Working Solaris version.
 *
 * Revision 1.10  1996/07/12  07:17:31  avi
 * rec file modifications
 *
 * Revision 1.9  1996/06/22  21:24:31  avi
 * Redo switch processing
 *
 * Revision 1.8  1996/06/18  03:49:54  avi
 * compute weights variance with respect to zero unless -z switch is set
 *
 * Revision 1.7  1996/05/22  06:22:08  avi
 * -a switch and new variable trailer
 *
 * Revision 1.6  1996/05/20  07:51:30  avi
 * exit if expandf returns nonzero
 *
 * Revision 1.5  1996/05/20  07:38:52  avi
 * Revision 1.4  1996/05/20  07:35:50  avi
 * Revision 1.3  1996/05/20  07:18:36  avi
 * cscale (activation map intensity scaling factor)
 *
 * Revision 1.2  1996/05/19  06:49:18  avi
 * correct frames vs. npts check
 *
 * Revision 1.1  1996/05/19  03:09:16  avi
 * Initial revision
 **/

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <float.h>
#include <string.h>
#include <unistd.h>			/* getpid () */
/*#include <Getifh.h>
#include <endianio.h>
#include <rec.h>
#include <conc.h>*/
#include "nifti1.h"
#include "nifti1_io.h"
#include "znzlib.h"
#include "fslio.h"
#include "config.h"

#define MAXL		256
#define MAXF		16384		/* maximum npts coded in format */
#define MAX(a,b)	(a>b? a:b)
#define MIN(a,b)	(a<b? a:b)
#define MAX_REC_LEN 1024
#define MAXL        256
#define CR 13            /* Decimal code of Carriage Return char */
#define LF 10            /* Decimal code of Line Feed char */


int	expandf (char *string, int len);				/* expandf.c */
float	fimg_mode (float* fimg, int nval);				/* fimg_mode.c */

/***************************/
/*Variables used in FSL I/O*/
/***************************/   
    FSLIO *src;
    FSLIO *dest;
    short x_dim[MAXL], y_dim[MAXL], z_dim[MAXL], v_dim[MAXL], V_DIM;
    short X = 0, Y = 0, Z = 0, V = 0;
    short vv, t; 
    char filename[MAXL], text_File[MAXL], txtroot[MAXL]; 
    char *buffer[MAXL];
    unsigned int direction = 0, bpp = 0;      
    double *vol;
    float *fptr;
    char listroot[MAXL][MAXL];
    char output_file[MAXL][MAXL];
    char input_file[MAXL][MAXL];
    int lLineCount;
    int ivoxel;
    int blen, clen;
    int ifile, file;
    int nframes = 0;
/********************/
/* global variables */
/********************/
static char rcsid[] = "$Id: actmapf_nifti.c,v 1.1 2008/08/10 20:09:43 mtt24 Exp $";

/*Split function added*/
int split (char *string, char *srgv[], int maxp) {
	int	i, m;
	char	*ptr;

	if (ptr = strchr (string, '#')) *ptr = '\0';
	i = m = 0;
	while (m < maxp) {
		while (!isgraph ((int) string[i]) && string[i]) i++;
		if (!string[i]) break;
		srgv[m++] = string + i;
		while (isgraph ((int) string[i])) i++;
		if (!string[i]) break;
		string[i++] = '\0';
	}
	return m;
}

void usage (char *program) {
	fprintf (stderr, "Usage:\t%s <format> <.nii|.nii.gz|-list .txt>\n", program);
	fprintf (stderr, " e.g.,\t%s -zu \"3x3(11+4x15-)\" b1_rmsp_dbnd_xr3d_norm\n", program);
	fprintf (stderr, " e.g.,\t%s -aanatomy -c10 -u \"+\" -list ball_dbnd_xr3d.txt\n", program);
	fprintf (stderr, " e.g.,\t%s -zu \"4x124+\" b1_rmsp_dbnd_xr3d -wweights.txt\n", program);
	fprintf (stderr, "\toption\n");
	fprintf (stderr, "\t-a<str>\tspecify nifti output root trailer (default = \"actmap\")\n");
	fprintf (stderr, "\t-c<flt>\tscale output by specified factor\n");
	fprintf (stderr, "\t-u\tscale weights to unit variance\n");
	fprintf (stderr, "\t-z\tadjust weights to zero sum\n");
	fprintf (stderr, "\t-R\tcompute relative modulation (default absolute)\n");
	fprintf (stderr, "\t-w<weight file>\tread (text) weights from specified filename\n");
	fprintf (stderr, "\t-@<b|l>\toutput big or little endian (default input endian)\n");
	fprintf (stderr, "N.B.:\tlist files must have extension \"txt\"\n");
	fprintf (stderr, "N.B.:\twhen using weight files 'x' frames in format are not counted\n");
	fprintf (stderr, "N.B.:\trelative modulation images are zeroed where mean intensity < 0.5*whole_image_mode\n");
	exit (1);
}

int main (int argc, char *argv[]) {
/**********************/
/* filename variables */
/**********************/
/*	CONC_BLOCK	conc_block;			/* conc i/o control block */
	FILE		*tmpfp, *imgfp, *weifp, *fp;
	char		imgroot[MAXL], imgfile[MAXL];	/* input 4dfp stack filename */
	char		outfile[MAXL], tmpfile[MAXL], weifile[MAXL] = "";
	char		trailer[MAXL] = "actmap";	/* appended to outfile name */
	char            outroot[MAXL];
/**********************/
/* image dimensioning */
/**********************/
/*	IFH		ifh;*/
	float		*imgt;			/* one volume */
	float		*imgs;			/* weighted sum */
	float		*imga;			/* simple sum */
	int		index, imgdim[4], vdim;	/* image dimensions */
	int		isbig, osbig;
	char		control = '\0';

/*************************/
/* timeseries processing */
/*************************/
	char		*str, format[MAXF];
	float		theta, twopi;
	float		weight[MAXF];
	float		fmin, fmax, fmode;
	float 		cscale = 1.0;
	float		weight_sd, wt_mean, wt_var;
	int		npts, npos, nneg, nzer, nnez, nsin;

/***********/
/* utility */
/***********/
	char		command[MAXL], *ptr, program[MAXL], *srgv[MAXL];
	int		c, i, j, k, m, jndex;

/*********/
/* flags */
/*********/
	int             zip_Flag = 1;
	int             list_Flag = 0; /*added to indicate text file is loaded*/
	int		conc_flag = 0;
	int		unit_var = 0;
	int		zero_mean = 0;
	int		scale_rel = 0;		/* normalize weighted sum by voxelwise mean intensity */
	int		status = 0;
	int		debug = 0;

	printf ("%s\n", rcsid);
	if (!(ptr = strrchr (argv[0], '/'))) ptr = argv[0]; else ptr++;
	strcpy (program, ptr);

/************************/
/* process command line */
/************************/
	for (k = 0, i = 1; i < argc; i++) {
	
		if (!strncmp("-list",argv[i],5)){
                strcpy(text_File,argv[i+1]);
		list_Flag = 1;
		if (! strstr (text_File, ".txt")){
		printf("error: list file must end with .txt\n");
		exit(-1);}
		clen = strlen(text_File);
		if (strcmp(text_File + clen-4,".txt") == 0) { 
		strcpy(txtroot, text_File);
		txtroot[clen-4]='\0';
		}
                k++; 
                }

		if (*argv[i] == '-') {
			strcpy (command, argv[i]); ptr = command;
			while (c = *ptr++) switch (c) {
				case 'd': debug++;		break;
				case 'z': zero_mean++;		break;
				case 'u': unit_var++;		break;
				case 'R': scale_rel++;		break;
				case '@': control = *ptr++;		*ptr = '\0'; break;
				case 'c': cscale = atof (ptr);		*ptr = '\0'; break;
				case 'w': strcpy (weifile, ptr);	*ptr = '\0'; break;
				case 'a': strcpy (trailer, ptr);	*ptr = '\0'; break;
			}
		}
		else switch (k) {
			case 0:	strcpy (format,  argv[i]);	k++; break;
			case 1:	strcpy (imgroot, argv[i]);
			/*	conc_flag = (strstr (argv[i], ".conc") == argv[i] + strlen (imgroot));*/
								k++; break;
		}	
	}
	if (k < 2) usage (program);

/******************************/
/* open temp process log file */
/******************************/
	sprintf (tmpfile, "temp%d", getpid ());
	tmpfp = fopen (tmpfile, "w");

/*******************************************/
/* execute preliminary timeseries analysis */
/*******************************************/
	if (k = expandf (format, MAXF)) exit (k);
	printf ("%s\n", format);
	npts = strlen (format);
	printf ("%s: time series defined for %d frames\n", program, npts);
	npos = nneg = nzer = nsin = 0;
	twopi = 8.*atan (1.);
	for (k = 0; k < npts; k++) {
		switch (format[k]) {
			case 'x': weight[k] =  0.; nzer++; break;
			case '+': weight[k] =  1.; npos++; break;
			case '-': weight[k] = -1.; nneg++; break;
			case 'C': case 'c': case 'S': case 's': {
				str = strchr (format + k, '~');
				j = str - format - k + 1;
				for (i = 0; i < j; i++) {
					theta = twopi * (float) i / (float) j;
					switch (format[k]) {
						case 'C': case 'c': weight[k + i] =  cos (theta); break;
						case 'S': case 's': weight[k + i] = -sin (theta); break;
					}
				}
				nsin += j;
				k += j - 1;
				break;
			}
		}
	}
	printf ("%s: number positive=%d  negative=%d  sinusoidal=%d  zero=%d\n",
		program, npos, nneg, nsin, nzer);
	nnez = npts - nzer;
	fprintf (tmpfp, "Timepoint counts: positive=%d  negative=%d  sinusoidal=%d  zero=%d\n",
		npos, nneg, nsin, nzer);
	fprintf (tmpfp, "%s\n", format);

	if (strlen (weifile)) {
/************************************/
/* read externally supplied weights */
/************************************/
		printf ("Reading: %s\n", weifile);
		if (!(weifp =  fopen (weifile, "r"))) printf ("%s: error reading file %s\n", program, weifile);
		k = 0;	while (fgets (command, MAXF, weifp)) {
			if (!(m = split (command, srgv, MAXL))) continue;
			if (command[0] == '#') {
				printf ("%s", command);
			} else {
				weight[k++] = atof (srgv[0]);
			}
		}
		fclose (weifp);
		if (k < npts) {
			fprintf (stderr, "%s: %s lines (%d) less than format npts (%d)\n",
			program, weifile, k, npts);
			exit (-1);
		}
	}

/********************************************/
/* compute mean and variance of the weights */
/********************************************/
	for (k = 0; k < 2; k++) {
		wt_mean = wt_var = 0.;
		for (i = 0; i < npts; i++) if (format[i] != 'x') {
			wt_mean += weight[i];
			wt_var  += weight[i] * weight[i];
		}
		wt_mean /= (float) nnez;
		if (zero_mean) wt_var -= (float) nnez * wt_mean * wt_mean;
		wt_var /= (float) nnez; 
		weight_sd = sqrt (wt_var);

		if (zero_mean) {
			for (i = 0; i < npts; i++) if (format[i] != 'x') weight[i] -= wt_mean;
			zero_mean = 0;
		}

		if (unit_var) {
			for (i = 0; i < npts; i++) if (format[i] != 'x') weight[i] /= weight_sd;
			unit_var = 0;
		}
	}
	if (debug) {
		for (k = 0; k < npts; k++) {
			printf ("%4d %c %10.6f\n", k + 1, format[k], weight[k]);
		}
	}
	printf ("%s: weight_mean=%10.6f  weight_sd=%10.6f\n", program, wt_mean, weight_sd);
	fprintf (tmpfp, "Time series weights:  mean=%10.6f  sd=%10.6f\n", wt_mean, weight_sd);

/*****************************/
/* get nifti stack dimensions */
/*****************************/

    if (list_Flag == 1){
	fp = fopen(text_File,"rb");
	nifti_lstread(fp);
    } 
    else if (list_Flag == 0){
	    lLineCount = 1; 
	    ifile = 0;
    }
	
   for (ifile = 0; ifile < lLineCount ; ifile++){

        	if (list_Flag == 1) {
		strcpy(imgroot,input_file[ifile]);
		}
   

		blen = strlen(imgroot);
		
		if (strcmp(imgroot + blen-4,".nii") == 0) { 
		strcpy(filename, imgroot);
		filename[blen-4]='\0';
		}
		else if (strcmp(imgroot + blen-7,".nii.gz") == 0) { 
		strcpy(filename, imgroot);
		filename[blen-7]='\0';
		}

		
		else strcpy(filename,imgroot);
	
		
	
	src=FslOpen(FslMakeBaseName(filename),"r");
  	FslGetDim(src,&x_dim[ifile],&y_dim[ifile],&z_dim[ifile],&v_dim[ifile]);
      	bpp = FslGetDataType(src, &t) / 8;
	V=v_dim[ifile]; X=x_dim[ifile]; Y=y_dim[ifile]; Z=z_dim[ifile];
	
	if (list_Flag == 1){ 
	nframes += v_dim[ifile];
	}

	
		

	
		
  	
   }  /*end of for loop for list_nifti*/


/***********************************************/
/*Putting data from seperate files in outbuffer*/
/***********************************************/
	
	/*
	printf("X = %d, Y = %d, Z = %d, V = %d\n", X, Y, Z, V);*/

	if (list_Flag == 1){V = nframes;}
	imgdim[0] = X; imgdim[1] = Y; imgdim[2] = Z; imgdim[3] = V;


/*
	if (conc_flag) {
		conc_init (&conc_block, program);
		conc_open (&conc_block, imgroot);
		strcpy (imgfile, conc_block.lstfile);
		for (k = 0; k < 4; k++) imgdim[k] = conc_block.imgdim[k];
		isbig = conc_block.isbig;
	} else {
		sprintf (imgfile, "%s.4dfp.img", imgroot);
		if (Getifh (imgfile, &ifh)) errr (program, imgfile);
		for (k = 0; k < 4; k++) imgdim[k] = ifh.matrix_size[k];
		if (!(imgfp = fopen (imgfile, "rb"))) errr (program, imgfile);
		printf ("Reading: %s\n", imgfile);
		isbig = strcmp (ifh.imagedata_byte_order, "littleendian");
	}*/


	if (!control) control = (isbig) ? 'b' : 'l';
	vdim = imgdim[0] * imgdim[1] * imgdim[2];
	if (imgdim[3] < npts) {
		fprintf (stderr, "%s: more defined npts (%d) than frames (%d)\n", program, npts, imgdim[3]);
		exit (-1);
	}
	imgs =	(float *) calloc (vdim, sizeof (float));
	imga =	(float *) calloc (vdim, sizeof (float));
	imgt =	(float *) calloc (vdim, sizeof (float));
	if (!imgs || !imgt || !imga) printf ("%s cannot allocate memory\n", program);
      
	
	printf ("computing weighted sum image scaled by %.4f\n", cscale);
	fprintf (tmpfp, "Weighted sum image scaled by %.4f\n", cscale);

	for (file = 0; file < lLineCount; file++){

	
	if (list_Flag == 1) {
	src=FslOpen(FslMakeBaseName(input_file[file]),"r");
	}
	else if (list_Flag == 0){
	src=FslOpen(FslMakeBaseName(filename),"r");
	}

	buffer[file] = malloc(x_dim[file]*y_dim[file]*z_dim[file]*v_dim[file]*bpp);
  	FslReadVolumes(src, buffer[file], v_dim[file]);
	FslClose(src);	

	vol = (double *) calloc (vdim*v_dim[file], sizeof (double));
  	convertBufferToScaledDouble(vol,buffer[file],X*Y*Z*v_dim[file],1.0,0.0,src->niftiptr->datatype);
  
	
	for (i = 0; i < v_dim[file]; i++) {

		for (j = 0; j < vdim; j++){
		    imgt[j] = (float) vol[j + i*vdim];
		}
		/*
		if (conc_flag) {
			conc_read_vol (&conc_block, imgt);
		} else {
			if (eread (imgt, vdim, isbig, imgfp)) errr (program, imgfile);
		}*/
		if (format[i + file*v_dim[file]] == 'x') continue;
		for (j = 0; j < vdim; j++) {
		imga[j] += imgt[j];
		imgs[j] += imgt[j]*weight[i + file*v_dim[file]];
		}
	}
	free (vol);
	free (buffer[file]);
	}/*end of file loop*/
	/*
	if (conc_flag) {
		conc_free (&conc_block);
	} else {
		if (fclose (imgfp)) errr (program, imgfile);
	}*/

	fmode = fimg_mode (imga, vdim);
/******************************/
/* compute final output image */
/******************************/
	fmin = FLT_MAX; fmax = -fmin;
	for (j = 0; j < vdim; j++) {
		if (scale_rel) {
			if (imga[j] > 0.5*fmode) {
				imgs[j] *= cscale / imga[j];
			} else {
				imgs[j] = 0.;
			}
		} else {
			imgs[j] *= cscale / (float) nnez;
		}
		fmin = MIN (fmin, imgs[j]);
		fmax = MAX (fmax, imgs[j]);
	}

/********************/
/* assemble outroot */
/********************/
	if (list_Flag == 1) strcpy (filename, txtroot);
	if (ptr = strrchr (filename, '/')) ptr++; else ptr = filename;
	sprintf (outfile, "%s_%s.nii", ptr, trailer);
	
/*********/
/* write */
/*********/
	printf ("Writing: %s\n", outfile);
	printf ("Max = %10.3f,\tMin = %10.3f\n", fmax, fmin);
	
	   
	fptr = imgs; 
	if (list_Flag == 1) write_nifti(input_file[0], outfile, fptr, vdim, zip_Flag, 1); 
	else if (list_Flag == 0) write_nifti(imgroot, outfile, fptr, vdim, zip_Flag, 1);
	   
/*
	if (!(imgfp = fopen (outfile, "wb")) || ewrite (imgs, vdim, control, imgfp)
	|| fclose (imgfp)) errw (program, outfile);

/*******/
/* ifh */
/*******/
/*	imgdim[3] = 1;
	if (conc_flag) {
		writeifhmce (program, outfile, imgdim,
			conc_block.voxdim, conc_block.orient, conc_block.mmppix, conc_block.center, control);
	} else {
		writeifhmce (program, outfile, imgdim,
			ifh.scaling_factor, ifh.orientation, ifh.mmppix, ifh.center, control);
	}

/*******/
/* hdr */
/*******/
/*	sprintf (command, "ifh2hdr -r%dto%d %s", (int) (fmin-0.5), (int) (fmax+0.5), outfile);
	printf ("%s\n", command); status |= system (command);

/*******/
/* rec */
/*******/
/*	startrecle (outfile, argc, argv, rcsid, control);
	fclose (tmpfp); catrec (tmpfile); remove (tmpfile);
	catrec (imgfile);
	endrec ();
*/
	free (imgt); free (imgs); free (imga);
	exit (status);
}
/*********************************************************************************/
int nifti_lstread(FILE *input)/*, char input_file[MAXL][MAX_REC_LEN], int lLineCount) 			      			      
/**********************************************************************************/
{
 
  
  int   isNewline;              /* Boolean indicating we've read a CR or LF */
  long  lFileLen;               /* Length of file */
  long  lIndex;                 /* Index into cThisLine array */
  long  lLineLen;               /* Current line length */
  long  lStartPos;              /* Offset of start of current line */
  long  lTotalChars;            /* Total characters read */
  char  cThisLine[MAX_REC_LEN]; /* Contents of current line */
  char *cFile;                  /* Dynamically allocated buffer (entire file) */
  char *cThisPtr;               /* Pointer to current position in cFile */
  fseek(input, 0L, SEEK_END);  /* Position to end of file */
  lFileLen = ftell(input);     /* Get file length */
  rewind(input);               /* Back to start of file */
  
  



/*************************************/
/*Processing text file for file names*/
/*************************************/

  cFile = calloc(lFileLen + 1, sizeof(char));

  if(cFile == NULL )
  {
    printf("\nInsufficient memory to read file.\n");
    return 0;
  }

  fread(cFile, lFileLen, 1, input); /* Read the entire file into cFile */

  lLineCount  = 0;
  lTotalChars = 0L;

  cThisPtr    = cFile;              /* Point to beginning of array */

  while (*cThisPtr)                 /* Read until reaching null char */
  {
    lIndex    = 0L;                 /* Reset counters and flags */
    isNewline = 0;
    lStartPos = lTotalChars;

    while (*cThisPtr)               /* Read until reaching null char */
    {
      if (!isNewline)               /* Haven't read a CR or LF yet */
      {
        if (*cThisPtr == CR || *cThisPtr == LF) /* This char IS a CR or LF */
          isNewline = 1;                        /* Set flag */
      }

      else if (*cThisPtr != CR && *cThisPtr != LF) /* Already found CR or LF */
        break;                                     /* Done with line */

      cThisLine[lIndex++] = *cThisPtr++; /* Add char to output and increment */
      ++lTotalChars;

    } /* end while (*cThisPtr) */

    cThisLine[lIndex-1] = '\0';     /* Terminate the string one index before carriage return*/
    strcpy(input_file[lLineCount],cThisLine);
 
    ++lLineCount;  /* Increment the line counter */
    
    
    
  }
        return lLineCount;
	
}  

/*******************************/
/*function to write nifti files*/
/*******************************/
int write_nifti(char *hdr_file, char *outfile, float *fptr, int dimension, int zip_Flag, int nvols)
{
void *outbuf;
int i;

void *buffer;
src = FslInit();
FslReadAllVolumes(src, hdr_file);
FslSetDataType(src, 16); /*added to set datatype*/ 

  
  THIS_UINT8 *uint8_Data;
  THIS_INT8   *int8_Data;
  THIS_UINT16 *uint16_Data;
  THIS_INT16  *int16_Data;
  THIS_UINT64 *uint64_Data;
  THIS_INT64  *int64_Data;
  THIS_UINT32 *uint32_Data;
  THIS_INT32  *int32_Data;
  THIS_FLOAT32 *float32_Data;
  THIS_FLOAT64 *float64_Data;   
  

        switch(src->niftiptr->datatype) {
            case NIFTI_TYPE_UINT8:
                 uint8_Data = (THIS_UINT8 *) calloc (dimension,  sizeof (THIS_UINT8));
                 for (i = 0; i < dimension; i++)
                     uint8_Data[i] = (THIS_UINT8)fptr[i];
			

 			if (zip_Flag == 1){
        		dest = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(dest, src);
        		FslClose(src);
  			dest->niftiptr->nt = nvols;
 			FslSetDimensionality(dest, 4);
  			FslWriteHeader(dest);
  			FslWriteVolumes(dest,uint8_Data,nvols);
  			FslClose(dest);
			}
            break;
            case NIFTI_TYPE_INT8:
                 int8_Data = (THIS_INT8 *) calloc (dimension,  sizeof (THIS_INT8));
            	 for (i = 0; i < dimension; i++)
            	 int8_Data[i] = (THIS_INT8)fptr[i];
		
			
			
			if (zip_Flag == 1){
        		dest = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(dest, src);
        		FslClose(src);
  			dest->niftiptr->nt = nvols;
 			FslSetDimensionality(dest, 4);
  			FslWriteHeader(dest);
  			FslWriteVolumes(dest,int8_Data,nvols);
  			FslClose(dest);
			}
			
		 
	    break;
            case NIFTI_TYPE_UINT16:
                 uint16_Data = (THIS_UINT16 *)calloc (dimension,  sizeof (THIS_UINT16));
            	 for (i = 0; i < dimension; i++)
            	 uint16_Data[i] = (THIS_UINT16)fptr[i];

		 	

			if (zip_Flag == 1){
        		dest = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(dest, src);
        		FslClose(src);
  			dest->niftiptr->nt = nvols;
 			FslSetDimensionality(dest, 4);
  			FslWriteHeader(dest);
  			FslWriteVolumes(dest,uint16_Data,nvols);
  			FslClose(dest);
			}
                 
            break;
            case NIFTI_TYPE_INT16:
                 int16_Data = (THIS_INT16 *)calloc (dimension,  sizeof (THIS_INT16));
            	 for (i = 0; i < dimension; i++)
            	 int16_Data[i] = (THIS_INT16)fptr[i];

			

			if (zip_Flag == 1){
        		dest = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(dest, src);
        		FslClose(src);
  			dest->niftiptr->nt = nvols;
 			FslSetDimensionality(dest, 4);
  			FslWriteHeader(dest);
  			FslWriteVolumes(dest,int16_Data,nvols);
  			FslClose(dest);
			}
			
		 
            break;
            case NIFTI_TYPE_UINT64:
                 uint64_Data = (THIS_UINT64 *)calloc (dimension,  sizeof (THIS_UINT64));
            	 for (i = 0; i < dimension; i++)
            	 uint64_Data[i] = (THIS_UINT64)fptr[i];

			

			if (zip_Flag == 1){
        		dest = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(dest, src);
        		FslClose(src);
  			dest->niftiptr->nt = nvols;
 			FslSetDimensionality(dest, 4);
  			FslWriteHeader(dest);
  			FslWriteVolumes(dest,uint64_Data,nvols);
  			FslClose(dest);
			}
			

            break;
            case NIFTI_TYPE_INT64:
                 int64_Data = (THIS_INT64 *)calloc (dimension,  sizeof (THIS_INT64));
            	 	for (i = 0; i < dimension; i++)
            	 	int64_Data[i] = (THIS_INT64)fptr[i];

		

			if (zip_Flag == 1){
        		dest = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(dest, src);
        		FslClose(src);
  			dest->niftiptr->nt = nvols;
 			FslSetDimensionality(dest, 4);
  			FslWriteHeader(dest);
  			FslWriteVolumes(dest,int64_Data,nvols);
  			FslClose(dest);
			}			

            break;
            case NIFTI_TYPE_UINT32:
                 uint32_Data = (THIS_UINT32 *)calloc (dimension,  sizeof (THIS_UINT32));
            	 for (i = 0; i < dimension; i++)
            	 uint32_Data[i] = (THIS_UINT32)fptr[i];

			


			if (zip_Flag == 1){
        		dest = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(dest, src);
        		FslClose(src);
  			dest->niftiptr->nt = nvols;
 			FslSetDimensionality(dest, 4);
  			FslWriteHeader(dest);
  			FslWriteVolumes(dest,uint32_Data,nvols);
  			FslClose(dest);
			}	    
		 
            break;
            case NIFTI_TYPE_INT32:
                int32_Data = (THIS_INT32 *)calloc (dimension,  sizeof (THIS_INT32));
            	for (i = 0; i < dimension; i++)
            	int32_Data[i] = (THIS_INT32)fptr[i];

			


			if (zip_Flag == 1){
        		dest = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(dest, src);
        		FslClose(src);
  			dest->niftiptr->nt = nvols;
 			FslSetDimensionality(dest, 4);
  			FslWriteHeader(dest);
  			FslWriteVolumes(dest,int32_Data,nvols);
  			FslClose(dest);
			}	
	    	            
	    break;
            case NIFTI_TYPE_FLOAT32:
                float32_Data = (THIS_FLOAT32 *)calloc (dimension,  sizeof (THIS_FLOAT32));
            	for (i = 0; i < dimension; i++)
            	float32_Data[i] = (THIS_FLOAT32)fptr[i];




			if (zip_Flag == 1){
        		dest = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(dest, src);
        		FslClose(src);
  			dest->niftiptr->nt = nvols;
 			FslSetDimensionality(dest, 4);
			FslSetCalMinMax(dest, 0.0, 0.0);
  			FslWriteHeader(dest);
  			FslWriteVolumes(dest,float32_Data,nvols);
  			FslClose(dest);
			}
		
            break;
            case NIFTI_TYPE_FLOAT64:
                float64_Data = (THIS_FLOAT64 *)calloc (dimension,  sizeof (THIS_FLOAT64));
            	for (i = 0; i < dimension; i++)
            	float64_Data[i] = (THIS_FLOAT64)fptr[i];


			if (zip_Flag == 1){
        		dest = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(dest, src);
        		FslClose(src);
  			dest->niftiptr->nt = nvols;
 			FslSetDimensionality(dest, 4);
  			FslWriteHeader(dest);
  			FslWriteVolumes(dest,float64_Data,nvols);
  			FslClose(dest);
			}
		            
	    break;

            case NIFTI_TYPE_FLOAT128:
            case NIFTI_TYPE_COMPLEX128:
            case NIFTI_TYPE_COMPLEX256:
            case NIFTI_TYPE_COMPLEX64:
            default:
            fprintf(stderr, "\nWarning, cannot support %s yet.\n",nifti_datatype_string(src->niftiptr->datatype));
            return(-1);
        }

}
