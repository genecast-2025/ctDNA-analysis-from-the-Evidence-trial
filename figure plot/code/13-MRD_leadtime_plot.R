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
})

#figS9D   
merge_table = "Source data.xlsx/pid.summary"
clinic <- read.table(merge_table,sep = "\t",header = T,check.names = F)
clinic[clinic==""] <- NA
clinic_T = subset(clinic,Treat_group == "T")
clinic_C = subset(clinic,Treat_group != "T")

anno_sta_fun <- function(data){
  p <- wilcox.test(data[which(data$Group=="CT"),]$Time,
                   data[which(data$Group=="MRD"),]$Time,
                   paired =TRUE)$p.value
  p_mark <- ifelse(p < 0.001,"Pvalue<0.001",sprintf("Pvalue=%s",round(p,3)))

  return(list(
    "p_anno" = p_mark)
  )
}

plot_fun <- function(input,title,Leadtime){
  print(input)
  anno <- anno_sta_fun(input)
  #scatter_plot <- ggplot(data=input, aes(x=Group, y=Time, group=PID,colour = Group)) +
  scatter_plot <- ggplot(data=input, aes(x=Time, y=Group, group=PID,colour = Group)) +
    geom_line(color="black")+
    geom_point(size = 3)+theme_classic()+
    #coord_cartesian(xlim = c(1,2),clip = "off") +
    #labs(y = "Relapse Time (days)", title = title)+
    labs(x = "Time to recurrence (days)", title = "")+
    scale_color_manual(values = c("MRD" = "#FF0000", "CT" = "#0000FF"))+
    annotate('text',x=500,y=2.6,label=anno$p_anno, size=13/.pt, color="black",hjust = 0)+
    annotate('text',x=500,y=2.2,label=Leadtime, size=13/.pt, color="black",hjust = 0)+
    coord_cartesian(clip = 'off',xlim = c(0,1500),ylim = c(1,2))+
    #annotate('text',x=1.2,y=1600,label=anno$MRD_anno, size=13/.pt, color="black",hjust = 0)+
    theme(
legend.position="none",
plot.title = element_text(hjust = 0.5,size = 16),
          legend.text = element_text(size = 14),
          legend.title = element_text(size = 14),
          axis.title = element_text(hjust = 0.5,size = 14),
          axis.text = element_text(hjust = 0.5,size = 14),
          legend.margin = margin(-0,0,0,0),
          legend.box.spacing = unit(0, "pt")
    )
  
  return(scatter_plot)
}

filter_fun <- function(input,which_time_subfix,DFS,re_DFS,leadtime){
  print(dim(input))
  input_filter <- input %>% select(c("PID", grep(paste("^",DFS,"$", sep=""),colnames(input)),
                                     grep(paste("^",re_DFS,"$", sep=""),colnames(input)),
                                     grep(paste("^",which_time_subfix,"$", sep=""),colnames(input)),
                                     grep(paste("^",leadtime,"$", sep=""),colnames(input)))) %>%
   filter(re_DFS ==1) %>%
 
    na.omit() %>%
    `colnames<-`(c("PID", "CT", "re_DFS", "MRD","Leadtime")) %>%
    filter(MRD > 0)
  print(dim(input_filter))
  print(input_filter$Leadtime)
  leadtime = median(input_filter$Leadtime) 
  Leadtime = paste("Median Leadtime =",leadtime,"days",collapse = " ")
  plot_data_lang <- input_filter %>% 
    select("PID","CT","MRD")%>% 
    gather(key = "Group",value = "Time",-c(PID)) 
  
  plot_tmp <- plot_fun(plot_data_lang,which_time_subfix,Leadtime)
  return(plot_tmp)
}

df_list = list(
"all"=clinic,
"Target"=clinic_T,
"Chemo"=clinic_C
)

for(n in names(df_list) ){
for(j in c("MinerVa.Prime","EGFR_MRD")){
print(paste(">>>",n,j,sep=">>>"))
df_tmp = df_list[[n]]
MRD3_plot_DFS <- filter_fun(df_tmp,paste0("Re_time_",j),"DFS","re_DFS",paste0("Leadtime",j))
pdf(paste(n,j,"leadtime.DFS.pdf",sep="."),width = 4,height = 3,onefile = FALSE)
print(MRD3_plot_DFS)
dev.off()
}}

















#figS13B
argv<-commandArgs()
merge_table = "Source data.xlsx/pid.summary"
clinic <- read.table(merge_table,sep = "\t",header = T,check.names = F)
clinic[clinic==""] <- NA

