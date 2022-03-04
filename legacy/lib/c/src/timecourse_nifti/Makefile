SHELL		=	csh

PROG	= timecourse_nifti
TRX	= ${_HVD_CODE_DIR}/lib/c/nifticlib-0.4/${_HVD_PLATFORM}

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
GNU_ANSI_FLAGS	= 	-Wall -ansi 
ANSI_FLAGS	= 	${GNU_ANSI_FLAGS}
CFLAGS		=	$(ANSI_FLAGS)

## Zlib defines
ZLIB_INC	=	-I/usr/include
ZLIB_PATH	=	-L/usr/lib
ZLIB_LIBS 	= 	$(ZLIB_PATH) -lm -lz 

OUTPUT_DIR      =       ${_HVD_CODE_DIR}/lib/c/${_HVD_PLATFORM}

## Platform specific redefines

## SGI 32bit
##ZLIB_INC	=	-I/usr/freeware/include
##ZLIB_PATH	=	-L/usr/freeware/lib32
##RANLIB		=	echo "ranlib not needed"


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
FSRCS	= 
OBJS	= ${CSRCS:.c=.o} ${FSRCS:.f=.o}

## Rules
ifeq ($(_HVD_PLATFORM),darwin_i386) ## mac osx darwin_i386
       LIBS	= -lm -lgfortran
else
ifeq ($(_HVD_PLATFORM),linux_x86_64) ## 64-bit Linux
       LIBS	= -lm
endif
endif

FSLIO_INCS	=	-I${TRX}/include
NIFTI_INCS	=	-I${TRX}/include
SHELL 		= 	csh


ZNZ_INCS	=	-I/usr/include

FSLIO_LIBS	=	-L${TRX}/lib -lfslio
NIFTI_LIBS	=	-L${TRX}/lib -lniftiio
ZNZ_LIBS	=	-L/usr/lib -L${TRX}/lib -lznz -lm -lz

## Rules

.SUFFIXES: .c .o

.c.o:
	$(CC) -c $(CFLAGS) $(INCFLAGS) $<



CC	=	gcc
CFLAGS	=	-ansi 

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
	$(PROG)

$(PROG):	timecourse_nifti.c ${TRX}/lib/libfslio.a
	$(CC) $(CFLAGS) -o ${OUTPUT_DIR}/$(PROG) $(PROG).c $(FSLIO_INCS) $(NIFTI_INCS) $(ZNZ_INCS) $(FSLIO_LIBS) $(NIFTI_LIBS) $(ZNZ_LIBS) $(OBJS) $(LIBS)
