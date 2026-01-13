library(ggplot2)
library(ggsci)

#fig3D
#PPV
merge_table = "Source data.xlsx/fig3D/"
df = read.table(merge_table,header = T,sep="\t")
df = df[order(df$PPV_time_point),]
df$PPV = df$PPV * 100
df$type = "PPV"
df_seg = subset(df,PPV_time_point %in% c(180,360,720))
df_seg

x_time = c(c(180,360,720),c(0,90,540))
x_labels = c(c(180,360,720),c(0,90,540))
print(x_labels)

#NPV
df2 = read.table(merge_table,header = T,sep="\t")
df2 = df2[order(df2$NPV_time_point),]
df2$NPV = df2$NPV * 100
df2$type = "NPV"
df_seg2 = subset(df2,NPV_time_point %in% c(180,360,720))
df_seg2

colnames(df_seg2) <- colnames(df_seg)
colnames(df2) <- colnames(df)
df = rbind(df,df2)
df

pp = ggplot(df, aes(x = PPV_time_point, y = PPV, fill = type)) +
  geom_point(size = 1, shape = 21) +
  #stat_smooth(aes(color = type), method = 'loess', span = 0.5, se = TRUE, level = 0.95) +
  stat_smooth(aes(color = type), method = 'loess', span = 0.5, se = F, level = 0.95) +
  theme_bw() +
  theme(
    text = element_text(size = 18, face = "bold"),
    plot.background = element_blank(),
    panel.grid = element_blank(),
    panel.border = element_blank(),
    strip.text.y = element_blank(),
    strip.text = element_text(size = 18, face = "bold"),
    strip.background = element_blank(),
    axis.line = element_line(color = 'black')
  ) +
  labs(x = "Time after each test (days)", y = "NPV & PPV") +
  scale_x_continuous(breaks = x_time, labels = x_labels) +
#  scale_y_continuous(expand = c(0, 0), breaks = seq(0, 100, 5), limits = c(0, 102)) +
  scale_y_continuous(expand = c(0, 0),
                     limits = c(0, 102),
                     breaks = seq(0, 100, 20),
                     labels = c(paste(seq(0, 100, 20), "%", sep = ""))) +

  geom_segment(data = df_seg, aes(x = PPV_time_point, y = 0, xend = PPV_time_point, yend = PPV), 
               colour = "#DF8F44FF", linetype = 2, size = 0.5, inherit.aes = FALSE) +
  geom_segment(data = df_seg, aes(x = 0, y = PPV, xend = PPV_time_point, yend = PPV), 
               colour = "#DF8F44FF", linetype = 2, size = 0.5, inherit.aes = FALSE) +
  annotate('text', x = -100, y = df_seg$PPV, label = paste0(round(df_seg$PPV, 1), "%"), 
           size = 12 / .pt, color = "#DF8F44FF", hjust = -0.01) +
  geom_segment(data = df_seg2, aes(x = PPV_time_point, y = 0, xend = PPV_time_point, yend = PPV), 
               colour = "#374E55FF", linetype = 2, size = 0.5, inherit.aes = FALSE) +
  geom_segment(data = df_seg2, aes(x = 0, y = PPV, xend = PPV_time_point, yend = PPV), 
               colour = "#374E55FF", linetype = 2, size = 0.5, inherit.aes = FALSE) +
  annotate('text', x = -100, y = df_seg2$PPV, label = paste0(round(df_seg2$PPV, 1), "%"), 
           size = 12 / .pt, color = "#374E55FF", hjust = -0.01) +
  scale_fill_manual(name = 'MRD', values =  c("PPV" = "#DF8F44FF", "NPV" = "#374E55FF"), na.value = "white") +
  scale_color_manual(name = 'MRD', values = c("PPV" = "#DF8F44FF", "NPV" = "#374E55FF")) +
  guides(color = guide_legend(override.aes = list(linetype = 0)), fill = guide_legend(override.aes = list(shape = 21, size = 10)))





pdf("longitudinal.PPV_NPV.pdf",width = 6, height = 3)
print(pp)
dev.off()
