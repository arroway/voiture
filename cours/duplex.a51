;communication entre deux microcontroleurs

recept	DATA	40h

			ORG	  0000h
			LJMP	begin
			ORG 	0003h
			LJMP	interrupt_tx
			ORG	  0013h
			LJMP	interrupt_rx
			ORG	  0030h
						
message:	
      DB		'HELLO NOOBS!'
			DB		0

;_______________________________________________________________________________
;sous programme Configuration de la liaison serie


config_ls:
			MOV	  A,TMOD
			ANL	  A,#0F0h
			ORL	  A,#20h
			MOV	  TMOD,A
			MOV	  SCON,#53h
			MOV	  TH1,#230
			MOV	  TL1,#230
			SETB	TR1
			RET
;__________________________________________________________________________________________		
;sous programme d'envoi

			
envoi_char:
			MOV	  C,P
			MOV	  ACC.7,C			
attente_ti:
			JNB 	TI,attente_ti
			CLR	  TI
			MOV	  SBUF,A
			RET
						
;________________________________________________________________________________
; Interruptions		
			
interrupt_tx:										;transmission à un 2e microcontroleur
						
			MOV	  DPTR,#message	
			MOV	  R1,#12			
			
boucle_envoi:			
			CLR	  A
			MOVC	A,@A+DPTR  		 
			LCALL	attente_ti
			INC	  DPTR
			DJNZ	R1,boucle_envoi

fin_envoi:	
			SETB	P1.3     					 		; pour prouver que j'ai transmis	
			MOV	  DPTR,#arret
			DEC	  SP
			DEC	  SP
			DEC	  SP
			DEC	  SP
			PUSH 	DPL
			PUSH	DPH
			MOV	  DPTR,#fin_reti
			PUSH 	DPL
			PUSH	DPH	
			RETI
			
;_______________________________________________		

interrupt_rx:										; reception du 2e microcontroleur, et affichage sur le minitel
			PUSH	ACC
			PUSH	PSW
			
			MOV	  R1,#12
			MOV 	R0,#recept
			
recept_char:
			JNB	  RI,recept_char					; détection de la réception
			MOV	  A,SBUF
			CLR	  RI
			MOV	  @R0,A
			INC	  R0									; on incr R0 (ie l'adresse à laquelle on veut écrire le contenu de SBUF)
			DJNZ	R1,recept_char
				
		
affichage_minitel:
			MOV	  R0,#recept
			MOV	  R1,#12
		  SETB 	RI
			
boucle_affichage:			
			CLR 	A
			MOV	  A,@R0	 
			LCALL	envoi_char
			INC	  R0
			DJNZ	R1,boucle_affichage

fin_affichage:			
			SETB	P1.2									;pour prouver que j'ai recu et affiché			
			POP	  PSW
			POP 	ACC
fin_reti:
			RETI
					
;_________________________________________________________________________________
; corps du programme

begin:
			LCALL	config_ls
			CLR	  P1.2
			CLR	  P1.3
			SETB	EA
			SETB	EX0
			SETB	EX1
			SETB	IT0
			SETB	IT1
			SETB	PX0					; on privilégie l'affichage à la réception (car si cela n'arrete pas d'envoyer de l'autre côté, on n'affichera js sur le minitel)
											; on peut perdre des données, mais on peut contrôler notre affichage et choisir de rafraichir l'écran												
			SETB	P1.2
			SETB	P1.3
			
			
			
arret:	
      MOV	  SP,#07h
arret2:	
      SJMP	arret2	
			
			END
			
