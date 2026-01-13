suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
  library(grid)
  library(tidyr)
  library(cowplot)
  library(reshape)
  library(scales)
  library(ggplot2)
  library(ggpubr)
  library(RColorBrewer)
  library(xlsx)
  library(ggsci)
})


#fig3F
font_family = "sans"
base_line_size = 0.5
base_font_title_size = 8
base_font_text_size = 6
annotate_font_size = base_font_text_size - 2
library("ggsci")
#custom_colors <- c(pal_jama("default",alpha = 0.9)(7), "#000000")
custom_colors = c(pal_d3("category10")(10),pal_npg("nrc", alpha = 0.8)(8))

merge_table = "Source data.xlsx/sample.summary"
df_sample <- read.table(merge_table,header=T,sep="\t",check.names=F)
df = subset(df_sample,df_sample$re_DFS==1)
df = subset(df_sample,df_sample$MinerVa.Prime=="Positive")
table(df$`metastasis site`)
df$`metastasis site` = ifelse(grepl("multiple",df$metastasis_site_type),"Multiple",df$`metastasis site`)
table(df$`metastasis site`)
df$`metastasis site` = gsub("brain","Brain",df$`metastasis site`)
df$`metastasis site` = gsub("bone","Bone",df$`metastasis site`)
df$`metastasis site` = gsub("liver","Liver",df$`metastasis site`)
df$`metastasis site` = gsub("lung","Lung",df$`metastasis site`)
df$`metastasis site` = gsub("lymph node","Lymph node",df$`metastasis site`)
df$`metastasis site` = gsub("pleura","Pleura",df$`metastasis site`)
table(df$`metastasis site`)

box_col_list <- c("hGE")

k <- c(paste0('k',1:length(box_col_list) ))
n <- 1
for (name in box_col_list){
  message(name)
  plot_data_tmp <- df[,c("metastasis site",name)]
  plot_data_tmp[plot_data_tmp==""] = NA
  print(dim(plot_data_tmp))
  plot_data_tmp <- na.omit(plot_data_tmp)
  colnames(plot_data_tmp) <- c("cohort","value")
  my_comparisons <- list(unique(plot_data_tmp$cohort))
  plot_data_tmp$cohort <- factor(plot_data_tmp$cohort)
  y_max <- max(plot_data_tmp$value)
  y_min <- min(plot_data_tmp$value)

  sta <- compare_means(value ~ cohort,  data = plot_data_tmp, method = "wilcox.test")$p.adj
  marker_size <- ifelse(sta == "ns",4,6)
  
 ybreaks <- c(0.01, 0.1, 0.4,10,100,205)
 ylables <- c(0.01, 0.1, 0.4,10,100,205)


plot_data_tmp_all = plot_data_tmp
plot_data_tmp_all$cohort = "All"
plot_data_tmp = rbind(plot_data_tmp_all,plot_data_tmp)
plot_data_tmp$cohort = factor(plot_data_tmp$cohort,levels=c(c("All","Multiple","Pleura","Bone","Lung","Lymph node","Brain","Liver"))) 
  # base violin plot
write.table(plot_data_tmp,"plot_data_tmp.xls",row.names=F,col.names=T,quote=F,sep="\t")
  q <- ggplot(plot_data_tmp, aes(x=cohort, y=value, fill=cohort)) +
    geom_violin(trim=TRUE,color="black")+
    geom_boxplot(width=0.1, fill="white",outlier.size = 0.5)+
    labs(title="",x="", y = name)+ 
    theme_classic()+

scale_fill_manual(values = custom_colors)+

scale_y_continuous(trans = "log2", breaks = ybreaks, labels = ylables) +

    theme(plot.title = element_text(hjust = 0.5,size=base_font_title_size,margin=margin(0,0,10,0),family = font_family),
          text=element_text(size=base_font_text_size),
          axis.text.x = element_text(face="bold",family = font_family,size=base_font_text_size),
          axis.ticks.x = element_blank(),
          axis.text.y = element_text(family = font_family,size=base_font_text_size),
          legend.position="none",legend.box.spacing = unit(-5, "pt"),
          legend.direction='horizontal',
          legend.title = element_blank(),
          legend.text = element_text(size = base_font_text_size,family = font_family),
          legend.key.height= unit(2, 'pt'),
          legend.key.width= unit(5, 'pt'),
          plot.margin=margin(t=2,r=0,b=2,l=3, unit="pt")
    )+
  scale_x_discrete(guide = guide_axis(angle = 45))
  
  assign(k[n],q)
  n <- n + 1
}


