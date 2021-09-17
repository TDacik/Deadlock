//# Deadlock: false
//# Lockgraph: [] 

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

typedef struct {
    int data;
    pthread_mutex_t *lock;
} data;

void f(data *d)
{
    pthread_mutex_lock(d->lock);
    d->data++;
    pthread_mutex_unlock(d->lock);

    pthread_mutex_lock(d->lock);
    d->data++;
    pthread_mutex_unlock(d->lock);
}

void *thread1(void *v)
{
    data *d = (data *) v;
    f(d);

    return NULL;
}

void *thread2(void *v)
{
    data *d = (data *) v;
    f(d);
    
    return NULL;
}

data *malloc_data()
{
    data *d = malloc(sizeof(data));
    if (d == NULL)
        exit(1);

    d->lock = malloc(sizeof(pthread_mutex_t));
    if (d->lock == NULL)
        exit(1);

    d->data = 0;
    pthread_mutex_init(d->lock, NULL);
    return d;
}

void free_data(data *d)
{ 
    pthread_mutex_destroy(d->lock);
    free(d->lock);
    free(d);
}

int main(int argc, char **argv)
{	
    pthread_t threads[2];

    data *data1 = malloc_data();
    data *data2 = malloc_data();

    pthread_create(&threads[0], NULL, thread1, data1);
    pthread_create(&threads[1], NULL, thread2, data2);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);

    free_data(data1);
    free_data(data2);
	
    return 0;
}
