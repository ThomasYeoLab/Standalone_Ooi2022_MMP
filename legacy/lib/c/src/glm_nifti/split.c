#include <stdlib.h>
#include <string.h>
#include <stdio.h>

char  ** split(char string[], int * num, char * sep) {
	char * pch;
	char ** out = 0;
        int i = 0;
	pch = strtok (string, sep );
       
	while (pch != 0 ) {
                out = realloc(out, (  i + 1 ) * sizeof( char * ));
		out[i] = malloc( strlen(pch ) + 1 );
                strcpy( out[i], pch );
                ++i;
		pch = strtok (NULL, sep);
	}
        *num = i;
	return out;
}


int main() {
    char str[255] = "one, two, tree, four,five  six";
    int num = 0;
    int i = 0;
    char ** tokens = split( str, &num, " ,");
    for( i = 0; i < num; ++i )
       printf("%s\n", tokens[i] );

    for( i = 0; i < num; ++i )
       free( tokens[i] );

    free(tokens); 
}
