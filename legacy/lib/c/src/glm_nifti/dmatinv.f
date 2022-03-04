cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Copyright 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005.
c Washington University, Mallinckrodt Institute of Radiology.
c All rights reserved.
c This software may not be reproduced, copied, or distributed without written
c permission of washington university. For further information contact A. Z. Snyder.
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c $Header: /autofs/space/nexus_001/users/nexus-tools/cvsrepository/nifti_tools/glm_nifti/dmatinv.f,v 1.1 2008/08/10 20:26:49 mtt24 Exp $
c $Log: dmatinv.f,v $
c Revision 1.1  2008/08/10 20:26:49  mtt24
c revision one
c
c Revision 1.1  2005/09/04  06:24:51  avi
c Initial revision
c
c     program dmatimvtst
      subroutine dmatimvtst
c     changed from real*8
      implicit real*4 (a-h,o-z)
      parameter (n=384)
c     changed from real*8
      real*4 q(n,n),t(n,n),r(n,n)
      INTEGER nval
      do 1 i=1,n
      do 1 j=1,n
c     changed from drand to rand
    1 t(i,j)=0.5*(rand(0)-.1)
      do 2 i=1,n
      do 2 j=1,n
      q(i,j)=0.0
      do 2 k=1,n
      q(i,j)=q(i,j)+t(i,k)*t(j,k)
    2 r(i,j)=q(i,j)
      call dmatinv(q,n,det)
      write(*,"('dimension=',i4,' det=',e12.6)")n,det
  101 format(3(3f16.12,4x))
      do 12 i=1,n
      do 12 j=1,n
      t(i,j)=0.0
      do 12 k=1,n
   12 t(i,j)=t(i,j)+q(i,k)*r(k,j)
      write(*,"()")
      if (n.eq.3)then
        do i=1,n
          write(*,101)(r(i,k),k=1,n),(q(i,k),k=1,n),(t(i,k),k=1,n)
         enddo
      endif
      derr=0.0
      ierr=0
      jerr=0
      do 6 i=1,n
      do 6 j=1,n
      x=t(i,j)
      if(i.eq.j)x=x-1.0
c     changed from dabs to abs
      if(abs(x).gt.derr)then
        ierr=i
        jerr=j
        derr=abs(x)
      endif
    6 continue
      write(*,"('maximum error = ',e12.6)")derr
      end
      subroutine dmatinv(a,n,det)
c     algorithm follows Bevington, Phillip R.,
c     Data Reduction and Error Analysis for the Physical Sciences,
c     Mcgraw-Hill, New York, 1969.
c     changed from real*8
      implicit real*4 (a-h,o-z)
c     changed from real*8
      real*4 a(n,n),det
c      integer*4 ik(:),jk(:)
c      allocatable ik,jk
c      nval = 4*n
c      allocate(ik(nval))
c      allocate(jk(nval))
       integer*4 :: ik(10000),jk(10000)
c       range /size/ik,jk
c       set range (1:n) /size/
c      pointer (pik,ik)
c      pik=malloc(4*n)
c      pjk=malloc(4*n)
      det=1.
      do 100 k=1,n
      vmax=0.
   21 do 30 i=k,n
      do 30 j=k,n
      if(abs(vmax).gt.abs(a(i,j)))goto 30
      vmax=a(i,j)
      ik(k)=i
      jk(k)=j
   30 continue
      i=ik(k)
      if(i-k)21,51,43
   43 do 50 j=1,n
      t=a(k,j)
      a(k,j)=a(i,j)
   50 a(i,j)=-t
   51 j=jk(k)
      if(j-k)21,61,53
   53 do 60 i=1,n
      t=a(i,k)
      a(i,k)=a(i,j)
   60 a(i,j)=-t
   61 do 70 i=1,n
      if(i.ne.k)a(i,k)=-a(i,k)/vmax
   70 continue
   71 do 80 i=1,n
      do 80 j=1,n
      if(i.ne.k.and.j.ne.k)a(i,j)=a(i,j)+a(i,k)*a(k,j)
   80 continue
   81 do 90 j=1,n
      if(j.ne.k)a(k,j)=a(k,j)/vmax
   90 continue
      a(k,k)=1./vmax
  100 det=det*vmax
      do 130 l=1,n
      k=n-l+1
      j=ik(k)
      if(j-k)111,111,105
  105 do 110 i=1,n
      t=a(i,k)
      a(i,k)=-a(i,j)
  110 a(i,j)=t
  111 i=jk(k)
      if(i-k)130,130,113
  113 do 120 j=1,n
      t=a(k,j)
      a(k,j)=-a(i,j)
  120 a(i,j)=t
  130 continue
c      call free(pik)
c      call free(pjk)
c      deallocate (ik)
c      deallocate (jk)
      return
      end
