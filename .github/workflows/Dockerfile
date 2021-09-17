FROM framac/frama-c:23.0

RUN git clone https://github.com/TDacik/Deadlock
RUN opam init
RUN eval $(opam env)
RUN opam install ounit2
RUN opam install containers

USER root
RUN cd Deadlock/src; ls; make; make setup; make install; frama-c -deadlock
