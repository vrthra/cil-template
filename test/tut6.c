#include <stdlib.h>
#include <stdio.h>

struct foo {
	int *a;
	int b;
	int *c;
};

struct bar {
	struct foo f;
	int *a;
	int b;
};

struct baz {
	struct bar b;
	int a;
	int *c;
};

int main()
{
	struct baz *b[37];
	int i;

	for (i = 0; i < 37; i++) {
		b[i] = malloc(sizeof(struct baz));
	}

  return 0;
}


