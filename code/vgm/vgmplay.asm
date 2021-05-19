
VGM_INIT:
	cmpi.l #$56676d20,(a0)
	beq.s VGM_INIT1
	moveq #1,d0
	rts

VGM_INIT1:
	move.l $14(a0),d0
	rol.w #8,d0
	swap d0
	rol.w #8,d0
	add.l #$14,d0
	add.l a0,d0
; 	DISPLAY_GD3 d0, #9
	moveq #0,d4
	move.l $1c(a0),d0
	beq.s VGM_INIT2
	rol.w #8,d0
	swap d0
	rol.w #8,d0
	add.l #$1c,d0
	move.l d0,d4
	add.l a0,d4

VGM_INIT2:
	cmpi.l #$50010000,8(a0)
	bcs.s VGM_INIT3
	move.l $34(a0),d0
	rol.w #8,d0
	swap d0
	rol.w #8,d0
	beq.s VGM_INIT3
	add.l #$34,d0
	bra.s VGM_INIT4

VGM_INIT3:
	moveq #64,d0

VGM_INIT4:
	add.l d0,a0
	lea VGM_INITRAM_INIT,a1
	lea $ff000A,a2
	moveq #17,d0

VGM_INIT5:
	move.b (a1)+,(a2)+
	dbra d0,VGM_INIT5
	moveq #0,d0
	move.l #$A04000,a4 
	move.l #$C00011,a6
	move.w #$000f,d5
	moveq #$00,d6
	bra VGM_PLAY

YM2612_REGWRITE:
	move.l a4,a3
	add.w d0,a3

YM2612_REGWRITE1:
	btst.b #7,(a4)
	bne.s YM2612_REGWRITE1
	move.b d1,(a3)+

YM2612_REGWRITE2:
	btst.b #7,(a4)
	bne.s YM2612_REGWRITE2
	move.b d2,(a3)
	rts

VGM_PLAY_DACW:
	move.b d2,$ff001B
	bra VGM_PLAY

VGM_PLAY_NOTE:
	lea $ff000F,a3
	move.b d2,d1
	and.w d5,d2
	cmp.w #4,d2
	bcs.s VGM_PLAY_NOTE1
	subq.w #1,d2

VGM_PLAY_NOTE1: 
	or.b d1,(a3,d2.w)
	addq.w #6,d2
	move.b d1,(a3,d2.w)
	bra VGM_PLAY

VGM_PLAY_YMP0:
	moveq #-1,d6
	moveq #0,d0
	move.b (a0)+,d1
	move.b (a0)+,d2
	cmp.b #$2A,d1
	beq VGM_PLAY_DACW
	cmp.b #$28,d1
	beq VGM_PLAY_NOTE
	move.w	#$0100,(z80_bus).l
.wait:
	btst	#0,(z80_bus).l
	bne.s	.wait
	bsr YM2612_REGWRITE
	
	move.b	#$2A,($A04000).l
	move.w	#0,(z80_bus).l
	bra VGM_PLAY

VGM_PLAY_YMP1:
	moveq #-1,d6
	moveq #2,d0
	move.b (a0)+,d1
	move.b (a0)+,d2
	move.w	#$0100,(z80_bus).l
.wait:
	btst	#0,(z80_bus).l
	bne.s	.wait
	bsr YM2612_REGWRITE
	
	move.b	#$2A,($A04000).l
	move.w	#0,(z80_bus).l
	bra VGM_PLAY

VGM_PLAY_PSGP:
	moveq #-1,d6
	move.l a3,-(a7)
	lea $ff000A,a3
	move.b (a0)+,d0
	move.b d0,d1
	bmi.s VGM_PLAY_PSGP1
	move.b 4(a3),d1	

VGM_PLAY_PSGP1:
	move.b d1,4(a3)	
	btst #4,d1
	bne.s VGM_PLAY_PSGP2
	move.b d0,$c00011
	bra.s VGM_PLAY_PSGP3

VGM_PLAY_PSGP2:
	and.w #$0060,d1
	lsr.w #5,d1
	and.b d5,d0
	and.b #$f0,(a3,d1.w)
	or.b  d0,(a3,d1.w)

VGM_PLAY_PSGP3:
	move.l (a7)+,a3
	bra VGM_PLAY

VGM_PLAY_DAC:
	moveq #-1,d6
	move.b (a1)+,$ff001B
	and.b d5,d0
	bne VGM_PLAY_WRITE
	bra VGM_PLAY