### clinic boxplot
plot_list_2 <- paste(k,collapse = ",")
cmd <- sprintf("plot_grid(%s, nrow = %s, align = 'hv',axis = 'lr',rel_heights = c(%s),rel_widths = c(%s))",plot_list_2,1, paste(rep(1,length(k)),collapse = ","),paste(rep(1,length(k)),collapse = ",") )
fig_1_B_2 <- eval(parse(text=cmd))

pdf("fig3F.pdf",width = 6.5 , height = 5)
fig_1_B_2
dev.off()




#fig5B
df <- read.table("Source data.xlsx/pid.summary",header=T,sep="\t",check.names=F)
df_pos = subset(df,MinerVa.Prime=="Positive")
box_col_list <- c("hGE")

k <- c(paste0('k',1:length(box_col_list) ))
n <- 1
for (name in box_col_list){
  message(name)
  plot_data_tmp <- df_pos[,c("pre.MinerVa.Prime_vs_EGFR_MRD",name)]
  plot_data_tmp[plot_data_tmp==""] = NA
  plot_data_tmp <- na.omit(plot_data_tmp)
  No_relapse_count <- unique(table(plot_data_tmp$pre.MinerVa.Prime_vs_EGFR_MRD))[1]
  No_relapse_count
  Relapse_count <- unique(table(plot_data_tmp$pre.MinerVa.Prime_vs_EGFR_MRD))[2]
  anno_count <- sprintf("n=%s n=%s",No_relapse_count,Relapse_count)
  
  colnames(plot_data_tmp) <- c("cohort","value")
  # my_comparisons <- list(c("Re", "Rf"))
  my_comparisons <- list(unique(plot_data_tmp$cohort))
  plot_data_tmp$cohort <- factor(plot_data_tmp$cohort)
  y_max <- max(plot_data_tmp$value)
  y_min <- min(plot_data_tmp$value)
  sta <- compare_means(value ~ cohort,  data = plot_data_tmp, method = "wilcox.test")$p.adj
  marker_size <- ifelse(sta == "ns",4,6)
  
 ybreaks <- c(0.01, 0.1, 0.4,10,100,205)
 ylables <- c(0.01, 0.1, 0.4,10,100,205)
 
  # base violin plot
  q <- ggplot(plot_data_tmp, aes(x=cohort, y=value, fill=cohort)) +
    geom_violin(trim=TRUE,color="black")+
    geom_boxplot(width=0.1, fill="white",outlier.size = 0.5)+
    labs(title="",x="", y = name)+ 
    theme_classic()+
scale_fill_manual(values = c("#7E6148FF","#FF0000"))+
scale_y_continuous(trans = "log2", breaks = ybreaks, labels = ylables) +
    theme(plot.title = element_text(hjust = 0.5,size=base_font_title_size,margin=margin(0,0,10,0),family = font_family),
          text=element_text(size=base_font_text_size),
          axis.text.x = element_text(face="bold",family = font_family,size=base_font_text_size),
          aspect.ratio=5/3,
          
          axis.ticks.x = element_blank(),
          axis.text.y = element_text(family = font_family,size=base_font_text_size),
          legend.position="none",legend.box.spacing = unit(-5, "pt"),
          legend.direction='horizontal',
          legend.title = element_blank(),
          legend.text = element_text(size = base_font_text_size,family = font_family),
          legend.key.height= unit(2, 'pt'),
          legend.key.width= unit(5, 'pt'),
          plot.margin=margin(t=2,r=0,b=2,l=3, unit="pt")
    )
  
  q <- q + stat_compare_means(comparisons = my_comparisons, 
                              method = "wilcox.test",
                              label.y = log(sig_label.y,2),
                              #label = "p.signif",
                              label = "p.adj",
                              bracket.size = 0.5,
                              tip.length = 0.01,
                              #symnum.args = list(cutpoints = c(0, 0.001, 0.01, 0.05, Inf), symbols = c("***", "**", "*", "ns")),
                              vjust = 0,
                              size = marker_size-2,
                              family = font_family,
  )+
    annotate("text", x = 1.6, y=log(10,2), label = anno_count,size =annotate_font_size-1.8, family = font_family)
  assign(k[n],q)
  n <- n + 1
}


