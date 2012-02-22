; Programme de la carte esclave - le retour custom
; 
; Commande de la sirene
; Commande du faisceau laser
; Détection de la balise
; Affichage sur l'écran LCD

; Declaration des variables
laser			BIT	P1.2
sirene		BIT	P1.3

RS				BIT	P0.5
RW				BIT	P0.6
E				BIT	P0.7

master		BIT	P3.1
dix			BIT	F0
nb_tours		EQU	R1
unite			EQU	R2
dizaine     EQU	R3
FD				EQU	R4
FC				EQU	R5
FG				EQU	R6


				ORG	0000h
				LJMP	debut
				ORG	0030h


recept	DATA	40h
		
msg_hello:
			DB		'ISE 2012 EQU. 1'
			DB 	0	
			
msg_balise:
			DB		' BALISE  '
			DB 	0	
						
msg_balise_detectee:
			DB		' DETECTEE     '
			DB 	0	
			
msg_balise_non_detectee:
			DB		' NON DETECTEE     '
			DB 	0					
			
msg_zero_impact:
			DB		'4'
			DB		0
			
msg_tir_droite:
			DB 	'TIR A DROITE'												
         DB		0
         
msg_tir_centre:
			DB 	'TIR AU CENTRE'												
         DB		0         

msg_tir_gauche:
			DB 	'TIR A GAUCHE'												
         DB		0
         
msg_score:
			DB		'SCORE: '
			DB 	0	       
  
msg_zero:
			;DB		'             '
			DB		0        
			
			
msg_tour:
			DB 	'TOUR '												
         DB		0
         
			
;______________________________________________________________________ 
; Temporisation de 40 ms

attend40ms:
			CLR	TF0
			MOV	TMOD,#00100001b	;MODE1 du TIMER1
			MOV	TH0,#63h
			MOV	TL0,#0C0h
			SETB	TR0
attente:
			JNB	TF0,attente
			CLR	TR0
			CLR	TF0
			RET         
    
   			
			
;______________________________________________________________________ 
; Temporisation de 1s		
								
attend1s:
			MOV	R0,#25
boucle_1s:
			LCALL	attend40ms
			DJNZ	R0,boucle_1s 
			RET												
;______________________________________________________________________ 
; Configuration de la liaison serie
; On utilise le Timer1 pour la détection de la balise

config_ls:
			MOV	A,TMOD
			ANL	A,#0Fh
			ORL	A,#20h
			MOV	TMOD,A				; Timer1 mis en mode 2
			MOV	SCON,#52h
			;MOV	SCON,#01010000b	; RI est mis a 0 au départ, REN=1, mode SM1
			MOV	TH1,#0E6h			; pour 1200 Bauds
			MOV	TL1,#0E6h
			SETB	TR1
			RET
	         
;______________________________________________________________________ 
; teste l'état du processeur (occupé ou pas) 
 
test_busy:
			MOV	P2,#0FFh
			CLR	RS
			SETB	RW
			SETB	E
			
check_busy:
			JB		P2.7,check_busy
			CLR	E
			RET
			
;______________________________________________________________________ 
; validation de l'envoi d'une instruction au LCD 			

en_lcd_code:
			CLR	RS
			CLR	RW
			SETB 	E
			CLR	E
			LCALL	test_busy
			RET
;______________________________________________________________________ 
; validation de l'envoi de données au LCD
 			
en_lcd_data:
			SETB	RS									
         CLR	RW
         SETB	E
         CLR	E
         LCALL	test_busy
         RET
         
;______________________________________________________________________ 
; Initialisation de l'ecran LCD

init_lcd:
   		LCALL	attend40ms						; attente au démarrage du LCD
	
			MOV	P2,#06h							; curseur en avant
			LCALL	en_lcd_code
			
			MOV	P2,#0Ch							; allume l'écran
			LCALL	en_lcd_code
			
			MOV	P2,#38h			      	   ; affichage sur 2 lignes
			LCALL	en_lcd_code
		
			MOV 	P2,#80h							; positionne le curseur sur le debut de la premiere ligne
			LCALL	en_lcd_code
			
			RET


;______________________________________________________________________ 
; Ecriture d'un message
   
LCD_ecriture:
	      CLR	A
			MOVC	A,@A+DPTR		
			MOV	P2,A
			JZ		fin_LCD_ecriture
			LCALL	en_lcd_data
			INC	DPTR							
   		MOV	P2,#06h				
			LCALL	en_lcd_code
			SJMP	LCD_ecriture
			
fin_LCD_ecriture:
			CLR	A
			RET  
	
	
effacer_LCD:
			MOV	P2,#01h			
			LCALL	en_lcd_code					
			RET
			
			
LCD_A_ecriture:	
			MOV	P2,A
			JZ		fin_LCD_ecriture
			LCALL	en_lcd_data
			INC	DPTR							
   		MOV	P2,#06h				
			LCALL	en_lcd_code
			LJMP	fin_LCD_ecriture
		
			
;______________________________________________________________________ 	
; Choix de la ligne d'affichage
			
						
ligne_1:
			MOV 	P2,#80h							; positionne le curseur sur le debut de la premiere ligne
			LCALL	en_lcd_code
			RET
	
ligne_2:			
			MOV 	P2,#0C0h							; positionne le curseur sur le debut de la premiere ligne
			LCALL	en_lcd_code
			RET				
	
	
;______________________________________________________________________ 	
; Boucle attente liaison série
					
