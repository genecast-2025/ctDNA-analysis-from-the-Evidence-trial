import os
import sys
import pandas as pd
import seaborn as sns
import numpy as np
import argparse
import matplotlib.pyplot as plt

#figS2A
outdir="./fig1/"
file1=pd.read_csv(outdir+"sim_LOD95.stat.v2.xls",sep="\t")
print(file1.head())
file1['tracking_number'] = file1['point_tracking']
file1['input'] = file1['group']
file1['lod_95(%)'] = file1['lod_95(%)'] / 100
file1['vaf_95_up(%)'] = file1['vaf_95_up(%)'] / 100
file1['vaf_95_low(%)'] = file1['vaf_95_low(%)'] / 100

data=file1[["tracking_number", "input", "lod_95(%)","vaf_95_up(%)",'vaf_95_low(%)']].drop_duplicates()

print(set(data['tracking_number']))
data = data[~data['tracking_number'].isin(['8','70'])]
print(set(data['tracking_number']))


order = ['1 (EGFR)','6','10','20', '30','40','50','60']
data['tracking_number'] = pd.Categorical(data['tracking_number'], categories=order, ordered=True)
data=data.sort_values(by=['input','tracking_number'], ascending=[True, True])
data.to_csv("plot_input.sim_LOD95.stat.v2.xls",index=False,sep="\t")
custom_palette = ['#EDD3CF', '#AA6C8F',  '#2F223C' ] 
custom_palette = ['#374E55FF', '#DF8F44FF',  '#00A1D5FF' ]
sns.set_palette(custom_palette)
barplot2=sns.barplot(data=data,x=data['tracking_number'],y=data["lod_95(%)"],hue="input")
flag=0

for a in range(len(data)):
    bar2 = barplot2.patches[a]
    height2 = bar2.get_height()
    print(height2)
    index=data["lod_95(%)"].tolist().index(height2)
    #row2 = data.iloc[a]
    vaf_95_low=data['vaf_95_low(%)'].tolist()[index]
    vaf_95_up=data['vaf_95_up(%)'].tolist()[index]
    plt.errorbar(
        x=bar2.get_x() + bar2.get_width()/2,  
        y=height2,
        yerr=[[height2 - vaf_95_low], [ vaf_95_up - height2]],
        capsize=5,
        color='black',
        fmt='none' 
        )
plt.yscale("log")
plt.legend(title="input (ng)",loc="upper right")
plt.ylabel("LoD95")
plt.xlabel("Number of tracking variants")
#plt.yticks([1e-5,5e-5,1e-4,5e-4,1e-3,5e-3,1e-2,5e-2,1e-1,5e-1]) 
plt.yticks([1e-5,5e-5,1e-4,5e-4,1e-3]) 
#plt.savefig("LOD95_t10_30_50_EGFR.plot2.pdf")
plt.savefig("figS2A.pdf")
#plt.show()






#figS2B
dir="./fig1/"
custom_palette = ['#374E55FF', '#DF8F44FF',  '#00A1D5FF','#B24745FF' ]
input30=pd.read_csv(dir+"JinL_LOD.30ng.samplep.spe.xls",sep="\t")
input30.loc[input30["sample_p"]<1e-10,"sample_p"]=1e-10
input30["PPM"] = input30["PPM"] / 10000
sns.scatterplot(x=input30["sample_ratio"],y="sample_p",hue=input30["PPM"].astype(str),data=input30,hue_order=["0.0025","0.005","0.05","0.5"],palette=custom_palette)
plt.axhline(y=0.01,color="red",linestyle='--')
plt.yscale("log")
plt.xscale("log")
plt.xlabel("ctDNA Ratio")
plt.legend(loc="upper right",title="Tumor fraction(%)")
plt.savefig(dir+"figS2B.pdf")
#plt.show()


#figS2C
new_labels = [f'H{i}' for i in range(1, 15)]
directory="./fig1/"
combined_info_neg=pd.read_csv(directory+"14Healthy_sample_blank_samplep.for.swarmplot.xls",sep="\t")
# Set figure size to adjust the height and width of the plot
custom_palette = ['#374E55FF', '#DF8F44FF',  '#00A1D5FF' ]
sns.set_palette(custom_palette)

plt.figure(figsize=(12, 6))

sns.swarmplot(x=combined_info_neg["sample_id"],y=combined_info_neg["sample_p"].astype(float))
plt.axhline(y=0.01, color='r', linestyle='--', label='y=0.01')
plt.xticks(ticks=combined_info_neg["sample_id"].unique(), labels=new_labels, rotation=45)
plt.ylabel("sample_p")
plt.yscale("log")
plt.legend(loc="lower left")
plt.savefig("figS2C.pdf")

#figS2D
file="sim.input.95CI.spe.xls"
grouped_data=pd.read_csv(file,sep="\t")
print(set(grouped_data['track_num']))
grouped_data = grouped_data[grouped_data["track_num"]!="8"]
print(set(grouped_data['track_num']))
custom_palette = ['#EDD3CF', '#AA6C8F',  '#2F223C' ] 
custom_palette = ['#374E55FF', '#DF8F44FF',  '#00A1D5FF' ]
group_order = ["<20","20-40",">40"]
#grouped_data['track_num']=grouped_data['track_num'].astype(int)
track_order=['EGFR','6','10','20','30','40','50','60']


