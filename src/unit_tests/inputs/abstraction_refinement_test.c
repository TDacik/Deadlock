#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

typedef enum {LOCK1, LOCK2, RESUME} actions;

void lock_wrapper(pthread_mutex_t *lock)
{
    pthread_mutex_lock(lock);
}

void unlock_wrapper(pthread_mutex_t *lock)
{
    pthread_mutex_unlock(lock);
}

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

void no_pure_input(actions action)
{
    if (action == LOCK1)
        action++;

    pause_fn(action);
}

void *thread1(void *v)
{
    stmt1: pause_fn(LOCK1);
    stmt2: no_pure_input(LOCK2);
    
    return NULL;
}

void *thread2(void *v)
{
    return NULL;
}

int main()
{	
    pthread_t threads[2];

    pthread_create(&threads[0], NULL, thread1, NULL);
    pthread_create(&threads[1], NULL, thread2, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);

    return 0;
}
