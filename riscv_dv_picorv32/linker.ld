/* Linker script for PicoRV32 test programs */
OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY {
    /* PicoRV32 typically starts execution at 0x80000000 */
    rom (rx) : ORIGIN = 0x80000000, LENGTH = 64K
    ram (rwx) : ORIGIN = 0x80010000, LENGTH = 64K
}

SECTIONS {
    .text : {
        *(.text.start)
        *(.text)
        *(.text.*)
    } > rom
    
    .data : {
        *(.data)
        *(.data.*)
        *(.sdata)
        *(.sdata.*)
    } > ram
    
    .bss : {
        *(.bss)
        *(.bss.*)
        *(.sbss)
        *(.sbss.*)
    } > ram
    
    /* Stack starts at end of RAM and grows downward */
    _stack_start = ORIGIN(ram) + LENGTH(ram);
}
