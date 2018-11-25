
; ==============================================================================

    ; *$288C5-$288D5 JUMP LOCATION
    Sprite_MasterSword:
    {
        LDA $0E80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw MasterSword_Main
        dw Sprite_MasterLightFountain 
        dw Sprite_MasterLightBeam 
        dw Sprite_MasterSwordPendant
        dw Sprite_MasterLightWell
    }

; ==============================================================================

    ; *$288D6-$28907 JUMP LOCATION
    MasterSword_Main:
    {
        LDA $10 : CMP.b #$1A : BEQ .in_end_sequence
        
        PHX
        
        LDX $8A
        
        LDA $7EF280, X : PLX : AND.b #$40 : BEQ .hasnt_been_taken
        
        JMP MasterSword_Terminate
    
    .hasnt_been_taken
    .in_end_sequence
    
        LDA $0D80, X : CMP.b #$05 : BEQ .skip_routine
        
        JSR MasterSword_Draw
    
    .skip_routine
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw MasterSword_ReadyAndWaiting
        dw MasterSword_PendantsInTransit
        dw MasterSword_CrankUpLightShow
        dw MasterSword_LightShowIsCrunk
        dw MasterSword_GrantToPlayer
        dw MasterSword_Terminate
    }

; ==============================================================================

    ; *$28908-$2894C JUMP LOCATION
    MasterSword_ReadyAndWaiting:
    {
        ; (Player in unusual pose => fail)
        JSL Sprite_CheckIfPlayerPreoccupied : BCS .cant_pull
        
        ; (Not in contact with the sprite => fail)
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCC .cant_pull
        
        LDA $2F : CMP.b #$02 : BNE .cant_pull
        
        ; (The 'A' button hasn't been pressed => fail)
        LDA $F6 : BPL .cant_pull
        
        ; (Don't have three pendants => fail)
        LDA $7EF374 : AND.b #$07 : CMP.b #$07 : BNE .cant_pull
        
        ; play "retrieving the master sword" music
        LDA.b #$0A : STA $012C
        
        LDA.b #$01 : STA $037B
        
        ; Spawn each of the pendant helper sprites
        LDA.b #$09 : JSR MasterSword_SpawnPendant
        LDA.b #$0B : JSR MasterSword_SpawnPendant
        LDA.b #$0F : JSR MasterSword_SpawnPendant
        
        JSR MasterSword_SpawnLightWell
        
        INC $0D80, X
        
        LDA.b #$F0 : STA $0DF0, X
    
    .cant_pull
    
        RTS
    }

; ==============================================================================

    ; *$2894D-$28967 JUMP LOCATION
    MasterSword_PendantsInTransit:
    {
        LDA $0DF0, X : BNE .wait
        
        JSR MasterSword_SpawnLightFountain
        
        INC $0D80, X
        
        LDA.b #$C0 : STA $0DF0, X
    
    .wait
    
        ; Special pose for Link?
        LDA.b #$0A : STA $0377
        
        ; Link can't move...
        LDA.b #$01 : STA $02E4
        
        RTS
    }

; ==============================================================================

    ; *$28968-$2899C JUMP LOCATION
    MasterSword_CrankUpLightShow:
    {
        LDA $0DF0, X : BNE .wait
        
        LDY.b #$FF : JSR MasterSword_SpawnLightBeams
        
        INC $0D80, X
        
        LDA.b #$08 : STA $0DF0, X
    
    .wait
    
        LDA.b #$0A
        
        BRA .immobilize_player
    
    ; *$2897E ALTERNATE ENTRY POINT
    shared MasterSword_LightShowIsCrunk:
    
        LDA $0DF0, X : BNE .wait_2
        
        LDA.b #$01
        LDY.b #$FF
        
        JSR MasterSword_SpawnLightBeams
        
        INC $0D80, X
        
        LDA.b #$10 : STA $0DF0, X
    
    .wait_2
    
        LDA.b #$0B
    
    .immobilize_player
    
        STA $0377
        
        ; Link can't move...
        LDA.b #$01 : STA $02E4
        
        RTS
    }

; ==============================================================================

    ; *$2899D-$289C5 JUMP LOCATION
    MasterSword_GrantToPlayer:
    {
        LDA $0DF0, X : BNE .wait
        
        PHX
        
        LDX $8A
        
        ; Make it so the Master Sword won't show up again here.
        LDA $7EF280, X : ORA.b #$40 : STA $7EF280, X
        
        LDY.b #$01
        
        STZ $02E9
        
        JSL Link_ReceiveItem
        
        PLX
        
        ; Change Overworld map icon set
        LDA.b #$05 : STA $7EF3C7
        
        ; Disable this shit, whatever it was (probably player oam related).
        STZ $0377
        
        INC $0D80, X
    
    .wait
    
        RTS
    }

; ==============================================================================

    ; *$289C6-$289C9 JUMP LOCATION
    MasterSword_Terminate:
    {
        STZ $0DD0, X
        
        RTS
    }

; ==============================================================================

    ; $289CA-$289DB DATA
    pool Sprite_MasterLightFountain:
    {
    
    .animation_states
        db $00, $01, $01, $02, $02, $02, $01, $01, $00
    
    .unknown
        db $00, $00, $01, $01, $02, $02, $00, $00, $00
    }

; ==============================================================================

    ; *$289DC-$28A15 JUMP LOCATION
    Sprite_MasterLightFountain:
    {
        JSR MasterSword_DrawLightBall
        
        INC $0D90, X : LDA $0D90, X : BNE .alpha
        
        INC $0DB0, X
        
        STZ $0DD0, X
    
    .alpha
    
        LSR #2 : AND.b #$03 : STA $0DE0, X
        
        LDA $0D90, X : LSR #5 : AND.b #$07 : TAY
        
        LDA .animation_states, Y : STA $0DC0, X
        
        LDA .unknown, Y : BEQ .beta
        
        TAY
        
        LDA $0D90, X : LSR #2 : AND.b #$01
        
        JSR MasterSword_SpawnLightBeams
    
    .beta
    
        RTS
    }

; ==============================================================================

    ; *$28A16-$28A33 JUMP LOCATION
    Sprite_MasterLightWell:
    {
        JSR MasterSword_DrawLightBall
        
        INC $0D90, X : LDA $0D90, X : BNE .alpha
        
        INC $0DB0, X
        
        STZ $0DD0, X
    
    .alpha
    
        LSR #2 : AND.b #$03 : STA $0DE0, X
        
        LDA.b #$00 : STA $0DC0, X
        
        RTS
    }

; ==============================================================================

    ; $28A34-$28A93 DATA
    pool MasterSword_DrawLightBall:
    {
    
    .animation_states
        dw -6, 4 : db $82, $00, $00, $02
        dw -6, 4 : db $82, $40, $00, $02
        dw -6, 4 : db $82, $C0, $00, $02
        dw -6, 4 : db $82, $80, $00, $02
        dw -6, 4 : db $A0, $00, $00, $02
        dw -6, 4 : db $A0, $40, $00, $02
        dw -6, 4 : db $A0, $C0, $00, $02
        dw -6, 4 : db $A0, $80, $00, $02
        dw -6, 4 : db $80, $00, $00, $02
        dw -6, 4 : db $80, $40, $00, $02
        dw -6, 4 : db $80, $C0, $00, $02
        dw -6, 4 : db $80, $80, $00, $02
    }

; ==============================================================================

    ; *$28A94-$28AB5 LOCAL
    MasterSword_DrawLightBall:
    {
        ; Generic routine that can draw either the light fountain (bigger) 
        ; or the light well (smaller). Technically the light well and fountain
        ; could have been merged into the same sprite, I'm fairly certain of
        ; this.
        
        LDA.b #$04 : JSL OAM_AllocateFromRegionC
        
        LDA $0DC0, X : ASL #2 : ADC $0DE0, X : ASL #3 
        
        ADC.b #((.animation_states >> 0) & $FF)              : STA $08
        LDA.b #((.animation_states >> 8) & $FF) : ADC.b #$00 : STA $09
        
        LDA.b #$01
    
    ; *$28AB1 ALTERNATE ENTRY POINT
    shared Sprite_DrawMultipleRedundantCall:
    
        ; The point of the name I chose for this routine is that there's 
        ; really no reason why client code couldn't just call
        ; Sprite_DrawMultiple directly, so this is just a waste of cpu time.
        
        JSL Sprite_DrawMultiple
        
        RTS
    }

; ==============================================================================

    ; *$28AB6-$28ACF LOCAL
    MasterSword_SpawnLightWell:
    {
        LDA.b #$62
        
        JSL Sprite_SpawnDynamically
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$04 : STA $0E80, Y
        LDA.b #$05 : STA $0F50, Y
        LDA.b #$00 : STA $0E40, Y
        
        RTS
    }

; ==============================================================================

    ; *$28AD0-$28AE9 LOCAL
    MasterSword_SpawnLightFountain:
    {
        LDA.b #$62
        
        JSL Sprite_SpawnDynamically
        JSL Sprite_SetSpawnedCoords
        
        LDA.b #$01 : STA $0E80, Y
        LDA.b #$05 : STA $0F50, Y
        LDA.b #$00 : STA $0E40, Y
        
        RTS
    }

; ==============================================================================

    ; *$28AEA-$28B07 JUMP LOCATION
    Sprite_MasterLightBeam:
    {
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        LDA $0D90, X : BEQ .alpha
        
        JSR Sprite2_Move
        
        LDA $1A : AND.b #$03 : BNE .beta
        
        JSR MasterLightBeam_SpawnAnotherBeam
    
    .alpha
    
        DEC $0DA0, X : BNE .beta
        
        STZ $0DD0, X
    
    .beta
    
        RTS
    }

; ==============================================================================

    ; $28B08-$28B1F DATA
    pool MasterSword_SpawnLightBeams:
    {
    
    .x_speeds_1
        db $00, $D0
        
    .x_speeds_2
        db $00, $30
    
    .x_speeds_3
        db $A0, $D0
    
    .x_speeds_4
        db $60, $30
        
    .y_speeds_1
        db $A0, $D0
    
    .y_speeds_2
        db $60, $30
    
    .y_speeds_3
        db $00, $30
    
    .y_speeds_4
        db $00, $D0
        
    .animation_states_1
        db $01, $00
    
    .animation_states_2
        db $03, $02
    
    .oam_properties_1
        db $05, $45
    
    .oam_properties_2
        db $05, $05
    }

; ==============================================================================

    ; *$28B20-$28B61 LOCAL
    MasterLightBeam_SpawnAnotherBeam:
    {
        ; Not sure if the name is 100% accurate, but I can always change it
        ; later.
        
        LDA.b #$62
        
        JSL Sprite_SpawnDynamically : BMI .alpha
        
        LDA $00 : ADD.b #$00 : STA $0D10, Y
        LDA $01 : ADC.b #$00 : STA $0D30, Y
        
        LDA $02 : ADD.b #$00 : STA $0D00, Y
        LDA $03 : ADC.b #$00 : STA $0D20, Y
        
        LDA.b #$02 : STA $0E80, Y
        
        LDA.b #$03 : STA $0DA0, Y
        
        LDA $0DC0, X : STA $0DC0, Y
        
        LDA $0F50, X : STA $0F50, Y
        
        LDA.b #$00 : STA $0E40, Y
    
    .alpha
    
        RTS
    }

; ==============================================================================

    ; *$28B62-$28CD2 LOCAL
    MasterSword_SpawnLightBeams:
    {
        PHY : PHA
        
        LDA.b #$62
        
        JSL Sprite_SpawnDynamically : BPL .success_1
        
        JMP .spawn_failed
    
    .success_1
    
        LDA $00 : SUB.b #$04 : STA $0D10, Y
        LDA $01 : SBC.b #$00 : STA $0D30, Y
        
        LDA $02 : ADD.b #$04 : STA $0D00, Y
        LDA $03 : ADC.b #$00 : STA $0D20, Y
        
        LDA.b #$02 : STA $0E80, Y : STA $0D90, Y
        
        LDA.b #$00 : STA $0E40, Y
        
        PLA
        
        PHX
        
        TAX
        
        LDA .x_speeds_1, X : STA $0D50, Y
        
        LDA .y_speeds_1, X : STA $0D40, Y
        
        LDA .animation_states_1, X : STA $0DC0, Y
        
        LDA .oam_properties_1, X : STA $0F50, Y
        
        TXA
        
        PLX
        
        STA $00
        
        PLA : STA $0DA0, Y : PHA
        
        LDA $00 : PHA
        
        LDA.b #$62
        
        JSL Sprite_SpawnDynamically : BPL .success_2
        
        JMP .spawn_failed
    
    .success_2
    
        LDA $00 : SUB.b #$04 : STA $0D10, Y
        LDA $01 : SBC.b #$00 : STA $0D30, Y
        
        LDA $02 : ADD.b #$04 : STA $0D00, Y
        LDA $03 : ADC.b #$00 : STA $0D20, Y
        
        LDA.b #$02 : STA $0E80, Y : STA $0D90, Y
        
        LDA.b #$00 : STA $0E40, Y
        
        PLA
        
        PHX
        
        TAX
        
        LDA .x_speeds_2, X : STA $0D50, Y
        
        LDA .y_speeds_2, X : STA $0D40, Y
        
        LDA .animation_states_1, X : STA $0DC0, Y
        
        LDA .oam_properties_1, X : STA $0F50, Y
        
        TXA
        
        PLX
        
        STA $00
        
        PLA : STA $0DA0, Y : PHA
        
        LDA $00 : PHA
        
        LDA.b #$62
        
        JSL Sprite_SpawnDynamically : BPL .success_3
        
        JMP .spawn_failed
    
    .success_3
    
        LDA $00 : SUB.b #$04 : STA $0D10, Y
        LDA $01 : SBC.b #$00 : STA $0D30, Y
        
        LDA $02 : ADD.b #$04 : STA $0D00, Y
        LDA $03 : ADC.b #$00 : STA $0D20, Y
        
        LDA.b #$02 : STA $0E80, Y : STA $0D90, Y
        
        LDA.b #$00 : STA $0E40, Y
        
        PLA
        
        PHX
        
        TAX
        
        LDA .x_speeds_3, X : STA $0D50, Y
        
        LDA .y_speeds_3, X : STA $0D40, Y
        
        LDA .animation_states_2, X : STA $0DC0, Y
        
        LDA .oam_properties_2, X : STA $0F50, Y
        
        TXA
        
        PLX
        
        STA $00
        
        PLA : STA $0DA0, Y
        
        PHA
        
        LDA $00 : PHA
        
        LDA.b #$62
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        LDA $00 : SUB.b #$04 : STA $0D10, Y
        LDA $01 : SBC.b #$00 : STA $0D30, Y
        
        LDA $02 : ADD.b #$04 : STA $0D00, Y
        LDA $03 : ADC.b #$00 : STA $0D20, Y
        
        LDA.b #$02 : STA $0E80, Y : STA $0D90, Y
        
        LDA.b #$00 : STA $0E40, Y
        
        PLA
        
        PHX
        
        TAX
        
        LDA .x_speeds_4, X : STA $0D50, Y
        
        LDA .y_speeds_4, X : STA $0D40, Y
        
        LDA .animation_states_2, X : STA $0DC0, Y
        
        LDA .oam_properties_2, X : STA $0F50, Y
        
        TXA
        
        PLX
        
        PLA : STA $0DA0, Y
        
        RTS
    
    .spawn_failed
    
        PLA : PLY
        
        RTS
    }

; ==============================================================================

    ; *$28CD3-$28D28 LOCAL
    MasterSword_SpawnPendant:
    {
        PHA
        
        ; Master Sword and beams of light ceremony
        LDA.b #$62
        
        JSL Sprite_SpawnDynamically
        
        PLA : STA $0F50, Y
        
        LDA $22 : STA $0D10, Y
        LDA $23 : STA $0D30, Y
        
        LDA $20 : ADD.b #$08 : STA $0D00, Y
        LDA $21 : ADC.b #$00 : STA $0D20, Y
        
        LDA.b #$04 : STA $0DC0, Y
        
        LDA.b #$03 : STA $0E80, Y
        
        LDA.b #$40 : STA $0E40, Y
        
        LDA.b #$E4 : STA $0DF0, Y
        
        PHX
        
        LDA $0F50, Y : LSR A : AND.b #$03 : TAX
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        PLX
        
        RTS
    
    .x_speeds
        db $FC, $04, $00, $00
    
    .y_speeds
        db $FE, $FE, $FC, $FC
    }

; ==============================================================================

    ; *$28D29-$28D3F JUMP LOCATION
    Sprite_MasterSwordPendant:
    {
        LDA.b #$04 : JSL OAM_AllocateFromRegionB
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw MasterSwordPendant_DriftingAway
        dw MasterSwordPendant_Flashing
        dw MasterSwordPendant_FlyAway
    }

; ==============================================================================

    ; *$28D40-$28D56 JUMP LOCATION
    MasterSwordPendant_DriftingAway:
    {
        JSR Sprite2_Move
        
        LDA $0DF0, X : BNE .wait
        
        INC $0D80, X
        
        LDA.b #$D0 : STA $0DF0, X
        
        LDA $0F50, X : STA $0D90, X
    
    .wait
    
        RTS
    }

; ==============================================================================

    ; *$28D57-$28D79 JUMP LOCATION
    MasterSwordPendant_Flashing:
    {
        LDA $0F50, X : AND.b #$F1 : STA $0F50, X
        
        TXA : ASL A : EOR $1A : AND.b #$0E : ORA $0F50, X : STA $0F50, X
        
        LDA $0DF0, X : BNE .wait
        
        INC $0D80, X
        
        ; Restore original palette color (blue, green, or red).
        LDA $0D90, X : STA $0F50, X
    
    .wait
    
        RTS
    }

; ==============================================================================

    ; *$28D7A-$28D95 JUMP LOCATION
    MasterSwordPendant_FlyAway:
    {
        ; This one gives me the impression of being poorly put together.
        ; I could be wrong, but I don't think it works as intended. Will
        ; will have to observe this in real time.
        
        JSR Sprite2_Move
        
        LDA $0DF0, X : BNE .wait
        
        ; double X and Y speed.... but not quite? (negative speeds would be...
        ; reversed)
        ASL $0D50, X
        
        ASL $0D40, X
        
        LDA.b #$06 : STA $0DF0, X
    
    .wait
    
        INC $0E90, X : BNE .beta
        
        STZ $0DD0, X
    
    .beta
    
        RTS
    }

; ==============================================================================

    ; $28D96-$28DA7 DATA
    pool MasterSword_Draw:
    {
    
    .x_offsets
        db -8,  0, -8,  0, -8,  0
    
    .y_offsets
        db -8, -8,  0,  0,  8,  8
    
    .chr
        db $C3, $C4, $D3, $D4, $E0, $F0
    }


; ==============================================================================

    ; *$28DA8-$28DD7 LOCAL
    MasterSword_Draw:
    {
        JSR Sprite2_PrepOamCoord
        
        PHX
        
        LDX.b #$05
    
    .alpha
    
        LDA $00 : ADD .x_offsets, X       : STA ($90), Y
        LDA $02 : ADD .y_offsets, X : INY : STA ($90), Y
        LDA .chr, X                  : INY : STA ($90), Y
        
        INY
        
        LDA $05 : STA ($90), Y
        
        INY
        
        DEX : BPL .alpha
        
        PLX
        
        LDY.b #$00
        LDA.b #$05
        
        JSL Sprite_CorrectOamEntriesLong
        
        RTS
    }

; ==============================================================================
