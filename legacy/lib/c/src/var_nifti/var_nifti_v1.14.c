/*$Header: /data/petsun4/data1/src_solaris/var_4dfp/RCS/var_4dfp.c,v 1.13 2006/09/24 02:20:47 avi Exp $*/
/*$Log: var_4dfp.c,v $
 * Revision 1.13  2006/09/24  02:20:47  avi
 * Solaris 10
 *
 * Revision 1.12  2006/08/07  03:35:20  avi
 * safe 1.e-37 test
 *
 * Revision 1.11  2005/08/21  02:10:47  avi
 * output unbiased (1/(n-1)) variance estimate
 * mark_undefined and option -E -N -Z
 *
 * Revision 1.10  2005/08/20  03:04:33  avi
 * read/write conc
 *
 * Revision 1.9  2004/11/03  05:33:38  avi
 * eliminate dependence of lmri
 * frames to count format
 * eliminate support for pre-ifh 4dfp
 *
 * Revision 1.8  2003/06/28  02:53:40  avi
 * -z option
 *
 * Revision 1.7  2000/04/25  06:17:43  avi
 * -m (remove mean volume) mode
 *
 * Revision 1.6  2000/04/25  05:09:31  avi
 * eliminate FORTRAN
 * allocate one frame instead of whole stack
 *
 * Revision 1.5  1997/05/23  03:56:17  yang
 * new rec macros
 * Revision 1.4  1997/04/28  21:10:15  yang
 * Working Solaris version.
 * Revision 1.3  1996/10/25  02:41:40  avi
 * add -c switch
 * Revision 1.2  1996/08/05  22:29:50  avi
 * correct output in old (pre ifh) mode
 * Revision 1.1  1996/08/05  02:13:36  avi
 * Initial revision
 **/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include <assert.h>
/*
#include <sunmath.h>
#include <Getifh.h>
#include <endianio.h>
#include <rec.h>
#include <conc.h>		/* /data/petsun4/data1/src_solaris/actmapf_4dfp */
#include "nifti1.h"
#include "nifti1_io.h"
#include "znzlib.h"
#include "fslio.h"
#include "config.h"
#ifndef _FEATURES_H		/* defined by math.h in Linux */
	#include <ieeefp.h>	/* isnormal() */
#endif
#define MAXL		256
#define MAXF		16384		/* maximum npts coded in format */
#define MAX(a,b)	(a>b? a:b)
#define MIN(a,b)	(a<b? a:b)
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
    char filename[MAXL], text_File[MAXL], txtroot[MAXL]; 
    char *buffer[MAXL], *outbuffer, *sbuffer;
    unsigned int direction = 0, bpp = 0;      
    double *vol;
    char listroot[MAXL][MAXL];
    char output_file[MAXL][MAXL];
    char input_file[MAXL][MAXL];
    int lLineCount;
    int ivoxel;
    int blen, clen;
    int ifile;
    int nframes = 0;
/*************/
/* externals */
/*************/
int	expandf (char *string, int len);		/* expandf.c */

/********************/
/* global variables */
/********************/
static char rcsid[] = "$Id: var_nifti.c,v 1.13 2006/09/24 02:20:47 avi Exp $";
static char	program[MAXL];
static int	debug = 0;

float **calloc_float2 (int n1, int n2) {
	int	i;
	float	**a;

	if (!(a = (float **) malloc (n1 * sizeof (float *)))) printf ("%s: could not allocate memory\n", program);
	if (!(a[0] = (float *) calloc (n1 * n2, sizeof (float)))) printf ("%s: could not allocate memory\n", program);
	for (i = 1; i < n1; i++) a[i] = a[0] + i*n2;
	return a;
}

void free_float2 (float **a) {
	free (a[0]);
	free (a);
}

void mark_undefined (float *imgt, int dimension, float *imgs, int NaN_flag) {
	int		i;

	for (i = 0; i < dimension; i++) if (!imgs[i]) switch (NaN_flag) {
		case 'Z': imgt[i] = 0.0;			break;
		case 'E': imgt[i] = 1.e-37;			break;
		case 'N': imgt[i] = 0.0/0.0;			break;
		default:					break;
	}
}

