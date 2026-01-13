library(forestplot)
library(dplyr)
argv<-commandArgs()



#fig2C  
merge_table = "Source data.xlsx/fig2C"
data = read.table(merge_table,header=T,sep="\t",check.names=F)
label <- cbind(
  c("Variable", data$Variable),
  c("HR (95% CI)", data$`HR (95% CI)`),
  c("p-value", data$`P-value`)
)

p=forestplot(
  labeltext = label, 
  mean = c(NA, data$HR), 
  lower = c(NA, data$LHR), 
  upper = c(NA, data$UHR), 
  xlog = T,
  zero = 1, 
  graphwidth = unit(.2,"npc"),
  boxsize = 0.2, 
  lineheight = unit(26, 'mm'), 
  colgap = unit(2, 'mm'), 
  lwd.zero = 2, 
  lwd.ci = 2, 
  col = fpColors(box = 'black', lines = 'black', zero = 'grey'), 
  hrzl_lines = list(
    #"1" = gpar(lty = 1, lwd = 1, col = "black"),
    "2" = gpar(lty = 1, lwd = 1, col = "black")
  ), 
  lwd.xaxis = 2, 
  lty.ci = "solid", 
  graph.pos = 3, 
 line.margin = unit(0.25, "cm"),

  xticks = c(log(0.1), log(1), log(10)), 
  txt_gp = fpTxtGp(
    label = gpar(fontfamily = "serif", cex = 1, lineheight = 1), 
    ticks = gpar(fontfamily = "serif", cex = 1),
    xlab = gpar(fontfamily = "serif", cex = 0.8),
    title = gpar(fontfamily = "serif", cex = 1)
  )
)

pdf(paste(merge_table,".pdf",sep=""), height=6,width = 16)
print(p)
grid::grid.text("Better DFS", x = unit(0.7, "npc"), y = unit(0.02, "npc"), gp = gpar(fontface = "bold", fontsize = 12))
grid::grid.text("Worse DFS", x = unit(0.4, "npc"), y = unit(0.02, "npc"), gp = gpar(fontface = "bold", fontsize = 12))
dev.off()



#fig2E  
merge_table = "Source data.xlsx/fig2E"
data = read.table(merge_table,header=T,sep="\t",check.names=F)
data
label <- cbind(
  c("Variable", data$Subgroup),
  c("MRD+\n(events/pts)\n", data$`Positive(events/patients)`),
  c("MRD-\n(events/pts)\n", data$`Negative(events/patients)`),
  c("HR(95% CI)", data$`HR(95% CI)`),
  c("p interaction", data$P_interaction)
)

is_summary = c(T,data$is_summary)
p=forestplot(
  labeltext = label, 
  mean = c(NA, data$HR), 
  lower = c(NA, data$LHR), 
  upper = c(NA, data$UHR), 
  is.summary = is_summary, 
  xlog = T,
  zero = 1, 
  graphwidth = unit(.2,"npc"),
  boxsize = 0.2, 
  lineheight = unit(26, 'mm'), 
  colgap = unit(2, 'mm'), 
  lwd.zero = 2, 
  lwd.ci = 2, 
  col = fpColors(box = 'black', lines = 'black', zero = 'grey'), 
  hrzl_lines = list(
    "2" = gpar(lty = 1, lwd = 1, col = "black")
  ), 
  lwd.xaxis = 2, 
  lty.ci = "solid", 
  graph.pos = 5, 
 line.margin = unit(0.25, "cm"),
  xticks = c(log(0.5), log(4), log(32)),
  txt_gp = fpTxtGp(
    label = gpar(fontfamily = "serif", cex = 1, lineheight = 1), 
    ticks = gpar(fontfamily = "serif", cex = 1),
    xlab = gpar(fontfamily = "serif", cex = 0.8),
    title = gpar(fontfamily = "serif", cex = 1)
  )
)

pdf(paste(merge_table,".pdf",sep=""), height=6,width = 8)
print(p)
grid::grid.text("Better DFS", x = unit(0.7, "npc"), y = unit(0.02, "npc"), gp = gpar(fontface = "bold", fontsize = 12))
grid::grid.text("Worse DFS", x = unit(0.4, "npc"), y = unit(0.02, "npc"), gp = gpar(fontface = "bold", fontsize = 12))
dev.off()

#figS4E
merge_table = "Source data.xlsx/figS4E"
data = read.table(merge_table,header=T,sep="\t",check.names=F)
data
label <- cbind(
  c("Studies", data$Studies),
  c("Stage", data$Stage),
  c("MRD+\n(events/pts)\n", data$`Positive(events/patients)`),
  c("MRD-\n(events/pts)\n", data$`Negative(events/patients)`),
  c("HR(95% CI)", data$`HR(95% CI)`),
  c("P interaction\n(I-II)", data$`P_interaction(I_II)`),
  c("P interaction\n(I-III)", data$`P_interaction(I_III)`),
  c("P interaction\n(II-III)", data$`P_interaction(II_III)`)
)

is_summary = c(T,data$is_summary)
p=forestplot(
  labeltext = label, 
  mean = c(NA, data$HR), 
  lower = c(NA, data$LHR), 
  upper = c(NA, data$UHR), 
  is.summary = is_summary, 
  xlog = T,
  zero = 1, 
  graphwidth = unit(.2,"npc"),
  boxsize = 0.2, 
  lineheight = unit(26, 'mm'), 
  colgap = unit(1, 'mm'), 
  lwd.zero = 2, 
  lwd.ci = 2, 
  col = fpColors(box = 'black', lines = 'black', zero = 'grey'), 
  hrzl_lines = list(
    #"1" = gpar(lty = 1, lwd = 1, col = "black"),
    "2" = gpar(lty = 1, lwd = 1, col = "black")
  ), 
  lwd.xaxis = 2, 
  lty.ci = "solid", 
  graph.pos = 5, 
#  clip = c(0, 3), 
#  clip = c(0.05, 1.0),
 line.margin = unit(0.25, "cm"),
  #xticks = c(0, 1, 10,20,30), 
  #xticks = c(-1,0, 1,2,3),
  xticks = c(log(0.5), log(4), log(32)),
  txt_gp = fpTxtGp(
    label = gpar(fontfamily = "serif", cex = 1, lineheight = 1), 
    ticks = gpar(fontfamily = "serif", cex = 1),
    xlab = gpar(fontfamily = "serif", cex = 0.8),
    title = gpar(fontfamily = "serif", cex = 1)
  )
)

pdf(paste(merge_table,".pdf",sep=""), height=10,width = 16)
print(p)
grid::grid.text("Worse DFS", x = unit(0.7, "npc"), y = unit(0.02, "npc"), gp = gpar(fontface = "bold", fontsize = 12))
grid::grid.text("Better DFS", x = unit(0.4, "npc"), y = unit(0.02, "npc"), gp = gpar(fontface = "bold", fontsize = 12))
dev.off()







