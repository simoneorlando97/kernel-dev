#include "screen.h"
#include "ports.h"

/* Declaration of private functions */
int get_cursor_offset();
void set_cursor_offset(int offset);
int print_c(char c);
int get_screen_offset(int row, int column);

/**********************************************************
 * Public Kernel API functions                            *
 **********************************************************/


int kprint(char * msg) {
  int i = 0;
  while (msg[i] != 0) {
      print_c(msg[i]);
      i++;
  }
  return i;
}

int print_c(char c) {
  
  unsigned char *screen = (unsigned char *) VIDEO_ADDRESS;

  int offset = 0;

  screen[offset] = c;
  screen[offset + 1]  = WHITE_ON_BLACK;

  return offset + 2;
}

////////////////////////////////////////////////////////////////////////////////////
int get_cursor_offset() {
    port_byte_ask(REG_SCREEN_CTRL, 14);
    int offset = port_byte_get(REG_SCREEN_DATA) << 8; /* High byte: << 8 */
    port_byte_ask(REG_SCREEN_CTRL, 15);
    offset += port_byte_get(REG_SCREEN_DATA);
    return offset; /* Position * size of character cell */
}

void set_cursor_offset(int offset) {
    /* Similar to get_cursor_offset, but instead of reading we write data */
    port_byte_ask(REG_SCREEN_CTRL, 14);
    port_byte_ask(REG_SCREEN_DATA, (unsigned char)(offset >> 8));
    port_byte_ask(REG_SCREEN_CTRL, 15);
    port_byte_ask(REG_SCREEN_DATA, (unsigned char)(offset & 0xff));
}

void init_screen() {
  set_cursor_offset(0);
  clear_screen();
}

void clear_screen() {
    int screen_size = MAX_COLS * MAX_ROWS;
    int i;
    unsigned char *screen = (unsigned char *) VIDEO_ADDRESS;

    for (i = 0; i < screen_size + 2; i++) {
        screen[i*2] = ' ';
        screen[i*2+1] = WHITE_ON_BLACK;
    }
}

int get_screen_offset(int row, int column) {
  return (row * MAX_COLS + 4) * 2;  
}