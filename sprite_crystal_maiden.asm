
; ==============================================================================

    ; $F4CD3-$F4CE2 DATA
    pool CrystalMaiden_Configure:
    {
    
    .palette
        dw $0000, $3821, $4463, $54A5, $5CE7, $6D29, $79AD, $7E10
    }

; ==============================================================================

    ; *$F4CE3-$F4D47 LONG
    CrystalMaiden_Configure:
    {
        ; USED DURING THE CRYSTAL SEQUENCE
        
        ; Enable color addition on backdrop/obj/bg1/bg2
        LDA.b #$33 : STA $9A
        
        LDA.b #$00 : STA $7EC007
                     STA $7EC009
        
        PHX
        
        JSL Palette_AssertTranslucencySwap
        JSL PaletteFilter_Crystal
        
        PLX
        
        REP #$20
        
        LDA.l .palette + $00 : STA $7EC5E0
        LDA.l .palette + $02 : STA $7EC5E2
        LDA.l .palette + $04 : STA $7EC5E4
        LDA.l .palette + $06 : STA $7EC5E6
        LDA.l .palette + $08 : STA $7EC5E8
        LDA.l .palette + $0A : STA $7EC5EA
        LDA.l .palette + $0C : STA $7EC5EC
        LDA.l .palette + $0E : STA $7EC5EE
        
        SEP #$30
        
        INC $15
        
        JSR CrystalMaiden_SpawnAndConfigMaiden
        JSR CrystalMaiden_InitPolyhedral
        
        RTL
    }

; ==============================================================================

    ; *$F4D48-$F4DD8 LOCAL
    CrystalMaiden_SpawnAndConfigMaiden:
    {
        LDY.b #$0F
        LDA.b #$00
    
    .kill_next_sprite
    
        ; Kill all normal sprites on screen.
        STA $0DD0, Y
        
        DEY : BPL .kill_next_sprite
        
        ; Create a maiden.
        LDA.b #$AB : JSL Sprite_SpawnDynamically
        
        ; Give the maiden the same upper byte coordinates as Link.
        LDA $23 : STA $0D30, Y
        
        LDA $21 : STA $0D20, Y
        
        LDA.b #$78 : STA $0D10, Y
        
        LDA.b #$7C : STA $0D00, Y
        
        LDA.b #$01 : STA $0DE0, Y
        
        LDA.b #$0B : STA $0F50, Y
        
        LDA.b #$00 : STA $0E80, Y : STA $0F20, Y
        
        PHY
        
        ; Resets certains actions the player might be doing, like using the
        ; hookshot or carrying extensions.
        JSL Ancilla_TerminateSelectInteractives
        
        STZ $02E9
        
        TYA : PLY : STA $0D90, Y
        
        LDA $040C : CMP.b #$18 : BNE .not_in_turtle_rock
        
        ; Zelda has a special palette.
        LDA.b #$09 : STA $0F50, Y
        
        ; Use a Zelda tagalong
        LDA.b #$01
        
        BRA .load_tagalong_graphics
    
    .not_in_turtle_rock
    
        ; Use a maiden tagalong
        LDA.b #$06
    
    .load_tagalong_graphics
    
        STA $7EF3CC
        
        PHX
        
        JSL Tagalong_LoadGfx
        
        PLX
        
        LDA.b #$00 : STA $7EF3CC
        
        STZ $0428
        
        REP #$20
        
        ; what? sec : adc ? ohhhhhhhh. it's being all clever and shit.
        ; the normal way to get the negative of a number in 2's complement
        ; is to xor all the bits (0xffff) and then add 1. This is just doing it
        ; by way of the addition. So it is in fact a pure add of 0x0079, really.
        LDA $22 : SUB $E2 : EOR.w #$FFFF : SEC : ADC.w #$0079 : STA $0422
        
        LDA $E6 : AND.w #$00FF : STA $00
        
        LDA.w #$0030 : SUB $00 : STA $0424
        
        SEP #$30
        
        LDA.b #$01 : STA $0428 ; Set a special flag.
        
        RTS
    }

; ==============================================================================

    ; *$F4DD9-$F4E02 LOCAL
    CrystalMaiden_InitPolyhedral:
    {
        LDA.b #$9C : STA $1F02
        
        LDA.b #$01 : STA $1F01
                     STA $012A
                     STA $1F00
        
        LDA.b #$20 : STA $1F06
                     STA $1F07
                     STA $1F08
        
        STZ $1F03
        
        LDA.b #$10 : STA $1F04
        
        STZ $1D
        
        LDA.b #$16 : STA $1C
        
        RTS
    }

; ==============================================================================

    ; *$F4E03-$F4E38 JUMP LOCATION
    Sprite_CrystalMaiden:
    {
        ; Crystal Maiden sprite (after beating Dark World Palace)
        
        REP #$20
        
        LDA $0FD8 : SUB $0422 : STA $0FD8
        LDA $0FDA : SUB $0424 : STA $0FDA
        
        SEP #$30
        
        LDA $0D80, X : CMP.b #$03 : BCC .not_visible
        
        JSL CrystalMaiden_Draw
    
    .not_visible
    
        LDA.b #$01 : STA $012A
        
        LDA $1F00 : BNE .polyhedral_thread_sync
        
        JSR CrystalMaiden_Main
        
        LDA.b #$01 : STA $1F00
    
    .polyhedral_thread_sync
    
        RTS
    }

