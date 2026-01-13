suppressPackageStartupMessages({
  library("xlsx")
  library(this.path)
  library(data.table)
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(cowplot)
  library(ggpubr)
  library(Hmisc)
  library(rms)
  library(RColorBrewer)
  library(broom)
  library(survival)
  library(survminer)
  library(tableone)
library(ggsci)  
})
args <- commandArgs()






#fig3E
marker = c("MinerVa.Prime_longitudinal")
custom_colors = c(pal_d3("category10")(10),pal_npg("nrc", alpha = 0.8)(8))
font_family = "sans"
merge_table = "Source data.xlsx/fig3E"
bar_plot_2 <- read.table(merge_table,check.names = F,sep = "\t",header = T)
bar_plot_2$Freq2 = bar_plot_2$Freq+runif(length(bar_plot_2$Freq),min = 1, max = 5)
bar_plot_2$MRD = factor(bar_plot_2$MRD,levels=marker)
bar_plot_2$SubGroup_mark = factor(bar_plot_2$SubGroup_mark,levels = c("All (n = 53)","Multiple (n = 3)","Pleura (n = 6)","Bone (n = 11)","Lung (n = 9)","Lymph node (n = 12)","Brain (n = 10)","Liver (n = 2)"))
fig_2 <- ggplot(bar_plot_2, aes(fill=SubGroup_mark, y=Freq, x=SubGroup_mark)) + 
  geom_bar(stat="identity",width = 0.7,position=position_dodge(width = 0.9),
           #colour="black")+
  )+ ylab("Sensitivity for recurrence") +#+labs(title=marker)+
  theme_classic(base_size = 8,
                base_family = 'sans',
                base_rect_size = 0.5,
                base_line_size = 0.5
  )+
  scale_y_continuous(expand = c(0,0),
                     limits = c(0,110),
                     breaks=seq(0,100,20),
                     labels = c(paste(seq(0,100,20),".0%",sep = "")))+
#  ggsci::scale_fill_jama(alpha = 0.9)+
  scale_fill_manual(values=custom_colors)+
theme(
panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid=element_blank(),
        #aspect.ratio=7/10,
        axis.title = element_blank(),
        plot.title = element_text(hjust = 0.5,family = font_family, size=14),
        axis.text = element_text(family = font_family,size=14),
        axis.ticks.x = element_blank(),
        #axis.text.y = element_text(size = 8,margin = margin(t = 0, r = 0, b = 0, l = 0)),
        #legend.position= "none",
        legend.position= "bottom",
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 14),
        plot.margin=unit(c(0,1,0,1), "pt")
  )+
  scale_x_discrete(guide = guide_axis(angle = 45))+
  geom_text(aes(x=SubGroup_mark,y=Freq2,label=Freq_mark),size = 16/.pt,
            position=position_dodge(width=0.9))+labs(ylab ="Sensitivity")

pdf("all_Sensitivity.Metastasis.pdf",height=6,width=8,onefile=FALSE)
print(fig_2)
dev.off()








#fig5E 
merge_table = "Source data.xlsx/fig5E"
df <- read.table("input.xls",check.names = F,sep = "\t",header = T)
bar_plot_2 = df
set.seed(2023)
bar_plot_2$Freq2 = bar_plot_2$Freq+runif(length(bar_plot_2$Freq),min = 1, max = 5)
fig_2 <- ggplot(bar_plot_2, aes(fill=SubGroup_mark, y=Freq, x=MRD, group = SubGroup_mark)) + 
  geom_bar(stat="identity",width = 0.7,position=position_dodge(width = 0.9),
           #colour="black")+
  )+ ylab("Sensitivity for recurrence") +#+labs(title=marker)+
  theme_classic(base_size = 8,
                base_family = 'sans',
                base_rect_size = 0.5,
                base_line_size = 0.5
  )+
  scale_y_continuous(expand = c(0,0),
                     limits = c(0,110),
                     breaks=seq(0,100,20),
                     labels = c(paste(seq(0,100,20),".0%",sep = "")))+
