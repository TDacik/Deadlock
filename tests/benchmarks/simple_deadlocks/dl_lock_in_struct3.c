// Lock in dynamically allocated structures, both locks are allocated
// on the same line.

//# Deadlock: true
//# Lockgraph:
//#   - __malloc_malloc_s_l34   -> __malloc_malloc_s_l34_0
//#   - __malloc_malloc_s_134_0 -> __malloc_malloc_s_134

// TODO:
//# With-eva-only: true

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

struct s_with_lock
{
    int data;
    pthread_mutex_t *lock;
};

struct s_with_lock *s1;
struct s_with_lock *s2;

void f(struct s_with_lock *s1, struct s_with_lock *s2) {
    pthread_mutex_lock(s1->lock);
    pthread_mutex_lock(s2->lock);
    s1->data++;
    s2->data++;
    pthread_mutex_unlock(s2->lock);
    pthread_mutex_unlock(s1->lock);
}

void *thread1(void *v)
{
    f(s1, s2);
    return NULL;
}

void *thread2(void *v)
{
    f(s2, s1);
    return NULL;
}

struct s_with_lock *malloc_s() 
{
    struct s_with_lock *s = malloc(sizeof(struct s_with_lock));
    if (s == NULL)
        exit(1);

    s->lock = malloc(sizeof(pthread_mutex_t));
    if (s->lock == NULL)
        exit(1);
    
    pthread_mutex_init(s->lock, NULL);
    return s;
}

void destroy_s(struct s_with_lock *s)
{
    pthread_mutex_destroy(s->lock);
    free(s->lock);
    free(s);
}

int main(int argc, char **argv)
{	
    pthread_t threads[2];

    s1 = malloc_s();
    s2 = malloc_s();

    pthread_create(&threads[0], NULL, thread1, NULL);
    pthread_create(&threads[1], NULL, thread2, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);

    destroy_s(s1);
    destroy_s(s2);
	
    return 0;
}