### clinic boxplot
plot_list_2 <- paste(k,collapse = ",")
cmd <- sprintf("plot_grid(%s, nrow = %s, align = 'hv',axis = 'lr',rel_heights = c(%s),rel_widths = c(%s))",plot_list_2,1, paste(rep(1,length(k)),collapse = ","),paste(rep(1,length(k)),collapse = ",") )
fig_1_B_2 <- eval(parse(text=cmd))

pdf("fig5B_hGE.box.pdf",width = 6.5 , height = 5)
fig_1_B_2
dev.off()

#fig5D
df_sample <- read.table(merge_table,header=T,sep="\t",check.names=F)
df <- read.table("Source data.xlsx/pid.summary",header=T,sep="\t",check.names=F)
df = df[,c("PID","longitudinal.MinerVa.Prime_vs_EGFR_MRD")]
df = merge(df,df_sample,all.y=T)
df_pos = subset(df,longitudinal.MinerVa.Prime_vs_EGFR_MRD!="Negative_Negative")
df_pos = subset(df_pos,MinerVa.Prime=="Positive")
box_col_list <- c("hGE")

k <- c(paste0('k',1:length(box_col_list) ))
n <- 1
for (name in box_col_list){
  message(name)
  plot_data_tmp <- df_pos[,c("longitudinal.MinerVa.Prime_vs_EGFR_MRD",name)]
  plot_data_tmp[plot_data_tmp==""] = NA
  plot_data_tmp <- na.omit(plot_data_tmp)
  No_relapse_count <- unique(table(plot_data_tmp$longitudinal.MinerVa.Prime_vs_EGFR_MRD))[1]
  No_relapse_count
  Relapse_count <- unique(table(plot_data_tmp$longitudinal.MinerVa.Prime_vs_EGFR_MRD))[2]
  anno_count <- sprintf("n=%s n=%s",No_relapse_count,Relapse_count)
  
  colnames(plot_data_tmp) <- c("cohort","value")
  # my_comparisons <- list(c("Re", "Rf"))
  my_comparisons <- list(unique(plot_data_tmp$cohort))
  plot_data_tmp$cohort <- factor(plot_data_tmp$cohort)
  y_max <- max(plot_data_tmp$value)
  y_min <- min(plot_data_tmp$value)
  sta <- compare_means(value ~ cohort,  data = plot_data_tmp, method = "wilcox.test")$p.adj
  marker_size <- ifelse(sta == "ns",4,6)
  
 ybreaks <- c(0.01, 0.1, 0.4,10,100,205)
 ylables <- c(0.01, 0.1, 0.4,10,100,205)
 
  # base violin plot
  q <- ggplot(plot_data_tmp, aes(x=cohort, y=value, fill=cohort)) +
    geom_violin(trim=TRUE,color="black")+
    geom_boxplot(width=0.1, fill="white",outlier.size = 0.5)+
    labs(title="",x="", y = name)+ 
    theme_classic()+
scale_fill_manual(values = c("#7E6148FF","#FF0000"))+
scale_y_continuous(trans = "log2", breaks = ybreaks, labels = ylables) +
    theme(plot.title = element_text(hjust = 0.5,size=base_font_title_size,margin=margin(0,0,10,0),family = font_family),
          text=element_text(size=base_font_text_size),
          axis.text.x = element_text(face="bold",family = font_family,size=base_font_text_size),
          aspect.ratio=5/3,
          
          axis.ticks.x = element_blank(),
          axis.text.y = element_text(family = font_family,size=base_font_text_size),
          legend.position="none",legend.box.spacing = unit(-5, "pt"),
          legend.direction='horizontal',
          legend.title = element_blank(),
          legend.text = element_text(size = base_font_text_size,family = font_family),
          legend.key.height= unit(2, 'pt'),
          legend.key.width= unit(5, 'pt'),
          plot.margin=margin(t=2,r=0,b=2,l=3, unit="pt")
    )
  
  q <- q + stat_compare_means(comparisons = my_comparisons, 
                              method = "wilcox.test",
                              label.y = log(sig_label.y,2),
                              #label = "p.signif",
                              label = "p.adj",
                              bracket.size = 0.5,
                              tip.length = 0.01,
                              #symnum.args = list(cutpoints = c(0, 0.001, 0.01, 0.05, Inf), symbols = c("***", "**", "*", "ns")),
                              vjust = 0,
                              size = marker_size-2,
                              family = font_family,
  )+
    annotate("text", x = 1.6, y=log(10,2), label = anno_count,size =annotate_font_size-1.8, family = font_family)
  assign(k[n],q)
  n <- n + 1
}


