#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock3 = PTHREAD_MUTEX_INITIALIZER;

int main(int argc, char **argv)
{                                // Must-in | May-in | Must-out | May-out | May-acq | Must-acq
    pthread_mutex_lock(lock1);   //   { }       { }       {1}       {1}       {1}       {1}
    pthread_mutex_unlock(lock2); //   {1}       {1}       { }       { }       { }       { }

    
}
