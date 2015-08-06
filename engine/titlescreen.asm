; copy text of fixed length $b (like player name, rival name, mon names, ...)
CopyFixedLengthText: ; 42b1 (1:42b1)
	ld bc, $b
	jp CopyData

SetDefaultNamesBeforeTitlescreen: ; 42b7 (1:42b7)
	ld hl, NintenText
	ld de, wPlayerName
	call CopyFixedLengthText
	ld hl, SonyText
	ld de, W_RIVALNAME
	call CopyFixedLengthText
	xor a
	ld [hWY], a
	ld [wLetterPrintingDelayFlags], a
	ld hl, wd732
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, BANK(Music_TitleScreen)
	ld [wc0ef], a
	ld [wc0f0], a

DisplayTitleScreen: ; 42dd (1:42dd)
	call GBPalWhiteOut
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a
	xor a
	ld [hTilesetType], a
	ld [hSCX], a
	ld a, $40
	ld [hSCY], a
	ld a, $90
	ld [hWY], a
	call ClearScreen
	call DisableLCD
	call LoadFontTilePatterns
	ld hl, NintendoCopyrightLogoGraphics
	ld de, vTitleLogo2 + $100
	ld bc, $50
	ld a, BANK(NintendoCopyrightLogoGraphics)
	call FarCopyData2
	ld hl, GamefreakLogoGraphics
	ld de, vTitleLogo2 + $100 + $50
	ld bc, $90
	ld a, BANK(GamefreakLogoGraphics)
	call FarCopyData2
	ld hl, PokemonLogoGraphics
	ld de, vTitleLogo
	ld bc, $600
	ld a, BANK(PokemonLogoGraphics)
	call FarCopyData2          ; first chunk
	ld hl, PokemonLogoGraphics+$600
	ld de, vTitleLogo2
	ld bc, $100
	ld a, BANK(PokemonLogoGraphics)
	call FarCopyData2          ; second chunk
	ld hl, Version_GFX
IF DEF(_RED)
	ld de,vChars2 + $600
	ld bc,$50
ENDC
IF DEF(_BLUE)
	ld de,vChars2 + $600 + $10
	ld bc,$50 - $10
ENDC

	ld a, BANK(Version_GFX)
	call FarCopyDataDouble
	call ClearBothBGMaps

; place tiles for pokemon logo (except for the last row)
	coord hl, 2, 1
	ld a, $80
	ld de, SCREEN_WIDTH
	ld c, 6
.pokemonLogoTileLoop
	ld b, $10
	push hl
.pokemonLogoTileRowLoop ; place tiles for one row
	ld [hli], a
	inc a
	dec b
	jr nz, .pokemonLogoTileRowLoop
	pop hl
	add hl, de
	dec c
	jr nz, .pokemonLogoTileLoop

; place tiles for the last row of the pokemon logo
	coord hl, 2, 7
	ld a, $31
	ld b, $10
.pokemonLogoLastTileRowLoop
	ld [hli], a
	inc a
	dec b
	jr nz, .pokemonLogoLastTileRowLoop

	call DrawPlayerCharacter

; put a pokeball in the player's hand
	ld hl, wOAMBuffer + $28
	ld a, $74
	ld [hl], a

; place tiles for title screen copyright
	coord hl, 2, 17
	ld de, .tileScreenCopyrightTiles
	ld b, $10
.tileScreenCopyrightTilesLoop
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, .tileScreenCopyrightTilesLoop

	jr .next

.tileScreenCopyrightTiles ; 437f (1:437f)
	db $41,$42,$43,$42,$44,$42,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E ; ©'95.'96.'98 GAME FREAK inc.

.next
	call SaveScreenTilesToBuffer2
	call LoadScreenTilesFromBuffer2
	call EnableLCD
IF DEF(_RED)
	ld a,CHARMANDER ; which Pokemon to show first on the title screen
ENDC
IF DEF(_BLUE)
	ld a,SQUIRTLE ; which Pokemon to show first on the title screen
