
; ==============================================================================

    {set0 word i},
    {set1 word j},
    {set2 word k}  => {states word i, j, k}
    
    pool foo1:
    {
         
    .set0
        dw a0
        dw a1
        dw a2
        dw a3
     
     .set1
        dw b0
        dw b1
        dw b2
        dw b3
    
    .set2
        dw c0
        dw c1
        dw c2
        dw c3
    }
    
    ; transformed state
    {
    
    .states
        dw a0, b0, c0
        dw a1, b1, c1
        dw a2, b2, c2
        dw a3, b3, c3
    }
    
; ==============================================================================

    {states word i} => {lowers byte i.lower},
                       {uppers byte i.upper}
    {
    
    .states
        dw a0
        dw a1
        dw a2
        dw a3
        dw a4
        dw a5
        dw a6
    }
    
    ; transformed state
    {
    
    .lowers
        db a0
        db a1
        db a2
        db a3
        db a4
        db a5
        db a6
        
    ; references such as lda .states+1 would start here
    .uppers
        db a0 >> 8
        db a1 >> 8
        db a2 >> 8
        db a3 >> 8
        db a4 >> 8
        db a5 >> 8
        db a6 >> 8
    }
    
; ==============================================================================

    {states long i} => {lowers word i      },
                       {uppers byte i >> 16}
    {
    
    .states
        dl a0
        dl a1
        dl a2
        dl a3
        dl a4
        dl a5
        dl a6
    }
    
    ; transformed state
    {
    
    .lowers
        dw a0
        dw a1
        dw a2
        dw a3
        dw a4
        dw a5
        dw a6
        
    .uppers
        db a0 >> 16
        db a1 >> 16
        db a2 >> 16
        db a3 >> 16
        db a4 >> 16
        db a5 >> 16
        db a6 >> 16
    }

; ==============================================================================

    ; similar to how bank 0x00 has its first jump table set up
    {states long i} => {bottoms byte i     },
                       {middles byte i >> 8},
                       {banks   byte i >> 16}
    {
    
    .states 
        dl a0
        dl a1
        dl a2
        dl a3
        dl a4
        dl a5
        dl a6
    }
    
    ; transformed state
    {
    
    .bottoms
        dw a0
        dw a1
        dw a2
        dw a3
        dw a4
        dw a5
        dw a6
        
    .middles
        db a0 >> 8
        db a1 >> 8
        db a2 >> 8
        db a3 >> 8
        db a4 >> 8
        db a5 >> 8
        db a6 >> 8
        
    .banks
        db a0 >> 16
        db a1 >> 16
        db a2 >> 16
        db a3 >> 16
        db a4 >> 16
        db a5 >> 16
        db a6 >> 16
    }
    
; ==============================================================================

    ; trying to work out a syntax for de-interleaving...
    {states word i, j, k} => {set0 word i},
                             {set1 word j},
                             {set2 word k}
    
    pool foo1:
    {
    
    .states
        dw a0, b0, c0
        dw a1, b1, c1
        dw a2, b2, c2
        dw a3, b3, c3
    }
    
    ; transformed state
    {
         
    .set0
        dw a0
        dw a1
        dw a2
        dw a3
     
     .set1
        dw b0
        dw b1
        dw b2
        dw b3
    
    .set2
        dw c0
        dw c1
        dw c2
        dw c3
    }

; ==============================================================================

