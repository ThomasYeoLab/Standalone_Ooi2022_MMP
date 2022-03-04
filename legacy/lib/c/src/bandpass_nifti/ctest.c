#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <float.h>
#include <stdlib.h>

#define MARGIN		16

extern int npad_ (int *tdim, int *margin);	/* FORTRAN librms */

int main() {
int tdim_pad;
int tdim = 10;
int margin = 16;


tdim_pad = npad_ (&tdim, &margin);
printf ("tdim_pad = %d\n", tdim_pad); 
return 0;
}
