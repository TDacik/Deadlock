#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

struct s_with_locks
{
    int data;
    pthread_mutex_t lock1;
    pthread_mutex_t lock2;
};

struct s_with_locks s;

void *thread1(void *v)
{
    pthread_mutex_lock(&s.lock1);
    pthread_mutex_lock(&s.lock2);
    pthread_mutex_unlock(&s.lock2);
    pthread_mutex_unlock(&s.lock1);

    return NULL;
}

void *thread2(void *v)
{
    pthread_mutex_lock(&s.lock2);
    pthread_mutex_lock(&s.lock1);
    pthread_mutex_unlock(&s.lock1);
    pthread_mutex_unlock(&s.lock2);

    return NULL;
}

int main(int argc, char **argv)
{	
    pthread_t threads[2];

    s.data = 1;

    pthread_mutex_init(&s.lock1, NULL);
    pthread_mutex_init(&s.lock2, NULL);

    pthread_create(&threads[0], NULL, thread1, NULL);
    pthread_create(&threads[1], NULL, thread2, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);
	
    return 0;
}
