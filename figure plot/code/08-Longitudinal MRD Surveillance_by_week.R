library(ggplot2)
library(ggsci)
library(dplyr)
library(tidyr)
require(cowplot)

argv<-commandArgs()

#fig4A
outfile = argv[6]
time_list = c('CF0W', 'CF12W', 'CF24W', 'CF36W', 'CF48W', 'CF60W', 'CF72W', 'CF84W', 'CF96W', 'CF108W',  'CF132W*', 'CF156W',"CF180W*")
i <- "re_DFS"
merge_table = "Source data.xlsx/fig4A"
data = read.table(merge_table,header=T,sep="\t")
bar_plot_1 = subset(data,Group=="BL_neg")
bar_plot_1$Adjuvant_therapy = factor(bar_plot_1$Adjuvant_therapy,levels=c("Icotinib","Chemotherapy"))
fig_1 <- ggplot(bar_plot_1, aes(fill=Adjuvant_therapy, y=all_no, x=SubGroup, group=Adjuvant_therapy)) +
  geom_bar(stat="identity", width=0.7, position=position_dodge(width=0.9)) +
  theme_bw() +
  scale_y_continuous(expand=c(0, 0),
                     limits=c(0, 110),
                     breaks=seq(0, 100, 10),
                     labels=c(paste(seq(0, 100, 10), ".0%", sep="")),
                     #sec.axis=sec_axis(~., name="Total number of samples")) +
                     sec.axis=sec_axis(~., name="")) +
  scale_fill_manual(name='Adjuvant Therapy (Bar)',
                    values=c("Icotinib"=adjustcolor("#00A1D5FF", alpha.f = 0.4),  
                             "Chemotherapy"=adjustcolor("#6A6599FF", alpha.f = 0.4))) +
  ylab("MRD positive rate") +
  xlab("Time since randomization (weeks)") +
  theme(
panel.background = element_rect(fill = 'transparent'),
        panel.border = element_rect(fill = NA, colour = "black"),
  panel.grid.major = element_blank(),    
    panel.grid.minor = element_blank(),    
axis.text.x = element_text(size=9,angle = 45, hjust = 1),  
  axis.title.x = element_text(size=9),
    axis.title.y = element_text(size=9),
#    axis.text.x = element_text(size=14),
    axis.text.y = element_text(size=9),
    axis.title.y.right = element_text(size=9), 
    axis.text.y.right = element_text(size=9),   
    legend.title = element_text(size=9),
    legend.text = element_text(size=9)
  )

fig_1 <- fig_1 +
  geom_line(data=bar_plot_1, aes(x=SubGroup, y=Freq, color=Adjuvant_therapy, group=Adjuvant_therapy), size=1.2) +
  geom_point(data=bar_plot_1, aes(x=SubGroup, y=Freq, color=Adjuvant_therapy), size=2) +
  geom_text(aes(x=SubGroup, y=Freq + 5, label=Freq_mark), size=6 / .pt, position=position_dodge(width=0.9))


fig_1 <- fig_1 +
  scale_color_manual(name='Adjuvant Therapy (Line & Point)', values=c("Icotinib"="#00A1D5FF", "Chemotherapy"="#6A6599FF"))


fig_1 <- fig_1 +
  guides(
    fill = guide_legend(order = 1),         
    color = guide_legend(order = 2, override.aes = list(linetype = 1, size = 5, keywidth = 3))  
  )

pdf('fig1.pdf',width=5,height=4)
print(fig_1)
dev.off()



bar_plot_1 = subset(data,Group!="BL_neg")
bar_plot_1$Adjuvant_therapy = factor(bar_plot_1$Adjuvant_therapy,levels=c("Icotinib","Chemotherapy"))
fig_2 <- ggplot(bar_plot_1, aes(fill=Adjuvant_therapy, y=all_no, x=SubGroup, group=Adjuvant_therapy)) +
  geom_bar(stat="identity", width=0.7, position=position_dodge(width=0.9)) +
  theme_bw() +
  scale_y_continuous(expand=c(0, 0),
                     limits=c(0, 110),
                     breaks=seq(0, 100, 10),
                     labels=c(paste(seq(0, 100, 10), ".0%", sep="")),
                     sec.axis=sec_axis(~., name="Total number of samples")) +
  scale_fill_manual(name='Adjuvant Therapy (Bar)',
                    values=c("Icotinib"=adjustcolor("#00A1D5FF", alpha.f = 0.4),  
                             "Chemotherapy"=adjustcolor("#6A6599FF", alpha.f = 0.4))) +
  #ylab("MRD positive rate") +
  ylab("") +
  xlab("Time since randomization (weeks)") +
  theme(
panel.background = element_rect(fill = 'transparent'),
        panel.border = element_rect(fill = NA, colour = "black"),
  panel.grid.major = element_blank(),     
    panel.grid.minor = element_blank(),     
axis.text.x = element_text(size=9,angle = 45, hjust = 1),
    axis.title.x = element_text(size=9),
    axis.title.y = element_text(size=9),
#    axis.text.x = element_text(size=14),
    axis.text.y = element_text(size=9),
    axis.title.y.right = element_text(size=9),  
    axis.text.y.right = element_text(size=9),   
    legend.title = element_text(size=9),
    legend.text = element_text(size=9)
  )


fig_2 <- fig_2 +
  geom_line(data=bar_plot_1, aes(x=SubGroup, y=Freq, color=Adjuvant_therapy, group=Adjuvant_therapy), size=1.2) +
  geom_point(data=bar_plot_1, aes(x=SubGroup, y=Freq, color=Adjuvant_therapy), size=2) +
  geom_text(aes(x=SubGroup, y=Freq + 5, label=Freq_mark), size=6 / .pt, position=position_dodge(width=0.9))


fig_2 <- fig_2 +
  scale_color_manual(name='Adjuvant Therapy', values=c("Icotinib"="#00A1D5FF", "Chemotherapy"="#6A6599FF"))


fig_2 <- fig_2 +
  guides(
    fill = guide_legend(order = 1),         

    color = guide_legend(order = 2, override.aes = list(linetype = 1, size = 5, keywidth = 3)) 
  )
pdf('fig2.pdf',width=5,height=4)
print(fig_2)
dev.off()


combined_plot <- plot_grid(
  fig_1 + theme(legend.position = "none"),
  fig_2 + theme(legend.position = "none"),
  ncol = 2,
  align = "h",
  rel_widths = c(2, 2)
)

pdf_filename=paste(outfile,paste(i,".standard.CFtime_MRD_pos_ratio.pdf",sep='.'),sep='.')
pdf(pdf_filename,width = 16,height = 4)
print(combined_plot)
dev.off()
