; ====================================================================
; ----------------------------------------------------------------
; SH2 ROM user data
; 
; This section will be gone if perfoming DMA ROM-to-VDP on the
; MD side
; 
; (setting RV=1)
; ----------------------------------------------------------------

MARS_RLEDATA	binclude "data/rle_data.bin"
		align 4
