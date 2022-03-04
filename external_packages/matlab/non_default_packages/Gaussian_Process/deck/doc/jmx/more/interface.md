
# Creator and extractor interfaces

Most data containers in JMX are built around the **creator/extractor interfaces**. These are two abstract classes which enable many useful methods, and only require the implementation of a couple of methods in return.

## Creator interface

The creator interface depends on the template type `key` (e.g. index or string), and requires the following method to be implemented:
```cpp
mxArray* _creator_assign( key, mxArray* );
```

Writing `ptr = mxArray*` for short, creators expose the following methods:
```cpp
ptr mkbool(key,bool);
ptr mkstr(key,std::string);

ptr mknum<T = double>(key, val);
Vector_mx<T> mkvec<T = double>(key, len, col=false);
Matrix_mx<T> mkmat<T = double>(key, nr, nc);
Volume_mx<T> mkvol<T = double>(key, nr, nc, ns);

Cell mkcell(key, len);
Struct mkstruct(key, {"f1","f2",...});
Struct mkstruct(key, {"f1","f2",...}, nr, nc);
Struct mkstruct(key, nr, nc); 
Struct mkstruct(key); 
```

## Extractor interface

The extractor interface depends on the template type `key` (e.g. index or string), and requires the following methods to be implemented:
```cpp
bool _extractor_valid_key(key) const;
const mxArray* _extractor_get(key) const;
```

Writing `ptr = const mxArray*` for short, extractors expose the following methods:
```cpp
bool getbool(key) const;
std::string getstr(key) const;
T getnum<T = double>(key) const;

bool getbool(key,default) const;
std::string getstr(key,default) const;
T getnum<T = double>(key,default) const;

Vector_ro<T> getvec<T = double>(key) const;
Matrix_ro<T> getmat<T = double>(key) const;
Volume_ro<T> getvol<T = double>(key) const;

Vector_mx<T> getvec_rw<T = double>(key) const;
Matrix_mx<T> getmat_rw<T = double>(key) const;
Volume_mx<T> getvol_rw<T = double>(key) const;

Struct getstruct(key, ind=0) const;
Cell getcell(key) const;
```