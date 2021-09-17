//# Deadlock: false
//# Lockgraph:
//#   - lock1 -> lock2

//# Context-sensitive-functions:
//#   - wrapper

//# With-eva-only: true

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

void wrapper(pthread_mutex_t *lock)
{ 
    pthread_mutex_lock(lock);
}

void *thread1(void *param)
{
    pthread_mutex_t *lock = (pthread_mutex_t *) param;

    wrapper(lock);
    wrapper(&lock2);

    return NULL;
}

void *thread2(void *param)
{
    pthread_mutex_t *lock = (pthread_mutex_t *) param;
    
    wrapper(&lock1);
    wrapper(lock);

    return NULL;
}

int main()
{	
    pthread_t threads[2];
    
    pthread_create(&threads[0], NULL, thread1, &lock1);
    pthread_create(&threads[1], NULL, thread2, &lock2);
    
    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);

    return 0;
}
