
# Memory management

## Abstract memory allocation

Memory allocations are classes with the following interface:
```cpp
template <class T>
struct AbstractMemory
{
    T *data;
    index_t size;

    void assign( T *ptr, index_t len );
    T& operator[] (index_t) const;

    void alloc(index_t len);
    void free();
};
```

## Concrete allocations

Three types of memory allocations are implemented in JMX:
```
Concrete type:      Parent type:                alloc/free:

ReadOnlyMemory<T>   AbstractMemory<const T>     throws error
ExternalMemory<T>   AbstractMemory<T>           throws error
MatlabMemory<T>     AbstractMemory<T>           uses mxCalloc
CppMemory<T>        AbstractMemory<T>           uses new
```
