#$Header: /data/petsun4/data1/src_solaris/interp_4dfp/RCS/bandpass_4dfp.mak,v 1.4 2006/09/25 16:53:04 avi Exp $
#$Log: bandpass_4dfp.mak,v $
# Revision 1.4  2006/09/25  16:53:04  avi
# ${PROG} ${RELEASE}
#
# Revision 1.3  2006/08/07  03:25:35  avi
# new ${TRX}
#
# Revision 1.2  2005/06/29  04:18:42  avi
#

PROG	= bandpass_4dfp
CSRCS	= ${PROG}.c
FSRCS	= butt1d.f
TRX	= ${NILSRC}/TRX
ACT	= ${NILSRC}/actmapf_4dfp
OBJS	= ${CSRCS:.c=.o} ${FSRCS:.f=.o}
LOBJS	= ${TRX}/rec.o ${TRX}/Getifh.o ${TRX}/endianio.o ${ACT}/conc.o
LIBS	= -lrms -lm 

FC	= f77 -O -e -I4
CFLAGS	= -I${ACT} -I${TRX} -O
CC	= cc ${CFLAGS}

.c.o:
	${CC} -c $<

.f.o:
	${FC} -c $<

${PROG}: ${OBJS}
	${FC} -o $@ ${OBJS} ${LOBJS} ${LIBS}

clean:
	rm ${OBJS} ${PROG}

checkout:
	co ${CSRCS} ${FSRCS}

checkin:
	ci ${CSRCS} ${FSRCS}

release: ${PROG}
	chgrp program ${PROG}
	chmod 751 ${PROG}
	/bin/mv ${PROG} ${RELEASE}
