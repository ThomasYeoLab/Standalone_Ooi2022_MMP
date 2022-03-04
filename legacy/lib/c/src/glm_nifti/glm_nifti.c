/*$Header: /autofs/space/nexus_001/users/nexus-tools/cvsrepository/nifti_tools/glm_nifti/glm_nifti.c,v 1.1 2008/08/10 20:26:49 mtt24 Exp $*/
/*$Log: glm_nifti.c,v $
/*Revision 1.1  2008/08/10 20:26:49  mtt24
/*revision one
/*
 * Revision 1.10  2006/09/24  01:09:44  avi
 * Solaris 10
 *
 * Revision 1.9  2006/05/04  05:24:52  avi
 * option -Z inhibit removing constant from regressors
 *
 * Revision 1.8  2005/09/05  05:26:12  avi
 * increase profile input line buffer to 4096 chars
 * write frame number to stdout during processing
 *
 * Revision 1.7  2005/09/05  00:54:10  avi
 * double precision GLM inversion
 *
 * Revision 1.6  2005/05/24  06:39:46  avi
 * -C option (read previously computed coefficients from 4dfp image)
 *
 * Revision 1.5  2005/01/12  07:31:15  avi
 * MAXF 4096 -> 16384
 *
 * Revision 1.4  2004/11/27  05:45:35  avi
 * replace conc_io.c subroutines with conc.c subroutines
 * eliminate dependence on libmri (get4dfpdimN())
 *
 * Revision 1.3  2004/09/07  19:43:54  avi
 * optionally read conc files
 *
 * Revision 1.2  2004/06/10  00:15:22  avi
 * MAXF 1024 -> 4096
 *
 * Revision 1.1  2004/05/26  05:30:46  avi
 * Initial revision
 **/

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <float.h>
#include <string.h>
#include <unistd.h>			/* getpid () */
#include <string.h>
#include "nifti1.h"
#include "nifti1_io.h"
#include "znzlib.h"
#include "fslio.h"
#include "config.h"
#define MAXL            256
#define MAXS		4096		/* maximum profile input string length */	
#define MAXF		16384
#define RTRAIL		"resid"
#define CTRAIL		"coeff"
#define MAX(a,b)	(a>b? a:b)
#define MIN(a,b)	(a<b? a:b)
#define MAX_REC_LEN 1024
#define MAXL        256
#define CR 13            /* Decimal code of Carriage Return char */
#define LF 10            /* Decimal code of Line Feed char */

int	expandf (char *string, int len);							/* expandf.c */
float	fimg_mode (float* fimg, int nval);							/* fimg_mode.c */
void	df2finvt_ (float *f, int *npts, int *ncol, float *a, float *finvt, int *nnez);	/* dglm_4dfp.f */
/*void	f_init (void), f_exit(void);*/
int write_nifti(char *hdr_file, char *outfile, float *fptr, int dimension, int zip_Flag, int nvols);
int nifti_lstread(FILE *input); /* char output_file[MAXL][MAX_REC_LEN], int lLineCount);*/
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
/***************************/
/*Variables used in FSL I/O*/
/***************************/
    
    FSLIO *src, *coesrc;
    FSLIO *dest;
    short x_dim[MAXL], y_dim[MAXL], z_dim[MAXL], v_dim[MAXL], V_DIM;
    short X = 0, Y = 0, Z = 0, V = 0;
    short vv, t; 
    char filename[MAXS]; 
    char *buffer[MAXL],*coeffbuffer;
    unsigned int direction = 0, bpp = 0, coebpp = 0;      
    double *vol, *coeffvol;
    char listroot[MAXL][MAXL];
    char output_file[MAXL][MAXL];
    char input_file[MAXL][MAXL];
    int lLineCount;
    int ivoxel;
    int blen;
    int ifile, file, nframes;
/***************/
/*FSL datatypes*/
/***************/

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
/********************/
/* global variables */
/********************/
static char	rcsid[] = "$Id: glm_nifti.c,v 1.1 2008/08/10 20:26:49 mtt24 Exp $";
static char	program[MAXL];
static int	debug = 0;

