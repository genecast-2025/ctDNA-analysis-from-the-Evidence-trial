library("ggplot2")
library("ggpubr")
library("survminer")
require("survival")
library("ggsci")
library(ggtext)
argv<-commandArgs()




get_pairwise_comparisons <- function(data, time_col, status_col, group_col) {
  groups <- sort(unique(data[[group_col]]))
  comparisons <- combn(groups, 2, simplify = FALSE)
  print(comparisons)
  
  results <- lapply(comparisons, function(pair) {
    sub_data <- data[data[[group_col]] %in% pair, ]
    
    # Cox module
    fit <- coxph(Surv(time = sub_data[[time_col]], event = sub_data[[status_col]]) ~ as.factor(sub_data[[group_col]]), data = sub_data)
    summary_fit <- summary(fit)
    
    logtest<-as.matrix(summary_fit$sctest)
    colnames(logtest)<-"logrank"
    p.value=round(logtest["pvalue",],4)
    hr<-round(as.data.frame(summary_fit$conf.int)[,"exp(coef)"],2)
    hr_95CI <- paste0(round(summary_fit$conf.int[3],2),"-",round(summary_fit$conf.int[4],2) )
    
    data.frame(
      group1 = pair[1],
      group2 = pair[2],
      HR = hr,
      p.value = p.value,
      label_table = paste(paste(pair[1],pair[2],sep="_vs_"),": ","P=",p.value,",HR=",hr,",HR(95%CI)=",hr_95CI,sep="")
      
    )
  })
  
  do.call(rbind, results)
}

