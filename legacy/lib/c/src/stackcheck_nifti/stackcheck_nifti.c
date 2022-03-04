
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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "nifti1.h"
#include "nifti1_io.h"
#include "znzlib.h"
#include "fslio.h"
#include <float.h>

#define MIN_HEADER_SIZE 348
#define NII_HEADER_SIZE 352
#define MAXL	256
#define MAXF	16384		/*maximum number of frames*/

/********************/
/* global variables */
/********************/
static char rcsid[] = "$Id: stackcheck_nifti.c,v 1.7 2009/02/13 18:10:17 mtt24 Exp $";
static char	program[MAXL];
int nf_anat;
float scale_factor;
float factor = 1.0;			/* multiplier for output image values */
float threshval = 150.0;            /*image masking threshold*/
float stdev_out = 2.5;                  /*threshold for standard deviation*/
int nifti_datatype;


/******************/
/*image processing*/
/******************/
	char		format[MAXF] = "";		/* pattern of frames to count */
	double		*fptr;			/* general float pointer */
	double		*imgv;                  /* variance over all frames*/
	double		*imgu;			/* multivolume average over all frames */
	double		*maskimg;
	double          *imgsd;			/*pointer to standard deviation image*/ 
        double          *imgsnr;                /*pointer to snr image*/ 
	double          *slice_mean, *slice_min, *slice_max, *image_mean, *slice_stdev, *slice_snr;
	double          sum_mean, sum_stdev, sum_min, sum_max, sum_snr;
	double 		**tempimgt, **plotimgt;
	int             *slice_voxel, *slice_out, sum_voxel, sum_out;
	int		dimension, slice, nslices, slicedim, nf_func;
	double 		*tempimgu, *tempimgv, *tempmaskimg;
	int             xnum, ynum, znum, nframes, total_dimension; 
	double		diff, sum1; 
	int		count1;
	char		control = '\0';
	double          temp_data;

double **calloc_float2 (int n1, int n2) {
	int	i;
	double	**a;
	if (!(a = (double **) malloc (n1 * sizeof (double *)))) 
		fprintf(stderr, "\nError allocating data buffer for temp_imgt\n");
	if (!(a[0] = (double *) calloc (n1 * n2, sizeof (double))))
		fprintf(stderr, "\nError allocating data buffer for plot_imgt\n");
	for (i = 1; i < n1; i++) a[i] = a[0] + i*n2;
	return a;
}

void free_float2 (double **a) {
	free (a[0]);
	free (a);
}

void display_help();

