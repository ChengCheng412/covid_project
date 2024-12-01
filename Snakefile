rule download_articles:
    output:
        "data/pmids.xml",
        directory("data/articles")
    shell:
        "srun scripts/download_data.sh"
