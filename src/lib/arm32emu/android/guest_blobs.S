/* The 32-bit engine and patcher, linked into the 64-bit runtime as data.
   ZC_GAME_SO and ZC_EXT_SO are the paths, passed by build.sh. */
    .section .rodata.zc_guest, "a", %progbits

    .p2align 4
    .globl zc_guest_game
    .hidden zc_guest_game
zc_guest_game:
    .incbin ZC_GAME_SO
    .globl zc_guest_game_end
    .hidden zc_guest_game_end
zc_guest_game_end:

    .p2align 4
    .globl zc_guest_ext
    .hidden zc_guest_ext
zc_guest_ext:
    .incbin ZC_EXT_SO
    .globl zc_guest_ext_end
    .hidden zc_guest_ext_end
zc_guest_ext_end:

    .section .note.GNU-stack, "", %progbits
