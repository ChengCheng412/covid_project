#!/bin/bash
#SBATCH --account=SSCM033324           # 账户名
#SBATCH --job-name=process_titles_job   # 作业名
#SBATCH --partition=cpu           # 分区（队列），替换为适合的分区
#SBATCH --nodes=1                       # 使用 1 个节点
#SBATCH --ntasks-per-node=1             # 每个节点使用 1 个任务
#SBATCH --time=01:00:00                 # 作业运行时间上限（例如 1 小时）
#SBATCH --mem=2G                        # 所需内存（例如 2GB）
#SBATCH --output=logs/process_titles.log  # 标准输出日志文件
#SBATCH --error=logs/process_titles.err   # 标准错误日志文件

# 激活 Conda 环境
source /user/work/nu24390/miniforge3/bin/activate covid_project

# 直接在脚本中嵌入 R 代码
Rscript --vanilla - <<EOF
# 加载必要的包
library(tidyverse)
library(tidytext)
library(SnowballC)

# 设置输入和输出文件路径
input_file <- "processed_data/processed_articles.tsv"
output_file <- "processed_data/processed_titles_cleaned.tsv"

# 读取数据
articles <- read_tsv(input_file, col_names = TRUE)

# 数据预处理
# 1. 使用 unnest_tokens() 将标题分成单词
# 2. 移除停用词和数字
# 3. 使用 SnowballC 进行词干提取
articles_cleaned <- articles %>%
  unnest_tokens(word, Title) %>% # 将标题分解成单词
  anti_join(stop_words, by = "word") %>% # 移除停用词
  filter(!str_detect(word, "\\\\d+")) %>% # 注意这里，双反斜杠来正确匹配数字
  mutate(word = wordStem(word)) %>% # 词干提取
  count(PMID, Year, word, sort = TRUE) # 统计每个单词的频率

# 保存结果
write_tsv(articles_cleaned, output_file)

cat("Text processing completed. Output saved to", output_file, "\n")
EOF
