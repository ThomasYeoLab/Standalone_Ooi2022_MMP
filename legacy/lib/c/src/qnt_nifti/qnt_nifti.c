/*$Header: /autofs/space/nexus_001/users/nexus-tools/cvsrepository/nifti_tools/qnt_nifti/qnt_nifti.c,v 1.1 2008/08/10 20:33:23 mtt24 Exp $*/
/*$Log: qnt_nifti.c,v $
/*Revision 1.1  2008/08/10 20:33:23  mtt24
/*revision one
/*
 * Revision 1.14  2006/09/25  03:22:40  avi
 * Solaris 10
 *
 * Revision 1.13  2006/08/07  03:30:35  avi
 * safe 1.e-37 test
 *
 * Revision 1.12  2006/05/04  02:17:19  avi
 * -W does not imply -D
 *
 * Revision 1.11  2006/05/04  01:46:49  avi
 * option -W (interpret mask a weights)
 *
 * Revision 1.10  2005/09/19  23:22:25  avi
 * options -D -d -f
 *
 * Revision 1.9  2005/09/16  03:43:29  avi
 * conc capability
 *
 * Revision 1.8  2005/09/16  01:37:33  avi
 * separate image and mask operations in preparation for conc capability
 *
 * Revision 1.7  2005/08/01  19:46:07  jon
 * Change total to type double to avoid precision problems.
 *
 * Revision 1.6  2004/09/22  05:51:09  avi
 * use get_4dfp_dimo_quiet ()
 *
 * Revision 1.5  2004/09/21  21:24:24  rsachs
 * Installed 'errm','errr','errw','setprog'. Replaced 'Get4dfpDimN' with 'get_4dfp_dimo'.
 *
 * Revision 1.4  2004/05/26  23:56:01  avi
 * -v option
 *
 * Revision 1.3  2000/04/22  03:18:08  avi
 * time series mode
 *
 * Revision 1.2  2000/04/07  15:18:40  jon
 * Updated to correct file reading.
 *
 * Revision 1.1  2000/03/30  17:34:01  jon
 * Initial revision
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include "nifti1.h"
#include "nifti1_io.h"
#include "znzlib.h"
#include "fslio.h"
#include "config.h"
#ifndef _FEATURES_H		/* defined by math.h in Linux */
/*	#include <ieeefp.h>	*//* isnormal() */
#endif
#define MAXF	16384		/* maximum number of frames */
#define MAXL      256	
#define MAX_REC_LEN 1024
#define MAXL        256
#define CR 13            /* Decimal code of Carriage Return char */
#define LF 10            /* Decimal code of Line Feed char */
/***************************/
/*Variables used in FSL I/O*/
/***************************/   
    FSLIO *src, *msk;
    FSLIO *dest;
    short x_dim[MAXL], y_dim[MAXL], z_dim[MAXL], v_dim[MAXL], V_DIM;
    short x_dimmsk, y_dimmsk, z_dimmsk, v_dimmsk;
    short X = 0, Y = 0, Z = 0, V = 0;
    short vv, t; 
    char filename[MAXL]; 
    char *buffer[MAXL], *mskbuffer;
    unsigned int direction = 0, bpp = 0, mskbpp = 0;      
    double *vol, *mskvol;
    /*float *splitimgt;*/
    char listroot[MAXL][MAXL];
    char output_file[MAXL][MAXL];
    char input_file[MAXL][MAXL];
    int lLineCount;
    int ivoxel;
    int blen, msklen;
    int ifile, filenum;

/*************/
/* externals */
/*************/
extern int expandf (char *format, int bufsiz);		/* expandf.c */

void setprog (char *program, char **argv) {
	char *ptr;

	if (!(ptr = strrchr (argv[0], '/'))) ptr = argv[0]; 
	else ptr++;
	strcpy (program, ptr);
}

void getrange (char *string, float *minval, float *maxval) {
        char	*str;

	str = strstr (string, "to");
	if (str) {
		*str = '\0';
		*minval = atof (string);
		*maxval = atof (str + 2);
	} else {
		*minval = 0.0;
		*maxval = atof (string);
	}
}

/********************/
/* global variables */
/********************/
char	program[MAXL];
static char rcsid[]= "$Id: qnt_nifti.c,v 1.1 2008/08/10 20:33:23 mtt24 Exp $";

void write_command_line (FILE *outfp, int argc, char *argv[]) {
	int		i;

	fprintf (outfp, "#%s", program);
	for (i = 1; i < argc; i++) fprintf (outfp, " %s", argv[i]);
	fprintf (outfp, "\n");
	fprintf (outfp, "#%s\n", rcsid);
}

