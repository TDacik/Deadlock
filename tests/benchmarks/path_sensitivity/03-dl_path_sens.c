//# Deadlock: true
//# Lockgraph:
//#   - lock1 -> lock2
//#   - lock2 -> lock1
//#   - lock1 -> main_lock
//#   - lock2 -> main_lock

//# Path-sensitive-functions:
//#   - pause_fn

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

pthread_mutex_t main_lock = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

typedef enum {PAUSE_ALL, RESUME_ALL, PAUSE_ALL2, RESUME_ALL2} actions;

void pause_fn(actions action)
{
    if (action == PAUSE_ALL)
    {
        pthread_mutex_lock(&lock1);
        pthread_mutex_lock(&lock2);
        pthread_mutex_lock(&main_lock);
    }
    else if (action == PAUSE_ALL2)
    {
        pthread_mutex_lock(&lock2);
        pthread_mutex_lock(&lock1);
        pthread_mutex_lock(&main_lock);
    }
    else if (action == RESUME_ALL)
    {
        pthread_mutex_unlock(&lock1);
        pthread_mutex_unlock(&lock2);
        pthread_mutex_unlock(&main_lock);
    }
    else if (action == RESUME_ALL2)
    {
        pthread_mutex_unlock(&lock1);
        pthread_mutex_unlock(&lock2);
        pthread_mutex_unlock(&main_lock);
    }
    else 
    {
        exit(-1);
    }
}

void *thread1(void *v)
{
    pause_fn(PAUSE_ALL);
    pause_fn(RESUME_ALL);
    
    return NULL;
}

void *thread2(void *v)
{
    pause_fn(PAUSE_ALL2);
    pause_fn(RESUME_ALL2);
    
    return NULL;
}

int main(int argc, char **argv)
{	
    pthread_t threads[2];

    pthread_create(&threads[0], NULL, thread1, NULL);
    pthread_create(&threads[1], NULL, thread2, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);
	
    return 0;
}