anno_sta_fun <- function(data){
  tmp = wilcox.test(data[which(data$Group=="LeadtimeMinerVa.Prime"),]$Time,
                   data[which(data$Group=="LeadtimeEGFR_MRD"),]$Time,
                   paired =F)
  print(tmp)
  p <- wilcox.test(data[which(data$Group=="LeadtimeMinerVa.Prime"),]$Time,
                   data[which(data$Group=="LeadtimeEGFR_MRD"),]$Time,
                   paired =F)$p.value
  p_mark <- ifelse(p < 0.001,"Pvalue<0.001",sprintf("Pvalue=%s",round(p,3)))
  return(list(
    "p_anno" = p_mark)
  )
}

plot_fun <- function(input,title,Leadtime,plot_data_leadtime){
  print(input)
  print(plot_data_leadtime)
  anno <- anno_sta_fun(plot_data_leadtime)
  scatter_plot <- ggplot(data=input, aes(x=Time, y=Group, group=PID,colour = Group)) +
    geom_line(color="black")+
    geom_point(size = 3)+theme_classic()+
    labs(x = "Time to recurrence (days)", title = "")+
    scale_color_manual(values = c("MinerVa.Prime" = scales::alpha("#ee2428",0.32), "CT" = "#0000FF","EGFR_MRD" = "#FF0000"))+
    annotate('text',x=500,y=3.6,label=anno$p_anno, size=13/.pt, color="black",hjust = 0)+
    annotate('text',x=500,y=2.2,label=Leadtime, size=13/.pt, color="black",hjust = 0)+
    coord_cartesian(clip = 'off',xlim = c(0,1500),ylim = c(1,3))+
    theme(
legend.position="none",
plot.title = element_text(hjust = 0.5,size = 16),
          legend.text = element_text(size = 14),
          legend.title = element_text(size = 14),
          axis.title = element_text(hjust = 0.5,size = 14),
          axis.text = element_text(hjust = 0.5,size = 14),
          legend.margin = margin(-0,0,0,0),
          legend.box.spacing = unit(0, "pt")
    )
  
  return(scatter_plot)
}

filter_fun <- function(input,which_time_subfix,DFS,re_DFS,leadtime, which_time_subfix2,leadtime2){
  print(dim(input))
  input_filter <- input %>% select(c("PID", grep(paste("^",DFS,"$", sep=""),colnames(input)),
                                     grep(paste("^",re_DFS,"$", sep=""),colnames(input)),
                                     grep(paste("^",which_time_subfix,"$", sep=""),colnames(input)),
                                     grep(paste("^",leadtime,"$", sep=""),colnames(input))),
                                     grep(paste("^",which_time_subfix2,"$", sep=""),colnames(input)),
                                     grep(paste("^",leadtime2,"$", sep=""),colnames(input))) %>%
   filter(re_DFS ==1) %>%
    `colnames<-`(c("PID", "CT", "re_DFS", "MinerVa.Prime","LeadtimeMinerVa.Prime","EGFR_MRD","LeadtimeEGFR_MRD")) #%>%
  Leadtime  = paste("Median Leadtime:\nMinerVa.Prime=",median(na.omit(input_filter$LeadtimeMinerVa.Prime)),"days\n","EGFR_MRD=",median(na.omit(input_filter$LeadtimeEGFR_MRD)),"days",collapse = " ")

  plot_data_leadtime <- input_filter %>%
    select("PID","LeadtimeMinerVa.Prime","LeadtimeEGFR_MRD")%>%
    gather(key = "Group",value = "Time",-c(PID))
   plot_data_leadtime = na.omit(plot_data_leadtime)


  plot_data_lang <- input_filter %>% 
    select("PID","CT","MinerVa.Prime","EGFR_MRD")%>% 
    gather(key = "Group",value = "Time",-c(PID)) 
  plot_data_lang$Group = factor(plot_data_lang$Group,levels=c("CT","EGFR_MRD","MinerVa.Prime"))
   plot_data_lang = na.omit(plot_data_lang)
   write.table(plot_data_lang,"plot_data_lang.xls",row.names=F,col.names=T,sep="\t",quote=F)

  plot_tmp <- plot_fun(plot_data_lang,which_time_subfix,Leadtime,plot_data_leadtime)
  return(plot_tmp)
}

df_list = list(
"all"=clinic
)

for(n in names(df_list) ){
df_tmp = df_list[[n]]
MRD3_plot_DFS <- filter_fun(df_tmp,"Re_time_MinerVa.Prime","DFS","re_DFS","LeadtimeMinerVa.Prime","Re_time_EGFR_MRD","LeadtimeEGFR_MRD")
pdf(paste(n,"leadtime.DFS.pdf",sep="."),width = 5,height = 4,onefile = FALSE)
print(MRD3_plot_DFS)
dev.off()
}
