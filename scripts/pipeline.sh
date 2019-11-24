#Download all the files specified in data/filenames
for url in $(cat data/urls) 
do
    bash scripts/download.sh $url data
done



# Download the contaminants fasta file, and uncompress it
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes 



#Index the contaminants file
mkdir -p  res/contaminants_idx
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx



# Merge the samples into a single file
mkdir -p out/merged
for sid in $(ls data/*.fastq.gz|cut -d "/" -f2| sort)
do
        bash scripts/merge_fastqs.sh data out/merged $sid
done



# TODO: run cutadapt for all merged files
mkdir out/trimmed log/cutadapt
for sample in $(ls out/merged)
do
        name=$(echo ${sample}|cut -d "." -f1)
        cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed -o out/trimmed/${name}.trimmed.fastq.gz out/merged/${sample} > log/cutadapt/${name}.log
done



#TODO: run STAR for all trimmed files
for fname in $(ls out/trimmed/*.fastq.gz)
do
        sid=$(basename $(echo $fname)|cut -d "." -f1)
        mkdir -p out/star/${sid}
        STAR --runThreadN 4 --genomeDir res/contaminants_idx --outReadsUnmapped Fastx --readFilesIn ${fname} --readFilesCommand zcat --outFileNamePrefix out/star/${sid}/
done



# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
for sid in $(ls out/merged/*.fastq.gz|cut -d "/" -f3| cut -d "." -f1)
do
        for log in $(ls log/cutadapt/$sid.log)
        do
                echo $sid >> log/pipeline.log
                echo "==========================================" >> log/pipeline.log
                cat log/cutadapt/$sid.log| grep "^Reads with adapters*"  >> log/pipeline.log
                cat log/cutadapt/$sid.log| grep "^Total basepairs*"  >> log/pipeline.log
        done

        for log in $(ls out/star/$sid/Log.final.out)
        do
                cat out/star/$sid/Log.final.out | grep "Uniquely mapped reads %" >> log/pipeline.log
                cat out/star/$sid/Log.final.out | grep "% of reads mapped to multiple loci" >> log/pipeline.log
                cat out/star/$sid/Log.final.out | grep "% of reads mapped to too many loci" >> log/pipeline.log
                echo >> log/pipeline.log
        done
done

