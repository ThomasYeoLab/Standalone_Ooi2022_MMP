#$Header: /data/petsun4/data1/src_solaris/qnt_4dfp/RCS/qnt_4dfp.mak,v 1.9 2006/09/25 03:21:53 avi Exp $
#$Log: qnt_4dfp.mak,v $
# Revision 1.9  2006/09/25  03:21:53  avi
# ${PROG} ${RELEASE}
#
# Revision 1.8  2006/08/07  03:29:53  avi
# point to ${ACT} to see conc.h
#
# Revision 1.7  2006/05/04  01:46:32  avi
# new TRX
#
# Revision 1.6  2005/09/20  00:00:33  avi
# expandf.o
#
# Revision 1.5  2005/09/16  03:42:10  avi
# add conc.o to ${LOBJS}
#
# Revision 1.4  2004/09/21  21:25:24  rsachs
# Removed 'libmri'. Added 'Getifh.o', 'get_4d_images2.o'.
#
# Revision 1.3  2004/05/27  00:01:19  avi
#
PROG	= qnt_4dfp
CSRCS	= ${PROG}.c
TRX     = ${NILSRC}/TRX
ACT     = ${NILSRC}/actmapf_4dfp
LOBJS   = ${TRX}/Getifh.o ${TRX}/endianio.o ${ACT}/conc.o ${ACT}/expandf.o ${TRX}/rec.o
OBJS	= ${CSRCS:.c=.o} 
LIBS	= -lm 

CC	= cc -O -I${TRX} -I${ACT}

.c.o:
	${CC} -c $<

${PROG}: ${OBJS}
	${CC} -o $@ ${OBJS} ${LOBJS} ${LIBS} 

release: ${PROG}
	chmod 775 ${PROG}
	chgrp program ${PROG}
	/bin/mv ${PROG} ${RELEASE}

clean:
	/bin/rm ${OBJS} ${PROG}

checkout:
	co ${CSRCS}

checkin:
	ci ${CSRCS}
