library(ggplot2)
library(dplyr)
library(tidyr)
library(cowplot)
library(tidyverse)

#figS7,8 ,figS13C

g_legend <- function(a.gplot){
  tmp <- ggplotGrob(a.gplot)
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}

custom_colors <- c(
  "Female" = "pink",
  "Male" = "lightblue",
  "II" = "yellow",
  "III" = "orange",
  "bone,brain" = "purple",
"pleura,bone" = "#1F77B4FF", 
"pleura" = "#2CA02CFF", 
"bone" = "#D62728FF",
"lung" = "#9467BDFF",
"lymph node" = "#8C564BFF",
"brain" = "#E377C2FF", 
"liver" = "#7F7F7FFF",
  "Yes" = "darkgrey",
  "No" = "lightgrey",
  "LUAD" = "cyan",
  "Non_LUAD" = "magenta",
  ">=65" = "gold",
  "<65" = "darkgreen",
  ">=3cm" = "darkred",#"beige",
  "<3cm" = "khaki",
  "EGFR_L858R" = "olivedrab",
  "EGFR_19DEL" = "hotpink"
)

merge_table = "Source data.xlsx/pid.summary"
df_pid = read.table(merge_table,header=T,sep="\t")
dim(df_pid)
df_pid = df_pid[,c("PID","MinerVa.Prime_longitudinal","EGFR_L858R_19DEL")]

df = read.table("Source data.xlsx/sample.summary",header=T,sep="\t")
dim(df)
df = merge(df,df_pid)
dim(df)

df$simplex_ctDNA_ratio <- ifelse(df$MinerVa.Prime == "Negative", 0, df$simplex_ctDNA_ratio)
df_pos = subset(df,MinerVa.Prime=="Positive")
df_neg = subset(df,MinerVa.Prime=="Negative")
quantiles <- quantile(df_pos$simplex_ctDNA_ratio, probs = seq(0, 1, by = 0.2), na.rm = TRUE)
unique_quantiles <- unique(quantiles)
df_pos$simplex_ctDNA_ratio_quantile <- cut(df_pos$simplex_ctDNA_ratio, breaks = unique_quantiles, include.lowest = TRUE, labels = FALSE)
df_neg$simplex_ctDNA_ratio_quantile <- 0
df = rbind(df_pos,df_neg)
table(df$simplex_ctDNA_ratio_quantile)
df$simplex_ctDNA_ratio_quantile = df$simplex_ctDNA_ratio_quantile+1
table(df$simplex_ctDNA_ratio_quantile)

df$Tumor_size_group = gsub("Gt3cm",">=3cm",df$Tumor_size_group) 
df$Tumor_size_group = gsub("Lt3cm","<3cm",df$Tumor_size_group) 
df$metastasis_site = df[,c("metastasis.site")]


patient_info <- df %>%
  select(PID, Gender, Stage, Adj_ALL,re_DFS,DFS,Smoking,Histological_subtype,Age_group,Tumor_size_group,EGFR_L858R_19DEL,metastasis_site) %>%
  distinct() %>%
  mutate(ID = row_number()) 
patient_info <- patient_info %>%
  arrange(Adj_ALL,desc(re_DFS),DFS,Stage, Gender)
pid_orders = unique(patient_info$PID)


df_long <- patient_info %>%
  select(PID, Gender, Stage, Smoking,Histological_subtype,Age_group,Tumor_size_group,EGFR_L858R_19DEL,metastasis_site)  %>%
  pivot_longer(cols = -PID, names_to = "Clinical_Info", values_to = "Value")

legends <- lapply(unique(df_long$Clinical_Info), function(info) {
  plot_data <- df_long %>% filter(Clinical_Info == info)
  dummy_plot <- ggplot(plot_data, aes(x = 1, y = 1, fill = Value)) +
    geom_tile(width = 0.5, height = 0.5) +
    scale_fill_manual(values = custom_colors[names(custom_colors) %in% plot_data$Value], name = info) +
    theme_void() +
    theme(legend.position = "right") +
    guides(fill = guide_legend(override.aes = list(shape = 15, size = 5))) # 15 对应于方形

  g_legend(dummy_plot)
})


heatmap_data <- patient_info %>%
  pivot_longer(cols = c(Gender, Stage, Smoking,Histological_subtype,Age_group,Tumor_size_group,EGFR_L858R_19DEL,metastasis_site), names_to = "Clinical_Info", values_to = "Value")
