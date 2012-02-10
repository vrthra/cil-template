








#define _GNU_SOURCE 
#include <stdio.h>
#include <dlfcn.h>
#include <errno.h>
#include <stdlib.h>
#include <pthread.h>

#include <ciltut.h>








int (*pthread_mutex_lock_orig)  (pthread_mutex_t *m) = NULL;
int (*pthread_mutex_unlock_orig)(pthread_mutex_t *m) = NULL;















int pthread_mutex_lock(pthread_mutex_t *m)
{
  int res;
  if (!pthread_mutex_lock_orig)
    pthread_mutex_lock_orig = checked_dlsym(RTLD_NEXT, "pthread_mutex_lock");
  res = pthread_mutex_lock_orig(m);
  printf("thread: %d - pthread_mutex_lock(%p)\n", gettid(), m);
  fflush(stdout);
  return res;
}

int pthread_mutex_unlock(pthread_mutex_t *m)
{
  int res;
  if (!pthread_mutex_unlock_orig)
    pthread_mutex_unlock_orig = checked_dlsym(RTLD_NEXT, "pthread_mutex_unlock");
  printf("thread: %d - pthread_mutex_unlock(%p)\n", gettid(), m);
  fflush(stdout);
  res = pthread_mutex_unlock_orig(m);
  return res;
}

