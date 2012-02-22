 ; Programme pour afficheur 7 segments
 ; 8 interrupteurs
 ; 3 afficheurs 7 segments
 ; codage DCB
 
 
 ; interrupteurs sur P1
 ; unités P2.0 - P2.3
 ; dizaines P0.0 - P0.3
 ; centaines P0.4 - P0.7
 
 
 			ORG   00h
 			LJMP	begin
      ORG	  30h
         
 begin:	
      MOV 	R0,P1			; recuperation des donnees des interrupteurs dans R0
 			MOV 	A,R0
 			MOV	  B,#10			; divisipon par 10 pour le codage en DCB
 			DIV 	AB				
 			MOV 	R0,B			; recuperation du chiffre des unites de B en R0
 			MOV	  B,#10
 			DIV 	AB
 			MOV	  R1,B			; recuperation du chiffre des dizaines de B en R1 (bits de poids faibles) - les bits de poids fort sont à 0
 		 	MOV	  B,#10
 			DIV 	AB				
 			MOV	  A,B			; recuperation du chiffre des centaines de B en R1 (poids de poids fort) - les bits de poids fort sont à 0
 			SWAP	A
 			ORL	  A,R1			; les donness des centaines et des dizaines sont sur A
 			MOV   P2,R0			; on envoie sur le premier afficheur (unités)
 			MOV	  P0,A			; on envoie sur le 2e et 3e afficheur (dizaines et centaines)
 			
 			SJMP	begin
 			END

 
