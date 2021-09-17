//# Deadlock: false
//# Lockgraph:
//#   - lock1 -> lock2
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
pthread_mutex_t lock3 = PTHREAD_MUTEX_INITIALIZER;

typedef enum {PAUSE_ALL, RESUME_ALL, PAUSE_MAIN, RESUME_MAIN} actions;

void f()
{
    pthread_mutex_lock(&lock2);
    pthread_mutex_lock(&lock3);
    pthread_mutex_unlock(&lock3);
    pthread_mutex_unlock(&lock2);
}

void pause_fn(actions action)
{
    if (action == PAUSE_ALL)
    {
        pthread_mutex_lock(&lock1);
        pthread_mutex_lock(&lock2);
        pthread_mutex_lock(&main_lock);
    }
    else if (action == PAUSE_MAIN)
    {
        pthread_mutex_lock(&main_lock);
    }
    else if (action == RESUME_ALL)
    {
        pthread_mutex_unlock(&lock1);
        pthread_mutex_unlock(&lock2);
        pthread_mutex_unlock(&main_lock);
    }
    else if (action == RESUME_MAIN)
    {
        pthread_mutex_unlock(&main_lock);
    }
    else 
    {
        exit(-1);
    }
}

void *thread(void *v)
{
    pause_fn(PAUSE_ALL);
    pause_fn(RESUME_ALL);

    pause_fn(PAUSE_MAIN);
    pause_fn(RESUME_MAIN);

    return NULL;
}

int main(int argc, char **argv)
{	
    pthread_t threads[3];

    for (int i = 0; i < 3; i++)
    {
        pthread_create(&threads[i], NULL, thread, NULL);
    }

    for (int i = 0; i < 3; i++)
    {
        pthread_join(threads[i], NULL);
    }
	
    return 0;
}
