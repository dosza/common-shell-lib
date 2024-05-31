# Extended Bash Library

<p align="center"><a href="https://github.com/dosza/ext-bash/archive/master.zip"><img src="https://img.shields.io/badge/Release-v0.3.3-green"/></a>
 <a href="https://github.com/dosza/ext-bash/LICENSE.md"><img src="https://img.shields.io/badge/language-shell-blue"></a> <img src="https://img.shields.io/github/license/dosza/ext-bash"/></p>

What is?
---
**Extended Bash Library** is a superset for the bash shell!
This superset aims to create a more readable shell script and add functionality inspired by other languages, such as pyhton and javascript.

Some methods have been adapted from javascript that work in a similar way, such as:
+	``` arrayMap()```: works similar to Array.map, but does not return an array
+	``` arrayFilter()```: works with syntax and behavior similar to array.filter, but the penultimate argument must be the NAME of the return array
+	``` forEach()```, a function that at each iteration points a reference to the current item in an array

From python:
+	``` len()```, returns to stdout the size of an array, the size of a string passed by reference, or a simple string
+	``` Split()```, has the same behavior as python's split() method

#### Curiosity ####

Previously the library was called "Common Shell Library", but from now on ( 07/28/2022 ) it is called "Extended Bash Library"
<br/>"Extended Bash Library" name was inspired by the extended family of filesystems (ext2, ext3, ext4)...

Pseudo keywords
---
Bash does not have these keywords, but aliases have been created to make it easier to declare certain types
+	```int```, declare  variable with 'integer' attribute
+	``` dict```, declare variable as associative array
+	``` newPtr```, declare variable as reference to named variable

### Considerations about scope of variables: ###
When using these pseudotypes in a function, the variables are locally scoped!<br/>To declare them as global variables, add the -g parameter<br/>Local variables are visible to the function in which they are defined, as well as their children¹


Example: 
```bash
f(){
	# Makes X a global variable
	int -g X=0
	# Makes NAMES a global variable
	dict -g NAMES=()
}
f
```



Advantages
---
Rapid development of installation and configuration scripts using WriterFileln function families
<br/>Support for referencing variables using the newPtr keyword (alias to ```declare -n```)

+ Easy development of installers for debian systems, using custom APT functions
+ Facilitates repository configuration, using the function
+ Import some concepts and facilities from python and javascripts to bash
+ It is a library that has passed unit tests!!

Functions
---
Note: a shell function is declared by Name(){COMMANDS;} or function Name{ COMMANDS;}
Each argument is referenced by \$1..\$n.

The list below includes the parameters within the parentheses for teaching purposes.
+	```replaceLine(file,string_to_find,string_to_replace)```
+	```deleteLine(file,line_to_delete)```
+	```scappeString(str)```//
+	```AptInstall(packages)``` //install apt packages

New: String manipulation functions
---
+	```strLen(str)``` //returns to output of length of string, a equivalent C strlen()
+	```strGetSubstring```(str,offset,length) // returns to output a str delimeted of offset and lenght
+	```strGetCurrentChar(str,index)``` //returns to output a char delimited by index, a equivalent C str[index];
+	```Split(str,delimiter,ref_array)``` // split (using a builtin command) a string and store in ref_array ( ref_array is a reference to array )
+	```splitStr(str,delimiter,ref_array)``` split a string and store in ref_array

New: Array Functions
---

#### Important note!! ####

In array functions the command must be enclosed in single quotes: 

+	```arrayMap(array,item, '{commands...}')``` // executes 'one or more commands' on each item in an array.
+	```arrayFilter(array, item, filteredItems, '[conditions]')```
+	```arrayToString(array)```
+	```arraySlice(array,offset,arraySliced)``` || ```arraySlice(array,offset,length,arraySliced)```
+	```forEach(array,item '{commands...}')``` //execute one or more commands, on each item in array, forEach is a function similar to arrayMap, but the iterator is a reference to the current element of the array
+	```initArrayAsCommand(array, '{commands'})``` //init an array as output of '{ commands }'


