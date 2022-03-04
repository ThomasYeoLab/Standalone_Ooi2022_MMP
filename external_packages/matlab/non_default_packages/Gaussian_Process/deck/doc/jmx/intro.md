
# Introduction

### Libraries and executables

Not all C++ programs are meant to be executed; that is, called with arguments from a terminal. Non-executable programs are called **libraries**, because they usually implement a range of functions and classes for a particular purpose (e.g. to build a web-server, or to read/write JSON files), and are designed and organised to facilitate their use by other programs for building specific applications (e.g. creating a website, or saving simulations as JSON files).

The JMX library is an example of such non-executable program. It mainly defines a set of classes that make it easier to write **Mex files**, which are Matlab executable programs written in one of the supported languages (C, C++, and ForTran). 

The primary use of JMX is to write small programs to be called from Matlab in order to accelerate certain tasks, but it can also be used to create a Matlab interface with native C++ libraries.

### Matlab vs standard C++ memory

There is a difference between the memory allocated by standard C++ functions such as `malloc` or `new`, and the memory used to store data within Matlab. You should be aware of this when you write Mex files.

When working with input arguments to a Mex function, remember that they **cannot** be modified in-place (this causes a segfault). Instead, you should create a new variable to be returned as an output, in order to store the results of your processing. JMX makes it easy to work with input and output arguments in Mex files.

Of course, most programs will require the creation of many other variables, which are neither input or output arguments, in order to store intermediary results. JMX defines a unified set of array containers (vectors, matrices and volumes) which can bind to both Matlab or standard C++ memory allocations. This means that matrices in your program can be used alike, whether they are intermediary variables, or output arguments. And that makes your code much simpler to write and understand.
