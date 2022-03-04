/***************************************************************************
 * Copyright 2007 Harvard University / HHMI
 * Cognitive Neuroscience Laboratory / Martinos Center for BiomedicalImaging
 ***************************************************************************/
/****************************************************************************
 * $Id: tseries_nifti.c,v 1.3 2007/04/04 20:09:18 mtt24 Exp $
 *
 * Description  : timecourse_nifti.c is used to otain time series for specified voxel
 *     		  coordinate.             
 *
 * Author       : Tanveer Talukdar <mtt24@nmr.mgh.harvard.edu>
 * 
 * Purpose : To generate time series data for individual voxel.
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
#define PROGRAM "timecourse_nifti"
#define MAXINPUTS 256
#define MAXL 256
/***********/
/*Functions*/
/***********/
float *detrend(float *ptr_tseries, int V, int DC_Flag);
/***************************/
/*Variables used in FSL I/O*/
/***************************/
    FSLIO *src, *msk;
    FSLIO *dest;
    short x_dim[MAXINPUTS], y_dim[MAXINPUTS], z_dim[MAXINPUTS], v_dim[MAXINPUTS];
    short X = 0, Y = 0, Z = 0, V = 0, t;
    float mmx, mmy, mmz;
    char filename[MAXL], mskfile[MAXL];
    char outfilename[MAXL]; 
    char *buffer, *mskbuffer; 
    unsigned int bpp = 0, mskbpp = 0;      
    double *vol, *mskvol;
    float voxx, voxy, voxz;
    int ivoxx, ivoxy, ivoxz;
    float x_voxdim, y_voxdim, z_voxdim;
    short x_dimmsk, y_dimmsk, z_dimmsk, v_dimmsk;
    mat44 stdmat;
    short sform_code;
    int order;


/********************/
/* Global variables */
/********************/

int blen, msklen; 
int  i, j, k; 
FILE *outfp;
char imgroot[MAXL], mskroot[MAXL];
char outroot[MAXL];
int ix, iy, iz, iv;
int dimension;	
char program[MAXL];
static char rcsid[] = "$Id: timecourse_nifti.c,v 1.1 2007/04/04 02:20:47 mtt24 Exp $";

int  lLineCount;   