float dzeromean (float *f, int npts, char *format) {
	int		i, n;
	float		u;

	for (u = n = i = 0; i < npts; i++) if (format[i] != 'x') {n++; u += f[i];}
	u /= n;
	for (i = 0; i < npts; i++) f[i] -= u;
	if (debug) for (i = 0; i < npts; i++) {
		printf ("%4d %c %10.6f\n", i + 1, format[i], f[i]);
	}
	return u;
}

float dunitvar (float *f, int npts, char *format) {
	int		i, n;
	float		v;

	for (v = n = i = 0; i < npts; i++) if (format[i] != 'x') {n++; v += f[i]*f[i];};
	v /= n;
	for (i = 0; i < npts; i++) {
		if (format[i] == 'x') {
			f[i] = 0.0;
		} else {
			f[i] /= sqrt (v);
		}
	}
	if (debug) for (i = 0; i < npts; i++) {
		printf ("%4d %c %10.6f\n", i + 1, format[i], f[i]);
	}
	return v;
}

void usage (char *program) {
	fprintf (stderr, "Usage:\t%s <format> <profile> <.nii/.nii.gz/.txt>\n", program);
	fprintf (stderr, "e.g.,\t%s \"4x124+\" doubletask.dat b1_rmsp_dbnd_xr3d_norm\n", program);
	fprintf (stderr, "\toption\n");
	fprintf (stderr,"\t-list use this option when using a text file containing a\n"); 
	fprintf (stderr,"\tlist of file names\n");
	fprintf (stderr, "\t-Z supress automatic removal of mean from input regressors\n");
	fprintf (stderr, "\t-c<flt>\tscale coefficient output images by specified factor\n");
	fprintf (stderr, "\t-o[str]\tsave regression coefficent images with specified\n"); 		fprintf (stderr, "\ttrailer (default = \"%s\")\n",CTRAIL);
	fprintf (stderr, "\t-C<.nii/.nii.gz> read coefficients from specified file\n");  		fprintf (stderr, "\t(default compute using <profile> and <input>)\n");
	fprintf (stderr, "\t-R scale output regression coefficients by mean\n");
	fprintf (stderr, "\t-r[str]\tsave residual time series with specified trailer\n"); 		fprintf (stderr, "\t(default = \"%s\")\n", RTRAIL);
	fprintf (stderr, "\t-@<b|l>\toutput big or little endian (default input endian)\n");
	fprintf (stderr, "N.B.:\t file list must have extension \"txt\"\n");
	fprintf (stderr, "N.B.:\t<profile> lists temporal profiles (ASCII npts x ncol\n");fprintf (stderr, "\t'#' introduces comments)\n");
	fprintf (stderr, "N.B.:\tprofile values past format end are ignored\n");
	fprintf (stderr, "N.B.:\tmaximum format length presently is %d frames\n", MAXF);
	exit (1);
}