New: APT functions
---
This family call APT functions with -y and check erros param
+	``` AptInstall(args...)``` #install packages without need confirm action
+	``` getCurrentDebianFrontend()``` # set (if is possible) DEBIAN_FRONTEND=
+	``` getAptKeys(array_key_ref)``` # import apt keys to Apt from array of Urls: note
	+	Solve ```apt-key``` deprecatation

+	``` getDebPackVersion``` # returns a version of package  (.deb) installed
+	``` ConfigureSourcesListByScript(scripts_url)``` configure sources from array of url scripts (apt)
+	``` ConfigureSourcesList(mirrors,apt_keys,repositories)```, configure sources
	+	ConfigureSourcesList now supports new APT repository signature
	sample:
	```sources.list
	deb [arch=amd64 signed-by=/usr/share/repo.gpg] https://deb.repo.com/debian main 
	```


## Samples:

### len function
Note: The ```len``` function can determine to infer the type of argument, if it is the name of a variable or a simple string


#### A length of ${#names[@]}
```bash
unset names
names=({1..20..2})
len names 
```
#### A lenght of ${#names}
```bash
unset names
names='Davros' 
# Returns 6 to stdout
len names
```
#### Sample return size of 'names' string
```bash
unset names
# Returns 5 to stdout
len names 
```
### sample: Splitting a string 
```bash
source ./extended-bash.sh
#split a string delimeted by ' ' (blank space)
my_array=()
str="Hello World!"
Split "$str" " " my_array # my_array=("Hello" "World!")
```

### sample: Getting a substring using a *offset* and *length*
```bash
source ./extended-bash.sh
str="user@pc:~"
sub_str="$(strGetSubstring "$str" 5 2)" #sub_str="pc"
```

### sample: Installing packages using arrayMap
```bash
source ./extended-bash.sh
packages=(gcc g++ wget)
arrayMap  packages package 'sudo apt-get install $package -y
```
**Notes**:
**packages** is array variable
**package** is name to iterator
'**sudo apt-get install $package**'  is a command to execute for each item in packages


### sample: Filter pars numbers and store in pars.
```bash
source ./extended-bash.sh
numbers=({357..368})
pars=()
arrayFilter numbers number pars '((number %2 == 0))'
#show pars
arrayToString pars
```

### sample: Filter names with start of letter D
```bash
source ./extended-bash.sh
names=(Davros Daniel Debra 'Yan Mordock' Woody)
matchD=()
regex_matched_to_d='^D'
arrayFilter names name matchD '[[ "$name" =~ $regex_matched_to_d ]]'
```

### sample: Calculing five times table with forEach
```bash
source ./extended-bash.sh
five_times_table=({0..10})
  forEach five_times_table number 'number=$(echo "$number * 5"| bc )'
  arrayMap five_times_table multiple number 'echo "5 * $number = $multiple"' #printing five times table
```

### sample: setting up 3rd party repository quickly

```bash
source ./extended-bash.sh

#example: configure google chrome, sublime text and microsoft teams repository!
repositories=(
	"/etc/apt/sources.list.d/google-chrome.list"
	"/etc/apt/sources.list.d/sublime-text.list"
	"/etc/apt/sources.list.d/geogebra.list"
	"/etc/apt/sources.list.d/teams.list")

mirrors=(
	'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' 
	'deb https://download.sublimetext.com/ apt/stable/' 
	'deb http://www.geogebra.net/linux/ stable main'   
	"deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main")

apt_key_url_repositories=(
	"https://dl-ssl.google.com/linux/linux_signing_key.pub"
	"https://static.geogebra.org/linux/office@geogebra.org.gpg.key"
	"https://packages.microsoft.com/keys/microsoft.asc")

# Note: requires admin
ConfigureSourcesList apt_key_url_repositories mirrors repositories
```

### sample: setting repository by url script download
```bash
source ./extended-bash.sh
# Configuring nodejs repository sample
scripts_url=(
  https://deb.nodesource.com/setup_lts.x 
)
ConfigureSourcesListByScript scripts_url #note requires admin 
```


References
---
[1](https://linux.die.net/man/1/bash) Bash Manual.