
; ==============================================================================

    ; $11ECA-$11EDB Jump Table
    pool Module_GanonEmerges:
    {
    
    .submodules
        dw GanonEmerges_GetBirdForPursuit
        dw GanonEmerges_PrepForPyramidLocation
        dw GanonEmerges_FadeOutDungeonScreen
        dw GanonEmerges_LOadPyramidArea
        dw GanonEmerges_LoadAmbientOverlay
        dw GanonEmerges_BrightenScreenThenSpawnBat
        dw GanonEmerges_DelayForBatSmashIntoPyramid
        dw GanonEmerges_DelayPlayerDropOff
        dw GanonEmerges_DropOffPlayerAtPyramid
    }

; ==============================================================================

    ; *$11EDC-$11F2E JUMP LOCATION LONG
    Module_GanonEmerges:
    {
        REP #$21
        
        LDA $E2 : PHA : ADC $011A : STA $E2 : STA $011E
        LDA $E8 : PHA : ADD $011C : STA $E8 : STA $0122
        LDA $E0 : PHA : ADD $011A : STA $E0 : STA $0120
        LDA $E6 : PHA : ADD $011C : STA $E6 : STA $0124
        
        SEP #$20
        
        JSL Sprite_Main
        
        REP #$20
        
        PLA : STA $E6
        PLA : STA $E0
        PLA : STA $E8
        PLA : STA $E2
        
        SEP #$20
        
        LDA $0200 : ASL A : TAX
        
        JSR (.submodules, X)
        
        JML PlayerOam_Main
    }

; ==============================================================================

    ; *$11F2F-$11F41 LOCAL
    GanonEmerges_GetBirdForPursuit:
    {
        JSL Effect_Handler
        JSL GanonEmerges_SpawnTravelBird
        JSL Dungeon_SaveRoomData.justKeys
        
        INC $0200
        INC $02E4
        
        RTS
    }

; ==============================================================================

    ; *$11F42-$11F5D LOCAL
    GanonEmerges_PrepForPyramidLocation:
    {
        JSL Effect_Handler
        
        LDA $11 : CMP.b #$0A : BNE .dont_transfer_yet
        
        LDA.b #$5B : STA $8A
        
        STZ $1B
        
        LDA.b #$18 : STA $10
        
        STZ $11
        
        LDA.b #$02 : STA $0200
    
    .dont_transfer_yet
    
        RTS
    }

; ==============================================================================

    ; *$11F5E-$11F75 LOCAL
    GanonEmerges_FadeOutDungeonScreen:
    {
        JSL Effect_Handler
        
        DEC $13 : BNE .not_fully_darkened
        
        JSL EnableForceBlank
        
        INC $0200
        
        JSL HUD.RebuildIndoor
        
        STZ $30 : STZ $31
    
    .not_fully_darkened
    
        RTS
    }

; ==============================================================================

    ; *$11F76-$11F8A LOCAL
    GanonEmerges_LOadPyramidArea:
    {
        ; The 9th bird travel target is only accessible via this code.
        ; It also happens to put you in the Dark World.
        LDA.b #$08 : STA $1AF0
                     STZ $1AF1
        
        JSL BirdTravel_LoadTargetArea
        JSR Overworld_LoadMusicIfNeeded
        
        ; Load the dark world music.
        LDA.b #$09 : STA $012C
        
        RTS
    }

; ==============================================================================

    ; *$11F8B-$11F93 LOCAL
    GanonEmerges_LoadAmbientOverlay:
    {
        JSL BirdTravel_LoadAmbientOverlay
        
        LDA.b #$00 : STA $B0
        
        RTS
    }

; ==============================================================================

    ; *$11F94-$11FC0 LOCAL
    GanonEmerges_BrightenScreenThenSpawnBat:
    {
        ; Module 0x18, submodule 0x05
        
        INC $13
        
        ; Wait until screen reaches full brightness
        LDA $13 : CMP.b #$0F : BNE .still_brightening
        
        STZ $0402
        STZ $0403
        STZ $0FC1
        
        JSL GanonEmerges_SpawnRetreatBat
        
        LDA.b #$02 : STA $2F
        
        LDA.b #$09 : STA $010C
        
        STZ $1B
        
        INC $0200 ; Go to the next submodule
        
        LDA.b #$80 : STA $B0
        
        LDA.b #$FF : STA $040C
    
    ; $11FC0 ALTERNATE ENTRY POINT
    shared GanonEmerges_DelayForBatSmashIntoPyramid:
    
    .still_brightening
    .return
    
        RTS
    }

; ==============================================================================

    ; *$11FC1-$11FC8 LOCAL
    GanonEmerges_DelayPlayerDropOff:
    {
        ; \wtf Why not juse branch to this routine's return instruction?!!
        ; *rolls eyes*
        DEC $B0 : BNE GanonEmerges_DelayForBatSmashIntoPyramid.return
        
        INC $0200
        
        RTS
    }

; ==============================================================================

    ; *$11FC9-$11FCD LOCAL
    GanonEmerges_DropOffPlayerAtPyramid:
    {
        ; \wtf Wasn't the previous module dungeon?
        JSL BirdTravel_Finish.restore_prev_module
        
        RTS
    }

; ==============================================================================