grouped_data['input(ng)'] = pd.Categorical(grouped_data['input(ng)'], categories=group_order, ordered=True)
grouped_data['track_num'] = pd.Categorical(grouped_data['track_num'], categories=track_order, ordered=True)

sns.set_palette(custom_palette)
barplot = sns.barplot(
    #x=grouped_data['track_num'].astype(int),
    x=grouped_data['track_num'],
    y='Specificity',
    hue='input(ng)',
    data=grouped_data
)
#plt.axhline(y=99, color='r', linestyle='--', label='y=0.01')
grouped_data2=grouped_data.sort_values(by=['input(ng)','track_num'])
for a in range(len(grouped_data2)):
        bar = barplot.patches[a]
        bar_x = bar.get_x() + bar.get_width() / 2
        height=bar.get_height()
        index=grouped_data2["Specificity"].tolist().index(height)
    #row2 = data.iloc[a]
        ci_lower=grouped_data2['ci_lower'].tolist()[index]
        ci_upper=grouped_data2['ci_upper'].tolist()[index]
     
        plt.errorbar(x=bar_x, y=height, yerr=[[height - ci_lower], [ci_upper - height]],
                    fmt='none', color='black', capsize=5)
plt.legend(loc="lower left",title='input (ng)',)
plt.ylabel(' Specificity(%)')
plt.xlabel('Number of tracking variants')
plt.ylim(95, 100)
plt.savefig("figS2D.pdf")
#plt.show()


#figS2E
dirs="./fig1/"
file=dirs+"t50_input.quantitative.final.xls"
outfile=dirs+"figS2E.pdf"
combined_info_set=pd.read_csv(file,sep="\t")
combined_info_raw = combined_info_set
combined_info3=combined_info_raw[combined_info_raw["track_num"]==50]
combined_info_pos=combined_info3[combined_info3["sample_p"].astype(float)<0.01]
combined_info_zero=combined_info3[combined_info3["sample_p"].astype(float)>=0.01]
combined_info_zero["ctDNA_ratio"]=1e-6
#custom_palette = ['#EDD3CF', '#AA6C8F',  '#2F223C' ] 
custom_palette = ['#374E55FF', '#DF8F44FF',  '#00A1D5FF' ] 
sns.set_palette(custom_palette)
orderlist=[ '0.0006', '0.0013','0.0025','0.005','0.05','0.5']

fig, ax1 = plt.subplots(figsize=(6, 4))
sns.boxplot(x="TumorFraction",y="ctDNA_ratio",ax=ax1,data=combined_info_pos,showfliers=False,hue="input",palette=custom_palette)
sns.stripplot(x='TumorFraction', y='ctDNA_ratio', ax=ax1,hue='input', data=combined_info_zero,palette=custom_palette, jitter=0.4, 
                  marker='o', facecolor='white', edgecolor='black', linewidth=0.5, dodge=True,legend=False)
ax1.set_yscale("log")
plt.legend(loc="upper left",title="input (ng)")
plt.ylabel("ctDNA Ratio")
plt.xlabel("Tumor Fraction (%)")
#plt.show()
plt.savefig(outfile)



#figS2F
file=dirs+"Seraseq_track_num_quantitative.xls"
outfile=dirs+"figS2F.pdf"
data=pd.read_csv(file,sep="\t")
def plt_track(combined_info_raw,outfile):
    combined_info2=combined_info_raw[(combined_info_raw["input"]==30)]
   
    orderlist=[ '0.0006', '0.0013','0.0025','0.005','0.05','0.5']

    combined_info2=combined_info2[combined_info2["TumorFraction"]!="0.0000"]
    combined_info=combined_info2

    combined_info_nonzero=combined_info.loc[combined_info["sample_p"].astype(float)<0.01]
    combined_info_zero=combined_info.loc[combined_info["sample_p"].astype(float)>=0.01]
    combined_info_zero.loc[combined_info["sample_p"].astype(float)>0.01,"sample_ratio_update"]=1e-6
   
    
    fig, ax = plt.subplots(figsize=(6, 4))
    print(combined_info_nonzero.head())
    custom_palette = ['#EDD3CF', '#AA6C8F',  '#2F223C' ] 
    custom_palette = ['#374E55FF', '#DF8F44FF',  '#00A1D5FF' ] 
    sns.set_palette(custom_palette)
    sns.boxplot(x="TumorFraction",y="fraction",ax=ax,data=combined_info_nonzero,showfliers=False,hue="track_num")
    sns.stripplot(x='TumorFraction', y='sample_ratio_update', ax=ax,hue='track_num', data=combined_info_zero, jitter=0.4, 
              marker='o', facecolor='white', edgecolor='black', linewidth=0.5, dodge=True,order=orderlist,legend=False,palette=custom_palette)
    ax.set_yscale("log")
    #plt.yscale("log")
    plt.legend(loc="upper left",title="Number of tracking variants")
    plt.ylabel("ctDNA Ratio")
    plt.xlabel("Tumor Fraction(%)")
    plt.savefig(outfile)
plt_track(data,outfile)