#  ggsci::scale_fill_jama(alpha = 0.9)+
  #scale_fill_manual(values="#F2A93B")+
scale_fill_manual(values = c("#FF0000","#7E6148FF"))+
#scale_fill_manual(values = c("#79AF97FF","#80796BFF"))+
  theme(
panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid=element_blank(),
        aspect.ratio=7/10,
        axis.title = element_blank(),
        plot.title = element_text(hjust = 0.5,family = font_family, size=14),
        axis.text = element_text(family = font_family,size=14),
        axis.ticks.x = element_blank(),
        #axis.text.y = element_text(size = 8,margin = margin(t = 0, r = 0, b = 0, l = 0)),
        #legend.position= "none",
        legend.position= "bottom",
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 14),
        plot.margin=unit(c(0,1,0,1), "pt")
  )+
  scale_x_discrete(guide = guide_axis(angle = 45))+
  #geom_text(aes(x=SubGroup,y=Freq2,label=Freq_mark),size = 9/.pt,
  geom_text(aes(x=MRD,y=Freq2,label=Freq_mark),size = 16/.pt,
            position=position_dodge(width=0.9))+labs(ylab ="Sensitivity")
pdf("relapse_prime_vs_EGFR.pdf",height=6,width=8,onefile=FALSE)
print(fig_2)
dev.off()



#figS13A
merge_table = "Source data.xlsx/figS12A"

marker = c("MinerVa.Prime_longitudinal","EGFR_MRD_longitudinal")
bar_plot_2 <- read.table(merge_table,check.names = F,sep = "\t",header = T)
bar_plot_2$Freq2 = bar_plot_2$Freq+runif(length(bar_plot_2$Freq),min = 1, max = 5)
bar_plot_2$MRD = factor(bar_plot_2$MRD,levels=marker)
bar_plot_2$SubGroup_mark = factor(bar_plot_2$SubGroup_mark,levels = c("All (n = 53)","Multiple (n = 3)","Pleura (n = 6)","Bone (n = 11)","Lung (n = 9)","Lymph node (n = 12)","Brain (n = 10)","Liver (n = 2)"))
fig_2 <- ggplot(bar_plot_2, aes(fill=MRD, y=Freq, x=SubGroup_mark, group = MRD)) + 
  geom_bar(stat="identity",width = 0.7,position=position_dodge(width = 0.9),
           #colour="black")+
  )+ ylab("Sensitivity for recurrence") +#+labs(title=marker)+
  theme_classic(base_size = 8,
                base_family = 'sans',
                base_rect_size = 0.5,
                base_line_size = 0.5
  )+
  scale_y_continuous(expand = c(0,0),
                     limits = c(0,110),
                     breaks=seq(0,100,20),
                     labels = c(paste(seq(0,100,20),".0%",sep = "")))+
#  ggsci::scale_fill_jama(alpha = 0.9)+
  #scale_fill_manual(values="#F2A93B")+
scale_fill_manual(values = c("#FF0000","#7E6148FF"))+
  theme(
panel.border = element_blank(),
        panel.background = element_blank(),
        panel.grid=element_blank(),
        #aspect.ratio=7/10,
        axis.title = element_blank(),
        plot.title = element_text(hjust = 0.5,family = font_family, size=14),
        axis.text = element_text(family = font_family,size=14),
        axis.ticks.x = element_blank(),
        #axis.text.y = element_text(size = 8,margin = margin(t = 0, r = 0, b = 0, l = 0)),
        #legend.position= "none",
        legend.position= "bottom",
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 14),
        plot.margin=unit(c(0,1,0,1), "pt")
  )+
  scale_x_discrete(guide = guide_axis(angle = 45))+
  geom_text(aes(x=SubGroup_mark,y=Freq2,label=Freq_mark),size = 16/.pt,
            position=position_dodge(width=0.9))+labs(ylab ="Sensitivity")

pdf("all_Sensitivity.Metastasis.pdf",height=6,width=8,onefile=FALSE)
print(fig_2)
dev.off()
bar_plot_2




