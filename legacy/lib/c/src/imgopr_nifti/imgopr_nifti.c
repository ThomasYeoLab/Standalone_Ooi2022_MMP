/*$Header: /autofs/space/nexus_001/users/nexus-tools/cvsrepository/nifti_tools/imgopr_nifti/imgopr_nifti.c,v 1.1 2008/08/10 20:28:20 mtt24 Exp $*/
/*$Log: imgopr_nifti.c,v $
/*Revision 1.1  2008/08/10 20:28:20  mtt24
/*revision one
/*
 * Revision 1.8  2006/09/24  02:55:52  avi
 * Solaris 10
 *
 * Revision 1.7  2006/09/13  02:09:48  avi
 * MAXR -> 4096
 *
 * Revision 1.6  2005/09/10  05:50:00  avi
 * fix usage and several bugs
 *
 * Revision 1.5  2005/09/10  04:21:47  avi
 * count defined (options -d and -u)
 * output defined (options -N -Z -E)
 *
 * Revision 1.4  2005/01/07  22:42:16  avi
 * -x and -y options
 * remove references to IFH and ifh.h
 *
 * Revision 1.3  2004/09/21  20:32:26  rsachs
 * Installed 'setprog'.
 *
 * Revision 1.2  2004/01/04  23:50:49  avi
 * prevent overwriting input by output
 *
 * Revision 1.1  2004/01/02  05:18:16  avi
 * Initial revision
 **/

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>		/* R_OK */
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <float.h>
/*#include <ieeefp.h>
#include <endianio.h>
#include <Getifh.h>
#include <rec.h>*/
#include "nifti1.h"
#include "nifti1_io.h"
#include "znzlib.h"
#include "fslio.h"
#include "config.h"



#define MAXL		256	/* maximum string length */
#define MAXR		4096	/* maximum number of input images */
#define UCHAR		unsigned char


/***************************/
/*Variables used in FSL I/O*/
/***************************/   
    FSLIO *src;
    FSLIO *dest;
    short x_dim[MAXL], y_dim[MAXL], z_dim[MAXL], v_dim[MAXL], V_DIM;
    short X = 0, Y = 0, Z = 0, V = 0;
    short vv, t;  
    char *buffer[MAXL];
    unsigned int direction = 0, bpp = 0;      
    double *vol;
    float *fptr;
    int blen;
    char filename[MAXL];
void setprog (char *program, char **argv) {
	char *ptr;

	if (!(ptr = strrchr (argv[0], '/'))) ptr = argv[0]; 
	else ptr++;
	strcpy (program, ptr);
}

/********************/
/* global variables */
/********************/
char		program[MAXL];
static char	rcsid[] = "$Id: imgopr_nifti.c,v 1.1 2008/08/10 20:28:20 mtt24 Exp $";

void usage () {
	fprintf (stderr, "Usage:	%s -<operation><(nii) outroot> <(nii) image1> <(nii) image2> ...\n", program);
	fprintf (stderr, "	operation\n");
	fprintf (stderr, "	-a	add\n");
	fprintf (stderr, "	-s	subtract (image1 - image2)\n");
	fprintf (stderr, "	-p	product\n");
	fprintf (stderr, "	-r	ratio (image1 / image2)\n");
	fprintf (stderr, "	-e	mean (expectation)\n");
	fprintf (stderr, "	-v	variance\n");
	fprintf (stderr, "	-g	geometric mean\n");
	fprintf (stderr, "	-n	count defined (see -u option) voxels\n");
	fprintf (stderr, "	-x	voxelwize maximum\n");
	fprintf (stderr, "	-y	voxelwize minimum\n");
	fprintf (stderr, "	-G	report serial number (counting from 1) of image with greatest value\n");
	fprintf (stderr, "	option\n");
	fprintf (stderr, "	-u	count only defined (not NaN or 1.e-37 or 0.0) voxels\n");
	fprintf (stderr, "	-N\toutput undefined voxels as NaN\n");
	fprintf (stderr, "	-Z\toutput undefined voxels as 0\n");
	fprintf (stderr, "	-E\toutput undefined voxels as 1.E-37 (default)\n");
	fprintf (stderr, "	-c<flt>	multiply output by specified scaling factor\n");
	fprintf (stderr, "	-l<lst>	read input file names from specified list file\n");
	fprintf (stderr, "	-@<b|l>\toutput big or little endian (default input endian)\n");
	exit (1);
}

