FROM framac/frama-c:23.0
RUN git clone https://github.com/TDacik/Deadlock
RUN cd Deadlock/src; ls; make; make setup; make install; frama-c -deadlock
