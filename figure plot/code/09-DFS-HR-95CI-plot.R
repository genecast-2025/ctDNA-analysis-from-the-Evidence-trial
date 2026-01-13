library(ggplot2)
library(ggsci)
library(dplyr)

#fig4B
split_string <- function(x) {
  matches <- regmatches(x, gregexpr("([^()]+)", x, perl = TRUE))[[1]]
  y <- matches[1]
  z <- matches[2]
  return(y)
}

split_string2 <- function(x) {
  matches <- regmatches(x, gregexpr("([^()]+)", x, perl = TRUE))[[1]]
  y <- matches[1]
  z <- matches[2]
  return(z)
}

monlist1 = c(0,12,24,36,48,60,72,84,96,108,132)
monlist1_list = c()
for(i in monlist1){
monlist1_list = c(monlist1_list,paste0("CF",i,"W"))
}


title="MinerVa.Prime"
ybreaks = c(5,10,seq(0,100,20),200)
ylables = c(5,10,seq(0,100,20),200)

merge_table = "Source data.xlsx/fig4B"

df <- read.table(merge_table, header = T, stringsAsFactors = F) %>%
    mutate(HR_tmp = HR) %>%
    mutate(Time = gsub("_MinerVa.Prime","",Factor1)) %>%
    mutate(HR = as.numeric(unlist(lapply(HR_tmp, split_string)))) %>%
    mutate(CI = unlist(lapply(HR_tmp, split_string2))) %>%
    mutate(Cohort = factor(Cohort, ordered = T, levels = c("All", "Target", "Chemo")),
           Time   = factor(Time,ordered = T, levels = monlist1_list),
           CI_low = as.numeric(gsub("[-].*", "", CI)),
           CI_high = as.numeric(gsub(".*[-]", "", CI))) %>%
    arrange(Cohort) %>% group_by(Time) %>%
    mutate(group_number = paste0(Cohort_number, collapse = " | "),
           Stage_new = paste0(Time, "\n", "(", group_number ,")"))
  df$Stage_new = factor(df$Stage_new,levels=unique(df$Stage_new))
df
df$Cohort = gsub("Target","Icotinib",df$Cohort)
df$Cohort = gsub("Chemo","Chemotherapy",df$Cohort)
df$Cohort = factor(df$Cohort,levels=c("All","Icotinib", "Chemotherapy"))
 pdf("fig4B.pdf", width = 6, height = 4, pointsize = 12)
  p <- ggplot(data = df,
              aes(x = Stage_new, y = HR,
                  ymin = CI_low, ymax = CI_high,
                  colour = Cohort, fill = Cohort))+
    geom_errorbar(position = position_dodge(width = 0.7), width = 0.4, color = "black", size = 0.4) +
    geom_point(position = position_dodge(width = 0.7)) +
    scale_y_continuous(trans="log2",breaks=ybreaks, labels=ylables)+
    guides(size = "none") +
    ylab("HR")  +
    xlab("Time since randomization (weeks)") +
    theme_bw() +
    theme(
panel.background = element_rect(fill = 'transparent'),
        panel.border = element_rect(fill = NA, colour = "black"),
  panel.grid.major = element_blank(),     
    panel.grid.minor = element_blank(),     
axis.text.x = element_text(angle = 45, hjust = 1,size=8),
strip.background = element_blank(),
          strip.text = element_text(face = "bold", size = 6),
          legend.position = "top")+ 
scale_color_manual(name='Cohort', values=c("All" = "#B24745FF","Icotinib"="#00A1D5FF", "Chemotherapy"="#6A6599FF"))
#    ggsci::scale_color_jama(alpha = 0.9)+ ggtitle(title)
#scale_color_npg()+ ggtitle(title)
  print(p)
  dev.off()

