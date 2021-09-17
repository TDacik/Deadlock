//# Deadlock: true
//# Lockgraph:
//#   - s1.lock -> s2.lock
//#   - s2.lock -> s1.lock


#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

struct s_with_lock
{
    int data;
    pthread_mutex_t lock;
};

struct s_with_lock s1;
struct s_with_lock s2;

void *thread1(void *v)
{
    pthread_mutex_lock(&s1.lock);
    pthread_mutex_lock(&s2.lock);
    pthread_mutex_unlock(&s2.lock);
    pthread_mutex_unlock(&s1.lock);

    return NULL;
}

void *thread2(void *v)
{
    pthread_mutex_lock(&s2.lock);
    pthread_mutex_lock(&s1.lock);
    pthread_mutex_unlock(&s1.lock);
    pthread_mutex_unlock(&s2.lock);

    return NULL;
}

int main(int argc, char **argv)
{	
    pthread_t threads[2];

    s1.data = 0;
    s2.data = 1;

    pthread_mutex_init(&s1.lock, NULL);
    pthread_mutex_init(&s2.lock, NULL);

    pthread_create(&threads[0], NULL, thread1, NULL);
    pthread_create(&threads[1], NULL, thread2, NULL);

    pthread_join(threads[0], NULL);
    pthread_join(threads[1], NULL);

    pthread_mutex_destroy(&s1.lock);
    pthread_mutex_destroy(&s2.lock);
	
    return 0;
}
