WRITE_EEPROM_GAME ; se implementa lectura tambien para recorrer las ultimas dos y poder sobreescribir la mas reciente
    movlw .3
    movwf EEADR, A
    ; Protocolo lectura
    bsf	EECON1, 0, A ;habilitar lectura
    movff EEDATA, temp_eeprom1 ; se guarda la part mas reciente en una var temp
    movlw .2
    movwf EEADR, A
    bsf	 EECON1, 0, A ;habilitar lectura
    movff EEDATA, temp_eeprom2 ; se guarda la 2nda part mas reciente en una var temp
    bcf EECON1, 0 , A ; se inhabilita la lectura
    ; se inicia sobreescritura
actualizar3_reciente
    movlw .3
    movwf EEADR, A
    movf puntaje, A
    movwf EEDATA, A ; pasamos el puntaje obtenido hasta ese punto al EEDATA
    call protocolo_escritura_eeprom ; se realiza el protocolo y se escribe
    ; checa si se copio el valor correcto
    movf puntaje,  A
    bsf EECON1 , 0, A ; habilita lectura del .3 recien agregado
    subwf EEDATA, W, A ; resta lectura - puntaje para verificar
    btfss STATUS, 2, A ; checa si la resta da 0 == iguales
    goto actualizar3_reciente ; si no son iguales , reintenta escritura
actualizar_2reciente    
    movlw .2
    movwf EEADR, A
    movf temp_eeprom1, A
    movwf EEDATA, A ; recorrido del 3 al 2, guardada anteriormente
    call protocolo_escritura_eeprom ; se realiza protocolo y se escribe
    ;checa si se copio el valor correcto
    movf temp_eeprom1, A
    bsf EECON1 , 0, A ; habilita lectura del .2 recien agregado
    subwf EEDATA, W, A ; resta lectura - temp registro 2 para verificar
    btfss STATUS, 2, A ; checa si la resta da 0 == iguales
    goto actualizar_2reciente ; si no son iguales , reintenta escritura
actualizar1_reciente    
    movlw .1
    movwf EEADR, A
    movf temp_eeprom2, A
    movwf EEDATA, A ; recorrido del 2 al 1, guardada anteriormente
    call protocolo_escritura_eeprom ; se realiza protocolo y se escribe
    ;checa si se copio el valor correcto
    movf temp_eeprom2, A
    bsf EECON1 , 0, A ; habilita lectura del .1 recien agregado
    subwf EEDATA, W, A ; resta lectura - temp registro 1 para verificar
    btfss STATUS, 2, A ; checa si la resta da 0 == iguales
    goto actualizar1_reciente ; si no son iguales , reintenta escritura
    return
   
protocolo_escritura_eeprom
    bsf EECON1, 2, A ; habilitamos Write
    movlw 0x55 ; Contraseņas del protocolo write
    movwf EECON2, A
    movlw 0xAA 
    movwf EECON2, A
    bsf EECON1, WR, A ; Empieza a escribir
waitwrite
    btfsc EECON1,WR,A ; checa antiflag
    goto waitwrite
    bcf EECON1 ,2 ,A ; cuando termine disables write
    clrf EEDATA ,A ; limpiar para verificaciones posteriores
    return
   
; otra que escriba en el highscore
ACTUALIZAR_HIGHSCORE
    movlw .0
    movwf EEADR, A
    movff puntaje, EEDATA ; pasamos el puntaje obtenido hasta ese punto al EEDATA
    call  protocolo_escritura_eeprom ; se realiza el protocolo y se escribe
    ; checa si se copio el valor correcto
    movf  puntaje, W, A
    bsf  EECON1 , 0, A ; habilita lectura del .0 recien agregado
    subwf EEDATA, W, A ; resta lectura - puntaje para verificar
    btfss STATUS, 2, A ; checa si la resta da 0 == iguales
    goto ACTUALIZAR_HIGHSCORE ; si no son iguales , reintenta escritura
    return
    
VERIFICAR_HIGHSCORE
    movlw   .0
    movwf   EEADR, A
    bsf	    EECON1, 0, A ;habilitar lectura
    movf    EEDATA, A
    bcf	    EECON1, 0 , A ; se inhabilita la lectura
    ;----------------------------------------------------
    ;NO FUNCIONA PORQUE PUNTAJE Y HIGHSCORE ESTAN EN ASCII
    ;----------------------------------------------------
    subwf puntaje, W, A ; resta puntaje - highscore
    btfss STATUS, 4, A ; checa si la resta da negativo
    return
    btfsc STATUS, 2, A ; checa si la resta da igual a 0
    return
    
    ;NEW HIGHSCORE
    call    SHOW_HIGHSCORE
    call    ACTUALIZAR_HIGHSCORE
    call    DELAY_1s