main(int argc,char *argv[]) {

char *ptr, command[MAXL];
int ifile = 0;
float vox_tseries[300];
short mskdim[4]; 
float vox_Val;
double vox_size;
float sum_vox;
float radmm;
float rad_Dist;
fprintf (stdout, "%s\n", rcsid);
float *ptr_detrend, *ptr_dmean;
float *ptr_percent, mean_sig, pct_sigerg;
int nskip = 0;
float *skip_vol; 
/*********/
/* Flags */
/*********/
int input_Flag = 0;
int reg_Flag = 0;
int rad_Flag = 0;
int outfile_Flag = 0;
int detrend_Flag = 0;
int DC_Flag = 0;
int dmean_Flag = 0;
int percent_Flag = 0;
	
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
		input_Flag = 1;
                strcpy(imgroot,argv[i+1]); k++;
        	}

		else if (!strncmp("-o",argv[i],2)){
		outfile_Flag = 1;
                strcpy(outroot,argv[i+1]); k++;
        	}

		else if (!strncmp("-r",argv[i],2)){
		reg_Flag = 1;
                strcpy(mskroot,argv[i+1]); k++;
        	}
	
		else if (!strncmp("-rad",argv[i],4)){
		rad_Flag = 1;
		strcpy(command,argv[i+1]);
                radmm = atof(command);
		}
		
		else if (!strncmp("-skip",argv[i],5)){
		strcpy(command,argv[i+1]);
                nskip = atoi(command);
		}

		else if (!strncmp("-detrend",argv[i],8)){
		detrend_Flag = 1; 
                }

		else if (!strncmp("-dmean",argv[i],6)){
		dmean_Flag = 1; 
                }

		else if (!strncmp("-percent",argv[i],8)){
		percent_Flag = 1; 
                }

	
	}  
	

	if (k < 1){
 
	printf ("Copyright 2007 Harvard University / HHMI\n");
	printf ("This program is used to output a .dat file containing the\n");
	printf ("mean time course data of a region.\n");
	printf ("Usage:\t%s -i <.nii/.nii.gz> -r <.nii/.nii.gz>\n", program);
        printf ("e.g. %s -i N15_bold015.nii -r N15_bold015.reg20mm_1_-1_-1_.nii\n", program);
	printf ("\toption\n");
	printf ("\t-i <.nii/.nii.gz>: input bold image filename\n");
	printf ("\t-o <outstem>: specify output file prefix name (default uses input prefix name)\n");
	printf ("\t-r <.nii/.nii.gz>: specify ROI from which to extract mean voxel time course\n");
	printf ("\t-skip <int>: skip the first n time points (default = 0) \n");
	printf ("\t-detrend: linear detrend time series\n");
	printf ("\t-dmean: linear detrend time series and remove mean\n");
	printf ("\t-percent: express percent signal change of detrended time series from the mean\n");
	printf ("N.B.:\n"); 
	printf ("Columns 1 and 2 of the output .dat file represent time and mean voxel intensity respectively\n");
	printf ("Those two columns are produced by default if -detrend or -dmean or -percent is not selected\n"); 
	printf ("If -detrend is selected, a 3rd column is produced containing detrended time series data in\n");
	printf ("addition to the 2 previous columns.\n");
	printf ("If -demean is selected, a 4th column is produced containing mean removed detrended time series\n");
	printf ("data in addition to the 3 previous columns.\n");
	printf ("If -percent is selected, a 5th column is produced containing the percent signal change from the\n");
	printf ("mean in addition to the 4 previous columns. \n");
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
	printf("X = %d, Y = %d, Z = %d, V = %d\n", X, Y, Z, V);


    
  	buffer = (char *)calloc(X*Y*Z*V*bpp, sizeof (char));
  	FslReadVolumes(src, buffer, V);
      	FslSetVoxUnits(src, "mm"); /*set voxel size in mm*/

        
	vol = (double *) calloc (X*Y*Z*V, sizeof (double));
  	convertBufferToScaledDouble(vol,src->niftiptr->data,X*Y*Z*V,1.0,0.0,src->niftiptr->datatype);

	sform_code = FslGetStdXform(src, &stdmat);
	/*printf("stdmat = %g\n", stdmat.m[0][0]);*/
	if (input_Flag || rad_Flag){
	
	FslGetVoxCoord(stdmat,mmx,mmy,mmz,&voxx,&voxy,&voxz);
	
	ivoxx = (int)voxx;
        ivoxy = (int)voxy;
	ivoxz = (int)voxz;
	
	/*printf("voxx = %d, voxy = %d, voxz = %d\n", ivoxx, ivoxy, ivoxz);*/
	
	x_voxdim = src->niftiptr->pixdim[1];
	y_voxdim = src->niftiptr->pixdim[2];
	z_voxdim = src->niftiptr->pixdim[3];
	
	/*copy skipped volume to buffer*/	
	skip_vol = (float *) calloc (X*Y*Z*(V-nskip), sizeof (float));
	
	for (iv = nskip; iv < V; iv++) 
		for (iz = 0; iz < Z; iz++) 	
			for  (iy = 0; iy < Y; iy++) 
				for  (ix = 0; ix < X; ix++){
				skip_vol[ix + iy*X + iz*X*Y + (iv-nskip)*X*Y*Z] = (float) vol[ix + iy*X + iz*X*Y + iv*X*Y*Z];
				/*
				printf("skip_vol = %f\n", skip_vol[k]);*/
	}
	
	

	V = V - nskip;/*change V npoints to V-nskip points*/
	printf("Number of frames skipped = %d\n", nskip);
	for (iv = 0; iv < V; iv++) { 
		for (iz = 0; iz < Z; iz++){	
			for  (iy = 0; iy < Y; iy++){
				for  (ix = 0; ix < X; ix++)
		
				if (ix == ivoxx && iy == ivoxy && iz == ivoxz){
			   	vox_Val = skip_vol[ix + iy*X + iz*X*Y + iv*X*Y*Z];
				}
			}
		}	
	
	vox_tseries[iv] = vox_Val;
	/*
	printf("vox_tseries = %f\n", vox_tseries[iv]);
	*/
	
	}

	if (rad_Flag == 1){
	for (iv = 0; iv < V; iv++){
	vox_size = 0;
	sum_vox = 0.;
		for (iz = 0; iz < Z; iz++)	
			for  (iy = 0; iy < Y; iy++)
				for  (ix = 0; ix < X; ix++){

rad_Dist = sqrt(pow(abs((voxx-ix)*(x_voxdim)),2) + pow(abs((voxy-iy)*(y_voxdim)),2) + pow(abs((voxz-iz)*(z_voxdim)),2));	

		if ((rad_Dist <= radmm) && (skip_vol[ix + iy*X + iz*X*Y + iv*X*Y*Z] > 0)){
		vox_size++;
		sum_vox += skip_vol[ix + iy*X + iz*X*Y + iv*X*Y*Z];
		}
		
				}
	vox_tseries[iv] = (float) (sum_vox/vox_size); /*mean intensity per frame*/
	}
	}

	} /*end of condition for input_Flag or rad_flag*/


	if (reg_Flag == 1){
/****************/
/* prepare mask */
/****************/
	msklen = strlen(mskroot);
		
	if (strcmp(mskroot + msklen-4,".nii") == 0) { 
	   strcpy(mskfile, mskroot);
	   mskfile[msklen-4]='\0';
	}
	else if (strcmp(mskroot + msklen-7,".nii.gz") == 0) { 
		strcpy(mskfile, mskroot);
		mskfile[msklen-7]='\0';
	     }

	else strcpy(mskfile,mskroot);

	
	msk=FslOpen(FslMakeBaseName(mskfile),"r");
        ifile = 0;
  	FslGetDim(msk, &x_dimmsk, &y_dimmsk, &z_dimmsk, &v_dimmsk);
	mskdim[0] = x_dimmsk;
	mskdim[1] = y_dimmsk;
	mskdim[2] = z_dimmsk;
	mskdim[3] = v_dimmsk;
	mskbpp = FslGetDataType(msk, &t) / 8;
	mskbuffer = (char *)calloc(mskdim[0]*mskdim[1]*mskdim[2]*mskdim[3]*mskbpp, sizeof (char));
  	FslReadVolumes(msk, mskbuffer,mskdim[3]);
	mskvol = (double *) calloc (mskdim[0]*mskdim[1]*mskdim[2]*mskdim[3], sizeof (double));
  	convertBufferToScaledDouble(mskvol,mskbuffer,mskdim[0]*mskdim[1]*mskdim[2]*mskdim[3],1.0,0.0,msk->niftiptr->datatype);
   	

	for (iv = 0; iv < V; iv++){
	vox_size = 0;
	sum_vox = 0.;
		for (iz = 0; iz < Z; iz++)	
			for  (iy = 0; iy < Y; iy++)
				for  (ix = 0; ix < X; ix++){	

		if (mskvol[ix + iy*X + iz*X*Y] > 0){
	
		vox_size++;
		sum_vox += skip_vol[ix + iy*X + iz*X*Y + iv*X*Y*Z];
		}
		
				}
	vox_tseries[iv] = (float) (sum_vox/vox_size); /*mean intensity per frame*/
	}
	}
	
	if (detrend_Flag == 1) ptr_detrend = detrend(vox_tseries, V, 0);
	if (dmean_Flag == 1){
	ptr_detrend = detrend(vox_tseries, V, 0); 
	ptr_dmean = detrend(vox_tseries, V, 1);
	}
	
	if (percent_Flag == 1){
	if (!(ptr_percent = (float *) calloc (V, sizeof (float)))) printf("Memory allocation failure\n");
	ptr_detrend = detrend(vox_tseries, V, 0); 
	ptr_dmean = detrend(vox_tseries, V, 1);
	for (iv = 0; iv < V; iv++)
	mean_sig +=  ptr_detrend[iv];
	mean_sig = mean_sig/V;/*total signal energy*/
	for (iv = 0; iv < V; iv++){
	pct_sigerg = 100.*(ptr_detrend[iv]-mean_sig)/mean_sig; /*percent signal
	pct_sigerg = 100.*(abs(mean_sig - abs(ptr_detrend[iv])))/mean_sig; /*percent signal change from the mean signal energy*/
	ptr_percent[iv] = pct_sigerg;
	}
	}/*end of percent_Flag*/
 
	
	
	
	
	
	if (outfile_Flag == 0){
	if (rad_Flag == 1) sprintf (outroot,"%s.%.0f_%.0f_%.0f.voxt%.0fmm.dat",filename, mmx, mmy, mmz, radmm);
	else if (reg_Flag == 1) sprintf (outroot,"%s.voxt.dat", filename);
        else sprintf (outroot,"%s.%.0f_%.0f_%.0f.voxt.dat",filename, mmx, mmy, mmz);
	printf("Writing file: %s \n", outroot);
	outfp = fopen(outroot, "wb");
	for (k = 0; k < V; k++){
	if (detrend_Flag == 1) fprintf(outfp, "%d\t %4.2f\t %6.2f\n", k+nskip+1, vox_tseries[k], ptr_detrend[k]);
	else if (dmean_Flag == 1)fprintf(outfp, "%d\t %4.2f\t %6.2f\t %6.2f\n", k+nskip+1, vox_tseries[k], ptr_detrend[k], ptr_dmean[k]);
	else if (percent_Flag == 1)fprintf(outfp, "%d\t %4.2f\t %6.2f\t %6.2f\t %8.2f\n", k+nskip+1, vox_tseries[k], ptr_detrend[k], ptr_dmean[k], ptr_percent[k]);
        else fprintf(outfp, "%d\t %4.4f\n", k+nskip+1, vox_tseries[k]);}
	fclose (outfp);
	}
        else if (outfile_Flag == 1) { 
	if (rad_Flag == 1) sprintf (outfilename,"%s.%.0f_%.0f_%.0f.voxt%.0fmm.dat",outroot, mmx, mmy, mmz, radmm);
	if (reg_Flag == 1) sprintf (outfilename,"%s.voxt.dat", outroot);
        else sprintf (outfilename,"%s.%.0f_%.0f_%.0f.voxt.dat",outroot, mmx, mmy, mmz);
	printf("Writing file: %s \n", outfilename);
 	outfp = fopen(outfilename, "wb");
	for (k = 0; k < V; k++){
	if (detrend_Flag == 1) fprintf(outfp, "%d\t %4.2f\t %6.2f\n", k+nskip+1, vox_tseries[k], ptr_detrend[k]);
	else if (dmean_Flag == 1)fprintf(outfp, "%d\t %4.2f\t %6.2f\t %6.2f\n", k+nskip+1, vox_tseries[k], ptr_detrend[k], ptr_dmean[k]);
	else if (percent_Flag == 1)fprintf(outfp, "%d\t %4.2f\t %6.2f\t %6.2f\t %8.2f\n", k+nskip+1, vox_tseries[k], ptr_detrend[k], ptr_dmean[k], ptr_percent[k]);
        else fprintf(outfp, "%d\t %4.4f\n", k+nskip+1, vox_tseries[k]);}
	fclose (outfp);
	}
	
	free (vol), free (buffer);	

exit(0);
	

}

