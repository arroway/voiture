 ; Programme pour afficheur 7 segments
 ; 8 interrupteurs
 ; 3 afficheurs 7 segments
 ; codage DCB
 
 
 ; interrupteurs sur P0
 ; unités P3.4 - P3.7
 ; dizaines P2.0 - P2.3
 ; centaines P2.4 - P2.7
 ; racine carré du nombre sur P1
 ; carry sur P3.4 - P3.7
 
; Interruption: affichage de la racine carrée sur front descendant de P3.2 (IT0)


 			ORG   0000h
 			LJMP	begin
 			ORG 	0003h
 			LJMP	interrupt
      ORG	  0030h

         
;__________________________________________________________________________         
; sous programme

division:	
			MOV	  B,#10
			DIV	  AB
			RET         
			
;__________________________________________________________________________
;sous programme d'interruption

interrupt:
 			
 			PUSH	ACC
 			PUSH	B
 			PUSH	PSW
 			
init_racine:  
			MOV	  A,P0		
			MOV	  R0,#0
			MOV 	R1,#1 
			CLR	  C		
			
calcul_racine:							
			JZ		affiche_racine			; si carre parfait
			SUBB	A,R1
			JC		affiche_racine
			INC	  R0
			INC	  R1
			INC	  R1
			SJMP	calcul_racine
			
affiche_racine:
			MOV	  A,R0
			LCALL	division
			SWAP	A				; recuperation du chiffre des unites dans B; dizaines dans A
			ORL	  A,B
			MOV	  P1,A	

			JC		afficheD

afficheB:
			ORL	  P3,#00000011b
			JNC	  sortieInterrrupt	
			
afficheD:  
			ORL	  P3,#00001001b  

sortieInterrupt:

			POP	  PSW
			POP 	B
			POP	  ACC
 			RETI			
;_________________________________________________________________________________________________
;corps du programme

begin: 
      ;ORL	IE,#10000001b				; set EA et EXO à 1
			;ORL	TCON,#00000001b			; set ITO à 1 (déclenchement sur front descendant)
			SETB	EA
			SETB 	EX0
			SETB	IT0

					
afficheNb:

 			MOV 	A,P0			; recuperation des donnees des interrupteurs dans A
 			LCALL	division			
 			MOV 	R6,B			; recuperation du chiffre des unites de B en R0
 			LCALL	division
 			MOV	  R5,B			; recuperation du chiffre des dizaines de B en R1 (bits de poids faibles) - les bits de poids fort sont à 0
 			SWAP	A
 			ORL	  A,R5			; les donnees des centaines et des dizaines sont sur A
 			MOV 	P2,A			; on envoie sur le 2e et 3e afficheur (dizaines et centaines)
 			MOV	  A,R6
 			SWAP	A
 			ORL	  A,#00000100b
 			MOV   P3,A			; on envoie sur le premier afficheur (unités)

 			SJMP 	afficheNb
 			
 			END