SVV_plot<-function(data,patient,factor,time,status,outdir,prefix){
  if(time=="OS"){
ylab_flag = "Overall survival"
}else if(time=="DFS"){
ylab_flag = "Disease-free survival"
}else if(time=="PFS"){
ylab_flag = "Progression-free survival"
}else{
ylab_flag = time
}

  data[data==""] = NA
  data<-data[c(patient,factor,time,status)]
  colnames(data)<-c("patient",factor,"OS","re")
  data <-na.omit(data)
  data[,factor]<-factor(data[,factor],levels=sort(unique(data[,factor])[(unique(data[,factor])!="")],decreasing=F))#转为有序因子,升序

  
  if(dim(data)[1]>2){
    if(length(unique(data[,factor]))>=2){
    data$re<-as.numeric(as.character(data$re))
    fit=eval(parse(text=paste("survfit(Surv(OS,re) ~ ",factor,",data = data)",sep="")))
    fit3=eval(parse(text=paste("coxph(Surv(OS,re) ~ ",factor,",data = data)",sep="")))
    fit4<-summary(fit3)
    logtest<-as.matrix(fit4$sctest)
    colnames(logtest)<-"logrank"
    nn=round(logtest["pvalue",],4)
    HR<-max(as.data.frame(fit4$conf.int)[,"exp(coef)"])

    pv_lable = "_"
    if(nn<0.05){pv_lable = "sig"}

    svv_diy_labs = c()
    for(i in rownames(as.matrix(fit$strata))){
      i = strsplit(i,'=')[[1]][2] 
      svv_diy_labs = c(svv_diy_labs,i)
    }
    svv_median = surv_median(fit, combine = FALSE)[,"median"]
    aa = data.frame(svv_diy_labs,facotr_number,svv_median)
    aa = aa[order(aa$facotr_number),]
    facotr_number = paste(aa$facotr_number,collapse=",")
    svv_median    = paste(round(aa$svv_median,1),collapse=",")
    svv_median2    = paste(round(aa$svv_media[order(aa$svv_median)],1),collapse=",")

    if(length(rownames(as.matrix(fit$strata)))>=3){
    data[,factor] = as.character(data[,factor])
    result <- get_pairwise_comparisons(data, "OS", "re", factor) 
    ddd = paste(as.character(result$label_table),collapse ="\n")
      pv<-paste("P = ",nn,"\nsurv_median: ",svv_median2,"\n",ddd)
      }
      else{
      pv<-paste("P = ",nn,"\nHR = ",round(HR,2),"\n95%CI: ",round(fit4$conf.int[3],2),"-",round(fit4$conf.int[4],2),"\nsurv_median: ",svv_median2,sep="")
      }

    if(length(svv_diy_labs)==9){
     cololr_list_diy = c("#6495ED","#0000FF","#F08080","#FF0000", "#4DBBD5FF",  "#7E6148FF", "black","grey40","#663366")
     linetype = c(2,2,2,2,2,1,1,1,1)
    }
    if(length(svv_diy_labs)==8){
      cololr_list_diy = c("#6495ED","#0000FF","#F08080","#FF0000", "#4DBBD5FF",  "#7E6148FF", "black","grey40")
      linetype = c(2,2,2,2,1,1,1,1)
    }
   if(length(svv_diy_labs)==7){
      cololr_list_diy = c("#6495ED","#0000FF","#F08080","#FF0000", "#4DBBD5FF",  "#7E6148FF", "black")
      linetype = c(2,2,2,1,1,1,1)
    }
    if(length(svv_diy_labs)==6){
      cololr_list_diy = c("#6495ED","#0000FF","#F08080","#FF0000", "#4DBBD5FF",  "#7E6148FF", "#8491B4FF")
      linetype = c(1,1,1,1,1,1)
    }
  if(length(svv_diy_labs)==5){
      cololr_list_diy = c("#6495ED","#0000FF","#F08080","#FF0000", "#4DBBD5FF",  "#7E6148FF", "#8491B4FF")
      linetype = c(1,1,1,1,1)
    }
if(length(svv_diy_labs)==4){
  cololr_list_diy  = c("#374E5599","#374E55FF","#DF8F4499","#DF8F44FF")
  cololr_list_diy  = c("#6495ED","#0000FF","#F08080","#FF0000")
  linetype=c(1,1,1,1)
}
if(length(svv_diy_labs)==3){
  cololr_list_diy = c("#374E55FF","#DF8F44E5","#B24745FF")
  cololr_list_diy = c("#0000FF","#7E6148FF","#FF0000")
  linetype = c(1,1,1)
}
if(length(svv_diy_labs)==2){
  cololr_list_diy = c("#0000FF","#FF0000")
#  cololr_list_diy = c("#374E55FF","#DF8F44FF")
#cololr_list_diy = c("#6A6599FF","#00A1D5FF")  
cololr_list_diy = c("#800081","#00aafe")
linetype = c(1,1)
}
if(factor=="MinerVa.Prime_vs_Adj_ALL"){
  cololr_list_diy = c("#0000FF","#FF0000")
  cololr_list_diy = c("#6A6599E5","#00A1D5E5","#6A6599FF","#00A1D5FF")
  cololr_list_diy  = c("#6495ED","#0000FF","#F08080","#FF0000")
    cololr_list_diy = c("#800080","#00aaff","#800081","#00aafe")
  linetype = c(2,2,1,1)
}
    k2 = ggsurvplot(fit,data = data, censor.shape="|", censor.size = 1.5,pval.size = 1,font.size=10,
                   break.time.by = 6, linetype =linetype,
legend.title = "",legend.labs =  svv_diy_labs,
                   pval=pv,legend =  "none",palette = cololr_list_diy,ylab=ylab_flag,xlab="Time since randomization (months)",title = "",surv.scale = 'percent',surv.median.line = "hv",
                   risk.table=T,risk.table.fontsize=2,risk.table.col = "strata",ggtheme=theme_classic(),risk.table.height = 0.2,lwd = 0.5)
    outfile=paste0(outdir,"/",prefix,".",factor,".n=",dim(data)[1],".",pv_lable,".svv.pdf")
    print(outfile)
   k2$table <- k2$table +
    theme(legend.key.size = unit(4,"pt"),
          axis.title.y = element_blank(),
          axis.title.x = element_blank(),
          text = element_text(size = 4),
          plot.margin=margin(t=0,r=1,b=1,l=1, unit="pt"),
          axis.text.y = element_text(
                                     size = 4,
                                     margin = margin(t = 0, r = 0, b = 0, l = 0)),
          axis.text.x = element_text(
                                     size = 4,
                                     margin = margin(t = 0, r = 0, b = 0, l = 0)),                           )

    pdf(outfile,onefile=F,width=4,height=3)
    print(k2)
    dev.off()

  }
}
}



