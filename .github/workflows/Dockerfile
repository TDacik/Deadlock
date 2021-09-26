FROM tdacik/deadlock-dependencies

# Add opam binaries to path
ENV PATH=$PATH:/home/opam/.opam/4.12/bin

# Install Deadlock
USER root
RUN git clone https://github.com/TDacik/Deadlock.git
RUN make -C Deadlock setup
RUN make -C Deadlock
RUN make -C Deadlock install

RUN make -C Deadlock unit-tests
RUN make -C Deadlock test
