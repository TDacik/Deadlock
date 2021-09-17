//# Deadlock: false
//# Lockgraph:
//#   - s1.lock -> s2.lock

//# Context-sensitive-functions:
//#   - lock_wrapper
//#   - unlock_wrapper

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

struct s_with_lock
{
    int data;
    pthread_mutex_t lock;
};

struct s_with_lock s1;
struct s_with_lock s2;

void lock_wrapper(struct s_with_lock *s)
{
    pthread_mutex_lock(&s->lock);
}

void unlock_wrapper(struct s_with_lock *s)
{
    pthread_mutex_unlock(&s->lock);
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

    pthread_mutex_init(&s1.lock, NULL);
    pthread_mutex_init(&s2.lock, NULL);

    pthread_create(&threads[0], NULL, thread1, NULL);
    pthread_create(&threads[1], NULL, thread2, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);

    pthread_mutex_destroy(&s1.lock);
    pthread_mutex_destroy(&s2.lock);

    return 0;
}
