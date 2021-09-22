FROM tdacik/deadlock-dependencies

# Install Deadlock
USER root
RUN git clone https://github.com/TDacik/Deadlock.git
RUN make -C Deadlock setup
RUN make -C Deadlock
RUN make -C Deadlock install
