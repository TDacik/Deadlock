//# Deadlock: false
//# Lockgraph: []

//# Path-sensitive-functions:
//#   - pause_fn

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t master_lock = PTHREAD_MUTEX_INITIALIZER;

enum actions {PAUSE, RESUME, PAUSE_ALL, RESUME_ALL};

void pause_threads(enum actions action) {
    switch (action)
    {
        case PAUSE_ALL:
            pthread_mutex_lock(&lock1);
            pthread_mutex_lock(&lock2);
        case PAUSE:
            pthread_mutex_lock(&master_lock);
            break;

        case RESUME_ALL:
            pthread_mutex_unlock(&lock2);
            pthread_mutex_unlock(&lock1);
        case RESUME:
            pthread_mutex_unlock(&master_lock);
            break;
    }

}

void *thread(void *v)
{
    pause_threads(PAUSE);
    pause_threads(RESUME);
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