int main (int argc, char *argv[]) {
/**********************/
/* filename variables */
/**********************/
	FILE		*tmpfp, *imgfp, *coefp, *outfp, *profp;
	char		coeroot[MAXL], coefile[MAXL];	/* coefficients image */
	char		imgroot[MAXL], imgfile[MAXL];	/* input 4dfp stack filename */
	char		outroot[MAXL], outfile[MAXL], tmpfile[MAXL], profile[MAXL];
	char		ctrail[MAXL] = CTRAIL;
	char		rtrail[MAXL] = RTRAIL;
	FILE		*fp;
        char            text_File[MAXL];
/**********************/
/* image dimensioning */
/**********************/
/*	CONC_BLOCK	conc_block;		/* conc i/o control block */
/*	IFH		ifhimg, ifhcoe;*/
	float		*imgt;			/* one volume */
	float		*imgs;			/* weighted sum */
	float		*imga;			/* simple sum */
	float           *splitimgt;             /*data containing split 4D volume*/
	
	float		voxdim[3], mmppix[3], center[3];
	int		jndex, imgdim[4], vdim;	/* image dimensions */
	int		isbig, isbigr;
	char		control = '\0';
	int             coematrix[4]; /*regression coefficient matrix dimension*/
	float 		*fptr; 
	float		*coefptr;
/*************************/
/* timeseries processing */
/*************************/
	char		format[MAXF];
	float		fmin, fmax, fmode;
	float 		cscale = 1.0;
	float		*f, *a, *finvt;
	int		ppts, npts, nnez, ncol;
	int 		Xcoeff, Ycoeff, Zcoeff, Vcoeff;
/***********/
/* utility */
/***********/
	char		command[MAXL], string[MAXS], *ptr, *srgv[MAXL];
	int		c, i, j, k, m;
	double		q;
	int             countfr = 0;
/*********/
/* flags */
/*********/
	int		conc_flag = 0;
	int		zeromean_flag = 1;
	int		read_coeff = 0;
	int		save_coeff = 0;
	int		save_resid = 0;
	int		scale_rel = 0;
	int		status = 0;
	int             zip_Flag = 1;
	int             list_Flag = 0;

	printf ("%s\n", rcsid);
	if (!(ptr = strrchr (argv[0], '/'))) ptr = argv[0]; else ptr++;
	strcpy (program, ptr);
	/*f_init ();*/	/* FORTRAN i/o */

/************************/
/* process command line */
/************************/
	for (k = 0, i = 1; i < argc; i++) {
		if (!strncmp("-list",argv[i],5)){
                strcpy(text_File,argv[i+1]);
                list_Flag = 1; k++; 
                }
		if (*argv[i] == '-') {
			strcpy (command, argv[i]); ptr = command;
			while (c = *ptr++) switch (c) {
				case 'd': debug++;			break;
				case 'Z': zeromean_flag = 0;		break;
				case 'R': scale_rel++;			break;
				case '@': control = *ptr++;		*ptr = '\0'; break;
				case 'C': read_coeff++; strcpy (coeroot, ptr);	*ptr = '\0'; break;
				case 'o': save_coeff++;
					if (strlen (ptr)) strcpy (ctrail, ptr);	*ptr = '\0'; break;
				case 'r': save_resid++;
					if (strlen (ptr)) strcpy (rtrail, ptr);	*ptr = '\0'; break;
				case 'c': cscale = atof (ptr);			*ptr = '\0'; break;
			}
		}
		else switch (k) {
			case 0:	strcpy (format, argv[i]);	k++; break;
			case 1:	strcpy (profile, argv[i]);	k++; break;
			case 2:	if (list_Flag == 0)
				strcpy (imgroot, argv[i]);
				/*conc_flag = (strstr (argv[i], ".conc") == argv[i] + strlen (imgroot));*/
								k++; break;
		}	
	}
	if (k < 3) usage (program);

/****************/
/* parse format */
/****************/
	if (k = expandf (format, MAXF)) exit (k);
	printf ("%s\n", format);
	npts = strlen (format);
	for (nnez = k = 0; k < npts; k++) if (format[k] != 'x') nnez++;
	printf ("%s: time series defined for %d frames, %d exluded\n", program, npts, npts - nnez);
	
/****************/
/* read profile */
/****************/
	printf ("Reading: %s\n", profile);
	if (!(profp = fopen (profile, "r"))) printf ("%s:could not read %s\n",program, profile);
	ppts = 0; while (fgets (string, MAXS, profp)) {
		if (!(m = split (string, srgv, MAXL))) continue;
		if (!ppts) {
			ncol = m;
			printf ("ncol=%d\n", ncol);
		} else {
			if (m != ncol) {
				fprintf (stderr, "%s: %s format error\n", program, profile);
				exit (-1);
			}
		}
		ppts++;
	}
	if (ppts < npts) {
		fprintf (stderr, "%s: %s length shorter than format\n", program, profile);
		exit (-1);
	}
	rewind (profp);
	if (!(f = (float *) malloc (npts * ncol * sizeof (float)))) 
	printf("%s could not allocate memory\n", program);
	if (!(finvt = (float *) malloc (npts * ncol * sizeof (float)))) 
	printf("%s could not allocate memory\n", program);
	if (!(a = (float *) malloc (ncol * ncol * sizeof (float))))
	printf("%s could not allocate memory\n", program);
	for (i = 0; i < npts; i++ ) {
		fgets (string, MAXS, profp);
		if (!(m = split (string, srgv, MAXL))) continue;
		for (j = 0; j < ncol; j++) (f + j*npts)[i] = atof (srgv[j]);
	}
	fclose (profp);
	for (j = 0; j < ncol; j++) {
		if (zeromean_flag) dzeromean (f + j*npts, npts, format);
		dunitvar (f + j*npts, npts, format);
	}

/**************************/
/* assemble design matrix */
/**************************/
	for (i = 0; i < ncol; i++) {
		for (j = i; j < ncol; j++) {
			for (q = k = 0; k < npts; k++) if (format[k] != 'x') q += (f + i*npts)[k] * (f + j*npts)[k];
			a[i + j*ncol] = a[j + i*ncol] = q/nnez;
			if (debug) printf ("a[%d,%d]=%10.6f\n", i, j, a[i + j*ncol]);
		}
	}
	df2finvt_ (f, &npts, &ncol, a, finvt, &nnez);

/*****************************/
/* get nifti stack dimensions */
/*****************************/
/*	if (conc_flag) {
		conc_init (&conc_block, program);
		conc_open (&conc_block, imgroot);
		strcpy (imgfile, conc_block.lstfile);
		for (k = 0; k < 4; k++) imgdim[k] = conc_block.imgdim[k];
		isbig = conc_block.isbig;
	} else*/ 
		
		/*
		sprintf (imgfile, "%s.4dfp.img", imgroot);
		if (Getifh (imgfile, &ifhimg)) errr (program, imgfile);
		for (k = 0; k < 4; k++) imgdim[k] = ifhimg.matrix_size[k];
		isbig = strcmp (ifhimg.imagedata_byte_order, "littleendian");
		if (!(imgfp = fopen (imgfile, "rb"))) errr (program, imgfile);
		printf ("Reading: %s\n", imgfile);
		*/
    if (list_Flag == 1){
	printf("List_Flag = %d\n", list_Flag);
	printf("text_File = %s\n", text_File);
	fp = fopen(text_File,"rb");
	nifti_lstread(fp);
    } 
    else if (list_Flag == 0){
	    lLineCount = 1; 
	    ifile = 0;
    }
	
   for (ifile = 0; ifile < lLineCount ; ifile++){

        	if (list_Flag == 1) {
		sprintf(imgroot,"%s",input_file[ifile]);
	        printf("Reading file: %s \n", imgroot);
		}
   
		if (list_Flag == 0){ 
		printf("Reading file: %s \n", imgroot);
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
		
		if (list_Flag == 1)
		strcpy(output_file[ifile], filename);
		
	/*printf("Reading file: %s.nii \n", filename);*/

	src=FslOpen(FslMakeBaseName(filename),"r");
    
  	FslGetDim(src,&x_dim[ifile],&y_dim[ifile],&z_dim[ifile],&v_dim[ifile]);
	
      	bpp = FslGetDataType(src, &t) / 8;
      	V=v_dim[ifile]; X=x_dim[ifile]; Y=y_dim[ifile]; Z=z_dim[ifile];
     	
	if (list_Flag == 1){ 
	nframes += v_dim[ifile];
	}

	/*
   	buffer[ifile] = malloc(x_dim[ifile]*y_dim[ifile]*z_dim[ifile]*v_dim[ifile]*bpp);
  	FslReadVolumes(src, buffer[ifile], v_dim[ifile]);
	*/

	FslClose(src);
	

	
  	
   }  /*end of for loop for list_nifti*/

/***********************************************/
/*Putting data from seperate files in outbuffer*/
/***********************************************/
	if (list_Flag == 1){
	V = nframes;}

	

	printf("X = %d, Y = %d, Z = %d, V = %d\n", X, Y, Z, V);
/*	if (!control) control = (isbig) ? 'b' : 'l'; */
	imgdim[0] = X; imgdim[1] = Y; imgdim[2] = Z; imgdim[3] = V;	
	vdim = imgdim[0] * imgdim[1] * imgdim[2];
	if (imgdim[3] < npts) {
		fprintf (stderr, "%s: more defined npts (%d) than frames (%d)\n", program, npts, imgdim[3]);
		exit (-1);
	}
	imgs =	(float *) calloc (vdim*ncol, sizeof (float));	/* regression coefficient images */
	imga =	(float *) calloc (vdim, sizeof (float));	/* sum of counted frames */
	imgt =	(float *) calloc (vdim, sizeof (float));	/* frame buffer V added for nifti files */
	
	/*if (!imgs || !imgt || !imga) errm (program);*/
	if (!imgs || !imgt || !imga) printf ("%s cannot allocate memory\n", program);
	
	/*
	for (ivoxel = 0; ivoxel < X*Y*Z*V; ivoxel++){
            imgt[ivoxel] =  (float) vol[ivoxel];
 	}*/

	
/**************************************/
/* read regression coefficient images */
/**************************************/
	if (read_coeff) {
		blen = strlen(coeroot);
		
		if (strcmp(coeroot + blen-4,".nii") == 0) { 
		strcpy(coefile, coeroot);
		coefile[blen-4]='\0';
		}
		else if (strcmp(coeroot + blen-7,".nii.gz") == 0) { 
		strcpy(coefile, coeroot);
		coefile[blen-7]='\0';
		}

		else strcpy(coefile, coeroot);
		
		
	        printf("Reading file: %s.nii \n", coefile);
		
        	coesrc=FslOpen(FslMakeBaseName(coefile),"r");
      		coebpp = FslGetDataType(coesrc, &t) / 8;
	
	Vcoeff = coesrc->niftiptr->nt; 
	Xcoeff = coesrc->niftiptr->nx; 
	Ycoeff = coesrc->niftiptr->ny;
	Zcoeff = coesrc->niftiptr->nz;
  	printf("Coefficient matrix dimensions: X = %d, Y = %d, Z = %d, V = %d\n", Xcoeff, Ycoeff, Zcoeff, Vcoeff);
      		
  	coeffbuffer = (char *)calloc(Xcoeff*Ycoeff*Zcoeff*Vcoeff*coebpp, sizeof (char));
  	FslReadVolumes(coesrc, coeffbuffer, Vcoeff);

		/*if (Getifh (coefile, &ifhcoe)) errr (program, coefile);*/
		
		
		coematrix[0] =  Xcoeff;
		coematrix[1] =  Ycoeff;
		coematrix[2] =  Zcoeff; 
		coematrix[3] =  Vcoeff;
		
		
		 
		for (k = 0; k < 3; k++) status |= (imgdim[k] != coematrix[k]);
		if (status) {
			fprintf (stderr, "%s: %s %s dimension mismatch\n", program, imgroot, coeroot);
			exit (-1);
		}
		
		if (coematrix[k] != ncol) {
			fprintf (stderr, "%s: %s %s column count mismatch\n", program, coeroot, profile);
			exit (-1);
		}
		
		/*
		isbigr = strcmp (ifhcoe.imagedata_byte_order, "littleendian");*/
		
		coeffvol = (double *) calloc (Xcoeff*Ycoeff*Zcoeff*ncol, sizeof (double));
 		convertBufferToScaledDouble(coeffvol,coeffbuffer,Xcoeff*Ycoeff*Zcoeff*ncol,1.0,0.0,coesrc->niftiptr->datatype);
		
                for (i = 0; i < Xcoeff*Ycoeff*Zcoeff*ncol; i++) imgs[i] = (float) coeffvol[i];
		
		/*
		if (!(coefp = fopen (coefile, "rb")) || eread (imgs, vdim*ncol, isbigr, coefp)
		|| fclose (coefp)) errr (program, coefile);*/
	} 
/*****************************************/
/* compute regression coefficient images */
/*****************************************/
	else {
		printf ("computing coefficients frame"); fflush (stdout);
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
			printf (" %d", i + 1 + file*v_dim[file]); fflush (stdout);

		
			for (jndex = 0; jndex < vdim; jndex++){
			imgt[jndex] = (float) vol[jndex + i*vdim];
			}
			/*if (conc_flag) {
				conc_read_vol (&conc_block, imgt);
			} else {
				if (eread (imgt, vdim, isbig, imgfp)) errr (program, imgfile);
			} */
			if (format[i + file*v_dim[file]] == 'x') continue; 
			for (jndex = 0; jndex < vdim; jndex++) {
				imga[jndex] += imgt[jndex]; /*index modified for nifti imgt ptr*/
				for (j = 0; j < ncol; j++) (imgs + j*vdim)[jndex] += imgt[jndex]*(finvt + j*npts)[i + file*v_dim[file]];
			}
		}
	        free (vol);
		free (buffer[file]);
	    }/*end of file loop*/ 	
		printf ("\n");  fflush (stdout);
		for (j = 0; j < ncol; j++) for (jndex = 0; jndex < vdim; jndex++) (imgs + j*vdim)[jndex] /= nnez;
	}
		
