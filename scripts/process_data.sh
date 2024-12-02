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

# 创建日志目录
mkdir -p logs

# 创建输出目录和输出文件
output_file="processed_data/processed_articles.tsv"
mkdir -p processed_data

# 写入表头
echo -e "PMID\tYear\tTitle" > $output_file

# 从 pmids.xml 文件中提取所有 PMID
pmid_list=$(grep -oP '(?<=<Id>)[0-9]+' data/pmids.xml)

# 遍历每一个 PMID
for pmid in $pmid_list; do
    # 构建 XML 文件的路径
    file="data/article-data-$pmid.xml"

    # 检查文件是否存在
    if [ ! -f "$file" ]; then
        echo "File for PMID $pmid not found, skipping." >&2
        continue
    fi


    # 提取年份（先从 PubDate 尝试，如果失败再从 ArticleDate）
    year=$(grep -oP '<PubDate>.*?<Year>\K[0-9]{4}' "$file" | head -n 1)
    if [ -z "$year" ];then
        year=$(grep -oP '<ArticleDate[^>]*><Year>\K[0-9]{4}' "$file" | head -n 1)
    fi

    # 如果年份为空，则跳过该条目
    if [ -z "$year" ]; then
        echo "Skipping file $file due to missing year." >&2
        continue
    fi

    # 提取标题
    title=$(grep -oP '<ArticleTitle>\K.*?(?=</ArticleTitle>)' "$file" | sed 's/<[^>]*>//g')

    # 如果标题为空，则跳过该条目
    if [ -z "$title" ]; then
        echo "Skipping file $file due to missing title." >&2
        continue
    fi

    # 确保每个条目只有一次输出
    echo -e "$pmid\t$year\t$title" >> "$output_file"
done

echo "Processing completed. Output saved to $output_file."

