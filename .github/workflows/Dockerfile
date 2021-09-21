FROM ocaml/opam:ubuntu-20.04-ocaml-4.12
USER root

RUN opam depext -y frama-c
RUN opam install frama-c

RUN git clone https://github.com/TDacik/Deadlock
RUN opam init
RUN eval $(opam env)
RUN opam install -y ounit2
RUN opam install -y containers

RUN cd Deadlock/src; ls; make; make setup; make install; frama-c -deadlock