heatmap_data$PID = factor(heatmap_data$PID,levels=pid_orders)
heatmap_data

heatmap_plot <- ggplot(heatmap_data, aes(x = Clinical_Info, y = PID, fill = Value)) +
  geom_tile(color = "white") +
  scale_fill_manual(values = custom_colors,na.value="white") +
  #scale_fill_manual(values = c("Female" = "pink", "Male" = "lightblue", "II" = "yellow", "III" = "orange", "Target" = "purple", "Chemo" = "brown")) +
  labs(fill = "Clinical Info") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank())




map_colors <- function(value, quantile) {
  if (value == "Positive") {
    return(c("yellow","green","blue","red","black")[as.numeric(quantile)-1])
  } else {
    return("white")
  }
}

unique(df$simplex_ctDNA_ratio_quantile)
df <- df %>%
  arrange(simplex_ctDNA_ratio_quantile)
unique(df$simplex_ctDNA_ratio_quantile)

df$fill_color <- mapply(map_colors, df$MinerVa.Prime, df$simplex_ctDNA_ratio_quantile)
df <- df %>%
  arrange(simplex_ctDNA_ratio_quantile) %>%
  mutate(fill_color_factor = factor(fill_color, levels = unique(fill_color)))

write.table(df,"add.sampleinfo.xls", sep = "\t", row.names = FALSE, col.names = TRUE,quote = FALSE)




swimming_plot <- ggplot(df) +
  geom_segment(aes(x = 0, xend = DFS, y = factor(PID, levels = unique(patient_info$PID)), yend = factor(PID, levels = unique(patient_info$PID)),colour= "Clinical follow up"), size = 1, inherit.aes = FALSE) +
  geom_segment(data = df %>% filter(Adj_ALL=="Chemo"), aes(x = Adj_chemo_start, xend = Adj_chemo_end,  y = factor(PID, levels = unique(patient_info$PID)), yend = factor(PID, levels = unique(patient_info$PID)),color = "Chemo therapy"), size = 2, inherit.aes = FALSE) +
  geom_segment(data = df %>% filter(Adj_ALL=="Target"),aes(x = Adj_target_start,xend = Adj_target_end, y = factor(PID, levels = unique(patient_info$PID)), yend = factor(PID, levels = unique(patient_info$PID)),color = "Target therapy"), size = 2, inherit.aes = FALSE) +
  geom_point(data = df, aes(x = inter_FF, y = factor(PID, levels = unique(patient_info$PID)), fill = simplex_ctDNA_ratio_quantile), shape = 21, size=4,color = "black") +
  geom_segment(data = df %>% filter(re_DFS==1), aes(x = DFS, xend = DFS + 5, y = factor(PID, levels = unique(patient_info$PID)), yend = factor(PID, levels = unique(patient_info$PID)), color = "Relapse time"), size = 6, inherit.aes = FALSE) +
  scale_color_manual(name = "Segment info", values = c("Clinical follow up" = "grey", "Chemo therapy" = "#800080", "Target therapy" = "#00aaff", "Relapse time" = "blue")) +
scale_fill_gradient(name = "simplex_ctDNA_ratio_quantile", low = "white", high = "red", breaks = 1:6, labels = 1:6) +
  scale_x_continuous(breaks = c(-30, 0, 30, 90, seq(180, 1600, 180))) +
  theme(axis.text = element_text(size = 8)) +
  theme(panel.background = element_rect(fill = 'transparent'),
        panel.border = element_rect(fill = NA, colour = "black")) +
  ylab(NULL) + 
  xlab("Time since treatment (days)") +
  geom_vline(xintercept = 0) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
pdf("swim.pdf",height=22,width=16)
print(swimming_plot)
dev.off()


legend_swimming <- get_legend(swimming_plot)



combined_plot <- plot_grid(
  heatmap_plot + theme(legend.position = "none"),
  swimming_plot + theme(legend.position = "none"),
  ncol = 2,
  align = "h",
  rel_widths = c(0.3, 1)
)

combined_legends <- cowplot::plot_grid(plotlist = legends, ncol = 2, align = 'v')


combined_legend <- plot_grid(
combined_legends,
legend_swimming,
  ncol = 1
)


final_plot <- plot_grid(
  combined_plot,
  combined_legend,
  ncol = 2,
  rel_widths = c(1, 0.2)
)


pdf("all.pdf",height=28,width=16)
print(final_plot)
dev.off()

