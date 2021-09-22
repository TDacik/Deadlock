# Deadlock

<img align="right" width="200" src="http://excel.fit.vutbr.cz/submissions/2020/012/12_nahled.png">

*Deadlock* is a static analyser for the detection of potential deadlocks in C programs implemented as a plugin of the [Frama-C](http://frama-c.com/) platform.

The core algorithm is based on an existing tool [RacerX](https://web.stanford.edu/~engler/racerx-sosp03.pdf). The so-called lockset analysis traverses control flow graph and computes the set of locks held at any program point. When lock b is acquired with current lockset already containing lock a, dependency a -> b is added to lockgraph. Each cycle in this graph is then reported as a potential deadlock.

The plugin uses [EVA](http://frama-c.com/value.html) (Value analysis plugin of Frama-C) to compute may-point-to information for parameters of locking operations. Because EVA can't natively analyse concurrent programs, we first identify all threads in a program and then run it for each thread separately with contexts of program points, where the thread was created. The result is then under-approximation, which doesn't take into account thread's interleavings. 

## Example
This example demonstrates output for the program with simple deadlock. The more complex example can be found [here](https://github.com/TDacik/Deadlock/wiki/example).
 
```C
void * thread1(void *v)
{
    pthread_mutex_lock(&lock1);
    pthread_mutex_lock(&lock2);
    ...
    pthread_mutex_unlock(&lock2);
    pthread_mutex_unlock(&lock1);
}

void * thread2(void *v)
{
    pthread_mutex_lock(&lock2);
    pthread_mutex_lock(&lock1);
    ...
    pthread_mutex_unlock(&lock1);
    pthread_mutex_unlock(&lock2);
}
```
#### Output:
```
[kernel] Parsing simple_deadlock.c (with preprocessing)
[Deadlock] Deadlock analysis started
[Deadlock] === Assumed threads: ===
[Deadlock] main
[Deadlock] thread1
[Deadlock] thread2
[Deadlock] === Lockgraph: ===
[Deadlock] lock1 -> lock2
[Deadlock] lock2 -> lock1
[Deadlock] ==== Results: ====
[Deadlock] Deadlock between threads thread1 and thread2:
  
  Trace of dependency (lock2 -> lock1):
  In thread thread2:
      Lock of lock2 (simple_deadlock.c:20)
      Lock of lock1 (simple_deadlock.c:21)
  
  Trace of dependency (lock1 -> lock2):
  In thread thread1:
      Lock of lock1 (simple_deadlock.c:10)
      Lock of lock2 (simple_deadlock.c:11)
```

## Installation
The current version is compatible with [Frama-C Vanadium](https://frama-c.com/fc-versions/vanadium.html), it's detailed installation guide can be found in [user manual](https://git.frama-c.com/pub/frama-c/blob/master/INSTALL.md).
After installing Frama-C, clone this repository and run 

```
cd Deadlock
make setup
make
make install
```

You may also run Deadlock in docker either by using `docker run -it tdacik/deadlock` or by running `make docker` to build an image of the most recent version.  

## Usage
The plugin can be run by following command: 
``` 
frama-c -deadlock *source_files.c*
``` 

## Related papers
Dacík T. [Static Deadlock Detection in Frama-C](http://excel.fit.vutbr.cz/submissions/2020/012/12.pdf) In *Proceedings of Excel@FIT'20*. Brno University of Technology, Faculty of Information Technology. 2020

Dacík T. [Static Analysis in the Frama-C Environment Focused on Deadlock Detection](https://www.fit.vut.cz/study/thesis/22928/.en) Bachelor's Thesis. Brno University of Technology, Faculty of Information Technology. 2020-07-10. Supervised by Vojnar Tomáš.

## Contact
If you have any questions, do not hesitate to contact the tool/method authors:
* **Tomáš Dacík** <[xdacik00@stud.fit.vutbr.cz](mailto:xdacik00@stud.fit.vutbr.cz)>
* [**Tomáš Vojnar**](https://www.fit.vut.cz/person/vojnar/) <[vojnar@fit.vutbr.cz](mailto:vojnar@fit.vutbr.cz)>

## License
The plugin is available under MIT license.