int main (int argc, char *argv[]) {
	FILE		*fp;
/*	IFH		ifh;*/
	char		imgroot[MAXR][MAXL], imgfile[MAXL], lstfile[MAXL] = "";
	char		outroot[MAXL] = "", outfile[MAXL];
	float		*img1, *imgo;
	double		*imgs;
	UCHAR		*imgn;		/* count defined voxels */
	UCHAR		*imgc;
	float		voxdim[3], voxdim1[3];
	float		sfactor = 1.0, amax = -FLT_MAX, amin = FLT_MAX;
	int		nrun = 0, opr = 0;			/* operation */
	int		orient, orient1, imgdim[4], imgdim1[4], dimension, isbig, isbig1;
	int		ndefined;
	char		defined;
	char		control = '\0';

/***********/
/* utility */
/***********/
	double		q, u;
	int		c, i, j, k, m;
	char		*ptr, command[MAXL];
	char		*srgv[MAXL];				/* list file string field pointers */

/*********/
/* flags */
/*********/
	int		debug = 0;
	int		count_defined = 0;
	int		NaN_flag = 'E';		/* 'E' 1.e-37; 'Z' 0.0; 'N' NaN; */
	int		status = 0;
	int             zip_Flag = 1;
	printf ("%s\n", rcsid);
	setprog (program, argv);
	for (k = 0; k < MAXR; k++) imgroot[k][0] = '\0';

/************************/
/* process command line */
/************************/
	for (i = 1; i < argc; i++) {
		if (*argv[i] == '-') {
			strcpy (command, argv[i]); ptr = command;
			while (c = *ptr++) switch (c) {
				case 'd': debug++;				break;
				case 'u': count_defined++;			break;
				case 'N': case 'Z': case 'E': NaN_flag = c;	break;
				case 'l': strcpy (lstfile, ptr);		*ptr =  '\0'; break;
				case 'n': count_defined++;
				case 'a':
				case 's':
				case 'p':
				case 'r':
				case 'e':
				case 'v':
				case 'x':
				case 'y':
				case 'G':
				case 'g': opr = c; strcpy (outroot, ptr);	*ptr =  '\0'; break;
				case 'c': sfactor = atof (ptr); 		*ptr =  '\0'; break;
				case '@': control = *ptr++;			*ptr = '\0'; break;
			}
		} else {
			strcpy (filename, argv[i]);
			blen = strlen(filename);
			
			if (strcmp(filename + blen-4,".nii") == 0) { 
			filename[blen-4]='\0';
			strcpy(imgroot[nrun++], filename);
			}
			else if (strcmp(filename + blen-7,".nii.gz") == 0) { 
			filename[blen-7]='\0';
			strcpy(imgroot[nrun++], filename);
			}
			else strcpy(imgroot[nrun++], filename);
			
		}
			
	}

/*******************/
/* parse list file */
/*******************/
	if (strlen (lstfile)) {
		if (!(fp = fopen (lstfile, "r"))) printf ("%s: cannot read %s\n", program, lstfile);
		while (fgets (command, MAXL, fp)) {
			if (nrun >= MAXR) {
				fprintf (stderr, "%s: maximum number of input images (%d) exceeded\n", program, MAXR);
				exit (-1);
			}
			if (ptr = strchr (command, '#'))  *ptr = '\0';
			if (!strlen (command)) continue;		/* skip blank lines */
			if (ptr = strchr (command, '\n')) *ptr = '\0';	/* strip terminal nl */
			i = m = 0; while (m < MAXL && i < MAXL) {
				while (!isgraph ((int) command[i]) && command[i]) i++;
				if (!command[i]) break;
				srgv[m++] = command + i;
				while (isgraph ((int) command[i])) i++;
				if (!command[i]) break;
				command[i++] = '\0';
			}
			strcpy (filename, srgv[0]);
			if (strcmp(filename + blen-4,".nii") == 0) { 
			filename[blen-4]='\0';
			strcpy(imgroot[nrun++], filename);
			}
			else if (strcmp(filename + blen-7,".nii.gz") == 0) { 
			filename[blen-7]='\0';
			strcpy(imgroot[nrun++], filename);
			}
			else strcpy(imgroot[nrun++], filename);
		}
		fclose (fp);
	}
	if (!nrun || !strlen (outroot)) usage ();

/*********************************/
/* check dimensional consistency */
/*********************************/
	for (i = 0; i < nrun; i++) {
	src=FslOpen(FslMakeBaseName(imgroot[i]),"r");
  	FslGetDim(src,&x_dim[i],&y_dim[i],&z_dim[i],&v_dim[i]);
      	bpp = FslGetDataType(src, &t) / 8;
	V=v_dim[i]; X=x_dim[i]; Y=y_dim[i]; Z=z_dim[i];
	
	 
   	buffer[i] = malloc(x_dim[i]*y_dim[i]*z_dim[i]*v_dim[i]*bpp);
  	FslReadVolumes(src, buffer[i], v_dim[i]);
	FslClose(src);
	}
	
	imgdim[0] =  x_dim[0]; 
	imgdim[1] =  y_dim[0];
	imgdim[2] =  z_dim[0];
	imgdim[3] =  v_dim[0];
	
	for (i = 0; i < nrun; i++) {
		if (!strcmp (imgroot[i], outroot)) {
			fprintf (stderr, "%s: output %s matches one or more inputs\n", program, outroot);
			exit (-1);
		}
		/*
		if (!i) {
			if (get_4dfp_dimoe (imgroot[i], imgdim,  voxdim,  &orient,  &isbig))  exit (-1);
			if (Getifh (imgroot[i], &ifh)) errr (program, imgroot[i]);
		} else {
			if (get_4dfp_dimoe (imgroot[i], imgdim1, voxdim1, &orient1, &isbig1)) exit (-1);
			status = (orient1 != orient);
			status |= (isbig1 != isbig);*/
		
			imgdim1[0] =  x_dim[i]; 
			imgdim1[1] =  y_dim[i];
			imgdim1[2] =  z_dim[i];
			imgdim1[3] =  v_dim[i];
		
			  
			for (k = 0; k < 4; k++) status |= (imgdim1[k] != imgdim[k]);
		/*	for (k = 0; k < 3; k++) status |= (fabs (voxdim1[k] - voxdim[k]) > 1.e-5);*/
			
		if (status) {
			fprintf (stderr, "%s: %s %s dimension of endian mismatch\n", program, imgroot[0], imgroot[i]);
			exit (-1);
		}
	}
	if (!control) control = (isbig) ? 'b' : 'l';
	
	dimension = imgdim[0]*imgdim[1]*imgdim[2]*imgdim[3];
	if (!(img1 = (float *)  calloc (dimension, sizeof (float))))printf ("%s: could not allocate memory\n",program);
	if (!(imgo = (float *)  calloc (dimension, sizeof (float))))printf ("%s: could not allocate memory\n",program);
	if (!(imgs = (double *) calloc (dimension, sizeof (double))))printf ("%s: could not allocate memory\n",program);
	if (!(imgc = (UCHAR *)  calloc (dimension, sizeof (UCHAR))))printf ("%s: could not allocate memory\n",program);
	if (!(imgn = (UCHAR *)  calloc (dimension, sizeof (UCHAR))))printf ("%s: could not allocate memory\n",program);

/******************/
/* prepare arrays */
/******************/
	for (j = 0; j < dimension; j++) {
		switch (opr) {
			case 'p':			/* product */
			case 'g':			/* geometric mean */
				imgo[j] = 1.0;
				break;
			case 'G':			/* Tony Jack operation */
			case 'x':			/* voxelwize maximum */
				imgo[j] = -FLT_MAX;
				break;
			case 'y':			/* voxelwize minimum */
				imgo[j] =  FLT_MAX;
				break;
			default:
				break;
		}
	}

/******************/
/* start rec file */
/******************/
/*	sprintf (outfile, "%s.4dfp.img", outroot);
	startrecle (outfile, argc, argv, rcsid, control);
	if (strlen (lstfile)) {
		printrec ("imglist\n"); catrec (lstfile); printrec ("endimglist\n");
	}

/*******************/
/* execute algebra */
/*******************/
	for (i = 0; i < nrun; i++) {
		sprintf (imgfile, "%s.nii", imgroot[i]);
		printf ("Reading: %s\n", imgfile);
		
	vol = (double *) calloc (x_dim[i]*y_dim[i]*z_dim[i]*v_dim[i], sizeof (double));
  	convertBufferToScaledDouble(vol,buffer[i],x_dim[i]*y_dim[i]*z_dim[i]*v_dim[i],1.0,0.0,src->niftiptr->datatype);

		for (j = 0; j < dimension; j++){
		img1[j] = (float) vol[j];
		}
		/*
		if (!(fp = fopen (imgfile, "rb")) || eread (img1, dimension, isbig, fp)
		|| fclose (fp)) errr (program, imgfile);
		catrec (imgfile);
		*/
		for (j = 0; j < dimension; j++) {
		if (count_defined && (img1[j] == 0.0 || img1[j] == 1.e37 || isnan (img1[j]))) continue;
			imgn[j]++;
			switch (opr) {
				case 'a':
				case 'e':
					imgo[j] += img1[j];				break;
				case 's':
					switch (i) {
						case 0: imgo[j]  = img1[j]; break;
						case 1: imgo[j] -= img1[j]; break;
					}						break;
				case 'p':
				case 'g':
					imgo[j] *= img1[j];				break;
				case 'n':
					imgo[j] =  imgn[j];				break;
				case 'r':
					switch (i) {
						case 0: imgo[j]  = img1[j]; break;
						case 1: imgo[j] /= img1[j]; break;
					}						break;
				case 'v':
					imgo[j] += img1[j];
					imgs[j]	+= img1[j]*img1[j];
											break;
				case 'x':
					if (img1[j] > imgo[j]) imgo[j] = img1[j];	break;
				case 'y':
					if (img1[j] < imgo[j]) imgo[j] = img1[j];	break;
				case 'G':
					if (img1[j] > imgo[j]) {
						imgo[j] = img1[j];
						imgc[j] = i + 1;
					}						break;
				default:						break;
			}
		}
	}

	for (ndefined = j = 0; j < dimension; j++) {
		q  = 1.0 / imgn[j];
		switch (opr) {
			case 'e':
				imgo[j] *= q;
				break;
			case 'g':
				imgo[j] = pow (imgo[j], q);
				break;
			case 'v':
				u = imgo[j] * q;
				imgo[j]	= (imgs[j] - u*u/q) / (imgn[j] - 1);
				if (imgn[j] > 1 && imgo[j] < 0.0) imgo[j] = 0.0;
				break;
			case 'G':
				imgo[j] = imgc[j];
				break;
			default:
				break;
		}
		if (!isnan (imgo[j]) && finite (imgo[j])) {
			imgo[j] *= sfactor;
			if (imgo[j] > amax) amax = imgo[j];
			if (imgo[j] < amin) amin = imgo[j];
			ndefined++;				
		} else switch (NaN_flag) {
			case 'Z': imgo[j] = 0.0;		break;
			case 'E': imgo[j] = (float) 1.e-37;	break;
			case 'N': default:			break;
		}
	}

/****************/
/* write result */
/****************/
	fptr = imgo;
	sprintf (outfile, "%s.nii", outroot);
	printf ("Writing: %s\n", outfile);
	write_nifti(imgroot, outroot, fptr, dimension, zip_Flag, V);
/*
	if (!(fp = fopen (outfile, "wb"))
	|| ewrite (imgo, dimension, control, fp)
	|| fclose (fp)) errw (program, outfile);

/*******/
/* ifh */
/*******/
/*	Writeifh (program, outfile, &ifh, control);

/*******/
/* hdr */
/*******/
/*	sprintf (command, "ifh2hdr %s -r%.0fto%.0f", outroot, amin, amax);
	printf ("%s\n", command);
	status |= system (command);

/*******/
/* rec */
/*******/
/*	sprintf (command, "defined output voxel count = %d out of %d total\n", ndefined, dimension);
	printrec (command);
	endrec ();*/
	free (img1); free (imgo); free (imgs); free (imgc); free (imgn); free (vol); 
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