VGM_PLAY_DELAY1:			
	move.b (a0)+,d0
	or.b (a0)+,d0
	and.b d6,d0
	beq.s VGM_PLAY
	sub.w #3,a0
	bra VGM_PLAY_WRITE

VGM_PLAY_DELAY2:			
	tst.b d6
	beq.s VGM_PLAY
	sub.w #1,a0
	bra VGM_PLAY_WRITE

VGM_PLAY:
	move.b (a0)+,d0
	move.b d0,d1
	andi.b #$f0,d1
	cmpi.b #$52,d0		
	beq VGM_PLAY_YMP0
	cmpi.b #$53,d0		
	beq VGM_PLAY_YMP1
	cmpi.b #$50,d0		
	beq VGM_PLAY_PSGP	
	cmpi.b #$80,d1		
	beq.s VGM_PLAY_DAC
	cmpi.b #$e0,d0		
	beq VGM_PLAY_SAMPSEEK
	cmpi.b #$61,d0		
	beq.s VGM_PLAY_DELAY1
	cmpi.b #$62,d0		
	beq.s VGM_PLAY_DELAY2
	cmpi.b #$63,d0		
	beq.s VGM_PLAY_DELAY2
	cmpi.b #$70,d1		
	beq.s VGM_PLAY_DELAY2
	cmpi.b #$67,d0		
	beq.s VGM_PLAY_DATABLOK
	
	; NEW ONES
	cmpi.b #$90,d0
	bcc VGM_DAC_STREAM
	
	bsr VGM_ERRORTEST
	moveq #-1,d6
	bra.s	VGM_PLAY
	

VGM_PLAY_SAMPSEEK:
	move.b (a0)+,d1				
	move.b (a0)+,-(a7)			
	move.w (a7)+,d0					
	move.b d1,d0					
	swap d0						
	move.b (a0)+,d0				
	swap d0						
	move.b (a0)+,d1				
	move.l a2,a1			
	add.l d0,a1				
	bra VGM_PLAY					

VGM_PLAY_DATABLOK:
	move.b (a0)+,d0
	move.b (a0)+,d0
	bne VGM_ERROR0
	move.b (a0)+,d1
	move.b (a0)+,d0
	lsl.w #8,d0
	move.b d1,d0
	swap d0
	move.b (a0)+,d1
	move.b (a0)+,d0
	lsl.w #8,d0
	move.b d1,d0
	swap d0
	move.l a0,a2
	add.l d0,a0
; 	bra.s *
	bra VGM_PLAY

VGM_PLAY_WRITE:
	move.w	#$0100,(z80_bus).l
.wait:
	btst	#0,(z80_bus).l
	bne.s	.wait
	
	moveq #0,d0
	move.b #$2a,d1
	move.b $ff001B,d2
	bsr YM2612_REGWRITE 
	lea $ff000F,a5
	move.b #$28,d1
	moveq #11,d3

VGM_PLAY_WRITE2:
	move.b (a5)+,d2
	bsr YM2612_REGWRITE
	dbra d3,VGM_PLAY_WRITE2
	lea $ff000A,a3
	moveq #4,d0

VGM_PLAY_WRITE3:
	move.b (a3)+,(a6)
	dbra d0,VGM_PLAY_WRITE3
	move.l #$A04002,a5
	moveq #0,d3
	move.l $8,d7
	
	move.b	#$2A,($A04000).l
	move.w	#0,(z80_bus).l
	bra PLAY_LOOP

DELAY_CODE2:
	add.w d0,d3				
	sub.w d3,d0				
	moveq #0,d3				
	bra.s DELAY_CODE3				

DELAY_CODE4: 						
	rol.l #6,d2				
	rol.l #5,d2				

DELAY_CODE3: 
	move.b $A10003,d1				
	move.b $00ff0000,d2				
	move.b d1,$00ff0000				
	move.b d1,$00ff0000				
	eor.b d1,d2					
	not.b d2					
	or.b d2,d1					
	cmp.b #$ff,d1					
	beq.s DELAY_CODE5			
	bsr PRESSED_KEY					

DELAY_CODE5:						
	ror.l #3,d2				
	ror.l #2,d2				
	subq.w #1,d0					
	bne DELAY_CODE4					
	bra PLAY_LOOP					

REG_WRITE: 	
	addq.w #1,d3				
	move.b (a0)+,d0				
	move.b d0,d1					
	and #$f0,d1					
	cmpi.b #$70,d1					
	bne.s REG_WRITE1				
	move.b d2,(a3)			

