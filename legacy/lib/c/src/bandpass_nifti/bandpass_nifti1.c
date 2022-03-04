/* $Header: /data/petsun4/data1/src_solaris/interp_4dfp/RCS/bandpass_4dfp.c,v 1.7 2006/09/25 16:53:34 avi Exp $*/
/* $Log: bandpass_4dfp.c,v $
 * Revision 1.7  2006/09/25  16:53:34  avi
 * Solaris 10
 *
 * Revision 1.6  2006/08/07  03:25:58  avi
 * correct 1.e-37 test
 *
 * Revision 1.5  2004/12/29  00:42:05  avi
 * conc functionality
 * unconfuse low/high half-frequencies vs. low/high pass
 *
 * Revision 1.4  2004/11/22  22:15:59  rsachs
 * Installed 'setprog'. Replaced 'Get4dfpDimN' with 'get_4dfp_dimo'.
 *
 * Revision 1.3  2004/08/31  04:55:38  avi
 * improved algorithm for computing DC shift and linear trend
 * -a now controls only retaining DC shift
 *
 * Revision 1.2  2004/05/26  20:55:42  avi
 * improve rec file filter characteristic listing
 *
 * Revision 1.1  2004/05/26  20:31:21  avi
 * Initial revision
 *
 * Revision 1.4  2002/06/26  05:37:44  avi
 * better usage
 *
 * Revision 1.3  2002/06/26  05:14:20  avi
 * -a (keepDC) option
 *
 * Revision 1.2  2002/06/25  05:32:02  avi
 * impliment Butterworth highpasss filter
 *
 * Revision 1.1  2002/06/25  02:39:29  avi
 * Initial revision
 **/
/*************************************************************
Purpose:	time series filter  
Date:		6/22/02
Author:		Avi Snyder
**************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <float.h>
#include <stdlib.h>
#include <unistd.h>		/* R_OK */
#include <string.h>
#include "nifti1.h"
#include "nifti1_io.h"
#include "znzlib.h"
#include "fslio.h"
#include "config.h"

#define MAXINPUTS 	10000
#define MAXL		256
#define MARGIN		16
#define ORDER_LO	0
#define ORDER_HI	0
#define NSKIP		4
#define TRAILER		"bpss"
#define N_POINT         1024
#define MAX_REC_LEN 1024
#define MAXL        256
#define CR 13            /* Decimal code of Carriage Return char */
#define LF 10            /* Decimal code of Line Feed char */

/*************/
/* externals */
/*************/
extern void f_init (void), f_exit (void);	/* FORTRAN i/o */
extern int npad_ (int *tdim, int *margin);	/* FORTRAN librms */
extern void butt1db_ (float *data, int *n, float *delta, float *fhalf_lo, int *iorder_lo, float *fhalf_hi, int *iorder_hi); 
int nifti_lstread(FILE *input); /*, char output_file[MAXL][MAX_REC_LEN], int lLineCount);
/***************************/
/*Variables used in FSL I/O*/
/***************************/
    FSLIO *src;
    FSLIO *dest;
    short x_dim[MAXINPUTS], y_dim[MAXINPUTS], z_dim[MAXINPUTS], v_dim[MAXINPUTS];
    short X = 0, Y = 0, Z = 0, V = 0;
    short xx, yy, zz, vv, t;
    char filename[10000]; 
    char *buffer; 
    unsigned int direction = 0, bpp = 0;      
    double *vol;
    char input_file[MAXL][MAXL];
    char output_file[MAXL][N_POINT];
    int lLineCount;
    int ivoxel;
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
 
void usage (char* program) {
	printf ("Usage:\t%s <(nii|nii.gz) input> <TR_vol>\n", program);
	printf ("e.g.:\t%s qst1_b1_rmsp_dbnd_xr3d 2.36 -bl0.01 -ol1 -bh0.15 -oh2\n", program);
	printf ("\toption\n");
	printf ("\t-list use this option when using a text file containing a list of file names\n");
	printf ("e.g.:\t%s files.txt 2.36 -bl0.01 -ol1 -bh0.15 -oh2\n", program);
	printf ("\t-b[l|h]<flt>\tspecify low end or high end half frequency in hz\n");
	printf ("\t-o[l|h]<int>\tspecify low end or high end Butterworth filter order\n");
	printf ("\t-n<int>\tspecify number of pre-functional frames (default = %d)\n", NSKIP);
	printf ("\t-c<flt>\tscale output by specified factor\n");
	printf ("\t-t<str>\tchange output filename trailer (default=\"_%s\")\n", TRAILER);
	printf ("\t-a\tretain DC (constant) component\n");
	printf ("\t-E\tcode undefined voxels as 1.e-37\n");
	printf ("\t-@<b|l>\toutput big or little endian (default input endian)\n");
	printf ("N.B.:\tinput conc files must have extension \"conc\"\n");
	printf ("N.B.:\toutput filnename root is <input>_<trailer>\n", TRAILER);
	printf ("N.B.:\tlinear trend is always removed before filtering\n");
	printf ("N.B.:\tomitting low  end order specification disables high pass component\n");
	printf ("N.B.:\tomitting high end order specification disables low  pass component\n");
	exit (1);
}

