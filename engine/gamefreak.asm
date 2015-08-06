InitShantyTownIntroAnimation: ; 70000 (1c:4000)
	ld b, 6
	call GoPAL_SET
	ld a, %11100100
 	ld [rOBP0], a ; $FF00+$48
 	ld [rOBP1], a ; $FF00+$49
 	ld hl, wOAMBuffer ; y position
	ld bc, 4
	ld a, $50
	ld [hl], a
	add hl, bc
	ld [hl], a
	add hl, bc
	add 8
	ld [hl], a
	add hl, bc
	ld [hl], a
	ret

PlayShantyTownAnimation: ; 70044 (1c:4044)
	ld a, SFX_SHOOTING_STAR  ; if you remove/change this line, it causes a seg fault. c'mon, rgbds...
	call InitShantyTownIntroAnimation
	; Roll pokeball to the right
	xor a
	ld [wWhichPokemon], a ; ball animation frame id
	ld [W_NUMSAFARIBALLS], a ; frame counter
	ld a, 8
	ld [W_FIRST_NEW_BYTE], a ; ball x pixel position
.rollRightLoop
	call LoadSpinningBallOAMTiles
	call MoveSpinningBall
	call RevealLetter
	call DelayFrame
	ld a, [W_NUMSAFARIBALLS]
	inc a
	ld [W_NUMSAFARIBALLS], a
	bit 0, a
	jr z, .moveBall
	; advance frame
	ld a, [wWhichPokemon]
	inc a
	cp 8
	jr c, .noOverflow
	xor a
.noOverflow
	ld [wWhichPokemon], a
.moveBall
	ld a, $be
 	call PlaySound
 	ld a, [W_FIRST_NEW_BYTE]
	add 2
	ld [W_FIRST_NEW_BYTE], a
	cp 180
	jr c, .rollRightLoop
.doneRollingRight
	ld c, $20
	call DelayFrames
	; roll pokeball to the left
	ld hl, wOAMBuffer ; y position
	ld bc, 4
	ld a, $60
	ld [hl], a
	add hl, bc
	ld [hl], a
	add hl, bc
	add 8
	ld [hl], a
	add hl, bc
	ld [hl], a
 	xor a
 	ld [wWhichPokemon], a ; ball animation frame id
	ld [W_NUMSAFARIBALLS], a ; frame counter
	ld a, 180
	ld [W_FIRST_NEW_BYTE], a ; ball x pixel position
	ld a, $bd
	call PlaySound
.rollLeftLoop
	call LoadSpinningBallOAMTiles
	call MoveSpinningBall
	call RevealPresentsLetter
	call DelayFrame
	ld a, [W_NUMSAFARIBALLS]
	inc a
	ld [W_NUMSAFARIBALLS], a
	; advance frame
	ld a, [wWhichPokemon]
	dec a
 	cp $ff
 	jr nz, .noOverflow2
	ld a, 7
.noOverflow2
	ld [wWhichPokemon], a
	ld a, [W_FIRST_NEW_BYTE]
	sub 4
	ld [W_FIRST_NEW_BYTE], a
	cp $f0
	jr c, .rollLeftLoop
	; done
	ld c, $30
	call DelayFrames
	ret

LoadSpinningBallOAMTiles:
	ld a, [wWhichPokemon]
	add a ; multiply by 2
	ld b, a
	ld a, $80
	add b
	ld bc, 4
	ld hl, wOAMBuffer + 2 ; tile id
	ld [hl], a
	add hl, bc
	inc a
	ld [hl], a
	add hl, bc
	add $f
	ld [hl], a
	add hl, bc
	inc a
	ld [hl], a
 	ret

MoveSpinningBall:
	ld a, [W_FIRST_NEW_BYTE]
	ld hl, wOAMBuffer + 1 ; x position
	sub 8
	ld bc, 4
	ld [hl], a
	add hl, bc
	add 8
	ld [hl], a
	add hl, bc
	sub 8
	ld [hl], a
	add hl, bc
	add 8
	ld [hl], a
	ret

RevealLetter:
	ld a, [W_FIRST_NEW_BYTE] ; x position
	cp $20
	ret c
	sub $20
	cp $68
	ret nc
	srl a
	srl a
	srl a
	ld c, a
	jp DrawLetterInShantyTown

DrawLetterInShantyTown:
; c = letter id
	ld a, c
	add a
	add c ; multiply by three
	ld c, a
	ld b, 0
	ld hl, ShantyTownLetters
	add hl, bc ; hl points to entry in ShantyTownLetters
.waitForHBlank
    ld a, [$ff41]
    and $3
    jr nz, .waitForHBlank
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [hl]
    ld [de], a
    ld hl, $0014
    add hl, de
    add $10
    ld [hl], a
    ret

ShantyTownLetters:
	dw $c443
	db $a0

	dw $c444
	db $a1

	dw $c445
	db $a2

	dw $c446
	db $a3

	dw $c447
	db $a4

	dw $c448
	db $a5

	dw $c449
	db $a6

	dw $c44a
	db $a7

	dw $c44b
	db $a8

	dw $c44c
	db $a9

	dw $c44d
	db $aa

	dw $c44e
	db $ab

	dw $c44f
	db $ac

RevealPresentsLetter:
	ld a, [W_FIRST_NEW_BYTE] ; x position
	cp $56
 	ret c

	sub $56
	cp $30
	ret nc
	srl a
	srl a
	srl a
	ld c, a
	jp DrawLetterInPresents

DrawLetterInPresents:
	; c = letter id
	ld a, c
	add a
	add c ; multiply by three
	ld c, a
	ld b, 0
	ld hl, PresentsLetters
	add hl, bc ; hl points to entry in PresentsLetters
.waitForHBlank
    ld a, [$ff41]
    and $3
    jr nz, .waitForHBlank
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    ld a, [hl]
    ld [de], a
    ret

PresentsLetters:
	dw $c472
	db $ad

	dw $c473
	db $ae

	dw $c474
	db $af

	dw $c475
	db $bd

	dw $c476
	db $be

	dw $c477
	db $bf
