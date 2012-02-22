 ; Compter 40ms
 
sec		EQU	R2
min		EQU	R1 	
 
 			ORG 	0000h
 			LJMP	begin
 			ORG 	0003h
 			LJMP	interruption_bouton
 			ORG	  000Bh
 			LJMP	interruption_timer
 			ORG	  0030h
 
;________________________________________________________________________________________
; Interruption Timer0

interruption_timer: 

			PUSH	ACC
			PUSH	PSW

			CLR	  TF0					
			CLR	  TR0	
			DEC	  R0									;1
			MOV	  A,TL0								;1 ; ajout du dépassement de cycle au nouveau compteur (tps supplémentaire à prendre en compte si affichage)
			ADD	  A,#0C8h							;1 : ajout de C0 + 8c de tps de rechargement
			MOV 	TL0,A								;1
			MOV	  A,TH0								;1
			ADDC	A,#63h                     ;1 ; on tient compte de l'éventuel débordement entre TL0 et TH0
			MOV	  TH0,A								;1 
			SETB	TR0								;1 ; lancement du Timer
			
			POP	  PSW
			POP	  ACC
			RETI
;_______________________________________________________________________________________
;Interruption bouton P3.2

interruption_bouton:
			CLR	  TR0
			CLR	  EA							; on arrête toutes les interruptions
			CLR	  TF0						; on remet le flag à zero s'il a été mis à 1 par Timer0
			CLR	  ET0
			MOV	  SP,#0007h
			
attente:
			JB		P3.3,attente
			
attente2:
			JNB	  P3.3,attente2
			
redemarre:
			MOV	  DPTR,#begin				; on veut revenir au début du prog, pas au contexte d'avant l'interruption
			PUSH	DPL
			PUSH	DPH	
			RETI						


;_______________________________________________________________________________________
; Sous-programme 		
	
division:			
			MOV	  B,#10
			DIV 	AB
			RET			
 	
;________________________________________________________________________________________
;Début du programme 		

begin:
			SETB	EA
			SETB	ET0
			SETB	EX0
			SETB	IT0
			CLR	  TF0
			CLR	  TR0
			MOV	  TMOD,#01h
			MOV	  TL0,#0C0h
			MOV	  TH0,#63h
			MOV	  sec,#0h							; initialisation de l'affichage à 0s
			MOV	  min,#0h							; initialisation de l'affichage à 0m
			MOV	  P2,sec							; affichage des secondes en P2 raz
			MOV	  P1,min							; affichage	des minutes en P1 raz
			SETB	TR0

boucle_sec:
			MOV	  R0,#25							; initialisation compteur pour 1s


start_timer:	
			MOV	  A,R0		
			JNZ	  start_timer						; si R0 <> 0, on continue de compter les cycles de 40ms

incr_sec:											; test qu'on est en dessous de 60 secondes et/ou 60 minutes - si oui, raz du chrono
			INC	  sec
			CJNE	sec,#60,affiche_sec

incr_minute:
			MOV	  sec,#0
			INC	  min									; on incrémente les minutes si R2 supérieur à 59s
			CJNE	min,#60,affiche_sec			; affichage des minutes
			LJMP	begin								; RAZ du chrono, on recommence du début
			
affiche_sec:										; affichage des secondes entre 1 et 59
			MOV	  A,sec
			LCALL	division
			SWAP	A
			ORL 	A,B
			MOV	  P2,A	
		
affiche_minute:	
			MOV	  A, min
			LCALL	division
			SWAP	A
			ORL 	A,B
			MOV	  P1,A	
			LJMP	boucle_sec	
					
			END   
