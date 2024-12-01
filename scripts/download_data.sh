#!/bin/bash
#SBATCH --account=SSCM033324
#SBATCH --job-name=download_data_job
#SBATCH --partition=teach_cpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=03:00:00
#SBATCH --mem=1G
#SBATCH --output=logs/download_data_%j.log
#SBATCH --error=logs/download_data_%j.err

mkdir -p logs
mkdir -p data

curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=%22long%20covid%22&retmax=10000" > data/pmids.xml

for pmid in $(grep -oP '(?<=<Id>)[^<]+' data/pmids.xml); do
    if [ -f "data/article-data-$pmid.xml" ]; then
        echo "Article data for PMID: $pmid already exists, skipping download."
        continue
    fi

    echo "Downloading article data for PMID: $pmid"
    curl -f "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=${pmid}" -o "data/article-data-$pmid.xml"

    if [ $? -ne 0 ]; then
        echo "Failed to download article data for PMID: $pmid, skipping..."
        rm -f "data/article-data-$pmid.xml"
        continue
    fi

    sleep 1
done
