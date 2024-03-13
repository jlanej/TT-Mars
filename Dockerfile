FROM continuumio/miniconda3


ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y upgrade && \
	apt-get install -y build-essential wget \
		libncurses5-dev zlib1g-dev libbz2-dev liblzma-dev libcurl3-dev git r-base r-base-dev && \
	apt-get clean && apt-get purge && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 
WORKDIR /app
RUN git clone https://github.com/mchaisso/mcutils.git
WORKDIR /app/mcutils/src/
RUN make && make install

WORKDIR /app
# Clone TT-Mars from github and cd TT-Mars. Python >= 3.8 is preferred.
RUN git clone https://github.com/jlanej/TT-Mars.git
WORKDIR /app/TT-Mars

#Create environment and activate: conda create -n ttmars and conda activate ttmars. 
RUN pip install --upgrade pip

RUN pip install -U --no-cache-dir \
    setuptools \
    wheel
    
SHELL ["/bin/bash", "--login", "-c"]

RUN conda config --add channels defaults
RUN conda config --add channels anaconda
RUN conda config --add channels bioconda
RUN conda config --add channels conda-forge
# RUN conda config --set channel_priority strict
RUN conda install conda-forge::libdeflate
RUN conda install -c bioconda lra
RUN conda install -c bioconda pysam

RUN pip install -U --no-cache-dir pysam
RUN pip install -U --no-cache-dir numpy
RUN pip install -U --no-cache-dir mappy
RUN pip install -U --no-cache-dir biopython
RUN pip install -U --no-cache-dir pybedtools

ENV PYTHONPATH "${PYTHONPATH}:/app/TT-Mars"
# RUN python ttmars.py

CMD ["/bin/bash"]
