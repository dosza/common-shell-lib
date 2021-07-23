# Common Shell Library
<p align="center">
	  <a href="https://github.com/DanielOliveiraSouza/common-shell-lib/archive/v0.2.0.zip"><img src="https://img.shields.io/badge/Release-v0.2.0-green"/> </a><img src="https://img.shields.io/badge/language-shell-blue"/> <a href="https://github.com/DanielOliveiraSouza/common-shell-lib/LICENSE.md"><img src="https://img.shields.io/github/license/danieloliveirasouza/common-shell-lib"/></a>
</p>

What is?
---
A  Shell Script Library that simplifies  that provides several functions that simplify the execution of complex commands like sed, shell expansions, among others ...

Motivation 
---
[UFMT-LAB-Tools](https://github.com/DanielOliveiraSouza/ufmt-cua-lab-tools),[PostInstall](https://github.com/DanielOliveiraSouza/Linux-PostInstall) and [LAMW Manager](https://github.com/DanielOliveiraSouza/LAMW4Linux-installer) are command line tools that automate the installation of many software.
From the development of these tools, it is observed that there is a set of routines that can be standardized.
This level of automation usually requires the execution of commands with poorly readable syntax. 
The idea is to provide a level of abstraction (generic) that the *user* can use in his context.



Functions
---
Note: a shell function is declared by Name(){COMMANDS;} or function Name{ COMMANDS;}
Each argument is referenced by \$1..\$n.

The list below includes the parameters within the parentheses for teaching purposes.
+ replaceLine(file,string_to_find,string_to_replace)
+ deleteLine(file,line_to_delete)
+ scappeString(str) //
+ AptInstall(packages) //install apt packages

New: String manipulation functions
---
+ strLen(str) //returns to output of length of string, a equivalent C strlen()
+ strGetSubstring(str,offset,length) // returns to output a str delimeted of offset and lenght
+ strGetCurrentChar(str,index) //returns to output a char delimited by index, a equivalent C str[index];
+ Split(str,delimiter,ref_array) // split (using a builtin command) a string and store in ref_array ( ref_array is a reference to array )
+ splitStr(str,delimiter,ref_array) split a string and store in ref_array

New: Array Functions
---
+ arrayMap(array,item, '{commands...}') // executes 'one or more commands' on each item in an array.
+ arrayFilter(array, item, filtersItens, '[conditions]')
+ arrayToString(array)
+ arraySlice(array,offset,arraySliced) || arraySlice(array,offset,length,arraySliced)
---

### sample:

```bash
#!/bin/bash 
# without common-shell-lib
sed  -i 's/stretch/buster/g' /etc/fstab

#with common shell library
#!/bin/bash
source ./common-shell-lib.sh
replaceLine /etc/apt/sources.list  "stretch" "buster" 

  ```	
### sample: A length string
```bash
str="0000-000-000"
strLen "$str" #write 12 in output
```

### sample: Splitting a string 

```bash
source ./common-shell-lib.sh
#split a string delimeted by ' ' (blank space)
my_array=()
str="Hello World!"
Split "$str" " " my_array # my_array=("Hello" "World!")
```

### sample: Getting a substring using a *offset* and *length*
```bash
source ./common-shell-lib.sh
str="user@pc:~"
sub_str="$(strGetSubstring "$str" 5 2)" #sub_str="pc"
```

### sample: Installing packages using arrayMap
```bash
source ./common-shell-lib
packages=(gcc g++ wget)
arrayMap  packages package 'sudo apt-get install $package -y
```
**Notes**:
**packages** is array variable
**package** is name to iterator
'**sudo apt-get install $package**'  is a command to execute for each item in packages


### sample: Filter pars numbers and store in pars.
```bash
source ./common-shell-lib
numbers=({357..368})
pars=()
arrayFilter numbers number pars '((number %2 == 0))'
#show pars
arrayToString pars
```

### sample: Filter names with start of letter D
```bash
source ./common-shell-lib
names=(Davros Daniel Debra 'Yan Mordock' Woody)
matchD=()
arrayFilter names name matchD 'echo "$name" | grep ^D'
```