ENDC

	ld [wTitleMonSpecies], a
	call LoadTitleMonSprite
	ld a, (vBGMap0 + $300) / $100
	call TitleScreenCopyTileMapToVRAM
	call SaveScreenTilesToBuffer1
	ld a, $40
	ld [hWY], a
	call LoadScreenTilesFromBuffer2
	ld a, vBGMap0 / $100
	call TitleScreenCopyTileMapToVRAM
	ld b, $6
	call GoPAL_SET
	call GBFadeInFromWhite
	call GBPalNormal
	ld a, %11100100
	ld [rOBP0], a

; make pokemon logo bounce up and down
	ld bc, hSCY ; background scroll Y
	ld hl, .TitleScreenPokemonLogoYScrolls
.bouncePokemonLogoLoop
	ld a, [hli]
	and a
	jr z, .finishedBouncingPokemonLogo
	ld d, a
	cp -3
	jr nz, .skipPlayingSound
	ld a, SFX_INTRO_CRASH
	call PlaySound
.skipPlayingSound
	ld a, [hli]
	ld e, a
	call .ScrollTitleScreenPokemonLogo
	jr .bouncePokemonLogoLoop

.TitleScreenPokemonLogoYScrolls: ; 43db (1:43db)
; Controls the bouncing effect of the Pokemon logo on the title screen
	db -4,16  ; y scroll amount, number of times to scroll
	db 3,4
	db -3,4
	db 2,2
	db -2,2
	db 1,2
	db -1,2
	db 0      ; terminate list with 0

.ScrollTitleScreenPokemonLogo
; Scrolls the Pokemon logo on the title screen to create the bouncing effect
; Scrolls d pixels e times
	call DelayFrame
	ld a, [bc] ; background scroll Y
	add d
	ld [bc], a
	dec e
	jr nz, .ScrollTitleScreenPokemonLogo
	ret

.finishedBouncingPokemonLogo
	call LoadScreenTilesFromBuffer1
	ld c, 36
	call DelayFrames
	ld a, SFX_INTRO_WHOOSH
	call PlaySound

; scroll game version in from the right
	call PrintGameVersionOnTitleScreen
	ld a, SCREEN_HEIGHT_PIXELS
	ld [hWY], a
	ld d, 144
.scrollTitleScreenGameVersionLoop
	ld h, d
	ld l, 64
	call ScrollTitleScreenGameVersion
	ld h, 0
	ld l, 80
	call ScrollTitleScreenGameVersion
	ld a, d
	add 4
	ld d, a
	and a
	jr nz, .scrollTitleScreenGameVersionLoop

	ld a, vBGMap1 / $100
	call TitleScreenCopyTileMapToVRAM
	call LoadScreenTilesFromBuffer2
	call PrintGameVersionOnTitleScreen
	call Delay3
	call WaitForSoundToFinish
	ld a, MUSIC_TITLE_SCREEN
	ld [wc0ee], a
	call PlaySound
	xor a
	ld [wcc5b], a

; Keep scrolling in new mons indefinitely until the user performs input.
.awaitUserInterruptionLoop
	ld c, 200
	call CheckForUserInterruption
	jr c, .finishedWaiting
	call TitleScreenScrollInMon
	ld c, 1
	call CheckForUserInterruption
	jr c, .finishedWaiting
	callba TitleScreenAnimateBallIfStarterOut
	call TitleScreenPickNewMon
	jr .awaitUserInterruptionLoop

.finishedWaiting
	ld a, [wTitleMonSpecies]
	call PlayCry
	call WaitForSoundToFinish
	call GBPalWhiteOutWithDelay3
	call ClearSprites
	xor a
	ld [hWY], a
	inc a
	ld [H_AUTOBGTRANSFERENABLED], a
	call ClearScreen
	ld a, vBGMap0 / $100
	call TitleScreenCopyTileMapToVRAM
	ld a, vBGMap1 / $100
	call TitleScreenCopyTileMapToVRAM
	call Delay3
	call LoadGBPal
	ld a, [hJoyHeld]
	ld b, a
	and D_UP | SELECT | B_BUTTON
	cp D_UP | SELECT | B_BUTTON
	jp z, .doClearSaveDialogue
	jp MainMenu

.doClearSaveDialogue
	jpba DoClearSaveDialogue

TitleScreenPickNewMon: ; 4496 (1:4496)
	ld a, vBGMap0 / $100
	call TitleScreenCopyTileMapToVRAM

