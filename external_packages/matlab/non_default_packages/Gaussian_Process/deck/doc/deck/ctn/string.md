# Strings

This module implements methods working with arrays of characters.

- [`dk.str.Template`](#Template) Python-like string template
- [`dk.str.singlespaces`](#spaces) Replace all spacings by a single space
- [`dk.str.capfirst|capwords`](#caps) Capitalise characters
- [`dk.str.strip|lstrip|rstrip`](#strip) Remove leading and/or trailing characters
- [`dk.str.set_ext|rem_ext|rep_ext`](#ext) Set, remove of replace file extensions
- [`dk.str.numbers`](#numbers) Extract numbers from string
- [`dk.str.to_substruct`](#to_substruct) Convert string to [`substruct`](https://uk.mathworks.com/help/matlab/ref/substruct.html)

---

### <a name="Template"/> `dk.str.Template`

This Matlab class allows to you to define [python-like](https://docs.python.org/2/library/string.html#template-strings) string templates.

A string template is a string which contains _named placeholders_ written as `${name}`. These placeholders can be substituded with values of your choice, to produce a so-called interpolated string, by providing `Name, Value` pairs with corresponding fieldnames. For example:
```matlab
tpl = dk.str.Template('Hello ${name}!'); % create template from a string
disp(tpl.substitute( 'name', 'World' ));
```

One of the advantages of template strings is that they can be reused with different interpolants:
```matlab
tpl = dk.str.Template('The ${animal} sounds like: "${noise}"');
disp(tpl.substitute( 'animal', 'cat', 'noise', 'meow' ));
disp(tpl.substitute( 'animal', 'dog', 'noise', 'woof' ));
```

Of course, if there are many placeholders, you can pass a structure instead:
```matlab
disp(tpl.substitute(struct( 'animal', 'dog', 'other', 'alien' ))); % this also works
```
and as you can see, the substitution can be only partial (so you can create another partial template from the result), and passing fields which are not placeholders does not cause any error.

If you want to ensure the substitution assigns all placeholders, and that all input fieldnames are used, you can set the member property `tpl.strict = true` prior to substitution. You can also list all the placeholders found in the text using the method `names = tpl.placeholders()`.

Finally, you can bind a template string to a file by calling `tpl = dk.str.Template( filename, true )`, instead of passing a string in input as we did previously.

Methods:
```
    tpl.clear() % reset object
    tpl.assign( text, isfilename=false ) % assign template string
    names = tpl.placeholders() % find placeholders in the text, and return their name
    text  = tpl.substitute(varargin) % substitute and return interpolated string

```

---

### <a name="spaces"/> `dk.str.singlespaces`

Signature:
```
    str = dk.str.singlespaces( str )
```

Replace any character that matches the [`\s` metacharacter](https://uk.mathworks.com/help/matlab/ref/regexp.html#inputarg_expression) with a single space.

Example:
```matlab
s = sprintf( 'This\n is\t an      example.' );
dk.str.singlespaces(s)
```

---

### <a name="caps"/> `dk.str.capfirst|capwords`

Signatures:
```
    str = dk.str.capfirst( str, lower_other=false )
    str = dk.str.capwords( str, lower_other=false )
```

Change the capitalisation of a string or text. Both methods run `dk.str.singlespaces` prior to capitalising characters (either just the first character with `capfirst`, or the first letter of every word with `capwords`), and optionally set all remaining characters to lowercase (see second argument).

Note that the beginning of words is detected with the regular expression `[ -]["']?\w`, so it includes dash-separated strings (capitalising each part independently) and strings within double or single quotes.

Example:
```matlab
s = sprintf('this is ''a "CAMEL-case"\t example');
dk.str.capfirst(s)      % This is 'a "CAMEL-case" example
dk.str.capfirst(s,true) % This is 'a "camel-case" example
dk.str.capwords(s,true) % This Is 'A "Camel-Case" Example
```

---

### <a name="strip"/> `dk.str.strip|lstrip|rstrip`

Signatures:
```
    s = dk.str.strip( s, chars='' )
    s = dk.str.lstrip( s, chars='' )
    s = dk.str.rstrip( s, chars='' )
```

Remove leading (`lstrip`) or trailing (`rstrip`) or both (`strip`) characters from a string.

The set of characters to be removed (input `chars`) should be specified with a _regular expression_ syntax; in particular it can contain metacharacters (eg `\w`) and ranges (eg `0-9`). The regular expression matching the substring(s) to be removed is simply `'[' chars ']*'`.

If no character is specified, these functions remove by default leading or trailing (or both) spacings matching the [`\s` metacharacter](https://uk.mathworks.com/help/matlab/ref/regexp.html#inputarg_expression).

Example:
```matlab
s = sprintf('\t*Starred text*\n');
dk.str.strip( s )       % *Starred text*
dk.str.strip( s, '*' )  % Starred text
dk.str.lstrip( s, '*' ) % Starred text*
dk.str.rstrip( s, '*' ) % *Starred text
```

---

### <a name="ext"/> `dk.str.set_ext|rem_ext|rep_ext`

Signatures:
```
    str = dk.str.set_ext( str, ext, dotc='.' )
    [str,rem] = dk.str.rem_ext( str, n=inf, dotc='.' )
    str = dk.str.rep_ext( str, ext, n=1 )
```

> Warning: the default behaviour for removing or replacing extensions with multiple parts (eg `.nii.gz`) is different.

Set (`set_ext`), remove (`rem_ext`) or replace (`rep_ext`) file extensions in a string.

When the extension contains multiple parts (eg `.nii.gz`) you can set the value `n` to specify manually how many "dot-parts" should be removed or replaced. By default all extensions are removed, but only the _last_ dot part is replaced.



Finally, note that the separating character (typically character `.`) can be replaced if needed.

Example:
```matlab
s = dk.str.set_ext('foo..bar','nii.gz') % foo..bar.nii.gz
dk.str.rem_ext( s, 'nii.gz' )           % foo..bar
dk.str.rem_ext( s, 3 )                  % foo.
dk.str.rep_ext( s, 'mat', 2 )           % foo..bar.mat
```

---

### <a name="numbers"/> `dk.str.numbers`

Signature:
```
    [pos,num] = dk.str.numbers( str, Option1, Option2, ... )
```

Extract numbers from string.
This implementation uses regular expressions to support floating-point and scientific notation formats.

The options can be specified as strings:

 - `'int'`: extract integers only
 - `'uint'`: extract unsigned integers only
 - `'once'`: stop searching after the first match

Example:
```matlab
[~,num] = dk.str.numbers('Example -234.0 with 01. multiple 10.7E-3 numbers.')              % [-234, 1, 0.0107]
[~,num] = dk.str.numbers('Example -234.0 with 01. multiple 10.7E-3 numbers.','int')        % [-234, 1]
[~,num] = dk.str.numbers('Example -234.0 with 01. multiple 10.7E-3 numbers.','uint')       % 1
[~,num] = dk.str.numbers('Example -234.0 with 01. multiple 10.7E-3 numbers.','int','once') % -234
```

---

### <a name="to_substruct"/> `dk.str.to_substruct`

Signature:
```
    sub = dk.str.to_substruct( str, ignorefirst )
```

Build a [`substruct`](https://uk.mathworks.com/help/matlab/ref/substruct.html) object from the input string, which can then be used with [`subsref`](https://uk.mathworks.com/help/finance/subsref.html) or [`subsasgn`](https://uk.mathworks.com/help/finance/subsasgn.html).
Optionally, the first part of the substruct can be ignored; this is useful for instance if it corresponds to the name of the variable being accessed/assigned.

Note that this implementation supports cell and/or multi-dimensional accesses, as well as range indices, including the indefinite range `:`.

Example:
```matlab
s = dk.str.to_substruct( 'foo(2).bar.baz{13}.arg(1,2,3)' );
t = subsasgn( struct(), s, 3 )
```
