# This script should merge all files from a given sample (the sample id is provided in the third argument)
# into a single file, which should be stored in the output directory specified by the second argument.
# The directory containing the samples is indicated by the first argument.


cat $1/$3 >> $2/$(echo $3|cut -d "-" -f1).fastq.gz
