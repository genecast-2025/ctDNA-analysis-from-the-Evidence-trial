# Load required packages
library(survival)
library(timeROC)
library('survivalROC')
library(ggplot2)
argv<-commandArgs()

#fig4C
merge_table = "Source data.xlsx/pid.summary"
df = read.table(merge_table,header=T,sep="\t")

max_time <- max(df$DFS)
time_points <- seq(12*30, max_time-30, by = 30)


get_roc_curve1 <- function(df, DFS,re_DFS,MRD_markers,time_points) {
data = df[,c("PID","Adj_ALL","Stage",DFS,re_DFS,MRD_markers)]
data[data==""] = NA
data = na.omit(data)
print(dim(df))
print(dim(data))
print(data[,c(MRD_markers)])

formula_str <- as.formula(paste("Surv(",DFS,", ",re_DFS,") ~ Adj_ALL + Stage +", MRD_markers))
model <- coxph(formula_str, data = data)

auc_values_res <- numeric(length(time_points))
for (i in seq_along(time_points)) {
    print(i)	
    time_roc_res <- timeROC(
        T = data$DFS,
        delta = data$re_DFS,
        marker = predict(model, type = "risk"),
        cause = 1,
        weighting = "marginal",
        times = time_points[i],
        ROC = TRUE,
        iid = TRUE
    )
    auc_values_res[i] <- time_roc_res$AUC[2]  
}
return(auc_values_res)
}

res_0w = get_roc_curve1(df, "DFS","re_DFS","CF0W_MinerVa.Prime",time_points)
res_12W = get_roc_curve1(df, "DFS","re_DFS","CF12W_MinerVa.Prime",time_points)
res_24W = get_roc_curve1(df, "DFS","re_DFS","CF24W_MinerVa.Prime",time_points)
res_36W = get_roc_curve1(df, "DFS","re_DFS","CF36W_MinerVa.Prime",time_points)




auc_data <- data.frame(
    Time = rep(time_points, 4),
    AUC = c(res_0w,res_12W,res_24W,res_36W),
    Factor = rep(c("CF0W", "CF12W", "CF24W","CF36W"), each = length(time_points))
)
auc_data

write.table(auc_data,file="auc_data.xls",row.names=F,col.names=T,sep="\t",quote=F)

pdf('auc.time_ROC.point.pdf',width=6,height=4)
ggplot(auc_data, aes(x = Time, y = AUC, color = Factor)) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE)+
    labs(title = "Time-dependent AUC for different weeks",
         x = "Follow up time (months)",
         y = "Predicted AUC") +
#    theme_bw()+
theme_classic() + #theme_bw() +
theme(panel.background = element_rect(fill = 'transparent'),
        panel.border = element_rect(fill = NA, colour = "black"))+
    ggsci::scale_color_jama(alpha = 0.9)+
scale_x_continuous(breaks = seq(0, max_time, by = 180), 
                       labels = function(x) paste(x / 30, "months",sep="\n"))

dev.off()






