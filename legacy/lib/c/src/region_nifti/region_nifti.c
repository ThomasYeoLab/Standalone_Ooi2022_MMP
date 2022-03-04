/***************************************************************************
 * Copyright 2007 Harvard University / HHMI
 * Cognitive Neuroscience Laboratory / Martinos Center for BiomedicalImaging
 ***************************************************************************/
/****************************************************************************
 * $Id: region_nifti.c,v 1.3 2007/04/04 20:09:18 mtt24 Exp $
 *
 * Description  : region_nifti.c is used to identify voxels in an activation
 *                map that have intensities higher than a specified threshold.  
 *
 * Author       : Tanveer Talukdar <mtt24@nmr.mgh.harvard.edu>
 * 
 * Purpose : To generate an image volume showing voxels that are above a 
 *           particular threshold.
 *     
 *****************************************************************************/
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include <stdlib.h>
#include <unistd.h>		/* R_OK */
#include "nifti1.h"
#include "nifti1_io.h"
#include "znzlib.h"
#include "fslio.h"
#include "dbh.h"
#define PROGRAM "region_nifti"
#define MAXINPUTS 256
#define MAXL 256

/***************************/
/*Variables used in FSL I/O*/
/***************************/
    FSLIO *src;
    FSLIO *dest;
    short x_dim[MAXINPUTS], y_dim[MAXINPUTS], z_dim[MAXINPUTS], v_dim[MAXINPUTS];
    short X = 0, Y = 0, Z = 0, V = 0, t;
    float mmx, mmy, mmz;
    char filename[MAXL]; 
    char *buffer; 
    unsigned int direction = 0, bpp = 0;      
    double *vol; 
    float *vol_coord, *fptr;
    float voxx, voxy, voxz;
    float x_voxdim,y_voxdim,z_voxdim; 
    mat44 stdmat;
    short sform_code;
    int order;


/********************/
/* Global variables */
/********************/


int i,k,blen; 
float rad_Dist;
char imgroot[MAXL];
char outroot[MAXL];
int ix, iy, iz, iv;
int dimension;	
char program[MAXL];
static char rcsid[] = "$Id: region_nifti.c,v 1.0 2007/04/04 02:20:47 mtt24 Exp $"; 

