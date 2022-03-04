
# Functional programming

Help is available for all functions except `dk.bsx.*` by typing `help <FunctionName>` in the Matlab console.

## Singleton expansion

These are simple wrappers for Matlab's `bsxfun` functions:
```
dk.bsx.add(a,b)         =>      bsxfun( @plus, a, b )
dk.bsx.sub(a,b)         =>      bsxfun( @minus, a, b )
dk.bsx.mul(a,b)         =>      bsxfun( @times, a, b )
dk.bsx.rdiv(a,b)        =>      bsxfun( @rdivide, a, b )
dk.bsx.ldiv(a,b)        =>      bsxfun( @ldivide, a, b )
dk.bsx.eq(a,b)          =>      bsxfun( @eq, a, b )
dk.bsx.neq(a,b)         =>      bsxfun( @ne, a, b )
dk.bsx.leq(a,b)         =>      bsxfun( @leq, a, b )
dk.bsx.lt(a,b)          =>      bsxfun( @lt, a, b )
dk.bsx.geq(a,b)         =>      bsxfun( @geq, a, b )
dk.bsx.gt(a,b)          =>      bsxfun( @gt, a, b )
dk.bsx.or(a,b)          =>      bsxfun( @or, a, b )
dk.bsx.and(a,b)         =>      bsxfun( @and, a, b )
dk.bsx.dot(a,b,dim)     =>      sum(bsxfun( @times, a, b ),dim)
```

## Iteration

```
dk.mapfun               map function to array or cell elements
dk.kvfun                map function to fields of struct or struct-arrays
dk.reduce               apply function to subsets with matching value
```

## Input/output modifiers

```
dk.deal                 powerful extension of Matlab's deal function
dk.call                 permute the order of a function's output
dk.reverse              reverse the order of a function's output
```

## Other

```
dk.pass                 accept everything, do nothing
dk.forward              output are the same as outputs
```