static void usage (char *program) {
	printf ("%s\n", rcsid);
	printf ("Usage:\t%s <nii/nii.gz/-list file.txt> <nifti mask>\n", program);
	printf (" e.g.:\t%s -t23.2 va1234_mpr mask\n", program);
	printf ("\toption\n");
	printf ("\t-s\ttime series mode\n");
	printf ("\t-d\tinclude backwards differences (differentiated signal) in output\n");
	printf ("\t-D\tcount only defined <image> voxels (see note below)\n");
	printf ("\t-W\tinterpret <mask> as spatial weights (negative values allowed)\n");
	printf ("\t-v<flt>[to<flt>] count only <image> voxels within specified range\n");
	printf ("\t-f<str>\tspecify frames to count format, e.g., \"4x120+4x76+\"\n");
	printf ("\t-p<flt>\tspecify mask threshold as percent of <mask> max\n");
	printf ("\t-t<flt>\tspecify absolute <mask> threshold (default = 0.0)\n");
	printf ("\t-c<flt>\tscale output mean values by specified constant (default = 1.0)\n");
	printf ("N.B.:\tonly the first frame of <mask> is used\n");
	printf ("N.B.:\t<image> and <mask> may be the same\n");
	printf ("N.B.:\tlist files must have extension \"txt\"\n");
	printf ("N.B.:\tdefined means not 0.0 and not NaN and not 1.e-37 and finite\n");
	printf ("N.B.:\t-d requires -f and implies -s\n");
	printf ("N.B.:\t-W disables mask threshold testing\n");
	exit (1);
}

