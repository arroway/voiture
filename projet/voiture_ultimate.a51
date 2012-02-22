;soustraction et addition sur 16 bits
;commande du moteur et du servo de direction
;l'action sur un bouton poussoir met le bit a 0
;au debut les roues sont droites et le moteur est a l'arrˆt
;l'appui sur BP1 provoque(progressivement) l'acceleration et le braquage des roues a gauche la led s'allume
;l'appui sur BP0 provoque(progressivement) a deceleration et le braquage des roues a droite la led s'eteind
dir     		    bit     P1.4   ; commande de direction
mot    			 bit     p1.5   ; commande du moteur
tir    			 bit     p3.5   ; commande du tir
ledmC  			 bit     p1.0   ; indique æC en marche (led allumee si p1.0 = 0)
bp0     			 bit     p1.1   ; pour l'etalonnage et calibrage
bp1    			 bit     p1.2   ; pour calibrage
capg   			 bit     p3.2   ; capteur gauche
capd   			 bit     p3.3   ; capteur droit
old_dir			 bit		p1.7	 ; bit de controle : à 1 si l'ancienne direction était gauche

;bit de flag
finint 			 bit    	7Fh    ; indicateur de preparation du timer0

;bit de presence de la balise
balise_here		 bit		p1.6	 ; bit de communication avec le microcontroleur esclave

; declaration des octets
; valeurs de reference a charger dans Timer0
vd1h			equ		0fah		;(65536-1500)			
vd1l			equ		24h		;
vdr1h			equ		0fch		;(65536-1000)
vdr1l			equ		18h

vm1h			equ		0fah		;(65536-1500)
vm1l        equ		024h
vmr1h			equ		0c1h		;(65536-16000)
vmr1l			equ		080h

;memoires recevant les valeurs a charger dans Timer0 
;pour realiser les durees de:

vd2l			equ		7fh		; la direction
vd2h			equ		7eh
vdr2l			equ		7dh		; reste de la direction
vdr2h			equ		7ch
vm2l			equ		7bh		; du moteur
vm2h			equ		7ah
vmr2l			equ		79h		; reste du moteur
vmr2h			equ		78h

vth0			equ		6eh		;memoire intermediaire recevant les valeurs
vtl0			equ		6fh		;a transferer dans th0 et tl0
;----------------------------------------------------------------------
; plage des interruptions

				org		0000h			;reset
				ljmp		debut
				
				org		0003h			;interruption int0

				org		000Bh			;interruption timer0
				ljmp		pinttimer0
				
				org		0013h			;interruption int1
                              	         
				org		001Bh			;interruption timer1 

				org		0023h			;interruption liaison serie

				org		0030h 
	
	
	
;---------------------------------------------------------------------------------------	
	
;programme d'interruption du Timer0. La periode set de 20ms separee en 4 durees:
;d= direction de 1 a 2ms, /d= reste de la direction pour completer a 2,5ms,
;m= moteur de 1 a 2ms, /m= reste du moteur pour completer a 17,5ms.

pinttimer0:
				push		psw
				push		acc

tr0a0: 
				cjne		r0,#0,tr0a1		;direction
				mov		vtl0,vd2l
				mov		vth0,vd2h
				mov		r0,#1
				setb		dir
				sjmp		relancet0

tr0a1:  
				cjne		r0,#1,tr0a2		;reste de la direction 
       		mov		vtl0,vdr2l
        		mov		vth0,vdr2h
        		mov		r0,#2
       		clr     	dir
       		sjmp		relancet0

tr0a2:  
				cjne		r0,#2,tr0a3		;moteur
       		mov		vtl0,vm2l
        		mov		vth0,vm2h
        		mov		r0,#3
				setb		mot
        		sjmp		relancet0

tr0a3:  
				mov		vtl0,vmr2l		;reste du moteur
				mov		vth0,vmr2h
				clr		mot
				mov		r0,#0
				setb		finint    		;pp peut traiter des nouvelles valeurs 
        
relancet0:
				clr		tr0      ; arret du timer
				mov		a,tl0    ; lecture de la valeur … charger
				add		a,#08		; addition avec le reste du timer
				addc		a,vtl0   ; valeur … ajuster
				mov		tl0,a    ; chargement du poids faible du timer0
				mov		a,vth0   ; lecture de la valeur … charger dans th0
				addc		a,th0    ; pour tenir compte du d‚bordement
				mov		th0,a    ; chargement du poids fort du timer0
				setb		tr0      ; lancement du timer

restit:
				pop		acc
				pop		psw

				reti	
	
	
	
	
	