### clinic boxplot
plot_list_2 <- paste(k,collapse = ",")
cmd <- sprintf("plot_grid(%s, nrow = %s, align = 'hv',axis = 'lr',rel_heights = c(%s),rel_widths = c(%s))",plot_list_2,1, paste(rep(1,length(k)),collapse = ","),paste(rep(1,length(k)),collapse = ",") )
fig_1_B_2 <- eval(parse(text=cmd))

pdf("fig5D_hGE.box.pdf",width = 6.5 , height = 5)
fig_1_B_2
dev.off()

#figS9A
df <- read.table(merge_table,header=T,sep="\t",check.names=F)
df$Relapse <- ifelse(df$re_DFS==1,"Recurrence","No recurrence")
table(df$Relapse)
df_pos = subset(df,Adj_ALL=="Target")
df_pos = subset(df_pos,MinerVa.Prime=="Positive")
df_pos = subset(df_pos,sample_group=="on_therapy")

box_col_list <- c("hGE")
k <- c(paste0('k',1:length(box_col_list) ))
n <- 1
for (name in box_col_list){  
  message(name)
  plot_data_tmp <- df_pos[,c("Relapse",name)]
  plot_data_tmp[plot_data_tmp==""] = NA
  print(dim(plot_data_tmp))
  plot_data_tmp <- na.omit(plot_data_tmp)
  No_relapse_count <- unique(table(plot_data_tmp$Relapse))[1]
  Relapse_count <- unique(table(plot_data_tmp$Relapse))[2]
  anno_count <- sprintf("n=%s n=%s",No_relapse_count,Relapse_count)
  
  colnames(plot_data_tmp) <- c("cohort","value")
  # my_comparisons <- list(c("Re", "Rf"))
  my_comparisons <- list(unique(plot_data_tmp$cohort))
  plot_data_tmp$cohort <- factor(plot_data_tmp$cohort)
  y_max <- max(plot_data_tmp$value)
  y_min <- min(plot_data_tmp$value)
  
  #sta <- compare_means(value ~ cohort,  data = plot_data_tmp, method = "wilcox.test")$p.signif
  sta <- compare_means(value ~ cohort,  data = plot_data_tmp, method = "wilcox.test")$p.adj
  marker_size <- ifelse(sta == "ns",4,6)

 ybreaks <- c(0.01, 0.1, 0.4,10,100,205)
 ylables <- c(0.01, 0.1, 0.4,10,100,205)
 
  # base violin plot
  q <- ggplot(plot_data_tmp, aes(x=cohort, y=value, fill=cohort)) +
    geom_violin(trim=TRUE,color="black")+
    geom_boxplot(width=0.1, fill="white",outlier.size = 0.5)+
    labs(title="",x="", y = name)+ 
    theme_classic()+
scale_fill_manual(values = c("#0000FF","#FF0000"))+
scale_y_continuous(trans = "log2", breaks = ybreaks, labels = ylables) +

    theme(plot.title = element_text(hjust = 0.5,size=base_font_title_size,margin=margin(0,0,10,0),family = font_family),
          text=element_text(size=base_font_text_size),
          axis.text.x = element_text(face="bold",family = font_family,size=base_font_text_size),
          aspect.ratio=5/3,
          
          axis.ticks.x = element_blank(),
          axis.text.y = element_text(family = font_family,size=base_font_text_size),
          legend.position="none",legend.box.spacing = unit(-5, "pt"),
          legend.direction='horizontal',
          legend.title = element_blank(),
          legend.text = element_text(size = base_font_text_size,family = font_family),
          legend.key.height= unit(2, 'pt'),
          legend.key.width= unit(5, 'pt'),
          plot.margin=margin(t=2,r=0,b=2,l=3, unit="pt")
    )

  q <- q + stat_compare_means(comparisons = my_comparisons, 
                              method = "wilcox.test",
                              label.y = log(sig_label.y,2),
                              #label = "p.signif",
                              label = "p.adj",
                              bracket.size = 0.5,
                              tip.length = 0.01,
                              #symnum.args = list(cutpoints = c(0, 0.001, 0.01, 0.05, Inf), symbols = c("***", "**", "*", "ns")),
                              vjust = 0,
                              size = marker_size-2,
                              family = font_family,
  )+
    annotate("text", x = 1.6, y=log(10,2), label = anno_count,size =annotate_font_size-1.8, family = font_family)
  assign(k[n],q)
  n <- n + 1
}

