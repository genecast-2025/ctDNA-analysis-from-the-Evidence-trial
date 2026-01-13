library(ggplot2)
library(ggsci)
library(ggpubr)
library(cowplot)

argv <- commandArgs()
#fig2F
merge_table = "Source data.xlsx/pid.summary"
df <- read.table(merge_table, header = TRUE, sep = "\t")
df <- subset(df, MinerVa.Prime == "Positive")
df <- df[, c("PID", "Adj_ALL", "DFS", "re_DFS", "hGE")]
df[df == ""] <- NA
df <- na.omit(df)
df$Dead <- ifelse(df$re_DFS == 1, "Recurrence", "No recurrence")
df$months <- df$OS / 30

df_T <- subset(df, Adj_ALL == "Target")
df_C <- subset(df, Adj_ALL != "Target")

generate_plot <- function(df, predex, width = 4, height = 4) {
  output_name <- paste(predex, "DFS_vs_hGE.cor.pdf", sep = '.')
  
  line_color <- "#DF8F44FF"
  
  pp <- ggplot(df, aes(x = months, y = log(hGE, 2), col = Dead)) +
    geom_point() +
    theme_bw() +
    theme(legend.position = "top",
          text = element_text(size = 5, face = "bold"),
          plot.background = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          strip.text.y = element_blank(),
          strip.text = element_text(size = 5, face = "bold"),
          strip.background = element_blank(),
          axis.line = element_line(color = 'black')) +
    stat_cor(label.y = c(15, 13), show.legend = FALSE,
             aes(label = paste(..rr.label.., ..p.label.., sep = "~`,`~"))) +
    stat_regline_equation(label.y = c(10, 8), show.legend = FALSE) +
    stat_smooth(method = 'lm', span = 0.5, se = TRUE, level = 0.95, color = line_color) +
    labs(x = "Months", y = "log2(hGE/ml)") +
    scale_x_continuous(limits = c(0, 54), breaks = seq(0, 54, 6)) + 
    scale_color_manual(values = c("Recurrence" = "#DF8F44FF", "No recurrence" = "#374E55FF"))
  
  pdf(output_name, width = width, height = height)
  print(pp)
  dev.off()
}

generate_plot(df, "all")
generate_plot(df_T, "Target")
generate_plot(df_C, "Chemo")

