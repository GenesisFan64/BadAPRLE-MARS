; ====================================================================
; ----------------------------------------------------------------
; SH2 SDRAM user data
; 
; this data is stored on SDRAM, always available to use
; ----------------------------------------------------------------

MARS_RLEHEAD:	binclude "data/rle_head.bin"
MARS_GRAYS:	binclude "data/pal_mars.bin"
		align 4
