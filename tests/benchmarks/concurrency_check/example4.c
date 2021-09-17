#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

void fn()
{
	pthread_mutex_lock(&lock1);
	pthread_mutex_lock(&lock2);
	pthread_mutex_unlock(&lock2);
	pthread_mutex_unlock(&lock1);
}

void *thread1(void *v)
{
	fn();
	return NULL;
}

void *thread2(void *v)
{
	pthread_mutex_lock(&lock2);
	pthread_mutex_lock(&lock1);
	pthread_mutex_unlock(&lock1);
	pthread_mutex_unlock(&lock2);

	return NULL;
}

void *thread3(void *v)
{
	fn();
	return NULL;
}

int main()
{	
	pthread_t threads[2];

	pthread_create(&threads[0], NULL, thread1, NULL);
	pthread_join(threads[0], NULL);
	
	pthread_create(&threads[1], NULL, thread2, NULL);
	pthread_create(&threads[2], NULL, thread3, NULL);
	pthread_join(threads[1], NULL);
	pthread_join(threads[2], NULL);

	return 0;
}
