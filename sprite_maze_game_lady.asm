
; ==============================================================================

    ; *$6CB54-$6CB5B LONG
    Sprite_MazeGameLadyLong:
    {
        PHB : PHK : PLB
        
        JSR Sprite_MazeGameLady
        
        PLB
        
        RTL
    }

; ==============================================================================

    ; *$6CB5C-$6CB7D LOCAL
    Sprite_MazeGameLady:
    {
        JSL Lady_Draw
        JSR Sprite5_CheckIfActive
        JSL Sprite_MakeBodyTrackHeadDirection
        
        JSL Sprite_DirectionToFacePlayerLong : TYA : EOR.b #$03 : STA $0EB0, X
        
        LDA $0D80, X
        
        JSL UseImplicitRegIndexedLocalJumpTable
        
        dw MazeGameLady_Startup
        dw MazeGameLady_PlayStartingNoise
        dw MazeGameLady_AccumulateTime
    }

; ==============================================================================

    ; *$6CB7E-$6CBB9 JUMP LOCATION
    MazeGameLady_Startup:
    {
        LDA $0D10, X : CMP $22 : BCS .yous_a_cheater
        
        ; "... reach the goal within 15 seconds, we will give you something..."
        LDA.b #$CC
        LDY.b #$00
        
        JSL Sprite_ShowMessageFromPlayerContact : BCC .didnt_speak
        
        STA $0EB0, X : STA $0DE0, X
        
        INC $0D80, X
        
        LDA.b #$00 : STA $7FFE00 : STA $7FFE01 : STA $7FFE02 : STA $7FFE03
        
        STZ $0D90, X
        
        STZ $0ABF
    
    .didnt_speak
    
        RTS
    
    .yous_a_cheater
    
        ; "You have to enter the maze from the proper entrance..."
        LDA.b #$D0
        LDY.b #$00
        
        JSL Sprite_ShowMessageFromPlayerContact
        
        RTS
    }

; ==============================================================================

    ; *$6CBBA-$6CBDF JUMP LOCATION
    MazeGameLady_AccumulateTime:
    {
        INC $0D90, X : LDA $0D90, X : CMP.b #$3F : BNE .no_reset_frame_counter
        
        STZ $0D90, X
        
        REP #$20
        
        LDA $7FFE00 : INC A : STA $7FFE00 : BNE .dont_increment_minute_counter
        
        LDA $7FFE02 : INC A : STA $7FFE02
    
    .dont_increment_minute_counter
    
        SEP #$30
    
    .no_reset_frame_counter
    
        RTS
    }

; ==============================================================================

    ; *$6CBE0-$6CBE9 JUMP LOCATION
    MazeGameLady_PlayStartingNoise:
    {
        LDA.b #$07 : JSL Sound_SetSfx3PanLong
        
        INC $0D80, X
        
        RTS
    }

; ==============================================================================
