
#include <pthread.h>

int counter = 0;
pthread_mutex_t mtx = PTHREAD_MUTEX_INITIALIZER;

int main()
{
  pthread_mutex_lock(&mtx);
  counter++;
  pthread_mutex_unlock(&mtx);
  return 0;
}
