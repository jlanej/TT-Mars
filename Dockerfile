FROM continuumio/miniconda3


ARG DEBIAN_FRONTEND=noninteractive

# RUN apt-get update
# RUN apt-get install -y --no-install-recommends build-essential
# RUN apt-get install -y --no-install-recommends libbz2-dev
# RUN apt-get install -y --no-install-recommends zlib1g-dev
# # RUN apt-get install -y --no-install-recommends libgl1-mesa-glx 
# # RUN apt-get install -y --no-install-recommends libglib2.0-0 
# # RUN apt-get install -y --no-install-recommends libsm6 
# # RUN apt-get install -y --no-install-recommends libxrender1 
# # RUN apt-get install -y --no-install-recommends libxext6 
# # RUN apt-get install -y --no-install-recommends tabix 
# RUN apt-get install -y --no-install-recommends git
# RUN apt-get install -y --no-install-recommends wget

RUN apt-get update && apt-get -y upgrade && \
	apt-get install -y build-essential wget \
		libncurses5-dev zlib1g-dev libbz2-dev liblzma-dev libcurl3-dev git r-base r-base-dev && \
	apt-get clean && apt-get purge && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# cd /usr/bin
# wget https://github.com/samtools/htslib/releases/download/1.9/htslib-1.9.tar.bz2
# tar -vxjf htslib-1.9.tar.bz2
# cd htslib-1.9
# make

RUN wget https://github.com/samtools/htslib/releases/download/1.16.1/htslib-1.16.1.tar.bz2 && \
	tar jxf htslib-1.16.1.tar.bz2 && \
	rm htslib-1.16.1.tar.bz2 && \
	cd htslib-1.16.1 && \
	./configure --prefix $(pwd) && \
	make
RUN wget https://github.com/samtools/samtools/releases/download/1.16.1/samtools-1.16.1.tar.bz2 && \
	tar jxf samtools-1.16.1.tar.bz2 && \
	rm samtools-1.16.1.tar.bz2 && \
	cd samtools-1.16.1 && \
	./configure --prefix $(pwd) && \
	make
RUN conda config --add channels bioconda
RUN conda install -c bioconda htslib 

WORKDIR /app
RUN git clone https://github.com/mchaisso/mcutils.git
WORKDIR /app/mcutils/src/
RUN make && make install

WORKDIR /app
RUN git clone --recursive https://github.com/ChaissonLab/lra.git -b master
WORKDIR /app/lra
RUN make

WORKDIR /app
# Clone TT-Mars from github and cd TT-Mars. Python >= 3.8 is preferred.
RUN git clone https://github.com/jlanej/TT-Mars.git
WORKDIR /app/TT-Mars

#Create environment and activate: conda create -n ttmars and conda activate ttmars. 
RUN pip install --upgrade pip

RUN pip install -U --no-cache-dir \
    setuptools==58.0.0 \
    wheel
    
SHELL ["/bin/bash", "--login", "-c"]
RUN pip install -U --no-cache-dir pysam
RUN pip install -U --no-cache-dir numpy
RUN pip install -U --no-cache-dir mappy
RUN pip install -U --no-cache-dir biopython
RUN pip install -U --no-cache-dir pybedtools

ENV PYTHONPATH "${PYTHONPATH}:/app/TT-Mars"
# RUN python ttmars.py

CMD ["/bin/bash"]


# RUN conda create -n ttmars
# RUN conda init bash
# RUN conda activate ttmars

# # skipping Run dowaload_files.sh to download required files to ./ttmars_files.
# # skipping  Run download_asm.sh to download assembly files of 10 samples from HGSVC.
# # Install packages: conda install -c bioconda pysam, conda install -c anaconda numpy, conda install -c bioconda mappy, conda install -c conda-forge biopython, conda install -c bioconda pybedtools.

# # need to add channels 
# RUN conda config --add channels r
# RUN conda config --add channels bioconda
# RUN conda config --add channels defaults
# RUN conda config --add channels conda-forge

# RUN conda install -c bioconda pysam 
# #RUN pip install -U --no-cache-dir pysam==0.16.0.1 
# #RUN pip install -U --no-cache-dir numpy==1.18.5 

# RUN conda install -c anaconda numpy 
# RUN conda install -c bioconda mappy 
# RUN conda install -c conda-forge biopython 
# RUN conda install -c bioconda pybedtools.
