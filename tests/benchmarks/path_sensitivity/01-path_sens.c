//# Deadlock: false
//# Lockgraph:
//#   - lock1 -> lock2

//# Path-sensitive-functions:
//#   - pause_fn

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

typedef enum {LOCK1, LOCK2, RESUME} actions;

void pause_fn(actions action)
{
    if (action == LOCK1)
    {    
        pthread_mutex_lock(&lock1);
    }
    else if (action == LOCK2)
    {
        pthread_mutex_lock(&lock2);
    }
    else if (action == RESUME)
    {
        pthread_mutex_unlock(&lock1);
        pthread_mutex_unlock(&lock2);
    }
    else
    {
        exit(-1);
    }
}

void *thread(void *v)
{
    pause_fn(LOCK1);
    pause_fn(LOCK2);
    pause_fn(RESUME);
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
