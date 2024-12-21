; Agon Console8
; Kaleidoscope
; Originally written for TRS-80 Model I
; Michael Keller 1980-2024
; Thanks to Richard Turnnidge for asm template

mos_sysvars:		EQU	08h	; return a pointer in IX to mos_sysvars
sysvar_keyascii:	EQU	05h	; 1: ASCII keycode, or 0 if no key is pressed
sysvar_rtc:		EQU	1Ah	; eight bytes of real-time clock data
sysvar_time:		EQU	00h	; system clock timer in centiseconds



	macro SET_MODE mode
	ld a, 22			; in BASIC: MODE x
	rst.lil $10
	ld a, mode			; mode to set
	rst.lil $10
	endmacro

	macro SET_GCOL mode, colour	; in BASIC: GCOL mode,colour
	ld a, 18
	rst.lil $10
	ld a,mode
	rst.lil $10
	ld a,colour
	rst.lil $10
	endmacro

	macro MOSCALL function
	ld	a, function
	rst.lil	$08
	endmacro

	macro VDPCALL
	rst.lil $18
	endmacro





.assume adl=1			; big memory mode
.org $40000			; load code here

	jp start_here		; jump to start of code

	.align 64		; MOS header
	.db "MOS",0,1

start_here:

	push af			; store all the registers
	push bc
	push de
	push ix
	push iy

; actual program starts here

	SET_MODE 18		; mono 1024x768
	SET_GCOL 4, 1		; line plot, invert colours
	ld hl, vdp_setup
	ld bc, end_vdp_setup-vdp_setup
	VDPCALL

; initialize values, handling H and L separately so that this will work in ADL mode without
; destroying the upper byte of HL(U)

	ld hl,(vertex_1x)
	ld h,$03
	ld l,$ff		; 1023 or $3ff
	ld (vertex_1x),hl
	ld hl,(vertex_1y)	; initialize values
	ld h,$00
	ld l,$00		; zero
	ld (vertex_1y),hl
	ld hl,(vertex_2x)	; initialize values
	ld h,$03
	ld l,$ff		; 1023 or $3ff
	ld (vertex_2x),hl
	ld hl,(vertex_2y)	; initialize values
	ld h,$02
	ld l,$ff		; 767 or $2ff
	ld (vertex_2y),hl
	ld hl,(vertex_3x)	; initialize values
	ld h,$00
	ld l,$00		; zero
	ld (vertex_3x),hl
	ld hl,(vertex_3y)	; initialize values
	ld h,$02
	ld l,$ff		; 767 or $2ff
	ld (vertex_3y),hl
	ld hl,(vertex_4x)	; initialize values
	ld h,$00
	ld l,$00		; zero
	ld (vertex_4x),hl
	ld hl,(vertex_4y)	; initialize values
	ld h,$00
	ld l,$00		; zero
	ld (vertex_4y),hl
	ld hl,(move_point_x)	; initialize values
	ld h,$00
	ld l,$00		; zero
	ld (move_point_x),hl
	ld hl,(move_point_y)	; initialize values
	ld h,$00
	ld l,$00		; zero
	ld (move_point_y),hl
;
;	ld d,4			; outer loop count
;	ld a, 01000000b 	; one-second delay
;
;start_loop:			; loop four seconds for physical display to sync with new screen mode
;
;	call multiPurposeDelay
;	dec d
;	jr nz, start_loop
;	jp end_here
;
;end_start_loop:

main_loop:

; if SPACE is pressed, exit, otherwise continue

	MOSCALL mos_sysvars
	ld a, (ix + sysvar_keyascii)
	cp 32			; SPACE pressed
	jp z, end_here

; set origin for this rectangle

	ld hl, (move_point_x)
	ld bc, (vertex_4x)
	ld h,b
	ld l,c
	ld (move_point_x),hl
	ld hl, (move_point_y)
	ld bc, (vertex_4y)
	ld h,b
	ld l,c
	ld (move_point_y),hl
	ld hl, vdp_move_point
	ld bc, end_move_point-vdp_move_point
	VDPCALL


	ld hl, vdp_draw_rect
	ld bc, end_vdp_draw_rect-vdp_draw_rect
	VDPCALL
	ld hl, vertex_1x
	ld bc, vertex_1x_dir
    	call process_counter_1023
	ld hl, vertex_1y
	ld bc, vertex_1y_dir
    	call process_counter_767

	ld hl, vertex_2x
	ld bc, vertex_2x_dir
    	call process_counter_1023
	ld hl, vertex_2y
	ld bc, vertex_2y_dir
    	call process_counter_767

	ld hl, vertex_3x
	ld bc, vertex_3x_dir
    	call process_counter_1023
	ld hl, vertex_3y
	ld bc, vertex_3y_dir
    	call process_counter_767

	ld hl, vertex_4x
	ld bc, vertex_4x_dir
    	call process_counter_1023
	ld hl, vertex_4y
	ld bc, vertex_4y_dir
    	call process_counter_767

	jp main_loop

