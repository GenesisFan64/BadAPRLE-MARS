; ----------------------------------------------------------------
; MD ROM bank
; 
; 1MB max
; ----------------------------------------------------------------

MDBANK_0:
		align $8000
VGM_DATA:	binclude "data/ba.vgm"
