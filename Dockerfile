FROM continuumio/miniconda3

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get install -y --no-install-recommends git

# Clone TT-Mars from github and cd TT-Mars. Python >= 3.8 is preferred.
WORKDIR /app
RUN git clone https://github.com/jlanej/TT-Mars.git
WORKDIR /app/TT-Mars

#Create environment and activate: conda create -n ttmars and conda activate ttmars. 

RUN conda create -n ttmars
RUN conda init ttmars
RUN conda activate ttmars
