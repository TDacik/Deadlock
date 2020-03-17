#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

void *thread1(void *v)
{
	pthread_t t;
	pthread_create(&t, NULL, (void *)(v), NULL);
	pthread_join(t, NULL);
	return NULL;
}

void *thread2(void *v)
{
	return NULL;
}

void *thread3(void *v)
{
	return NULL;
}

int main()
{	
	pthread_t threads[2];
	
	pthread_create(&threads[0], NULL, thread1, &thread2);
	pthread_create(&threads[1], NULL, thread1, &thread3);
	
	pthread_join(threads[0], NULL);
	pthread_join(threads[1], NULL);
	return 0;
}