;--------------------------------------------------------------------
;virage a gauche selon R6
virgauche:
				clr		c
				mov		a,vd2l
				add		a,r6
				mov		vd2l,a
				mov		a,vd2h
				addc		a,#00h
				mov		vd2h,a
restdir3:
				clr		c
				mov		a,vdr2l
				subb		a,r6
				mov		vdr2l,a
				mov		a,vdr2h
				subb		a,#00h
				mov		vdr2h,a
				ret
;----------------------------------------------------------------------
;virage a droite selon R6
virdroite:
				clr		c
				mov		a,vd2l
				subb		a,r6
				mov		vd2l,a
				mov		a,vd2h
				subb		a,#00h
				mov		vd2h,a 
restdir4:
				clr		c
				mov		a,vdr2l
				add		a,r6
				mov		vdr2l,a
				mov		a,vdr2h
				addc		a,#00h
				mov		vdr2h,a
				ret
				
;---------------------------------------------------------------------
;sous programme de gestion de la vitesse

vitesse_croisiere:
				mov		vm2h,#0f9h	; chargement de la valeur de croisiere (65536-1585)
				mov		vm2l,#0cfh	
				mov		vmr2h,#0c1h	; chargement du reste (65536-15915)
				mov		vmr2l,#0d5h
				ret
				
				
vitesse_virage:
				mov		vm2h,#0f9h	; chargement de la valeur de virage (65536-1572)
				mov		vm2l,#0dch	
				mov		vmr2h,#0c1h	; chargement du reste (65536-15928)
				mov		vmr2l,#0c8h
				ret			
				
vitesse_balise:
				mov		vm2h,#0f9h	; chargement de la valeur de virage (65536-1575)
				mov		vm2l,#0d9h	
				mov		vmr2h,#0c1h	; chargement du reste (65536-15925)
				mov		vmr2l,#0cbh
				ret	
				
vitesse_accelere:
				mov		vm2h,#0f9h	; chargement de la vitesse en detection de balise (65536-1595)
				mov		vm2l,#0c5h 
				mov		vmr2h,#0c1h	; chargement du reste (65536-15905)
				mov		vmr2l,#0dfh
				ret

;----------------------------------------------------------------------
;roues droites quand les capteurs detectent que la voiture est bien sur la piste


roues_droites:
				mov		vd2l,#vd1l	; chargement de la valeur de repos 1500æs
				mov		vd2h,#vd1h	; pour la direction
				mov		vdr2l,#vdr1l; chargement du complement (1000us)a 2,5ms
				mov		vdr2h,#vdr1h; pour la direction 
				ret
						
;------------------------------------------------------------------------
tournedroite:
       		lcall		virdroite		;calcul des valeurs a charger dans T0
            mov		a,vd2h
            cjne		a,#0f8h,diffh3 
            mov		a,vd2l
            cjne		a,#94h,diffl3
            ljmp		sortie_droite3
diffl3:
				jnc		sortie_droite3
				sjmp		suph3
diffh3:
				jnc		sortie_droite3
suph3:
				mov		vd2h,#0f8h	;chargement des valeurs max
				mov		vd2l,#94h
				mov		vdr2h,#0fdh
				mov		vdr2l,#0a8h

				 
sortie_droite3:
				ret
;-------------------------------------------------------------------------					
tournegauche:
				lcall		virgauche	;calcul des valeurs a charger dans T0
				mov		a,vd2h
				cjne		a,#0fbh,diffh4		
				mov		a,vd2l
				cjne		a,#0b4h,diffl4

diffh4:
				jnc		infh4
				ljmp		sortie_gauche2
diffl4:
				jnc		infh4
				ljmp		sortie_gauche2
infh4:
				mov		vd2h,#0fbh	;chargement de la valeur max de l'impulsion
				mov		vd2l,#0b4h	
				mov		vdr2h,#0fah	
				mov		vdr2l,#88h

sortie_gauche2:
				ret
				
;-------------------------------------------------------------------------
braque_gauche:
				mov		vd2h,#0fbh	;chargement de la valeur max de l'impulsion
				mov		vd2l,#0b4h	
				mov		vdr2h,#0fah	
				mov		vdr2l,#88h
				ljmp		retour_piste

braque_droite:
				mov		vd2h,#0f8h	;chargement des valeurs max
				mov		vd2l,#94h
				mov		vdr2h,#0fdh
				mov		vdr2l,#0a8h
				
retour_piste:
				jnb		capd,retour_piste
				jnb		capg,retour_piste
				
				
				ret				

;----------------------------------------------------------------------
;nombre de fois 20ms

durecom:										 ; gère r1 =  Nb de commandes soit r1*20ms 
				jnb		finint,durecom
				clr		finint
				djnz		r1,durecom 		 ; r1 contient le Nb de commandes 
				ret

