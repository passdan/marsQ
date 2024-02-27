import pandas as pd
import sys
import os
import argparse

parser = argparse.ArgumentParser(description='Extract stats from mapped genomes')

parser.add_argument('-i', '--input', nargs='+', help='genome coverage stats files')
parser.add_argument('-o', '--output', help='filename output_base', default='mapping_stats')

parser.parse_args(args=None if sys.argv[1:] else ['--help'])

args = parser.parse_args()


def process_files(files):
    data_reads = {}
    data_cov = {}
    data_depth = {}
    
    for file in files:
        try:
           df = pd.read_csv(file, sep='\t', header=0)

           filename = os.path.basename(file)
	
           sample = "_".join(filename.split('_')[0:3])
           genome = "_".join(filename.split('_')[3:5])

           # Process data
           total_reads = df["numreads"].sum()
           avg_cov = round(df["coverage"].mean(), 3)
           avg_depth = round(df["meandepth"].mean(), 3)
           #print(f"{genome} {total_reads} {avg_cov} {avg_depth}")

           # add to table
           data_reads.setdefault(genome, {})[sample] = total_reads
           data_cov.setdefault(genome, {})[sample] = avg_cov
           data_depth.setdefault(genome, {})[sample] = avg_depth           


        except Exception as e:
            print(f"Error processing {file}: {e}")

        

    df_reads = pd.DataFrame(data_reads).T
    df_cov = pd.DataFrame(data_cov).T
    df_depth = pd.DataFrame(data_depth).T

    return df_reads, df_cov, df_depth


df_reads, df_cov, df_depth = process_files(args.input)

print("Outputting")
print("==========")
print("Total Reads")
df_reads.to_csv(args.output + "_read_counts.csv")

print("Average Coverage:")
df_cov.to_csv(args.output + "_coverage.csv")

print("Average Depth")
df_depth.to_csv(args.output + "_depth.csv")