DELAYN_WRITE:	
	and.w d5,d0					
	addq.w #1,d0					

DELAYNN_WRITE: 
	bra DELAY_CODE					

REG_WRITE1:						
	move.b d2,(a3)			
	suba.l #1,a0				
	nop						
	nop
	move.b	#$2A,($A04000).l
	move.w	#0,(z80_bus).l
	bra PLAY_LOOP					

YMP0_WRITE: 
	move.w	#$0100,(z80_bus).l
.wait:
	btst	#0,(z80_bus).l
	bne.s	.wait

	move.l a4,a3		
	move.b (a0)+,(a3)+		
	move.b (a0)+,d2			
	rol.l #4,d0					
	rol.l #2,d0					
	bra REG_WRITE					

YMP1_WRITE: 
	move.w	#$0100,(z80_bus).l
.wait:
	btst	#0,(z80_bus).l
	bne.s	.wait

	move.l a5,a3		
	move.b (a0)+,(a3)+		
	move.b (a0)+,d2			
	rol.l	#4,d0					
	bra REG_WRITE

PSGP_WRITE: 
	move.l a6,a3		
	move.b (a0)+,d2 			
	move.w #$1234,d0				
	move.b d0,(a0)				
	bra REG_WRITE					

DAC_WRITE: 
	move.w	#$0100,(z80_bus).l
.wait:
	btst	#0,(z80_bus).l
	bne.s	.wait

	move.l a4,a3		
	move.b #$2A,(a3)+			
	ror.l #8,d2				
	ror.l #4,d2				
	addq.w #1,d3				
	and.w #$000f,d0					
	move.b (a1)+,(a3)
	
	move.b	#$2A,($A04000).l
	move.w	#0,(z80_bus).l
	
DELAY_CODE:						
	sub.w d0,d3				
	bcc.s PLAY_LOOP					
	bra DELAY_CODE2					

PLAY_LOOP: 
	move.b (a0)+,d0				
	move.b d0,d1					
	sub.b #$52,d0					
	beq YMP0_WRITE				
	subq.b #1,d0					
	beq.s YMP1_WRITE				
	addq.b #3,d0					
	beq.s PSGP_WRITE				
	and.b #$f0,d1					
	cmpi.b #$80,d1					
	beq.s DAC_WRITE					
	cmpi.b #$90,d0					
	bne.s NOT_SAMPSEEK			

SAMPLE_SEEK:		
	addq.w #1,d3				
	move.b (a0)+,d1				
	move.b (a0)+,-(a7)			
	move.w (a7)+,d0					
	move.b d1,d0					
	swap d0						
	move.b (a0)+,d0				
	swap d0						
	move.b (a0)+,d1				
	move.l a2,a1			
	add.l d0,a1				
	bra PLAY_LOOP					
			
NOT_SAMPSEEK:
	cmpi.b #$70,d1					
	beq.s DELAYN_TEMP				
	cmpi.b #$16,d0					
	beq.s VGM_END					
	cmpi.b #$ff,d0					
	beq.s VGM_GGPSG					
	cmpi.b #$11,d0					
	beq. DELAYNN_TEMP				
	cmpi.b #$12,d0					
	beq DELAY735					
	cmpi.b #$13,d0					
	beq DELAY882					
	cmpi.b #$17,d0					
	beq VGM_BLOCKSET
	
	cmp.b #$40,d0
	bcc VGM_DAC_PART2
	
	;TODO: checar aqui
	bsr VGM_ERRORTEST				
	addq.w #2,d3				
	rol.l #6,d2				
	bra PLAY_LOOP

DELAYN_TEMP: 		
	ror.l #6,d2				
	bra DELAYN_WRITE				

VGM_END: 			
	tst.l d4					
	bne.s VGM_LOOPS					
	rts

VGM_LOOPS:
	addq.w #1,d3				
	move.l d4,a0			
	ror.w #1,d2				
	subq.l #1,d7					
	bne PLAY_LOOP					
	rts

VGM_GGPSG: 			
	addq.w #1,d3				
	move.b (a0)+,d0				
	addq.w #1,d3				
	nop						
	bra PLAY_LOOP					

DELAYNN_TEMP: 			
	move.b (a0)+,d1				
	move.b (a0)+,d0				
	lsl.w #8,d0					
	move.b d1,d0					
	bra.s DELAY_COMMON					

DELAY735: 
	move.w #735,d0					
	ror.l #7,d2				
	bra.s DELAY_COMMON				

