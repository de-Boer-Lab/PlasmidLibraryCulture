# Introduction

This repository contains all code required to reproduce the results of Culture wars: Empirically determining the best approach for plasmid library amplification.

## Processing pipeline

The `SRA_pipeline` directory contains a Snakemake pipeline that, for each sample, takes in a pair of fastq files and outputs a tab-separated file of each unique sequence observed and its count. The pipeline is set up to run on a cluster that uses Slurm. Note that the pipeline used to process the original fastq files can be found in `original_pipeline`. Files downloaded from the SRA have different filenames and a different delimiter for read number in the headers so the pipeline in `SRA_pipeline` needs to be used for these data. The output of both pipelines is identical.

### 1. Download fastq files from the SRA

With [sra-tools](https://github.com/ncbi/sra-tools) installed, from the `SRA_download` directory run the download_sra.sh script:

```
./download_sra.sh sra_accessions.txt
```
If any downloads or fastq conversions fail, simply run the script again to finish processing the failed samples. There should be 88 fastq files in the `SRA_download/sra_data` directory at the end.  

Once the downloads are finished, gzip the files and transfer to a suitable location for running the pipeline.

### 2. Create a Snakemake conda environment

Create a conda environment from the `envs/snakemake_env.yaml` file (used conda 24.4.0):
```
conda env create --file snakemake_env.yaml
conda activate snakemake
```

### 3. Install NGmerge

All software used in the pipeline is automatically installed by Snakemake into a pipeline-specific conda environment except for NGmerge, as the version of NGmerge available on conda is not up to date and is missing a required option (-t, for setting the header delimiter). Clone [NGmerge](https://github.com/jsh58/NGmerge) version 0.3 into the `pipeline` directory and compile it according to the directions on GitHub. You should have an `NGmerge` directory containing the `NGmerge` binary inside the `pipeline` directory at the end.

### 4. Configure the pipeline

In `pipeline/pipeline_config.yaml`, set the `data_dir` variable to the path of the raw fastq files. Modify `pipeline/profile/config.yaml` to work with the cluster that you're using. For a Slurm cluster, only `--account` needs to be changed. See the Snakemake documentation for other job schedulers. You should be able to run the pipeline locally as well, but it will take a long time to run.

### 5. Run the pipeline

In the `pipeline` directory, and with the `snakemake` environment activated, run
```
snakemake --profile profile
```

You may want to use the --dry-run option first to make sure everything looks correct.  

Snakemake will create a conda environment with the necessary software from the `environment.yaml` file, then submit each job to the cluster. The final count files will be placed in `pipeline/output/counts`.

## Analysis

All code used for analysis can be found in Jupyter notebooks in the `analysis` directory. Follow these steps to reproduce the analysis.

### 1. Move count files to the data directory

Transfer the count files generated from the processing steps above to `data/counts`, or extract the pre-processed count files in `data/counts.tar.gz`.

### 2. Create a virtual environment

Create a new Python virtual environment (used Python 3.10.4):
```
python -m venv /path/to/new/venv
```

Activate the environment, then install the requirements from `envs/requirements.txt`:

```
python -m pip install -r requirements.txt
```

Add the environment to Jupyter:
```
python -m ipykernel install --user --name <venv_name>
```

Now use the environment kernel to run the analysis notebooks.