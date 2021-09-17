// Usage of functions different from pthread_mutex_lock()

//# Deadlock: true
//# Lockgraph:
//#   - lock1 -> lock2
//#   - lock2 -> spinlock
//#   - spinlock -> lock1


#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;
pthread_spinlock_t spinlock;

void *thread1(void *v)
{
    pthread_mutex_trylock(&lock1); // always acquired
    sleep(1);
    pthread_mutex_lock(&lock2);
    pthread_mutex_unlock(&lock2);
    pthread_mutex_unlock(&lock1);

    return NULL;
}

void *thread2(void *v)
{ 
    struct timespec time = {1, 1};
    pthread_mutex_timedlock(&lock2, &time); // always acquired
    sleep(1);
    pthread_spin_lock(&spinlock);
    pthread_spin_unlock(&spinlock);
    pthread_mutex_unlock(&lock2);

    return NULL;
}

void *thread3(void *v)
{
    pthread_spin_trylock(&spinlock); // not always, but can close the cycle
    sleep(1);
    pthread_mutex_lock(&lock1);
    pthread_mutex_unlock(&lock1);
    pthread_spin_unlock(&spinlock);

    return NULL;
}

int main(int argc, char **argv)
{	
    pthread_t threads[3];

    pthread_spin_init(&spinlock, 0);

    pthread_create(&threads[0], NULL, thread1, NULL);
    pthread_create(&threads[1], NULL, thread2, NULL);
    pthread_create(&threads[2], NULL, thread3, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);
    pthread_join(threads[2], NULL);

    pthread_spin_destroy(&spinlock);
	
    return 0;
}
