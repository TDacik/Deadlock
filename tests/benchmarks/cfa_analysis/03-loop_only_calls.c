//# Terminates: true

void my_pthread_cond_signal() {return;}
void my_pthread_cond_wait() {return;}

int main (int argc, char **argv)
{
	while(argc < 10){
		my_pthread_cond_signal();
		my_pthread_cond_wait();
	}
}