main(argc,argv) 
int argc;
char *argv[];
{

/***************************/
/* variables used in main()*/
/***************************/

char *hdr_file, *data_file;
short do_read=0;
short do_write=0;
char *ptr, command[MAXL];
int c, i, j, k; 
FILE	*imgfp, *outfp;
FILE    *report, *dat; /*for writing report file*/
char	imgroot[MAXL], niftifile[MAXL];
char	outroot[MAXL], outfile[MAXL];
char	outstem[MAXL], holdstem[MAXL], statproc[MAXL], statfile[MAXL];
char    mskroot[MAXL], mskfile[MAXL];
int msklen;
fprintf (stdout, "%s\n", rcsid);
	if (ptr = strrchr (argv[0], '/')) ptr++; else ptr = argv[0];
	strcpy (program, ptr);

/*********/
/* flags */
/*********/		
	int		opr = 0;		
	int 		report_flag = 0;
	int             plot_flag = 0;
	int 		mean_flag = 0;
	int		mask_flag = 0;
	int		stdev_flag = 0;
	int		snr_flag = 0;
	int		quiet_flag = 0;
	int		help_flag = 0;
	int 		zip_Flag = 0;
	int             reg_Flag = 0;
	int             thresh_Flag = 0;
/************************/
/* process command line */
/************************/
	for (k = 0, i = 1; i < argc; i++) {
		
		if (!strncmp("-reg",argv[i],4)){
                strcpy(mskroot,argv[i+1]);
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
		reg_Flag = 1;
		k++;
        	}
		
		else if (!strncmp("-report", argv[i],7)){
		report_flag = 'r'; printf("-report\n");}

		else if (!strncmp("-mean", argv[i],5)){
		mean_flag = 'u'; printf("-mean\n");}

		else if (!strncmp("-mask", argv[i],5)){
		mask_flag = 'b'; printf("-mask\n");}
				
		else if (!strncmp("-snr", argv[i],4)){
		snr_flag = 'm';  printf("-snr\n");}

		else if (!strncmp("-stdev", argv[i],6)){
		stdev_flag = 's'; printf("-stdev\n");}
		
		else if (!strncmp("-plot", argv[i],5)){
		plot_flag = 'g'; printf("-plot\n");}

		else if (!strncmp("-quiet", argv[i],6)){
		quiet_flag = 1;}

		else if (!strncmp("-help", argv[i],5)){
		help_flag = 1;}
		
		else if (!strncmp("-thresh",argv[i],7)){
                strcpy(command,argv[i+1]);
                threshval = atof(command);
		thresh_Flag = 1; 
                }
		
		else if (!strncmp("-skip",argv[i],5)){
                strcpy(command,argv[i+1]);
                nf_anat = atoi(command); 
                }

		else if (!strncmp("-zip", argv[i],4)){
		zip_Flag = 1;}
		
  		else if (!strncmp(argv[i],"-i",2)){
		do_read = 1;
		strcpy (imgroot, argv[i+1]); /*was imgroot instead of niftifile*/
 		}

		else if (!strncmp(argv[i],"-o", 2)){
		strcpy (holdstem, argv[i+1]); opr = 'o';
		}

		
                  if (*argv[i] == '-'){
		  strcpy (command, argv[i]); ptr = command;
			
   		
			while (c = *ptr++) switch (c) {
				case 'f': strcpy (format, ptr);			*ptr = '\0'; break;
				case 'c': factor = atof (ptr);			*ptr = '\0'; break;
		       }
		  }
		
		k++;
	}	
		int blen;
  		blen = strlen(imgroot);
		
		if (strcmp(imgroot + blen-4,".nii") == 0) { 
		strcpy(niftifile, imgroot);
		imgroot[blen-4]='\0';
		}
		if (strcmp(imgroot + blen-7,".nii.gz") == 0) { 
		strcpy(niftifile, imgroot);
		imgroot[blen-7]='\0';
		}
		else
		sprintf(niftifile, "%s.nii", imgroot);
		
		hdr_file = niftifile; 
		data_file = niftifile;
		
		
		
	 
	if (help_flag == 1) {
		display_help();
		exit(0);
	} 

 
	
	if (k < 1 && help_flag == 0) {
		printf ("Copyright 2007 Harvard University / HHMI\n");
		printf ("Usage:\t%s <(.nii/.nii.gz) input>\n", program);
		printf (" e.g.,\t%s -report -mean -mask -skip 3 -i test_b1_rmsp_dbnd\n", program);
		printf ("\toption\n");
		printf ("\t-d\tdebug mode\n");
		printf ("\t-i\t<instem> : Input file name\n");
		printf ("\t-o\t<outstem> : Output file name\n");
		printf ("\t-reg\t<outstem> : Specify input region file name\n");
		printf ("\t-report\treport statistics for image slices in \".report\" file\n");
		printf ("\t-mean\toutput global mean image\n"); 
		printf ("\t-mask\toutput mask image\n");
		printf ("\t-snr\toutput snr image\n");
		printf ("\t-stdev\toutput standard deviation image\n");
		printf ("\t-plot\tcreates a \".mean.dat\" file with mean slice intensity over time\n");
		printf ("\t-quiet\tquiet mode\n");
		printf ("\t-thresh <float> specify threshold value for masking image (default = 150)\n");
		printf ("\t-skip <int> specify number of pre-functional frames per run (default = 0)\n");
                printf ("\t-zip creates .nii.gz output file\n");
		printf ("\t-f <str> specify frames to count format, e.g., \"4x120+4x76+\"\n");
		printf ("\t-c<flt> tscale output image values by specified factor\n");
		exit (1);
	}


/********** do the simple read or write */
	if (do_read)
        read_nifti_file(hdr_file, data_file, nf_anat, quiet_flag, reg_Flag, mskfile, thresh_Flag);


/*********************/
/* Write report file */
/*********************/	

	switch (report_flag) {
	
	case 'r':
		if (opr == 'o'){
		sprintf (statproc, "%s.report", holdstem);}
		else 
	        sprintf (statproc, "%s.report", imgroot); 
		sprintf (statfile, "%s", statproc);
		printf ("Writing: %s\n", statfile);				
                report = fopen(statfile, "wb");   
		fprintf (report, "%s\n", rcsid);
		fprintf (report, "Input .nii root: \"%s\"\n", imgroot); 
		fprintf (report, "z = %d, x = %d, y = %d images per slice = %d\n\n", znum, xnum, ynum, nframes);
	        fprintf (report, "Timepoints = %d skip = %d count = %d\n\n",nframes,nframes - nf_func,nf_func);
		fprintf	(report, "Threshold value for mask: %4.2f\n\n", threshval);
                fprintf(report, "slice\tvoxels\tmean\tstdev\tsnr\tmin\tmax\t#out\n");
                for (slice = 0; slice < nslices; slice++){
                fprintf(report, "%-10.3d\%-d\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%d\n", slice+1, 
		slice_voxel[slice], slice_mean[slice], slice_stdev[slice], slice_snr[slice], slice_min[slice], 			slice_max[slice],slice_out[slice]);}
		fprintf(report, "\nVOXEL\t%d\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%d/%d\n", sum_voxel, 
		(sum_mean/sum_voxel), (sum_stdev/sum_voxel), (sum_snr/sum_voxel), (sum_min/sum_voxel), 
		(sum_max/sum_voxel), (sum_out), (znum*nframes));
		fclose (report);
		break;
	
	}


/***********************/
/* Write mean dat file */
/***********************/
	switch (plot_flag) {
	
	case 'g':
		if (opr == 'o'){
		sprintf (statproc, "%s.mean.dat", holdstem);}
		else 
	        sprintf (statproc, "%s.mean.dat", imgroot); /*report stats*/
		sprintf (statfile, "%s", statproc);
		printf ("Writing: %s\n", statfile);				
                dat = fopen(statfile, "wb");
		
			for (j = 0; j < nframes; j++){
			fprintf (dat, "%d\t", j);
		
			     for (slice = 0; slice < nslices; slice++){	
				
			     	fprintf (dat,"%4.2f\t", plotimgt[j][slice]);
			     }
			fprintf(dat, "\n");
			}
			fclose (dat);
		break;
	}

/*******************************/
/* Output mean image intensity */
/*******************************/
	switch (mean_flag) {
	case 'u':
		
		
		
		for (k = 0; k < dimension; k++){ 
		imgu[k] *= factor;
		if (isnan(imgu[k])) imgu[k] = 0.0;
		if (!finite(imgu[k])) imgu[k] = 0.0;}
		fptr = imgu;
		printf ("Please wait...including mean image file\n");
		if (opr == 'o'){
		sprintf (outroot, "%s_mean", holdstem);}
		else 
		sprintf (outroot, "%s_mean", imgroot);
		sprintf (outfile, "%s.nii", outroot);
		if (zip_Flag == 1) sprintf (outfile, "%s.nii.gz", outroot);
		printf ("Writing: %s\n", outfile);
		write_nifti_file(hdr_file, outfile, fptr, dimension, zip_Flag);
		break;		
	}

/*******************************/
/* Output mask image intensity */
/*******************************/
	switch (mask_flag) {
	case 'b':
		
		
		for (k = 0; k < dimension; k++) {
		maskimg[k] *= factor;
		if (isnan(maskimg[k])) maskimg[k] = 0.0;
		if (!finite(maskimg[k]));}
		fptr = maskimg;
		printf ("Please wait...including mask image file\n");
		if (opr == 'o'){
		sprintf (outroot, "%s_mask", holdstem);}
		else 
		sprintf (outroot, "%s_mask", imgroot);
		sprintf (outfile, "%s.nii", outroot);
		if (zip_Flag == 1) sprintf (outfile, "%s.nii.gz", outroot);
		printf ("Writing: %s\n", outfile);
		write_nifti_file(hdr_file, outfile, fptr, dimension, zip_Flag);
		break;		
	}
/**********************************/
/* Output standard deviation image*/
/**********************************/
	switch (stdev_flag) {
	case 's':
		
		for (k = 0; k < dimension; k++) { 
		imgsd[k] = (factor * sqrt (imgv[k]));
		if (isnan(imgv[k])) imgsd[k] = 0.0;
		if (!finite(imgv[k])) imgsd[k] = 0.0;}
		fptr = imgsd;
		printf ("Please wait...including stdev image file\n");
		if (opr == 'o'){
		sprintf (outroot, "%s_sd", holdstem);}
		else 
		sprintf (outroot, "%s_sd", imgroot);
		sprintf (outfile, "%s.nii", outroot);
		if (zip_Flag == 1) sprintf (outfile, "%s.nii.gz", outroot);
		printf ("Writing: %s\n", outfile);
		write_nifti_file(hdr_file, outfile, fptr, dimension, zip_Flag);
		break;	
	}

/*******************/
/* Output snr image*/
/*******************/
	switch (snr_flag) {
	case 'm':
		if (reg_Flag == 1){
		for (k = 0; k < dimension; k++){  
		if  (imgv[k] == 0.0) imgsnr[k] = 0.0;
		else imgsnr[k] = (factor * ((imgu[k])/sqrt(imgv[k])));
		if (isnan(imgv[k])) imgsnr[k] = 0.0;
		if (!finite(imgv[k])) imgsnr[k] = 0.0;}
		}

		if (reg_Flag == 0){
		for (k = 0; k < dimension; k++){ 
		imgsnr[k] = (factor * ((imgu[k])/sqrt(imgv[k])));
		if (isnan(imgv[k])) imgsnr[k] = 0.0;
		if (!finite(imgv[k])) imgsnr[k] = 0.0;}
		}
		fptr = imgsnr;
		printf ("Please wait...including snr image file\n");
		if (opr == 'o'){
		sprintf (outroot, "%s_snr", holdstem);}
		else 
		sprintf (outroot, "%s_snr", imgroot);
		sprintf (outfile, "%s.nii", outroot);
		if (zip_Flag == 1) sprintf (outfile, "%s.nii.gz", outroot);
		printf ("Writing: %s\n", outfile);
		write_nifti_file(hdr_file, outfile, fptr, dimension, zip_Flag);
		break;
		
	}
/*************/
/* close i/o */
/*************/
	
	free (imgv); free (imgsd); free (imgsnr); free (imgu); free (slice_mean); free (slice_voxel);
	free (maskimg); free (slice_max); free (image_mean); free_float2 (tempimgt); free (slice_min);
	free (slice_stdev); free (slice_snr); free_float2 (plotimgt); 
exit(0);
}

