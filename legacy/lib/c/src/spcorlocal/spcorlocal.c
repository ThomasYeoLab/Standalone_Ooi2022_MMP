/***************************************************************************
 * Copyright 2007 Harvard University / HHMI
 * Cognitive Neuroscience Laboratory / Martinos Center for BiomedicalImaging
 ***************************************************************************/

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
#include "dbh.h"
#define PROGRAM "spcorlocal"
#define MAXINPUTS 256
#define MAXL 256

/*Beginning function for binary search*/

typedef int ElementType;
#define NotFound (-1)

        int
        BinarySearch( const ElementType A[ ], ElementType X, int N )
        {
            int Low, Mid, High;

           Low = 0; High = N - 1;
           while( Low <= High )
            {
          Mid = ( Low + High ) / 2;
          if( A[ Mid ] < X )
              Low = Mid + 1;
                else
          if( A[ Mid ] > X )
              High = Mid - 1;
                else
              return Mid;  /* Found */
            }
      return NotFound;     /* NotFound is defined as -1 */
        }
/* END */

/***************************/
/*Variables used in FSL I/O*/
/***************************/
    FSLIO *src, *incsrc;
    FSLIO *dest;
    short x_dim[MAXINPUTS], y_dim[MAXINPUTS], z_dim[MAXINPUTS], v_dim[MAXINPUTS];
    short incx_dim, incy_dim, incz_dim, incv_dim;
    short X = 0, Y = 0, Z = 0, V = 0, t;
    char filename[MAXL]; 
    char *buffer, *incbuffer; 
    unsigned int bpp = 0;      
    double *vol, *inc_vol;
    
    
    
/********************/
/* Global variables */
/********************/

int blen; 
int i, j, k,  k1, k2, k3, x, y, z; 
FILE	*imgfp, *outfp;
FILE    *report, *dat; /*for writing report file*/
char    incroot[MAXL];
char	imgroot[MAXL];
char	outroot[MAXL];
int ix, iy, iz, iv;
int px, py, pz, pv;
int dimension;
float *fptr;
char program[MAXL];
static char rcsid[] = "$Id: spcorlocal.c,v 1.0 2009/11/03 02:20:47 mtt24 Exp $"; 
int sx, sy, sz;
float xdim, ydim, zdim;
main(int argc,char *argv[]) 