int main (int argc, char *argv[]) {
	FILE		*imgfp, *outfp, *fp;
	char		imgroot[MAXL], imgfile[MAXL];
	char		outroot[MAXL], outfile[MAXL], ifhfile[MAXL];
/*	CONC_BLOCK	conc_block;		/* conc i/o control block */
/*	IFH		ifh;

/*********/
/* flags */
/*********/
	int		opr = 'v';		/* 'v' : variance; 's' : sd1; 'm' : remove mean */
	int		conc_flag = 0;
	int		NaN_flag = 'E';		/* 'E' 1.e-37; 'Z' 0.0; 'N' NaN; */
	int		status = 0;
	int             list_Flag = 0;
	int 		zip_Flag = 1;

/***********/
/* utility */
/***********/
	double		q;
	int		c, i, j, k;
	char		*ptr, command[MAXL];

/*******************/
/* imge processing */
/*******************/
	char		format[MAXF] = "";		/* pattern of frames to count */
	float		*fptr;				/* general float pointer */
	float		*imgt;				/* input 4dfp volume */
	float		*imgs;				/* mask of nonzero (sampled) voxels */
	float		*imgv;				/* variance over all frames */
	float		**imgu;				/* multivolume average over all frames */
	float		factor = 1.0;			/* multiplier for output image values */
	int		imgdim[4], dimension, nf_total, nf_func, nf_anat = 0;
	int		nfile, ifile;
	int		isbig;
	char		control = '\0';
	float *splitimgt;
	fprintf (stdout, "%s\n", rcsid);
	if (ptr = strrchr (argv[0], '/')) ptr++; else ptr = argv[0];
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

		
		else if (!strncmp("-s",argv[i],2)) opr = 's';

		if (*argv[i] == '-') {
			strcpy (command, argv[i]); ptr = command;
			while (c = *ptr++) switch (c) {
				case 'd': debug++;				break;
				case 'm': case 'z': opr = c;			break;
				case 'N': case 'Z': case 'E': NaN_flag = c;	break;
				case '@': control = *ptr++;			*ptr = '\0'; break;
				case 'f': strcpy (format, ptr);			*ptr = '\0'; break;
				case 'n': nf_anat = atoi (ptr);			*ptr = '\0'; break;
				case 'c': factor = atof (ptr);			*ptr = '\0'; break;
			}
		} else switch (k) {
		 	case 0: strcpy (filename, argv[i]);
				/*conc_flag = (strstr (argv[i], ".conc") == argv[i] + strlen (imgroot));*/
										k++; break;
		}	
	}
	if (k < 1) {
		printf ("Usage:\t%s <(nii|nii.gz|-list .txt) input>\n", program);
		printf (" e.g.,\t%s -sn3 -c10 test_b1_rmsp_dbnd\n", program);
		printf ("\toption\n");
		printf ("\t-d\tdebug mode\n");
		printf ("\t-m\tremove mean volume from stack\n");
		printf ("\t-s\tcompute s.d. about mean\n");
		printf ("\t-v\tcompute variance about mean (default operation)\n");
		printf ("\t-z\toutput logical and of all nonzero defined voxels\n");
		printf ("\t-n<int>\tspecify number of pre-functional frames per run (default = 0)\n");
		printf ("\t-f<str>\tspecify frames to count format, e.g., \"4x120+4x76+\"\n");
		printf ("\t-c<flt>\tscale output image values by specified factor\n");
		printf ("\t-N\toutput undefined voxels as NaN\n");
		printf ("\t-Z\toutput undefined voxels as 0\n");
		printf ("\t-E\toutput undefined voxels as 1.e-37 (default)\n");
		printf ("\t-@<b|l>\toutput big or little endian (default input endian)\n");
		printf ("N.B.:\tinput list files must have extension \"txt\"\n");
		printf ("N.B.:\tvoxelwise mean is individually computed over each run in conc\n");
		printf ("N.B.:\t-f option overrides -n\n");
		exit (1);
	}

/*****************************/
/* get nifti image dimensions */
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
		strcpy(filename,input_file[ifile]);
		}
   

		blen = strlen(filename);
		
		if (strcmp(filename + blen-4,".nii") == 0) { 
		strcpy(imgroot, filename);
		imgroot[blen-4]='\0';
		}
		else if (strcmp(filename + blen-7,".nii.gz") == 0) { 
		strcpy(imgroot, filename);
		imgroot[blen-7]='\0';
		}

		
		else strcpy(imgroot, filename);
	
		
		if (list_Flag == 1)
		strcpy(output_file[ifile], imgroot);

	src=FslOpen(FslMakeBaseName(filename),"r");
  	FslGetDim(src,&x_dim[ifile],&y_dim[ifile],&z_dim[ifile],&v_dim[ifile]);
      	bpp = FslGetDataType(src, &t) / 8;
	V=v_dim[ifile]; X=x_dim[ifile]; Y=y_dim[ifile]; Z=z_dim[ifile];
	if (list_Flag == 1){ 
	
	nframes += v_dim[ifile];
	
   	buffer[ifile] = malloc(x_dim[ifile]*y_dim[ifile]*z_dim[ifile]*v_dim[ifile]*bpp);
  	FslReadVolumes(src, buffer[ifile], v_dim[ifile]);
	FslClose(src);
	}

	
		
  	
   }  /*end of for loop for list_nifti*/


