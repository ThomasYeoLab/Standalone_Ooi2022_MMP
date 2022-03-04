#$Header: /data/petsun4/data1/src_solaris/sqrt_4dfp/RCS/rho2z_4dfp.mak,v 1.3 2006/09/24 23:36:53 avi Exp $
#$Log: rho2z_4dfp.mak,v $
# Revision 1.3  2006/09/24  23:36:53  avi
# ${PROG} ${RELEASE}
#
# Revision 1.2  2006/08/07  02:34:46  avi
# new ${TRX}
#
# Revision 1.1  2005/09/13  03:22:06  avi
# Initial revision
#
SHELL		=	csh


PROG	= 	rho2z_nifti
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
CSRCS 		= 	
 
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
