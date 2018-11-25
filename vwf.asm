
; ==============================================================================

    ; *$74440-$74447 JUMP LOCATION (LONG)
    Messaging_Text:
    {
        ; Module 0x0E.0x02 (dialogue or "text" mode)
        
        PHB : PHK : PLB
        
        JSR Text_Local
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$74448-$74454 LOCAL
    Text_Local:
    {
        LDA $1CD8
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Text_Initialize
        dw Text_Render
        dw Text_PostDeathSaveOptions
    }

; ==============================================================================

    ; *$74455-$74482 JUMP LOCATION
    Text_PostDeathSaveOptions:
    {
        ; "Load the save & continue, save & quit, do not save or quit" dialog box
        ; that appears after you've died and the game wants you to decide what to do next.
        LDA.b #$03 : STA $1CF0
        LDA.b #$00 : STA $1CF1
        
        LDX.b #$00
        
        JSR Text_Initialize.initModuleStateLoop
        
        ; Manually sets the .... position? Window type?
        LDA.b #$E8 : STA $1CD2
        LDA.b #$61 : STA $1CD3
        LDA.b #$02 : STA $1CD4
        
        ; The first call sets up the border, the second sets up the vwf tilemap
        ; the third, fourth, and fifth calls render one line of text each, with the
        ; fifth doing clean up. could be wrong about all this, but best guess so far...
        JSR Text_Render
        JSR Text_Render
        JSR Text_Render
        JSR Text_Render
        JSR Text_Render
        
        RTS
    }

; ==============================================================================

    ; *$74483-$744C8 JUMP LOCATION
    Text_Initialize:
    {
        ; (the increment into the next sub-submodule is obscured a bit)
        
        ; Load the characters for the text message and zero out some buffers
        ; also sets up the frame, if necessary
        
        ; Module 0x0E.0x02.0x00
        
        ; Are we in History mode?
        LDA $10 : CMP.b #$14 : BNE .notInAtractMode
        
        JSL Attract_ResetHudPalettes_4_and_5
    
    .notInAttractMode
    
        ; This is is always called - not the best use of time since we're not
        ; always in attract mode. What gives?
        JSL Attract_DecompressStoryGfx
        
        LDX.b #$00
    
    .initModuleStateLoop
    
        ; Assign predetermined initial states for many of the text variables
        ; It should be noted that this is the mechanism that increments $1CD8 into the next submodule :/
        ; (It would be hard to spot unless you examined the above array in a hex editor)
        LDA Text_InitializationData, X : STA $1CD0, X
        
        INX : CPX.b #$20 : BCC .initModuleStateLoop
        
        JSR Text_InitVwfState
        JSR Text_SetDefaultWindowPos
        
        REP #$30
        
        ; (why is this all manually done? Probably due to using an assembler and not a compiler.
        ; This gives us a hint that some of these were probably compile time constants which could be
        ; considered variables in some sense.)
        LDA.w #$387F : AND.w #$FF00 : ORA.w #$0180 : STA $1CE2
        
        SEP #$30
        
        JSR Text_LoadCharacterBuffer
        JSR VWF_ClearBuffer
        
        REP #$30
        
        STZ $1CD9
        
        SEP #$30
        
        ; Lets NMI routine know to copy $7F0000[0x7E0] to the BG2 tilemap
        LDA.b #$02 : STA $17 : STA $0710
        
        RTS
    }

; ==============================================================================

    ; *$744C9-$744E1 LOCAL
    Text_InitVwfState:
    {
        STZ $0722
        STZ $0723
        STZ $0720
        STZ $0721
        STZ $0724
        STZ $0725
        STZ $0726
        STZ $0727
        
        RTS
    }

; ==============================================================================

    ; *$744E2-$74546 LOCAL
    Text_LoadCharacterBuffer:
    {
        REP #$30
        
        ; X = $1CF0 * 3
        LDA $1CF0 : ASL A : ADC $1CF0 : TAX
        
        ; Load the address for the text's data from WRAM.
        LDA $7F71C0, X : STA $04
        LDA $7F71C2, X : STA $06
        
        ; Initialize the beginning of the character buffer to the "terminate"
        ; message, in case we load no actual characters
        LDA.w #$7F7F : STA $7F1200
        
        LDY.w #$0000 : TYX : STY $1CD9 : STY $1CDD
        
        SEP #$20
    
    .nextByte
    
        ; Load the first byte of data
        ; Negative byte
        LDA [$04], Y : BMI .dictionarySequence
        CMP.b #$67   : BCS .commandByte
        
        ; Put text to buffer
        STA $7F1200, X
        
        INY : STY $1CDD
        INX : STX $1CD9
        
        BRA .nextByte
    
    .commandByte
    
        ; Terminator byte = bye bye ;)
        CMP.b #$7F : BEQ .endOfMessage
        
        JSR Text_Command
        
        LDX $1CD9
        LDY $1CDD
        
        BRA .nextByte
    
    .dictionarySequence
    
        ; Dictionary compression for partial words
        SUB.b #$88
        
        JSR Text_DictionarySequence
        
        LDX $1CD9
        LDY $1CDD
        
        BRA .nextByte
    
    .endOfMessage
    
        LDA.b #$7F : STA $7F1200, X
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$74547-$74580 LOCAL
    Text_Command:
    {
        SEP #$31
        
        SBC.b #$67
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        ; Text Routines 1 (preparation)
        ; These routines are used for setting up the $7F1200[0x800] buffer that will later
        ; be used to generate the actual VWF (variable width font) text as well as handle commands
        
        dw Text_IgnoreCommand        ; 0x67 [NextPic] command
        dw Text_IgnoreCommand        ; 0x68 [Choose] command
        dw Text_IgnoreCommand        ; 0x69 [Item] command (for waterfall of wishing)
        dw Text_WritePlayerName      ; 0x6A [Name] command (insert's player's name)
        dw Text_SetWindowType        ; 0x6B [Window XX] command (takes next byte as argument)
        dw Text_WritePreloadedNumber ; 0x6C [Number XX] command (takes next byte as argument)
        dw Text_SetWindowPos         ; 0x6D [Position XX] command (takes next byte as argument)
        dw Text_IgnoreParamCommand   ; 0x6E [ScrollSpd XX] command (takes next byte as argument)
        dw Text_IgnoreCommand        ; 0x6F [SelChng] command
        dw Text_IgnoreCommand        ; 0x70 [Crash] in Hyrule Magic (don't use)
        dw Text_IgnoreCommand        ; 0x71 [Choose2]
        dw Text_IgnoreCommand        ; 0x72 [Choose3]
        dw Text_IgnoreCommand        ; 0x73 [Scroll] command
        dw Text_IgnoreCommand        ; 0x74 [1] command
        dw Text_IgnoreCommand        ; 0x75 [2] command
        dw Text_IgnoreCommand        ; 0x76 [3] command
        dw Text_SetColor             ; 0x77 [Color XX] command (takes next byte as argument)
        dw Text_IgnoreParamCommand   ; 0x78 [Wait XX] command (takes next byte as argument)
        dw Text_IgnoreParamCommand   ; 0x79 [Sound XX] command (takes next byte as argument)
        dw Text_IgnoreParamCommand   ; 0x7A [Speed XX] command (takes next byte as argument)
        dw Text_IgnoreCommand        ; 0x7B [Command 7B]
        dw Text_IgnoreCommand        ; 0x7C [Command 7C]
        dw Text_IgnoreCommand        ; 0x7D [Command 7D]
        dw Text_IgnoreCommand        ; 0x7E [waitkey] command
        dw Text_IgnoreCommand        ; 0x7F [End] stop command for the whole message
    }

; ==============================================================================

    ; *$74581-$74597 JUMP LOCATION
    Text_IgnoreCommand:
    {
        REP #$10
        
        LDX $1CD9
        LDY $1CDD
        
        LDA [$04], Y : STA $7F1200, X
        
        INY
        INX
        
        STX $1CD9
        STY $1CDD
        
        RTS
    }

; ==============================================================================

    ; *$74598-$745B2 JUMP LOCATION
    Text_IgnoreParamCommand:
    {
        REP #$30
        
        LDX $1CD9
        LDY $1CDD
        
        LDA [$04], Y : STA $7F1200, X
        
        INY #2
        INX #2
        
        STX $1CD9
        STY $1CDD
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$745B3-$74638 JUMP LOCATION
    Text_WritePlayerName:
    {
        ; [Name] command (setup)
        ; In this routine $08[6] contains the character values for the player's name
        ; This routine is a tad sloppy in how it does things, I might add. I'd write it
        ; somewhat differently on my own.
        
        REP #$30
        
        ; Check which file is active
        LDA $701FFE : TAX
        
        ; Get its offset in sram
        LDA $00848A, X : TAX
        
        LDY.w #$0000
    
    .nextCharacter
    
        LDA $7003D9, X : PHA : AND.w #$000F : STA $0008, Y
        
        PLA : LSR A : AND.w #$FFF0 : ORA $0008, Y : STA $0008, Y
        
        INX #2
        
        INY : CPY.w #$0006 : BCC .nextCharacter
        
        SEP #$20
        
        LDY.w #$0000
    
    .nextCharacter2
    
        ; Now that the name is in memory check it for spaces
        LDA $0008, Y
        
        JSR Text_FilterPlayerNameCharacters
        
        STA $0008, Y
        
        INY : CPY.w #$0006 : BCC .nextCharacter2
        
        REP #$30
        
        ; Target Buffer position ($1CD9), 
        LDA $1CD9 : ADD.w #$0006 : TAX
        
        ; Source Buffer position ($1CDD)
        INC $1CDD
        
        SEP #$20
        
        ; Write player name to the text buffer
        LDA $08 : STA $7F11FA, X
        LDA $09 : STA $7F11FB, X
        LDA $0A : STA $7F11FC, X
        LDA $0B : STA $7F11FD, X
        LDA $0C : STA $7F11FE, X
        LDA $0D : STA $7F11FF, X
        
        LDY.w #$0005
    
    .nextCharacter3
    
        ; Now the length for spaces
        LDA $0008, Y : CMP.b #$59 : BNE .notSpaceCharacter
        
        DEX
        
        DEY : BPL .nextCharacter3
    
    .notSpaceCharacter
    
        STX $1CD9
        
        RTS
    }

; ==============================================================================

    ; *$74639-$74656 LOCAL
    Text_FilterPlayerNameCharacters:
    {
        CMP.b #$5F : BCC .alpha
        CMP.b #$76 : BCS .beta
        CMP.b #$5F : BNE .gamma
        
        LDA.b #$08
    
    .gamma
    
        CMP.b #$60 : BNE .delta
        
        LDA.b #$22
    
    .delta
    
        CMP.b #$61 : BNE .alpha
        
        LDA.b #$3E
    
    .alpha
    
        RTS
    
    .beta
    
        SBC.b #$42
        
        RTS
    }

; ==============================================================================

    ; *$74657-$74666 JUMP LOCATION
    Text_SetWindowType:
    {
        ; [Window XX] Command (preparation)
        
        REP #$10
        
        LDY $1CDD : INY
        
        ; This modifies the second level module controller, but ... why?
        ; Maybe that changes which window type is displayed by changing the pointer to different code?
        ; You could, in theory, end the message with this command by setting it to 4, crash the game by setting it to
        ; 5 or more, and.... this makes my head hurt, honestly. Probably could use a rewrite to be more safe!!!
        LDA [$04], Y : STA $1CD4
        
        ; $1CDD is incremented by two bytes b/c this command has an argument
        INY : STY $1CDD
        
        RTS
    } 

; ==============================================================================

    ; *$74667-$7469B JUMP LOCATION
    Text_WritePreloadedNumber:
    {
        ; [Number XX] Command
        ; Writes one of the four preloaded numerical parameters
        ; the programmer was supposed to have stored before entering text mode
        ; This command isn't very safe in the sense that it doesn't validate
        ; the input
        
        REP #$30
        
        LDX $1CD9
        LDY $1CDD
        
        ; The lower byte of this load is the command byte, and the upper is the parameter to
        ; use to determine the number to write.
        LDA [$04], Y
        
        INY #2 : STY $1CDD
        
        XBA : AND.w #$00FF : LSR A
        
        PHP
        
        TAY
        
        ; Since the expected parameter is only 0 to 3 inclusive, this means
        ; that Y here is expected to be 0 or 1, grabbing one of two bytes
        ; further down, one of two nybbles will be selected from one of these two bytes
        LDA $1CF2, Y
        
        PLP : BCC .useLowerNybble
        
        LSR #4
    
    .useLowerNybble
    
        AND.w #$000F : ADD.w #$0004 : ORA.w #$0030 : STA $7F1200, X
        
        INX : STX $1CD9
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$7469C-$746B5 JUMP LOCATION
    Text_SetWindowPos:
    {
        ; [Position XX]
        ; This routine is dangerous too, what the hell is with these preparation routines
        ; and them not validating their input, even when it would incur virtually no extra
        ; performance hit.
        
        
        REP #$30
        
        LDY $1CDD : INY
        
        LDA [$04], Y : AND.w #$00FF : ASL A : TAX
        
        ; Chooses from one of two preset window positions (high or low, basically)
        LDA Text_Positions, X : STA $1CD2
        
        INY : STY $1CDD
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$746B6-$746D9 JUMP LOCATION
    Text_SetColor:
    {
        ; [Color XX]
        ; And it's worth noting that this stage (the loading process)
        ; is the only time [Color XX] does any meaningful work
        ; The command it leaves in the $7F1200[0x800] buffer doesn't work as they probably
        ; realized it would be difficult to make work anyway
        
        REP #$30
        
        LDY $1CDD
        
        ; Why are they ANDing with 0x3c00? That would seem to give the illusion that you
        ; could specify the priority bit, but the code below begs otherwise, unless it was something
        ; that was determined at compile time. Either way, the parameter is probably only good from 0 to 7,
        ; but feel free to use 8 to 0x0f if you like wasting bits *grumble*...
        LDA [$04], Y : ASL #2 : AND.w #$3C00 : STA $00
        
        ; This just preserves the priority bit i.e., A = 0x2000
        ; then provides it with a starting CHR of 0x0180, with palette, hflip, and vflip all zero.
        ; The palette provided by [Color XX] here XX ranges from 0 to 7, is then inserted
        ; $1CE2 is therefore the template tilemap entry for all text characters
        LDA.w #$387F : AND.w #$E300 : ORA.w #$0180 : ORA $00 : STA $1CE2
        
        INY #2 : STY $1CDD
        
        SEP #$20
        
        RTS
    }

; ==============================================================================

    ; *$746DA-$74702 LOCAL
    Text_DictionarySequence:
    {
        ; Handle dictionary compressed word fragments
        ; Generally speaking its arguments are 0x80 and above but have had 0x88 subtracted from them
        ; This would produce something like 0x00 to 0x78 as well as 0xF8 to 0xFF
        
        REP #$30
        
        INC $1CDD ; Position in the $7F1200, X buffer >_>
        
        LDX $1CD9 : ASL A : AND.w #$00FF : TAY
        
        LDA Text_DictionaryPointers+2, Y : STA $00
        LDA Text_DictionaryPointers, Y   : TAY
        
        SEP #$20
    
    .nextCharacter
    
        LDA $0000, Y : STA $7F1200, X
        
        INX
        
        INY : CPY $00 : BCC .nextCharacter
        
        STX $1CD9
        
        RTS
    }

; ==============================================================================

    ; $74703-$747C6 DATA ; dictionary pointers
    DictionaryPointers:
    {
        dw DictionaryEntries_fourSpaces
        dw DictionaryEntries_threeSpaces
        dw DictionaryEntries_twoSpaces
        dw DictionaryEntries_possessive
        dw DictionaryEntries_and_space
        dw DictionaryEntries_are_space
        dw DictionaryEntries_all_space
        dw DictionaryEntries_ain
        dw DictionaryEntries_and_no_space
        dw DictionaryEntries_at_space
        dw DictionaryEntries_ast
        dw DictionaryEntries_an
        dw DictionaryEntries_at_no_space
        dw DictionaryEntries_ble
        dw DictionaryEntries_ba
        dw DictionaryEntries_be
        dw DictionaryEntries_bo
        dw DictionaryEntries_can_space
        dw DictionaryEntries_che
        dw DictionaryEntries_com
        dw DictionaryEntries_ck
        dw DictionaryEntries_des
        dw DictionaryEntries_di
        dw DictionaryEntries_do
        dw DictionaryEntries_en_space
        dw DictionaryEntries_er_space
        dw DictionaryEntries_ear
        dw DictionaryEntries_ent
        dw DictionaryEntries_ed_space
        dw DictionaryEntries_en_no_space
        dw DictionaryEntries_er_no_space
        dw DictionaryEntries_ev
        dw DictionaryEntries_for
        dw DictionaryEntries_fro
        dw DictionaryEntries_give_space
        dw DictionaryEntries_get
        dw DictionaryEntries_go
        dw DictionaryEntries_have
        dw DictionaryEntries_has
        dw DictionaryEntries_her
        dw DictionaryEntries_hi
        dw DictionaryEntries_ha
        dw DictionaryEntries_ight_space
        dw DictionaryEntries_ing_space
        dw DictionaryEntries_in
        dw DictionaryEntries_is
        dw DictionaryEntries_it
        dw DictionaryEntries_just
        dw DictionaryEntries_know
        dw DictionaryEntries_ly_space
        dw DictionaryEntries_la
        dw DictionaryEntries_lo
        dw DictionaryEntries_man
        dw DictionaryEntries_ma
        dw DictionaryEntries_me
        dw DictionaryEntries_mu
        dw DictionaryEntries_nt_contraction_space
        dw DictionaryEntries_non
        dw DictionaryEntries_not
        dw DictionaryEntries_open
        dw DictionaryEntries_ound
        dw DictionaryEntries_out_space
        dw DictionaryEntries_of
        dw DictionaryEntries_on
        dw DictionaryEntries_or
        dw DictionaryEntries_per_not_asm
        dw DictionaryEntries_ple
        dw DictionaryEntries_pow
        dw DictionaryEntries_pro
        dw DictionaryEntries_re_space
        dw DictionaryEntries_re_no_space
        dw DictionaryEntries_some
        dw DictionaryEntries_se
        dw DictionaryEntries_sh
        dw DictionaryEntries_so
        dw DictionaryEntries_st
        dw DictionaryEntries_ter_space
        dw DictionaryEntries_thin
        dw DictionaryEntries_ter
        dw DictionaryEntries_tha
        dw DictionaryEntries_the
        dw DictionaryEntries_thi
        dw DictionaryEntries_to
        dw DictionaryEntries_tr
        dw DictionaryEntries_up
        dw DictionaryEntries_ver
        dw DictionaryEntries_with
        dw DictionaryEntries_wa
        dw DictionaryEntries_we
        dw DictionaryEntries_wh
        dw DictionaryEntries_wi
        dw DictionaryEntries_you
        dw DictionaryEntries_Her
        dw DictionaryEntries_Tha
        dw DictionaryEntries_The
        dw DictionaryEntries_Thi
        dw DictionaryEntries_You
        dw DictionaryEntries_endOfTable
    }
    
; ==============================================================================

    ; $747C7-$748D8 DATA ; dictionary data
    DictionaryEntries:
    {
    
    .fourSpaces
        db $59, $59, $59, $59
    
    .threeSpaces
        db $59, $59, $59
    
    .twoSpaces
        db $59, $59
    
    .possessive ; "'s "
        db $51, $2C, $59
    
    .and_space
        db $1A, $27, $1D, $59
    
    .are_space
        db $1A, $2B, $1E, $59
    
    .all_space
        db $1A, $25, $25, $59
    
    .ain ; whatever the hell that is...
        db $1A, $22, $27
    
    .and_no_space
        db $1A, $27, $1D
    
    .at_space
        db $1A, $2D, $59
    
    .ast
        db $1A, $2C, $2D
    
    .an
        db $1A, $27
    
    .at_no_space
        db $1A, $2D
    
    .ble
        db $1B, $25, $1E
    
    .ba
        db $1B, $1A
    
    .be
        db $1B, $1E
    
    .bo
        db $1B, $28
    
    .can_space
        db $1C, $1A, $27, $59
    
    .che
        db $1C, $21, $1E
    
    .com
        db $1C, $28, $26
    
    .ck
        db $1C, $24
    
    .des
        db $1D, $1E, $2C
    
    .di
        db $1D, $22
    
    .do
        db $1D, $28
    
    .en_space
        db $1E, $27, $59
    
    .er_space
        db $1E, $2B, $59
    
    .ear
        db $1E, $1A, $2B
    
    .ent
        db $1E, $27, $2D
    
    .ed_space
        db $1E, $1D, $59
    
    .en_no_space
        db $1E, $27
    
    .er_no_space
        db $1E, $2B
    
    .ev
        db $1E, $2F
    
    .for
        db $1F, $28, $2B
    
    .fro    
        db $1F, $2B, $28
    
    .give_space
        db $20, $22, $2F, $1E, $59
    
    .get
        db $20, $1E, $2D
    
    .go
        db $20, $28
    
    .have
        db $21, $1A, $2F, $1E
    
    .has
        db $21, $1A, $2C
    
    .her
        db $21, $1E, $2B
    
    .hi
        db $21, $22
    
    .ha
        db $21, $1A
    
    .ight_space
        db $22, $20, $21, $2D, $59
    
    .ing_space
        db $22, $27, $20, $59
    
    .in
        db $22, $27
    
    .is
        db $22, $2C
    
    .it
        db $22, $2D
    
    .just
        db $23, $2E, $2C, $2D
    
    .know
        db $24, $27, $28, $30
    
    .ly_space
        db $25, $32, $59
    
    .la
        db $25, $1A
    
    .lo
        db $25, $28
    
    .man
        db $26, $1A, $27
    
    .ma
        db $26, $1A
    
    .me
        db $26, $1E
    
    .mu
        db $26, $2E
    
    .nt_contraction_space
        db $27, $51, $2D, $59
    
    .non
        db $27, $28, $27
    
    .not
        db $27, $28, $2D
    
    .open
        db $28, $29, $1E, $27
    
    .ound
        db $28, $2E, $27, $1D
    
    .out_space
        db $28, $2E, $2D, $59
    
    .of
        db $28, $1F
    
    .on
        db $28, $27
    
    .or
        db $28, $2B
    
    .per_not_asm
        db $29, $1E, $2B
    
    .ple
        db $29, $25, $1E
    
    .pow
        db $29, $28, $30
    
    .pro
        db $29, $2B, $28
    
    .re_space
        db $2B, $1E, $59
    
    .re_no_space
        db $2B, $1E
    
    .some
        db $2C, $28, $26, $1E
    
    .se
        db $2C, $1E
    
    .sh
        db $2C, $21
    
    .so
        db $2C, $28
    
    .st
        db $2C, $2D
    
    .ter_space
        db $2D, $1E, $2B, $59
    
    .thin
        db $2D, $21, $22, $27
    
    .ter
        db $2D, $1E, $2B
    
    .tha
        db $2D, $21, $1A
    
    .the
        db $2D, $21, $1E
    
    .thi
        db $2D, $21, $22
    
    .to
        db $2D, $28
    
    .tr
        db $2D, $2B
    
    .up
        db $2E, $29
    
    .ver
        db $2F, $1E, $2B
    
    .with
        db $30, $22, $2D, $21
    
    .wa
        db $30, $1A
    
    .we
        db $30, $1E
    
    .wh
        db $30, $21
    
    .wi
        db $30, $22
    
    .you
        db $32, $28, $2E
    
    .Her
        db $07, $1E, $2B
    
    .Tha
        db $13, $21, $1A
    
    .The
        db $13, $21, $1E
    
    .Thi
        db $13, $21, $22
    
    .You
        dw $18, $28, $2E
    
    .endOfTable
    }

; ==============================================================================

    ; *$748D9-$748E9 JUMP LOCATION
    Text_Render:
    {
        LDA $1CD4 ; (second level controller for text mode submodules)
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Text_DrawBorder           ; (0x00) Set up a DMA transfer to blit the message box frame during NMI
        dw Text_DrawBorderIncremenal ; (0x01) this appears to be unused... it might be worth investigating what the hell it does.
        dw Text_CharacterTilemap     ; (0x02) Sets up a template tilemap, for which actual graphical data will be loaded for in the next section (joys of VWF)
        dw Text_MessageHandler       ; (0x03) Generates the game text text and other processing
        dw Text_Close                ; (0x04) Called after player hits A, B, Y, or X
    }

; ==============================================================================

    ; *$748EA-$74918 JUMP LOCATION
    Text_DrawBorder:
    {
        JSR Text_InitBorderOffsets
        
        ; Draw the top line of the box frame
        JSR Text_DrawBorderRow
        
        REP #$30
        
        LDA.w #$0006 : STA $00
    
    .nextRow
    
        ; This loop draws the middle rows of the message box border
        LDY.w #$0006
        
        JSR Text_DrawBorderRow
        
        DEC $00 : BNE .nextRow
        
        LDY.w #$000C
        
        JSR Text_DrawBorderRow
        
        LDA.w #$FFFF : STA $1002, X
        
        SEP #$30
        
        ; Indicates to update the tilemap using the array at $7E1000[0x???] (I'm not sure how long it can get)
        LDA.b #$01 : STA $14
        
        ; Skip the second routine and begin drawing the text. (Then what does $1CD4 = 0x01 mean?)
        LDA.b #$02 : STA $1CD4
        
        RTS
    }

; ==============================================================================

    ; *$74919-$74935 JUMP LOCATION
    Text_DrawBorderIncremenal:
    {
        ; Unlike the previous method of drawing the border, this method takes place over the course of 8 frames,
        ; drawing one row per frame.
        
        ; Use $1000[???] to update the tilemap(s)
        LDA.b #$01 : STA $14
        
        ; they wanted to save 12 bytes by not including extra entries in the jump table for the 6 middle rows, (just one row).
        ; The irony here is that the code they added to do this completely negated to a
        ; whopping net savings of zero(!) bytes, whilst incurring additional, unnecessary CPU cycles.
        LDA $1CD7  : BEQ .alpha
        CMP.b #$07 : BCC .beta
        LDA.b #$02 : BRA .alpha
    
    .beta
        
        LDA.b #$01
    
    .alpha
    
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw Text_DrawFirstBorderRow
        dw Text_DrawMiddleBorderRow
        dw Text_DrawBottomBorderRow
    }

; ==============================================================================

    ; *$74936-$74949 JUMP LOCATION
    Text_DrawTopBorderRow:
    {
        REP #$30
        
        JSR Text_InitBorderOffsets
        JSR Text_DrawBorderRow
        
        LDA.w #$FFFF : STA $1002, X
        
        SEP #$30
        
        INC $1CD7
        
        RTS
    } 

; ==============================================================================

    ; *$7494A-$74960 JUMP LOCATION
    Text_DrawMiddleBorderRow:
    {
        REP #$30
        
        LDX.w #$0000
        LDY.w #$0006
        
        JSR Text_DrawBorderRow
        
        LDA.w #$FFFF : STA $1002, X
        
        SEP #$30
        
        INC $1CD7
        
        RTS
    }

; ==============================================================================

    ; *$74961-$7497C JUMP LOCATION
    Text_DrawBottomBorderRow:
    {
        REP #$30
        
        LDX.w #$0000
        LDY.w #$000C
        
        JSR Text_DrawBorderRow
        
        LDA.w #$FFFF : STA $1002, X
        
        SEP #$30
        
        INC $1CD7
        
        LDA.b #$02 : STA $1CD4
        
        RTS
    }

; ==============================================================================

    ; *$7497D-$74983 JUMP LOCATION
    Text_CharacterTilemap:
    {
        JSR Text_BuildCharacterTilemap
        
        INC $1CD4
        
        RTS
    }

; ==============================================================================

    ; *$74984-$749FC JUMP LOCATION
    Text_MessageHandler:
    {
    
    .epsilon
    
        REP #$30
        
        ; if $1CDD < 0x63
        LDA $1CDD : LDY.w #$0000 : CMP.w #$0063 : BCC .alpha
        
        ; else
        LDA.w #$0000
        
        STY $1CE6 ; $1CE6 = 0
        
        BRA .beta
    
    .alpha
    
        ; What is the significance of this?
        CMP.w #$003B : BCC .zeta
        CMP.w #$0050 : BCS .zeta ; Or this?
        
        ; if( ($1CDD >= 0x3B) && ($1CDD < 0x50) )
        LDA.w #$0050
        
        STY $1CE6 ; $1CE6 = 0
        
        BRA .beta
    
    .zeta
    
        CMP.w #$0013 : BCC .beta
        CMP.w #$0028 : BCS .beta
        
        ; if($1CDD >= 0x0013 && $1CDD < 0x0028) STY $1CE6
        LDA.w #$0028
        
        STY $1CE6
    
    .beta
    
        ; Maybe $1CDD in this case is something different? (also some kind of positioner?)
        STA $1CDD
        
        CMP.w #$0012 : BEQ .gamma
        CMP.w #$003A : BEQ .gamma
        CMP.w #$0062 : BNE .loadNextByte
    
    .gamma
    
        LDA $1CE6 : AND.w #$0007 : CMP.w #$0006 : BCC .loadNextByte
        
        ; I don't think this location is ever reached, therefore I hypothesize
        ; that this variable is never changed during VWF rendering
        INC $1CDD
        
        BRA .epsilon
    
    .loadNextByte
    
        LDX $1CD9
        
        ; Load a character (or maybe a command) from the text buffer
        ; (Dictionary doesn't matter here so AND with 0x7F)
        LDA $7F1200, X : AND.w #$007F : SUB.w #$0066 : BPL .commandByte
        
        ; In this case it's a character
        LDA.w #$0000
    
    .commandByte
    
        SEP #$30
        
        JSR VWF_CharacterOrCommand
        
        LDA.b #$02 : STA $17 : STA $0710
        
        RTS
    }

; ==============================================================================

    ; *$749FD-$74A34 LOCAL
    VWF_CharacterOrCommand:
    {
        JSL UseImplicitRegIndexedLocalJumpTable
        
        ; Text Routines 2
        ; These routines are used in the actual generation of the text
        
        dw VWF_Render              ; This thing takes forever to execute (handles normal characters)
        dw VWF_NextPicture         ; [NextPic]
        dw VWF_Select2Or3_Indented ; [Choose]
        dw VWF_SelectItem          ; [Item]
        dw VWF_IgnoreCommand       ; [Name]
        dw VWF_IgnoreCommand       ; [Window XX]
        dw VWF_IgnoreCommand       ; [Number XX]
        dw VWF_IgnoreCommand       ; [Postion XX]
        dw VWF_IgnoreCommand       ; [ScrollSpd XX]
        dw VWF_Select2Or3          ; [SelChng] Check for player input
        dw VWF_Crash               ; [Crash] Leads to data, hence it crashes
        dw VWF_Choose3             ; [Choose3]
        dw VWF_Choose1Or2          ; [Choose2]
        dw VWF_Scroll              ; [Scroll]
        dw VWF_SetLine             ; [1]
        dw VWF_SetLine             ; [2]
        dw VWF_SetLine             ; [3]
        dw VWF_SetPalette          ; [Color XX] (does nothing unfortunately)
        dw VWF_Wait                ; [Wait XX] 
        dw VWF_PlaySound           ; [Sound XX]
        dw VWF_SetSpeed            ; [Speed XX]
        dw VWF_Command7B           ; [Command 7B] thought to be unused (intent of usage also unclear)
        dw VWF_Command7C           ; [Command 7C] thought to be unused
        dw VWF_ClearBuffer         ; [Command 7D] (This is unused in any original game messages, though, for whatever reason.)
        dw VWF_WaitKey             ; [WaitKey]
        dw VWF_EndMessage          ; [End] - this stops the text message completely. 
                   ; Corresponds to byte 0x7F in the data.
    }

; ==============================================================================

    ; *$74A35-$74A6B JUMP LOCATION
    Text_Close:
    {
        REP #$30
        
        JSR Text_InitBorderOffsets
        
        REP #$30
        
        LDA $1CD0 : XBA : STA $1002, X : INX #2
        LDA .reg_config : STA $1002, X : INX #2
        LDA .data       : STA $1002, X : INX #2
        
        LDA.w #$FFFF : STA $1002, X
        
        SEP #$30
        
        LDA.b #$01 : STA $14
        
        STZ $1CD8
        STZ $11
        
        ; Restore us to whatever mode we came from.
        LDA $010C : STA $10
        
        RTS
    }

; ==============================================================================

    ; *$74A6C-$74A98 JUMP LOCATION
    VWF_Render:
    {
        ; Which line the text is currently printing to?
        LDA $1CD5 : CMP.b #$02 : BCC .validSpeed
        
        LDA.b #$02
    
    .validSpeed
    
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw VWF_RenderRecursive ; 
        dw VWF_RenderSingle    ; speed = 1
        dw VWF_InvalidSpeed_1  ; speed = 2 (immediately drops down to speed = 1)
        dw VWF_InvalidSpeed_2  ; speed = 3 ... doesn't do anything at all???
        dw VWF_InvalidSpeed_2  ; speed = 4 ...*rips hair out*
        dw VWF_InvalidSpeed_2
        dw VWF_InvalidSpeed_2
        dw VWF_InvalidSpeed_2
        dw VWF_InvalidSpeed_2
        dw VWF_InvalidSpeed_2
        dw VWF_InvalidSpeed_2
        dw VWF_InvalidSpeed_2
        dw VWF_InvalidSpeed_2
        dw VWF_InvalidSpeed_2
        dw VWF_InvalidSpeed_2
        dw VWF_InvalidSpeed_2 
    }

; ==============================================================================

    ; *$74A99-$74AB7 JUMP LOCATION
    VWF_RenderRecursive:
    {
        JSR VWF_RenderSingle
        
        REP #$30
        
        LDA $1CDD
        
        ; basically, branch if $1CDD = 19, 59, or 99 (why?)
        CMP.w #$0013 : BEQ BRANCH_ALPHA
        CMP.w #$003B : BEQ BRANCH_ALPHA
        CMP.w #$0063 : BEQ BRANCH_ALPHA
        
        SEP #$30
        
        ; This is recursion, son. Fear it (stack overflows are possible)
        JMP $C984 ; $74984 IN ROM

    BRANCH_ALPHA:

        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$74AB8-$74ADE LOCAL
    VWF_RenderSingle:
    {
        ; Renders a single character (non recursive)
        
        REP #$10
        
        LDX $1CD9
        
        ; Is it a space (as in, " ")
        LDA $7F1200, X : CMP.b #$59 : BEQ .blankCharacter
        
        ; no, so make some noise bitch
        SEP #$30
        
        LDA.b #$0C : STA $012F
    
    .blankCharacter
    
        REP #$30
        
        ; There's no point to this.... X's value is destroyed in the callee below.
        LDA $1CDD : ASL A : TAX
        
        SEP #$30
        
        JSR VWF_RenderCharacter
        
        LDA $1CD6 : STA $1CD5
        
        RTS
    }

    ; $74ADF-$74B5D DATA
    pool VWF_RenderCharacter:
    {
    
    .widths
    
        db 6, 6, 6, 6, 6, 6, 6, 6, 3, 6, 6, 6, 7, 6, 6, 6
        db 6, 6, 6, 7, 6, 7, 7, 7, 7, 6, 6, 6, 6, 6, 6, 6
        db 6, 6, 3, 5, 6, 3, 7, 6, 6, 6, 6, 5, 6, 6, 6, 7
        db 7, 7, 7, 6, 6, 4, 6, 6, 6, 6, 6, 6, 6, 6, 3, 7
        db 6, 4, 4, 6, 8, 6, 6, 6, 6, 6, 8, 8, 8, 7, 7, 7
        db 7, 4, 8, 8, 8, 8, 8, 8, 8, 4, 8, 8, 8, 8, 8, 8
        db 8, 8, 4
        ; Interesting that there are only widths for characters
        ; 0x0 through 0x62.... what about the other 4 characters?
        
    .setMasks
    
        db $80, $40, $20, $10, $08, $04, $02, $01
    
    .renderPositions
    
        dw $0000, $02A0, $0540
    
    .linePositions
    
        dw $0000, $0040, $0080
    
    .unsetMasks
    
        db ~$80, ~$40, ~$20, ~$10, ~$08, ~$04, ~$02, ~$01
    }

; ==============================================================================

    ; *$74B5E-$74CF8 LOCAL
    VWF_RenderCharacter:
    {
        ; Notes:
        ; In this routine, "tile" means an 8 pixel by 8 pixel graphic (2bpp native to SNES)
        ; "character" is tile data taken from the rom for each letter of symbol. It could be up to 8 pixels wide,
        ; but frequently it is less, usually 3 to 7 pixels wide. The characters are stored in 8 pixel by 16 pixels
        ; entries at $0E:8000 ($70000 in the Rom)
        ; each character obviously consists of 16 lines. If you've played the game you'd know this.
        ; $0724[2] indexes into $7EC230[0xC0] to indicate how many pixels (horizontally) we are into the current tile location
        ; once it reaches 8 we move on to the next tile.
        
        !charWidth        = $02
        !charWidthCounter = $03
        !rowOfPixels      = $04 ; pixel data for a single horizontal row of the current (source) font tile
        !charLinePos      = $06 ; how many rows into the current (source) font tile we are
        !fontTileOffset   = $0A ; offset relative to the beginning of the font data in ROM.
        !fontBase         = $0D
        
        !changeRowFlag      = $0720
        !rowIndex           = $0722
        !cumulativePosIndex = $0724
        !renderBase         = $0726
        
        ; ---------------------------------------
        
        SEP #$30
        
        PHB : PHK : PLB
        
        REP #$20
        
        LDA !changeRowFlag : BEQ .notChangingRow
        
        ; Index of the line text is being generated on
        LDY !rowIndex
        
        LDA .renderPositions, Y : STA !renderBase
        LDA .linePositions, Y   : STA !cumulativePosIndex
        
        STZ !changeRowFlag
    
    .notChangingRow
    
        SEP #$20
        REP #$10
        
        STZ !charWidthCounter
        
        LDX $1CD9
        
        LDA $7F1200, X ; Load the character value
        
        SEP #$10
        
        ; Y = the character value
        TAY : LDA .widths, Y : STA !charWidth
        
        ; Take our current (H) position in the tile; add the width of the last character; store it as the our h pixel position on the line as a whole
        ; and then moves on to the next character's cumulative position index
        LDX !cumulativePosIndex : ADD $7EC230, X : STA $7EC231, X
        
        INX : STX !cumulativePosIndex
        
        ; Multiply the character value's upper nybble by 2 (0x62 -> 0xE2, etc)
        TYA : AND.b #$F0 : ASL A   : STA $00
        TYA : AND.b #$0F : ORA $00 : STA !fontTileOffset : STZ !fontTileOffset+1
        
        REP #$20
        
        LDA.w #$8000 : STA !fontBase
        LDY.b #$0E   : STY !fontBase+2
        
        REP #$10
        
        ; $00[2] = the byte position in the vwfBuffer, I think
        LDA $7EC22F, X : AND.w #$00FF : ASL A : STA $00
        
        LDX.w #$0000
        
        ; Shift left by 4 to express the offset in 2bpp tiles (each is 16 bytes long)
        LDA !fontTileOffset : ASL #4 : TAY
    
    .topHalf_nextSourceRow
    
        ; Note: $0E:8000 contains uncompressed graphics for all the characters
        ; This VWF copies them byte by byte based on a width value
        
        ; A = value at ($0E:8000 + Y)
        LDA [!fontBase], Y : STA !rowOfPixels
        
        PHY
        
        ; X is um....
        STX !charLinePos
        
        ; $00[2] is the width we have remaining for this particular CHR?
        LDA $00 : ADD !renderBase : TAY
        
        ; This AND operation tells us which tile in the vwfBuffer to draw to
        AND.w #$0FF0 : ADD !charLinePos : TAX
        
        ; A = pixel position in the vwfBuffer (mod 8 b/c we're only concerned about the current tile)
        TYA : LSR A : AND.w #$0007 : TAY
        
        SEP #$20
        
        LDA !charWidth : STA !charWidthCounter
    
    .topHalf_notAtTargetTileBoundary
    
        ; Cycle through each bit
        ; If the bit is clear branch
        ASL !rowOfPixels : BCC .topHalf_unsetPlane0
        
        LDA $7F0000, X : EOR .setMasks, Y : STA $7F0000, X
        
        BRA .topHalf_doPlane1
    
    .topHalf_unsetPlane0
    
        ; Use masks to "erase" a dot
        ; Unset a bit in the bitmap
        LDA $7F0000, X : AND .unsetMasks, Y : STA $7F0000, X
    
    .topHalf_doPlane1
    
        ASL !rowOfPixels+1 : BCC .topHalf_unsetPlane1
        
        LDA $7F0001, X : EOR .setMasks, Y : STA $7F0001, X
        
        BRA .topHalf_decWidthCounter
    
    .topHalf_unsetPlane1
    
        LDA $7F0001, X : AND .unsetMasks, Y : STA $7F0001, X
    
    topHalf_decWidthCounter
    
        DEC !charWidthCounter : BEQ .topHalf_outOfWidth
        
        ; See if there's still room in the current tile
        ; Yep, there's still room, so branch up and handle the next bit in the data
        INY : CPY.w #$0008 : BNE .topHalf_notAtTargetTileBoundary
    
    .topHalf_outOfWidth
    
        ; This is reached if we run out of room in the tile or run out of "length" in the character
        REP #$20
        
        ; Moves us to the next tile to the right in the target buffer
        ; (possibly to the next line in some cases)
        TXA : ADD.w #$0010 : TAX
        
        LDA !rowOfPixels : BEQ .topHalf_noRemainingSetPixels
        
        STA $7F0000, X
    
    .topHalf_noRemainingSetPixels
    
        PLY : INY #2
        
        LDX !charLinePos : INX #2 : CPX.w #$0010 : BNE .topHalf_nextSourceRow
        
        ; Positions us on the lower half of the text line
        LDA !renderBase : ADD.w #$0150 : STA $08
        
        LDX.w #$0000
        
        ; Increment the row, then shift left 4 times (this grabs the next tile down)
        LDA !fontTileOffset : ADD.w #$0010 : ASL #4 : TAY
    
    .bottomHalf_NextSourceRow
    
        ; Handles the lower half of the character
        ; A = value at ($0E:8000 + Y)
        LDA [!fontBase], Y : STA !rowOfPixels
        
        PHY
        
        STX !charLinePos
        
        LDX !cumulativePosIndex : LDA $7EC22F, X : AND.w #$00FF : ASL A : ADD $08 : TAY
        
        AND.w #$0FF0 : ADD !charLinePos : TAX
        
        TYA : LSR A : AND.w #$0007 : TAY
        
        SEP #$20
        
        LDA !charWidth : STA !charWidthCounter
    
    .bottomHalf_notAtTargetTileBoundary
    
        ; Shift through the next bit in the line of 2bpp pixel data
        ASL !rowOfPixels : BCC .bottomHalf_unsetPlane0
        
        ; Set a bit in the bitmap
        LDA $7F0000, X : EOR .setMasks, Y : STA $7F0000, X
        
        BRA .bottomHalf_doPlane1
    
    .bottomHalf_unsetPlane0
    
        ; Unset a bit in the bitmap
        LDA $7F0000, X : AND .unsetMasks, Y : STA $7F0000, X
    
    .bottomHalf_doPlane1
    
        ; Shift through the next bit in the "line" of 2bpp pixel data
        ASL !rowOfPixels+1 : BCC .bottomHalf_unsetPlane1
        
        ; Set a bit in the bitmap
        LDA $7F0001, X : EOR .setMasks, Y : STA $7F0001, X
        
        BRA .bottomHalf_decWidthCounter
    
    .bottomHalf_unsetPlane1
    
        ; Unset a bit in the bitmap
        LDA $7F0001, X : AND .unsetMasks, Y : STA $7F0001, X
    
    .bottomHalf_decWidthCounter
    
        DEC !charWidthCounter : BEQ ,bottomHalf_outOfWidth
        
        ; if not, see if we've run out of room in the current tile
        ; We still have room in the current tile, so branch
        INY : CPY.w #$0008 : BNE .bottomHalf_notAtTargetTileBoundary
    
    ,bottomHalf_outOfWidth
    
        ; This is reached if we run out of room in either the tile or the character
        
        REP #$20
        
        ; Moves on to the next tile
        TXA : ADD.w #$0010 : TAX
        
        ; See if there is any pixel data left in the current line
        ; if there's only transparent pixels left, there's no need to keep drawing
        LDA !rowOfPixels : BEQ .bottomHalf_noRemainingSetPixels
        
        ; If there still is pixel data, the "remainder" will end up in the next tile
        STA $7F0000, X
    
    .bottomHalf_noRemainingSetPixels
    
        PLY : INY #2
        
        LDX !charLinePos : INX #2 : CPX.w #$0010 : BEQ .characterFinished
        
        BRL .bottomHalf_NextSourceRow
    
    .characterFinished
    
        ; After all that bullshit... move on to the next character!
        INC $1CD9
        
        SEP #$30
        
        PLB
        
        RTS
    
    ; *74CF8 ALTERNATE ENTRY POINT
    .unused
    
        ; Unused location, pretty sure
    
        RTS
    }

; ==============================================================================

    ; *$74CF9-$74CFD JUMP LOCATION
    VWF_InvalidSpeed:
    {
    
    ._1
    
        DEC $1CD5
        
        RTS
    
    ._2
    
        RTS
    }

; ==============================================================================

    ; *$74CFE-$74D15 JUMP LOCATION
    VWF_NextPicture:
    {
        ; [NextPic] Command (rendering stage)
        
        ; Is it history mode?
        ; If it's not history module, just move to the next character >_>
        LDA $10 : CMP.b #$14 : BNE .notInAttractMode
        
        JSL PaletteFilterHistory
        
        LDA $7EC007 : BNE .notDoneFiltering
    
    .notInAttractMode
    
        ; Wait for the colors to finished being modified before advancing to the
        ; next character or command.
        
        REP #$30
        
        INC $1CD9
        
        SEP #$30
    
    .notDoneFiltering
    
        RTS
    }

    ; $74D16-$74D19 DATA
    VWF_Select2Or3_Indented_messages:
    {
        dw $0001, $0002
    }

; ==============================================================================

    ; *$74D1A-$74D87 JUMP LOCATION
    VWF_Select2Or3_Indented:    
    {
        LDA $1CE9 : BEQ .readyForInput
        
        DEC A : STA $1CE9 : CMP.b #$01 : BNE .return
        
        LDA.b #$24 : STA $012F
        
        BRA .return
    
    .readyForInput
    
        LDA $F4 : TAY : ORA $F6
    
        ; Player has chosen if the A, B, X, or Y buttons are pressed
        AND.b #$C0       : BNE .playerHasChosen
        TYA : AND.b #$08 : BNE .upPushed
        TYA : AND.b #$04 : BNE .downPushed
    
    .return
    
        RTS
    
    .upPushed
    
        LDA $1CE8 : BEQ .return
        
        STZ $1CE8
        
        BRA .moveChoiceArrow
    
    .downPushed
    
        LDA $1CE8 : DEC A : BEQ .return
        
        LDA.b #$01 : STA $1CE8
    
    .moveChoiceArrow
    
        LDA.b #$20 : STA $012F
        
        LDA $1CE8 : ASL A : TAX
        
        LDA VWF_Select2Or3_Indented_messages, X   : STA $1CF0
        LDA VWF_Select2Or3_Indented_messages+1, X : STA $1CF1
        
        JSR Text_LoadCharacterBuffer
        
        STZ $1CE6
        STZ $1CD9
        STZ $1CDA
        
        JSR Text_InitVwfState
        
        RTS
    
    .playerHasChosen
    
        ; Play a sound.
        LDA.b #$2B : STA $012E
        
        ; Move on to the final step of 0x0E.0x02.0x00
        LDA.b #$04 : STA $1CD4
        
        RTS
    }

; ==============================================================================

    ; *$74D88-$74DC7 JUMP LOCATION
    VWF_SelectItem:
    {
        ; [Item] command
        LDA $1CE9 : BEQ .readyForInput
        
        DEC A : STA $1CE9 : CMP.b #$01 : BEQ VWF_SelectNextItem
        
        BRA .return
    
    .readyForInput
    
        LDA $F4 : ORA $F6 : AND.b #$C0 : BNE .playerHasChosen
        
        LDA $F4 : AND.b #$05 : BEQ .noDownOrLeftInput
        
        INC $1CE8
        
        BRA BRANCH_EPSILON
    
    .noDownOrLeftInput
    
        LDA $F4 : AND.b #$0A : BEQ .noDownOrRightInput
        
        DEC $1CE8
        
        JSR VWF_SelectPrevItem
        JSR Text_DrawCharacterTilemap
        
        BRA .return
    
    BRANCH_EPSILON:
    .noDownOrRightInput
    
        JSR VWF_SelectNextItem
        JSR Text_DrawCharacterTilemap
    
    .return
    
        RTS
    
    .playerHasChosen
    
        LDA.b #$04 : STA $1CD4
        
        RTS
    }

; ==============================================================================

    ; *$74DC8-$74DEC LOCAL
    VWF_SelectPrevItem:
    {
    
    .tryPrevSlot
    
        LDX $1CE8 : BPL .inRange
        
        LDX.b #$1F : STX $1CE8
    
    .inRange
    
        CPX.b #$0F : BEQ .invalidSlot
        
        LDA $7EF340, X : BMI .invalidValue : BNE VWF_ChangeItemTiles
    
    .invalidValue
    
        CPX.b #$20 : BNE .invalidSlot
        
        LDA $7EF341, X : BNE VWF_ChangeItemTiles
    
    .invalidSlot
    
        DEC $1CE8 : BRA .tryPrevSlot
    }

; ==============================================================================

    ; *$74DED-$74E13 LOCAL
    VWF_SelectNextItem:
    {
    
    .tryNextSlot
    
        LDX $1CE8 : CPX.b #$20 : BCC .inRange
        
        ; Wrap around back to 0x00 (so valid range is 0x00 to 0x1f)
        LDX.b #$00 : STX $1CE8
    
    .inRange
    
        ; The "has bottles" slot is invalid because it only is a flag for whether
        ; we have any bottles, not a tangible item.
        CPX.b #$0F : BEQ .invalidSlot
        
        LDA $7EF340, X : BMI .invalidValue : BNE VWF_ChangeItemTiles
    
    .invalidValue
    
        CPX.b #$20 : BNE .invalidSlot
        
        LDA $7EF341, X : BNE VWF_ChangeItemTiles
    
    .invalidSlot
    
        INC $1CE8 : BRA .tryNextSlot
    }
    
    ; *$74E14-$74E6A
    VWF_ChangeItemTiles:
    {
    
        ; Y = X, Y = X << 1, A is destroyed
        TXY : TXA : ASL A : TAX
        
        LDA $0DFA93, X : STA $00
        LDA $0DFA94, X : STA $01
        LDA.b #$0D     : STA $02
        
        TYX
        
        LDA $7EF340, X
        
        CPX.b #$20 : BEQ .isRupeesSlot
        CPX.b #$03 : BNE .notBombsSlot
    
    .isRupeesSlot
    
        LDA.b #$01
    
    .notBombsSlot
    
        ASL #3 : TAY
        
        ; Loads the 4 tilemap entries for the currently selected item type.
        LDA [$00], Y : STA $13C2 : INY
        LDA [$00], Y : STA $13C3 : INY
        LDA [$00], Y : STA $13C4 : INY
        LDA [$00], Y : STA $13C5 : INY
        LDA [$00], Y : STA $13EC : INY
        LDA [$00], Y : STA $13ED : INY
        LDA [$00], Y : STA $13EE : INY
        LDA [$00], Y : STA $13EF
        
        RTS
    }

; ==============================================================================

    ; *$74E6B-$74E7E LOCAL
    VWF_IgnoreCommand:
    {
        ; [Window XX], [Name], [Number XX] point here in text generation but this routine
        ; doesn't really do anything except grab the next character or command byte
        
        REP #$10
        
        ; Get position in character stream
        LDX $1CD9 : INX
        
        ; This determines how many lines to scroll up per frame
        LDA $7F1200, X : STA $1CEA
        
        ; Increment to the next byte in the stream
        INX : STX $1CD9
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; $74E7F-$74E82 DATA
    VWF_Select2Or3_messages:
    {
        dw $000B, $000C
    }

; ==============================================================================

    ; *$74E83-$74EF0 JUMP LOCATION
    VWF_Select2Or3:
    {
        ; [SelChng]
        ; It's worth noting that there are no clear distinctions between this command
        ; and [Choose], other than the difference in the positions of the subsequent options
        ; it brings up
        LDA $1CE9 : BEQ .readyForInput
        
        DEC A : STA $1CE9 : CMP.b #$01 : BNE .return
        
        LDA.b #$24 : STA $012F
        
        BRA .return
    
    .readyForInput
    
        ; Player has chosen if the A, B, X, or Y buttons are pressed
        LDA $F4 : TAY : ORA $F6
        
        AND.b #$C0       : BNE .playerHasChosen
        TYA : AND.b #$08 : BNE .upPushed
        TYA : AND.b #$04 : BNE .downPushed
    
    .return
    
        RTS
    
    .upPushed
    
        LDA $1CE8 : BEQ .return
        
        STZ $1CE8
        
        BRA .moveChoiceArrow
    
    .downPushed
    
        LDA $1CE8 : DEC A : BEQ .return
        
        LDA.b #$01 : STA $1CE8
    
    .moveChoiceArrow
    
        LDA.b #$20 : STA $012F
        
        LDA $1CE8 : ASL A : TAX
        
        LDA VWF_Select2Or3_messages, X   : STA $1CF0
        LDA VWF_Select2Or3_messages+1, X : STA $1CF1
        
        JSR Text_LoadCharacterBuffer
        
        STZ $1CE6
        STZ $1CD9
        STZ $1CDA
        
        JSR Text_InitVwfState
        
        RTS
    
    .playerHasChosen
    
        ; Play a sound
        LDA.b #$2B : STA $012E
        
        ; Move on to the final step of 0x0E.0x02.0x00
        LDA.b #$04 : STA $1CD4
        
        RTS
    }

; ==============================================================================

    ; $74EF1-$74EF6 DATA
    VWF_Crash:
    VWF_Choose3_ArrowDialogs:
    {
        dw $0006, $0007, $0008
    }

; ==============================================================================

    ; *$74EF7-$74F6D JUMP LOCATION
    VWF_Choose3:
    {
        LDA $1CE9 : BEQ .readyForInput
        
        DEC A : STA $1CE9 : CMP.b #$01 : BNE .return
        
        ; Play flutey sound effect
        LDA.b #$24 : STA $012F
        
        BRA .return
    
    .readyForInput
    
        LDA $F6 : AND.b #$C0 : ORA $F4 : TAY
        
        AND.b #$D0       : BNE .playerHasChosen
        TYA : AND.b #$08 : BNE .upPushed
        TYA : AND.b #$04 : BNE .downPushed
    
    .return
    
        RTS
    
    .upPushed
    
        LDA $1CE8 : DEC A : CMP.b #$FF : BNE .didntUnderflow
        
        LDA.b #$02
    
    .didntUnderflow
    
        STA $1CE8
        
        BRA .moveChoiceArrow
    
    .downPushed
    
        LDA $1CE8 : INC A : CMP.b #$03 : BNE .didntOverflow
        
        LDA.b #$00
    
    .didntOverflow
    
        STA $1CE8
    
    .moveChoiceArrow
    
        LDA.b #$20 : STA $012F
        
        LDA $1CE8 : ASL A : TAX
        
        LDA VWF_Choose3_ArrowDialogs, X   : STA $1CF0
        LDA VWF_Choose3_ArrowDialogs+1, X : STA $1CF1
        
        JSR Text_LoadCharacterBuffer
        
        STZ $1CE6
        STZ $1CD9
        STZ $1CDA
        
        JSR Text_InitVwfState
        
        RTS
    
    .playerHasChosen
    
        LDA.b #$2B : STA $012E
        
        LDA.b #$04 : STA $1CD4
        
        RTS
    }

; ==============================================================================

    ; $74F6E-$74F71 DATA
    VWF_Choose1Or2_messages:
    {
        dw $0009, $000A
    }

; ==============================================================================

    ; *$74F72-$74FE1 JUMP LOCATION
    VWF_Choose1Or2:
    {
        ; [Choose2]
        ; The only difference between this and [Choose] / [SelChng] is that it
        ; accepts the Start button as a valid affirmative input. (And the messages it
        ; links to for choice arrows)
        
        LDA $1CE9 : BEQ .readyForInput
        
        DEC A : STA $1CE9 : CMP.b #$01 : BNE .return
        
        ; Play flutey sound effect
        LDA.b #$24 : STA $012F
        
        BRA .return
    
    .readyForInput
    
        LDA $F6 : AND.b #$C0 : ORA $F4 : TAY
        
        ; Player has chosen if the A, B, X, Y, or Start buttons are pressed
              AND.b #$D0 : BNE .playerHasChosen
        TYA : AND.b #$08 : BNE .upPushed
        TYA : AND.b #$04 : BNE .downPushed
    
    .return
    
        RTS
    
    .upPushed
    
        LDA $1CE8 : BEQ .return
        
        STZ $1CE8
        
        BRA .moveChoiceArrow
    
    .downPushed
    
        LDA $1CE8 : DEC A : BEQ .return
        
        LDA.b #$01 : STA $1CE8
    
    .moveChoiceArrow
    
        LDA.b #$20 : STA $012F
        
        LDA $1CE8 : ASL A : TAX
        
        LDA VWF_Choose1Or2_messages, X   : STA $1CF0
        LDA VWF_Choose1Or2_messages+1, X : STA $1CF1
        
        JSR Text_LoadCharacterBuffer
        
        STZ $1CE6
        STZ $1CD9
        STZ $1CDA
        
        JSR Text_InitVwfState
        
        RTS
    
    .playerHasChosen
    
        LDA.b #$2B : STA $012E
        LDA.b #$04 : STA $1CD4
        
        RTS
    }

; ==============================================================================

    ; *$74FE2-$750C2 JUMP LOCATION
    VWF_Scroll:
    {
        ; [Scroll] (rendering stage)
        
        PHB : LDA.b #$7F : PHA : PLB ; data bank = 0x7F
        
        ; (note this is unfiltered joypad 1 input) Look for A button presses
        LDA $F2 : AND.b #$80 : BEQ .A_ButtonNotHeld
        
        LDA $001CEA ; Holding A down doesn't make any real difference
        
        BRA .fuckingUselessAdditionalLogic
    
    .A_ButtonNotHeld
    
        LDA $001CEA
    
    .fuckingUselessAdditionalLogic
    
        STA $02
    
    .nextLine
    
        REP #$30
        
        STZ $00
    
    .moveTileUpOnePixel
    
        ; This loop modifies graphical tile data by making it appear to scroll up
        
        LDX $00
        
        LDA $0002, X : STA $0000, X ; Line 0 = the old Line 1
        LDA $0004, X : STA $0002, X ; Line 1 = the old Line 2, and so on
        LDA $0006, X : STA $0004, X
        LDA $0008, X : STA $0006, X
        LDA $000A, X : STA $0008, X
        LDA $000C, X : STA $000A, X
        LDA $000E, X : STA $000C, X
        LDA $0150, X : STA $000E, X ; Line 7 = the old Line 1 from the tile that is "below" this tile
        
        ; hence the scrolling effect
        
        LDA $00 : ADD.w #$0010 : STA $00
        
        CMP.w #$07E0 : BCC .moveTileUpOnePixel
        
        STZ $07DE
        STZ $07CE
        STZ $07BE
        STZ $07AE
        STZ $079E
        STZ $078E
        STZ $077E
        STZ $076E
        STZ $075E
        STZ $074E
        STZ $073E
        STZ $072E
        STZ $071E
        STZ $070E
        STZ $06FE
        STZ $06EE
        STZ $06DE
        STZ $06CE
        STZ $06BE
        STZ $06AE
        STZ $069E
        
        SEP #$30
        
        LDA $001CDF : ADD.b #$01 : STA $001CDF
        
        AND.b #$0F : BNE .lineFinished
        
        ; This gets called after the text has moved up 0x10 pixels
        
        REP #$30
        
        ; Move on to the next byte in the character stream
        LDA $001CD9 : ADD.w #$0001 : STA $001CD9
        
        ; Signify that we are on row 3 (figure head)
        LDA.w #$0050 : STA $001CDD
        
        ; Signify that we are on row 3 (actually does something)
        LDA $0ED0C7 : STA $000722
        
        ; Signify that we need to draw a new line
        LDA.w #$0001 : STA $000720
        
        SEP #$30
        
        LDA.b #$00 : STA $001CE6
        
        STZ $02
    
    .lineFinished
    
        DEC $02 : BMI .doneScrolling
        
        JMP .nextLine
    
    .doneScrolling
    
        PLB
        
        RTS
    }

    ; $750C3-$750C8 DATA ; consists of values for $7E0722
    VWF_RowPositions:
    {
        dw $0000, $0002, $0004
    }

; ==============================================================================

    ; *$750C9-$750F1 JUMP LOCATION
    VWF_SetLine:
    {
        ; [1], [2], and [3]
        
        REP #$30
        
        ; X = next character in the buffer
        LDX $1CD9
        
        ; Possible values are 0x74, 0x75, or 0x76
        LDA $7F1200, X : AND.w #$0003 : ASL A : TAX
        
        LDA VWF_LinePositions, X : STA $1CDD
        
        LDA VWF_RowPositions, X : STA $0722
        
        ; Signal the need for a new line
        LDA.w #$0001 : STA $0720
        
        ; Move to the next character in the buffer
        INC $1CD9
        
        SEP #$30
        
        STZ $1CE6
        
        RTS
    }

; ==============================================================================

    ; *$750F2-$75114 JUMP LOCATION
    VWF_SetPalette:
    {
        ; [Color XX]
        ; Color 7 is the only one used normally
        
        REP #$10
        
        ; 0b11100011 (presumably this is to preserve vflip, hflip, priority, and the chr bits)
        LDA $1CDC : AND.b #$E3 : STA $1CDC
        
        LDX $1CD9 : INX
        
        ; Sets the tile palette, or rather, it would...
        ; If this variable was actually used anywhere else in rendering.
        ; Sorry folks this is an abandoned feature - the command is useless, and probably rightly
        ; so in this VWF's design. The only way you could change color in this engine is to make sure
        ; you've started a new tile, which would be terribly inconvenient for a VWF.
        LDA $7F1200, X : AND.b #$07 : ASL #2 : ORA $1CDC : STA $1CDC
        
        INX : STX $1CD9
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$75115-$75137 JUMP LOCATION
    VWF_Wait:
    {
        ; [Wait XX] command (actual generation)

        ; Check for input from the player
        ; note that in history mode the game does not record input other than the start button
        ; specifically, NMI does record it and then later history mode deletes the input
        LDA $F2 : AND.b #$80 : BEQ .A_ButtonNotHeld
        
        ; A button has been held down down, so break out of this wait loop prematurely
        LDA.b #$01
        
        BRA .runWaitProcedure
    
    .A_ButtonNotHeld
    
        REP #$30
        
        LDA $1CE0 : CMP.w #$0002 : BCC .runWaitProcedure
        
        LDA.w #$0002
    
    .runWaitProcedure
    
        SEP #$30
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw VWF_WaitLoop_initCounter ; sets up the wait loop (valid input would be 0 - F)
        dw VWF_EndWait              ; break out of the wait loop
        dw VWF_WaitLoop_decCounter  ; just counts down the timer (can be as high as 8.33 seconds!)
    }

    ; *$75138-$75153 JUMP LOCATION
    VWF_WaitLoop:
    {
    
    .initCounter
    
        REP #$30
        
        LDX $1CD9
        
        LDA $7F1201, X : AND.w #$000F : ASL A : TAX
        
        LDA Text_WaitDurations, X : STA $1CE0
    
    ; *$7514C ALTERNATE ENTRY POINT
    .decCounter
    
        REP #$30
        
        DEC $1CE0 ; decrement the loop counter
        
        SEP #$30
        
        RTS
    } 

    ; *$75154-$75161 JUMP LOCATION
    VWF_EndWait:
    {
        REP #$30
        
        ; Moves on to the next command or character.
        INC $1CD9
        INC $1CD9
        
        SEP #$30
        
        STZ $1CE0
        
        RTS
    }

    ; *$75162-$75175 JUMP LOCATION
    VWF_PlaySound:
    {
        ; [Sound XX] (rendering stage)
        
        REP #$10
        
        LDX $1CD9 : INX
        
        ; Plays a sound effect
        LDA $7F1200, X : STA $012F
        
        INX : STX $1CD9
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$75176-$7518C JUMP LOCATION
    VWF_SetSpeed:
    {
        ; [Speed XX] (rendering stage)
        
        REP #$10
        
        LDX $1CD9 : INX
        
        ; Speed, also mirror location for speed
        LDA $7F1200, X : STA $1CD6 : STA $1CD5
        
        ; Move to the next byte
        INX : STX $1CD9
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$7518D-$751BC JUMP LOCATION
    VWF_Command7B:
    {
        ; [Command 7B] - unused?
        ; Seems like it was intended to draw a item graphics (2bpp) 
        ; selected from a list to screen, not sure though.
        REP #$30
        
        INC $1CD9 : LDX $1CD9
        
        LDA $7F1200, X : AND.w #$007F : ASL #2 : TAX
        
        LDY $1CDD
        
        LDA .unknown, X : STA $12D8, Y
        
        INX #2
        
        LDA .unknown, X : STA $1300, Y
        
        INY #2
        
        STY $1CDD
        
        INC $1CD9
        
        SEP #$30
        
        JMP $C984 ; $74984 IN ROM
    }

; ==============================================================================

    ; *$751BD-$751F8 JUMP LOCATION
    VWF_Command7C:
    {
        ; Command 0x7C (unused)
        REP #$30
        
        INC $1CD9 : LDX $1CD9
        
        LDA $7F1200, X : AND.w #$007F : ASL #3 : TAX
        
        LDA.w #$0002 : STA $00

        LDY $1CDD
    
    .alpha
    
        LDA Text_Command_7C_Data, X : STA $12D8, Y
        
        INX #2
        
        LDA Text_Command_7C_Data, X : STA $1300, Y
        
        INX #2
        
        INY #2
        
        DEC $00 : BNE .alpha
        
        STY $1CDD
        
        INC $1CD9
        
        SEP #$30
        
        JMP $C984 ; $74984 IN ROM
    }

; ==============================================================================

    ; *$751F9-$7522F JUMP LOCATION
    VWF_ClearBuffer:
    {
        ; This routine sets $7F:0000 to $7F:07DF to zero.
        ; This could of course be sped up with a $2180 DMA transfer. (which I plan on doing)
        ; Large zeroing loops are annoying time dumps :(
        ; Update: I cut it from 40+ scanlines to 12 scanlines
        
        PHB : LDA.b #$7F : PHA : PLB
        
        REP #$30
        
        LDA.w #$07D0 : TAX

    .zeroLoop

        STZ $0000, X : STZ $0002, X : STZ $0004, X : STZ $0006, X
        STZ $0008, X : STZ $000A, X : STZ $000C, X : STZ $000E, X
        
        SUB.w #$0010 : TAX : BPL .zeroLoop
        
        PLB
        
        ; Initialize the text buffer positions
        STZ $1CDD
        
        INC $1CD9
        
        SEP #$30
        
        STZ $1CE6
        
        RTS
    }

; ==============================================================================

    ; *$75230-$7525A JUMP LOCATION
    VWF_WaitKey:
    {
        ; [WaitKey] command
        ; waits for ... duh... someone to press a button
        
        ; Note this is set to 0x1C when the game enters text mode
        LDA $1CE9 : BEQ .readyForInput
        
        DEC A : STA $1CE9 : CMP.b #$01 : BNE .return
        
        ; Play that flutey sound effect.
        LDA.b #$24 : STA $012F
        
        BRA .return
    
    .readyForInput
    
        ; SNES equivalent to "press any key to continue", checks for A, B, X, and Y presses
        LDA $00F4 : ORA $00F6 : AND.b #$C0 : BEQ .return
        
        ; If a key is pressed, move on to the next character or command
        REP #$30
        
        INC $1CD9
        
        SEP #$30
        
        ; Reset the delay timer (almost half a second)
        LDA.b #$1C : STA $1CE9
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$7525B-$7527F JUMP LOCATION
    VWF_EndMessage:
    {
        ; [End] Command
        
        LDA $1CE9 : BEQ .readyForInput
        
        DEC A : STA $1CE9 : CMP.b #$01 : BNE .return
        
        ; Play flutey sound effect
        LDA.b #$24 : STA $012F
        
        BRA .return
    
    .readyForInput
    
        ; This command will take any joypad input as the signal to continue,
        ; unlike [WaitKey]
        LDA $F4 : ORA $F6 : BEQ .return
        
        ; Exit Text mode
        LDA.b #$04 : STA $1CD4
        LDA.b #$1C : STA $1CE9
    
    .return
    
        RTS
    }

; ==============================================================================

    ; *$75280-$7529B LOCAL
    Text_SetDefaultWindowPos:
    {
        ; Determines one of two positions for the text box,
        ; based on what Link's vertical position is.
        
        REP #$30
        
        ; Get Link's Y coordinate, Subtract Y coordinate of scroll register
        ; This is a nifty trick, an alternative to branching to load one of two values
        LDA $20 : SUB $E8 : CMP.w #$0078 : ROL A : EOR.w #$0001 : AND.w #$0001 : ASL A : TAX
        
        ; Ultimately, a vram address gets stored here, so the system knows where to draw the tiles
        LDA Text_Positions, X : STA $1CD2
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$7529C-$752AA LOCAL
    Text_InitBorderOffsets:
    {
        REP #$30
        
        LDA $1CD2 : STA $1CD0
        
        LDX.w #$0000 : TXY
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$752AB-$752EB LOCAL
    Text_DrawBorderRow:
    {
        REP #$30
        
        ; Store the big endian version of the base VRAM address
        LDA $1CD0 : XBA : STA $1002, X
        
        INX #2
        
        ; Our vram address will be moving "down", so increment by 32 words
        XBA : ADD.w #$0020 : STA $1CD0
        
        ; Write 0x30 bytes, use incrementing dma mode, increment on writes to $2119
        LDA.w #$2F00 : STA $1002, X : INX #2
        
        LDA Text_BorderTiles, Y : STA $1002, X : INX #2
        
        INY #2
        
        LDA.w #$0016 : STA $0E
        
        LDA Text_BorderTiles, Y
    
    .repeatTile
    
        STA $1002, X
        
        INX #2
        
        DEC $0E : BNE .repeatTile
        
        INY #2
        
        LDA Text_BorderTiles, Y : STA $1002, X
        
        INX #2
        
        RTS
    }

; ==============================================================================

    ; *$752EC-$75306 LOCAL
    Text_BuildCharacterTilemap:
    {
        REP #$30
        
        LDX.w #$0000
    
    ; This loop fills $7E1300[0xFC] with incremented values of $1CE2
    ; Which is the starting tilemap entry value. Generally speaking, this tilemap entry
    ; has settings that are determined earlier during initialization. Some of those settings
    ; are variable at compile time, like vflip (0), hflip (0), priority(1), chr (0x180).
    ; Each iteration of this loop is essentially increasing the chr property, all the way up to
    ; 0x27b. Later on, the VWF will be constructing 
    .buildLoop
    
        LDA $1CE2 : STA $1300, X
        
        INC $1CE2
        
        INX #2 : CPX.w #$00FC : BCC .buildLoop
        
        JSR Text_DrawCharacterTilemap
        
        SEP #$30
        
        RTS
    }

; ==============================================================================

    ; *$75307-$75359 LOCAL
    Text_DrawCharacterTilemap:
    {
        ; This routine is where the tilemap actually gets configured to be transferred to
        ; vram during the NMI interrupt.
        
        !num_columns = $0C
        !num_rows    = $0E
        
        ; ----------------------------------------
        
        REP #$30
        
        LDA.w #$0006 : STA !num_rows
        
        JSR Text_InitBorderOffsets
        
        REP #$30
        
        ; Move vram target address down one tile and to the right one tile from the upper left
        ; corner of the message box's border address in vram.
        LDA $1CD0 : ADD.w #$0021 : STA $1CD0
    
    .nextRow
    
        ; Store vram address (big endian, not sure why they felt like it was good to do that)
        LDA $1CD0 : XBA : STA $1002, X
        
        ; Make it so the dma will start one row down from this one (adding 0x20 to a vram address
        ; typically accopmlishes this if you can be sure that you'll remain in the same tilemap)
        XBA : ADD.w #$0020 : STA $1CD0
        
        ; dma will transfer 0x2a bytes (which is twice 0x15 or 21). Each row is 21 tiles,
        ; so this makes sense.
        INX #2 : LDA.w #$2900 : STA $1002, X
        INX #2
        
        LDA.w #$0015 : STA !num_columns
    
    ; The rows will contain tilemap entries that reference chr values 0x180 through 0x194, the next
    ; 0x195 to 0x1a9, 0x1aa to 0x1be, to 0x1bf to 0x1d3, ... I think...
    .nextColumn
    
        ; Store consecutive tilemap entries from the buffer we generated just prior this subroutine call
        LDA $1300, Y : STA $1002, X
        
        INX #2
        INY #2
        
        DEC !num_columns : BNE .nextColumn
        DEC !num_rows    : BNE .nextRow
        
        LDA.w #$FFFF : STA $1002, X
        
        SEP #$30
        
        LDA.b #$01 : STA $14
        
        RTS
    }
    
; ==============================================================================

    ; $7535A-$75379
    Text_InitializationData:
    {
        ; Nothing of note here, sets $1CD0-$1CD7 to 0x00
        db $00, $00, $00, $00, $00, $00, $00, $00
        
        ; Of note, this first byte sets $1CD8, to 1, advancing the submodule index in the text module
        ; The 5th byte sets $1CDC 0b00111001 (unused variable, but best guess indicates that it would
        ; direct a previous version of the engine to set the priority bits in VWF tilemap entries,
        ; and use palette 6, and to use chr starting at 0x100
        db $01, $00, $00, $00, $39, $00, $00, $00
        
        ; Not sure if the rest of this is in fact intended for initialization of text mode variables
        db $00, $00, $00, $00, $00, $00, $00, $00, $00, $1C, $04, $00, $00, $00, $00, $00    
    }
    
    ; $7537A-$7537E
    ; unused?
    {
        db $00, $00, $00, $00, $00
    }
    
; ==============================================================================

    ; $7537F-$75390 DATA
    Text_BorderTiles:
    {
    .top
        dw $28F3, $28F4, $28F3
        
    .middle
        dw $28C8, $387F, $68C8
        
    .bottom
        dw $A8F3, $A8F4, $E8F3
    }
    
; ==============================================================================

    ; $75391-$75394
    Text_Positions:
    {
        dw $6125, $6244
    }
    
; ==============================================================================

    ; $75395-$75398
    pool Text_Close:
    {
    .reg_config
    
        dw $2E42
    
    .data
    
        dw $387F
    }
    
; ==============================================================================

    ; $75399-$7539E DATA
    VWF_LinePositions:
    {
        ; line position values
        dw $0000, $0028, $0050
    }
    
; ==============================================================================

    ; $7539F-$753A6 DATA
    Text_Command_7C_Data:
    {
        ; For use with command 0x7C (looks like items if you look at vram)
        dw $24B8, $24BA, $24BC, $24BE
    }
    
; ==============================================================================

    ; $753A7-$753AE DATA
    pool VWF_Command7B:
    {
    
    .unknown
        ; For use with command 0x7B (looks like items if you look at vram)
        dw $24B8, $24BA, $24BC, $24BE
    }
    
; ==============================================================================

    ; $753AF-$753CE DATA
    Text_WaitDurations:
    {
        ; as expressed in frames or (1/60ths of a second)
        dw $001F, $003F, $005E, $007D, $009C, $00BC, $00DB, $00FA
        dw $0119, $0139, $0158, $0177, $0196, $01B6, $01D5, $01F4
    }
    
; ==============================================================================

    ; $753CF-$753D1
    Text_UnusedData:
    {
        ; unused? I can't find this used anywhere in the rom,
        ; and it has no clear contextual hidden usage, except maybe they used
        ; to have more commands, but I think it's a stretch that one of them was 8
        ; bytes long.... dunno
        db 8, 3, 1
    }
    
    ; $753D2-$753EA
    Text_CommandLengths:
    {
        ; Command argument lengths, starting with command 0x67 all the way up to
        ; command 0x7f (terminate). The length includes the command itself, for reference.
        db 1, 1, 1, 1, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1
        db 2, 2, 2, 2, 1, 1, 1, 1, 1
    }

; ==============================================================================

    ; *$753EB-$7544A LONG
    Text_GenerateMessagePointers:
    {
        ; In this routine:
        ; $00[3] - index into $1C:8000
        
        !commandLengthTable = Text_CommandLengths-$67
        
        ; -------------------------------------------
        
        PHB : PHK : PLB
        
        ; Would indicate that memory accesses at $00 will have
        ; Bank 1C/2 = 8 + 6 = E IN ROM
        LDA.b #$1C : STA $02
        
        REP #$30
        
        ; $00[3]: $1C8000, which is rom address $E0000
        LDA.w #$8000 : STA $00
        
        LDX.w #$0000
    
    .nextPointer
    
        LDA $00 : STA $7F71C0, X
        
        ; $7F71C0[3] = #$1C8000 on the first iteration
        LDA $01 : STA $7F71C1, X
        
        INX #3
    
    .keepGoing
    
        ; $1C8000 => $E0000 IN ROM
        LDA [$00] : AND.w #$00FF : TAY
        
        LDA !commandLengthTable, Y : AND.w #$00FF
        
        CPY.w #$0067 : BCC .characterCodeOrDictionary
        CPY.w #$0080 : BCC .isCommand
    
    .characterCodeOrDictionary
    
        ; characters and dictionary entries are always 1 byte, whereas
        ; commands are variable length (1 or 2)
        LDA.w #$0001
    
    .isCommand
    
        ; Increment our position in the pointer table by one.
        ADD $00 : STA $00
        
        ; Is it the terminator byte? If so, load the next pointer
        CPY.w #$007F : BEQ .nextPointer
        
        ; refers to the fact that you won't switch data sets yet
        CPY.w #$0080 : BNE .noSwitch
        
        ; A byte of 0x80 indicates the end of all text
        DEX #3
        
        LDA.w #$DF40 : STA $00
        
        LDA.w #$000E : STA $02
        
        BRA .nextPointer
    
    .noSwitch
    
        ; This is not entirely necessary but I guess it provides another stop condition
        CPY.w #$00FF : BNE .keepGoing
        
        SEP #$30
        
        PLB
        
        RTL
    }

; ==============================================================================
