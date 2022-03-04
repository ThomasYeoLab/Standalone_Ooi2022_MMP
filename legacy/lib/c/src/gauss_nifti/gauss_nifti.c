/*$Header: /autofs/space/nexus_001/users/nexus-tools/cvsrepository/nifti_tools/gauss_nifti/gauss_nifti.c,v 1.2 2010/03/23 15:55:16 mtt24 Exp $*/
/*$Log: gauss_nifti.c,v $
/*Revision 1.2  2010/03/23 15:55:16  mtt24
/*added checks for memroy allocation failures
/*
 * Revision 1.15  2007/04/23  02:37:19  avi
 * gcc v3 compliant (filter subroutines converted to C)
 * remove f_init() and f_exit()
 *
 * Revision 1.14  2006/09/25  18:59:24  avi
 * correct bug computing conc outfile
 *
 * Revision 1.13  2006/09/25  18:34:31  avi
 * Solaris 10
 *
 * Revision 1.12  2005/12/06  06:37:37  avi
 * conc file capability
 *
 * Revision 1.11  2005/12/02  06:56:48  avi
 * better usage
 *
 * Revision 1.10  2005/07/02  03:11:57  avi
 * report current volume to stdout
 *
 * Revision 1.9  2004/10/08  18:08:45  rsachs
 * Installed 'errm','errr','errw','getroot','setprog'. Replaced 'Get4dfpDi'
 *
 * Revision 1.8  1999/01/18  03:23:54  avi
 * eliminate #include <mri/mri.h>
 * initialize outroot to ""
 *
 * Revision 1.6  1998/12/03  00:28:02  avi
 * -d option
 *
 * Revision 1.4  1998/05/20  07:29:03  avi
 * new rec subroutines
 *
 * Revision 1.3  1998/05/20  07:18:43  avi
 * clean code
 * -w option
 *
 * Revision 1.2  1998/04/17  17:12:41  tscull
 * set debug to false
 *
 * Revision 1.1  1998/03/18  18:25:56  tscull
 * Initial revision
 *
 * Revision 1.3  1997/10/02  18:14:48  tscull
 * modified usage text to be more complete and easy to read
 *
 * Revision 1.2  1997/10/02  17:56:38  tscull
 * frequency to text more compact
 *
 * Revision 1.1  1997/09/30  21:00:19  tscull
 * Initial revision
 **/
/****************************************************************
  Description:	This program filters a 4dfp image volume
		by using the Gaussian filter.

  History:	Created by Tom Yang and Avi Snyder on 12/17/92. 
                Originally for ECAT images
		Modified by AZS on 10/25/95.
		Converted to 4dfp input by Tom Cull 9/30/97.
*****************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#include <math.h>
#include "nifti1.h"
#include "nifti1_io.h"
#include "znzlib.h"
#include "fslio.h"
#include "config.h"
/*
#include <endianio.h>
#include <Getifh.h>
#include <rec.h>
#include <conc.h>
*/
#define MAXL      256	
#define MAX_REC_LEN 1024
#define MAXL        256
#define CR 13            /* Decimal code of Carriage Return char */
#define LF 10            /* Decimal code of Line Feed char */
/***************************/
/*Variables used in FSL I/O*/
/***************************/   
    FSLIO *src;
    FSLIO *dest;
    short x_dim[MAXL], y_dim[MAXL], z_dim[MAXL], v_dim[MAXL], V_DIM;
    short X = 0, Y = 0, Z = 0, V = 0;
    short vv, t; 
    char filename[MAXL]; 
    char *buffer[MAXL];
    unsigned int direction = 0, bpp = 0;      
    double *vol;
    char listroot[MAXL][MAXL];
    char output_file[MAXL][MAXL];
    char input_file[MAXL][MAXL];
    int lLineCount;
    int ivoxel;
    int blen;
    int file, nframes;
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
/*************/
/* externals */
/*************/
extern int	npad_ (int *n, int *margin);									/* FORTRAN librms */
extern void	imgpad_   (float *imag, int *nx, int *ny, int *nz, float *imgp, int *nxp, int *nyp, int *nzp);	/* FORTRAN librms */
extern void	imgdap_   (float *imag, int *nx, int *ny, int *nz, float *imgp, int *nxp, int *nyp, int *nzp);	/* FORTRAN librms */
extern void	gauss3d   (float *imag, int *nx, int *ny, int *nz, float *cmppix, float *fhalf);		/* cgauss3d.c */
extern void	gauss3dd  (float *imag, int *nx, int *ny, int *nz, float *cmppix, float *fhalf);		/* cgauss3dd.c */
int nifti_lstread(FILE *input);
int write_nifti(char *hdr_file, char *outfile, float *fptr, int dimension, int zip_Flag, int nvols);
void setprog (char *program, char **argv) {
	char *ptr;

	if (!(ptr = strrchr (argv[0], '/'))) ptr = argv[0]; 
	else ptr++;
	strcpy (program, ptr);
}