/***********************************************/
/*Putting data from seperate files in outbuffer*/
/***********************************************/
	if (list_Flag == 1){
	printf("Reading list file: %s \n", text_File);
	V = nframes;
	outbuffer = malloc(X * Y * Z * V * bpp);
	vv=0;
	for (ifile = 0; ifile < lLineCount; ifile++){
 	memcpy(outbuffer+X*Y*Z*vv*bpp,buffer[ifile],X*Y*Z*v_dim[ifile]*bpp);
      	vv+=v_dim[ifile];
	}
	vol = (double *) calloc (X*Y*Z*V, sizeof (double));
  	convertBufferToScaledDouble(vol,outbuffer,X*Y*Z*V,1.0,0.0,src->niftiptr->datatype);
	}
	
	else if (list_Flag == 0){
	sbuffer = (char *)calloc(X*Y*Z*V*bpp, sizeof (char));
  	FslReadVolumes(src, sbuffer, V);
	vol = (double *) calloc (X*Y*Z*V, sizeof (double));
  	convertBufferToScaledDouble(vol,sbuffer,X*Y*Z*V,1.0,0.0,src->niftiptr->datatype);
	}

	imgdim[0] = X; imgdim[1] = Y; imgdim[2] = Z; imgdim[3] = V;
/*
	if (conc_flag) {
		conc_init (&conc_block, program);
		conc_open (&conc_block, imgroot);
		strcpy (imgfile, conc_block.lstfile);
		for (k = 0; k < 4; k++) imgdim[k] = conc_block.imgdim[k];
		dimension = conc_block.vdim;
		nfile = conc_block.rnfile;
		isbig = conc_block.isbig;
	} else {
		sprintf (imgfile, "%s.4dfp.img", imgroot);
		if (Getifh (imgfile, &ifh)) errr (program, imgfile);
		for (k = 0; k < 4; k++) imgdim[k] = ifh.matrix_size[k];
		dimension = imgdim[0] * imgdim[1] * imgdim[2];
		nfile = 1;
		if (!(imgfp = fopen (imgfile, "rb"))) errr (program, imgfile);
		isbig = strcmp (ifh.imagedata_byte_order, "littleendian");
	}*/
	if (list_Flag == 1) nfile = lLineCount;
	else if (list_Flag == 0) {
	nfile = 1;
	sprintf (imgfile, "%s.nii", imgroot);
	}
	dimension = imgdim[0] * imgdim[1] * imgdim[2];
	if (!control) control = (isbig) ? 'b' : 'l';


/***********************************/
/* set up frames to count (format) */
/***********************************/
	if (strlen (format)) {
		if (k = expandf (format, MAXF)) exit (k);
		if ((nf_total = strlen (format)) > imgdim[3]) {
			fprintf (stderr, "format codes for more frames (%d) than data (%d)\n", nf_total, imgdim[3]);
			exit (-1);
		}
	} else {
		nf_total = imgdim[3];
		printf ("var_nifti: nf_anat=%d\n", nf_anat);
		for (k = ifile = 0; ifile < nfile; ifile++) {
			if (list_Flag == 1) nf_func = v_dim[ifile] - nf_anat;
			else if (list_Flag == 0) nf_func = imgdim[3] - nf_anat;
			if (nf_func < 0) {
				fprintf (stderr, "%s: %s has more skip than total frames\n", program,
				(list_Flag) ? input_file[ifile] : imgfile);
			}
			for (j = 0; j < nf_anat; j++) format[k++] = 'x';
			for (j = 0; j < nf_func; j++) format[k++] = '+';
		}
		assert (k == imgdim[3]);
	}
	printf ("%s\n", format);
	for (nf_func = j = 0; j < nf_total; j++) if (format[j] == '+') nf_func++;
	printf ("frames total=%d counted=%d skipped=%d\n", nf_total, nf_func, nf_total - nf_func);

	if (!(imgt = (float *) malloc (dimension * sizeof (float)))
	||  !(imgs = (float *) malloc (dimension * sizeof (float)))
	||  !(imgv = (float *) calloc (dimension,  sizeof (float)))) printf ("%s cannot allocate memory\n", program);
        
	imgu = calloc_float2 (nfile, dimension);