SVV_plot_2facotr <-function(data,patient,factor1,factor2,time,status,outdir,prefix){
  if(time=="OS"){
ylab_flag = "Overall survival"
}else if(time=="DFS"){
ylab_flag = "Disease-free survival"
}else if(time=="PFS"){
ylab_flag = "Progression-free survival"
}else{
ylab_flag = time
}

data<-data[,c(patient,factor1,factor2,time,status)]
if(dim(data)[1]>0){
  data[,factor1]<-factor(data[,factor1],levels=sort(unique(data[,factor1])[(unique(data[,factor1])!="")],decreasing=F))
  data[,factor2]<-factor(data[,factor2],levels=sort(unique(data[,factor2])[(unique(data[,factor2])!="")],decreasing=F))
factor = paste(factor1,factor2,sep="_vs_")
data[data==""] = NA
data[,factor] = ifelse(is.na(data[,factor1]) | is.na(data[,factor2]), NA, paste(data[,factor1], data[,factor2],sep="_"))

data<-data[,c(patient,factor1,factor2,factor,time,status)]
  colnames(data)<-c("patient",factor1,factor2,factor,"OS","re")
  data <-na.omit(data)
  data[,factor]<-factor(data[,factor],levels=sort(unique(data[,factor])[(unique(data[,factor])!="")],decreasing=F))
  data <-na.omit(data)
  print(unique(data[,factor]))

  if(dim(data)[1]>2){
    if(length(unique(data[,factor]))>=2){
    data$re<-as.numeric(as.character(data$re))
    fit=eval(parse(text=paste("survfit(Surv(OS,re) ~ ",factor,",data = data)",sep="")))
    fit3=eval(parse(text=paste("coxph(Surv(OS,re) ~ ",factor,",data = data)",sep="")))
    fit4<-summary(fit3)
    logtest<-as.matrix(fit4$sctest)
    colnames(logtest)<-"logrank"
    nn=round(logtest["pvalue",],4)
    HR<-max(as.data.frame(fit4$conf.int)[,"exp(coef)"])
    pv_lable = "_"
    if(nn<0.05){pv_lable = "sig"}
    facotr_number = as.matrix(fit$n)[,1]

    svv_diy_labs = c()
    for(i in rownames(as.matrix(fit$strata))){
      i = strsplit(i,'=')[[1]][2] 
      svv_diy_labs = c(svv_diy_labs,i)
    }
    svv_median = surv_median(fit, combine = FALSE)[,"median"]
    aa = data.frame(svv_diy_labs,facotr_number,svv_median)
    aa = aa[order(aa$facotr_number),]
    facotr_number = paste(aa$facotr_number,collapse=",")
    svv_diy_labs_name = paste(aa$svv_diy_labs,collapse=",")
    svv_median    = paste(round(aa$svv_median,1),collapse=",")
    svv_median2    = paste(round(aa$svv_media[order(aa$svv_median)],1),collapse=",")


    if(length(rownames(as.matrix(fit$strata)))>=3){
    data[,factor] = as.character(data[,factor])
    result <- get_pairwise_comparisons(data, "OS", "re", factor) 
    ddd = paste(as.character(result$label_table),collapse ="\n")

    if(length(rownames(as.matrix(fit$strata)))>=4){
    uni<- eval(parse(text=paste("coxph(Surv(OS,re) ~ ", factor1,"*",factor2,",data = data)",sep="")))
    uni<-as.data.frame(as.matrix(coef(summary(uni))))
    uni$feature<-factor1
    P_interaction = round(uni[grep(":",row.names(uni)),"Pr(>|z|)"],4)
}
 
      pv<-paste("P = ",nn,"\nP_interaction= ",P_interaction,"\nsurv_median: ",svv_median2,"\n",ddd)
      }
      else{     
      pv<-paste("P = ",nn,"\nHR = ",round(HR,2),"\n95%CI: ",round(fit4$conf.int[3],2),"-",round(fit4$conf.int[4],2),"\nsurv_median: ",svv_median2,sep="")
      }



    if(length(svv_diy_labs)==9){
     cololr_list_diy = c("#6495ED","#0000FF","#F08080","#FF0000", "#4DBBD5FF",  "#7E6148FF", "black","grey40","#663366")
     linetype = c(2,2,2,2,2,1,1,1,1)

    }
    if(length(svv_diy_labs)==8){
      cololr_list_diy = c("#6495ED","#0000FF","#F08080","#FF0000", "#4DBBD5FF",  "#7E6148FF", "black","grey40")
      linetype = c(2,2,2,2,1,1,1,1)
    }
   if(length(svv_diy_labs)==7){
      cololr_list_diy = c("#6495ED","#0000FF","#F08080","#FF0000", "#4DBBD5FF",  "#7E6148FF", "black")
      linetype = c(2,2,2,1,1,1,1)
    }
    if(length(svv_diy_labs)==6){
      cololr_list_diy = c("#6495ED","#0000FF","#F08080","#FF0000", "#4DBBD5FF",  "#7E6148FF", "#8491B4FF")
      linetype = c(1,1,1,1,1,1)
    }
  if(length(svv_diy_labs)==5){
      cololr_list_diy = c("#6495ED","#0000FF","#F08080","#FF0000", "#4DBBD5FF",  "#7E6148FF", "#8491B4FF")
      linetype = c(1,1,1,1,1)
    }
if(length(svv_diy_labs)==4){
  cololr_list_diy  = c("#374E5599","#374E55FF","#DF8F4499","#DF8F44FF")
    cololr_list_diy  = c("#6495ED","#0000FF","#F08080","#FF0000")
  linetype=c(1,1,1,1)
}
if(length(svv_diy_labs)==3){
  cololr_list_diy = c("#374E55FF","#DF8F44E5","#B24745FF")
  cololr_list_diy = c("#0000FF","#7E6148FF","#FF0000")
  linetype = c(1,1,1)
}
if(length(svv_diy_labs)==2){
  cololr_list_diy = c("#0000FF","#FF0000")
 # cololr_list_diy = c("#374E55FF","#DF8F44FF")
  cololr_list_diy = c("#800081","#00aafe")
  linetype = c(1,1)
}
if(factor=="MinerVa.Prime_vs_Adj_ALL"){
  cololr_list_diy = c("#0000FF","#FF0000")
  cololr_list_diy = c("#6A6599E5","#00A1D5E5","#6A6599FF","#00A1D5FF")
    cololr_list_diy  = c("#6495ED","#0000FF","#F08080","#FF0000")
    cololr_list_diy = c("#800080","#00aaff","#800081","#00aafe")
  linetype = c(1,1,1,1)
}

    k2 = ggsurvplot(fit,data = data, censor.shape="|", censor.size = 1.5,pval.size = 1,font.size=10,
                   break.time.by = 6, linetype =linetype, 
legend.title = "",legend.labs =  svv_diy_labs,
                   pval=pv,legend =  "none",palette = cololr_list_diy,ylab=ylab_flag,xlab="Time since randomization (months)",title = "",surv.scale = 'percent',surv.median.line = "hv",
                   risk.table=T,risk.table.fontsize=2,risk.table.col = "strata",ggtheme=theme_classic(),risk.table.height = 0.2,lwd = 0.5)
    outfile=paste0(outdir,"/",prefix,".",factor,".n=",dim(data)[1],".",pv_lable,".svv.pdf")
    print(outfile)
   k2$table <- k2$table +
    theme(legend.key.size = unit(4,"pt"),
          axis.title.y = element_blank(),
          axis.title.x = element_blank(),
          text = element_text(size = 4),
          plot.margin=margin(t=0,r=1,b=1,l=1, unit="pt"),
          axis.text.y = element_text(
                                     size = 4,
                                     margin = margin(t = 0, r = 0, b = 0, l = 0)),
          axis.text.x = element_text(
                                     size = 4,
                                     margin = margin(t = 0, r = 0, b = 0, l = 0)),                           )

    pdf(outfile,onefile=F,width=4,height=3)
    print(k2)
    dev.off()
  }
}
}
}