void usage (char* program) {
	printf ("Usage:\t%s <.nii/.nii.gz/-list file.txt> f_half [outroot]\n", program);
	printf (" e.g.,\t%s pt349_study9to9 0.1\n", program);
	printf (" e.g.,\t%s p1234ho5 0.7 p1234ho5_g7\n", program);
	printf ("\toptions\n");
	printf ("\t-@<b|l>\toutput big or little endian (default input endian)\n");
	printf ("\t-w\t(wrap) suppress x and y padding\n");
	printf ("\t-d\tdifferentiate\n");
	printf ("N.B.:	f_half is half frequency in 1/cm\n");
	printf ("N.B.:	default output root is <inroot>_g<10*f_half>\n");
	printf ("N.B.:	FWHM*f_half = (2ln2/pi) = 0.4412712\n");
	printf ("N.B.:	list files must have file names in a column\n");
	printf ("N.B.:	user outroot specification not possible with conc files\n");
	exit (1);
}

static char rcsid[] = "$Id: gauss_nifti.c,v 1.2 2010/03/23 15:55:16 mtt24 Exp $";
int main (int argc, char **argv) {
/*	CONC_BLOCK	conc_block;			/* conc i/o control block */
	FILE 		*imgfp, *outfp, *fp;
/*	IFH		ifh;*/
	char 		imgroot[MAXL], imgfile[MAXL];
	char 		outroot[MAXL] = "", outfile[MAXL], trailer[MAXL];
	char            text_File[MAXL];
        int  		imgdim[4], isbig;
        float	 	voxdim[3];	
	float		cmppix[3], f0;
	float		*imgt, *imgp, *fptr;
	float 		*imgtbuffer;
	int		nx, ny, nz;
	int		nxp, nyp, nzp;
	int		margin, vdim;
	char		control = '\0';

/***********/
/* utility */
/***********/
	char 		command[MAXL], program[MAXL], *ptr;
	float		val;
	int		c, i, k;
	int		jndex;
/*********/
/* flags */
/*********/
	int		conc_flag = 0;
	int		debug = 0;
	int		status = 0;
	int		wrap_flag = 0;
	int		diff_flag = 0;
	int             zip_Flag = 1;
	int             list_Flag = 0;

	fprintf (stdout, "%s\n", rcsid);
	setprog (program, argv);
/************************/
/* process command line */
/************************/
	for (k = 0, i = 1; i < argc; i++) {

		if (!strncmp("-list",argv[i],5)){
                strcpy(text_File,argv[i+1]);
                list_Flag = 1; k++; 
                }

		if (*argv[i] == '-') {
			strcpy (command, argv[i]);
			ptr = command;
			while (c = *ptr++) switch (c) {
				case 'w': wrap_flag++;		break;
				case 'd': diff_flag++;		break;
				case '@': control = *ptr++;	*ptr = '\0'; break;
			}
		}
		else switch (k) {
			case 0:	strcpy (imgroot, argv[i]);
				/*conc_flag = (strstr (argv[i], ".conc") == argv[i] + strlen (imgroot));*/
								k++; break;
			case 1:	if (list_Flag) f0 = atof (argv[i+1]);	
				else f0 = atof (argv[i]); k++; break;
			case 2: if (list_Flag) k++;
				else strcpy (outroot, argv[i]);	k++; break;
		}	
	}
	if (k < 2) usage (program);

/***************************/
/* compute outroot trailer */
/***************************/
	sprintf (trailer, "%sg%d", (diff_flag) ? "d" : "", (int) (10.0*f0 + 0.5));

/*******************************************/
/* get nifti dimensions and open read/write */
/*******************************************/
    if (list_Flag == 1){
	printf("List_Flag = %d\n", list_Flag);
	printf("text_File = %s\n", text_File);
	fp = fopen(text_File,"rb");
	nifti_lstread(fp);
    } 
    else if (list_Flag == 0){
	    lLineCount = 1; 
	    file = 0;
    }
	
   for (file = 0; file < lLineCount ; file++){

        	if (list_Flag == 1) {
		sprintf(imgroot,"%s",input_file[file]);
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
		strcpy(output_file[file], filename);
		
	

	src=FslOpen(FslMakeBaseName(filename),"r");
    
  	FslGetDim(src,&x_dim[file],&y_dim[file],&z_dim[file],&v_dim[file]);
	
      	bpp = FslGetDataType(src, &t) / 8;
      	V=v_dim[file]; X=x_dim[file]; Y=y_dim[file]; Z=z_dim[file];
     	
	if (list_Flag == 1){
	nframes += v_dim[file];
	}

  	
   }  /*end of for loop for list_nifti*/
	
/***********************************************/
/*Putting data from seperate files in outbuffer*/
/***********************************************/
	
	
        /*
	if (conc_flag) {
		conc_init (&conc_block, program);
		conc_open (&conc_block, imgroot);
		strcpy (imgfile, conc_block.lstfile);
		for (k = 0; k < 4; k++) imgdim[k] = conc_block.imgdim[k];
		for (k = 0; k < 3; k++) voxdim[k] = conc_block.voxdim[k];
		isbig = conc_block.isbig;
		strcpy (outfile, conc_block.outfile);
	} else {
		sprintf (imgfile, "%s.4dfp.img", imgroot);
		if (Getifh (imgfile, &ifh)) errr (program, imgfile);
		for (k = 0; k < 4; k++) imgdim[k] = ifh.matrix_size[k];
		for (k = 0; k < 3; k++) voxdim[k] = ifh.scaling_factor[k];
		isbig = strcmp (ifh.imagedata_byte_order, "littleendian");
		if (!(imgfp = fopen (imgfile, "rb"))) errr (program, imgfile);
		if (!strlen (outroot)) sprintf (outroot, "%s_%s", imgroot, trailer);
		sprintf (outfile, "%s.4dfp.img", outroot);
		if (!(outfp = fopen (outfile, "wb"))) errw (program, outfile);
	}
	if (!control) control = (isbig) ? 'b' : 'l';
	if (conc_flag) {conc_newe (&conc_block, trailer, control); strcpy (outfile, conc_block.outfile);}
	printf ("Reading: %s\n", imgfile);
	printf ("Writing: %s\n", outfile);*/
	voxdim[0] = (float)(src->niftiptr->pixdim[1]); /*printf("This is voxdim[0]: %f\n", voxdim[0]);*/ 
	voxdim[1] = (float)(src->niftiptr->pixdim[2]); /*printf("This is voxdim[1]: %f\n", voxdim[1]);*/
	voxdim[2] = (float)(src->niftiptr->pixdim[3]); /*printf("This is voxdim[2]: %f\n", voxdim[2]);*/
	

	nx = X;
	ny = Y;
	nz = Z;

	vdim = nx * ny * nz;
	if (list_Flag == 1){
	V = nframes;}

	printf("X = %d, Y = %d, Z = %d, V = %d\n", X, Y, Z, V);
	imgdim[0] = X; imgdim[1] = Y; imgdim[2] = Z; imgdim[3] = V;

	for (k = 0; k < 3; k++) cmppix[k] = voxdim[k] / 10.0;
	
/********************/
/* allocate buffers */
/********************/
	if (wrap_flag) {
		nxp = nx;
		nyp = ny;
	} else {
		val = (0.5 + (2.0 * 0.1874 / (cmppix[0] * f0))); margin = val; nxp = npad_ (&nx, &margin);
		val = (0.5 + (2.0 * 0.1874 / (cmppix[1] * f0))); margin = val; nyp = npad_ (&ny, &margin);
	}
	val = (0.5 + (4.0 * 0.1874 / (cmppix[2] * f0))); margin = val; nzp = npad_ (&nz, &margin);
	printf ("image dimensions %d %d %d padded to %d %d %d\n", nx, ny, nz, nxp, nyp, nzp);

	if (!(imgt = (float *) malloc (vdim * sizeof (float)))
	||  !(imgp = (float *) calloc (nxp * nyp * nzp, sizeof (float)))) {fprintf (stderr, "%s: could not allocate memory\n", program); exit (-1);}

	/*
	imgt = (float *) malloc (vdim * sizeof (float));
	imgp = (float *) calloc (nxp * nyp * nzp, sizeof (float));
	
	if (!imgp || !imgt) {fprintf (stderr, "%s: could not allocate memory for buffer\n", program); exit (-1);}*/

	printf ("processing volume");

	if (list_Flag == 0){ 
	lLineCount = 1; 
	file = 0;
	}
		
	
   for (file = 0; file < lLineCount; file++){

	
	if (list_Flag == 1) {
	src=FslOpen(FslMakeBaseName(input_file[file]),"r");
	}
	else if (list_Flag == 0){
	src=FslOpen(FslMakeBaseName(filename),"r");
	}
	if (!(buffer[file] = malloc(x_dim[file]*y_dim[file]*z_dim[file]*v_dim[file]*bpp))) {fprintf (stderr, "%s: could not allocate memory for buffer\n", program); exit (-1);}
	/*buffer[file] = malloc(x_dim[file]*y_dim[file]*z_dim[file]*v_dim[file]*bpp);*/
  	FslReadVolumes(src, buffer[file], v_dim[file]);
	FslClose(src);
	if (!(imgtbuffer =  (float *) calloc (vdim*v_dim[file], sizeof (float)))) {fprintf (stderr, "%s: could not allocate memory for imgtbuffer\n", program); exit (-1);}
	if (!(vol = (double *) calloc (vdim*v_dim[file], sizeof (double)))) {fprintf (stderr, "%s: could not allocate memory for vol\n", program); exit (-1);}	
	/*vol = (double *) calloc (vdim*v_dim[file], sizeof (double));*/
  	convertBufferToScaledDouble(vol,buffer[file],X*Y*Z*v_dim[file],1.0,0.0,src->niftiptr->datatype);
  
	for (k = 0; k < v_dim[file]; k++) {
	
	printf(" %d", k + 1 + file*v_dim[file]); fflush (stdout);
	    	
		for (jndex = 0; jndex < vdim; jndex++){
		imgt[jndex] = (float) vol[jndex + k*vdim];
		}
                    
                
		 	
		/*   
		if (conc_flag) {
			conc_read_vol (&conc_block, imgt);
		} else {
			if (eread (imgt, vdim, isbig, imgfp)) errr (program, imgfile);
		}*/
		imgpad_ (imgt, &nx, &ny, &nz, imgp, &nxp, &nyp, &nzp);
		if (diff_flag) {
			gauss3dd (imgp, &nxp, &nyp, &nzp, cmppix, &f0);
		
		} else {
			gauss3d  (imgp, &nxp, &nyp, &nzp, cmppix, &f0);
		}
		imgdap_ (imgt, &nx, &ny, &nz, imgp, &nxp, &nyp, &nzp);

		for (jndex = 0; jndex < vdim; jndex++){
		imgtbuffer[jndex  + k*vdim] = imgt[jndex];
		}
	}

		if (list_Flag == 1) {
		
		sprintf (listroot[file], "%s_%s", output_file[file], trailer);
		printf ("\nWriting: %s.nii.gz\n", listroot[file]);
		V_DIM = v_dim[file];
		fptr = imgtbuffer;
		write_nifti(input_file[file], listroot[file], fptr, vdim*V_DIM, zip_Flag, V_DIM);
		free (vol);
		free (imgtbuffer);
		
		}
		else {

		fptr = imgtbuffer; 
		sprintf (outroot, "%s_%s", filename, trailer);
		strcpy (outfile, outroot);
		printf ("\nWriting: %s.nii.gz\n", outfile);
		write_nifti(imgroot, outfile, fptr, vdim*V, zip_Flag, V);
		printf ("\n");  fflush (stdout);
	   	free (vol);
		free (imgtbuffer);
		free (buffer[file]);
		}
		
   
    }



/*		if (conc_flag) {
			conc_write_vol (&conc_block, imgt);
		} else {
			if (ewrite (imgt, vdim, control, outfp)) errw (program, outfile);
		}*/
	
	

/***************/
/* ifh hdr rec */
/***************/
/*
	if (conc_flag) {
		status |= conc_ifh_hdr_rec (&conc_block, argc, argv, rcsid);
		conc_free (&conc_block);
	} else {
		if (fclose (imgfp)) errr (program, imgfile);
		if (fclose (outfp)) errw (program, outfile);
		if (Writeifh (program, outfile, &ifh, control)) errw (program, outroot);
		sprintf (command, "ifh2hdr %s", outroot);
		status |= system (command);
	}
	startrece (outfile, argc, argv, rcsid, control);
	catrec (imgfile);
	endrec ();
*/	
	free (imgp);
	free (imgt);
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
