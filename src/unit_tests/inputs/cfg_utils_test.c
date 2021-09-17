#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void *thread1(void *v)
{
    int x;
    stmt1: x = 5;
    return NULL;
}

void *thread2(void *v)
{
    thread1(NULL);
    return NULL;
}

int g()
{
    pthread_t threads[2];

    create1: pthread_create(&threads[0], NULL, thread1, NULL);
    create2: pthread_create(&threads[1], NULL, thread2, NULL);

    join1: pthread_join(threads[0], NULL);
    join2: pthread_join(threads[1], NULL);

    thread1(NULL);
    thread2(NULL);

    return 0;
}

void f()
{
    int x = g(); // Check also local init
    g();
    stmt3: g();
}

int main()
{	
    stmt2: f();
    g();
    return 0;
}
