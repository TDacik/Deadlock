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

int main(int argc, char **argv)
{	
	pthread_t t, t2, t3;

    pthread_create(&t, NULL, thread, NULL);
    pthread_create(&t2, NULL, thread, NULL);

    pthread_join(t, NULL);
    pthread_join(t2, NULL);

    pthread_create(&t3, NULL, thread, NULL);
    pthread_join(t3, NULL);

	pthread_mutex_lock(&lock2);	
    pthread_mutex_lock(&lock1);
	pthread_mutex_unlock(&lock1);
	pthread_mutex_unlock(&lock2);

    return 0;
}