plot_list_2 <- paste(k,collapse = ",")
cmd <- sprintf("plot_grid(%s, nrow = %s, align = 'hv',axis = 'lr',rel_heights = c(%s),rel_widths = c(%s))",plot_list_2,1, paste(rep(1,length(k)),collapse = ","),paste(rep(1,length(k)),collapse = ",") )
fig_1_B_2 <- eval(parse(text=cmd))

pdf("figS7A.pdf",width = 6.5 , height = 5)
fig_1_B_2
dev.off()


#figS9B
df <- read.table(merge_table,header=T,sep="\t",check.names=F)
df$Relapse <- ifelse(df$re_DFS==1,"Recurrence","No recurrence")
table(df$Relapse)
df_pos = subset(df,Adj_ALL=="Target")#df_pos = subset(df,Adj_ALL!="Target") and next code are same as Target
df_pos = subset(df_pos,MinerVa.Prime=="Positive")
df_pos = subset(df_pos,sample_group=="post_therapy")
box_col_list <- c("hGE")

k <- c(paste0('k',1:length(box_col_list) ))
n <- 1
for (name in box_col_list){
message(name)
  plot_data_tmp <- df_pos[,c("Relapse",name)]
  plot_data_tmp[plot_data_tmp==""] = NA

  plot_data_tmp <- na.omit(plot_data_tmp)

  No_relapse_count <- unique(table(plot_data_tmp$Relapse))[1]
  Relapse_count <- unique(table(plot_data_tmp$Relapse))[2]
  anno_count <- sprintf("n=%s n=%s",No_relapse_count,Relapse_count)
  
  colnames(plot_data_tmp) <- c("cohort","value")
  # my_comparisons <- list(c("Re", "Rf"))
  my_comparisons <- list(unique(plot_data_tmp$cohort))
  plot_data_tmp$cohort <- factor(plot_data_tmp$cohort)
  y_max <- max(plot_data_tmp$value)
  y_min <- min(plot_data_tmp$value)
  
  #sta <- compare_means(value ~ cohort,  data = plot_data_tmp, method = "wilcox.test")$p.signif
  sta <- compare_means(value ~ cohort,  data = plot_data_tmp, method = "wilcox.test")$p.adj
compare_means(value ~ cohort,  data = plot_data_tmp, method = "wilcox.test")  
marker_size <- ifelse(sta == "ns",4,6)

 ybreaks <- c(0.01, 0.1, 0.4,10,100,205)
 ylables <- c(0.01, 0.1, 0.4,10,100,205)
 
  # base violin plot
  q <- ggplot(plot_data_tmp, aes(x=cohort, y=value, fill=cohort)) +
    geom_violin(trim=TRUE,color="black")+
    geom_boxplot(width=0.1, fill="white",outlier.size = 0.5)+
    labs(title="",x="", y = name)+ 
    theme_classic()+
scale_fill_manual(values = c("#0000FF","#FF0000"))+
scale_y_continuous(trans = "log2", breaks = ybreaks, labels = ylables) +

    theme(plot.title = element_text(hjust = 0.5,size=base_font_title_size,margin=margin(0,0,10,0),family = font_family),
          text=element_text(size=base_font_text_size),
          axis.text.x = element_text(face="bold",family = font_family,size=base_font_text_size),
          aspect.ratio=5/3,
          
          axis.ticks.x = element_blank(),
          axis.text.y = element_text(family = font_family,size=base_font_text_size),
          legend.position="none",legend.box.spacing = unit(-5, "pt"),
          legend.direction='horizontal',
          legend.title = element_blank(),
          legend.text = element_text(size = base_font_text_size,family = font_family),
          legend.key.height= unit(2, 'pt'),
          legend.key.width= unit(5, 'pt'),
          plot.margin=margin(t=2,r=0,b=2,l=3, unit="pt")
    )

  q <- q + stat_compare_means(comparisons = my_comparisons, 
                              method = "wilcox.test",
                              label.y = log(sig_label.y,2),
                              #label = "p.signif",
                              label = "p.adj",
                              bracket.size = 0.5,
                              tip.length = 0.01,
                              #symnum.args = list(cutpoints = c(0, 0.001, 0.01, 0.05, Inf), symbols = c("***", "**", "*", "ns")),
                              vjust = 0,
                              size = marker_size-2,
                              family = font_family,
  )+
    annotate("text", x = 1.6, y=log(10,2), label = anno_count,size =annotate_font_size-1.8, family = font_family)

  assign(k[n],q)
  n <- n + 1
}