;------------------------------------------
debut:		
				mov		sp,#30h		;pour sortir de la zone de banque
				mov		tmod,#21h	; T1 mode 2(autoreload),T0 16bits
				mov		th1,#0E6h	; LS … 1200bits/s quartz 12MHz
				mov		tl1,#0E6h	; pour le d‚mmarage. 
				mov		scon,#50h	; mode 1 10 bits, ren=1,ti=0
				setb		tr1			; lancement timer1 pour diviser fqz (baudrate)
				clr		dir 
				clr		mot
				clr		finint		; pas de fin d'interruption
				
				
				
; validation des interruptions du timer 0
				setb		ea				; enable all ,validation generale
				setb		et0			; enable	interruption timer
				clr		pt0   		; clr priorité timer0
        		cpl		ledmC
        		mov		r6,#80		; increment pour la direction
        		;mov		r7,#1			; increment pour la vitesse
        		
; chargement des valeurs par défaut:        		
				mov		vd2l,#vd1l	; chargement de la valeur de repos 1500æs
				mov		vd2h,#vd1h	; pour la direction
				mov		vdr2l,#vdr1l; chargement du complement (1000us)a 2,5ms
				mov		vdr2h,#vdr1h; pour la direction 
			
				mov		vm2l,#vm1l	; chargement de la valeur de repos 1500æs
				mov		vm2h,#vm1h	; pour le moteur
				mov		vmr2l,#vmr1l; complement moteur
				mov		vmr2h,#vmr1h

;phase 1 pour le cycle d'asservissement:			
				mov		r0,#0			; debut du traitement des signaux dir et mot
				
;lancement du timer0:				
				mov		th0,#0FFh	; pour lancement du timer 0 premiŠre fois
				mov		tl0,#0F0h	; pour lancement du timer 0 premiŠre fois
				setb		tr0			; lancement du timer0
											; ensuite le timer se relance tout seul


;boucle principale:
				mov		r1,#5      ; 5x20ms = 100ms
				lcall		durecom    
								
reglage:
				jb			balise_here,attention_balise
				jnb		capg,test_capd
				jnb		capd,vers_gauche
				lcall		roues_droites
				lcall		vitesse_croisiere
				mov		r1,#5
				lcall		durecom
				ljmp		reglage	
				
test_capd:
				jnb		capd,sortie_piste
				
vers_droite:
				cpl		ledmc
				clr		old_dir
				lcall		vitesse_virage
				lcall		tournedroite
				mov		r1,#5
				lcall		durecom
				ljmp		reglage				
				
vers_gauche:
				cpl		ledmc
				setb		old_dir
				lcall		vitesse_virage
				lcall		tournegauche
				mov		r1,#5
				lcall		durecom
				ljmp		reglage
				
sortie_piste:
				jnb		old_dir,sortie_gauche		


sortie_droite:
				cpl		ledmc
				;lcall		vitesse_virage
				lcall		braque_gauche
				mov		r1,#5
				lcall		durecom
				ljmp		reglage

sortie_gauche:
				cpl		ledmc
				;lcall		vitesse_virage
				lcall		braque_droite
				mov		r1,#5
				lcall		durecom
				ljmp		reglage
				
;--------------------------------------------------------------------------
attention_balise:				
				lcall		vitesse_balise
				mov		r6,#50
				
reglage_balise:
				jnb		balise_here,sortie_balise
				jnb		capg,test_capd_balise
				jnb		capd,vers_gauche_balise
				lcall		roues_droites
				mov		r1,#5
				lcall		durecom
				ljmp		reglage_balise	
				
test_capd_balise:
				jnb		capd,sortie_piste_balise
				
vers_droite_balise:
				cpl		ledmc
				clr		old_dir
				lcall		tournedroite
				mov		r1,#5
				lcall		durecom
				ljmp		reglage_balise				
				
vers_gauche_balise:
				cpl		ledmc
				setb		old_dir
				lcall		tournegauche
				mov		r1,#5
				lcall		durecom
				ljmp		reglage_balise
				
sortie_piste_balise:
				jnb		old_dir,sortie_gauche		

sortie_droite_balise:
				cpl		ledmc
				lcall		braque_gauche
				mov		r1,#5
				lcall		durecom
				ljmp		reglage_balise

sortie_gauche_balise:
				cpl		ledmc
				lcall		braque_droite
				mov		r1,#5
				lcall		durecom
				ljmp		reglage_balise

sortie_balise:	
				mov		r6,#80
				lcall		vitesse_accelere
				mov		r1,#5
				lcall		durecom
				ljmp		reglage
				
;--------------------------------------------------------------------------

				end				

