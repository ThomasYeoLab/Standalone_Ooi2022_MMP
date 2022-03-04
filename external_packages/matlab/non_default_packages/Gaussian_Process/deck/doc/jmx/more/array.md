
# Arrays

JMX defines three array containers: vector, matrix and volume. Only real-valued matrices at the moment.

## Abstract base

The base class for all array containers depends on two template types:
```cpp
template <class T, class M = CppMemory<T> > class Array;
```
where `T` is the type of the underlying data (non-const), and `M` is the allocation type, which defaults to `CppMemory` (i.e. using `new`, see [memory management](jmx/more/memory)). 

The **value-type** (i.e. the type returned when accessing the data) is derived from the allocation:
```cpp
using value_type = typename M::value_type;
```
In brief, this is equal to `T` unless the allocation template is `ReadOnlyMemory`, in which case it is `const T` and the values are therefore immutable.

The following members/methods are common to all array containers:
```cpp
M mem; // memory allocation

index_t ndims() const;
index_t numel() const;
value_type& operator[] (index_t) const;

value_type* memptr() const; // underlying data
void free(); // release memory (if allocation permits)
```

## Concrete arrays

Additional members/methods for `Vector<T,M>`:
```cpp
index_t length() const;

void assign( value_type *ptr, index_t len );
void alloc( index_t len );
```

Additional members/methods for `Matrix<T,M>`:
```cpp
index_t nrows() const;
index_t ncols() const;

void assign( value_type *ptr, index_t nr, index_t nc );
void alloc( index_t nr, index_t nc );

// specialised access
value_type& operator() (index_t r, index_t c) const;
```

Additional members/methods for `Volume<T,M>`:
```cpp
index_t nrows() const;
index_t ncols() const;
index_t nslabs() const;

void assign( value_type *ptr, index_t nr, index_t nc, index_t ns );
void alloc( index_t nr, index_t nc, index_t ns );

// specialised access
value_type& operator() (index_t r, index_t c, index_t s) const;
```

## Specialised variants

As written above, the default allocation template is `CppMemory<T>`, which means that the underlying memory is managed by the standard operator `new`.

For convenience, each array type also defines two specialised variants:
```cpp
Vector_ro<T> = Vector<T, ReadOnlyMemory<T> >; // constant value-type
Vector_mx<T> = Vector<T, MatlabMemory<T> >; // using mxCalloc

// similarly for Matrix and Volume
```

## Creating runtime variables

Creating input and output arguments to Mex functions (i.e. within Matlab's own memory) has been previously described [here](jmx/basic/io).

Since by default, array containers are instanciated with `CppMemory` template allocation, creating runtime arrays in practice is as simple as:
```cpp
Vector<T> x(len);
Matrix<T> M(nr,nc);
Volume<T> V(nr,nc,ns);
```

> **Note:** it is very unlikely that you will ever have to explicitly allocate a container declared with `MatlabMemory` allocation template. Use the [makers](jmx/more/maker) instead if needed.

