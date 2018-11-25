
    ; $1EA1D-$1EAE0 LONG
    {
        LDA $F2 : AND.b #$10 : BNE .r_button_held
        
        JMP .fail
    
    .r_button_held
    
        REP #$20
        
        LDA $7003D9 : CMP.w #$00AF : BNE .fail
        LDA $7003DB : CMP.w #$010A : BNE .fail
        LDA $7003DD : CMP.w #$010A : BNE .fail
        LDA $7003DF : CMP.w #$010A : BNE .fail
        
        SEP #$20
        
        ; \wtf 0x0A to this variable seems... bad. More research needed.
        STA $7EF37B
        
        LDA $F6
        
        JSL .check_button_press
        
        LDA $7EF359 : CMP.b #$04 : BNE .not_golden_sword
        
        LDA.b #$03 : STA $7EF35A
        DEC A      : STA $7EF35B
    
    .not_golden_sword
    
        LDA $F4 : BPL .b_button_not_pressed
        
        LDA $037F : EOR.b #$01 : STA $037F
    
    .b_button_not_pressed
    
        BIT $F4 : .y_button_not_pressed
        
        ; refill all hearts, magic, bombs, and arrows
        LDA.w #$FF : STA $7EF372
                    STA $7EF373
                    STA $7EF375
                    STA $7EF376
        
        ADD $7EF360 : STA $7EF360
        
        LDA $7EF361 : ADC.b #$00 : STA $7EF361
        
        LDA.b #$09 : STA $7EF36F
    
    .y_button_not_pressed
    
        RTL
    
    .fail
    
        SEP #$20
        
        LDA $F3 : AND.b #$10 : BEQ .return
        
        LDA $F7 : BPL .return
        
        LDA $7EF359 : INC A : CMP.b #$05 : BCC .valid_sword
        
        LDA.b #$01 : STA $7EF359
    
    .valid_sword
    
        LDA $7EF35B : INC A : CMP.b #$03 : BNE .valid_armor
        
        LDA.b #$00
    
    .valid_armor
    
        LDA $7EF35A : INC A : CMP.b #$04 : BNE .valid_shield
        
        LDA.b #$01
    
    .valid_shield
    
        STA $7EF35A
    
    .return
    
        RTL
    }