/**************/
/* initialize */
/**************/
	for (i = 0; i < dimension; i++) imgs[i] = 1.0;
	
/********************************/
/* compute mean and logical and */
/********************************/
	for (ifile = 0; ifile < nfile; ifile++) {
		if (list_Flag == 1) printf ("Reading: %s", input_file[ifile]);
		else if (list_Flag == 0) printf ("Reading: %s", imgfile);
		/*printf ("Reading: %s", (list_Flag) ? input_file[ifile] : imgfile);*/
		printf ("\t%d frames\n", (list_Flag) ? v_dim[ifile] : imgdim[3]);
		for (k = j = 0; j < ((list_Flag) ? v_dim[ifile] : imgdim[3]); j++) {
		    
		     if (list_Flag == 1){
			for (i = 0; i < dimension; i++){
			imgt[i] = (float) vol[i + j*dimension + ifile*v_dim[ifile]*dimension];
			}
		     }

		     else if (list_Flag == 0){
			for (i = 0; i < dimension; i++){
			imgt[i] = (float) vol[i + j*dimension];
			}
		     }
			/*conc_read_vol (&conc_block, imgt);
			} else {
				if (eread (imgt, dimension, isbig, imgfp)) errr (program, imgfile);
			}*/
			if (format[j] != '+') continue;
			k++;		/* single run functional frame count */
			for (i = 0; i < dimension; i++) {
				if (imgt[i] == (float) 1.e-37 || isnan (imgt[i]) || imgt[i] == 0.0) imgs[i] = 0.;
				imgu[ifile][i] += imgt[i];
				
			}
		}
		for (i = 0; i < dimension; i++) imgu[ifile][i] /= k;
	}
	
/********************/
/* compute variance */
/********************/
	/*if (!conc_flag) rewind (imgfp);*/
	for (ifile = 0; ifile < nfile; ifile++) {
		for (j = 0; j < ((list_Flag) ? v_dim[ifile] : imgdim[3]); j++) {
		    
		    if (list_Flag == 1) {
			for (i = 0; i < dimension; i++){
			imgt[i] = (float) vol[i + j*dimension + ifile*v_dim[ifile]*dimension];
			}
		    }

		     else if (list_Flag == 0){
			for (i = 0; i < dimension; i++){
			imgt[i] = (float) vol[i + j*dimension];
			}
		     }
			/*if (conc_flag) {
				conc_read_vol (&conc_block, imgt);
			} else {
				if (eread (imgt, dimension, isbig, imgfp)) errr (program, imgfile);
			}*/
			if (format[j] != '+') continue;
			for (i = 0; i < dimension; i++) {
				q = imgt[i] - imgu[ifile][i];
				imgv[i] += q*q;
			}
		}
	}
	for (i = 0; i < dimension; i++) imgv[i] /= (nf_func - nfile);

	switch (opr) {
	case 'z':
		if (list_Flag == 1) sprintf (outroot, "%s_sam", txtroot);
		else if (list_Flag == 0) sprintf (outroot, "%s_sam", imgroot);
		fptr = imgs;
		break;
	case 'm':
		if (list_Flag == 0) sprintf (outroot, "%s_uout", imgroot);
		break;
	case 's':
		if (list_Flag == 1) sprintf (outroot, "%s_sd1", txtroot);
		else if (list_Flag == 0) sprintf (outroot, "%s_sd1", imgroot);
		for (k = 0; k < dimension; k++) imgv[k] = factor * (sqrt (imgv[k]));
		/*mark_undefined (imgv, dimension, imgs, NaN_flag);*/
		fptr = imgv;
		break;
	case 'v': default:
		if (list_Flag == 1) sprintf (outroot, "%s_var", txtroot);
		else if (list_Flag == 0) sprintf (outroot, "%s_var", imgroot);
		for (k = 0; k < dimension; k++) imgv[k] *= factor;
		mark_undefined (imgv, dimension, imgs, NaN_flag);
		fptr = imgv;
		break;
	}
				
