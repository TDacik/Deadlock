// Correct handling of program exit in lockset analysis
// Example inspired by smbnetfs-0.6.0_src_smbnetfs.c

//# Todo: true

//# Deadlock: False
//# Lockgraph:
//#   - lock2 -> lock1

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t lock1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t lock2 = PTHREAD_MUTEX_INITIALIZER;

int f()
{
    pthread_mutex_lock(&lock1);

    int *i = malloc(sizeof(int));

    if (i == NULL)
        return -1;

    free(i);

    pthread_mutex_unlock(&lock1);
    return 0;
}

void *thread1(void *v)
{
    int ret = f();
    if (ret != 0)
        return NULL;

    pthread_mutex_lock(&lock2);
    pthread_mutex_unlock(&lock2);

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

int main(int argc, char **argv)
{	
    pthread_t threads[2];

    pthread_create(&threads[0], NULL, thread1, NULL);
    pthread_create(&threads[1], NULL, thread2, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);
	
    return 0;
}