{
/**************************/
/* variables used in main */
/**************************/
char *ptr, command[MAXL];
float *imgt;
int ifile = 0;
/*Variables used in correlation analysis*/
int inc_tdim;
int n_sample = 4;
float denom,r;
float threshval = 0;

float tdim;
int ftdim;
int r_count;
int *arrcounter;
int *arrnum;
float *voxtarr;
float *voxtarr_flip;
float *arr_sxx, *arr_sxy;
float sum_voxt, sum_sxx, sum_sxy;
float *corrarr;
int *mskarrindex;
int mskdim, mskdim_l;
int mskdim_i, mskdim_f;
int *x_coor, *y_coor, *z_coor;
float invw;
float percent;
float rad_Dist, rad = 6;
int indx, mskindx;
int true = 0;
int binval;
/************************/
/*Data Testing Variables*/
/************************/
/*
int arr1[] = {2,4,3,7};
int *arr2;
int *arr3;
int arrval;
/*********/
/* Flags */
/*********/

int zip_Flag = 1;
int include_Flag = 0;      
int out_Flag = 0;
int pos_Flag = 1;
int neg_Flag = 0;
int rad_Flag = 0;

	fprintf (stdout, "%s\n", rcsid);
	
	if (ptr = strrchr (argv[0], '/')) ptr++; else ptr = argv[0];
	strcpy (program, ptr);
	
		
	for (k = 0, i = 1; i < argc; i++) {

		

		if (!strncmp("-i",argv[i],2)){
                strcpy(imgroot,argv[i+1]);k++;
                }
		
		else if (!strncmp("-mask",argv[i],5)){
                strcpy(incroot,argv[i+1]);
		include_Flag = 1; k++;
                }
		
		else if (!strncmp("-o",argv[i],2)){
                strcpy(outroot,argv[i+1]);
		out_Flag = 1;
        	}
		
		else if (!strncmp("-thresh",argv[i],7)){
                threshval = atof(argv[i+1]);
		
        	}

		else if (!strncmp("-pos",argv[i],4)){
                pos_Flag = 1;
		
        	}

		else if (!strncmp("-neg",argv[i],4)){
                neg_Flag = 1;
		
        	}

		else if (!strncmp("-rad",argv[i],4)){
		rad_Flag = 1;
                rad = atof(argv[i+1]); 
                }
		
	
	}  
	
	if (k < 1){ 
	printf ("Copyright 2007 Harvard University / HHMI\n");
	printf ("Usage:\t%s  -i <(nii|nii.gz)> -mask <(nii|nii.gz)>\n", program);
	printf ("\toption\n");
	printf ("\t-i:\t<.nii/.nii.gz> : specify input image\n");
	printf ("\t-mask:<.nii/.nii.gz> : specify mask > 0 to select voxels from input image\n");
	printf ("\t-thresh:<float> : set threshold for counting voxel values > threshold.\n");
        printf ("\t-rad: specify radius (default = 6).\n");
	printf ("\t-pos: specify positive correlations to be counted (default is +ive).\n");
	printf ("\t-neg: specify negative correlations to be counted.\n");
	printf ("\t-o:\t<outstem> : specify output image\n");
	printf ("N.B.:when threshold is specified using -thresh, the output will be count image only.\n");
	
	exit (1);
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

		else sprintf(filename,"%s",imgroot);
		printf("Reading input image: %s.nii \n", filename);
		
	
	src=FslOpen(FslMakeBaseName(filename),"r");
    
  	FslGetDim(src,&x_dim[ifile],&y_dim[ifile],&z_dim[ifile],&v_dim[ifile]);
	
      	bpp = FslGetDataType(src, &t) / 8;
      	V=v_dim[ifile]; X=x_dim[ifile]; Y=y_dim[ifile]; Z=z_dim[ifile];
    
  	buffer = (char *)calloc(X*Y*Z*V*bpp, sizeof (char));
  	FslReadVolumes(src, buffer, V);
      	
        
  	printf("X = %d, Y = %d, Z = %d, V = %d\n", X, Y, Z, V);
	
	if (include_Flag == 1){
	printf("Reading mask image: %s\n", incroot);
	incsrc = FslOpen(FslMakeBaseName(incroot),"r");
	FslGetDim(incsrc,&incx_dim,&incy_dim,&incz_dim,&incv_dim);
	inc_tdim = incx_dim*incy_dim*incz_dim*incv_dim;
	if ((incx_dim != X) ||  (incy_dim != Y) || (incz_dim != Z)){
	printf ("Dimension mismatch between input image X,Y,Z dimension and mask image X,Y,Z dimension!\n");
	printf ("Program terminated.\n");
	exit(-1);
	}
	inc_vol = (double *) calloc (inc_tdim, sizeof (double));
	bpp = FslGetDataType(incsrc, &t) / 8;
	incbuffer = (char *)calloc(inc_tdim*bpp, sizeof (char));
	FslReadVolumes(incsrc, incbuffer, incv_dim);
	convertBufferToScaledDouble(inc_vol,incsrc->niftiptr->data,inc_tdim,1.0,0.0,incsrc->niftiptr->datatype);
	} /*end of if loop for include_Flag option*/
	
	
	vol = (double *) calloc (X*Y*Z*V, sizeof (double));
  	convertBufferToScaledDouble(vol,src->niftiptr->data,X*Y*Z*V,1.0,0.0,src->niftiptr->datatype);
	xdim = (float)(src->niftiptr->pixdim[1]);
        ydim = (float)(src->niftiptr->pixdim[2]);
        zdim = (float)(src->niftiptr->pixdim[3]);
/*Name output file*/
	if (out_Flag == 1)
	printf("Writing file: %s.nii.gz\n", outroot);  	
	else if (out_Flag == 0){
	sprintf(outroot,"%s_spcorlocal_msk_r%0.01fmm_thr_%0.02f",filename,rad,threshval);
	printf("Writing file: %s.nii.gz\n", outroot);}	



/*positive or negative correlation*/

if (neg_Flag == 1) pos_Flag = 0;	
/******************************/
/*Find voxel-voxel correlation*/
/******************************/	
	
/*locate voxel*/
if (include_Flag == 1){
arrcounter = (int* ) calloc (X*Y*Z, sizeof (int));
mskdim = 0;
	for (i = 0; i < X*Y*Z; i++){
	if (inc_vol[i] > 0){
	arrcounter[i] = i; mskdim++;}
	else arrcounter[i] = 0;
	}

/* unnecessary*/
for (i = 0; i < X*Y*Z; i++) if (arrcounter[i] > 0) {mskdim_i = arrcounter[i]; break;}
for (i = X*Y*Z; i > 0; i--) if (arrcounter[i] > 0) {mskdim_f = arrcounter[i]; break;}


mskdim_l = mskdim_f - mskdim_i;
printf("Total dimension of mask > 0 = %d \n", mskdim);

mskarrindex = (int* ) calloc (mskdim, sizeof (int));
if (rad_Flag == 1){
x_coor = (int* ) calloc (mskdim, sizeof (int));
y_coor = (int* ) calloc (mskdim, sizeof (int));
z_coor = (int* ) calloc (mskdim, sizeof (int));
}


	k = 0; k1 = 0; k2 = 0; k3 = 0;
	for (iz = 0; iz < Z; iz++) 
 		for (iy = 0; iy < Y; iy++)
			for (ix = 0; ix < X; ix++){
		if (arrcounter[ix + iy*X + iz*X*Y] > 0){ 
		mskarrindex[k++] = arrcounter[ix + iy*X + iz*X*Y];
		if (rad_Flag == 1){
		x_coor[k1++] = ix;
		y_coor[k2++] = iy;
		z_coor[k3++] = iz;}
		}
		
			}/*end of for loop in ix*/
}/*end of include_Flag*/


arrnum = (int*) calloc (mskdim, sizeof (int));
voxtarr = (float* ) calloc (mskdim*V, sizeof (float));
arr_sxx = (float* ) calloc (mskdim, sizeof (float));
arr_sxy = (float* ) calloc (mskdim, sizeof (float));

corrarr = (float* ) calloc (X*Y*Z, sizeof(float));
if (corrarr == NULL)printf("Failure to allocate room for covariance array\n");


/*make contiguous array of voxels pointing to time series array*/
	/*calculate mean of each time series*/
	for (i = 0; i < mskdim; i++){ 
		sum_voxt = 0.;
		for (iv = 0; iv < V; iv++){
		/*
		if (arr_[i] > 0)*/
		sum_voxt += (float) vol[mskarrindex[i] + iv*X*Y*Z];
		}
		arr_sxx[i] = sum_voxt/V;
	}
	
	/*Remove mean from each time series*/
	for (i = 0; i < mskdim; i++)
		for (iv = 0; iv < V; iv++){
	/*if (inc_vol[i] > 0)*/
	voxtarr[i + iv*mskdim] = (float) vol[mskarrindex[i] + iv*X*Y*Z] - arr_sxx[i];
	}

	
	/*calculate sum sxx*/
	for (i = 0; i < mskdim; i++){
		sum_sxx = 0;
		for (iv = 0; iv < V; iv++){
	/*if (inc_vol[i] > 0)*/
		sum_sxx += voxtarr[i + iv*mskdim]*voxtarr[i + iv*mskdim];
		}
	arr_sxx[i] = sum_sxx;
	}
	
	/*calculate sum sxy and r value*/
	sx = (int) floor(rad/xdim);
  	sy = (int) floor(rad/ydim);
  	sz = (int) floor(rad/zdim);

	
	/*size of sphere*/
	for (i = 0; i < mskdim; i++){
	 
	r_count = 0;
	
	/*make sphere around each voxel within mask*/

  	for (z=z_coor[i]-sz; z<z_coor[i]+sz; z++) {
    		for (y=y_coor[i]-sy; y<y_coor[i]+sy; y++) {
      			for (x=x_coor[i]-sx; x<x_coor[i]+sx; x++) {


	/*check if voxel within cube lies within sphere of radius <mm>*/
	rad_Dist = ((x_coor[i] - x)*(x_coor[i] - x) + (y_coor[i] - y)*(y_coor[i] - y) + (z_coor[i] - z)*(z_coor[i] - z));

		true = 0;
      		/*make sure voxel is also within mask*/
			if (rad_Dist <= rad*rad){ 
				indx = x + y*X + z*X*Y; /*set index val*/
				binval = BinarySearch(mskarrindex, indx, mskdim);
			  	if (binval != -1) {true = 1; mskindx = binval;}/*if indx exist in mskarrindex then true = 1*/
				else true = 0;
			}	

		/*
			if (rad_Dist <= rad*rad) indx = x + y*X + z*X*Y; /*set index val*/
			
      		/*make sure voxel is also within mask*/
		/*	true = 0;
			for (j = 0; j < mskdim; j++){ 
			if (indx == mskarrindex[j]) {true = 1; mskindx = j; break;}
	  		}		
		*/
	if (true == 1){

	
		sum_sxy = 0;
		for (iv = 0; iv < V; iv++){
		sum_sxy += voxtarr[i + iv*mskdim]*voxtarr[mskindx + iv*mskdim];
		}
		denom = sqrt(arr_sxx[i]*arr_sxx[mskindx]);
		if (denom == 0)
  		r =0.0;										
       		else r = sum_sxy / denom;
		
		if (neg_Flag == 1){
		if ((r < threshval) && (i!=mskindx)) arrnum[i] = ++r_count;
		}
		else if (pos_Flag == 1){
		if ((r > threshval) && (i!=mskindx)) arrnum[i] = ++r_count;
		}
		
	}/*end of true statement*/
	

	}}}  /*end of sphere loop*/
	
	printf("completed %4.2f %%\r", (100*((float)i/(float)mskdim)));
	
	}
	
	for (i = 0; i < mskdim; i++)
	corrarr[mskarrindex[i]] = arrnum[i];
		
	fptr = corrarr;
	dimension = X*Y*Z;
	write_nifti(imgroot, outroot, fptr, dimension, zip_Flag, 1);
	

	free (vol), free (buffer), free (incbuffer), free (inc_vol), free (x_coor), free (y_coor), free (z_coor); 
	free (voxtarr), free (arr_sxx), free (arr_sxy), free (arrnum), free (corrarr);
	exit(0);
	/*end of vsmaple_Flag*/
}

        
/*******************************/
/*function to write nifti files*/
/*******************************/
int write_nifti(char *hdr_file, char *outfile, float *fptr, int dimension, int zip_Flag, int nvols)
{
void *outbuf;
int i;
FSLIO *src, *dest;
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
