
; ==============================================================================

    ; *$2E675-$2E67C LONG
    SpritePrep_SnitchesLong:
    {
        ; Sprite Prep for Scared Lady, Scared Ladies, and Inn Keeper? (0x3D, 0x34, 0x35 ?)
        
        PHB : PHK : PLB
        
        JSR SpritePrep_Snitches
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$2E67D-$2E699 LOCAL
    SpritePrep_Snitches:
    {
        LDA.b #$02 : STA $0DE0, X : STA $0EB0, X
        
        INC $0BA0, X
        
        LDA $0D10, X : STA $0D90, X
        LDA $0D30, X : STA $0DA0, X
        
        LDA.b #$F7 : STA $0D50, X
        
        RTS
    }

; ==============================================================================

    ; *$2E69A-$2E6A1 LONG
    Sprite_OldSnitchLadyLong:
    {
        ; Scared Ladies / Chicken Lady (0x3D)
        
        PHB : PHK : PLB
        
        JSR Sprite_OldSnitchLady
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; $2E6A2-$2E6A9 DATA
    
    {
    
        ; \task Name these sublabels and the routines that use them.
    .x_speeds
        db  0,  0, -9,  9
    
    .y_speeds
        db -9,  9,  0,  0
    }

; ==============================================================================

    ; *$2E6AA-$2E705 LOCAL
    Sprite_OldSnitchLady:
    {
        LDA $0E30, X : BEQ .not_indoor_chicken_lady
        
        JSL Sprite_ChickenLadyLong
        
        RTS
    
    .not_indoor_chicken_lady
    
        LDA $0D80, X : CMP.b #$03 : BCS .not_visible
        
        ; Draws the old lady...
        JSL Lady_Draw
    
    .not_visible
    
    ; *$2E6BF ALTERNATE ENTRY POINT
    shared Sprite_Snitch:
    
        JSR Sprite2_CheckIfActive
        
        LDA $0D80, X : CMP.b #$03 : BCS .gamma
        
        LDA $1B : BEQ .outdoors
        
        JSL Sprite_MakeBodyTrackHeadDirection
        
        JSR Sprite2_DirectionToFacePlayer : TYA : EOR.b #$03 : STA $0EB0, X
        
        ; \tcrf (verified), submitted)
        ; You can place this sprite indoors and it behaves as a old lady
        ; looking sign that just tells you to head west for
        ; a bomb shop. Wtf? Debug sprite for testing?
        ; Looks like an old lady, and faces you, but has no collision.
        
        ; Wtf is this message doing here? I thought this was for a sprite, not
        ; a sign.
        
        ; "This Way"
        ; "<- Bomb Shop"
        LDA.b #$AD
        LDY.b #$00
        
        JSL Sprite_ShowSolicitedMessageIfPlayerFacing
        
        RTS
    
    .outdoors
    
        LDA $0D80, X : BNE .skip_player_collision_logic
        
        JSL Sprite_CheckDamageToPlayerSameLayerLong : BCS Snitch_FacePlayer
    
    .skip_player_collision_logic
    
        JSL Sprite_MakeBodyTrackHeadDirection : BCC Snitch_SetShortTimer
        
        JSR Sprite2_Move
    
    .gamma
    
    ; *$2E6F7 ALTERNATE ENTRY POINT
    shared Snitch_RunStateHandler:
    
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw $E71A ; = $2E71A*
        dw $E78D ; = $2E78D*
        dw $E831 ; = $2E831*
        dw $E887 ; = $2E887*
    }

; ==============================================================================

    ; *$2E706-$2E715 BRANCH LOCATION
    Snitch_FacePlayer:
    {
        JSR Sprite2_DirectionToFacePlayer : TYA : EOR.b #$03 : STA $0DE0, X
    
    ; $2E70F ALTERNATE ENTRY POINT
    shared Snitch_SetShortTimer:
    
        LDA.b #$01 : STA $0DF0, X
        
        BRA Snitch_RunStateHandler
    }

; ==============================================================================

    ; $2E716-$2E719 DATA
    {
    
        ; \task Name these sublabels and the routines that use them.
        db -32, 32
    
    
        db -1,   0
    }

; ==============================================================================

    ; *$2E71A-$2E78C JUMP LOCATION
    {
        LDA $0DF0, X : BNE .alpha
        
        LDY $0DB0, X
        
        LDA $0D90, X : ADD $E716, Y : CMP $0D10, X : BNE .alpha
        
        LDA $0D90, X : ADD $E716, Y
        
        LDA $0DA0, X : ADC $E718, Y : CMP $0D30, X : BNE .alpha
        
        LDA $0DE0, X : EOR.b #$01 : STA $0EB0, X : TAY
        
        LDA $E6A2, Y : STA $0D50, X
        
        LDA $E6A6, Y : STA $0D40, X
        
        LDA $0DB0, X : EOR.b #$01 : STA $0DB0, X
    
    .alpha
    
        TXA : EOR $1A : LSR #4 : AND.b #$01 : STA $0DC0, X
        
        LDA $0F60, X : PHA
        
        LDA.b #$03 : STA $0F60, X
        
        ; "Hey! Here is [Name], the wanted man! Soldiers! Anyone! Come quickly!"
        LDA.b #$2F
        LDY.b #$00
        
        JSL Sprite_ShowMessageFromPlayerContact
        
        TAY
        
        PLA : STA $0F60, X : BCC .beta
        
        TYA : STA $0DE0, X
        
        JSL SpawnCrazyVillageSoldier
        
        INC $0D80, X
    
    .beta
    
        RTS
    }

    ; *$2E78D-$2E830 JUMP LOCATION
    {
        STZ $0EB0, X
        
        LDY $0FDE
        
        LDA $0B18, Y : STA $00
        LDA $0B20, Y : STA $01
        
        LDA $0D00, X : STA $02
        LDA $0D20, X : STA $03
        
        REP #$20
        
        LDA $00 : CMP $02 : SEP #$30 : BCC .alpha
        
        INC $0D80, X
        
        STZ $0D50, X
        STZ $0D40, X
        
        LDA.b #$02 : STA $0F60, X
        
        LDA $0B08, Y : STA $02
        LDA $0B10, Y : STA $03
        
        PHX
        
        REP #$30
        
        LDA $00 : SUB $0708 : AND $070A : ASL #3 : STA $04
        
        LDA $02 : LSR #3 : SUB $070C : AND $070E : ADD $04 : TAX
        
        CLC
        
        JSL Overworld_DrawWoodenDoor
        
        PLX
        
        LDA.w #$10 : STA $0DF0, X
        
        RTS
    
    .alpha
    
        LDA.b #$01 : STA $02E4
        
        LDA $0B08, Y : STA $04
        LDA $0B10, Y : STA $05
        
        LDA $0B18, Y : STA $06
        LDA $0B20, Y : STA $07
        
        LDA.b #$40
        
        JSL Sprite_ProjectSpeedTowardsEntityLong
        
        LDA $00 : STA $0D40, X
        LDA $01 : STA $0D50, X
        
        STZ $0DE0, X
        STZ $0EB0, X
        
        TXA : EOR $1A : LSR #3 : AND.b #$01 : STA $0DC0, X
        
        RTS
    }

    ; *$2E831-$2E886 JUMP LOCATION
    {
        LDA $0DF0, X : BNE .alpha
        
        LDY $0FDE
        
        LDA $0B18, Y : STA $0D00, X : STA $00
        LDA $0B20, Y : STA $0D20, X : STA $01
        
        LDA $0B08, Y : STA $0D10, X : STA $02
        LDA $0B10, Y : STA $0D30, X : STA $03
        
        PHX
        
        REP #$30
        
        LDA $00          : SUB $0708 : AND $070A : ASL #3  : STA $04
        
        LDA $02 : LSR #3 : SUB $070C : AND $070E : ADD $04 : TAX
        
        SEC
        
        JSL Overworld_DrawWoodenDoor
        
        PLX
        
        INC $0D80, X
    
    .alpha
    
        JSR Sprite2_Move
        
        RTS
    }

    ; *$2E887-$2E88D JUMP LOCATION
    {
        STZ $0DD0, X
        STZ $02E4
        
        RTS
    }

; ==============================================================================

