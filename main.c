#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

struct patch {
  uint32_t patch_ret;
};

struct patch patch_emerald = {
  .patch_ret = 0x080005F1
};

int
main(int argc, char ** argv) {
  int ret = 1;
  if (argc != 4) return fprintf(stderr, "Require 3 arguments.\n"), ret;
  const char * bin_str = argv[1];
  const char * addr_str = argv[2];
  const char * pat_str = argv[3];
  char * addr_str_end;
  long addr = strtol(addr_str, &addr_str_end, 0);
  if (!addr_str[0] || addr_str_end != addr_str + strlen(addr_str) || addr < 0)
    return fprintf(stderr, "Argument 3 should be positive integer.\n"), ret;
  FILE * bin;
  FILE * pat;
  if ((bin = fopen(bin_str, "r+b")) == NULL) return perror(bin_str), ret;
  if ((pat = fopen(pat_str, "rb")) == NULL) { perror(pat_str); goto close_bin; }
  if (fseek(pat, 0L, SEEK_END) == -1) { perror(pat_str); goto close_pat; }
  long file_size_long;
  if ((file_size_long = ftell(pat)) == -1) { perror(pat_str); goto close_pat; }
  size_t file_size = (size_t) file_size_long;
  if (fseek(pat, 0L, SEEK_SET) == -1) { perror(pat_str); goto close_pat; }
  if (fseek(bin, addr, SEEK_SET) == -1) { perror(bin_str); goto close_pat; }
  uint8_t block[1024];
  for (size_t i = 0; i < file_size; i += sizeof(block)) {
    size_t size = (file_size - i < sizeof(block) ?
                   file_size - i : sizeof(block));
    if (fread(block, size, 1, pat) != 1) { perror(pat_str); goto close_pat; }
    if (fwrite(block, size, 1, bin) != 1) { perror(bin_str); goto close_pat; }
  }
  ret = 0;
close_pat: fclose(pat);
close_bin: fclose(bin);
  return ret;
}
