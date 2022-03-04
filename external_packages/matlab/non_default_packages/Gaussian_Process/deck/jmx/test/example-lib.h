#ifndef EXAMPLE_LIB_H_INCLUDED
#define EXAMPLE_LIB_H_INCLUDED

//==================================================
// @title        what's in there?
// @author       my name
// @contact      my email
//==================================================

#include "jmx.h"

// include other files from this project
// #include "example-other.h"
// ...

// include standard library needed for the functions below
// #include <iostream>
// #include <vector>
// ...

// ------------------------------------------------------------------------

// declare a simple function, implement it in example-lib.cpp
void simple_function( const jmx::Vector<double>& x, const jmx::Struct& s );

// declare a template function or class, and implement it here
template <class T>
bool template_function( const jmx::Vector<T>& x )
{
    // do clever stuff...
}

#endif