/**********************************************************************
 *
 * read_nifti_file
 *
 **********************************************************************/
int read_nifti_file(hdr_file, data_file, nf_anat, quiet_flag, reg_Flag, mskfile, thresh_Flag)
char *hdr_file, *data_file;
char mskfile[MAXL];
{
int c1 = 0;
int i1, j1, k1, l1;
int datatype;
float *data;
double *data1=NULL; 
double total,***vol;
double *vol1;


/*********************************/
/*Reading using FSL read function*/
/*********************************/
 
        FSLIO *fslio;
        void *buffer;
        int nvols, ret;
        fslio = FslInit();
	buffer = FslReadAllVolumes(fslio,hdr_file);

/**************************/
/*Variables used for mask */
/**************************/
    FSLIO *msk; 
    char *mskbuffer; 
    unsigned mskbpp = 0;      
    double *mskvol;
    short mskdim[4];
    short x_dimmsk, y_dimmsk, z_dimmsk, v_dimmsk, t;
    int ifile;
     
/***********************************/
/* get input nifti image dimensions */
/***********************************/
		xnum = fslio->niftiptr->nx;  
		ynum = fslio->niftiptr->ny;
		znum = fslio->niftiptr->nz;
		nframes = fslio->niftiptr->nt;
		dimension = xnum*ynum*znum;
		total_dimension = nframes*dimension;
		slicedim = xnum*ynum;
		nslices = znum;
		
	if (reg_Flag == 1){


	
	
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
	

	vol1 = (double *) calloc (total_dimension,  sizeof (double));
	convertBufferToScaledDouble(vol1,fslio->niftiptr->data,total_dimension,1,0,fslio->niftiptr->datatype);
	
	data1 = (double *) calloc (total_dimension,  sizeof (double));
	for (j1 = 0; j1 < nframes; j1++){
		for (i1 = 0; i1 < dimension; i1++){
		if (mskvol[i1] > 0)
		data1[i1 + j1*dimension] = vol1[i1 + j1*dimension];
		else data1[i1 + j1*dimension] = 0;
		}	
	} 
	
	} /*end of reg_Flag condition*/
	
	else if (reg_Flag == 0){

	vol1 = (double *) calloc (total_dimension,  sizeof (double));
	convertBufferToScaledDouble(vol1,fslio->niftiptr->data,total_dimension,1,0,fslio->niftiptr->datatype);
	
	data1 = (double *) calloc (total_dimension,  sizeof (double));
	for (i1 = 0; i1 < total_dimension; i1++)
	data1[i1] = vol1[i1]; 
	}

/***********/
/* utility */
/***********/
	
	int i, j, k;
	double 	q;
        
	

/***********************************/
/* allocate buffer for stats info  */
/***********************************/		
	
	if (!(imgv = (double *) calloc (dimension,  sizeof (double)))
   	||  !(imgsd = (double *) calloc (dimension,  sizeof (double)))
	||  !(imgsnr = (double *) calloc (dimension,  sizeof (double)))
	||  !(imgu = (double *) calloc (dimension,  sizeof (double)))
	||  !(maskimg = (double *) calloc (dimension,  sizeof (double)))
	||  !(image_mean = (double *) calloc (nframes,  sizeof (double)))
	||  !(slice_max = (double *) calloc (nslices,  sizeof (double)))
	||  !(slice_voxel = (int *) calloc (nslices,  sizeof (int)))
	||  !(slice_min = (double *) calloc (nslices,  sizeof (double)))
	||  !(slice_stdev = (double *) calloc (nslices,  sizeof (double)))
	||  !(slice_mean = (double *) calloc (nslices,  sizeof (double)))
	||  !(slice_snr = (double *) calloc (nslices,  sizeof (double)))
	||  !(slice_out = (int *) calloc (nslices,  sizeof (int))))
	fprintf(stderr, "\nError allocating data buffer for stats\n");
	tempimgt = calloc_float2 (nframes, dimension);
	plotimgt = calloc_float2 (nframes, nslices);	



/***********************************/
/* set up frames to count (format) */
/***********************************/
	
		printf ("stackcheck_nifti: nf_anat=%d\n", nf_anat);
			nf_func = nframes - nf_anat;
			if (nf_func < 0) {
				fprintf (stderr, "%s: %s has more skip than total frames\n", program, data_file);
			}
			for (j = k = 0; j < nf_anat; j++) format[k++] = 'x';
			for (j = 0; j < nf_func; j++) format[k++] = '+';
		
		
	
	printf ("%s\n", format);
	for (nf_func = j = 0; j < nframes; j++) if (format[j] == '+') nf_func++;
	printf ("frames total = %d counted = %d skip = %d\n", nframes, nf_func, nframes - nf_func);
	printf ("stackcheck_nifti: nf_anat = %d\n", nf_anat);
		nf_func = nframes - nf_anat;
		if (nf_func < 0) {
			fprintf (stderr, "stackcheck_nifti: %s has more skip than total frames\n", data_file);
		}


/********************************/
/* compute mean and logical and */
/********************************/
	
		printf ("Reading: %s", data_file);
		printf ("\t%d frames\n", nf_func);
		printf ("Please wait...This may take a few minutes\n");
		
		for (k = j = 0; j < nframes; j++) {
			if (format[j] != '+') continue;
			k++;
			for (i = 0; i < dimension; i++) {
				tempimgt[j][i] = (data1[i + j*dimension]); /*holds image data for each frame*/			
				if (thresh_Flag == 1){
				if (data1[i + j*dimension] > threshval){
				temp_data = (data1[i + j*dimension]);
				imgu[i] += temp_data;}
				else imgu[i] = 0;}
				
				else if (thresh_Flag == 0){
				imgu[i] += (data1[i + j*dimension]);}
				if (data1[i + j*dimension] > threshval){
					sum1 += (data1[i + j*dimension]);
					count1 ++;
				}
				
   				
			}
				
		}
			
			scale_factor = sum1/count1; /*used for normalizing image*/
			  for (i = 0; i < dimension; i++){ 
				imgu[i] /= k; /*mean image in a run*/
				if (isnan(imgu[i])) imgu[i] = 0.0;
				}

/********************/
/* compute variance */
/********************/
	        
		for (k = j = 0; j < nframes; j++) { 
			if (format[j] != '+') continue;
			k++;
			for (i = 0; i < dimension; i++) {
				if (thresh_Flag == 1){
				if (data1[i + j*dimension] > threshval){
				temp_data = (data1[i + j*dimension]);
				q = temp_data - imgu[i];}
				else q = 0;
				imgv[i] += q*q;}
				else if (thresh_Flag == 0){
				q = (data1[i + j*dimension]) - imgu[i];
				imgv[i] += q*q;}
			}
		}
	
	for (i = 0; i < dimension; i++) {
		imgv[i] /= (k - 1);
		if (isnan(imgv[i])) imgv[i] = 0.0;
	}  /*computing variance*/ 


/************************************************************************/
/* make mask around mean volume brain and calculate mean slice intensity*/
/************************************************************************/
	sum_voxel = 0;
	sum_mean = 0.;
	for (slice = 0; slice < nslices; slice++){
		double sum = 0.;
		int count = 0;
		
		for (count = i = 0; i < slicedim; i++){
			if (imgu[i + (slice*slicedim)] > threshval){
			    maskimg[i + (slice*slicedim)] = 1.;
			    sum += imgu[i + (slice*slicedim)];
			    count += 1;
			}
			else maskimg[i + (slice*slicedim)] = 0.;
				
		}
		
		
		slice_mean[slice] = sum/count; /*mean slice intensity*/
		slice_voxel[slice] = count; /*sum of inbrain voxels per slice*/
		sum_voxel += slice_voxel[slice]; /*sum of inbrain voxel values for all slices*/
		if (slice_voxel[slice] != 0) /*check for zero voxel count & exclude from calculation*/ 
		sum_mean += ((slice_mean[slice])*(slice_voxel[slice])); /*sum of all mean intensities*/ 
		slice_max[slice] = 0.;
		slice_min[slice] = 10000.;
		
	}

		

/**********************************************************************************************/
/* compute mean intensity for inbrain voxels, slice standard deviation slice snr and slice out*/
/**********************************************************************************************/
		sum_max = 0.; sum_min = 0.; sum_stdev = 0.; sum_snr = 0.; sum_out = 0;
		for (slice = 0; slice < nslices; slice++){  
		    	
			for (j = 0; j < nframes; j++){
			if (format[j] != '+') continue;
			
			sum1 = 0.;
			count1 = 0;
		     	  for (i = 0; i < slicedim; i++){
			     if (maskimg[i + (slice*slicedim)] == 1.){
				count1++;
				sum1 += tempimgt[j][i + (slice*slicedim)]; /*sum of inbrain voxels per slice*/ 		     		     }						   
			  }	       
		       	 
		       image_mean[j] = sum1/(count1);
		    
		       plotimgt[j][slice] = image_mean[j];
		       if (image_mean[j] > slice_max[slice])
		       slice_max[slice] = image_mean[j];
		       if (image_mean[j] < slice_min[slice])
		       slice_min[slice] = image_mean[j];
		       
	               }
		       if (slice_voxel[slice] == 0){    /*outputting "nan" for zero voxel count*/
		       slice_min[slice] = 0.0/0.0;
                       slice_max[slice] = 0.0/0.0;
                       }
		       
			if (slice_voxel[slice] != 0)
		        sum_min += ((slice_min[slice])*(slice_voxel[slice]));
		       
			if (slice_voxel[slice] != 0)
		        sum_max += ((slice_max[slice])*(slice_voxel[slice]));
		  	
			double sum_diff = 0.;
			diff = 0.;
			for  (j = 0; j < nframes; j++){
				if (format[j] != '+') continue;
				diff = image_mean[j] - slice_mean[slice];
				sum_diff += fabs(diff*diff);
			}
				slice_stdev[slice] = sqrt(sum_diff/(nframes-nf_anat-1));
				slice_snr[slice] = slice_mean[slice]/slice_stdev[slice];
				
				if (slice_voxel[slice] != 0)
				sum_stdev += ((slice_stdev[slice])*(slice_voxel[slice]));
				
				if (slice_voxel[slice] != 0)
				sum_snr += ((slice_snr[slice])*(slice_voxel[slice]));

			
			for  (j = 0; j < nframes; j++){
			  	if (format[j] != '+') continue;
		  		if ((fabs(image_mean[j] - slice_mean[slice])) > (stdev_out*slice_stdev[slice])){
				   slice_out[slice]++;
  				}									
			}
				

				sum_out += slice_out[slice];
				
				if (quiet_flag != 1){
				printf("%d\t%d\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%4.2f\t%d\n", slice+1, 
				slice_voxel[slice], slice_mean[slice], slice_stdev[slice], slice_snr[slice], 
				slice_min[slice], slice_max[slice],slice_out[slice]);
				}

		}
	 




return (0);
}


