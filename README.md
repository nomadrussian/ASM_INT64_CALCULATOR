# INT64 CLI Calculator

__INT64 CLI Calculator__ is a lightweight x86-64 calculator with command-line interface, which is capable of handling 4 integer operations:  
&nbsp;__+__ _(addition)_  
&nbsp;__-__ _(subtraction)_  
&nbsp;__*__ _(multiplication)_  
&nbsp;__/__ _(integer division, it is possible to use '___:___' instead)_  
&nbsp;__^__ _(natural power)_  

## Installation

0. Make sure you have installed:  
&nbsp;__Netwide Assembler__ (___nasm___)  
&nbsp;__GNU Linker__ (___ld___)  
&nbsp;__GNU Make__ (___make___)  

If you want to debug, also make sure you have __GNU Debugger__ (___gdb___) on your computer.

1. Clone the repository:  

```bash
git clone https://github.com/nomadrussian/INT64_CLI_Calculator
```

2. Use __Make__ utility to compile the project:

```bash
make bin
```

3. If you want to use __GDB__, compile the debug version (with debug info):

```bash
make dbg
```

4. You can compile both by just calling __Make__ without arguments:

```bash
make
```

5. To run __INT64 CLI Calculator__:

```bash
./run
```

6. To debug you must have __GNU Debugger__ installed, then just run:

```bash
./debug
```

7. If you wanna clean the build, also use __Make__:
```bash
make clean_bin            # cleans what was built through $ make bin
make clean_debug          # cleans what was built through $ make dbg
make clean                # cleans both
```

## Usage

After having __INT64 CLI Calculator__ launched, simply type in you two operands and the operation between them.
For example, this is how you can divide _563_ by _-65_:

```bash
563/-65
```
Then press __[Enter]__, and you'll get the result: _-8_ and the remainder _-43_ in the round brackets.
```bash
563/-65 
-8 (43)
```

Or, for example, this is how natural powers are calculated:
```bash
15^4
```
The result is:
```bash
15^4
50625
```

The calculator is capable of operating with numbers from _–9223372036854775807_ (_-(2^63-1)_) up to _9223372036854775807_ (_2^63-1_).
__In case of overflow the result is undefined__.

When ready to quit, type in '__q__' or '__Q__' and press __[Enter]__ to finish:
```bash
q
```

## License

[MIT](https://choosealicense.com/licenses/mit/)
