
library(ggplot2)
library(dplyr)
library(tidyr)
library(broom)
library(forcats)
suppressMessages(library(ggsci))

# figS4a
merge_table = "Source data.xlsx/pid.summary"
df <- read.table(merge_table,check.names = F,sep = "\t",header = T)
df$MinerVa.Prime_pre_therapy = df$MinerVa.Prime
df$MinerVa.Prime_pre_therapy <- gsub("Positive",1,df$MinerVa.Prime_pre_therapy)
df$MinerVa.Prime_pre_therapy <- gsub("Negative",0,df$MinerVa.Prime_pre_therapy)
df[df == ''] <- NA
df[,"ECOG"] = factor(df[,"ECOG"],levels=c(0,1))
df$Adj_therapy = df$Adj_ALL
df$Adj_therapy = gsub("Chemo", "Chemo", df$Adj_therapy)
df$Adj_therapy = gsub("Target", "Icotinib", df$Adj_therapy)
df$N_stage = gsub("N0_N1", "N0-N1", df$N_stage)
df$Stage = df$TNM_stage
df$EGFR_mutation = df$EGFR_L858R
df$EGFR_mutation = gsub("Mut", "L858R", df$EGFR_mutation)
df$EGFR_mutation = gsub("Wild", "19Del", df$EGFR_mutation)
df$Overall = "overall"
df$Histological = df$Histological_subtype
df$Age = df$Age_group
dat = df[,c("PID","Gender","Smoking","Stage","Adj_therapy","EGFR_mutation","ECOG","T_stage","N_stage","Histological","Age","MinerVa.Prime_pre_therapy","Overall")]
dim(dat)

long_dat <- dat %>%
  pivot_longer(cols = c(Gender,Smoking,Stage,Adj_therapy,EGFR_mutation,Histological,Age,ECOG,T_stage,N_stage,Overall), names_to = "Subgroup", values_to = "Value")
long_dat$MinerVa.Prime_pre_therapy = as.numeric(long_dat$MinerVa.Prime_pre_therapy)
long_dat = long_dat %>%
  filter(!is.na(MinerVa.Prime_pre_therapy)) %>%  
  filter(!is.na(Value))


summary_table <- long_dat %>%
  group_by(Subgroup, Value) %>%
  summarize(
    total = n(),
    positive = sum(MinerVa.Prime_pre_therapy),
    positive_rate = positive / total
  ) %>%
  ungroup()

summary_table <- summary_table[order(summary_table$Subgroup, -summary_table$positive_rate), ]


pairwise_fisher <- function(data) {
  subgroups <- unique(data$Subgroup)
  results <- list()
  
  for (subgroup in subgroups) {
    values <- as.character(unique(data$Value[data$Subgroup == subgroup]))
    if(length(values)>=2){ 
    table <- table(data$MinerVa.Prime_pre_therapy[data$Subgroup == subgroup], as.character(data$Value[data$Subgroup == subgroup]))
    fisher_test <- fisher.test(table)
    or <- fisher_test$estimate
    ci <- fisher_test$conf.int
    if(is.null(ci)){
      or="."
      ci=c(".",".")
    }
    p_value <- fisher_test$p.value
    
    results[[subgroup]] <- data.frame(
      Subgroup = subgroup,
      OR = or,
      CI_lower = ci[1],
      CI_upper = ci[2],
      p_value = p_value
    )
  }
  }
  return(do.call(rbind, results))
}

comparison_results <- pairwise_fisher(long_dat)
comparison_results
annotations_df <- data.frame()

