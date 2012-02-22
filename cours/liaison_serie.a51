

;ecriture d'un message sur le minitel

			ORG 	0000h
			LJMP	begin
			ORG	  0030h
message:
			DB		'VOUS NE PASSEREZ PAS !'
			DB		0

;_______________________________________________________________________________
;sous programme Configuration de la liaison serie


config_ls:
			MOV	  A,TMOD
			ANL	  A,#0Fh
			ORL	  A,#20h
			MOV	  TMOD,A
			MOV	  SCON,#42h
			MOV	  TH1,#230
			MOV	  TL1,#230
			SETB	TR1
			RET
		
			
;_________________________________________________________________________________
;corps du programme


begin:
			LCALL	config_ls
			
envoi:
			MOV	  DPTR,#message
			
attente:	
      JNB	  P3.3,attente
			
			
boucle_envoi:			
			CLR	  A
			MOVC	A,@A+DPTR
			JZ		fin_transmission
			
			LCALL	envoi_char
			INC	  DPTR
			SJMP	boucle_envoi

	
			
fin_transmission:
			SJMP	envoi
			
envoi_char:
			MOV	  C,P
			MOV	  ACC.7,C
attente_ti:
			JNB	  TI,attente_ti
			CLR	  TI
			MOV	  SBUF,A
			RET
			
			
			END
			
			
