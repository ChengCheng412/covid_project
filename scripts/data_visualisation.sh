#!/bin/bash
#SBATCH --account=SSCM033324            # 账户名
#SBATCH --job-name=plot_word_sentiments # 作业名
#SBATCH --partition=teach_cpu           # 分区（队列）
#SBATCH --nodes=1                       # 使用 1 个节点
#SBATCH --ntasks-per-node=1             # 每个节点使用 1 个任务
#SBATCH --time=01:00:00                 # 作业运行时间上限
#SBATCH --mem=2G                        # 所需内存
#SBATCH --output=logs/plot_word_sentiments.log  # 标准输出日志文件
#SBATCH --error=logs/plot_word_sentiments.err   # 标准错误日志文件

# 激活 Conda 环境
source /user/work/nu24390/miniforge3/bin/activate covid_project
mkdir -p results
# 直接在脚本中嵌入 R 代码
Rscript --vanilla - <<EOF
# 加载必要的包
library(tidyverse)
library(tidytext)

# 设置输入文件和输出文件路径
input_file <- "processed_data/processed_titles_cleaned.tsv"
output_plot <- "results/word_sentiment_trends_plot.png"

# 读取数据
articles_cleaned <- read_tsv(input_file, col_names = TRUE)

# 使用 NRC 词汇库进行情感分析
# 加载情感词汇库
sentiments <- get_sentiments("nrc")

sentiments <- sentiments %>% distinct(word, sentiment)
# 将文章标题中的单词与情感词汇库结合，提取出情感类别
articles_sentiments <- articles_cleaned %>%
  inner_join(sentiments, by = "word") %>%
  count(Year, sentiment) %>% # 统计每年每个情感类别的频率
  ungroup()

# 过滤出积极和消极情感
filtered_sentiments <- articles_sentiments %>%
  filter(sentiment %in% c("positive", "negative"))

# 创建堆叠条形图，展示积极和消极情感的随时间变化趋势
plot <- ggplot(filtered_sentiments, aes(x = Year, y = n, fill = sentiment)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(title = "Sentiment Analysis of Long COVID Articles Over Time",
       x = "Year",
       y = "Count of Words",
       fill = "Sentiment") +
  theme_minimal()

# 保存图像
ggsave(output_plot, plot, width = 10, height = 6)

cat("Plot saved to", output_plot, "\n")
EOF