### clinic boxplot
plot_list_2 <- paste(k,collapse = ",")
cmd <- sprintf("plot_grid(%s, nrow = %s, align = 'hv',axis = 'lr',rel_heights = c(%s),rel_widths = c(%s))",plot_list_2,1, paste(rep(1,length(k)),collapse = ","),paste(rep(1,length(k)),collapse = ",") )
fig_1_B_2 <- eval(parse(text=cmd))

pdf("figS9B.pdf",width = 6.5 , height = 5)
fig_1_B_2
dev.off()



#figS9C
df <- read.table(merge_table,header=T,sep="\t",check.names=F)
df$Relapse <- ifelse(df$re_DFS==1,"Recurrence","No recurrence")
table(df$Relapse)
df_pos = subset(df,Adj_ALL=="Target")
df_pos = subset(df_pos,MinerVa.Prime=="Positive")
#df_pos = subset(df_pos,sample_group %in% c("on_therapy","post_therapy"))
df_pos = subset(df_pos,sample_group !="pre_therapy")
box_col_list <- c("hGE")

k <- c(paste0('k',1:length(box_col_list) ))
n <- 1
for (name in box_col_list){
 message(name)
  plot_data_tmp <- df_pos[,c("sample_group",name)]
  plot_data_tmp[plot_data_tmp==""] = NA
  print(dim(plot_data_tmp))
  plot_data_tmp <- na.omit(plot_data_tmp)
  print(dim(plot_data_tmp))
  print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
 write.table(plot_data_tmp,"on_vs_post_therapy.xls",row.names=F,col.names=T,sep="\t",quote=F)

  No_relapse_count <- unique(table(plot_data_tmp$sample_group))[1]
  sample_group_count <- unique(table(plot_data_tmp$sample_group))[2]
  anno_count <- sprintf("n=%s n=%s",No_relapse_count,sample_group_count)
  
  colnames(plot_data_tmp) <- c("cohort","value")
  # my_comparisons <- list(c("Re", "Rf"))
  my_comparisons <- list(unique(plot_data_tmp$cohort))
  plot_data_tmp$cohort <- factor(plot_data_tmp$cohort)
  y_max <- max(plot_data_tmp$value)
  y_min <- min(plot_data_tmp$value)
  
  #sta <- compare_means(value ~ cohort,  data = plot_data_tmp, method = "wilcox.test")$p.signif
  sta <- compare_means(value ~ cohort,  data = plot_data_tmp, method = "wilcox.test")$p.adj
  marker_size <- ifelse(sta == "ns",4,6)
 ybreaks <- c(0.01, 0.1, 0.4,10,100,205)
 ylables <- c(0.01, 0.1, 0.4,10,100,205)
 
  # base violin plot
  q <- ggplot(plot_data_tmp, aes(x=cohort, y=value, fill=cohort)) +
    geom_violin(trim=TRUE,color="black")+
    geom_boxplot(width=0.1, fill="white",outlier.size = 0.5)+
    labs(title="",x="", y = name)+ 
    theme_classic()+
scale_fill_manual(values = c("#0000FF","#FF0000"))+
scale_y_continuous(trans = "log2", breaks = ybreaks, labels = ylables) +

    theme(plot.title = element_text(hjust = 0.5,size=base_font_title_size,margin=margin(0,0,10,0),family = font_family),
          text=element_text(size=base_font_text_size),
          axis.text.x = element_text(face="bold",family = font_family,size=base_font_text_size),
          aspect.ratio=5/3,
          
          axis.ticks.x = element_blank(),
          axis.text.y = element_text(family = font_family,size=base_font_text_size),
          legend.position="none",legend.box.spacing = unit(-5, "pt"),
          legend.direction='horizontal',
          legend.title = element_blank(),
          legend.text = element_text(size = base_font_text_size,family = font_family),
          legend.key.height= unit(2, 'pt'),
          legend.key.width= unit(5, 'pt'),
          plot.margin=margin(t=2,r=0,b=2,l=3, unit="pt")
    )

  q <- q + stat_compare_means(comparisons = my_comparisons, 
                              method = "wilcox.test",
                              label.y = log(sig_label.y,2),
                              #label = "p.signif",
                              label = "p.adj",
                              bracket.size = 0.5,
                              tip.length = 0.01,
                              #symnum.args = list(cutpoints = c(0, 0.001, 0.01, 0.05, Inf), symbols = c("***", "**", "*", "ns")),
                              vjust = 0,
                              size = marker_size-2,
                              family = font_family,
  )+
    annotate("text", x = 1.6, y=log(10,2), label = anno_count,size =annotate_font_size-1.8, family = font_family)

  assign(k[n],q)
  n <- n + 1
}

