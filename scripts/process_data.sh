#!/bin/bash
#SBATCH --account=SSCM033324           
#SBATCH --job-name=process_xml_job    
#SBATCH --partition=teach_cpu          
#SBATCH --nodes=1                      
#SBATCH --ntasks-per-node=1            
#SBATCH --time=01:00:00               
#SBATCH --mem=1G                      
#SBATCH --output=logs/process_xml.log  
#SBATCH --error=logs/process_xml.err  

# Create logs directory if not exists
mkdir -p logs

# Create output directory and output file
output_file="processed_data/processed_articles.tsv"
mkdir -p processed_data

# Write header to output file
echo -e "PMID\tYear\tTitle" > $output_file

# Extract all PMIDs from pmids.xml file
pmid_list=$(grep -oP '(?<=<Id>)[0-9]+' data/pmids.xml)

# Loop through each PMID
for pmid in $pmid_list; do
    # Construct XML file path
    file="data/article-data-$pmid.xml"

    # Check if file exists
    if [ ! -f "$file" ]; then
        echo "File for PMID $pmid not found, skipping." >&2
        continue
    fi

    # Extract year (try from PubDate first, then from ArticleDate)
    year=$(grep -oP '<PubDate>.*?<Year>\K[0-9]{4}' "$file" | head -n 1)

    # Skip if year is missing
    if [ -z "$year" ]; then
        echo "Skipping file $file due to missing year." >&2
        continue
    fi

    # Extract title
    title=$(grep -oP '<ArticleTitle>\K.*?(?=</ArticleTitle>)' "$file" | sed 's/<[^>]*>//g')

    # Skip if title is missing
    if [ -z "$title" ]; then
        echo "Skipping file $file due to missing title." >&2
        continue
    fi

    # Write output entry
    echo -e "$pmid\t$year\t$title" >> "$output_file"
done

echo "Processing completed. Output saved to $output_file."
