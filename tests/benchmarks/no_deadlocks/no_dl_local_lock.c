#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t global_lock = PTHREAD_MUTEX_INITIALIZER;

void *thread1(void *v)
{
    pthread_mutex_t local_lock;
    pthread_mutex_init(&local_lock, NULL);

    pthread_mutex_lock(&local_lock);
    pthread_mutex_lock(&global_lock);
    pthread_mutex_unlock(&global_lock);
    pthread_mutex_unlock(&local_lock);

    pthread_mutex_destroy(&local_lock);
    return NULL;
}

void *thread2(void *v)
{
    pthread_mutex_t local_lock;
    pthread_mutex_init(&local_lock, NULL);

    pthread_mutex_lock(&global_lock);
    pthread_mutex_lock(&local_lock);
    pthread_mutex_unlock(&local_lock);
    pthread_mutex_unlock(&global_lock);

    pthread_mutex_destroy(&local_lock);
    return NULL;
}

int main(int argc, char **argv)
{	
    pthread_t threads[2];

    pthread_create(&threads[0], NULL, thread1, NULL);
    pthread_create(&threads[1], NULL, thread2, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);
	
    return 0;
}
