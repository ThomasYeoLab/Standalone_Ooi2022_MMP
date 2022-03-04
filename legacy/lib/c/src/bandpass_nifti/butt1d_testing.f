C$Header: /data/petsun4/data1/src_solaris/interp_4dfp/RCS/butt1d.f,v 1.4 2007/01/16 06:15:54 avi Exp $
C$Log: butt1d.f,v $
c Revision 1.4  2007/01/16  06:15:54  avi
c subroutine butt1dba()
c
c Revision 1.3  2004/05/26  20:30:53  avi
c subroutine butt1db
c
c Revision 1.2  2002/06/27  05:12:21  avi
c correct code to compute factor
c
c Revision 1.1  2002/06/25  05:16:29  avi
c Initial revision
c


      subroutine butt1db(data,n,delta,fhalf_lo,
&     iorder_lo,fhalf_hi,iorder_hi)
      real data(n)
      parameter (nmax=1024)
      parameter (m=2)
      real a(nmax/2+1),b(nmax/2+1)
      
      if(n.gt.nmax)then
        write(*,"('butt1db: input array length',i,' exceeds',i)")n,nmax
        call exit(-1)
      endif
	
      if (mod(n,m).ne.0) then
	write(*,"('butt1db: input array length illegal',i)")n
        call exit(-1)
      endif
      
      if(iorder_lo.lt.0.or.iorder_hi.lt.0)then
        write(*,*)'butt1db: negative Butterworth 
&	filter orders not allowed'
        call exit(-1)
      endif
 
      i=1
      do 21 k=1,n,2
      a(i)=data(k)
      b(i)=data(k+1)
      print *, i, a(i)
   21 i=i+1

      call fft  (a,b,1,n/2,1,-1)
      
      call REALT(a,b,1,n/2,1,-1)

      i=1
      do 22 k=1,n/2,1
      print *, k, a(k)
   22 i=i+1

      do 31 i=1,n/2+1
      f=float(i-1)/(float(n)*delta)
      if(iorder_lo.gt.0)then
        r_lo=(f/fhalf_lo)**(2*iorder_lo)
        factor_lo=r_lo/(1.0+r_lo)
      else
        factor_lo=1.0
      endif
      if(iorder_hi.gt.0)then
        r_hi=(f/fhalf_hi)**(2*iorder_hi)
        factor_hi=1.0/(1.0+r_hi)
      else
        factor_hi=1.0
      endif

      print *,delta,iorder_lo,iorder_hi,fhalf_lo,fhalf_hi,f,r_hi,factor_lo,factor_hi
      a(i)=factor_lo*factor_hi*a(i)
   31 b(i)=factor_lo*factor_hi*b(i)
      call REALT(a,b,1,n/2,1,+1)
      call fft  (a,b,1,n/2,1,+1)


       open (unit = 3, file = "debugafft")
       write (3,*) "vector A after fft: ", a
       close(3)




      i=1
      do 41 k=1,n,2
      data(k)  =a(i) 
      data(k+1)=b(i)
      print *, i, a(i)

   41 i=i+1
      return
      end
     
