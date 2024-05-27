#!/bin/bash

# Check if input file with SRA accessions is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <accession_file>"
    exit 1
fi

accession_file=$1

# Create a directory for the downloaded files
output_dir="sra_data"
mkdir -p $output_dir
mkdir -p logs

# Function to download and convert SRA accession
download_and_convert() {
    accession=$1
    echo "Processing $accession..."

    # Check if the prefetch step is already done
    if [ ! -f "logs/${accession}.prefetch_done" ]; then
        # Use prefetch to download the SRA file
        prefetch --progress $accession
        if [ $? -ne 0 ]; then
            echo "Failed to download $accession" | tee -a logs/errors.log
            return 1
        fi
        touch "logs/${accession}.prefetch_done"
    else
        echo "Prefetch already completed for $accession"
    fi
    
    # Check if the fasterq-dump step is already done
    if [ ! -f "logs/${accession}.fasterq_done" ]; then
        # Use fasterq-dump to convert the SRA file to FASTQ files
        fasterq-dump --split-files --outdir $output_dir --progress ${accession}
        if [ $? -ne 0 ]; then
            echo "Failed to convert $accession" | tee -a logs/errors.log
            return 1
        fi
        touch "logs/${accession}.fasterq_done"
    else
        echo "Fasterq-dump already completed for $accession"
    fi
    
    echo "Completed $accession"
}

# Read each SRA accession from the file and process it
while IFS= read -r accession; do
    download_and_convert $accession
done < "$accession_file"

echo "All accessions processed."
