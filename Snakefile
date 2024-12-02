#Failed to use snakemaker for the download_data.sh file,so i just use "srun  scripts/download_data.sh" to run download_data.sh
# rule download_articles:
#     output:
#     "data/data/pmids.xml"
#     shell:
#         """
#         srun  scripts/download_data.sh
#         """
rule process_articles:
    input:
        "data/pmids.xml"  
    output:
        "processed_data/processed_articles.tsv"  
    shell:
        """
        sbatch --wait scripts/process_data.sh
        """
rule process_titles:
    input:
        "processed_data/processed_articles.tsv"  
    output:
        "processed_data/processed_titles_cleaned.tsv"  
    shell:
        """
        sbatch --wait scripts/process_titles.sh
        """
rule data_visualisation:
    input:
        "processed_data/processed_titles_cleaned.tsv"  
    output:
        "results/word_sentiment_trends_plot.png"  
    shell:
        """
        sbatch --wait scripts/data_vi*on.sh
        """