; ====================================================================
; ----------------------------------------------------------------
; MD code (at $FF0000)
; ----------------------------------------------------------------

; ====================================================================
; ------------------------------------------------------
; Global RAM
; ------------------------------------------------------

		struct RAM_MdGlobal
RAM_MdGlbExmpl	ds.w 1
sizeof_mdglbl	ds.l 0
		finish

; ====================================================================
; ------------------------------------------------------
; Variables
; ------------------------------------------------------

Var_example	equ	1234

; ====================================================================
; ------------------------------------------------------
; Structs
; ------------------------------------------------------

; 		struct 0
; strc_xpos	ds.w 1
; strc_ypos	ds.w 1
; 		finish

; ====================================================================
; ------------------------------------------------------
; RAM for current screen mode
; ------------------------------------------------------

; 		struct RAM_ModeBuff
; GmMode0_long	ds.l 1
; GmMode0_word	ds.w 1
; GmMode0_byte	ds.b 1
; 		finish

; ====================================================================
; --------------------------------------------------------
; Include system features
; --------------------------------------------------------

		include	"system/md/system.asm"
		include	"system/md/video.asm"
		include	"system/md/sound.asm"

; ====================================================================
; --------------------------------------------------------
; Initialize system
; --------------------------------------------------------

MD_Main:
		bsr 	Sound_init
		bsr 	Video_init
		bsr	System_Init
		
; ====================================================================
; ------------------------------------------------------
; Code start
; ------------------------------------------------------
	
		move.w	#$2700,sr
		bsr	Mode_Init
		bsr	Video_PrintInit
; 		bset	#bitDispEnbl,(RAM_VdpRegs+1).l		; Enable display
; 		bset	#bitVint,(RAM_VdpRegs+1).l
; 		move.l	#VBLANK_custom,(RAM_VBlankGoTo+2).l
; 		bsr	Video_Update
; 		move.w	#$8164,(vdp_ctrl).l
; 		move.w	#$2000,sr
		
; ====================================================================
; ------------------------------------------------------
; Loop
; ------------------------------------------------------

; 	bsr	Video_Init
; 	bsr	Sound_Init
; 	bsr	FMV_Init
; 	move.w #$100,$a11100
; 	move.w #$100,$a11200
; 	move.b #$40, $a10003
; 	move.b #$40, $a10009
; 	move.b #$7f,$ff0000
	move.w #1,$ff0006
	clr.w $ff0008
	jmp PLAY_TRACK

VGM_LIST:
 dc.l 1
	dc.l VGM_DATA

; .loop:
; 		bsr	System_VSync
; 
; 		lea	str_Title(pc),a0
; 		move.l	#locate(0,0,26),d0
; 		bsr	Video_Print
; 		bra	.loop
		
; ====================================================================
; ------------------------------------------------------
; Subroutines
; ------------------------------------------------------

		include "code/vgm/vgmplay.asm"
		include "code/vgm/interact.asm"
	
; ====================================================================
; ------------------------------------------------------
; Interrupts
; ------------------------------------------------------

; --------------------------------------------------
; Custom VBlank
; --------------------------------------------------

; --------------------------------------------------
; Custom HBlank
; --------------------------------------------------

VBLANK_custom:
; 		movem.l	d0-d7/a0-a6,-(sp)
; 		lea	str_Title(pc),a0
; 		move.l	#locate(0,0,26),d0
; 		bsr	Video_Print
; 		movem.l	(sp)+,d0-d7/a0-a6
		rte

; ====================================================================
; ------------------------------------------------------
; DATA
; 
; short stuff goes here
; ------------------------------------------------------

		align 2
str_Title:	dc.b "\\w \\w \\w \\w",$A
		dc.b "\\w \\w \\w \\w         MD: \\l",0
		dc.l sysmars_reg+comm0
		dc.l sysmars_reg+comm2
		dc.l sysmars_reg+comm4
		dc.l sysmars_reg+comm6
		dc.l sysmars_reg+comm8
		dc.l sysmars_reg+comm10
		dc.l sysmars_reg+comm12
		dc.l sysmars_reg+comm14
		dc.l RAM_FrameCount
		align 4