.loop
; Keep looping until a mon different from the current one is picked.
	call Random
	and $f
	ld c, a
	ld b, 0
	ld hl, TitleMons
	add hl, bc
	ld a, [hl]
	ld hl, wTitleMonSpecies

; Can't be the same as before.
	cp [hl]
	jr z, .loop

	ld [hl], a
	call LoadTitleMonSprite

	ld a, $90
	ld [hWY], a
	ld d, 1 ; scroll out
	callba TitleScroll
	ret

TitleScreenScrollInMon: ; 44c1 (1:44c1)
	ld d, 0 ; scroll in
	callba TitleScroll
	xor a
	ld [hWY], a
	ret

ScrollTitleScreenGameVersion: ; 44cf (1:44cf)
.wait
	ld a, [rLY]
	cp l
	jr nz, .wait

	ld a, h
	ld [rSCX], a

.wait2
	ld a, [rLY]
	cp h
	jr z, .wait2
	ret

DrawPlayerCharacter: ; 44dd (1:44dd)
	ld hl, PlayerCharacterTitleGraphics
	ld de, vSprites
	ld bc, $230
	ld a, BANK(PlayerCharacterTitleGraphics)
	call FarCopyData2
	call ClearSprites
	xor a
	ld [wPlayerCharacterOAMTile], a
	ld hl, wOAMBuffer
	ld de, $605a
	ld b, 7
.loop
	push de
	ld c, 5
.innerLoop
	ld a, d
	ld [hli], a ; Y
	ld a, e
	ld [hli], a ; X
	add 8
	ld e, a
	ld a, [wPlayerCharacterOAMTile]
	ld [hli], a ; tile
	inc a
	ld [wPlayerCharacterOAMTile], a
	inc hl
	dec c
	jr nz, .innerLoop
	pop de
	ld a, 8
	add d
	ld d, a
	dec b
	jr nz, .loop
	ret

ClearBothBGMaps: ; 4519 (1:4519)
	ld hl, vBGMap0
	ld bc, $400 * 2
	ld a, " "
	jp FillMemory

LoadTitleMonSprite: ; 4524 (1:4524)
	ld [wcf91], a
	ld [wd0b5], a
	coord hl, 5, 10
	call GetMonHeader
	jp LoadFrontSpriteByMonIndex

TitleScreenCopyTileMapToVRAM: ; 4533 (1:4533)
	ld [H_AUTOBGTRANSFERDEST + 1], a
	jp Delay3

LoadCopyrightAndTextBoxTiles: ; 4538 (1:4538)
	xor a
	ld [hWY], a
	call ClearScreen
	call LoadTextBoxTilePatterns

LoadCopyrightTiles: ; 4541 (1:4541)
	ld de, NintendoCopyrightLogoGraphics
	ld hl, $8800
	ld bc, (BANK(NintendoCopyrightLogoGraphics) << 8) + $29
	call CopyVideoData
	coord hl, 2, 5
	ld de, CopyrightTextString
	jp PlaceString

CopyrightTextString: ; 4556 (1:4556)
	db   $80,$81,$82,$81,$83,$81,$84,$7F,$85,$86,$87,$88,$89,$8A             ; ©'95.'96.'98 Nintendo
	next $80,$81,$82,$81,$83,$81,$84,$7F,$8B,$8C,$8D,$8E,$8F,$90,$91,$92     ; ©'95.'96.'98 Creatures inc.
	next $80,$81,$82,$81,$83,$81,$84,$7F,$a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$a8 ; ©'95.'96.'98 GAME FREAK inc.
	next $80,$93,$94,$95,$7f,$7f,$7f,$7f,$96,$97,$98,$99,$9a,$9b,$9c ; ©2015 ShantyTown
	db   "@"

INCLUDE "data/title_mons.asm"

; prints version text (red, blue)
PrintGameVersionOnTitleScreen: ; 4598 (1:4598)
	coord hl, 8, 8
	ld de, VersionOnTitleScreenText
	jp PlaceString

; these point to special tiles specifically loaded for that purpose and are not usual text
VersionOnTitleScreenText: ; 45a1 (1:45a1)
	db $60,$61,$62,$63,$64,$65,"@" ; "Thief Red"