DELAY882: 
	move.w #882,d0					
	ror.l #3,d2				

DELAY_COMMON: 	
	addq.w #2,d3				
	ror.l #8,d2				
	rol.l #8,d2				
	ror.l #8,d2				
	rol.l #8,d2				
	bra DELAYNN_WRITE				
	
VGM_BLOCKSET:
	move.b (a0)+,d0
	move.b (a0)+,d0
	bne VGM_ERROR0
	move.b (a0)+,d1
	move.b (a0)+,d0
	lsl.w #8,d0
	move.b d1,d0
	swap d0
	move.b (a0)+,d1
	move.b (a0)+,d0
	lsl.w #8,d0
	move.b d1,d0
	swap d0
	move.l a0,a2
	add.l d0,a0
	bra PLAY_LOOP

VGM_ERRORTEST:
	move.b -1(a0),d0		
	cmp.b #$30,d0		
	bcc.s VGM_ERROR1		
 
VGM_ERROR0
	move.b -1(a0),d0
; 	move.l #$eeeeeee,d7
	
  move.l #$C0000000,($C00004).l
 move.w #$EEE,($C00000).l
 bra.s *
 
; 	bra.s VGM_ERROR0

VGM_ERROR1:				
	cmp.b #$51,d0			
	bcc VGM_ERROR2			
	adda.w #1,a0
	rts

VGM_ERROR2:	
; 	cmp.b #$90,d0			
; 	bcc VGM_DAC_STREAM
	cmp.b #$60,d0			
	bcc VGM_ERROR3	
	adda.w #2,a0		
	rts				

VGM_ERROR3:
	cmp.b #$a0,d0
	bcs VGM_ERROR0
	cmp.b #$c0,d0
	bcc VGM_ERROR4
	adda.w #2,a0
	rts

VGM_ERROR4:
	cmp.b #$e0,d0
	bcc VGM_ERROR5
	adda.w #3,a0
	rts

VGM_ERROR5:
	adda.w #4,a0
	rts

VGM_INITRAM_INIT:
	dc.b $9f, $bf, $df, $ff, $9f, $00, $01, $02, $04, $05, $06
	dc.b $00, $01, $02, $04, $05, $06, $80
	align 2
	
VGM_DAC_STREAM:
	cmp.b #$90,d0
	beq.s VGMDAC_90
	cmp.b #$91,d0
	beq.s VGMDAC_91
	cmp.b #$92,d0
	beq.s VGMDAC_92
	cmp.b #$93,d0
	beq.s VGMDAC_93
	cmp.b #$94,d0
	beq.s VGMDAC_94
	cmp.b #$95,d0
	beq.s VGMDAC_95

VGM_DACERR:
  move.l #$C0000000,($C00004).l
 move.w #$E00,($C00000).l
 bra.s *
	
; 0x90 ss tt pp cc
;      ss = Stream ID
;      tt = Chip Type (see clock-order in header, e.g. YM2612 = 0x02)
;            bit 7 is used to select the 2nd chip
;      pp cc = write command/register cc at port pp
;      Note: For chips that use Channel Select Registers (like the RF5C-family
;            and the HuC6280), the format is pp cd where pp is the channel
;            number, c is the channel register and d is the data register.
;            If you set pp to FF, the channel select write is skipped.
VGMDAC_90:
; 	adda	#1,a0		; ss
; 	move.b	(a0)+,d0	; tt
; 	cmp.b 	#2,d0
; 	bne.s	VGM_DACERR
; 	move.b	(a0)+,d0
; 	move.b	(a0)+,d1
; 
; 	bsr	VGMDAC_REGWRITE

	adda #4,a0
	bra VGM_PLAY
	
;  0x91 ss dd ll bb
;      ss = Stream ID
;      dd = Data Bank ID (see data block types 0x00..0x3f)
;      ll = Step Size (how many data is skipped after every write, usually 1)
;            Set to 2, if you're using an interleaved stream (e.g. for
;             left/right channel).
;      bb = Step Base (data offset added to the Start Offset when starting
;            stream playback, usually 0)
;            If you're using an interleaved stream, set it to 0 in one stream
;            and to 1 in the other one.
;      Note: Step Size/Step Step are given in command-data-size
;             (i.e. 1 for YM2612, 2 for PWM), not bytes
VGMDAC_91:
	adda #4,a0
	bra VGM_PLAY
	
