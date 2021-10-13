//# Deadlock: false
//# Lockgraph:
//#   - lock1 -> lock2

//# Context-sensitive-functions:
//#   - lock_wrapper
//#   - unlock_wrapper

//# Nb-analysed-functions-EVA: 15
//  + 1 main
//  + 1 thread1
//    + 3 lock_wrapper
//    + 3 unlock_wrapper
//  1 x thread2
//    + 3 lock_wrapper
//    + 3 unlock_wrapper
//  -----
//     15

//# Nb-analysed-functions-CIL: 13
//  + 1 main
//  + 1 thread1
//    + 3 lock_wrapper
//    + 3 unlock_wrapper
//  + 1 thread2
//    + 2 lock_wrapper   (imprecise analysis + refinement, this can be optimize), then can cache
//    + 2 unlock_wrapper                   -||-

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

void lock_wrapper(pthread_mutex_t *lock)
{
    pthread_mutex_lock(lock);
}

void unlock_wrapper(pthread_mutex_t *lock)
{
    pthread_mutex_unlock(lock);
}

void *thread1(void *v)
{
    lock_wrapper(&lock1);
    lock_wrapper(&lock2);
    unlock_wrapper(&lock2);
    unlock_wrapper(&lock1);

    return NULL;
}

void *thread2(void *v)
{
    lock_wrapper(&lock1);
    lock_wrapper(&lock2);
    unlock_wrapper(&lock2);
    unlock_wrapper(&lock1);

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