void setprog (char *program, char **argv) {
	char *ptr;

	if (!(ptr = strrchr (argv[0], '/'))) ptr = argv[0]; 
	else ptr++;
	strcpy (program, ptr);
}

static char rcsid[] = "$Id: bandpass_nifti.c,v 1.7 2006/09/25 16:53:34 avi Exp $";
int main (int argc, char *argv[]) {
	char		imgroot[MAXL], imgfile[MAXL], outroot[MAXL], outfile[MAXL];
	char		trailer[MAXL] = TRAILER;
	FILE		*ifp;
        char            text_File[MAXL];
	char		control = '\0';
	int		c, i, j, k, ix, iy, iz, ivox, orient, isbig, osbig;
	int		nfile, ifile;
	int		imgdim[4], vdim, dimension, tdim, tdim_pad, margin = MARGIN, padlen;
	int		order_lo = ORDER_LO, order_hi = ORDER_HI, nskip = NSKIP;
	float		fhalf_lo = 0.0, fhalf_hi = 0.0, TR_vol;
	float	        *imga, cscale = 1.0;
	short		*mask;		/* set to 1 at undefined (1.e-37) voxels */
	short		*imgn;		/* denominator for average volume */
	float 		*imgt;
/****************************/
/* linear trend computation */
/****************************/
	float		*x, sy, sxy, sxx, a[2];
	float		*tpad, q;
	
/***********/
/* utility */
/***********/
	char *ptr, program[MAXL], command[MAXL];
	int blen;
/*********/
/* flags */
/*********/
	int		status;
	int		conc_flag = 0;
	int		keepDC = 0;
	int		E_flag = 0;
	int 		list_Flag = 0;
	f_init ();
	fprintf (stdout, "%s\n", rcsid);
	setprog (program, argv);
/******************************/
/* get command line arguments */
/******************************/
	for (k = 0, i = 1; i < argc; i++) {
		if (!strncmp("-list",argv[i],5)){
                strcpy(text_File,argv[i+1]);
		printf ("this is textfile: %s\n", text_File);
                list_Flag = 1;k++; 
                }
		
		

		if (*argv[i] == '-') {
		strcpy (command, argv[i]); ptr = command;
		if (!strncmp("-t", argv[i], 2))strcpy (trailer, ptr+2);
		while (c = *ptr++) switch (c) {
				case 'a': keepDC++;			break;
				case 'E': E_flag++;			break;
				case '@': control = *ptr++;		*ptr = '\0'; break;
				case 'c': cscale = atof (ptr);		*ptr = '\0'; break;
				case 'n': nskip = atoi (ptr);		*ptr = '\0'; break;
		/*		case 't': strcpy (trailer, ptr);	*ptr = '\0'; break;*/
				case 'o': switch (*ptr++) {
				case 'l': order_lo = atoi (ptr);	break;
				case 'h': order_hi = atoi (ptr);	break;
				default:  usage (program);		break;
			}						*ptr = '\0'; break;
				case 'b': switch (*ptr++) {
				case 'l': fhalf_lo = atof (ptr);	break;
				case 'h': fhalf_hi = atof (ptr);	break;
			/*	default:  usage (program);      	break;*/
				}				*ptr = '\0'; break;
			}
		} else 
			switch (k) {
		 	case 0: strcpy (imgroot, argv[i]);k++; break;
		 	case 1: TR_vol = atof (argv[i]);k++; break;
		}
	}
	
	if (k < 2) usage (program);
	printf ("fhalf_lo %.4f order_lo %d fhalf_hi %.4f order_hi %d\n", fhalf_lo, order_lo, fhalf_hi, order_hi);
	if (fhalf_lo <= 0.0 || order_lo < 0) order_lo = 0;
	if (fhalf_hi <= 0.0 || order_hi < 0) order_hi = 0;

	
        
        if (list_Flag == 1){
        printf("Opening text file: %s\n", text_File);
	ifp = fopen(text_File,"rb");
	nifti_lstread(ifp);
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
		
		
  		

	src=FslOpen(FslMakeBaseName(filename),"r");
    
  	FslGetDim(src,&x_dim[ifile],&y_dim[ifile],&z_dim[ifile],&v_dim[ifile]);
	
      	bpp = FslGetDataType(src, &t) / 8;
      	V=v_dim[ifile]; X=x_dim[ifile]; Y=y_dim[ifile]; Z=z_dim[ifile];
     	
	if (direction==0) V = v_dim[ifile];  	
    
  	buffer = (char *)calloc(X*Y*Z*V*bpp, sizeof (char));
  	FslReadVolumes(src, buffer, V);
      	
        
  	printf("X = %d, Y = %d, Z = %d, V = %d\n", X, Y, Z, V);
	vol = (double *) calloc (X*Y*Z*V, sizeof (double));
  	convertBufferToScaledDouble(vol,buffer,X*Y*Z*V,1.0,0.0,src->niftiptr->datatype);
        
	
		
		vdim = X*Y*Z ;
		if (list_Flag == 1){
		sprintf(outroot,"%s_%s",filename, trailer);
		sprintf (outfile, "%s", outroot);
		/*printf("Writing: %s.nii\n", outfile);*/
		} 
		else if (list_Flag == 0) {
		sprintf (outroot, "%s_%s", imgroot, trailer);
		sprintf (outfile, "%s", outroot);
		/*printf("Writing: %s.nii\n", outfile);*/
		}
	
	if (!(mask = (short *) calloc (vdim, sizeof (short)))) printf("Memory allocation failure\n");
	if (!(imgn = (short *) calloc (vdim, sizeof (short)))) printf("Memory allocation failure\n");	
	if (!(imga = (float *) calloc (vdim, sizeof (float)))) printf("Memory allocation failure\n");	
         
/***********************/
/* loop on input files */
/***********************/

	
	
	dimension = vdim * V;
	if (!(imgt = (float *) calloc (dimension, sizeof (float))))printf("Memory allocation failure\n"); 
        for (ivoxel = 0; ivoxel < dimension; ivoxel++){
            imgt[ivoxel] =  (float) vol[ivoxel];
 	}
        

/********************************/
/* allocate time series buffers */
/********************************/
	tdim = V - nskip;
	tdim_pad = npad_ (&tdim, &margin);
	padlen = tdim_pad - tdim;
	printf ("original time series length %d padded to %d\n", tdim, tdim_pad);
	if (!(tpad = (float *) calloc (tdim_pad, sizeof (float)))) printf("Memory allocation failure\n"); 
	if (!(x =    (float *) calloc (tdim, sizeof (float)))) printf("Memory allocation failure\n");
	for (i = 0; i < tdim; i++) x[i] = -1. + 2.*i/(tdim - 1);
	sxx = ((float) tdim*(tdim+1)) / (3.*(tdim-1));

/*********************************/
/* process all voxels of one run */
/*********************************/

	for (ivox = 0; ivox < vdim; ivox++) mask[ivox] = 0;
	ivox = 0;
	printf ("processing slice");
	for (iz = 0; iz < Z; iz++) {printf(" %d", iz + 1); fflush (stdout);
	for (iy = 0; iy < Y; iy++) {
	for (ix = 0; ix < X; ix++) {
		for (k = i = 0; i < V; i++) {
       
			if ((imgt + ivox)[i * vdim] == (float) 1.e-37) mask[ivox] = 1;
			if (i >= nskip) tpad[k++] = (imgt + ivox)[i * vdim];
		}
       
/****************************/
/*remove DC and linear trend*/
/****************************/
		for (sy = sxy = k = 0; k < tdim; k++) {
			sy  += tpad[k];
			sxy += tpad[k]*x[k];
		}
		a[0] = sy/tdim;
		a[1] = sxy/sxx;
		for (k = 0; k < tdim; k++) tpad[k] -= (a[0] + x[k]*a[1]);

/*********************************/
/* circularly connect timeseries */
/*********************************/
		q = (tpad[0] - tpad[tdim - 1]) / (padlen + 1);
		for (j = 1, k = tdim; k < tdim_pad; k++) tpad[k] = tpad[tdim - 1] + q*j++;
/**********/
/* filter */
/**********/	
	
		butt1db_ (tpad, &tdim_pad, &TR_vol, &fhalf_lo, &order_lo, &fhalf_hi, &order_hi);
		
/********************************************************************************/
/* force unpadded timeseries to zero mean and put fltered results back in image */
/********************************************************************************/
		for (q = k = 0; k < tdim; k++) q += tpad[k];
		q /= tdim;
		for (k = 0, i = nskip; i < V; i++) (imgt + ivox)[i * vdim] = tpad[k++] - q;

		for (i = 0; i < V; i++) {
			if (E_flag && mask[ivox]) {				(imgt + ivox)[i * vdim] = 1.e-37;
			} else {
				if (i <  nskip && !keepDC)			(imgt + ivox)[i * vdim] -= a[0];
				if (i >= nskip && keepDC)			(imgt + ivox)[i * vdim] += a[0];
				if (cscale != 1.0)				(imgt + ivox)[i * vdim] *= cscale;
			}
		}
		if (!E_flag || !mask[ivox]) {
			imga[ivox] += a[0]*cscale;
			imgn[ivox]++;
		}
		ivox++;
	}}}
	printf("\n");

/**********************/
/*Restore DC component*/
/**********************/

if (keepDC == 1) {
	for (ivox = 0; ivox < vdim; ivox++) if (imgn[ivox]) imga[ivox] /= imgn[ivox];
	for (ivox = 0; ivox < vdim; ivox++) {
		if (E_flag && imgt[ivox] == (float) 1.e-37) continue;
		imgt[ivox] += imga[ivox];
	}
}
/*************************************/
/*write bandpass filtered nifti stack*/
/*************************************/
printf("\nWriting: %s.nii\n", outfile);
FslSetDataType(src, 16); /*added to set datatype*/ 

        switch(src->niftiptr->datatype) {
            case NIFTI_TYPE_UINT8:
                 uint8_Data = (THIS_UINT8 *) calloc (dimension,  sizeof (THIS_UINT8));
                 for (ivoxel = 0; ivoxel < dimension; ivoxel++)
                 uint8_Data[ivoxel] = (THIS_UINT8)imgt[ivoxel];
                 
		 strcpy(filename,outfile);
                 dest = FslOpen(FslMakeBaseName(filename), "w");
                 FslCloneHeader(dest, src);
                 FslClose(src);
  	         FslSetDim(dest, X, Y, Z, V);
 	         FslSetDimensionality(dest, 4);
  	         FslWriteHeader(dest);
  	         FslWriteVolumes(dest,uint8_Data,V);
  	         FslClose(dest);
	         
            break;
            case NIFTI_TYPE_INT8:
                 int8_Data = (THIS_INT8 *) calloc (dimension,  sizeof (THIS_INT8));
            	 for (ivoxel = 0; i < dimension; ivoxel++)
            	 int8_Data[ivoxel] = (THIS_INT8)imgt[ivoxel];
            
		 strcpy(filename,outfile);
        	 dest = FslOpen(FslMakeBaseName(filename), "w");
        	 FslCloneHeader(dest, src);
         	 FslClose(src);
  		 FslSetDim(dest, X, Y, Z, V);
 		 FslSetDimensionality(dest, 4);
  		 FslWriteHeader(dest);
  		 FslWriteVolumes(dest,int8_Data,V);
  		 FslClose(dest);
		 
            break;
            case NIFTI_TYPE_UINT16:
                 uint16_Data = (THIS_UINT16 *)calloc (dimension,  sizeof (THIS_UINT16));
            	 for (ivoxel = 0; ivoxel < dimension; ivoxel++)
            	 uint16_Data[ivoxel] = (THIS_UINT16)imgt[ivoxel];
            
                 strcpy(filename,outfile);
        	 dest = FslOpen(FslMakeBaseName(filename), "w");
        	 FslCloneHeader(dest, src);
         	 FslClose(src);
  		 FslSetDim(dest, X, Y, Z, V);
 		 FslSetDimensionality(dest, 4);
  		 FslWriteHeader(dest);
  		 FslWriteVolumes(dest,uint16_Data,V);
  		 FslClose(dest);
		 
            break;
            case NIFTI_TYPE_INT16:
                 int16_Data = (THIS_INT16 *)calloc (dimension,  sizeof (THIS_INT16));
            	 for (ivoxel = 0; ivoxel < dimension; ivoxel++)
            	 int16_Data[ivoxel] = (THIS_INT16)imgt[ivoxel];
            
		 strcpy(filename,outfile);
        	 dest = FslOpen(FslMakeBaseName(filename), "w");
        	 FslCloneHeader(dest, src);
        	 FslClose(src);
  		 FslSetDim(dest, X, Y, Z, V);
 		 FslSetDimensionality(dest, 4);
  		 FslWriteHeader(dest);
  		 FslWriteVolumes(dest,int16_Data,V);
  		 FslClose(dest);
		 
            break;
            case NIFTI_TYPE_UINT64:
                 uint64_Data = (THIS_UINT64 *)calloc (dimension,  sizeof (THIS_UINT64));
            	 for (ivoxel = 0; ivoxel < dimension; ivoxel++)
            	 uint64_Data[ivoxel] = (THIS_UINT64)imgt[ivoxel];
            
	 	 strcpy(filename,outfile);
        	 dest = FslOpen(FslMakeBaseName(filename), "w");
        	 FslCloneHeader(dest, src);
        	 FslClose(src);
  		 FslSetDim(dest, X, Y, Z, V);
 		 FslSetDimensionality(dest, 4);
  		 FslWriteHeader(dest);
  		 FslWriteVolumes(dest,uint64_Data,V);
  		 FslClose(dest);
		 
            break;
            case NIFTI_TYPE_INT64:
                 int64_Data = (THIS_INT64 *)calloc (dimension,  sizeof (THIS_INT64));
            	 for (ivoxel = 0; ivoxel < dimension; ivoxel++)
            	 int64_Data[ivoxel] = (THIS_INT64)imgt[ivoxel];
	    
		 strcpy(filename,outfile);
        	 dest = FslOpen(FslMakeBaseName(filename), "w");
        	 FslCloneHeader(dest, src);
        	 FslClose(src);
  		 FslSetDim(dest, X, Y, Z, V);
 		 FslSetDimensionality(dest, 4);
  		 FslWriteHeader(dest);
  		 FslWriteVolumes(dest,int64_Data,V);
  		 FslClose(dest);
	 	 
            break;
            case NIFTI_TYPE_UINT32:
                 uint32_Data = (THIS_UINT32 *)calloc (dimension,  sizeof (THIS_UINT32));
            	 for (ivoxel = 0; ivoxel < dimension; ivoxel++)
            	 uint32_Data[ivoxel] = (THIS_UINT32)imgt[ivoxel];
	    
		 strcpy(filename,outfile);
        	 dest = FslOpen(FslMakeBaseName(filename), "w");
        	 FslCloneHeader(dest, src);
        	 FslClose(src);
  		 FslSetDim(dest, X, Y, Z, V);
 		 FslSetDimensionality(dest, 4);
  		 FslWriteHeader(dest);
  		 FslWriteVolumes(dest,uint32_Data,V);
  		 FslClose(dest);
		 
            break;
            case NIFTI_TYPE_INT32:
                int32_Data = (THIS_INT32 *)calloc (dimension,  sizeof (THIS_INT32));
            	for (ivoxel = 0; ivoxel < dimension; ivoxel++)
            	int32_Data[ivoxel] = (THIS_INT32)imgt[ivoxel];
	    
	    	strcpy(filename,outfile);
            	dest = FslOpen(FslMakeBaseName(filename), "w");
            	FslCloneHeader(dest, src);
        	FslClose(src);
  		FslSetDim(dest, X, Y, Z, V);
 		FslSetDimensionality(dest, 4);
  		FslWriteHeader(dest);
  		FslWriteVolumes(dest,int32_Data,V);
  		FslClose(dest);
		
            break;
            case NIFTI_TYPE_FLOAT32:
                float32_Data = (THIS_FLOAT32 *)calloc (dimension,  sizeof (THIS_FLOAT32));
            	for (ivoxel = 0; ivoxel < dimension; ivoxel++)
            	float32_Data[ivoxel] = (THIS_FLOAT32)imgt[ivoxel];
            
		strcpy(filename,outfile);
        	dest = FslOpen(FslMakeBaseName(filename), "w");
        	FslCloneHeader(dest, src);
        	FslClose(src);
  		FslSetDim(dest, X, Y, Z, V);
 		FslSetDimensionality(dest, 4);
  		FslWriteHeader(dest);
  		FslWriteVolumes(dest,float32_Data,V);
  		FslClose(dest);
		
            break;
            case NIFTI_TYPE_FLOAT64:
                float64_Data = (THIS_FLOAT64 *)calloc (dimension,  sizeof (THIS_FLOAT64));
            	for (ivoxel = 0; ivoxel < dimension; ivoxel++)
            	float64_Data[ivoxel] = (THIS_FLOAT64)imgt[ivoxel];
            
		strcpy(filename,outfile);
        	dest = FslOpen(FslMakeBaseName(filename), "w");
        	FslCloneHeader(dest, src);
        	FslClose(src);
  		FslSetDim(dest, X, Y, Z, V);
 		FslSetDimensionality(dest, 4);
  		FslWriteHeader(dest);
  		FslWriteVolumes(dest,float64_Data,V);
  		FslClose(dest);
		
            break;

            case NIFTI_TYPE_FLOAT128:
            case NIFTI_TYPE_COMPLEX128:
            case NIFTI_TYPE_COMPLEX256:
            case NIFTI_TYPE_COMPLEX64:
            default:{
                fprintf(stderr, "\nWarning, cannot support %s yet.\n",nifti_datatype_string(src->niftiptr->datatype));
                return(-1);}
        }
	
	free (tpad), free (x);
	free (vol), free (imgt), free (buffer);
	free (mask), free (imgn), free (imga);

    }  /*end of for loop for list_nifti*/
/************************/
/* restore DC component */
/************************/
/*	switch (control) {
		case 'b': case 'B': osbig = 1; break;
		case 'l': case 'L': osbig = 0; break;
		default: osbig = CPU_is_bigendian(); break;
	}
	if (conc_flag && keepDC) {
		for (ivox = 0; ivox < vdim; ivox++) if (imgn[ivox]) imga[ivox] /= imgn[ivox];
		if (!(imgt = (float *) malloc (vdim * sizeof (float)))) errm (program);
		for (ifile = 0; ifile < nfile; ifile++) {
			printf ("Adding back DC %s frame", conc_block.imgfile1[ifile]);
			if (!(fp = fopen (conc_block.imgfile1[ifile], "r+b"))) errr (program, conc_block.imgfile1[ifile]);
			for (k = 0; k < conc_block.nvol[ifile]; k++) {printf(" %d", k + 1); fflush (stdout);
				if (fseek (fp, (long) k*vdim*sizeof (float), SEEK_SET)
				||  eread (imgt, vdim, osbig, fp))
					errr (program, conc_block.imgfile1[ifile]);
				for (ivox = 0; ivox < vdim; ivox++) {
					if (E_flag && imgt[ivox] == (float) 1.e-37) continue;
					imgt[ivox] += imga[ivox];
				}
				if (fseek (fp, (long) k*vdim*sizeof (float), SEEK_SET)
				||  ewrite (imgt, vdim, control, fp))
					errw (program, conc_block.imgfile1[ifile]);
			}
			printf ("\n"); fflush (stdout);
			if (fclose (fp)) errw (program, conc_block.imgfile1[ifile]);
		}
		free (imgt);
	}


/*******/
/* rec */
/*******/

/*
	startrece (outfile, argc, argv, rcsid, control);
	sprintf (command, "TR_vol (sec) %.4f\n", TR_vol);					printrec (command);
	if (!conc_flag) {
		sprintf (command, "Original time series length %d padded to %d\n", tdim, tdim_pad);
		printrec (command);
	}
	if (keepDC) {
		sprintf (command, "Linear trend removed (DC preserved)\n");
	} else {
		sprintf (command, "DC shift and linear trend removed\n");
	}											printrec (command);
	if (order_lo) {
		sprintf (command, "High pass fhalf=%.4f (hz)  order=%d\n", fhalf_lo, order_lo);	printrec (command);
	}
	if (order_hi) {
		sprintf (command, "Low  pass fhalf=%.4f (hz)  order=%d\n", fhalf_hi, order_hi);	printrec (command);
	}
	if (cscale != 1.0) {
		sprintf (command, "Output intensity scaled by %.4f\n", cscale);			printrec (command);
	}
	catrec (imgfile);
	endrec ();
        */
	
	/*free (mask), free (imgn), free (imga);*/
	f_exit ();
	exit(0);
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

