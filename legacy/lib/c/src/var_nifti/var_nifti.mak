# $Header: /data/petsun4/data1/src_solaris/actmapf_4dfp/RCS/actmapf_4dfp.mak,v 1.8 2006/09/23 23:03:04 avi Exp $
# $Log: actmapf_4dfp.mak,v $
# Revision 1.8  2006/09/23  23:03:04  avi
# ${NILSRC} ${RELEASE}
#
# Revision 1.7  2006/09/21  19:56:59  avi
# use endian invariant subroutines
#
# Revision 1.6  2005/07/22  05:08:56  avi
# add conc.c and eliminate all references to libmri and librms
#
# Revision 1.5  2004/05/23  04:05:03  avi
# link with fimg_mode.o
#
# Revision 1.4  2004/05/16  01:55:57  avi
# chmod to program on release
#
# Revision 1.3  1999/03/11  09:17:43  avi
# Getifh.o
#
# Revision 1.2  1999/01/04  08:21:01  avi
# new release
#
# Revision 1.1  1998/10/08  23:51:41  avi
# Initial revision
#
SHELL		=	csh


PROG	= 	var_nifti
TRX	= 	/autofs/space/nexus_001/users/nexus-tools/src/nilsrc/niftilib/nifticlib-0.4/

## Projects
NIFTI		=	niftilib
ZNZ		=	znzlib
FSLIO		=	fsliolib
THIS_DIR	=	`basename ${PWD}`
EXAMPLES	= 	THIS_DIR
## Compiler  defines
cc		=	gcc
CC		=	gcc
AR		=	ar
RANLIB  = ranlib
DEPENDFLAGS	=	-MM
GNU_ANSI_FLAGS	= 	-Wall -ansi -pedantic
ANSI_FLAGS	= 	${GNU_ANSI_FLAGS}
CFLAGS		=	$(ANSI_FLAGS)

## Zlib defines
ZLIB_INC	=	-I/usr/include
ZLIB_PATH	=	-L/usr/lib
ZLIB_LIBS 	= 	$(ZLIB_PATH) -lm -lz 


## Platform specific redefines

## SGI 32bit
##ZLIB_INC	=	-I/usr/freeware/include
##ZLIB_PATH	=	-L/usr/freeware/lib32
##RANLIB	=	echo "ranlib not needed"


## RedHat Fedora Linux
## ZLIB_INC	=	-I/usr/include
## ZLIB_PATH	=	-L/usr/lib


#################################################################

## ZNZ defines
ZNZ_INC		=	-I${TRX}/$(ZNZ)
ZNZ_PATH	=	-L${TRX}/$(ZNZ)
ZNZ_LIBS	=	$(ZNZ_PATH)  -lznz
USEZLIB         =       -DHAVE_ZLIB

## NIFTI defines
NIFTI_INC	=	-I${TRX}/$(NIFTI)
NIFTI_PATH	=	-L${TRX}/$(NIFTI)
NIFTI_LIBS	=	$(NIFTI_PATH) -lniftiio

## FSLIO defines
FSLIO_INC	=	-I${TRX}/$(FSLIO)
FSLIO_PATH	=	-L${TRX}/$(FSLIO)
FSLIO_LIBS	=	$(FSLIO_PATH) -lfslio
FSRCS 		= 	
CSRCS 		= 	expandf.c
 
OBJS	= ${CSRCS:.c=.o} ${FSRCS:.f=.o}

LIBS	= -lm

FSLIO_INCS	=	-I${TRX}/include
NIFTI_INCS	=	-I${TRX}/include
SHELL 		= 	csh


ZNZ_INCS	=	-I/usr/include

FSLIO_LIBS	=	-L${TRX}/lib -lfslio
NIFTI_LIBS	=	-L${TRX}/lib -lniftiio
ZNZ_LIBS	=	-L/usr/lib -L${TRX}/lib -lznz -lm -lz

## Rules

FC	= f77 
CC	= f77 -O 

.SUFFIXES: .c .o

.c.o:
	$(CC) -c $(CFLAGS) $(INCFLAGS) $<
.f.o:
	$(FC) -c $<
   

CFLAGS	= -ansi


FSLIO_INCS	=	-I${TRX}/include
NIFTI_INCS	=	-I${TRX}/include
ZNZ_INCS	=	-I/usr/include

FSLIO_LIBS	=	-L${TRX}/lib -lfslio
NIFTI_LIBS	=	-L${TRX}/lib -lniftiio
ZNZ_LIBS	=	-L/usr/lib -L${TRX}/lib -lznz -lm -lz



## SGI 32bit
ifeq ($(ARCH),SGI)
ZNZ_INCS	=	-I/usr/freeware/include
ZNZ_LIBS	=	-L/usr/freeware/lib32 -L${TRX}/lib -lznz -lm -lz
endif

all:	$(PROG)

clean:
	$(PROG):  	


$(PROG):  	${OBJS} ${TRX}/lib/libfslio.a 
	$(CC) $(CFLAGS) -o $(PROG) $(PROG).c $(FSLIO_INCS) $(NIFTI_INCS) $(ZNZ_INCS) $(FSLIO_LIBS) $(NIFTI_LIBS) $(ZNZ_LIBS) $(OBJS) 