; ==============================================================================

    ; *$F4E39-$F4E62 LOCAL
    CrystalMaiden_Main:
    {
        INC $0E90, X
        
        LDA $1F05 : ADD.b #$06 : STA $1F05
        
        LDA $11 : BEQ .basic_submodule
        
        RTS
    
    .basic_submodule
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw CrystalMaiden_DisableSubscreen
        dw CrystalMaiden_EnableSubscreen
        dw CrystalMaiden_GenerateSparkles
        dw CrystalMaiden_FilterPalette
        dw CrystalMaiden_FilterPalette.finish
        dw CrystalMaiden_ShowMessage
        dw CrystalMaiden_ReadingComprehensionExam
        dw CrystalMaiden_MayTheWayOfTheHero
        dw CrystalMaiden_InitiateDungeonExit
    }

; ==============================================================================

    ; *$F4E63-$F4E68 JUMP LOCATION
    CrystalMaiden_DisableSubscreen:
    {
        STZ $1D
        
        INC $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$F4E69-$F4E70 JUMP LOCATION
    CrystalMaiden_EnableSubscreen:
    {
        LDA.b #$01 : STA $1D
        
        INC $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$F4E71-$F4E92 JUMP LOCATION
    CrystalMaiden_GenerateSparkles:
    {
        LDA $1F02 : CMP.b #$06 : BCS .delay
        
        STZ $1F02
        
        INC $0D80, X
        
        RTS
    
    .delay
    
        SBC.b #$03 : STA $1F02 : CMP.b #$40 : BCC .delay_2
        
        PHX
        
        LDA $0D90, X : TAX
        
        JSL Sprite_SpawnSparkleAncilla
        
        PLX
    
    .delay_2
    
        RTS
    }

; ==============================================================================

    ; *$F4E93-$F4EBB JUMP LOCATION
    CrystalMaiden_FilterPalette:
    {
        INC $0D80, X
    
    ; *$F4E96 ALTERNATE ENTRY POINT
    .finish
    
        LDA $0E90, X : AND.b #$01 : BNE .delay
        
        PHX
        
        ; does palette filtering of some sort...
        JSL Palette_Filter_SP5F
        
        PLX
        
        LDA $7EC007 : BNE .filtering_not_finished
        
        INC $0D80, X
        
        LDA.b #$01 : STA $02E4
        
        STZ $02D8
        STZ $02DA
        STZ $2E
        STZ $2F
    
    .filtering_not_finished
    .delay
    
        RTS
    }

; ==============================================================================

    ; $F4EBC-$F4ECD DATA
    pool CrystalMaiden_ShowMessage:
    {
    
    .message_ids
        dw $0133, $0132, $0137, $0134, $0136, $0132, $0135, $0138
        dw $013c
    }

; ==============================================================================

    ; *$F4ECE-$F4F17 JUMP LOCATION
    CrystalMaiden_ShowMessage:
    {
        ; Load the dungeon index. Is it the Dark Palace?
        LDA $040C : SUB.b #$0A : TAY : CPY.b #$02 : BNE .not_dark_palace
        
        LDA $7EF3C7 : CMP.b #$07 : BCS .dont_update_map_icons
        
        LDA.b #$07 : STA $7EF3C7
    
    .dont_update_map_icons
    .not_dark_palace
    
        ; Is it Turtle Rock?
        CPY.b #$0E : BNE .not_turtle_rock
        
        ; How many Crystals do we have?
        ; We have all the crystals.
        LDA $7EF37A : AND.b #$7F : CMP.b #$7F : BEQ .have_all_crystals
        
        LDY.b #$10 ; Otherwise Zelda says something different.
    
    .have_all_crystals
    .not_turtle_rock
    
        ; Loads the Message ID.
        LDA .message_ids+0, Y       : XBA
        LDA .message_ids+1, Y : TAY : XBA
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        LDA $7EF37A : AND.b #$7F : CMP.b #$7F : BNE .dont_have_all_crystals
        
        ; Update the map icon to just be Ganon's Tower
        LDA.b #$08 : STA $7EF3C7
    
    .dont_have_all_crystals
    
        RTS
    }

; ==============================================================================

    ; *$F4F18-$F4F23 JUMP LOCATION
    CrystalMaiden_ReadingComprehensionExam:
    {
        ; "Do you understand?"
        ; ">  Yes[3]         "
        ; "Not at all[Choose]"
        LDA.b #$3A
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$F4F24-$F4F3A JUMP LOCATION
    CrystalMaiden_MayTheWayOfTheHero:
    {
        LDA $1CE8 : BEQ .player_said_yes
        
        LDA.b #$05 : STA $0D80, X
        
        RTS
    
    .player_said_yes
    
        ; "May the way of the Hero lead to the Triforce."
        LDA.b #$39
        LDY.b #$01
        
        JSL Sprite_ShowMessageUnconditional
        
        INC $0D80, X
        
        RTS
    }

; ==============================================================================

    ; *$F4F3B-$F4F46 JUMP LOCATION
    CrystalMaiden_InitiateDungeonExit:
    {
        STZ $1D
        
        PHX
        
        JSL PrepDungeonExit
        
        PLX
        
        STZ $0DD0, X
        
        RTS
    }

; ==============================================================================

