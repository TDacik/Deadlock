// Lock in dynamically allocated structures, both locks are allocated
// on the same line.

//# Deadlock: false
//# Lockgraph: []

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

struct s_with_lock
{
    int data;
    pthread_mutex_t *lock;
};

struct s_with_lock s1;
struct s_with_lock s2;

void f(struct s_with_lock *s) {
    pthread_mutex_lock(s->lock);
    s->data++;
    pthread_mutex_unlock(s->lock);
}

void *thread(void *v)
{
    struct s_with_lock *s = (struct s_with_lock *) v;
    f(s);
    f(s);

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

    s->data = 2;
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

    struct s_with_lock *s1 = malloc_s();
    struct s_with_lock *s2 = malloc_s();

    pthread_create(&threads[0], NULL, thread, (void *) s1);
    pthread_create(&threads[1], NULL, thread, (void *) s2);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);
	
    return 0;
}
