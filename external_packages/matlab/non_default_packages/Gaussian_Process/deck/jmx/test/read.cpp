
#include <iostream>
#include <vector>
#include <string>

#include "jmx.h"

// ------------------------------------------------------------------------

void dispVector( const jhm::Vector<double>& vec, const char *name )
{
    jhm::println("Vector %s (length %d)", name, vec.n);
    if ( vec.numel() == 0 ) {
        jhm::println("\t(empty)"); return;
    }
    jhm::print("\t[");
    for ( int i=0; i < vec.n; i++ )
        jhm::print(" %g,", vec[i]);
    jhm::print("]\n");
}

void dispMatrix( const jhm::Matrix<double>& mat, const char *name )
{
    jhm::println("Matrix %s (size %dx%d)", name, mat.nr, mat.nc);
    if ( mat.numel() == 0 ) {
        jhm::println("\t(empty)"); return;
    }
    for ( int r = 0; r < mat.nr; r++ ) {
        jhm::print("\t");
        for ( int c = 0; c < mat.nc; c++ )
            jhm::print(" %g,", mat(r,c));
        jhm::print("\n");
    }
}

void dispVolume( const jhm::Volume<double>& vol, const char *name )
{
    jhm::println("Volume %s (size %dx%dx%d)", name, vol.nr, vol.nc, vol.ns);
    if ( vol.numel() == 0 ) {
        jhm::println("\t(empty)"); return;
    }
    for ( int s = 0; s < vol.ns; s++ ) {
        jhm::println("---------- Slice %d", s);
        for ( int r = 0; r < vol.nr; r++ ) {
            jhm::print("\t");
            for ( int c = 0; c < vol.nc; c++ )
                jhm::print(" %g,", vol(r,c,s));
            jhm::print("\n");
        }
        jhm::println("----------");
    }
}

// ------------------------------------------------------------------------

void showLogical( const jhm::MAT& mfile )
{
    std::vector<std::string> b2s = { "false", "true" };
    jhm::println("+= Logical variables:");
    jhm::println("  logt: %s", b2s[jhm::get_scalar<bool>(mfile["logt"])].c_str() );
    jhm::println("  logf: %s", b2s[jhm::get_scalar<bool>(mfile["logf"])].c_str() );
}

void showNumeric( const jhm::MAT& mfile )
{
    jhm::println("+= Numeric variables:");
    jhm::println("  num1: %g", jhm::get_scalar<double>(mfile["num1"]) );
    jhm::println("  num2: %g", jhm::get_scalar<double>(mfile["num2"]) );
    jhm::println("  num3: %g", jhm::get_scalar<double>(mfile["num3"]) );
    jhm::println("  num4: %g", jhm::get_scalar<double>(mfile["num4"]) );
    jhm::println("  num5: %g", jhm::get_scalar<double>(mfile["num5"]) );
    jhm::println("  num6: %g", jhm::get_scalar<double>(mfile["num6"]) );
}

void showVector( const jhm::MAT& mfile )
{
    jhm::println("+= Vector variables:");
    dispVector( jhm::get_vector<double>(mfile["vec1"]), "vec1" );
    dispVector( jhm::get_vector<double>(mfile["vec2"]), "vec2" );
    dispVector( jhm::get_vector<double>(mfile["vec3"]), "vec3" );
}

void showMatrix( const jhm::MAT& mfile )
{
    jhm::println("+= Matrix variables:");
    dispMatrix( jhm::get_matrix<double>(mfile["mat1"]), "mat1" );
    dispMatrix( jhm::get_matrix<double>(mfile["mat2"]), "mat2" );
    dispMatrix( jhm::get_matrix<double>(mfile["mat3"]), "mat3" );
}

void showVolume( const jhm::MAT& mfile )
{
    jhm::println("+= Volume variables:");
    dispVolume( jhm::get_volume<double>(mfile["vol1"]), "vol1" );
    dispVolume( jhm::get_volume<double>(mfile["vol2"]), "vol2" );
    dispVolume( jhm::get_volume<double>(mfile["vol3"]), "vol3" );
}

void showString( const jhm::MAT& mfile ) 
{
    jhm::println("+= String variables:");
    jhm::println("  str1: %s", jhm::get_string(mfile["str1"]).c_str());
    jhm::println("  str2: %s", jhm::get_string(mfile["str2"]).c_str());
}

// ------------------------------------------------------------------------

void mexFunction( int nargout, mxArray *out[],
                  int nargin, const mxArray *in[] )
{
    jhm::cout_redirect();
    jhm::MAT mfile("data.mat");
    
    jhm::println( "Opened file with %d variables.", mfile.nfields() );
    showLogical(mfile);
    showNumeric(mfile);
    showString(mfile);
    showVector(mfile);
    showMatrix(mfile);
    showVolume(mfile);
}
