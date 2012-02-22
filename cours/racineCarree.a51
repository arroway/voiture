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
 
boutonP	BIT	P3.2


 			ORG   00h
 			LJMP	afficheNb
      ORG	  30h
         
         
         
division:
			MOV	  B,#10
			DIV	  AB
			RET         			
			
afficheNb:
 			MOV 	A,P0			; recuperation des donnees des interrupteurs dans A
 			LCALL	division			
 			MOV 	R6,B			; recuperation du chiffre des unites de B en R0
 			LCALL	division
 			MOV	  R5,B			; recuperation du chiffre des dizaines de B en R1 (bits de poids faibles) - les bits de poids fort sont à 0
 			SWAP	A
 			ORL	  A,R5			; les donnees des centaines et des dizaines sont sur A
 			MOV	  P2,A			; on envoie sur le 2e et 3e afficheur (dizaines et centaines)
 			MOV	  A,R6
 			SWAP	A
 			ORL	  A,#00000100b
 			MOV   P3,A			; on envoie sur le premier afficheur (unités)

 			JNB	  boutonP,afficheNb ; si pas d'appui sur boutonP, on revient au debut
 			
racine:  
			MOV	  A,P0		
			MOV	  R0,#0
			MOV 	R1,#1 
			CLR	  C
			
			
calcul:							
			JZ		afficheSq			; si carre parfait
			SUBB	A,R1
			JC		afficheSq
			INC	  R0
			INC	  R1
			INC	  R1
			SJMP	calcul
			
afficheSq:
			MOV	  A,R0
			LCALL	division
			SWAP	A				; recuperation du chiffre des unites dans B; dizaines dans A
			ORL	  A,B
			MOV	  P1,A	

			JC		afficheD

afficheB:
			ORL	  P3,#00000011b
			JNC	  afficheNb		
			
afficheD:  
			ORL	  P3,#00001001b  
			
	
 			SJMP	afficheNb
 			END