merge_table = "Source data.xlsx/pid.summary"
data = read.table(merge_table,header=T,sep="\t")
dim(data)
all_factors = colnames(data)
all_factors


df = data
df$OS  = df$OS / 30 
df$DFS = df$DFS / 30
PRO_dir = argv[8]
dir.create(PRO_dir)

print(dim(df))
df_C = subset(df,Adj_ALL=="Chemo")
df_T = subset(df,Adj_ALL=="Target")



df_list_vs = list(
"all"=df,
"df_C"=df_C,
"df_T"=df_T
)


if(T){
outdir=paste0(PRO_dir,"/svv")
dir.create(outdir)


#fig2A，#fig3A-C,#fig4D,4E, #fig5A,C, #figS1, #figS3A, #figS5A-B, #figS6A-D, 
#figS11A,11B(use new DFS time to mitigate the potential immortal survival bias,)
#figS12A-B(use new DFS time to mitigate the potential immortal survival bias,),
if(T){
for(n in names(df_list_vs) ){
for(j in c("DFS","OS")){
for(i in c("Adj_ALL","MinerVa.Prime","MinerVa.Prime_longitudinal","MinerVa.Prime_on_therapy","MinerVa.Prime_post_therapy","CF24W_MinerVa.Prime_clearance_info","pre.MinerVa.Prime_vs_EGFR_MRD","longitudinal.MinerVa.Prime_vs_EGFR_MRD")){
print(paste(">>>",n,j,i,sep=">>>"))
df_tmp = df_list_vs[[n]]
pv = SVV_plot(df_tmp,"PID",i,j,paste0("re_",j),outdir,paste0(n,".",j))
}
}
}
}

#fig2B #figS3B,
for(n in names(df_list_vs) ){
for(j in c("DFS")){
for(i in c("MinerVa.Prime"){
print(paste(">>>",n,j,i,"Adj_ALL",sep=">>>"))
df_tmp = df_list_vs[[n]]
pv = SVV_plot_2facotr(df_tmp,"PID",i,"Adj_ALL",j,paste0("re_",j),outdir,paste0(n,".",j))
}
}
}

#fig2E, #figS4B-D 
if(F){
for(n in names(df_list_vs) ){
for(j in c("DFS","OS")){
for(i in unique(c("Stage","Age_group","Smoking","Gender","EGFR_L858R_19DEL","ECOG","Adj_ALL"))){
#for(i in unique(c("Adj_ALL"))){
#for(m in c("MinerVa","MinerVa.Prime","EGFR_MRD")){
for(m in c("MinerVa.Prime","CF24W_MinerVa.Prime")){
print(paste(">>>",n,j,i,m,sep=">>>"))
df_tmp = df_list_vs[[n]]
pv = SVV_plot_2facotr(df_tmp,"PID",m,i,j,paste0("re_",j),outdir,paste0(n,".",j))
}
}
}}
}
}

