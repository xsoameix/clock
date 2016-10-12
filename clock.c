#include <stdint.h>

#define thumb __attribute__((target("thumb")))

void thumb
patch_main(void) {
  // english:  0x03005d90
  // japanese: 0x03005af0
  void * player_data = * (void **) 0x03005af0;
  int8_t * sec = (int8_t *) (player_data + 0x11);
  int16_t * day = (int16_t *) (player_data + 0x98);
  int8_t * hour = (int8_t *) (player_data + 0x9a);
  int8_t * min = (int8_t *) (player_data + 0x9b);
  int8_t * sum_buff = (int8_t *) 0x0201f000;
  if (sum_buff[0] == * sec) return;
  sum_buff[0] = * sec;
  sum_buff[1]++;
  if (sum_buff[1] <= 59) return;
  sum_buff[1] = 0;
  if (* min > 0) { (* min)--; return; }
  * min = 59;
  if (* hour > 0) { (* hour)--; return; }
  * hour = 23;
  (* day)++; // 0: 2000-01-01, 1: 2000-01-02, ...
}