/**********************************************************************
 *
 * write_nifti_file
 * 
 * write a nifti1 (.nii) data file
 * 
 * using nifti_image structure from nifti1_io.h
  ***********************************************************************/



int write_nifti_file(hdr_file, outfile, fptr, dimension, zip_Flag)
char *hdr_file, *outfile;
double *fptr;
int dimension;
int zip_Flag;
{


void *outbuf;
int i;
FSLIO *fslio, *fsl1; 

        void *buffer;
        fslio = FslInit();
	FslReadAllVolumes(fslio, hdr_file);
	
 /*******************************************************/		
 /* write output by converting to original FSL datatype */
 /*******************************************************/
  
  
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
  FslSetDataType(fslio, 16);
  
        switch(fslio->niftiptr->datatype) {
            case NIFTI_TYPE_UINT8:
                 uint8_Data = (THIS_UINT8 *) calloc (dimension,  sizeof (THIS_UINT8));
                 for (i = 0; i < dimension; i++)
                     uint8_Data[i] = (THIS_UINT8)fptr[i];
			
			if (zip_Flag == 0){
                 	fsl1 = FslOpen(outfile,"wb"); 
		 	FslCloneHeader(fsl1,fslio);
		 	fsl1->niftiptr->nt = 1;
		 	FslSetDataType(fsl1, fslio->niftiptr->datatype);
		 	fsl1->niftiptr->data = uint8_Data; 
		 	FslWriteHeader(fsl1);
           	 	FslWriteVolumes(fsl1,fsl1->niftiptr->data,1);
		 	FslClose(fsl1);
		 	}

 			if (zip_Flag == 1){
        		fsl1 = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(fsl1, fslio);
        		FslClose(fslio);
  			fsl1->niftiptr->nt = 1;
 			FslSetDimensionality(fsl1, 4);
  			FslWriteHeader(fsl1);
  			FslWriteVolumes(fsl1,uint8_Data,1);
  			FslClose(fsl1);
			}
            break;
            case NIFTI_TYPE_INT8:
                 int8_Data = (THIS_INT8 *) calloc (dimension,  sizeof (THIS_INT8));
            	 for (i = 0; i < dimension; i++)
            	 int8_Data[i] = (THIS_INT8)fptr[i];
		
			if (zip_Flag == 0){
            	 	fsl1 = FslOpen(outfile,"wb"); 
		 	FslCloneHeader(fsl1,fslio);
		 	fsl1->niftiptr->nt = 1;
		 	FslSetDataType(fsl1, fslio->niftiptr->datatype);
		 	fsl1->niftiptr->data = int8_Data; 
		 	FslWriteHeader(fsl1);
           	 	FslWriteVolumes(fsl1,fsl1->niftiptr->data,1);
		 	FslClose(fsl1);
			}
			
			if (zip_Flag == 1){
        		fsl1 = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(fsl1, fslio);
        		FslClose(fslio);
  			fsl1->niftiptr->nt = 1;
 			FslSetDimensionality(fsl1, 4);
  			FslWriteHeader(fsl1);
  			FslWriteVolumes(fsl1,int8_Data,1);
  			FslClose(fsl1);
			}
			
		 
	    break;
            case NIFTI_TYPE_UINT16:
                 uint16_Data = (THIS_UINT16 *)calloc (dimension,  sizeof (THIS_UINT16));
            	 for (i = 0; i < dimension; i++)
            	 uint16_Data[i] = (THIS_UINT16)fptr[i];
		 
		 	if (zip_Flag == 0){
                 	fsl1 = FslOpen(outfile,"wb"); 
		 	FslCloneHeader(fsl1,fslio);
		 	fsl1->niftiptr->nt = 1;
		 	FslSetDataType(fsl1, fslio->niftiptr->datatype);
		 	fsl1->niftiptr->data = uint16_Data; 
		 	FslWriteHeader(fsl1);
           	 	FslWriteVolumes(fsl1,fsl1->niftiptr->data,1);
		 	FslClose(fsl1);
			}

			if (zip_Flag == 1){
        		fsl1 = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(fsl1, fslio);
        		FslClose(fslio);
  			fsl1->niftiptr->nt = 1;
 			FslSetDimensionality(fsl1, 4);
  			FslWriteHeader(fsl1);
  			FslWriteVolumes(fsl1,uint16_Data,1);
  			FslClose(fsl1);
			}
                 
            break;
            case NIFTI_TYPE_INT16:
                 int16_Data = (THIS_INT16 *)calloc (dimension,  sizeof (THIS_INT16));
            	 for (i = 0; i < dimension; i++)
            	 int16_Data[i] = (THIS_INT16)fptr[i];
		 

		
			if (zip_Flag == 0){
            	 	fsl1 = FslOpen(outfile,"wb"); 
		 	FslCloneHeader(fsl1,fslio);
		 	fsl1->niftiptr->nt = 1;
		 	FslSetDataType(fsl1, fslio->niftiptr->datatype);
		 	fsl1->niftiptr->data = int16_Data; 
		 	FslWriteHeader(fsl1);
           	 	FslWriteVolumes(fsl1,fsl1->niftiptr->data,1);
		 	FslClose(fsl1);
			}

			if (zip_Flag == 1){
        		fsl1 = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(fsl1, fslio);
        		FslClose(fslio);
  			fsl1->niftiptr->nt = 1;
 			FslSetDimensionality(fsl1, 4);
  			FslWriteHeader(fsl1);
  			FslWriteVolumes(fsl1,int16_Data,1);
  			FslClose(fsl1);
			}
			
		 
            break;
            case NIFTI_TYPE_UINT64:
                 uint64_Data = (THIS_UINT64 *)calloc (dimension,  sizeof (THIS_UINT64));
            	 for (i = 0; i < dimension; i++)
            	 uint64_Data[i] = (THIS_UINT64)fptr[i];

			if (zip_Flag == 0){
            	 	fsl1 = FslOpen(outfile,"wb"); 
		 	FslCloneHeader(fsl1,fslio);
		 	fsl1->niftiptr->nt = 1;
		 	FslSetDataType(fsl1, fslio->niftiptr->datatype);
		 	fsl1->niftiptr->data = uint64_Data; 
		 	FslWriteHeader(fsl1);
           	 	FslWriteVolumes(fsl1,fsl1->niftiptr->data,1);
		 	FslClose(fsl1);
			}

			if (zip_Flag == 1){
        		fsl1 = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(fsl1, fslio);
        		FslClose(fslio);
  			fsl1->niftiptr->nt = 1;
 			FslSetDimensionality(fsl1, 4);
  			FslWriteHeader(fsl1);
  			FslWriteVolumes(fsl1,uint64_Data,1);
  			FslClose(fsl1);
			}
			

            break;
            case NIFTI_TYPE_INT64:
                 int64_Data = (THIS_INT64 *)calloc (dimension,  sizeof (THIS_INT64));
            	 	for (i = 0; i < dimension; i++)
            	 	int64_Data[i] = (THIS_INT64)fptr[i];

			if (zip_Flag == 0){
	    	 	fsl1 = FslOpen(outfile,"wb"); 
		 	FslCloneHeader(fsl1,fslio);
		 	fsl1->niftiptr->nt = 1;
		 	FslSetDataType(fsl1, fslio->niftiptr->datatype);
		 	fsl1->niftiptr->data = int64_Data; 
		 	FslWriteHeader(fsl1);
           	 	FslWriteVolumes(fsl1,fsl1->niftiptr->data,1);
		 	FslClose(fsl1);
			}

			if (zip_Flag == 1){
        		fsl1 = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(fsl1, fslio);
        		FslClose(fslio);
  			fsl1->niftiptr->nt = 1;
 			FslSetDimensionality(fsl1, 4);
  			FslWriteHeader(fsl1);
  			FslWriteVolumes(fsl1,int64_Data,1);
  			FslClose(fsl1);
			}			

            break;
            case NIFTI_TYPE_UINT32:
                 uint32_Data = (THIS_UINT32 *)calloc (dimension,  sizeof (THIS_UINT32));
            	 for (i = 0; i < dimension; i++)
            	 uint32_Data[i] = (THIS_UINT32)fptr[i];

			if (zip_Flag == 0){
		 	fsl1 = FslOpen(outfile,"wb"); 
		 	FslCloneHeader(fsl1,fslio);
		 	fsl1->niftiptr->nt = 1;
		 	FslSetDataType(fsl1, fslio->niftiptr->datatype);
		 	fsl1->niftiptr->data = uint32_Data; 
		 	FslWriteHeader(fsl1);
           	 	FslWriteVolumes(fsl1,fsl1->niftiptr->data,1);
		 	FslClose(fsl1);
			}


			if (zip_Flag == 1){
        		fsl1 = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(fsl1, fslio);
        		FslClose(fslio);
  			fsl1->niftiptr->nt = 1;
 			FslSetDimensionality(fsl1, 4);
  			FslWriteHeader(fsl1);
  			FslWriteVolumes(fsl1,uint32_Data,1);
  			FslClose(fsl1);
			}	    
		 
            break;
            case NIFTI_TYPE_INT32:
                int32_Data = (THIS_INT32 *)calloc (dimension,  sizeof (THIS_INT32));
            	for (i = 0; i < dimension; i++)
            	int32_Data[i] = (THIS_INT32)fptr[i];

			if (zip_Flag == 0){
	    		fsl1 = FslOpen(outfile,"wb"); 
			FslCloneHeader(fsl1,fslio);
			fsl1->niftiptr->nt = 1;
			FslSetDataType(fsl1, fslio->niftiptr->datatype);
			fsl1->niftiptr->data = int32_Data; 
			FslWriteHeader(fsl1);
           		FslWriteVolumes(fsl1,fsl1->niftiptr->data,1);
			FslClose(fsl1);
			}


			if (zip_Flag == 1){
        		fsl1 = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(fsl1, fslio);
        		FslClose(fslio);
  			fsl1->niftiptr->nt = 1;
 			FslSetDimensionality(fsl1, 4);
  			FslWriteHeader(fsl1);
  			FslWriteVolumes(fsl1,int32_Data,1);
  			FslClose(fsl1);
			}	
	    	            
	    break;
            case NIFTI_TYPE_FLOAT32:
                float32_Data = (THIS_FLOAT32 *)calloc (dimension,  sizeof (THIS_FLOAT32));
            	for (i = 0; i < dimension; i++)
            	float32_Data[i] = (THIS_FLOAT32)fptr[i];


			if (zip_Flag == 0){
                	fsl1 = FslOpen(outfile,"wb"); 
			FslCloneHeader(fsl1,fslio);
			fsl1->niftiptr->nt = 1;
			FslSetDataType(fsl1, fslio->niftiptr->datatype);
			fsl1->niftiptr->data = float32_Data; 
			FslWriteHeader(fsl1);
           		FslWriteVolumes(fsl1,fsl1->niftiptr->data,1);
			FslClose(fsl1);
			}


			if (zip_Flag == 1){
        		fsl1 = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(fsl1, fslio);
        		FslClose(fslio);
  			fsl1->niftiptr->nt = 1;
 			FslSetDimensionality(fsl1, 4);
  			FslWriteHeader(fsl1);
  			FslWriteVolumes(fsl1,float32_Data,1);
  			FslClose(fsl1);
			}
		
            break;
            case NIFTI_TYPE_FLOAT64:
                float64_Data = (THIS_FLOAT64 *)calloc (dimension,  sizeof (THIS_FLOAT64));
            	for (i = 0; i < dimension; i++)
            	float64_Data[i] = (THIS_FLOAT64)fptr[i];

			if (zip_Flag == 0){
            		fsl1 = FslOpen(outfile,"wb"); 
			FslCloneHeader(fsl1,fslio);
			fsl1->niftiptr->nt = 1;
			FslSetDataType(fsl1, fslio->niftiptr->datatype);
			fsl1->niftiptr->data = float64_Data; 
			FslWriteHeader(fsl1);
           		FslWriteVolumes(fsl1,fsl1->niftiptr->data,1);
			FslClose(fsl1);
			}

			if (zip_Flag == 1){
        		fsl1 = FslOpen(FslMakeBaseName(outfile), "w");
        		FslCloneHeader(fsl1, fslio);
        		FslClose(fslio);
  			fsl1->niftiptr->nt = 1;
 			FslSetDimensionality(fsl1, 4);
  			FslWriteHeader(fsl1);
  			FslWriteVolumes(fsl1,float64_Data,1);
  			FslClose(fsl1);
			}
		            
	    break;

            case NIFTI_TYPE_FLOAT128:
            case NIFTI_TYPE_COMPLEX128:
            case NIFTI_TYPE_COMPLEX256:
            case NIFTI_TYPE_COMPLEX64:
            default:
                fprintf(stderr, "\nWarning, cannot support %s yet.\n",nifti_datatype_string(fslio->niftiptr->datatype));
                return(-1);
        }
	
	
return(0);
}





