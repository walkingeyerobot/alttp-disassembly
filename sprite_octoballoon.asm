
; ==============================================================================

    ; $356A2-$356A9 DATA
    pool Sprite_Octoballoon:
    {
    
    .altitudes
        db 16, 17, 18, 19, 20, 19, 18, 17
    }

; ==============================================================================

    ; *$356AA-$3572A JUMP LOCATION
    Sprite_Octoballoon:
    {
        LDA $0E80, X : LSR #3 : AND.b #$07 : TAY
        
        LDA .altitudes, Y : STA $0F70, X
        
        JSR Octoballoon_Draw
        JSR Sprite_CheckIfActive
        
        LDA $0DF0, X : BNE .delay_bursting
        
        LDA.b #$03 : STA $0DF0, X
        
        ; \note Interesting thing about this loop is that it seems to assume
        ; that at one point the game devs designed for more than one Octoballoon
        ; being on screen at a time. However, I tried it out and having two
        ; of these things burst at once is a recipe for some pretty good
        ; slowdown.
        LDY.b #$0F
    
    .search_for_octobabies
    
        LDA $0DD0, Y : BEQ .inactive_sprite
        
        LDA $0E20, Y : CMP.b #$10 : BEQ .delay_bursting
    
    .inactive_sprite
    
        DEY : BPL .search_for_octobabies
        
        LDA.b #$06 : STA $0DD0, X
        
        JMP Octoballoon_ScheduleForDeath
    
    .delay_bursting
    
        JSR Sprite_CheckIfRecoiling
        
        INC $0E80, X
        
        TXA : EOR $1A : AND.b #$0F : BNE .skip_speed_check_logic
        
        LDA.b #$04 : JSR Sprite_ProjectSpeedTowardsPlayer
        
        LDA $0D40, X : CMP $00 : BEQ .at_target_y_speed
                                 BPL .above_target_y_speed
        
        INC $0D40, X
        
        BRA .check_x_speed
    
    .above_target_y_speed
    
        DEC $0D40, X
    
    .at_target_y_speed
    .check_x_speed
    
        LDA $0D50, X : CMP $01 : BEQ .at_target_x_speed
                                 BPL .above_target_x_speed
        
        INC $0D50, X
        
        BRA .speed_check_logic_complete
    
    .above_target_x_speed
    
        DEC $0D50, X
    
    .at_target_x_speed
    .speed_check_logic_complete
    .skip_speed_check_logic
    
        JSR Sprite_Move
        
        ; \note The Octoballoon can't actually damage the player, only its
        ; spawn can.
        JSR Sprite_CheckDamageToPlayer : BCC .no_player_collision
        
        JSR Octoballoon_ApplyRecoilToPlayer
    
    .no_player_collision
    
        JSR Sprite_CheckDamageFromPlayer
        JSR Sprite_CheckTileCollision
        JSR Sprite_WallInducedSpeedInversion
        
        RTS
    }

; ==============================================================================

    ; *$3572B-$3573B LOCAL
    Octoballoon_ApplyRecoilToPlayer:
    {
        LDA $46 : BNE .player_invulnerable_right_now
        
        LDA.b #$04 : STA $46
        
        LDA.b #$10 : JSR Sprite_ApplyRecoilToPlayer
        
        JSR Sprite_Invert_XY_Speeds
    
    .player_invulnerable_right_now
    
        RTS
    }

; ==============================================================================

    ; $3573C-$35783 DATA
    pool Octoballoon_Draw:
    {
        ; \task Fill in data.
    }

; ==============================================================================

    ; *$35784-$35801 LOCAL
    Octoballoon_Draw:
    {
        STZ $0A
        
        LDA $0DD0, X : CMP.b #$06 : BNE .not_dying
        
        LDA $0DF0, X : CMP.b #$06 : BNE .dont_spawn_babies
        
        LDA $11 : BNE .dont_spawn_babies
        
        JSR Octoballoon_SpawnTheSpawn
    
    .dont_spawn_babies
    
        LDA $0DF0, X : LSR A : AND.b #$04 : ADD.b #$04 : STA $0A
    
    .not_dying
    
        JSR Sprite_PrepOamCoord
        
        PHX
        
        LDA.b #$03 : STA $0B
        
        ADD $0A : TAX
    
    .next_oam_entry
    
        PHX
        
        TXA : ASL A : TAX
        
        REP #$20
        
        LDA $00 : ADD $D73C, X : STA ($90), Y
        
        AND.w #$0100 : STA $0E
        
        LDA $02 : ADD $D754, X : INY : STA ($90), Y
        
        ADD.w #$0010 : CMP #$0100 : SEP #$20 : BCC .on_screen_y
        
        LDA.b #$F0 : STA ($90), Y
    
    .on_screen_y
    
        PLX
        
        LDA $D76C, X           : INY : STA ($90), Y
        LDA $D778, X : ORA $05 : INY : STA ($90), Y
        
        PHY
        
        TYA : LSR #2 : TAY
        
        LDA.b #$02 : ORA $0F : STA ($92), Y
        
        PLY : INY
        
        DEX
        
        DEC $0B : BPL .next_oam_entry
        
        PLX
        
        JMP Sprite_DrawShadow
    }

; ==============================================================================

    ; $35802-$3580D DATA
    pool Octoballoon_SpawnTheSpawn:
    {
    
    .x_speeds
        db  16,  11, -11, -16, -11,  11
    
    .y_speeds
        db   0,  11,  11,   0, -11, -11
    }

; ==============================================================================

    ; hehe.
    ; *$3580E-$35842 LOCAL
    Octoballoon_SpawnTheSpawn:
    {
        LDA.b #$0C : JSL Sound_SetSfx2PanLong
        
        LDA.b #$05 : STA $0D
    
    .spawn_loop
    
        LDA.b #$10
        
        JSL Sprite_SpawnDynamically : BMI .spawn_failed
        
        JSL Sprite_SetSpawnedCoords
        
        PHX
        
        LDX $0D
        
        LDA .x_speeds, X : STA $0D50, Y
        
        LDA .y_speeds, X : STA $0D40, Y
        
        LDA.b #$30 : STA $0F80, Y
        
        LDA.b #$FF : STA $0E80, Y
        
        PLX
    
    .spawn_failed
    
        DEC $0D : BPL .spawn_loop
        
        RTS
    }

; ==============================================================================