plot_list_2 <- paste(k,collapse = ",")
cmd <- sprintf("plot_grid(%s, nrow = %s, align = 'hv',axis = 'lr',rel_heights = c(%s),rel_widths = c(%s))",plot_list_2,1, paste(rep(1,length(k)),collapse = ","),paste(rep(1,length(k)),collapse = ",") )
fig_1_B_2 <- eval(parse(text=cmd))

pdf("figS9C.pdf",width = 6.5 , height = 5)
fig_1_B_2
dev.off()

# figS11C
df <- read.table("20240519.summary.pid.xls",header=T,sep="\t",check.names=F)
df$Relapse <- ifelse(df$re_DFS==1,"Recurrence","No recurrence")
table(df$sample_group)
df_pos = subset(df,MinerVa.Prime=="Positive")
df_pos = subset(df_pos,sample_group =="pre_therapy")
box_col_list <- c("hGE")
k <- c(paste0('k',1:length(box_col_list) ))
n <- 1
for (name in box_col_list){
 message(name)
  plot_data_tmp <- df_pos[,c("CF24W_MinerVa.Prime_clearance",name)]
  plot_data_tmp[plot_data_tmp==""] = NA
  print(dim(plot_data_tmp))
  plot_data_tmp <- na.omit(plot_data_tmp)
  print(dim(plot_data_tmp))
 write.table(plot_data_tmp,"CF24W_MinerVa.Prime_clearance.xls",row.names=F,col.names=T,sep="\t",quote=F)

  print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
  No_relapse_count <- unique(table(plot_data_tmp$CF24W_MinerVa.Prime_clearance))[1]
  Relapse_count <- unique(table(plot_data_tmp$CF24W_MinerVa.Prime_clearance))[2]
  anno_count <- sprintf("n=%s n=%s",No_relapse_count,Relapse_count)
  
  colnames(plot_data_tmp) <- c("cohort","value")
  # my_comparisons <- list(c("Re", "Rf"))
  my_comparisons <- list(unique(plot_data_tmp$cohort))
  plot_data_tmp$cohort <- factor(plot_data_tmp$cohort)
  y_max <- max(plot_data_tmp$value)
  y_min <- min(plot_data_tmp$value)
  
  #sta <- compare_means(value ~ cohort,  data = plot_data_tmp, method = "wilcox.test")$p.signif
  sta <- compare_means(value ~ cohort,  data = plot_data_tmp, method = "wilcox.test")$p.adj
  marker_size <- ifelse(sta == "ns",4,6)
  
 ybreaks <- c(0.01, 0.1, 0.4,10,100,205)
 ylables <- c(0.01, 0.1, 0.4,10,100,205)
 
  # base violin plot
  q <- ggplot(plot_data_tmp, aes(x=cohort, y=value, fill=cohort)) +
    geom_violin(trim=TRUE,color="black")+
    geom_boxplot(width=0.1, fill="white",outlier.size = 0.5)+
    labs(title="",x="", y = name)+ 
    theme_classic()+
scale_fill_manual(values = c("#0000FF","#FF0000"))+
scale_y_continuous(trans = "log2", breaks = ybreaks, labels = ylables) +
    theme(plot.title = element_text(hjust = 0.5,size=base_font_title_size,margin=margin(0,0,10,0),family = font_family),
          text=element_text(size=base_font_text_size),
          axis.text.x = element_text(face="bold",family = font_family,size=base_font_text_size),
          aspect.ratio=5/3,
          
          axis.ticks.x = element_blank(),
          axis.text.y = element_text(family = font_family,size=base_font_text_size),
          legend.position="none",legend.box.spacing = unit(-5, "pt"),
          legend.direction='horizontal',
          legend.title = element_blank(),
          legend.text = element_text(size = base_font_text_size,family = font_family),
          legend.key.height= unit(2, 'pt'),
          legend.key.width= unit(5, 'pt'),
          plot.margin=margin(t=2,r=0,b=2,l=3, unit="pt")
    )
  
  q <- q + stat_compare_means(comparisons = my_comparisons, 
                              method = "wilcox.test",
                              label.y = log(sig_label.y,2),
                              #label = "p.signif",
                              label = "p.adj",
                              bracket.size = 0.5,
                              tip.length = 0.01,
                              #symnum.args = list(cutpoints = c(0, 0.001, 0.01, 0.05, Inf), symbols = c("***", "**", "*", "ns")),
                              vjust = 0,
                              size = marker_size-2,
                              family = font_family,
  )+
    annotate("text", x = 1.6, y=log(10,2), label = anno_count,size =annotate_font_size-1.8, family = font_family)
   assign(k[n],q)
  n <- n + 1
}


plot_list_2 <- paste(k,collapse = ",")
cmd <- sprintf("plot_grid(%s, nrow = %s, align = 'hv',axis = 'lr',rel_heights = c(%s),rel_widths = c(%s))",plot_list_2,1, paste(rep(1,length(k)),collapse = ","),paste(rep(1,length(k)),collapse = ",") )
fig_1_B_2 <- eval(parse(text=cmd))

pdf("figS11C.pdf",width = 6.5 , height = 5)
fig_1_B_2
dev.off()



