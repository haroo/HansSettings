#!/bin/bash
##
## Cleanup script, removes orphaned bouquet files
##
## (c) 2019 PLi Association, WanWizard
##
## 20190911 - Initial version
##

################################################################################
# Function: clean a direcory based on an index file
################################################################################
function cleanup
{
	# array for the userbouquets
	BOUQUETS=()

	# make sure we have all arguments
	if [ "$#" -ne "2" ]; then
		echo "Incorrect number of arguments to cleanup()!"
		exit 1
	fi

	# validate arguments
	if [ ! -d $1 ]; then
		echo "cleanup() : $1 is not a valid directory"
		exit 1
	fi
	if [ "$2" != "tv" -a "$2" != "radio" ]; then
		echo "cleanup() : second parameter must be either \"tv\" or \"radio\"!"
		exit 1
	fi

	echo "- Processing $2 in $1..."

	# loop over the index file
	while IFS="" read -r line || [ -n "$line" ]; do
		line=`echo $line | cut -d'"' -f 2`
		# add it to the list if it is a userbouquet
		if [[ $line = userbouquet* ]]; then
			BOUQUETS+=($line)
			if [ ! -f $1/$line ]; then
				echo "  Missing bouquet: $line"
			fi
		fi
	done < $1/bouquets.$2

	# loop over the userbouquet files
	cd $1
	for f in userbouquet.*.$2; do
		if [[ ! " ${BOUQUETS[@]} " =~ " ${f} " ]]; then
			echo "  Orphaned bouquet: $f"
			rm -f $f
		fi
	done
	cd - > /dev/null
}

################################################################################
# Variables controlling the process.
################################################################################
CHECK=0

# check if we're in the right repo directory
if [ -f .git/config ]; then
	if grep -q "haroo/HansSettings" .git/config ; then
		CHECK=1
	fi
fi

# bail out if we're not
if [ $CHECK -eq 0 ]; then
	echo "This directory doesn't contain the HansSettings repository!"
	exit 1
fi

# iterate over the directory
for d in *; do

	# we're only intrested in directories
	if [ -d $d ]; then

		# does it have a TV bouquets index file
		if [ -f $d/bouquets.tv ]; then
			cleanup $d tv
		fi

		# does it have a radio bouquets index file
		if [ -f $d/bouquets.radio ]; then
			cleanup $d radio
		fi

	fi

done

# done
exit 0
