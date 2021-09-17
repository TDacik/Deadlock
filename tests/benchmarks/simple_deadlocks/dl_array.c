//# Deadlock: true
//# Lockgraph:
//#   - locks[0] -> locks[1]
//#   - locks[1] -> locks[0]

// Arrays are not supported without EVA
//# With-eva-only: true

#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_mutex_t locks[2];

void *thread1(void *v)
{
    pthread_mutex_lock(&locks[0]);
    pthread_mutex_lock(&locks[1]);
    pthread_mutex_unlock(&locks[1]);
    pthread_mutex_unlock(&locks[0]);

    return NULL;
}

void *thread2(void *v)
{
    pthread_mutex_lock(&locks[1]);
    pthread_mutex_lock(&locks[0]);
    pthread_mutex_unlock(&locks[0]);
    pthread_mutex_unlock(&locks[1]);

    return NULL;
}

int main(int argc, char **argv)
{	
    pthread_t threads[2];

    pthread_mutex_init(&locks[0], NULL);
    pthread_mutex_init(&locks[1], NULL);

    pthread_create(&threads[0], NULL, thread1, NULL);
    pthread_create(&threads[1], NULL, thread2, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);

    pthread_mutex_destroy(&locks[0]);
    pthread_mutex_destroy(&locks[1]);
	
    return 0;
}
