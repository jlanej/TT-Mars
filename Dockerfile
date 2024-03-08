FROM continuumio/miniconda3

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get install -y --no-install-recommends git

# Clone TT-Mars from github and cd TT-Mars. Python >= 3.8 is preferred.
WORKDIR /app
RUN git clone https://github.com/jlanej/TT-Mars.git
WORKDIR /app/TT-Mars

#Create environment and activate: conda create -n ttmars and conda activate ttmars. 

SHELL ["/bin/bash", "--login", "-c"]

RUN conda create -n ttmars
RUN conda init bash
RUN conda activate ttmars

# skipping Run dowaload_files.sh to download required files to ./ttmars_files.
# skipping  Run download_asm.sh to download assembly files of 10 samples from HGSVC.
# Install packages: conda install -c bioconda pysam, conda install -c anaconda numpy, conda install -c bioconda mappy, conda install -c conda-forge biopython, conda install -c bioconda pybedtools.

# need to add channels 
RUN conda config --add channels r
RUN conda config --add channels bioconda
RUN conda config --add channels defaults
RUN conda config --add channels conda-forge
RUN conda config --add channels bioconda

# RUN conda install -c bioconda pysam 
RUN pip install -U --no-cache-dir pysam==0.16.0.1 
RUN pip install -U --no-cache-dir numpy==1.18.5 

RUN conda install -c anaconda numpy 
RUN conda install -c bioconda mappy 
RUN conda install -c conda-forge biopython 
RUN conda install -c bioconda pybedtools.