/****************/
/* write output */
/****************/
	switch (opr) {
	case 'm':
		/*
		if (conc_flag) {
			conc_newe (&conc_block, "uout", control);
			sprintf (outfile, "%s.conc", outroot);
			printf ("Writing: %s\n", outfile);
		} else {
			sprintf (outfile, "%s.4dfp.img", outroot);
			if (!(outfp = fopen (outfile, "wb"))) errw (program, outfile);
			rewind (imgfp);
		}*/
		/*if (list_Flag == 0){
		splitimgt = (float *) calloc (dimension*V, sizeof (float));
		}*/

		
		for (ifile = 0; ifile < nfile; ifile++) {

			if (list_Flag == 1){
			splitimgt = (float *) calloc (dimension*v_dim[ifile], sizeof (float));
			}

			else if (list_Flag == 0){
			splitimgt = (float *) calloc (dimension*V, sizeof (float));
			}
			sprintf (listroot[ifile], "%s_%s", output_file[ifile], "uout");
			printf ("Writing: %s.nii", (list_Flag) ? listroot[ifile] : outroot);
			printf ("\t%d frames\n", (list_Flag) ? v_dim[ifile] : imgdim[3]);
			for (j = 0; j < ((list_Flag) ? v_dim[ifile] : imgdim[3]); j++) {
				

			if (list_Flag == 1) {
				
				for (i = 0; i < dimension; i++){
				imgt[i] = (float) vol[i + j*dimension + ifile*v_dim[ifile]*dimension];
				}
		    	}

		     	else if (list_Flag == 0){
				for (i = 0; i < dimension; i++){
				imgt[i] = (float) vol[i + j*dimension];
				}
		     	}
				/*if (conc_flag) {
					conc_read_vol (&conc_block, imgt);
				} else {
					if (eread (imgt, dimension, isbig, imgfp)) errr (program, imgfile);
				}*/
			for (i = 0; i < dimension; i++) {imgt[i] -= imgu[ifile][i]; imgt[i] *= factor;}
			mark_undefined (imgt, dimension, imgs, NaN_flag);

			
			for (i = 0; i < dimension; i++){
			splitimgt[i + j*dimension] = imgt[i];}
			
			}/*end of j loop*/

		fptr = splitimgt;

		if (list_Flag == 0){
		write_nifti(imgroot, outroot, fptr, dimension*V, zip_Flag, V);}
		else if (list_Flag == 1){
	     	write_nifti(input_file[ifile], listroot[ifile], fptr, dimension*v_dim[ifile], zip_Flag, v_dim[ifile]);}
		free (splitimgt);
		}/*end of ifile loop*/			
		

		
			
			/*	if (conc_flag) {
					conc_write_vol (&conc_block, imgt);
				} else {
					if (ewrite (imgt, dimension, control, outfp)) errw (program, outfile);
				}*/
			
		
		/*if (!conc_flag) if (fclose (outfp)) errw (program, outfile);*/
		break;
	case 'z': case 'v': case 's':
		imgdim[3] = 1;
		sprintf (outfile, "%s.nii", outroot);
		printf ("Writing: %s\n", outfile);
		write_nifti(imgroot, outfile, fptr, dimension, zip_Flag, imgdim[3]);
		/*if (!(outfp = fopen (outfile, "wb"))) errw (program, outfile);
		if (ewrite (fptr, dimension, control, outfp)) errw (program, outfile);
		if (fclose (outfp)) errw (program, outfile);*/
		break;
	}

/***************/
/* ifh and hdr */
/***************/
/*	if (opr == 'm' && conc_flag) {
		conc_ifh_hdr_rec (&conc_block, argc, argv, rcsid);
	} else {
		if (conc_flag) {
			writeifhmce (program, outfile, imgdim,
				conc_block.voxdim, conc_block.orient, conc_block.mmppix, conc_block.center, control);
		} else {
			writeifhmce (program, outfile, imgdim,
				ifh.scaling_factor, ifh.orientation, ifh.mmppix, ifh.center, control);
		}
		sprintf (command, "ifh2hdr %s", outroot); status |= system (command);
	}

/*******/
/* rec */
/*******/
/*	startrece (outfile, argc, argv, rcsid, control);
	sprintf (command, "Output scaled by %.4f\n", factor); printrec (command);
	if (conc_flag) {
		for (ifile = 0; ifile < nfile; ifile++) catrec (conc_block.imgfile0[ifile]);
	} else {
		catrec (imgfile);
	}
	endrec ();

/*************/
/* close i/o */
/*************/
/*	if (conc_flag) {
		conc_free (&conc_block);
	} else {
		if (fclose (imgfp)) errr (program, imgfile);
	}
*/
	free (imgt); free (imgv); free (imgs);
	free_float2 (imgu);
	free (sbuffer);
	free (outbuffer);
	free (vol);
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
