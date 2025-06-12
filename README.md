# INT64 CLI Calculator

INT64 CLI Calculator is a lightweight x86-64 calculator with command-line interface, which is capable of handling 4 integer operations:  
    + (addition)  
    - (subtraction)  
    * (multiplication)  
    / (integer division, it is possible to use ':' instead)  
    ^ (natural power)  

## Installation

0. Make sure you have installed:
    Netwide Assembler (NASM)  
    GNU Linker (ld)  
    GNU Make (make)  
If you want to debug:  
    GNU Debugger (gdb)  

1. Clone the repository:  

```bash
git clone https://github.com/nomadrussian/INT64_CLI_Calculator
```

2. Use "Make" utility to compile the project:

```bash
make bin
```

3. If you want to use gdb, compile the debug version (with debug info):

```bash
make dbg
```

4. You can compile both by just calling "Make":

```bash
make
```

5. To run INT64 CLI Calculator:

```bash
./run
```

6. To debug you must have GNU Debugger installed, then just run:

```bash
./debug
```

## Usage

After having INT64 CLI Calculator launched, simply type in you two operands and the operation between them.
For example, this is how you can divide 563 by -65:

```bash
563/-65
```
Then press [Enter], and you'll get the result: -8 and the remainder -43 in the round brackets.
```bash
563/-65 
-8 (43)
```

Or, e.g., the power:
```bash
15^4
```
and you'll get:
```bash
15^4
50625
```

The calculator is capable of operating with numbers from –9223372036854775807 (-(2^63-1)) up to 9223372036854775807 (2^63-1).
In case of overflow the result is undefined.

When ready to quit, type in 'q' or 'Q' and [Enter] to finish:
```bash
q
```

## License

[MIT](https://choosealicense.com/licenses/mit/)