;  0x92 ss ff ff ff ff
;      ss = Stream ID
;      ff = Frequency (or Sample Rate, in Hz) at which the writes are done
VGMDAC_92:
	adda #5,a0
	bra VGM_PLAY
	
;  0x93 ss aa aa aa aa mm ll ll ll ll
;      ss = Stream ID
;      aa = Data Start offset in data bank (byte offset in data bank)
;            Note: if set to -1, the Data Start offset is ignored
;      mm = Length Mode (how the Data Length is calculated)
;            00 - ignore (just change current data position)
;            01 - length = number of commands
;            02 - length in msec
;            03 - play until end of data
;            1? - (bit 4) Reverse Mode
;            8? - (bit 7) Loop (automatically restarts when finished)
;      ll = Data Length
VGMDAC_93:
	bsr dodac_93
	
	adda #$A,a0
	bra VGM_PLAY
	
;  0x94 ss
;      ss = Stream ID
;            Note: 0xFF stops all streams
VGMDAC_94:
	adda #1,a0
	bra VGM_PLAY

;  0x95 ss bb bb ff
;      ss = Stream ID
;      bb = Block ID (number of the data block that is part of the data bank set
;            with command 0x91)
;      ff = Flags
;            bit 0 - Loop (see command 0x93, mm bit 7)
;            bit 4 - Reverse Mode (see command 0x93)
VGMDAC_95:
	adda #4,a0
	bra VGM_PLAY	
	
; d0 - Port
; d1 - Data

VGMDAC_REGWRITE:
; 	move.w	#$0100,(z80_bus).l
; .wait:
; 	btst	#0,(z80_bus).l
; 	bne.s	.wait
; 		
; REGWAIT_1:
; 	btst.b	#7,(a4)
; 	bne.s	REGWAIT_1
; 	move.b	d0,1(a4)
; REGWAIT_2:
; 	btst.b	#7,(a4)	
; 	bne.s	REGWAIT_2
; 	move.b	d1,1(a4)
; 	
; 	move.w	#0,(z80_bus).l
	rts

VGM_DAC_PART2:
	cmp.b #$40,d0
	beq.s ._40
	cmp.b #$41,d0
	beq.s ._41
	cmp.b #$42,d0
	beq.s ._42
	cmp.b #$43,d0
	beq.s ._43
	cmp.b #$44,d0
	beq.s ._44
	cmp.b #$45,d0
	beq.s ._45

  move.l #$C0000000,($C00004).l
 move.w #$0E0,($C00000).l
 bra.s *
._40:
	adda #4,a0
	bra PLAY_LOOP
._41:
	adda #4,a0
	bra PLAY_LOOP
._42:
	adda #5,a0
	bra PLAY_LOOP
._43:
	bsr dodac_93
	adda #$A,a0
	bra PLAY_LOOP
._44:
	adda #1,a0
	bra PLAY_LOOP
._45:
	adda #4,a0
	bra PLAY_LOOP	

	
dodac_93:
	movem.l	d0-d3,-(sp)
	
	move.w	#$0100,(z80_bus).l
.wait:
	btst	#0,(z80_bus).l
	bne.s	.wait
	
	move.b 4(a0),d1
	lsl.l #8,d1
	move.b 3(a0),d1
	lsl.l #8,d1
	move.b 2(a0),d1
	lsl.l #8,d1
	move.b 1(a0),d1
	add.l	a2,d1
	move.l d1,$FF0120
	move.l	d1,d3
	
	move.l	d1,d2
	move.b	d2,($A00000+Sample_Start)
	lsr.l	#8,d2
	or.b	#$80,d2
	move.b	d2,($A00000+Sample_Start+1)
	lsr.l	#8,d1
	lsr.l	#7,d1
	move.b	d1,($A00000+Sample_Start+2)

	move.b 9(a0),d1
	lsl.l #8,d1
	move.b 8(a0),d1
	lsl.l #8,d1
	move.b 7(a0),d1
	lsl.l #8,d1
	move.b 6(a0),d1
; 	sub.l	#$100,d1
	add.l	d3,d1
	move.l d1,$FF0124

	move.l	d1,d2
	move.b	d2,($A00000+Sample_End)
	lsr.l	#8,d2
	or.b	#$80,d2
	move.b	d2,($A00000+Sample_End+1)
	lsr.l	#8,d1
	lsr.l	#7,d1
	move.b	d1,($A00000+Sample_End+2)
	
	move.b	#%11,($A00000+Sample_Flags)
	
	move.w	#0,(z80_bus).l
	movem.l	(sp)+,d0-d3
	rts
	
