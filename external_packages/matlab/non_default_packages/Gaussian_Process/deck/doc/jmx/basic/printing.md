
# Printing and display

## Using `stdout` and `stderr`

Without JMX, using `printf` or `std::cout` in Mex files will not reliably print to the Matlab console. You need to use `mexPrintf` instead.

With JMX, you can use the function `jmx::println` to write formatted message with the same syntax as `printf`.

In addition, JMX provides provides stream redirections for `stdout` and `stderr`. Most often, you will want to use that throughout your program, by writing the following at the beginning of the `mexFunction`:
```cpp
// redirect stdout and stderr to the Matlab console
jmx::cout_redirect();
jmx::cerr_redirect();
```
Subsequent calls to `std::cout` or `std::cerr` will then be redirected to the Matlab console. 

If, for any reason, you wish to turn off this redirection temporarily in your program, simply call these functions again:
```cpp
// disable stream redirection
jmx::cout_redirect(false);
jmx::cerr_redirect(false);
```

## Displaying containers

To-do
