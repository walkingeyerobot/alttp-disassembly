
; ==============================================================================

    ; *$F3CE8-$F3D22 JUMP LOCATION
    Sprite_SpikeBlock:
    {
        LDA $0E90, X : BNE Sprite_TransientSpikeBlock
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckDamage
        JSR Sprite3_Move
        JSR Sprite3_CheckTileCollision
        
        LDA $0DF0, X : BNE .ignore_collision
        
        JSR SpikeBlock_CheckStatueSpriteCollision : BCC .no_sprite_collision
        
        LDA $0E70, X : AND.b #$0F : BEQ .no_tile_collision
    
    .no_sprite_collision
    
        LDA.b #$04 : STA $0DF0, X
        
        LDA $0D50, X : EOR.b #$FF : INC A : STA $0D50, X
        
        LDA.b #$05 : JSL Sound_SetSfx2PanLong
    
    .no_tile_collision
    .ignore_collision
    
        RTS
    }

; ==============================================================================

    ; $F3D23-$F3D4A BRANCH LOCATION
    Sprite_TransientSpikeBlock:
    {
        ; \note Spike blocks created by Mothula end up here.
        
        LDA.b #$04 : JSL OAM_AllocateFromRegionB
        
        JSL Sprite_PrepAndDrawSingleLargeLong
        JSR Sprite3_CheckIfActive
        JSR Sprite3_CheckDamage
        
        LDA $0D80, X : BNE TransientSpikeBlock_Activated
        
        ; Transmute a bg-based spike block into a mobile one (this sprite),
        ; but erase the underlying bg-based one.
        LDY.b #$00 : JSR SpikeBlock_InduceTilemapUpdate
        
        INC $0D80, X
        
        LDA.b #$40 : STA $0DF0, X
        
        LDA.b #$69 : STA $0E00, X
        
        RTS
    }

; ==============================================================================

    ; $F3D4B-$F3D4C DATA
    pool TransientSpikeBlock_Activated:
    {
    
    .wiggle_x_speeds
        db 8, -8
    }

; ==============================================================================

    ; *$F3D4D-$F3D73 BRANCH LOCATION
    TransientSpikeBlock_Activated:
    {
        LDA $0DF0, X : BEQ TransientSpikeBlock_InMotion
        CMP.b #$01   : BNE .wiggling
        
        LDA $0D90, X : STA $0D10, X
        
        LDA $0DA0, X : STA $0D00, X
        
        RTS
    
    .wiggling
    
        ; \note While this may look weird, what it does is it wiggles the spike
        ; block before it becomes fully detatched.
        LSR A : AND.b #$01 : TAY
        
        LDA .wiggle_x_speeds, Y : STA $0D50, X
        
        JSR Sprite3_MoveHoriz
        
        STZ $0D50, X
        
        RTS
    }

; ==============================================================================

    ; $F3D74-$F3D7F DATA
    pool TransientSpikeBlock_InMotion:
    {
    
    .target_x_speeds
        db 32, -32
    
    .target_y_speeds
        db  0,   0,  32, -32
    
    .x_acceleration
        db  1,  -1
    
    .y_acceleration
        db  0,   0,   1,  -1
    }

; ==============================================================================

    ; *$F3D80-$F3DC7 BRANCH LOCATION
    TransientSpikeBlock_InMotion:
    {
        LDA $0D80, X : CMP.b #$01 : BNE TransientSpikeBlock_Retract
        
        ; \note This branch will never be taken. But with an actual nonzero
        ; mask this could have been used to slow down the acceleration.
        LDA $1A : AND.b #$00 : BNE .acceleration_delay
        
        LDY $0DE0, X
        
        LDA $0D50, X : CMP .target_x_speeds, Y : BEQ .at_target_x_speed
        
        ADD .x_acceleration, Y : STA $0D50, X
    
    .at_target_x_speed
    
        LDA $0D40, X : CMP .target_y_speeds, Y : BEQ .at_target_y_speed
        
        ADD .y_acceleration, Y : STA $0D40, X
    
    .at_target_y_speed
    .acceleration_delay
    
        JSR Sprite3_Move
        
        LDA $0E00, X : BNE .skip_tile_collision_logic
        
        JSL Sprite_Get_16_bit_CoordsLong
        
        JSR Sprite3_CheckTileCollision : BEQ .no_tile_collision
        
        INC $0D80, X
        
        LDA.b #$40 : STA $0E00, X
    
    .no_tile_collision
    .skip_tile_collision_logic
    
        RTS
    }

; ==============================================================================

    ; $F3DC8-$F3DCF DATA
    pool TransientSpikeBlock_Retract:
    {
    
    .x_speeds
        db -16,  16,   0,   0
    
    .y_speeds
        db   0,   0, -16,   0
    }

; ==============================================================================

    ; *$F3DD0-$F3DFF BRANCH LOCATION
    TransientSpikeBlock_Retract:
    {
        ; \note The spike block waits at its current position and then
        ; retracts back to where it spawned from.
        LDA $0E00, X : BNE .delay
        
        LDY $0DE0, X
        
        LDA .x_speeds, Y : STA $0D50, X
        
        LDA .y_speeds, Y : STA $0D40, X
        
        JSR Sprite3_Move
        
        LDA $0D10, X : CMP $0D90, X : BNE .not_at_target_coord
        
        LDA $0D00, X : CMP $0DA0, X : BNE .not_at_target_coord
        
        STZ $0DD0, X
        
        ; Place a bg-based spike block here as the sprite version terminates.
        LDY.b #$02 : JSR SpikeBlock_InduceTilemapUpdate
    
    .not_at_target_coord
    .delay
    
        RTS
    }

; ==============================================================================

    ; *$F3E00-$F3E18 LOCAL
    SpikeBlock_InduceTilemapUpdate:
    {
        LDA $0D10, X : STA $00
        LDA $0D30, X : STA $01
        
        LDA $0D00, X : STA $02
        LDA $0D20, X : STA $03
        
        JSL Dungeon_SpriteInducedTilemapUpdate
        
        RTS
    }

; ==============================================================================

    ; *$F3E19-$F3E7D LOCAL
    SpikeBlock_CheckStatueSpriteCollision:
    {
        ; This subroutine checks collisions between the sprite block and
        ; other selected sprites.
        
        LDY.b #$0F
    
    .next_sprite_slot
    
        TYA : EOR $1A : AND.b #$01 : BNE .delay
        
        LDA $0DD0, Y : BEQ .inactive_sprite
        
        LDA $0E20, Y : CMP.b #$1C : BNE .not_movable_statue
        
        LDA $0D10, X : STA $00
        LDA $0D30, X : STA $01
        
        LDA $0D00, X : STA $02
        LDA $0D20, X : STA $03
        
        LDA $0D10, Y : STA $04
        LDA $0D30, Y : STA $05
        
        LDA $0D00, Y : STA $06
        LDA $0D20, Y : STA $07
        
        REP #$20
        
        LDA $00 : SUB $04 : ADD.w #$0010 : CMP.w #$0020 : BCS .no_collision
        
        LDA $02 : SUB $06 : ADD.w #$0008 : CMP.w #$0010 : BCS .no_collision
        
        SEP #$20
        
        RTS
    
    .no_collision
    
        SEP #$20
    
    .delay
    .not_movable_statue
    .inactive_sprite
    
        DEY : BPL .next_sprite_slot
        
        SEC
        
        RTS
    }

; ==============================================================================

