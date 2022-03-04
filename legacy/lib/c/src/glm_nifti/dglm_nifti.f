c$Header: /autofs/space/nexus_001/users/nexus-tools/cvsrepository/nifti_tools/glm_nifti/dglm_nifti.f,v 1.1 2008/08/10 20:26:49 mtt24 Exp $
c$Log: dglm_nifti.f,v $
cRevision 1.1  2008/08/10 20:26:49  mtt24
crevision one
c
c Revision 1.1  2005/09/05  00:52:46  avi
c Initial revision
c
c Revision 1.1  2004/05/26  05:31:05  avi
c Initial revision
c
c changed all real*8 to real*4
      subroutine df2finvt(f,npts,ncol,a,finvt,nnez)
      implicit real*4 (a-h,o-z)
      integer*4 npts,ncol
      real*4 f(npts,ncol),
     &finvt(npts,ncol),a(ncol,ncol)
      real*4 ainv(ncol,ncol),
     &e(ncol,ncol),w(ncol,ncol)
c calling C subroutines for memory allocation
 
c      pointer ( painv, ainv )
c      pointer ( pe, e )
c      pointer ( pw, w )

c     write(*,"('f')")
c     call matlst(f,npts,ncol)
c     write(*,"('a')")
c     call matlst(a,ncol,ncol)

c      painv=malloc(4*ncol*ncol)
c      pe   =malloc(4*ncol*ncol)
c      pw   =malloc(4*ncol*ncol)
c      if(painv.eq.0.or.pe.eq.0.or.pw.eq.0) 
c    & stop 'df2finvt memory allocation error'

      do 23 i=1,ncol
      do 23 j=1,ncol
      ainv(i,j)=a(i,j)
   23 e(i,j)=a(i,j)
      call deigen(e,w,ncol)
      write(*,"('condition_number=',e12.6)")e(1,1)/e(ncol,ncol)
      call dmatinv(ainv,ncol,det)
      write(*,"('det=',e12.6)")det

      do 22 i=1,npts
      do 22 j=1,ncol
      finvt(i,j)=0.0
      do 22 k=1,ncol
   22 finvt(i,j)=finvt(i,j)+f(i,k)*ainv(k,j)

      do 24 i=1,ncol
      do 24 j=1,ncol
      e(i,j)=0.0
      do 25 k=1,npts
   25 e(i,j)=e(i,j)+finvt(k,i)*f(k,j)
   24 e(i,j)=e(i,j)/float(nnez)
c     write(*,"('identity matrix')")
c     call matlst(e,ncol,ncol)
      call errlist(e,ncol)

c      call free(painv)
c      call free(pe)
c      call free(pw)


      return
      end

      subroutine errlist(t,n)
      implicit real*4 (a-h,o-z)
      real*4 t(n,n)
      derr=0.0
      do 6 i=1,n
      do 6 j=1,n
      x=t(i,j)
      if(i.eq.j)x=x-1.0
c     changed from dabs to abs
      if(abs(x).gt.derr)derr=abs(x)
    6 continue
      write(*,"('maximum_error=',e12.6)")derr
      end

      subroutine matlst(a,ni,nj)
      real*4 a(ni,nj)
      do 1 i=1,ni
    1 write(*,"(10f10.6)")(a(i,j),j=1,nj)
      return
      end
