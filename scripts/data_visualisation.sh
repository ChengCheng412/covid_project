#!/bin/bash
#SBATCH --account=SSCM033324            
#SBATCH --job-name=plot_word_sentiments 
#SBATCH --partition=teach_cpu           
#SBATCH --nodes=1                       
#SBATCH --ntasks-per-node=1             
#SBATCH --time=01:00:00                
#SBATCH --mem=2G                        
#SBATCH --output=logs/plot_word_sentiments.log  
#SBATCH --error=logs/plot_word_sentiments.err   

# Activate Conda environment
source /user/work/nu24390/miniforge3/bin/activate covid_project
mkdir -p results  # Create results directory if not exists

# Embed R script within bash script
Rscript --vanilla - <<EOF
# Load required libraries
library(tidyverse)
library(tidytext)

# Set input and output file paths
input_file <- "processed_data/processed_titles_cleaned.tsv"
output_plot <- "results/word_sentiment_trends_plot.png"

# Read data
articles_cleaned <- read_tsv(input_file, col_names = TRUE)

# Load NRC sentiment lexicon
sentiments <- get_sentiments("nrc") %>% distinct(word, sentiment)

# Join articles with sentiment lexicon, count sentiments per year
articles_sentiments <- articles_cleaned %>%
  inner_join(sentiments, by = "word") %>%
  count(Year, sentiment) %>%
  ungroup()

# Filter for positive and negative sentiments
filtered_sentiments <- articles_sentiments %>%
  filter(sentiment %in% c("positive", "negative"))

# Create stacked bar plot showing sentiment trends over time
plot <- ggplot(filtered_sentiments, aes(x = Year, y = n, fill = sentiment)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(title = "Sentiment Analysis of Long COVID Articles Over Time",
       x = "Year",
       y = "Count of Words",
       fill = "Sentiment") +
  theme_minimal()

# Save the plot
ggsave(output_plot, plot, width = 10, height = 6)

cat("Plot saved to", output_plot, "\n")
EOF