/********************************/
/* create temp process log file */
/*******************************/
	sprintf (tmpfile, "temp%d", getpid ());
	if (!(tmpfp = fopen (tmpfile, "w"))) printf ("%s:could not write %s\n",program,tmpfile);
	fprintf (tmpfp, "Timepoint counts: counted=%d  skipped=%d\n", nnez, npts - nnez);
	fprintf (tmpfp, "%s\n", format);
	if (read_coeff) fprintf (tmpfp, "Regression coefficients read from %s\n", coeroot);
	fclose (tmpfp);

	
/*****************************/
/* remove profile components */
/*****************************/
	if (save_resid) {
		
		/*
		if (conc_flag) {
			conc_newe (&conc_block, rtrail, control);
			strcpy (outfile, conc_block.outfile);
		} else {*/
		
	       /*	if (!(outfp =  fopen (outfile, "wb"))) errw (program, outfile);
			rewind (imgfp);
		}*/
		
		printf ("computing residual frame"); fflush (stdout);
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
		splitimgt = (float *) calloc (vdim*v_dim[file], sizeof (float));
		for (i = 0; i < v_dim[file]; i++) {
			printf (" %d", i + 1 + file*v_dim[file]); fflush (stdout);
			/*if (conc_flag) {
				conc_read_vol (&conc_block, imgt);
			} else {
				if (eread (imgt, vdim, isbig, imgfp)) errr (program, imgfile);
			}*/
			
			if (format[i + file*v_dim[file]] != 'x') for (jndex = 0; jndex < vdim; jndex++) {
			for (q = j = 0; j < ncol; j++) q += (imgs + j*vdim)[jndex]*(f + j*npts)[i + file*v_dim[file]];
			vol[jndex + i*vdim] -= q;     /*jndex modified for nifti imgt ptr*/		
			}
			/*if (conc_flag) {
				conc_write_vol (&conc_block, imgt);
			} else {
				if (ewrite (imgt, vdim, control, outfp)) errw (program, outfile);
			}*/
		} 
	  
		printf ("\n"); fflush (stdout);
		
		    for (k = i = 0; i < v_dim[file]; i++) {
		/*	if (format[i] == 'x') continue; k++;*/ 
			for (jndex = 0; jndex < vdim; jndex++){
			    splitimgt[jndex + i*vdim] = (float) vol[jndex + i*vdim];
		        }
                    }   
                        fptr = splitimgt;
		
		if (list_Flag == 1) {
		sprintf (listroot[file], "%s_%s", output_file[file], rtrail);
		printf ("\nWriting: %s.nii.gz\n", listroot[file]);
		V_DIM = v_dim[file];	
		write_nifti(input_file[file], listroot[file], fptr, vdim*v_dim[file], zip_Flag, v_dim[file]);
				   
	   	}/*end of if (list_Flag == 1)*/

		else if (list_Flag == 0){ 
		sprintf (outroot, "%s_%s", filename, rtrail);
		strcpy (outfile, outroot);
		printf ("\nWriting: %s.nii.gz\n", outfile);
		write_nifti(imgroot, outfile, fptr, vdim*V, zip_Flag, V);
		printf ("\n");  fflush (stdout);
	   	}
		free (buffer[file]);
		free (splitimgt);
		free (vol);

	   }/*end of file loop*/
	   
	   
	}
	/*	
		if (conc_flag) {
			status |= conc_ifh_hdr_rec (&conc_block, argc, argv, rcsid);
		} else {
			if (fclose (outfp)) errw (program, outfile);
			sprintf (command, "/bin/cp %s.4dfp.ifh %s.4dfp.ifh", imgroot, outroot);
			printf ("%s\n", command); status |= system (command);
			sprintf (command, "ifh2hdr -r4000 %s", outroot); system (command);
			printf ("%s\n", command); status |= system (command);
		}
		startrecle (outfile, argc, argv, rcsid, control);
		catrec (tmpfile);
		catrec (imgfile);
		endrec ();
	}
	if (conc_flag) {
		conc_free (&conc_block);
	} else {
		if (fclose (imgfp)) errr (program, imgfile);
	}
	*/
	if (save_coeff) {
		sprintf (outroot, "%s_%s", filename, ctrail);
		strcpy (outfile, outroot);
		fmode = fimg_mode (imga, vdim);
		fmin = FLT_MAX; fmax = -fmin;
		for (j = 0; j < ncol; j++) {
			for (jndex = 0; jndex < vdim; jndex++) {
				if (scale_rel) {
					if (imga[j] > (0.5*fmode)) {
						(imgs + j*vdim)[jndex] *= (cscale * nnez) / imga[jndex];
					} else {
						(imgs + j*vdim)[jndex] = 0.0;
					}
				} else {
					(imgs + j*vdim)[jndex] *= cscale;
				}
				fmin = MIN (fmin, (imgs + j*vdim)[jndex]);
				fmax = MAX (fmax, (imgs + j*vdim)[jndex]);
			}
		}
	
		
		printf ("Max = %10.3f,\tMin = %10.3f\n", fmax, fmin);
		coefptr = imgs;
		if (list_Flag == 1) {
		
		blen = strlen(text_File);
		
		if (strcmp(text_File + blen-4,".txt") == 0) { 
		strcpy(coefile, text_File);
		coefile[blen-4]='\0';	
		}
		sprintf (coeroot, "%s_%s", coefile, ctrail);
		strcpy(outfile,coeroot);
		printf ("Writing: %s.nii.gz\n", outfile);
		write_nifti(imgroot, outfile, coefptr, vdim*ncol, zip_Flag, ncol);
		}


		else if (list_Flag == 0){
		sprintf (outroot, "%s_%s", filename, ctrail);
		strcpy(outfile,outroot);
		printf ("Writing: %s.nii.gz\n", outfile);
		write_nifti(imgroot, outfile, coefptr, vdim*ncol, zip_Flag, ncol);
		}
/*		
		if (!(outfp = fopen (outfile, "wb")) || ewrite (imgs, vdim*ncol, control, outfp)
		|| fclose (outfp)) errw (program, outfile);
		imgdim[3] = ncol;
		if (conc_flag) {
			writeifhmce (program, outfile, imgdim,
				conc_block.voxdim, conc_block.orient, conc_block.mmppix, conc_block.center, control);
		} else {
			writeifhmce (program, outfile, imgdim,
				ifhimg.scaling_factor, ifhimg.orientation, ifhimg.mmppix, ifhimg.center, control);
		}
		sprintf (command, "ifh2hdr -r%dto%d %s", (int) (fmin-0.5), (int) (fmax+0.5), outfile);
		printf ("%s\n", command); status |= system (command);
		startrecle (outfile, argc, argv, rcsid, control);
		sprintf (command, "Regression coefficients scaled by %.4f\n", cscale); printrec (command);
		catrec (tmpfile);
		catrec (imgfile);
		endrec ();*/
	}

 	remove (tmpfile);
	/*f_exit ();	*//* FORTRAN i/o */
	free (f); free (a); free (finvt); free (coeffbuffer); free (coeffvol);
	free (imgt); free (imgs); free (imga);
	
	exit (status);
  

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
			FslSetCalMinMax(dest, 0.0, 0.0);
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
			FslSetCalMinMax(dest, 0.0, 0.0);
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
			FslSetCalMinMax(dest, 0.0, 0.0);
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
			FslSetCalMinMax(dest, 0.0, 0.0);
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
			FslSetCalMinMax(dest, 0.0, 0.0);
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
			FslSetCalMinMax(dest, 0.0, 0.0);
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
			FslSetCalMinMax(dest, 0.0, 0.0);
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
			FslSetCalMinMax(dest, 0.0, 0.0);
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
			FslSetCalMinMax(dest, 0.0, 0.0);
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
