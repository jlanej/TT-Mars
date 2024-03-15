FROM continuumio/miniconda3

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y upgrade && \
	apt-get install -y build-essential wget \
		libncurses5-dev zlib1g-dev libbz2-dev liblzma-dev libcurl3-dev git r-base r-base-dev && \
	apt-get clean && apt-get purge && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


WORKDIR /usr/src
# needed for liftover.sh
RUN wget https://github.com/samtools/samtools/releases/download/1.19.2/samtools-1.19.2.tar.bz2 && \
	tar jxf samtools-1.19.2.tar.bz2 && \
	rm samtools-1.19.2.tar.bz2 && \
	cd samtools-1.19.2 && \
	./configure --prefix $(pwd) && \
	make

ENV PATH=${PATH}:/usr/src/samtools-1.19.2

# build mcutils 
# needed for liftover.sh
WORKDIR /app
RUN git clone https://github.com/mchaisso/mcutils.git
WORKDIR /app/mcutils/src/
RUN make && make install

ENV PATH=${PATH}:/app/mcutils/src/

SHELL ["/bin/bash", "--login", "-c"]

# install lra
# needed for liftover.sh
RUN conda config --add channels defaults
RUN conda config --add channels anaconda
RUN conda config --add channels bioconda
RUN conda config --add channels conda-forge
RUN conda install conda-forge::libdeflate
RUN conda install -c bioconda lra


# needed for ttmars.py
RUN pip install --upgrade pip
RUN pip install -U --no-cache-dir \
    setuptools \
    wheel

RUN pip install -U --no-cache-dir pysam
RUN pip install -U --no-cache-dir numpy
RUN pip install -U --no-cache-dir mappy
RUN pip install -U --no-cache-dir biopython
RUN pip install -U --no-cache-dir pybedtools

ADD https://worldtimeapi.org/api/ip time.tmp

WORKDIR /app
RUN git clone https://github.com/jlanej/TT-Mars.git
WORKDIR /app/TT-Mars

ENV PYTHONPATH "${PYTHONPATH}:/app/TT-Mars"
# RUN python ttmars.py

CMD ["/bin/bash"]
