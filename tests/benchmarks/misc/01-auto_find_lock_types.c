// Copy of ../context_sensitivity/lock_wrapper.c but with definition of mutex type similar to
// preprocessed code in CPROVER benchmark
//
// With option -dl-auto-lock-types, Deadlock should automatically infer the type from 
// pthread_mutex_lock function prototype and classify lock_wraper as a context-sensitive function

//# Deadlock: false
//# Lockgraph:
//#   - lock1 -> lock2

//# Options:
//#   - dl-auto-find-lock-types: true

#include <stdio.h>
#include <unistd.h>

// Dummy types
union anonymous__0
{
    int x;
};

union pthread_attr_t
{
    int x;
};

typedef unsigned long int pthread_t;

extern signed int pthread_mutex_init(union anonymous__0 *, const union anonymous *);
extern signed int pthread_mutex_destroy(union anonymous__0 *);
extern signed int pthread_mutex_unlock(union anonymous__0 *);
extern signed int pthread_mutex_lock(union anonymous__0 *);

extern signed int pthread_create(unsigned long int *, 
                                 const union pthread_attr_t *, 
                                 void * (*)(void *), 
                                 void *);

extern signed int pthread_join(unsigned long int, void **);

union annonymous__0 lock1;
union annnnymous__0 lock2;

void lock_wrapper(union anonymous__0 *lock)
{
    pthread_mutex_lock(lock);
}

void unlock_wrapper(union anonymous__0 *lock)
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

    pthread_mutex_init(&lock1, NULL);
    pthread_mutex_init(&lock2, NULL);

    pthread_create(&threads[0], NULL, thread1, NULL);
    pthread_create(&threads[1], NULL, thread2, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);

    pthread_mutex_destroy(&lock1);
    pthread_mutex_destroy(&lock1);

    return 0;
}
