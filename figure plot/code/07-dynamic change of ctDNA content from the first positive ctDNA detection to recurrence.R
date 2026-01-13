library(ggplot2)
library(ggsci)
library(dplyr)
library(tidyr)
require(cowplot)

argv<-commandArgs()


###fig3G
merge_table = "Source data.xlsx/fig3G"
data = read.table(merge_table,header=T,sep="\t")
outfile = argv[6]
data[data == ''] <- NA
data$re_DFS[data$re_DFS ==  0]="No recurrence"
data$re_DFS[data$re_DFS ==  1]="Recurrence"
data$re_DFS = factor(data$re_DFS,levels=c("Recurrence","No recurrence"))
data$Adj_ALL = gsub("Chemo", "Chemotherapy", data$Adj_ALL)
data$Adj_ALL = gsub("Target", "Icotinib", data$Adj_ALL)
data$time_to_relapse = data$inter_FF - data$DFS
data$DFS = 0

data$hGE = ifelse(data$MinerVa.Prime=="Negative",0,data$hGE)
group_list = read.table(argv[7],header=FALSE,sep="\t")
group_list
dim(data)
data[data == ''] <- NA
dat = data

ybreaks <- c(0, 1,5, 10, 50,100,200,300,2000,3000)
ylables <- c(0, 1,5, 10, 50,100,200,300,2000,3000)


for (i in group_list$V1) {
    print(i)
    data <- dat
    data <- data[, c("time_to_relapse", "PID", "Adj_ALL", "hGE", i, "MinerVa.Prime")]
    print(dim(data))
    data <- na.omit(data)
    print(dim(data))
    data[, i] <- factor(data[, i])
    subgroup_counts <- data %>%
        group_by(re_DFS) %>%
        summarise(n = n_distinct(PID)) %>%
        ungroup() %>%
        mutate(label = paste0("N=", n))
subgroup_counts
    data_with_labels <- merge(data, subgroup_counts, by = c("re_DFS"))
    pdf_filename <- paste(outfile, paste(i, "test.re_DFS.pdf", sep = '.'), sep = '.')
    print(head(data))


data_with_labels$`DFS status` = data_with_labels$re_DFS
    p <- ggplot(data_with_labels, aes(x = time_to_relapse, y = hGE, group = PID)) +
        geom_line(aes(color = Adj_ALL,linetype = `DFS status`), size = 1) +
        #geom_point(aes(fill = MinerVa.Prime), size = 2, shape = 21, color = "black") +
        geom_point(aes(fill = Adj_ALL), size = 2, shape = 21) +
        theme_bw() +
        facet_wrap(~ re_DFS) +
        #scale_color_manual(values = alpha(rainbow(length(unique(data_with_labels$PID))), 0.8), name = 'PID') +
        #scale_fill_manual(name = 'MinerVa.Prime', values = alpha(c("Positive" = "black", "Negative" = "gray"), c(1, 0.5)), na.value = "white") +
        scale_fill_manual(name = 'MinerVa.Prime', values = c("Icotinib" = "#00aaff", "Chemotherapy" = "#800080"), na.value = "white") +
        scale_color_manual(name = 'Adj_therapy',  values = c("Icotinib" = "#00aaff", "Chemotherapy" = "#800080")) + 
        scale_y_continuous(trans = "log2", breaks = ybreaks, labels = ylables) +
        #scale_linetype_manual(name="DFS status")+
        theme(text = element_text(size = 18, face = "bold"),
              legend.position = 'right',
              axis.text.x = element_text(angle = 45, hjust = 1),
              panel.grid.major = element_blank(), 
              panel.grid.minor = element_blank(),
#              strip.background = element_rect(fill = c("Icotinib" = "#00aaff", "Chemotherapy" = "#800080")[unique(data_with_labels$re_DFS)]))+
              strip.background =  element_blank())+
        labs(color = 'Adj_therapy', fill = 'MinerVa.Prime') +
        ylab("hGE(ng/ml)") +
        xlab("Time to recurrence or end of radiological follow-up (days)") +
        #geom_hline(yintercept = 0.000001 , linetype = "dashed", color = "grey") +
        geom_vline(xintercept = 0, linetype = "dashed", color = "black") +
        #ggtitle("xxx") +
        geom_text(data = subgroup_counts, aes(x = Inf, y = Inf, label = label),
                  vjust = 2, hjust = 2, size = 5, fontface = "bold", inherit.aes = FALSE)

    pdf(pdf_filename, width = 16, height = 9)
    print(p)
    dev.off()
}
