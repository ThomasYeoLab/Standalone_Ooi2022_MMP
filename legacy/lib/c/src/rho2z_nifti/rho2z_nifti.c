/*$Header: /autofs/space/nexus_001/users/nexus-tools/cvsrepository/nifti_tools/rho2z_nifti/rho2z_nifti.c,v 1.1 2008/08/10 20:30:37 mtt24 Exp $*/
/*$Log: rho2z_nifti.c,v $
/*Revision 1.1  2008/08/10 20:30:37  mtt24
/*revision one
/*
 * Revision 1.4  2006/09/24  23:37:24  avi
 * Solaris 10
 *
 * Revision 1.3  2006/08/07  02:31:51  avi
 * make 1.e-37 test safe
 *
 * Revision 1.2  2005/07/08  02:15:42  avi
 * -r (reverse operation) option
 *
 * Revision 1.1  2005/01/23  00:41:50  avi
 * Initial revision
 **/

#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#include <math.h>
#include <unistd.h>
#include <float.h>
#include "nifti1.h"
#include "nifti1_io.h"
#include "znzlib.h"
#include "fslio.h"
#include "config.h"
#define MAXL 256
double atanh(double x);
/***************************/
/*Variables used in FSL I/O*/
/***************************/   
    FSLIO *src;
    FSLIO *dest;
    short x_dim[MAXL], y_dim[MAXL], z_dim[MAXL], v_dim[MAXL], V_DIM;
    short X = 0, Y = 0, Z = 0, V = 0;
    short vv, t;  
    char *sbuffer;
    unsigned int direction = 0, bpp = 0;      
    double *vol;
    double *fptr;
    int blen;
    char filename[MAXL];
    int ifile = 0;
/***************************/
/***************************/

void setprog (char *program, char **argv) {
	char *ptr;

	if (!(ptr = strrchr (argv[0], '/'))) ptr = argv[0]; 
	else ptr++;
	strcpy (program, ptr);
}


static double z (double rho) {
	return (fabs (rho) < 1.) ? 0.5*log ((1. + rho)/(1. - rho)) : 0.0/0.0;
}

static void numerical_test () {
	int		i;
	double		q;

	for (i = 0; i < 15; i++) {
		q = (double) random() / (double) 0x7fffffffL;
		q = 3.0*q - 1.0;
		printf ("%5d %10.6f %10.6f %10.6f %10.6f\n", i, q, z(q), atanh(q), tanh(z(q)));
	}
	exit (0);
}

