	

c write(*,"('butt1db: input array length',i,' exceeds',i)")n,nmax
	parameter (nmax=8192)
	parameter (n=8200)

	if(n.gt.nmax)then
	write(*,*) 'butt1db: input array length',n,' exceeds',nmax
        call exit(-1)
      	endif
	return
	end
