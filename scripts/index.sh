# This script should index the genome file specified in the first argument,
# creating the index in a directory specified by the second argument.

# The STAR command is provided for you. You should replace the parts surrounded by "<>" and uncomment it.

STAR --runThreadN 4 --runMode genomeGenerate --genomeDir $WD/res/contaminants_idx --genomeFastaFiles $WD/res --genomeSAindexNbases 9