end_here:
	SET_MODE 1
	pop iy
	pop ix
	pop de
	pop bc
	pop af
	ret

vdp_setup:
	.db 23,0,192,0		; disable logical screen scaling
end_vdp_setup:

vdp_move_point:
	.db 25,4		; move the plot point to x,y
move_point_x:
	.dw 0			
move_point_y:
	.dw 0			
end_move_point:

vdp_draw_rect:
	.db 25,5		; plot a line, inverting pixels as we go
vertex_1x:
	.dw 1023
vertex_1y:
	.dw 0
	.db 25,5		; plot a line, inverting pixels as we go
vertex_2x:
	.dw 1023
vertex_2y:
	.dw 767
	.db 25,5		; plot a line, inverting pixels as we go
vertex_3x:
	.dw 0
vertex_3y:
	.dw 767
	.db 25,5		; plot a line, inverting pixels as we go
vertex_4x:
	.dw 0
vertex_4y:
	.dw 0
end_vdp_draw_rect:
	
vertex_1x_dir:	.db 1		; start out decrementing
vertex_1y_dir:	.db 0		; start out incrementing
vertex_2x_dir:	.db 1		; start out decrementing
vertex_2y_dir:	.db 1		; start out decrementing
vertex_3x_dir:	.db 0		; start out incrementing
vertex_3y_dir:	.db 1		; start out decrementing
vertex_4x_dir:	.db 0		; start out incrementing
vertex_4y_dir:	.db 0		; start out incrementing


; With thanks to Richard Turnnidge

; multiPurposeDelay routine waits a fixed time, then returns
; arrive with A = the delay byte. One bit to be set only.
; eg. ld A, 00000100b

multiPurposeDelay:
	push bc
	ld b,a
	MOSCALL mos_sysvars

waitLoop:
	ld a, (ix + sysvar_time)
	and b
	ld c,a
	ld a, (oldTimeStamp)
	cp c
	jr z, waitLoop
	ld a,c
	ld (oldTimeStamp), a

	pop bc
	ret

oldTimeStamp:	.db 00h

;Bing Copilot helped write the mathematics part
;As we don't do anything that should affect the high-order byte of DE(U),
;loading and storing it shouldn't hurt the VDP commands.

process_counter_1023:
    LD A, (bc)  ; Load direction flag
    CP 0x00             ; Compare with 0 (up)
    JP Z, count_up_1023

count_down_1023:
    ld DE, (HL)         ; Load counter value into DE
    DEC DE              ; Decrement counter
	ld (hl), de
    LD A, D             ; Load high byte of DE into A
    OR E                ; Check if DE is zero
    JP NZ, return_1023  ; Return if not zero

    ; If zero, switch direction
    LD A, 0x00
    LD (bc), A
    JP return_1023

count_up_1023:
    ld DE, (HL)         ; Load counter value into DE
    INC DE              ; Increment counter
	ld (hl), de
    LD A, D             ; Load high byte of DE into A
    CP 0x04             ; Compare with 4 (1024)
    JP NZ, return_1023  ; Return if not reached 1024

    ; If reached max, switch direction
    LD A, 0x01
    LD (bc), A
    DEC DE              ; Decrement counter
    DEC DE              ; Decrement counter
	ld (hl), de
return_1023:
    RET

process_counter_767:
    LD A, (bc)  ; Load direction flag
    CP 0x00             ; Compare with 0 (up)
    JP Z, count_up_767

count_down_767:
    ld DE, (HL)         ; Load counter value into DE
    DEC DE              ; Decrement counter
	ld (hl), de
    LD A, D             ; Load high byte of DE into A
    OR E                ; Check if DE is zero
    JP NZ, return_767   ; Return if not zero

    ; If zero, switch direction
    LD A, 0x00
    LD (bc), A
    JP return_767

count_up_767:
    ld DE, (HL)         ; Load counter value into DE
    INC DE              ; Increment counter
	ld (hl), de
    LD A, D             ; Load high byte of DE into A
    CP 0x03             ; Compare with 3
    JP NZ, return_767   ; Return if high byte not 3
    LD A, E
    CP 0x00             ; Compare low byte with 0
    JP NZ, return_767   ; Return if not 768

    ; If reached max, switch direction
    LD A, 0x01
    LD (bc), A
    DEC DE              ; Decrement counter
    DEC DE              ; Decrement counter
	ld (hl), de
return_767:
    RET

; End of program