int main (int argc, char *argv[]) {
/*************/
/* image I/O */
/*************/
/*	CONC_BLOCK	conc_block;			/* conc i/o control block */
	FILE            *imgfp, *mskfp, *fp;
	char            imgroot[MAXL], imgfile[MAXL], mskroot[MAXL], mskfile[MAXL];
	char            text_File[MAXL]; /*for reading a list containing file names*/
/**************/
/* processing */
/**************/
	char		format[MAXF] = "";		/* pattern of frames to count */
	int             imgdim[4], mskdim[4], vdim, dimension, nvox, imgori, mskori, isbig, isbigm;
	int		nf_total = 0, nfile, ifile, iframe, nframes;
	float           imgvox[4], mskvox[4];
        float           *imgt, *imgm;
	float		threshold = 0.0, pct, imgmax, vneg, vpos;
	double		total, scale = 1.0; /*was type double*/
	char            *val;
/***********/
/* utility */
/***********/
	char            *ptr, command[MAXL];
	int             c, i, j, k, m;
	float		q, p, w, diff; /*was type double*/

/*********/
/* flags */
/*********/
	int             list_Flag = 0; /*added to indicate text file is loaded*/
	int		wei_flag = 0;
	int		conc_flag = 0;
	int		deriv_flag = 0;
	int             pctflag = 0;
	int		series = 0;
	int             vrange = 0;
	int             status = 0;
	int		defined;	/* test on imgt voxel value */
	int		D_flag = 0;	/* gates defined test effect on ROI value */
	int             pdefined;	/* previous frame is defined */

	setprog (program, argv);
/************************/
/* process command line */
/************************/
	for (j = 0, i = 1; i < argc; i++) {

		
		if (!strncmp("-list",argv[i],5)){
                strcpy(text_File,argv[i+1]);
		list_Flag = 1;
		printf("#Reading list file: %s\n", text_File);
		if (! strstr (text_File, ".txt")){
		printf("error: list file must end with .txt\n");
		exit(-1);}
                j++; 
                }

		else if (!strncmp("-s",argv[i],2)){
                	series++;
			}
			

		if (*argv[i] == '-') {
			if ((!strncmp("-d",argv[i],2))||(!strncmp("-D",argv[i],2))||(!strncmp("-W",argv[i],2))||(!strncmp("-f",argv[i],2))||(!strncmp("-c",argv[i],2))||(!strncmp("-p",argv[i],2))||(!strncmp("-t",argv[i],2))||(!strncmp("-v",argv[i],2))){
			strcpy (command, argv[i]); ptr = command;
			while (c = *ptr++) switch (c) {
				case 'd': deriv_flag++;
				/*case 's': series++;					break;*/
				case 'D': D_flag++;					break;
				case 'W': wei_flag++;					break;
				case 'f': strcpy (format, ptr);				*ptr = '\0'; break;
				case 'c': scale = atof (ptr);				*ptr = '\0'; break;
				case 'p': pctflag++; pct = atof (ptr);			*ptr = '\0'; break;
				case 't': threshold = atof (ptr);			*ptr = '\0'; break;
				case 'v': getrange (ptr, &vneg, &vpos);	vrange++;	*ptr = '\0'; break;
			}
			}
		} else switch (j) {
			case 0:	strcpy (imgroot, argv[i]);
			/*	list_flag = (strstr (argv[i], ".txt") == argv[i] + strlen (imgroot));
				if (list_Flag == 1) strcpy(text_File,imgroot);*/
                		j++; break;
                	case 1: if (list_Flag == 1) strcpy(mskroot, argv[i+1]);
				else if (list_Flag == 0) strcpy (mskroot, argv[i]);
				j++; 
				break;
		}
	}
	/*printf("J= %d\n", j);*/
	
	if (j < 2) usage (program);
	write_command_line (stdout, argc, argv);
	
/********************************************/
/* get input 4dfp dimensions and open files */
/********************************************/
   if (list_Flag == 1){
	fp = fopen(text_File,"rb");
	nifti_lstread(fp);
    } 
    else if (list_Flag == 0){
	    lLineCount = 1; 
	    ifile = 0;
    }
  
   for (filenum = 0; filenum < lLineCount ; filenum++){
		
        	if (list_Flag == 1) {
		strcpy(imgroot,input_file[filenum]);
	        printf("#Reading file: %s \n", imgroot);
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
		strcpy(output_file[filenum], filename);
		
	/*printf ("this is filename: %s\n", filename);*/

	src=FslOpen(FslMakeBaseName(filename),"r");
    
  	FslGetDim(src,&x_dim[filenum],&y_dim[filenum],&z_dim[filenum],&v_dim[filenum]);
	
      	bpp = FslGetDataType(src, &t) / 8;
      	V=v_dim[filenum]; X=x_dim[filenum]; Y=y_dim[filenum]; Z=z_dim[filenum];
     	
	if (list_Flag == 1){ 
	nframes += v_dim[filenum];
	}

	
	
  	
   }  /*end of for loop for list_nifti*/

/***********************************************/
/*Putting data from seperate files in outbuffer*/
/***********************************************/
	
	if (list_Flag == 1){V = nframes;}
	/*printf("X = %d, Y = %d, Z = %d, V = %d\n", X, Y, Z, V);*/
	imgdim[0] = X; imgdim[1] = Y; imgdim[2] = Z; imgdim[3] = V;
	FslGetVoxDim(src, &imgvox[0], &imgvox[1], &imgvox[2], &imgvox[3]);
	

	nfile = lLineCount; /*added to indicate the number of image files in list file*/

/*
	if (conc_flag) {
		conc_init_quiet (&conc_block, program);
		conc_open_quiet (&conc_block, imgroot);
		strcpy (imgfile, conc_block.lstfile);
		for (k = 0; k < 4; k++) imgdim[k] = conc_block.imgdim[k];
		for (k = 0; k < 3; k++) imgvox[k] = conc_block.voxdim[k];
		imgori = conc_block.orient;
		nfile  = conc_block.rnfile;
		isbig = conc_block.isbig;
	} else {
		sprintf (imgfile, "%s.4dfp.img", imgroot);
		if (get_4dfp_dimoe_quiet (imgfile, imgdim, imgvox, &imgori, &isbig) < 0) errr (program, imgfile);
		nfile = 1;
		if (!(imgfp = fopen (imgfile, "rb"))) errr (program, imgfile);
	}
*/
/***********************************/
/* set up frames to count (format) */
/***********************************/
	if (strlen (format)) {
		if (k = expandf (format, MAXF)) exit (k);
		if ((nf_total = strlen (format)) > imgdim[3]) {
			fprintf (stderr, "format codes for more frames (%d) than data (%d)\n", nf_total, imgdim[3]);
			exit (-1);
		}
	}
	if (deriv_flag && !nf_total) usage (program);

/*****************/
/* alloc buffers */
/*****************/
	dimension  = imgdim[0]*imgdim[1]*imgdim[2];
	vdim = dimension;
	if (!(imgt = (float *) malloc (dimension * sizeof (float)))) printf ("%s cannot allocate memory\n", program); 
	if (!(imgm = (float *) malloc (dimension * sizeof (float)))) printf ("%s cannot allocate memory\n", program); 

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
   	FslGetVoxDim(msk, &mskvox[0], &mskvox[1], &mskvox[2], &mskvox[3]);
	

	/*sprintf (mskfile, "%s.4dfp.img", mskroot);
	if (get_4dfp_dimoe_quiet (mskfile, mskdim, mskvox, &mskori, &isbigm) < 0) errr (program, mskfile);
	status = mskori - imgori;*/
	status = FslGetLeftRightOrder(msk) - FslGetLeftRightOrder(src);
	for (k = 0; k < 3; k++) status |= (imgdim[k] != mskdim[k]);
	/*for (k = 0; k < 3; k++) status |= (fabs (imgvox[k] - mskvox[k]) > 0.0001);*/
	if (status) {
		fprintf (stderr, "%s: %s %s dimension mismatch\n", program, imgroot, mskroot);
		exit (-1);
	}

	/*
	if (!(mskfp = fopen (mskfile, "rb"))) errr (program, mskfile);*/
	fprintf (stdout, "#Reading: %s.nii\n", mskfile);	    
	
	
		
   /*  for (k = 0; k < mskdim[3]; k++) {*/
			
		for (i = 0; i < dimension; i++){
		imgm[i] = (float) mskvol[i];
		}                   
	/*
	if (eread (imgm, dimension, isbigm, mskfp)) errr (program, mskfile);
	*/
	if (pctflag) {
		imgmax = -FLT_MAX;
		for (i = 0; i < dimension; i++) if (imgm[i] > imgmax) imgmax = imgm[i];
		printf ("#Maximum= %f\n#Percent= %f\n", imgmax, pct);
		threshold = pct * imgmax / 100.;
		/*rewind (mskfp);*/
	}
	
   /* } /*end of for loop for mask volumes*/
	printf ("#Threshold= %-.4f\n", threshold);
/***********/
/* process */
/***********/
/*	if (list_Flag == 0) printf ("#Reading: %s\n", imgroot);
	if (list_Flag == 1) printf ("#Reading: %s\n", text_File);
	/*printf ("#Reading: %s\n", imgfile);*/
	if (series) {
		if (deriv_flag) {
			printf ("#Frame      Mean     Deriv      Nvox\n");
		} else {
			printf ("#Frame      Mean     Nvox\n");
		}
	}
	for (iframe = pdefined = ifile = 0; ifile < nfile; ifile++) {
		
		if (list_Flag == 1) {
		src=FslOpen(FslMakeBaseName(input_file[ifile]),"r");
		}
		else if (list_Flag == 0){
		src=FslOpen(FslMakeBaseName(filename),"r");
		}
		buffer[ifile] = malloc(x_dim[ifile]*y_dim[ifile]*z_dim[ifile]*v_dim[ifile]*bpp);
  		FslReadVolumes(src, buffer[ifile], v_dim[ifile]);
		FslClose(src);
		vol = (double *) calloc (vdim*v_dim[ifile], sizeof (double));
  		convertBufferToScaledDouble(vol,buffer[ifile],X*Y*Z*v_dim[ifile],1.0,0.0,src->niftiptr->datatype);
		
		V_DIM = v_dim[ifile];
		
		
		for (k = 0; k < V_DIM; k++, iframe++) {
		
			for (i = 0; i < dimension; i++){
		
			imgt[i] = (float) vol[i + k*dimension];
			
			}
		
		total = nvox = 0;
		/*
		for (k = 0; k < ((conc_flag) ? conc_block.nvol[ifile] : imgdim[3]); k++, iframe++) {
			if (conc_flag) {
				conc_read_vol (&conc_block, imgt);
			} else {
				if (eread (imgt, dimension, isbig, imgfp)) errr (program, imgfile);
			}*/


			
			
			for (i = 0; i < dimension; i++) {
				m = (vrange) ? (imgt[i] > vneg && imgt[i] < vpos) : 1;
		defined = finite (imgt[i]) && !isnan (imgt[i]) && imgt[i] != (float) 1.e-37 && imgt[i] != 0.0;
				if (D_flag) m &= defined; /*printf ("j[%d] = %d\n",i, j);*/
				
				if (m && (wei_flag || (imgm[i] > threshold))) {
					w = (wei_flag) ? imgm[i] : 1.0; /*msk[i + k*dimension]*/
					total += imgt[i]*w;
					nvox++;
				}
			}
			p = q;
			q = scale*(total/nvox);
/*****************************************************/
/* print frame, mean, and voxel count for each frame */
/*****************************************************/
			if (series) {
				pdefined = k && format[iframe - 1] != 'x';
				if (deriv_flag) {
					diff = (pdefined) ? q - p : 0.0;
					printf ("%6d%10.4f%10.4f%10d\n", iframe + 1, q, diff, nvox);
				} else {
					printf ("%6d%10.4f%10d\n", iframe + 1, q, nvox);
				}
			} else {
				printf ("Total= %f\nMean= %f\nVoxels= %d\n", total, q, nvox);
			  }
		}
	
	free (vol);
	free (buffer[ifile]);
	} /*end of ifile loop*/

/*********************/
/* clean up and exit */
/*********************/
/*	if (conc_flag) {
		conc_free (&conc_block);
	} else {
		if (fclose (imgfp)) errr (program, imgfile);
	}
	fclose (mskfp);*/
	free (imgt); free (imgm); 
	free (mskvol); free (mskbuffer); 
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
