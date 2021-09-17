#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_t threads[2];

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

void *thread1(void *v)
{
	pthread_mutex_lock(&lock1);
	pthread_mutex_lock(&lock2);
	pthread_mutex_unlock(&lock2);
	pthread_mutex_unlock(&lock1);

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

void fn2()
{
	return;
}

void fn1()
{
	fn2();
}

void join()
{
	pthread_join(threads[0], NULL);
}

int main()
{	

	pthread_create(&threads[0], NULL, thread1, NULL);	
	join();
	
	pthread_create(&threads[1], NULL, thread2, NULL);
	pthread_join(threads[1], NULL);

	return 0;
}