main(int argc,char *argv[]) {

char *ptr, command[MAXL];
int ifile = 0;
int voxel_count[300];
float radmm;
float val;
float threshval;
int vox_Size;
fprintf (stdout, "%s\n", rcsid);

/*********/
/* Flags */
/*********/
int thresh_Flag = 0;
int val_Flag = 0;
int all_Flag = 0;
int rad_Flag = 0;
int super_Flag = 0;
int zip_Flag = 1;
int outfile_Flag = 0;
	
	if (ptr = strrchr (argv[0], '/')) ptr++; else ptr = argv[0];
	strcpy (program, ptr);
	
		
	for (k = 0, i = 1; i < argc; i++) {

		
		switch (i) {
		case 1 : mmx = atof (argv[i]);
		case 2 : mmy = atof (argv[i]);			
		case 3 : mmz = atof (argv[i]);
		
		break;			
		}
		
		
		if (!strncmp("-i",argv[i],2)){
                strcpy(imgroot,argv[i+1]); k++;
        	}

		else if (!strncmp("-o",argv[i],2)){
		outfile_Flag = 1;
                strcpy(outroot,argv[i+1]); k++;
        	}

		else if (!strncmp("-rad",argv[i],4)){
		rad_Flag = 1;
		strcpy(command,argv[i+1]);
                radmm = atof(command);
		}
		
		else if (!strncmp("-val",argv[i],4)){
		strcpy(command,argv[i+1]);
                val = atof(command); 
		val_Flag = 1;
                }

		else if (!strncmp("-thresh",argv[i],7)){
		thresh_Flag = 1;
		strcpy(command,argv[i+1]);
                threshval = atof(command); 
                }
		
		else if (!strncmp("-all",argv[i],4)){ 
		all_Flag = 1;
                }
		else if (!strncmp("-super",argv[i],6)){
		super_Flag = 1; 
                }
		
	
	}  
	

	if (k < 1){
 
	printf ("Copyright 2007 Harvard University / HHMI\n");
	printf ("Usage:\t%s <x y z> -thresh <float> -rad <int> -val <float> -i <.nii/.nii.gz>\n", program);
        printf ("e.g. %s 2 2 4 -thresh 0.5 -val 1 -rad 8 -i N15_avg_corr.nii\n", program);
	printf ("\toption\n");
	printf ("\t<x y z> : input x, y, and z coordinate in mm\n");
	printf ("\t-i <instem>: input image file name or file prefix name\n");
	printf ("\t-o <outstem>: output image file name (use prefix only)\n");
	printf ("\t-rad <int>: define maximum distance in mm to be searched for\n");
	printf ("\tactive voxels\n");
	printf ("\t-val <float>: specify intensity for output region (default\n"); 
	printf ("\t value is the actual voxel intensity)\n"); 
	printf ("\t-thresh <float>: set threshold value for voxels to be included in region\n");
	printf ("\t-all: include all voxel intensities in selected region\n");
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
		printf("Reading file: %s.nii \n", filename);
		
	

	src=FslOpen(FslMakeBaseName(filename),"r");
    
  	FslGetDim(src,&x_dim[ifile],&y_dim[ifile],&z_dim[ifile],&v_dim[ifile]);
	
      	bpp = FslGetDataType(src, &t) / 8;
      	V=v_dim[ifile]; X=x_dim[ifile]; Y=y_dim[ifile]; Z=z_dim[ifile];
     	order = FslGetLeftRightOrder(src);
	/*printf("oder = %d \n", order);*/
	

	sform_code = FslGetStdXform(src, &stdmat);
	/*printf("stdmat = %g\n", stdmat.m[0][0]);*/
	
	
	FslGetVoxCoord(stdmat,mmx,mmy,mmz,&voxx,&voxy,&voxz);
	
	if (direction==0) V = v_dim[ifile];  	
    
  	buffer = (char *)calloc(X*Y*Z*V*bpp, sizeof (char));
  	FslReadVolumes(src, buffer, V);
      	FslSetVoxUnits(src, "mm"); /*set voxel size in mm*/
        
  	printf("X = %d, Y = %d, Z = %d, V = %d\n", X, Y, Z, V);


	vol = (double *) calloc (X*Y*Z*V, sizeof (double));
	vol_coord = (float *) calloc (X*Y*Z*V, sizeof (float));
  	convertBufferToScaledDouble(vol,src->niftiptr->data,X*Y*Z*V,1.0,0.0,src->niftiptr->datatype);
	
	x_voxdim = src->niftiptr->pixdim[1];
	y_voxdim = src->niftiptr->pixdim[2];
	z_voxdim = src->niftiptr->pixdim[3];
	
        if (rad_Flag == 1 && all_Flag == 0){
		
	
	for (iv = 0; iv < V; iv++){
		for (iz = 0; iz < Z; iz++)	
			for  (iy = 0; iy < Y; iy++)
				for  (ix = 0; ix < X; ix++){
	rad_Dist = sqrt(pow(abs((voxx-ix)*(x_voxdim)),2) + pow(abs((voxy-iy)*(y_voxdim)),2) + pow(abs((voxz-iz) *(z_voxdim)),2));
	if (thresh_Flag == 1){
	if ((rad_Dist <= radmm) && (vol[ix + iy*X + iz*X*Y + iv*X*Y*Z] > threshval)){
		if (val_Flag == 1) vol_coord[ix + iy*X + iz*X*Y + iv*X*Y*Z] = val;
		else vol_coord[ix + iy*X + iz*X*Y + iv*X*Y*Z] = (float) vol[ix + iy*X + iz*X*Y + iv*X*Y*Z];
	}
	if ((rad_Dist <= radmm) && (vol[ix + iy*X + iz*X*Y + iv*X*Y*Z] < threshval)){
		if (super_Flag == 1) vol_coord[ix + iy*X + iz*X*Y + iv*X*Y*Z] = (float) vol[ix + iy*X + iz*X*Y + iv*X*Y*Z];
		else vol_coord[ix + iy*X + iz*X*Y + iv*X*Y*Z] = 0.;
	}
	}
	
				}
		
	}
	} /*end of rad_Flag condition*/
	
	else if (all_Flag == 1 && rad_Flag == 1){
	V = 1;
	for (iv = 0; iv < V; iv++){
		for (iz = 0; iz < Z; iz++)	
			for  (iy = 0; iy < Y; iy++)
				for  (ix = 0; ix < X; ix++){
	rad_Dist = sqrt(pow(abs((voxx-ix)*(x_voxdim)),2) + pow(abs((voxy-iy)*(y_voxdim)),2) + pow(abs((voxz-iz) *(z_voxdim)),2));
	if (rad_Dist <= radmm){
		if (val_Flag == 1) vol_coord[ix + iy*X + iz*X*Y + iv*X*Y*Z] = val;
		if (super_Flag == 1) vol_coord[ix + iy*X + iz*X*Y + iv*X*Y*Z] = (float) vol[ix + iy*X + iz*X*Y + iv*X*Y*Z];
		
	}
				}
	}
	} /*end of all_Flag condition*/

	if (outfile_Flag == 0){
        sprintf (outroot,"%s_reg%.0fmm_%.0f_%.0f_%.0f_",filename, radmm, mmx, mmy, mmz);
	}
	
        else if (outfile_Flag == 1) sprintf (outroot,"%s_reg%.0fmm_%.0f_%.0f_%.0f_",outroot, radmm, mmx, mmy, mmz);
 	
	fptr = vol_coord;
        dimension = X*Y*Z;
        printf("writing file: %s.nii.gz\n", outroot);
	write_nifti(imgroot, outroot, fptr, dimension*V, zip_Flag, V);  

	free (vol), free(vol_coord), free (buffer);	

exit(0);
	

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
