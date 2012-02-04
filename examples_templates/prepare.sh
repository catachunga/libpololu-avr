#!/bin/sh

set -ue

example=$1
device=$2
mcu=$3
device_specific_macro=$4

example_template=examples_templates/$example
example_dir=examples/$device/$example

mkdir -p $example_dir

# Copy the source files.
cp -a $example_template/*.[ch] $example_dir/

# Create the Makefile using concatenation.
cat examples_templates/template_$device.mk $example_template/Makefile > $example_dir/Makefile

# Copy and edit the AVR Studio 4 project file.
cat $example_template/*.aps \
	| sed "s/<PART>[^<]*<\/PART>/<PART>$mcu<\/PART>/" \
	| sed "s/<LIB>libpololu[^<]*\.a<\/LIB>/<LIB>libpololu_$device.a<\/LIB>/" \
	| sed "s/<OPTIONSFORALL>/<OPTIONSFORALL>-D$device_specific_macro /" \
	> $example_dir/$example.aps

# Copy and edit the AVR Studio 5 project file.
cat examples_templates/test.avrgccproj \
	| sed "s/<avrdevice>[^<]*<\/avrdevice>/<avrdevice>$mcu<\/avrdevice>/" \
	| sed "s/<Value>pololu_[^<]*<\/Value>/<Value>pololu_$device<\/Value>/" \
	> $example_dir/$example.avrgccproj

if [ $device_specific_macro ]
then
  sed -i "s/<avrgcc.compiler.symbols.DefSymbols><ListValues><\/ListValues><\/avrgcc.compiler.symbols.DefSymbols>/<avrgcc.compiler.symbols.DefSymbols><ListValues><Value>$device_specific_macro<\/Value><\/ListValues><\/avrgcc.compiler.symbols.DefSymbols>/" $example_dir/$example.avrgccproj
fi


# Copy and edit the AVR Studio 5 solution file.
cat examples_templates/test.avrsln \
	| sed "s/\"test/\"$example/g" \
	> $example_dir/$example.avrsln