/***********************************************************************
Display help function
 ***********************************************************************/
void display_help()
{
char *help = "\n Copyright 2007 Harvard University / HHMI\n\
\n\
Application: stackcheck_nifti runs on nifti .nii/.nii.gz files.\n\
\n\
Purpose: stackcheck_nifti is designed to take in a nifti stack of fMRI images \n\
with single or multiple slices and evaluate the stability of the data and \n\
make several basic measurements.  In addition, stackcheck_nifti will build a \n\
new series of MRI images that are in the exact same format as the original \n\
images but adjusted based on options specified by the user. \n\
\n\
stackcheck_nifti takes in a nifti format file <nii/nii.gz> specified by the \n\
-i option and creates a new nifti file with the initial file prefix and a \n\
\"_<mean/snr/mask/stdev>.nii\" image file depending on the user selection. \n\
Alternate output files are specified by -o. Both prefixes or full file name \n\
may be used for both of these options (e.g., -i S120r43/S120r43.nii/S120r43.nii.gz). \n\
It should be noted that -i <file> cannot be the same as the -o <file>.\n\
\n\
A report is also created with a \".report\" extension attached to the infile root \n\
infile root. This report contains information about each slice as well as the history\n\
of what was done to the image stack. This is a text file and can be read by opening \n\
it in a text editor. The columns in the .report file are mostly self explanatory but \n\
snr = signal to noise ratio (i.e., the ratio of mean to stdev), min = slice minimum, \n\
max = slice maximum, voxels = the number of voxels being considered (> threshval) per \n\
slice (and then total in last line), #out is the number of images > 2.5 stdev from the mean.\n\
A final file that can be created by selecting the -plot option is a text file that contains \n\
the mean slice intensity for each time point. This file can be viewed using a text editor\n\
or, better yet, graphed using xvgr (e.g., xvgr S120r42.mean).\n\
\n\
Additional options are:\n\
\n\
-skip 	This option will cause stackcheck_nifti to skip the first n images in \n\
 	all statistical calculations (e.g., -skip 4). this is good when \n\
	the first images are bad due to t1 stabiliation or other factors. \n\
\n\
-thresh This option sets the threshold to determine which voxels \n\
	are in the brain. It is used for all calculations where slice \n\
	values are computed.\n\
\n\
-quiet	Turns off a good portion of the messages. Slice values, if \n\
	computed, are still displayed. \n\
\n\
-zip	Produces output image files which are in zipped format <.nii.gz> \n\
	\n\
For further information on how to use stackcheck_nifti, please visit CNLwiki \n\
page at www.nmr.mgh.harvard.edu/nexus\n\n"; 


    fprintf(stdout, help);
    exit(0);
}			/* END display_help */
