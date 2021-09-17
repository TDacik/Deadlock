#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

void *thread(void *v)
{
	pthread_mutex_lock(&lock1);
	pthread_mutex_lock(&lock2);
	pthread_mutex_unlock(&lock2);
	pthread_mutex_unlock(&lock1);

	return NULL;
}

int main()
{	
	pthread_t threads[2];

	pthread_mutex_lock(&lock2);
	pthread_mutex_lock(&lock1);
	pthread_mutex_unlock(&lock1);
	pthread_mutex_unlock(&lock2);

	pthread_create(&threads[0], NULL, thread, NULL);

	pthread_mutex_lock(&lock2);	
    sleep(1);
    pthread_mutex_lock(&lock1);
	pthread_mutex_unlock(&lock1);
	pthread_mutex_unlock(&lock2);

	pthread_join(threads[0], NULL);
	
    return 0;
}
