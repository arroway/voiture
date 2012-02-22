 ; Compter 40ms
 
 	sec	EQU	R2
 	min	EQU	R1
 
 
 			ORG 	0000h
 			LJMP	begin
 			ORG	  0030h
 
 			
division:			
			MOV	  B,#10
			DIV 	AB
			RET			
 		
begin: 				
			MOV	  TMOD,#01h
			MOV	  sec,#0h							; initialisation de l'affichage à 0s
			MOV	  min,#0h							; initialisation de l'affichage à 0m
			MOV	  P2,sec							; affichage des secondes en P2 raz
			MOV	  P1,min							; affichage	des minutes en P1 raz

boucle_sec:
			MOV	  R0,#25							; initialisation compteur pour 1s

start_timer:		
			CLR	  TF0					
			CLR	  TR0	
			MOV	  A,TL0								;1 ; ajout du dépassement de cycle au nouveau compteur (tps supplémentaire à prendre en compte si affichage)
			ADD	  A,#0C7h							;1 : ajout de C0 + 7c de tps de rechargement
			MOV	  TL0,A								;1
			MOV	  A,TH0								;1
			ADDC	A,#63h                     ;1 ; on tient compte de l'éventuel débordement entre TL0 et TH0
			MOV	  TH0,A								;1 
			SETB	TR0								;1 ; lancement du Timer
			
boucle_40ms:
			JNB	  TF0,boucle_40ms		
			DJNZ	R0,start_timer					; si R0 <> 0, on continue de compter les cycles de 40ms

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
			MOV 	P1,A	
			LJMP	boucle_sec	
			
			SJMP	begin			
			END  