float *detrend(float *ptr_tseries, int V, int DC_Flag){

/****************************/
/* linear trend computation */
/****************************/
float	*x, sy, sxy, sxx, a[2];
float	*tpad, q;
int tdim;
int i, iv, k;
/********************************/
/* allocate time series buffers */
/********************************/
	tdim = V;	
	if (!(tpad = (float *) calloc (tdim, sizeof (float)))) printf("Memory allocation failure\n");
	if (!(x =    (float *) calloc (tdim, sizeof (float)))) printf("Memory allocation failure\n");
	for (i = 0; i < tdim; i++) x[i] = -1. + 2.*i/((tdim) - 1);
	sxx = ((float) (tdim)*(tdim+1)) / (3.*(tdim-1));	
			for (k = iv = 0; iv < V; iv++) {
		
		if (iv >= 0)tpad[k++] = ptr_tseries[iv];
		
					}
       
/****************************/
/*remove DC and linear trend*/
/****************************/

		for (sy = sxy =  k = 0; k < tdim; k++) {
			sy  += tpad[k];
			sxy += tpad[k]*x[k];
		}
		if (DC_Flag == 1)
		a[0] = sy/tdim;
		else if (DC_Flag == 0) a[0] = 0.; 
		a[1] = sxy/sxx;
		for (k = 0; k < tdim; k++) tpad[k] -= (a[0] + x[k]*a[1]);

	
	return tpad;
} /* end of detrend function*/  
