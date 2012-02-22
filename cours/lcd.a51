; affichage LCD

RS		BIT	P2.0
RW		BIT	P2.1
E			BIT	P2.2


 			ORG 	0000h
 			LJMP	begin
 			ORG 	0030h
 			
message1:
			DB		'ISE3--2012--BONJOUR--TEST--DECALAGE--!!!'
			DB		0

message2:	 			
 		   DB		'--BON  TRAVAIL--'
 		   DB		0
 
;______________________________________________________________________ 
; teste l'état du processeur (occupé ou pas) 
 
test_busy:
			MOV	  P1,#0FFh
			CLR	  RS
			SETB	RW
			SETB	E
			
check_busy:
			JB		P1.7,check_busy
			CLR	  E
			RET
			
;______________________________________________________________________ 
; validation de l'envoi d'une instruction au LCD 			

en_lcd_code:
			CLR	  RS
			CLR	  RW
			SETB 	E
			CLR 	E
			LCALL	test_busy
			RET
;______________________________________________________________________ 
; validation de l'envoi de données au LCD
 			
en_lcd_data:
			SETB	RS									
      CLR 	RW
      SETB	E
      CLR 	E
      LCALL	test_busy
      RET
         
;______________________________________________________________________ 
; attente de 40 ms

attente_debut:
			MOV	  TMOD,#01h
			MOV	  TH0,#63h
			MOV	  TL0,#0C0h
			CLR	  TF0			
			SETB	TR0
			
wait2:
			JNB	  TF0,wait2
			CLR	  TF0
			CLR	  TR0	
			RET
			
			
;_____________________________________________________________________________
tempo200:			
			MOV	  TMOD,#01h
			MOV	  R0,#5
			
boucle40:
			MOV	  TH0,#63h
			MOV	  TL0,#0C0h
			CLR	  TF0			
			SETB	TR0
			
wait:
			JNB	  TF0,wait
			CLR	  TF0
			CLR 	TR0
			DJNZ	R0,boucle40
			RET

;_______________________________________________________________
			
tempo500:			
			MOV	  TMOD,#01h
			MOV	  R0,#12
			LCALL	boucle40
			RET
															
			
;_____________________________________________________________________

message40:
			
			MOV	  DPTR,#message1
			LCALL	ecriture
			RET
			
;_____________________________________________________________________

message16:
			MOV	  DPTR,#message2
			LCALL	ecriture		
			RET			
			
			
;_____________________________________________________________________
;sous programme d'écriture
			
ecriture:
			CLR	  A
			MOVC	A,@A+DPTR
			JZ		retour
			MOV	  P1,A
			LCALL	en_lcd_data
			INC	  DPTR
			MOV	  P1,#06h						;incrémente curseur						
			LCALL	en_lcd_code
			SJMP	ecriture
			
retour:	
			RET	
			
			
;______________________________________________________________________
decale_gauche:
			MOV	  R1,#24						; decalage de 24 lettres


boucle_decale_gauche:			
			LCALL	tempo200
			
			MOV	P1,#18h
			LCALL	en_lcd_code
			
			DJNZ	R1,boucle_decale_gauche
			RET
			
;___________________________________________________________________________
decale_droite:
			MOV	  R1,#24						; decalage de 24 lettres
						
boucle_decale_droite:
			LCALL	tempo200
			
			MOV	  P1,#1Ch			
			LCALL	en_lcd_code
			
			DJNZ	R1,boucle_decale_droite
			RET

;_______________________________________________________________________________


clignote:
			MOV	  R3,#5
			
cligne:
			MOV	  P1,#08h
			LCALL	en_lcd_code
			LCALL	tempo500
			MOV	  P1,#0Ch
			LCALL	en_lcd_code
			LCALL	tempo500
			
			DJNZ	R3,cligne
			RET
		
		
;_______________________________________________________________________

decale_curseur:
			MOV	  R3,#80
			
curseur:
			MOV	  P1,#10h
			LCALL	en_lcd_code
			LCALL	tempo200
			DJNZ	R3,curseur
			RET						
;______________________________________________________________________ 		
     
 begin:
			LCALL	attente_debut
			
			MOV	  P1,#06h						; curseur en avant
			LCALL	en_lcd_code
			
			MOV	  P1,#0Ch						; allume l'écran
			LCALL	en_lcd_code
			
			MOV	  P1,#38h			         ; affichage sur 2 lignes
			LCALL	en_lcd_code
			
			MOV 	P1,#80h						; positionne le curseur sur le debut de la premiere ligne
			LCALL	en_lcd_code
			
			LCALL	message40					;ecriture de 40 caractères sur la premiere ligne
			
			MOV	  P1,#0C0h						;positionne le curseur sur le debut de la deuxieme ligne
			LCALL	en_lcd_code
			
			LCALL message16					;ecriture de 16 caractères sur la deuxieme ligne
			
			LCALL	decale_gauche
			LCALL	clignote
			LCALL	decale_droite
			LCALL	decale_curseur
					
			
			
infini:	
      SJMP	infini			
			
			END
			
			
			
			
			
