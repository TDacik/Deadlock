#TODO: use frama-c image when available with ocaml >= 4.12
FROM ocaml/opam:ubuntu-20.04-ocaml-4.12
USER root

RUN opam depext -y frama-c
RUN opam install -y frama-c
RUN opam install -y ounit2
RUN opam install -y containers

# Install python3.9 for test and evaluation scripts
RUN apt install -y python3.9
RUN apt install -y python3-pip

# Install python dependencies
USER opam
RUN python3.9 -m pip install pyyaml

# Add opam binaries to path
ENV PATH=$PATH:/home/opam/.opam/4.12/bin

# Install Deadlock
USER root
RUN git clone https://github.com/TDacik/Deadlock.git
RUN make -C Deadlock setup
RUN make -C Deadlock
RUN make -C Deadlock install
