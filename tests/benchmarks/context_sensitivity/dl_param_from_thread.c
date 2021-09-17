//# Deadlock: true
//# Lockgraph:
//#   - lock1 -> lock2
//#   - lock2 -> lock1

//# Context-sensitive-functions: []

//# With-eva-only: true

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

// This function is not classified as contex-sensitive since its (precise) calling context is
// included in initial states of threds thread1 and thread2
void f(pthread_mutex_t *lock1, pthread_mutex_t *lock2)
{ 
    pthread_mutex_lock(lock1);
    pthread_mutex_lock(lock2);

    pthread_mutex_unlock(lock2);
    pthread_mutex_unlock(lock1);
}

void *thread1(void *param)
{
    pthread_mutex_t *lock = (pthread_mutex_t *) param;
    f(lock, &lock2);

    return NULL;
}

void *thread2(void *param)
{
    pthread_mutex_t *lock = (pthread_mutex_t *) param;
    f(lock, &lock1);

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
