# rule download_articles:
#     output:
#         "data/pmids.xml"
        
#     shell:
#         """
#         bash scripts/download_data.sh
#         """
rule process_articles:
    input:
        "data/pmids.xml"  # 指定整个 data/articles 目录作为输入
    output:
        "data/processed_articles.tsv"  # 生成的输出文件
    shell:
        """
        sbatch scripts/process_data.sh
        """