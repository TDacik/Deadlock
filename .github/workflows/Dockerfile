FROM framac/frama-c:23.0

USER root

RUN git clone https://github.com/TDacik/Deadlock
RUN opam install ouni2
RUN opam install containers
RUN cd Deadlock/src; ls; make; make setup; make install; frama-c -deadlock
