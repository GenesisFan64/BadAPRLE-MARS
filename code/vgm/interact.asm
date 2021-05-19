

NEXT_TRACK:
	lea VGM_LIST,a0
	move.l (a0),d1
	move.w $ff0006,d0
	addq.w #1,d0
	cmp.w d1,d0
	bls.s NEXT_TRACK1
	moveq #1,d0

NEXT_TRACK1:
	move.w d0,$ff0006
	bra PLAY_TRACK1

PREV_TRACK:
	lea VGM_LIST,a0
	move.l (a0),d1
	move.w $ff0006,d0
	subq.w #1,d0
	bne.s PREV_TRACK1
	move.w d1,d0

PREV_TRACK1:
	move.w d0,$ff0006
	bra PLAY_TRACK1

PLAY_TRACK:
	lea VGM_LIST,a0
	move.w $ff0006,d0

PLAY_TRACK1:; 
	lsl.w #2,d0
	move.l (a0,d0.w),a0
	tst.w $ff0008
	beq.s PLAY_TRACK2

TrackDelay:
	move.l 12,d0

TrackDelay1:
	move.b $A10003,d1				
	move.b $00ff0000,d2				
	move.b d1,$00ff0000				
	move.b d1,$00ff0000				
	eor.b d1,d2					
	not.b d2					
	or.b d2,d1					
	cmp.b #$ff,d1					
	beq.s TrackDelay2				
	clr.w $ff0008					
	bra TEST_KEYS					

TrackDelay2:
	ror.l	#8,d2				
	ror.l #8,d2				
	rol.l #3,d2				
	subq.l #1,d0					
	bne.s TrackDelay1				

PLAY_TRACK2
	move.w #-1,$ff0008
	jsr VGM_INIT
	bsr SOUND_OFF
	bra NEXT_TRACK

SOUND_OFF:
	move.b #$80,d1
	move.b #$0f,d2

SOUND_OFF1:
	moveq #0,d0
	bsr YM2612_REGWRITE
	moveq #2,d0
	bsr YM2612_REGWRITE
	addq.b #1,d1
	cmp.b #$8f,d1
	bcs.s SOUND_OFF1
	move.b #$00,d0
	move.b #$28,d1
	moveq #0,d2
	jsr YM2612_REGWRITE
	moveq #1,d2
	jsr YM2612_REGWRITE
	moveq #2,d2
	jsr YM2612_REGWRITE
	moveq #4,d2
	jsr YM2612_REGWRITE
	moveq #5,d2
	jsr YM2612_REGWRITE
	moveq #6,d2
	jsr YM2612_REGWRITE
	move.b #%10011111,(a6)
	move.b #%10111111,(a6)
	move.b #%11011111,(a6)
	move.b #%11111111,(a6)
	rts

PRESSED_KEY:
	move.b d1,d4
	bsr SOUND_OFF
	adda.l #4,a7
	bra.s TEST_KEYS

UI_WAITKEY:
	move.b $A10003,d4
	move.b $ff0000,d2
	move.b d4,$ff0000
	eor.b d4,d2
	not.b d2
	or.b d2,d4
	cmp.b #$ff,d4
	beq.s UI_WAITKEY

TEST_KEYS:
	move.b d4,$ff0010
	btst #5,d4
	beq PLAY_TRACK
	not.b d4
	move d4,d0
	and #5,d0
	bne PREV_TRACK
	and #10,d4
	bne NEXT_TRACK
	bra UI_WAITKEY

