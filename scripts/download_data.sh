#!/bin/bash
#SBATCH --account=SSCM033324           # Account name for the job
#SBATCH --job-name=download_data_job    # Job name
#SBATCH --partition=cpu                 # Partition (queue)
#SBATCH --nodes=1                       # Number of nodes
#SBATCH --ntasks-per-node=1             # Tasks per node
#SBATCH --time=03:00:00                 # Max runtime (3 hours)
#SBATCH --mem=1G                        # Memory requirement (1GB)
#SBATCH --output=logs/download_data.log # Output log file
#SBATCH --error=logs/download_data.err  # Error log file

mkdir -p logs                          # Create logs directory
mkdir -p data                          # Create data directory

# Download PubMed IDs related to "long covid"
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=%22long%20covid%22&retmax=10000" > data/pmids.xml

# Loop through each PMID to download article details
for pmid in $(grep -oP '(?<=<Id>)[^<]+' data/pmids.xml); do
    if [ -f "data/article-data-$pmid.xml" ]; then
        echo "Article data for PMID: $pmid already exists, skipping download."
        continue
    fi

    # Download article data for the given PMID
    echo "Downloading article data for PMID: $pmid"
    curl -f "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=${pmid}" -o "data/article-data-$pmid.xml"

    # If download fails, remove the partial file
    if [ $? -ne 0 ]; then
        echo "Failed to download article data for PMID: $pmid, skipping..."
        rm -f "data/article-data-$pmid.xml"
        continue
    fi

    # Sleep for 0.1 seconds to avoid overwhelming the server
    sleep 0.1
done
