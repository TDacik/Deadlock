// This program demonstrates situation when path-sensitive refinement should NOT be used
// because parameter of function *pause_fn* is at line 48 is not a constant

// Expected false positive:
//# Deadlock: true
//# Lockgraph:
//#   - lock1 -> lock2
//#   - lock2 -> lock1

//# Path-sensitive-functions:
//#   - pause_fn

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

typedef enum {PAUSE, RESUME} actions;

int pause_fn(actions action)
{
    if (action == PAUSE)
    {    
        pthread_mutex_lock(&lock1);
        pthread_mutex_lock(&lock2);
    }
    else if (action == RESUME)
    {
        pthread_mutex_unlock(&lock1);
        pthread_mutex_unlock(&lock2);
    }
    else
    {
        return -1;
    }

    return 0;
}

void *thread(void *v)
{
    // Lock
    pause_fn(0);

    // Double-lock or unlock
    pause_fn(Frama_C_nondet(0, 1));
    return NULL;
}

int main(int argc, char **argv)
{	
    pthread_t threads[2];

    pthread_create(&threads[0], NULL, thread, NULL);
    pthread_create(&threads[1], NULL, thread, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);
	
    return 0;
}
