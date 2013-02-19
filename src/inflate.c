/*
 * tgunzip  -  gzip decompressor example
 *
 * Copyright (c) 2003 by Joergen Ibsen / Jibz
 * All Rights Reserved
 *
 * http://www.ibsensoftware.com/
 *
 * This software is provided 'as-is', without any express
 * or implied warranty.  In no event will the authors be
 * held liable for any damages arising from the use of
 * this software.
 *
 * Permission is granted to anyone to use this software
 * for any purpose, including commercial applications,
 * and to alter it and redistribute it freely, subject to
 * the following restrictions:
 *
 * 1. The origin of this software must not be
 *    misrepresented; you must not claim that you
 *    wrote the original software. If you use this
 *    software in a product, an acknowledgment in
 *    the product documentation would be appreciated
 *    but is not required.
 *
 * 2. Altered source versions must be plainly marked
 *    as such, and must not be misrepresented as
 *    being the original software.
 *
 * 3. This notice may not be removed or altered from
 *    any source distribution.
 */

#include <stdlib.h>
#include <stdio.h>
#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

#include "tinf.h"

void exit_error(const char *what)
{
   Rprintf("ERROR: %s\n", what);
}

SEXP inflateFile(SEXP input)
{
    FILE *fin, *fout;
    SEXP outputVector;
    unsigned int len, dlen, outlen;
    unsigned char *source, *dest;
    int res;
    int i;

    Rprintf("test_inflate - example from the tiny inflate library \n\n");

    tinf_init();

    len = length(input);
    source = (unsigned char *)R_alloc(sizeof(char), len);
    for(i = 0; i < len; i++) {
        source[i] = INTEGER(input)[i];
    }
    
    for(i = 0; i < 10; i++) {
        Rprintf("%i ", source[i]);
    }
    Rprintf("\n");

    /* -- set decompressed length to 10MB -- */ 
    dlen = 100000000;
    dest = (unsigned char *)R_alloc(sizeof(char), dlen);
    if (dest == NULL) exit_error("memory");

    /* -- decompress data -- */

    outlen = dlen;

    res = tinf_uncompress(dest, &outlen, source, len);

    for(i = 0; i < 100; i++) {
        printf("%c", dest[i]);
    }
    printf("\n");

    PROTECT(outputVector = allocVector(INTSXP, outlen));
    for(i = 0; i < outlen; i++) {
        INTEGER(outputVector)[i] = dest[i];
    } 
    
    printf("decompressed %u bytes\n", outlen);
    UNPROTECT(1);
    return outputVector;
}
