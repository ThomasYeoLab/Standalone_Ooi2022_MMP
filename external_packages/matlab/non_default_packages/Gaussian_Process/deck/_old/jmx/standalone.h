#ifndef STANDALONE_H_INCLUDED
#define STANDALONE_H_INCLUDED

//==================================================
// @title        standalone.h
// @author       Jonathan Hadida
// @contact      Jhadida [at] fmrib.ox.ac.uk
//==================================================

#include "mex.h"
#include "mat.h"

#include <cstdio>
#include <string>
#include <cstdlib>
#include <iostream>
#include <stdexcept>

#include <deque>
#include <unordered_map>
#include <initializer_list>

// ------------------------------------------------------------------------

#ifndef STANDALONE_MSG_SIZE
#define STANDALONE_MSG_SIZE 2047
#endif

// Assertions
static char sa_msg_[STANDALONE_MSG_SIZE];

#define SA_THROW( msg, args... ) \
	{ sprintf( sa_msg_, "::SA:: " msg "\n", ##args ); throw std::runtime_error(sa_msg_); }

#define SA_REJECT( cdt, msg, args... ) { if (cdt) SA_THROW(msg,##args) }
#define SA_ASSERT( cdt, msg, args... ) SA_REJECT(!(cdt),msg,##args)

// Detect keyboard interruptions with utIsInterruptPending()
#ifdef __cplusplus
    extern "C" bool utIsInterruptPending();
#else
    extern bool utIsInterruptPending();
#endif



    //--------------------     ==========     --------------------//
    //--------------------     **********     --------------------//



namespace sa {

inline bool check_interruption() {
    return utIsInterruptPending();
}

template <class... Args>
void println( std::string fmt, Args&&... args )
{
	fmt += "\n"; 
    mexPrintf( fmt.c_str(), std::forward<Args>(args)... );
}

// ------------------------------------------------------------------------

// Typedefs
using index_t = mwIndex;
using integ_t = mwSignedIndex;
using real_t  = double;

/**
 * Basic containers.
 */

template <class T, class I = index_t>
struct Vector
{
    T *data;
    I len;

    Vector()
        { clear(); }
    Vector( T *data_, I len_ )
        { set(data_,len_); }

    inline void clear()
        { data = NULL; len = 0; }
	inline void free()
		{ delete[] data; clear(); }

    inline void set( T *data_, I len_ )
        { data = data_; len = len_; }

    inline T& operator[] ( I k ) const
        { return data[k]; }
};

// ----------  =====  ----------

template <class T, class I = index_t>
struct Matrix
{
    T *data;
    I nrows, ncols;

    Matrix()
        { clear(); }
    Matrix( T *data_, I nrows_, I ncols_ )
        { set(data_,nrows_,ncols_); }

    inline void clear()
        { data = NULL; nrows = ncols = 0; }
	inline void free()
		{ delete[] data; clear(); }

    inline void set( T *data_, I nrows_, I ncols_ )
        { data = data_; nrows = nrows_; ncols = ncols_; }

    inline T& operator() ( I r, I c ) const
	    { return data[ r + nrows*c ]; }
};

// ----------  =====  ----------

template <class T, class I = index_t>
struct Volume
{
    T *data;
    I nr, nc, ns;

    Volume()
        { clear(); }
    Volume( T *data_, I nr_, I nc_, I ns_ )
        { set(data_,nr_,nc_,ns_); }

    inline void clear()
        { data = NULL; nr = nc = ns = 0; }
	inline void free()
		{ delete[] data; clear(); }

    inline void set( T *data_, I nr_, I nc_, I ns_ )
        { data = data_; nr = nr_; nc = nc_; ns = ns_; }

    inline T& operator() ( I r, I c, I s ) const
	    { return data[ r + nr*c + nr*nc*s ]; }
};

// ------------------------------------------------------------------------

// short alias for initializer lists
template <class T>
using inilst = std::initializer_list<T>;

/**
 *  Basic wrappers.
 */

class Cell 
{
public:

    Cell()
        { clear(); }
    Cell( const mxArray *ms )
        { wrap(ms); }

    inline void clear()
        { mcell = nullptr; }
    inline void wrap( const mxArray *ms )
    {
        SA_ASSERT( ms && mxIsCell(ms), "Input should be a cell." );
        mcell = ms;
    }

    inline index_t numel() const { return mxGetNumberOfElements(mcell); }
    inline bool    empty() const { return numel() == 0; }
    inline bool    valid() const { return mcell && mxIsCell(mcell); }
    inline operator bool() const { return valid() && !empty(); }

    inline mxArray* operator[] ( index_t k ) const { 
        return mxGetCell(mcell,k); 
    }

private: 
    const mxArray *mcell;
};

// ----------  =====  ----------

class Mappable
{
public: 

    using fieldmap_type = std::unordered_map< std::string, mxArray* >;
    using fields_type   = std::deque< std::string >;

    inline virtual void clear() 
    {
        m_fields.clear();
        m_fmap.clear();
    }
	virtual bool valid() const =0;

	// Dimensions / validity
	inline bool      empty() const { return nfields() == 0; }
	inline index_t    size() const { return nfields(); }
	inline index_t nfields() const { return m_fields.size(); }
	inline operator   bool() const { return valid(); }

	// Check if field exists
	inline bool has_field( const std::string& name ) const { 
        return m_fmap.find(name) != m_fmap.end(); 
    }

    inline bool has_any( const inilst<const char*>& names ) const
    {
        for ( auto& name: names )
            if ( has_field(name) )
                return true;

        return false;
    }
    
    inline bool has_fields ( const inilst<const char*>& names ) const
    {
        for ( auto& name: names ) 
            if ( !has_field(name) ) 
            {
                println( "Field '%s' doesn't exist.", name );
                return false;
            }
        return true;
    }

	// Access by index
	inline const std::string& field_name  ( index_t n ) const { return m_fields.at(n); }
	inline mxArray*           field_value ( index_t n ) const { return field_value(field_name(n)); }

 	// Access by name (overload necessary to avoid ambiguity)
 	inline mxArray* operator[] ( const std::string& name ) const { return field_value(name); }
	inline mxArray* operator[] ( const char* name )        const { return field_value(name); }

	inline mxArray* field_value( const std::string& name ) const { 
        return has_field(name)? m_fmap.find(name)->second : nullptr; 
    }

protected:
	fieldmap_type  m_fmap;
	fields_type    m_fields;    
};

// ----------  =====  ----------

class MAT : public Mappable
{
public:

    MAT() 
        : mfile(nullptr)
        { clear(); }
    MAT( const char *name ) 
        : mfile(nullptr)
        { open(name); }

    inline void clear() 
    {
        if (mfile) matClose(mfile);

        mfile = nullptr;
        Mappable::clear();
    }

    inline bool valid() const { return mfile; }
	inline const MATFile* mx() const { return mfile; }

    inline bool open( const char *name )
    {
        clear();
        if ( !name ) { println("Null filename."); return false; }

        MATFile *mf = matOpen( name, "r" );
        if ( mf == NULL ) {
            println("Error opening file '%s'.", name);
            return false;
        }

        int nf = 0;
        const char **fnames = (const char**) matGetDir( mf, &nf );
        if ( nf == 0 ) { println("Empty file."); }

        mfile = mf;
        this->m_fields.resize(nf);

        for ( int f = 0; f < nf; ++f )
        {
            this->m_fields[f] = fnames[f];
            this->m_fmap[ this->m_fields[f] ] = matGetVariable( mf, fnames[f] );
        }

        return true;
    }

private:
    MATFile *mfile;
};

// ----------  =====  ----------

class Struct : public Mappable
{
public:
    
    Struct()
		{ clear(); }
	Struct( const mxArray* ms, index_t index = 0 )
		{ wrap(ms,index); }

	inline void clear() 
    {
        mstruct = nullptr;
        Mappable::clear();
    }

    inline bool valid() const { return mstruct; }
	inline const mxArray* mx() const { return mstruct; }

	inline bool wrap( const mxArray* ms, index_t index = 0 )
    {
        clear();
        if ( !ms ) { println("Null pointer."); return false; }
        if ( !mxIsStruct(ms) ) { println("Not a struct."); return false; }

        const index_t nf = mxGetNumberOfFields(ms);
        if ( nf == 0 ) { println("Empty struct."); };

        mstruct = ms;
        this->m_fields.resize(nf);

        for ( index_t f = 0; f < nf; ++f )
        {
            this->m_fields[f] = mxGetFieldNameByNumber(ms,f);
            this->m_fmap[ this->m_fields[f] ] = mxGetFieldByNumber(ms,index,f);
        }

        return true;
    }

protected:

	const mxArray *mstruct;
};

// ------------------------------------------------------------------------

/**
 * Basic extraction methods.
 */

template <class T>
Vector<T> get_vector( const mxArray *ms )
{
	SA_ASSERT( mxIsNumeric(ms) && !mxIsComplex(ms), "Bad input type." );
	SA_ASSERT( mxGetNumberOfDimensions(ms)==2, "Not a vector." );

	index_t nr = mxGetM(ms);
	index_t nc = mxGetN(ms);

	if ( nr < nc )
	{
		SA_ASSERT( (nr==1) && (nc>1), "Not a vector." );
		return Vector<T>( static_cast<T*>(mxGetData(ms)), nc );
	}
	else
	{
		SA_ASSERT( (nc==1) && (nr>1), "Not a vector." );
		return Vector<T>( static_cast<T*>(mxGetData(ms)), nr );
	}
}

template <class T>
Matrix<T> get_matrix( const mxArray *ms )
{
	SA_ASSERT( mxIsNumeric(ms) && !mxIsComplex(ms), "Bad input type." );
	SA_ASSERT( mxGetNumberOfDimensions(ms)==2, "Not a matrix." );
	return Matrix<T>( static_cast<T*>(mxGetData(ms)), mxGetM(ms), mxGetN(ms) );
}

template <class T>
Volume<T> get_volume( const mxArray *ms )
{
	SA_ASSERT( mxIsNumeric(ms) && !mxIsComplex(ms), "Bad input type." );
	SA_ASSERT( mxGetNumberOfDimensions(ms)==3, "Not a volume." );
    const index_t *size = mxGetDimensions(ms);
	return Volume<T>( static_cast<T*>(mxGetData(ms)), size[0], size[1], size[2] );
}

template <class T>
T get_scalar( const mxArray *ms )
{
	SA_ASSERT( ms, "Null pointer in input." );
	SA_ASSERT( (mxIsNumeric(ms) || mxIsLogical(ms)) && !mxIsComplex(ms) && (mxGetNumberOfElements(ms) == 1),
		"Input should be a numeric scalar." );

	return static_cast<T>(mxGetScalar(ms));
}

template <class T>
T get_scalar( const mxArray *ms, const T& default_val ) {
	return (ms) ? get_scalar<T>(ms) : default_val;
}

inline std::string get_string( const mxArray *ms ) 
{
    SA_ASSERT( ms, "Null pointer in input." );
	SA_ASSERT( mxIsChar(ms), "Input should be a string." );

    std::string val;
    val.resize( mxGetNumberOfElements(ms) );
    mxGetString( ms, &val[0], val.size()+1 );
    return val;
}

inline std::string get_string( const mxArray *ms, const std::string& default_val ) {
    return (ms) ? get_string(ms) : default_val;
}

// ------------------------------------------------------------------------

/**
 * Simple setter utilities.
 */

inline int set_field( mxArray *mxs, index_t index, const char *field, mxArray *value )
{
    SA_ASSERT( mxIsStruct(mxs), "Input is not a struct." );

    // try to find the corresponding field
	int fnum = mxGetFieldNumber( mxs, field );

	// the field exists, check if there is something there
	if ( fnum >= 0 )
	{
		mxArray *fval = mxGetFieldByNumber( mxs, index, fnum );

		// there is something, so delete it first
		if ( fval ) mxDestroyArray( fval );
	}
	else // the field doesn't exist, so create it
	{
		fnum = mxAddField( mxs, field );
	}

	// set the value now
	mxSetField( mxs, index, field, value );

	return fnum;
}

inline int set_field( mxArray *mxs, const char *field, mxArray *value ) { 
    return set_field( mxs, 0, field, value ); 
}

inline int set_field( MATFile *mtf, const char *field, mxArray *value ) {
    return matPutVariable( mtf, field, value );
}

// ------------------------------------------------------------------------

/**
 * Basic creation methods.
 */

template <class T>
inline mxArray* make_scalar( const T& val ) {
    return mxCreateDoubleScalar(static_cast<double>(val));
}

inline mxArray* make_logical( bool val ) {
    return mxCreateLogicalScalar(val);
}

inline mxArray* make_string( const std::string& val ) {
    return mxCreateString( val.c_str() );
}

inline mxArray* make_matrix( index_t nr, index_t nc, mxClassID classid=mxDOUBLE_CLASS ) {
    return mxCreateNumericMatrix( nr, nc, classid, mxREAL );
}

inline mxArray* make_vector( index_t len, bool column=false, mxClassID classid=mxDOUBLE_CLASS )
{
    if (column)
        return make_matrix( len, 1, classid );
    else
        return make_matrix( 1, len, classid );
}

inline mxArray* make_volume( index_t nr, index_t nc, index_t ns, mxClassID classid=mxDOUBLE_CLASS )
{
    index_t size[3] = {nr,nc,ns};
    return mxCreateNumericArray( 3, size, classid, mxREAL );
}

inline mxArray* make_struct( const char *fields[], index_t nfields, index_t nrows=1, index_t ncols=1 ) { 
    return mxCreateStructMatrix( nrows, ncols, nfields, (const char**) fields ); 
}

inline mxArray* make_struct( inilst<const char*> fields, index_t nrows=1, index_t ncols=1 ) {
    return mxCreateStructMatrix( nrows, ncols, fields.size(), const_cast<const char**>(fields.begin()) ); 
}

}; // end namespace

#endif