for (i in 1:nrow(comparison_results)) {
  subgroup <- comparison_results$Subgroup[i]
  
  summary_subgroup <- summary_table %>%
    filter(Subgroup == subgroup) %>%
    slice(2)
summary_subgroup$Value = paste0(summary_subgroup$Value," (",summary_subgroup$positive,"/",summary_subgroup$total,")")

    print(">>>>>>>>>>>>>>>>")
    print(summary_subgroup) 
  max_positive_rate <- max(summary_table$positive_rate[summary_table$Subgroup == subgroup]) + 0.05
  
  if (comparison_results$OR[i] == ".") {
    annotations = NA
    #pvalue = signif(comparison_results$p_value[i], 2)
    pvalue = round(comparison_results$p_value[i], 2)
  } else {
    annotations <- paste0(
      round(as.numeric(comparison_results$OR[i]), 2), 
      "(", 
      round(as.numeric(comparison_results$CI_lower[i]), 2), 
      ", ", 
      round(as.numeric(comparison_results$CI_upper[i]), 2), 
      ")")  
    #  pvalue =signif(comparison_results$p_value[i], 2)
    pvalue = round(comparison_results$p_value[i], 3)

  }
  
  annotations_df <- rbind(annotations_df, data.frame(
    Subgroup = subgroup,
    Value = summary_subgroup$Value,
    x = max_positive_rate,
    label = annotations,
    pvalue = pvalue
  ))
}


single_annotation_df <- data.frame(
  Subgroup = "Adj_therapy",  
  Value = "",         
  x = 0.75,
  label = "OR (95% CI)",
  pvalue = "P-value"
)

        ColorAll = c(pal_d3("category10")(10),pal_npg("nrc", alpha = 0.8)(8))
summary_table$Value = paste0(summary_table$Value," (",summary_table$positive,"/",summary_table$total,")")
summary_table$Value = factor(summary_table$Value, levels = unique(summary_table$Value))
summary_table$Subgroup = factor(summary_table$Subgroup,levels =c("Overall","Adj_therapy","Age","Gender","ECOG","Histological","T_stage","N_stage","Stage","EGFR_mutation","Smoking"))
summary_table
annotations_df
cut_sig <- function(p) {
  out <- cut(p, breaks = c(0, 0.001, 0.01, 0.05, 1), include.lowest = T, labels = c("***","**", "*", "ns"))
  return(out)}
annotations_df$pvalue_sig = cut_sig(annotations_df$pvalue)

write.table(annotations_df,file="annotations_df.xls",row.names=F,col.names = TRUE,quote = F,sep="\t")
write.table(summary_table,file="summary_table.xls",row.names=F,col.names = TRUE,  quote = F,sep="\t")



p <- ggplot(summary_table, aes(y = fct_inorder(Value), x = positive_rate, fill = Subgroup)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.7) +
  geom_text(aes(label = scales::percent(positive_rate, accuracy = 0.1)),
            hjust = -0.3, position = position_dodge(width = 0.7), size = 6) +
  theme_bw() +
  #theme_classic() +
  labs(title = "",
       y = "",
       x = "ctDNA Positive ratio") +
  facet_grid(rows = vars(Subgroup), scales = "free_y", space = "free", switch = "y") +
  theme(
    legend.position = "none",
    strip.background = element_rect(fill = "white", color = "white"),
    text = element_text(size = 22, face = "bold"),
    strip.text.y.left = element_text(angle = 0, hjust = 1),  
    strip.placement = "outside",                             
    panel.spacing.y = unit(0.5, "lines"),                    
    axis.text.y = element_text(margin = margin(r = -140)),     
     panel.grid.major = element_blank(),                      
    panel.grid.minor = element_blank(),                       
        axis.ticks.y = element_blank()                           

  ) +
  scale_fill_manual(values = ColorAll) +
  scale_x_continuous(labels = scales::percent, limits = c(-0.3, 0.75)) +
  #geom_text(data = annotations_df, aes(x = 0.7, y = Value, label = pvalue), size = 6, hjust = 0, vjust = 0.5) +
  geom_text(data = annotations_df, aes(x = 0.7, y = Value, label = pvalue_sig), size = 6, hjust = 0, vjust = 0.5) +
  ggtitle("                                        Pvalue") #+

pdf("figS4a.pdf", height = 12, width = 9)
print(p)
dev.off()