static char rcsid[]= "$Id: rho2z_nifti.c,v 1.1 2008/08/10 20:30:37 mtt24 Exp $";
int main (int argc, char *argv[]) {
/*************/
/* image I/O */
/*************/
	FILE		*fp_img, *fp_out;
/*	IFH		ifh;*/
	char		imgfile[MAXL], outfile[MAXL], imgroot[MAXL] = "", outroot[MAXL] = "";
	char		*str, command[MAXL], program[MAXL];
	char		trailerz[] = "zfrm", trailerr[] = "corr";

/**************/
/* processing */
/**************/
	char		control = '\0';
	int		imgdim[4], orient, isbig;
	float		voxdim[3];
	float		*imgt;
	int		dimension, c, i, k;
	double		q;

/*********/
/* flags */
/*********/
	int		z2r_flag = 0;
	int		status = 0;
	int		E_flag = 0;
	int		debug = 0;
	int             zip_Flag = 1;
	printf ("%s\n", rcsid);
	setprog (program, argv);

/************************/
/* process command line */
/************************/
        for (k = 0, i = 1; i < argc; i++) {
                if (*argv[i] == '-') {
		strcpy (command, argv[i]); str = command;
			while (c = *str++) switch (c) {
				case 'd': debug++;		break;
				case 'r': z2r_flag++;		break;
				case 'E': E_flag++;		break;
				case '@': control = *str++;	*str = '\0'; break;
			}
		} else switch (k) {
                        case 0: 
			strcpy (filename, argv[i]);
			blen = strlen(filename);
			
			if (strcmp(filename + blen-4,".nii") == 0) { 
			filename[blen-4]='\0';
			strcpy(imgroot, filename);
			}
			else if (strcmp(filename + blen-7,".nii.gz") == 0) { 
			filename[blen-7]='\0';
			strcpy(imgroot, filename);
			}
			else strcpy(imgroot, filename);
								k++; break;
                        case 1: strcpy (outroot, argv[i]);	k++; break;
                }
        }
	if (debug) numerical_test ();
        if (k < 1) {
		fprintf (stderr, "Usage:\t%s <(nii) image> [outroot]\n", program);
		fprintf (stderr, "e.g.,\t%s vce20_rho[.nii[.nii.gz]]\n", program);
		fprintf (stderr, "\toption\n");
		fprintf (stderr, "\t-r\treverse (convert z to r)\n");
		fprintf (stderr, "\t-E\toutput undefined voxels as 1.0e-37 (default 0.0)\n");
		fprintf (stderr, "\t-@<b|l>\toutput big or little endian (default input-endian)\n");
		fprintf (stderr, "N.B.:\tdefault r to z output filename root = <image>_%s\t\n", trailerz);
		fprintf (stderr, "N.B.:\tdefault z to r output filename root = <image>_%s\t\n", trailerr);
		exit (1);
	}

	sprintf (imgfile, "%s.nii", imgroot);
/***************************************/
/* create output filename if not given */
/***************************************/
	if (!strlen (outroot)) sprintf (outroot, "%s_%s", imgroot, (z2r_flag) ? trailerr : trailerz);	
	sprintf (outfile, "%s.nii", outroot);

/*****************************/
/* get 4dfp input dimensions */
/*****************************/
	src=FslOpen(FslMakeBaseName(filename),"r");
  	FslGetDim(src,&x_dim[ifile],&y_dim[ifile],&z_dim[ifile],&v_dim[ifile]);
      	bpp = FslGetDataType(src, &t) / 8;
	V=v_dim[ifile]; X=x_dim[ifile]; Y=y_dim[ifile]; Z=z_dim[ifile];
	sbuffer = (char *)calloc(X*Y*Z*V*bpp, sizeof (char));
  	FslReadVolumes(src, sbuffer, V);
	vol = (double *) calloc (X*Y*Z*V, sizeof (double));
  	convertBufferToScaledDouble(vol,sbuffer,X*Y*Z*V,1.0,0.0,src->niftiptr->datatype);
	

	imgdim[0] = X; imgdim[1] = Y; imgdim[2] = Z; imgdim[3] = V;
	/*
	if (get_4dfp_dimoe (imgfile, imgdim, voxdim, &orient, &isbig) < 0) errr (program, imgfile);
	if (Getifh (imgfile, &ifh)) errr (program, imgfile);*/
	if (!control) control = (isbig) ? 'b' : 'l';
	dimension = imgdim[0] * imgdim[1] * imgdim[2] * imgdim[3];

/*****************/
/* alloc buffers */
/*****************/
/*	if (!(imgt = (float *) malloc (dimension * sizeof (float)))) printf ("%s: could not allocate memory: %s\n", program);*/

/***********/
/* process */
/***********/
/*	if (!(fp_img = fopen (imgfile, "rb"))) printf ("%s: could not read file: %s\n", program, imgfile);
	if (!(fp_out = fopen (outfile, "wb"))) printf ("%s: could not write file: %s\n", program, outfile);*/
	fprintf (stdout, "Reading: %s\n", imgfile);
	
	fprintf (stdout, "Writing: %s\n", outfile);
	/*for (k = 0; k < imgdim[3]; k++) {
		if (eread  (imgt, dimension, isbig, fp_img)) errr (program, imgfile);*/
		/*
		for (i = 0; i < dimension; i++) imgt[i] = (float) vol[i]; 
		*/
		for (i = 0; i < dimension; i++) {
			q = (z2r_flag) ? tanh (vol[i]) : atanh (vol[i]);
			
			if (E_flag) {
				if (vol[i] == 1.e-37) continue;
				vol[i] = (isnan (q)) ? 1.e-37 : q;
			} else {
				vol[i] = (isnan (q)) ? 0.0 : q;
				/*
				if (isnan (q)){
				printf("val of q[%d] = %f\n", i, q);
				printf("val of vol[%d] = %f\n", i, vol[i]);
				}*/
			}
		
		}
		  
		/*if (ewrite (imgt, dimension, control, fp_out)) errw (program, outfile);
	}*/
		fptr = vol;
		write_nifti(imgroot, outfile, fptr, dimension, zip_Flag, V);
	/*fclose (fp_img);
	fclose (fp_out);

/*******************/
/* create rec file */
/*******************/
/*	startrece (outfile, argc, argv, rcsid, control);
	catrec    (imgfile);
	endrec    ();

/*******/
/* ifh */
/*******/
/*	if (Writeifh (program, outfile, &ifh, control)) errw (program, outfile);

/*******/
/* hdr */
/*******/
/*	sprintf (command, "ifh2hdr %s", outroot);
	status |= system (command);
*/
	free (vol); /*free (imgt); */
	exit (status);
}

/*******************************/
/*function to write nifti files*/
/*******************************/
int write_nifti(char *hdr_file, char *outfile, double *fptr, int dimension, int zip_Flag, int nvols)
{
void *outbuf;
int i;

void *buffer;
src = FslInit();
FslReadAllVolumes(src, hdr_file);
 
  
  
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
  FslSetDataType(src, 16); /*added to set datatype*/ 

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

