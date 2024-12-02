#Main Files Overview

#1. download_data_job.sh
This script is responsible for downloading data from PubMed. It retrieves the PubMed IDs of articles related to "long COVID" and then downloads the metadata of each article in XML format. The data is saved in the data/ directory, and the script uses Slurm to manage the job on a cluster.

Note: Due to issues with using Snakemake for the download_data.sh file, the command srun scripts/download_data.sh was used directly to execute the download step. 

#2. process_xml_job.sh
Purpose: This script extracts metadata from the downloaded XML files. It processes each file to extract the publication year, title, and PubMed ID (PMID) of the articles. Articles missing essential information are skipped. The cleaned data is saved as a tab-separated file (processed_data/processed_articles.tsv).
Related Snakefile Rule:
rule process_articles:
    input:
        "data/pmids.xml"
    output:
        "processed_data/processed_articles.tsv"
    shell:
        """
        sbatch --wait scripts/process_xml_job.sh
        """

#3. process_titles_job.sh
Purpose: This script cleans and processes the article titles. It tokenizes each title into individual words, removes stop words, and applies stemming using R and the tidyverse and tidytext packages. The output, containing word frequencies for each article, is saved as processed_data/processed_titles_cleaned.tsv.
Related Snakefile Rule:
rule process_titles:
    input:
        "processed_data/processed_articles.tsv"
    output:
        "processed_data/processed_titles_cleaned.tsv"
    shell:
        """
        sbatch --wait scripts/process_titles_job.sh
        """
    
#4. plot_word_sentiments_job.sh
Purpose: This script performs sentiment analysis on the words extracted from the article titles. Using the NRC sentiment lexicon, it categorizes words as positive or negative. A stacked bar plot is then generated to illustrate the change in positive and negative sentiments over time. The plot is saved as results/word_sentiment_trends_plot.png.
Related Snakefile Rule:
rule data_visualisation:
    input:
        "processed_data/processed_titles_cleaned.tsv"
    output:
        "results/word_sentiment_trends_plot.png"
    shell:
        """
        sbatch --wait scripts/plot_word_sentiments_job.sh
        """


#The complete code and running results at git@github.com:ChengCheng412/covid_project.git
view