attente_ti:
				JNB	TI,attente_ti
				CLR	TI
				MOV	SBUF,A
				INC	DPTR
				RET		
			
;______________________________________________________________________
; Comptage des points

score:
				;LCALL	effacer_LCD
				LCALL	ligne_2
				MOV	DPTR,#msg_score
				LCALL	LCD_ecriture	
				JNB	dix,affiche_unite
				LCALL	score_dix	
affiche_unite:
				CLR	A
				MOV	A,unite
				LCALL	LCD_A_ecriture	
				MOV	DPTR,#msg_zero	
				LCALL	LCD_ecriture				
fin_score:
				LCALL	ligne_1
				RET
				
score_dix:		
				CLR	A
				MOV	A,dizaine
				LCALL	LCD_A_ecriture	
				MOV	DPTR,#msg_zero	
				LCALL	LCD_ecriture				
            RET				

;_____________________________________________________________________ 
				
debut:
				CLR	laser
				CLR	sirene
				CLR	master
				CLR	dix
				MOV	nb_tours,#30h
				MOV	FD,#0h
				MOV	FC,#0h
				MOV	FG,#0h
				LCALL	init_lcd
				LCALL	config_ls
				
				MOV	DPTR, #msg_hello
				LCALL	LCD_ecriture
				MOV	unite,#30h
				MOV	dizaine,#30h
				
; sur le Timer1				
attente_detection_balise:
				JNB	RI,attente_detection_balise
				
				
balise_detectee:
				CLR	RI	
				LCALL	effacer_LCD	
				
				LCALL	ligne_1	
				MOV	DPTR, #msg_balise	
				LCALL	LCD_ecriture	
										
				LCALL	ligne_2	
				MOV	DPTR, #msg_balise_detectee		
				LCALL	LCD_ecriture	
																
pock_master:
				SETB	master
				
allume_laser:	
				
				SETB	sirene
				SETB  laser
				
				LCALL	attend40ms
				JB		RI,tir
				LJMP	balise_plus_detectee			
tir:				
				CLR	RI
				MOV	A,SBUF
				CLR	ACC.7

;--------------------------------------------------------
;Tir à droite

tir_droite:
				CJNE	A,#44h,tir_centre
				CJNE	FD,#0h,tir_centre
				MOV	FD,#1h				
				CJNE	unite,#39h,inc_droite			
				LCALL	set_dix
				MOV	unite,#30h
				LJMP	affiche_droite				
inc_droite:				
				INC	unite			
affiche_droite:	
				LCALL	effacer_LCD			
				LCALL	score				
				MOV	DPTR,#msg_tir_droite
				LCALL	ligne_1
				LCALL	LCD_ecriture
				LJMP	allume_laser
				
				
;--------------------------------------------------------
;Tir au centre

				
tir_centre:
				CJNE	A,#43h,tir_gauche
				CJNE	FC,#0h,tir_gauche
				MOV	FC,#1h
				CJNE	unite,#37h,test_huit
				LCALL	set_dix
				MOV	unite,#30h
				LJMP	affiche_centre
				
test_huit:						
				CJNE	unite,#38h,test_neuf				
				LCALL	set_dix
				MOV	unite,#31h
				LJMP	affiche_centre
				
test_neuf:							
				CJNE	unite,#39h,inc_centre
				LCALL	set_dix
				MOV	unite,#32h
				LJMP	affiche_centre
				
inc_centre:
				INC	unite
				INC	unite
				INC	unite
affiche_centre:		
				LCALL	effacer_LCD
				LCALL	score								
				MOV	DPTR,#msg_tir_centre
				LCALL	ligne_1
				LCALL	LCD_ecriture
				LJMP	allume_laser

;--------------------------------------------------------
;Tir à gauche

			
tir_gauche:
				CJNE	A,#47h,allume_laser
				CJNE	FG,#0h,allume_laser
				MOV	FG,#1h
				CJNE	unite,#39h,inc_gauche			
				LCALL	set_dix
				MOV	unite,#30h
				LJMP	affiche_gauche
inc_gauche:					
				INC	unite
affiche_gauche:	
				LCALL	effacer_LCD			
				LCALL	score		
				MOV	DPTR,#msg_tir_gauche
				LCALL	ligne_1
				LCALL	LCD_ecriture
				LJMP	allume_laser		
				
										
set_dix:
				INC	dizaine
				SETB	dix
				RET	
				
;-----------------------------------------------------------------------------------
				
balise_plus_detectee:
				CLR	RI
				MOV	FD,#0h
				MOV	FC,#0h
				MOV	FG,#0h
				
				LCALL	effacer_LCD
				LCALL	score						;sur la ligne 2
				INC	nb_tours
				LCALL	ligne_1
				MOV	DPTR,#msg_tour
				LCALL	LCD_ecriture
				MOV	A,nb_tours
				LCALL	LCD_A_ecriture
				MOV	DPTR,#msg_zero	
				LCALL	LCD_ecriture
			
				
				;LCALL	effacer_LCD	
				;LCALL	ligne_1	
			  	;MOV	DPTR, #msg_balise	
				;LCALL	LCD_ecriture		
									
				;LCALL	ligne_2	
				;MOV	DPTR, #msg_balise_non_detectee		
				;LCALL	LCD_ecriture	
				
				LCALL	attend1s
				CLR	laser
				CLR	sirene
				
unpock_master:
				CLR	master
	
fin_unpock:
				LJMP	attente_detection_balise				
		
				END							

