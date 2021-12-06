//# Deadlock: false
//# Lockgraph:
//#   - s1.lock -> s2.lock

//# Context-sensitive-functions:
//#   - lock_wrapper
//#   - unlock_wrapper

//# With-eva-only: true

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

struct s_inner
{
    pthread_mutex_t *lock;
};

struct s_with_nested_lock
{
    int data;
    struct s_inner *inner;
};

struct s_with_nested_lock s1;
struct s_with_nested_lock s2;

void lock_wrapper(struct s_with_nested_lock *s)
{
    pthread_mutex_lock(s->inner->lock);
}

void unlock_wrapper(struct s_with_nested_lock *s)
{
    pthread_mutex_unlock(s->inner->lock);
}

void *thread1(void *v)
{
    lock_wrapper(&s1);
    lock_wrapper(&s2);
    unlock_wrapper(&s2);
    unlock_wrapper(&s1);

    return NULL;
}

void *thread2(void *v)
{
    lock_wrapper(&s1);
    lock_wrapper(&s2);
    unlock_wrapper(&s2);
    unlock_wrapper(&s1);

    return NULL;
}

int main()
{	
    pthread_t threads[2];

    s1.inner = malloc(sizeof(struct s_inner));
    s2.inner = malloc(sizeof(struct s_inner));

    if (s1.inner == NULL || s2.inner == NULL)
        return 1;

    s1.inner->lock = malloc(sizeof(pthread_mutex_t));
    s2.inner->lock = malloc(sizeof(pthread_mutex_t));
   
    if (s1.inner->lock == NULL || s2.inner->lock == NULL)
        return 1;

    pthread_mutex_init(s1.inner->lock, NULL);
    pthread_mutex_init(s2.inner->lock, NULL);

    pthread_create(&threads[0], NULL, thread1, NULL);
    pthread_create(&threads[1], NULL, thread2, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);

    pthread_mutex_destroy(s1.inner->lock);
    pthread_mutex_destroy(s2.inner->lock);

    free(s1.inner);
    free(s2.inner);

    return 0;
}
