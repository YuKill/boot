#ifndef _MM_H_
#define _MM_H_

typedef struct memory_block {
   unsigned int start;
   unsigned int end;
   int size;
   int inUse; // 0 to free memory block
} memory_block;

unsigned int* free_memory_blocks;
unsigned int* inUse_memory_blocks;

#endif
