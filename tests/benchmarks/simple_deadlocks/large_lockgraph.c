// Test cycle detection algorithm on a large lockgraph.
// TODO: identical cycles with length > 2

//# Deadlock: true
//# Nb-deadlocks: 20

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock3 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock4 = PTHREAD_MUTEX_INITIALIZER;

void cycle2(pthread_mutex_t *lock1, pthread_mutex_t *lock2)
{
    pthread_mutex_lock(lock1);
    pthread_mutex_lock(lock2);
    pthread_mutex_unlock(lock2);
    pthread_mutex_unlock(lock1);

    pthread_mutex_lock(lock2);
    pthread_mutex_lock(lock1);
    pthread_mutex_unlock(lock1);
    pthread_mutex_unlock(lock2);
}

void *thread(void *v)
{
    cycle2(&lock1, &lock2);
    cycle2(&lock1, &lock3);
    cycle2(&lock1, &lock4);
    cycle2(&lock2, &lock3);
    cycle2(&lock2, &lock4);
    cycle2(&lock3, &lock4);
    
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
