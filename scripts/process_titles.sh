#!/bin/bash
#SBATCH --account=SSCM033324           
#SBATCH --job-name=process_titles_job   
#SBATCH --partition=cpu           
#SBATCH --nodes=1                       
#SBATCH --ntasks-per-node=1            
#SBATCH --time=01:00:00                 
#SBATCH --mem=2G                        
#SBATCH --output=logs/process_titles.log  
#SBATCH --error=logs/process_titles.err   

# Activate Conda environment
source /user/work/nu24390/miniforge3/bin/activate covid_project

# R script embedded within the bash script
Rscript --vanilla - <<EOF
# Load necessary libraries
library(tidyverse)
library(tidytext)
library(SnowballC)

# Set input and output file paths
input_file <- "processed_data/processed_articles.tsv"
output_file <- "processed_data/processed_titles_cleaned.tsv"

# Read data
articles <- read_tsv(input_file, col_names = TRUE)

# Data preprocessing
articles_cleaned <- articles %>%
  unnest_tokens(word, Title) %>% # Split titles into words
  anti_join(stop_words, by = "word") %>% # Remove stop words
  filter(!str_detect(word, "\\\\d+")) %>% # Remove numbers
  mutate(word = wordStem(word)) %>% # Perform stemming
  count(PMID, Year, word, sort = TRUE) # Count word frequency

# Save result
write_tsv(articles_cleaned, output_file)

cat("Text processing completed. Output saved to", output_file, "\n")
EOF
