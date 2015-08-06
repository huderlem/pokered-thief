PlayIntro: ; 41682 (10:5682)
	xor a
	ld [hJoyHeld], a
	inc a
	ld [H_AUTOBGTRANSFERENABLED], a
	call PlayShootingStar
	xor a
	ld [hSCX], a
	ld [H_AUTOBGTRANSFERENABLED], a
	call ClearSprites
	call DelayFrame
	ret

IntroClearScreen: ; 417f0 (10:57f0)
	ld hl, vBGMap1
	ld bc, $240
	jr IntroClearCommon

IntroClearMiddleOfScreen: ; 417f8 (10:57f8)
; clear the area of the tile map between the black bars on the top and bottom
	coord hl, 0, 4
	ld bc, SCREEN_WIDTH * 10

IntroClearCommon: ; 417fe (10:57fe)
	ld [hl], $1
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, IntroClearCommon
	ret

IntroPlaceBlackTiles: ; 41807 (10:5807)
	ld a, $c1
.loop
	ld [hli], a
	dec c
	jr nz, .loop
	ret

IntroCopyTiles: ; 4183f (10:583f)
	coord hl, 13, 7

CopyTileIDsFromList_ZeroBaseTileID: ; 41842 (10:5842)
	ld c, 0
	predef_jump CopyTileIDsFromList

PlayMoveSoundB: ; 41849 (10:5849)
; unused
	predef GetMoveSoundB
	ld a, b
	jp PlaySound

LoadShantyTownIntroGfx:
	ld hl, ShantyTownIntro
	ld de, $8800
	ld bc, $450
	ld a, Bank(ShantyTownIntro)
	jp FarCopyData2

PlayShootingStar: ; 4188a (10:588a)
	ld b, $c
	call GoPAL_SET
	callba LoadCopyrightAndTextBoxTiles
	ld a, $e4
	ld [rBGP], a
	ld c, 180
	call DelayFrames
	call ClearScreen
	call DisableLCD
	xor a
	ld [W_CUROPPONENT], a
	call IntroDrawBlackBars
	call LoadShantyTownIntroGfx
	call EnableLCD
	ld hl, rLCDC
	res 5, [hl]
	set 3, [hl]
	ld c, 64
	call DelayFrames
	callba PlayShantyTownAnimation
	push af
	pop af
.next
	ld a, BANK(Music_IntroBattle)
	ld [wc0ef], a
	ld [wc0f0], a
	ld a, MUSIC_INTRO_BATTLE
	ld [wc0ee], a
	;call PlaySound
	call GBFadeOutToWhite
	call IntroClearMiddleOfScreen
	call ClearSprites
	jp Delay3

IntroDrawBlackBars: ; 418e9 (10:58e9)
; clear the screen and draw black bars on the top and bottom
	call IntroClearScreen
	coord hl, 0, 0
	ld c, SCREEN_WIDTH * 4
	call IntroPlaceBlackTiles
	coord hl, 0, 14
	ld c, SCREEN_WIDTH * 4
	call IntroPlaceBlackTiles
	ld hl, vBGMap1
	ld c, $80
	call IntroPlaceBlackTiles
	ld hl, vBGMap1 + $1c0
	ld c, $80
	jp IntroPlaceBlackTiles

EmptyFunc4: ; 4190c (10:590c)
	ret

GameFreakIntro: ; 41959 (10:5959)
	INCBIN "gfx/gamefreak_intro.2bpp"
	INCBIN "gfx/gamefreak_logo.2bpp"
	ds $10 ; blank tile

FightIntroBackMon: ; 41a99 (10:5a99)
	INCBIN "gfx/intro_fight.2bpp"

FightIntroFrontMon: ; 42099 (10:6099)

ShantyTownIntro:
	INCBIN "gfx/shantytown-intro.2bpp"
