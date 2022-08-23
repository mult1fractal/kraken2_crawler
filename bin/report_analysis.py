docker run --rm -it -v $PWD:/input multifractal/template_pandas:v3.8.p--21e23c9
cd input/
python
# importing module 
import pandas as pd
import numpy as np
import glob

# The * is not a regex, it just means "match anything"
# This matches datafile-0.csv, datafile-1.csv, etc.
filenames = glob.glob("*.kreport")
# convert files to list of dataframpe with a list comprehension
list_of_dfs = [pd.read_csv(filename, sep='\t') for filename in filenames]
# add column names
for df in list_of_dfs: 
    df.columns = ['Abundance', 'Reads', 'other', 'Tax_leaf', 'other2', 'Organism']

# zip loops through TWO THINGS AT ONCE
# so you're looking at dataframe #1 and filename #1
# then dataframe #2 and filename #2
# etc
# and assigning that filename as a new column in the dataframe
for dataframe, filename in zip(list_of_dfs, filenames):
    dataframe['filename'] = filename

# Combine a list of dataframes, on top of each other
combined_df = pd.concat(list_of_dfs, ignore_index=True)
# Extract lines that only contain Genus
Genus_dataframe = combined_df[combined_df['Tax_leaf'] == "G"]
##for genus activate str stip
## replace whitespace in column ## to remove both endings .str.strip()
#Genus_dataframe.Organism = Genus_dataframe.Organism.str.replace(' ', '')
##for species actiivate
Genus_dataframe['Organism'] = Genus_dataframe['Organism'].str.strip()


#To select rows whose column value equals a scalar, some_value, use ==:
# put these organisms to a list
df_test = Genus_dataframe.loc[Genus_dataframe['Reads'] >= 40]
col_one_list = df_test['Organism'].tolist()

## count total reads

## extract rows that contain the organisms in a list
pat = '|'.join(r"\b{}\b".format(x) for x in col_one_list)
df_base_organsims = Genus_dataframe[Genus_dataframe['Organism'].str.contains(pat)]

#To select rows whose column value equals a scalar, some_value, use ==:
# put these organisms to a list



# pivot by reads
pivoted_df = df_base_organsims.pivot(index="Organism", columns="filename",values="Reads").fillna(0)
reverted_def = pivoted_df.stack().reset_index()
reverted_def.columns = ['Organism', 'Sample_name', 'Reads']


##reverted_def["overlapping_kmer"]=""
##reverted_def["Experiment"][reverted_def['Sample_name'].str.contains(pat= "deep")] = "Control"
##reverted_def["Experiment"][reverted_def['Sample_name'].str.contains(pat= "depletion")] = "Depletion"
##reverted_def["Experiment"][reverted_def['Sample_name'].str.contains(pat= "enrich")] = "Enrichment"
##reverted_def['Sample_id'] = reverted_def['Sample_name'].str.split('_').str[0]

## add total read counts to files
total_reads_df = pd.read_csv("read_counts/read_count_list_per_sample.csv", sep=',')
merged_df = pd.merge(reverted_def, total_reads_df, on='Sample_name', how='outer')
merged_df = merged_df[merged_df['Organism'].notna()]

## calculate percent of organisms in overall reads
merged_df['Perc'] = (merged_df['Reads'] / merged_df['total_reads']) *100




#df_reduced_organism = merged_df.loc[merged_df['Reads'] >= 10]

#merged_df.to_csv('testframe_plotting.tsv', sep = '\t', index=False)
merged_df.to_csv('testframe_plotting_species.tsv', sep = '\t', index=False)

##### Genus
folder="over30to100cutoff"
mkdir $folder
## genus do this in linux organism with more than 30 reads
cat testframe_plotting.tsv | cut -f5 |sort -u |head -15 >$folder/sample_id_list.txt
for i in $(cat tmp_files/sample_id_list.txt) ; do
    awk -v pattern="$i" '$5 == pattern' testframe_plotting.tsv > $folder/tmp_sample_"$i"_testframe.tsv
    # grep -w "$i" testframe_plotting.tsv 
    awk ' $3 > 30 ' $folder/tmp_sample_"$i"_testframe.tsv | awk ' $3 < 100 ' | cut -f1 |sort -u > $folder/tmp_organism_"$i"_to_select.txt
    grep -f $folder/tmp_organism_"$i"_to_select.txt $folder/tmp_sample_"$i"_testframe.tsv > $folder/tmp_testframe_plotting_"$i"_genus_up_pandas.tsv
done
cat $folder/tmp_*_genus_up_pandas.tsv > $folder/tmp_testframe_plotting_genus_up_pandas"$folder".tsv
sed -e '1i\Organism\tSample_name\tReads\tExperiment_x\tSample_id\treal_sample_name\ttotal_reads\teasy_sample_name\tExperiment_y\tPerc' $folder/tmp_testframe_plotting_genus_up_pandas"$folder".tsv > testframe_plotting_genus_cutoff_"$folder".tsv
#rm tmp_files/tmp*
