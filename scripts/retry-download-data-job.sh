#!/bin/bash
#SBATCH --account=SSCM033324
#SBATCH --job-name=retry_download_data_job
#SBATCH --partition=cpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=01:00:00
#SBATCH --mem=1G
#SBATCH --output=logs/retry_download_data_%j.log
#SBATCH --error=logs/retry_download_data_%j.err


failed_pmids_file="logs/failed_pmids.txt"
log_file="logs/download_data_10845920.log"

if [ ! -f "$log_file" ]; then
    echo "Log file $log_file does not exist. No failed PMIDs to retry."
    exit 0
fi

grep "Failed to download article data for PMID" "$log_file" | awk '{print $8}' > "$failed_pmids_file"


if [ ! -s "$failed_pmids_file" ]; then
    echo "No failed PMIDs to retry."
    exit 0
fi

while read pmid; do


    echo "Retrying download for article data for PMID: $pmid"
    curl -f "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=${pmid}" -o "data/article-data-$pmid.xml"

    if [ $? -ne 0 ]; then
        echo "Still failed to download article data for PMID: $pmid."
    else
        echo "Successfully downloaded article data for PMID: $pmid on retry."
    fi

    sleep 1
done < "$failed_pmids_file"