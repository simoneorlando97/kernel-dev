/**
 * Read a byte from the specified port
 */

unsigned char port_byte_get (unsigned short port) {
    unsigned char result;
    // set the C variable result to the value of register eax
    // map the C variable port into edx register
    // in: copies the value from the I/O port specified with the second operand 
    // (source operand) to the destination operand (first operand).
    __asm__("in %%dx, %%al" : "=a" (result) : "d" (port));
    return result;
}

void port_byte_ask (unsigned short port, unsigned char data) {
  // copies the value from the second operand (source operand) 
  // to the I/O port specified with the destination operand (first operand).
   __asm__("out %%al, %%dx" : : "a" (data), "d" (port));
}

unsigned short port_word_get (unsigned short port) {
    unsigned short result;
    __asm__("in %%dx, %%ax" : "=a" (result) : "d" (port));
    return result;
}

void port_word_ask (unsigned short port, unsigned short data) {
    __asm__("out %%ax, %%dx" : : "a" (data), "d" (port));
}

