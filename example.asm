.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Exemplu proiect desenare",0
area_width EQU 640
area_height EQU 480
area DD 0
pointer dd 46
pointer1 dd 56
pointer2 dd 137
counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include litere.inc
include digits.inc
include letters.inc
include caracter.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl caracteree
	cmp eax, 'Z'
	jg caracteree
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
	
caracteree:
	cmp eax,33
	jl literee
	cmp eax,46
	jg literee
	sub eax,33
	lea esi,caracter
	jmp draw_text
	
literee:
	cmp eax,'a'
	jl make_digit
	cmp eax,'z'
	jg make_digit
	sub eax,'a'
	lea esi,litere
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

 line_horizontal macro x,y,len,color
 local bucla_line
 mov eax,y
 mov ebx,area_width
 mul ebx
 add eax,x
 shl eax,2
 add eax,area
 mov ecx,len
 bucla_line:
 mov dword ptr[eax],color
 add eax,4
 loop bucla_line
 endm
 
 line_vertical macro x,y,len,color
 local bucla_line
 mov eax,y
 mov ebx,area_width
 mul ebx
 add eax,x
 shl eax,2
 add eax,area
 mov ecx,len
 bucla_line:
 mov dword ptr[eax],color
 add eax, area_width*4
 loop bucla_line
 endm
 
 line_horizontal_1 macro x,y,len,color
 local bucla_line
 mov eax,y
 mov ebx,area_width
 mul ebx
 add eax,x
 shl eax,2
 add eax,area
 mov ecx,len
 bucla_line:
 mov dword ptr[eax],color
 add eax,4
 loop bucla_line
 endm
 
 
 
 
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere

evt_click:

	
	mov eax,[ebp+arg2];;;  tasta "z"
	cmp eax,73
	jl jos
	cmp eax,93
	jg jos
	mov eax,[ebp+arg3]
	cmp eax,270
	jl jos
	cmp eax, 282
	jg jos
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareZ
	make_text_macro 'Z', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareZ:
	make_text_macro 'z', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere

	
	jos:
	mov eax,[ebp+arg2];;;  tasta "jos"
	cmp eax,307
	jl coborare
	cmp eax,328
	jg coborare
	mov eax,[ebp+arg3]
	cmp eax,290
	jl coborare
	cmp eax, 310
	jg coborare
		;make_text_macro ' ',area,pointer,pointer2
		line_vertical pointer,pointer2,20,0FFFFFFh ;;;; cursor
	add pointer2,25
	jmp afisare_litere
	
	
	
	coborare:
	mov eax,[ebp+arg2];;;  tasta "enter"
	cmp eax,277
	jl sus
	cmp eax,301
	jg sus
	mov eax,[ebp+arg3]
	cmp eax,229
	jl sus
	cmp eax, 261
	jg sus
	
	line_vertical pointer,pointer2,20,0FFFFFFh 
	add pointer2,25
	mov pointer,46
	mov pointer1,56
	jmp afisare_litere
	
	
	sus:
	
	mov eax,[ebp+arg2];;;  tasta "sus"
	cmp eax,305
	jl tasta1
	cmp eax,329
	jg tasta1
	mov eax,[ebp+arg3]
	cmp eax,268
	jl tasta1
	cmp eax, 285
	jg tasta1
	line_vertical pointer,pointer2,20,0FFFFFFh 
	sub pointer2,25
	
	jmp afisare_litere
	
	
	
    tasta1:
	mov eax,[ebp+arg2];;;  tasta "1"
	cmp eax,70
	jl button_fail
	cmp eax,95
	jg button_fail
	mov eax,[ebp+arg3]
	cmp eax,206
	jl button_fail
	cmp eax, 227
	jg button_fail
	make_text_macro '1', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere

	button_fail:
	mov eax,[ebp+arg2];;;  tasta "2"
	cmp eax,98
	jl button_fail2
	cmp eax,115
	jg button_fail2
	mov eax,[ebp+arg3]
	cmp eax,210
	jl button_fail2
	cmp eax, 227
	jg button_fail2
	make_text_macro '2', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	button_fail2:
	mov eax,[ebp+arg2];;;  tasta "3"
	cmp eax,116
	jl button_fail3
	cmp eax,132
	jg button_fail3
	mov eax,[ebp+arg3]
	cmp eax,210
	jl button_fail3
	cmp eax, 224
	jg button_fail3
	make_text_macro '3', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	button_fail3:
	mov eax,[ebp+arg2];;;  tasta "4"
	cmp eax,138
	jl button_fail4
	cmp eax,153
	jg button_fail4
	mov eax,[ebp+arg3]
	cmp eax,210
	jl button_fail4
	cmp eax, 224
	jg button_fail4
	make_text_macro '4', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	button_fail4:
	mov eax,[ebp+arg2];;;  tasta "5"
	cmp eax,157
	jl button_fail5
	cmp eax,172
	jg button_fail5
	mov eax,[ebp+arg3]
	cmp eax,210
	jl button_fail5
	cmp eax, 224
	jg button_fail5
	make_text_macro '5', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	button_fail5:
	mov eax,[ebp+arg2];;;  tasta "6"
	cmp eax,178
	jl button_fail6
	cmp eax,191
	jg button_fail6
	mov eax,[ebp+arg3]
	cmp eax,210
	jl button_fail6
	cmp eax, 224
	jg button_fail6
	make_text_macro '6', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	button_fail6:
	mov eax,[ebp+arg2];;;  tasta "7"
	cmp eax,198
	jl button_fail7
	cmp eax,212
	jg button_fail7
	mov eax,[ebp+arg3]
	cmp eax,210
	jl button_fail7
	cmp eax, 224
	jg button_fail7
	make_text_macro '7', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	button_fail7:
	mov eax,[ebp+arg2];;;  tasta "8"
	cmp eax,219
	jl button_fail8
	cmp eax,232
	jg button_fail8
	mov eax,[ebp+arg3]
	cmp eax,210
	jl button_fail8
	cmp eax, 224
	jg button_fail8
	make_text_macro '8', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere 
	
	button_fail8:
	mov eax,[ebp+arg2];;;  tasta "9"
	cmp eax,238
	jl button_fail9
	cmp eax,252
	jg button_fail9
	mov eax,[ebp+arg3]
	cmp eax,210
	jl button_fail9
	cmp eax, 224
	jg button_fail9
	make_text_macro '9', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	button_fail9:
	mov eax,[ebp+arg2];;;  tasta "0"
	cmp eax,258
	jl tab
	cmp eax,272
	jg tab
	mov eax,[ebp+arg3]
	cmp eax,210
	jl tab
	cmp eax, 224
	jg tab
	make_text_macro '0', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	tab:
	mov ecx,[ebp+arg2];;;  tasta "CAPS"
	cmp ecx,44
	jl caps
	cmp ecx,67
	jg caps
	mov ecx,[ebp+arg3]
	cmp ecx,232
	jl caps
	cmp ecx, 247
	jg caps
	make_text_macro ' ', area,pointer,pointer2
	add pointer,30
	add pointer1,30
	make_text_macro ' ', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	
	
	caps:
	mov ecx,[ebp+arg2];;;  tasta "CAPS"
	cmp ecx,42
	jl litereQ
	cmp ecx,67
	jg litereQ
	mov ecx,[ebp+arg3]
	cmp ecx,248
	jl litereQ
	cmp ecx, 264
	jg litereQ

	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne StergeL
	line_horizontal_1 41,258,30,0FFFFFFh
	line_horizontal_1 41,257,30,0FFFFFFh
	line_horizontal_1 41,256,30,0FFFFFFh
	line_horizontal_1 41,255,30,0FFFFFFh
	line_horizontal_1 41,254,30,0FFFFFFh
	jmp afisare_litere
	
	
	StergeL:
	line_horizontal_1 41,258,30,000FF00h
	line_horizontal_1 41,257,30,000FF00h
	line_horizontal_1 41,256,30,000FF00h
	line_horizontal_1 41,255,30,000FF00h
	line_horizontal_1 41,254,30,000FF00h
	
	jmp afisare_litere
	
	litereQ:
	mov eax,[ebp+arg2];;;  tasta "q"
	cmp eax,73
	jl litereW
	cmp eax,93
	jg litereW
	mov eax,[ebp+arg3]
	cmp eax,228
	jl litereW
	cmp eax, 244
	jg litereW
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareQ
	make_text_macro 'Q', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareQ:
	make_text_macro 'q', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereW:
	mov eax,[ebp+arg2];;;  tasta "w"
	cmp eax,98
	jl litereE
	cmp eax,114
	jg litereE
	mov eax,[ebp+arg3]
	cmp eax,228
	jl litereE
	cmp eax, 244
	jg litereE
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareW
	make_text_macro 'W', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareW:
	make_text_macro 'w', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereE:
	mov eax,[ebp+arg2];;;  tasta "e"
	cmp eax,117
	jl litereR
	cmp eax,133
	jg litereR
	mov eax,[ebp+arg3]
	cmp eax,228
	jl litereR
	cmp eax, 244
	jg litereR
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareE
	make_text_macro 'E', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareE:
	make_text_macro 'e', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	
	litereR:
	
	mov eax,[ebp+arg2];;;  tasta "r"
	cmp eax,137
	jl litereT
	cmp eax,152
	jg litereT
	mov eax,[ebp+arg3]
	cmp eax,228
	jl litereT
	cmp eax, 244
	jg litereT
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareR
	make_text_macro 'R', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareR:
	make_text_macro 'r', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereT:
	
	mov eax,[ebp+arg2];;;  tasta "t"
	cmp eax,157
	jl litereY
	cmp eax,172
	jg litereY
	mov eax,[ebp+arg3]
	cmp eax,228
	jl litereY
	cmp eax, 244
	jg litereY
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareT
	make_text_macro 'T', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareT:
	make_text_macro 't', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereY:
	
	mov eax,[ebp+arg2];;;  tasta "y"
	cmp eax,178
	jl litereU
	cmp eax,192
	jg litereU
	mov eax,[ebp+arg3]
	cmp eax,228
	jl litereU
	cmp eax, 244
	jg litereU
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareY
	make_text_macro 'Y', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareY:
	make_text_macro 'y', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereU:
	mov eax,[ebp+arg2];;;  tasta "u"
	cmp eax,197
	jl litereI
	cmp eax,214
	jg litereI
	mov eax,[ebp+arg3]
	cmp eax,228
	jl litereI
	cmp eax, 244
	jg litereI
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareU
	make_text_macro 'U', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareU:
	make_text_macro 'u', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	
	litereI:
	
	mov eax,[ebp+arg2];;;  tasta "i"
	cmp eax,219
	jl litereO
	cmp eax,233
	jg litereO
	mov eax,[ebp+arg3]
	cmp eax,228
	jl litereO
	cmp eax, 244
	jg litereO
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareI
	make_text_macro 'I', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareI:
	make_text_macro 'i', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereO:
	mov eax,[ebp+arg2];;;  tasta "o"
	cmp eax,237
	jl litereP
	cmp eax,254
	jg litereP
	mov eax,[ebp+arg3]
	cmp eax,228
	jl litereP
	cmp eax, 244
	jg litereP
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareO
	make_text_macro 'O', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareO:
	make_text_macro 'o', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	
	litereP:
	
	mov eax,[ebp+arg2];;;  tasta "p"
	cmp eax,258
	jl litereA
	cmp eax,272
	jg litereA
	mov eax,[ebp+arg3]
	cmp eax,228
	jl litereA
	cmp eax, 244
	jg litereA
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareP
	make_text_macro 'P', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareP:
	make_text_macro 'p', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereA:
	
	mov eax,[ebp+arg2];;;  tasta "a"
	cmp eax,73
	jl litereS
	cmp eax,93
	jg litereS
	mov eax,[ebp+arg3]
	cmp eax,249
	jl litereS
	cmp eax, 263
	jg litereS
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareA
	make_text_macro 'A', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareA:
	make_text_macro 'a', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereS:
	mov eax,[ebp+arg2];;;  tasta "s"
	cmp eax,98
	jl litereS
	cmp eax,111
	jg litereD
	mov eax,[ebp+arg3]
	cmp eax,249
	jl litereD
	cmp eax, 263
	jg litereD
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareS
	make_text_macro 'S', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareS:
	make_text_macro 's', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereD:
	mov eax,[ebp+arg2];;;  tasta "d"
	cmp eax,117
	jl litereF
	cmp eax,133
	jg litereF
	mov eax,[ebp+arg3]
	cmp eax,249
	jl litereF
	cmp eax, 263
	jg litereF
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareD
	make_text_macro 'D', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareD:
	make_text_macro 'd', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereF:
	mov eax,[ebp+arg2];;;  tasta "f"
	cmp eax,137
	jl litereG
	cmp eax,152
	jg litereG
	mov eax,[ebp+arg3]
	cmp eax,249
	jl litereG
	cmp eax, 263
	jg litereG
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareF
	make_text_macro 'F', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareF:
	make_text_macro 'f', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereG:
	mov eax,[ebp+arg2];;;  tasta "g"
	cmp eax,157
	jl litereH
	cmp eax,172
	jg litereH
	mov eax,[ebp+arg3]
	cmp eax,249
	jl litereH
	cmp eax, 263
	jg litereH
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareG
	make_text_macro 'G', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareG:
	make_text_macro 'g', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereH:
	mov eax,[ebp+arg2];;;  tasta "h"
	cmp eax,178
	jl litereJ
	cmp eax,192
	jg litereJ
	mov eax,[ebp+arg3]
	cmp eax,249
	jl litereJ
	cmp eax, 263
	jg litereJ
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareH
	make_text_macro 'H', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareH:
	make_text_macro 'h', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereJ:
	mov eax,[ebp+arg2];;;  tasta "j"
	cmp eax,197
	jl litereK
	cmp eax,214
	jg litereK
	mov eax,[ebp+arg3]
	cmp eax,249
	jl litereK
	cmp eax, 263
	jg litereK
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareJ
	make_text_macro 'J', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareJ:
	make_text_macro 'j', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereK:
	
	mov eax,[ebp+arg2];;;  tasta "k"
	cmp eax,219
	jl litereL
	cmp eax,233
	jg litereL
	mov eax,[ebp+arg3]
	cmp eax,249
	jl litereL
	cmp eax, 263
	jg litereL
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareK
	make_text_macro 'K', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareK:
	make_text_macro 'k', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	
	litereL:
	mov eax,[ebp+arg2];;;  tasta "l"
	cmp eax,237
	jl litereX
	cmp eax,254
	jg litereX
	mov eax,[ebp+arg3]
	cmp eax,249
	jl litereX
	cmp eax, 263
	jg litereX
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareL
	make_text_macro 'L', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareL:
	make_text_macro 'l', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	; litereZ:
	
	; mov eax,[ebp+arg2];;;  tasta "z"
	; cmp eax,73
	; jl litereX
	; cmp eax,93
	; jg litereX
	; mov eax,[ebp+arg3]
	; cmp eax,270
	; jl litereX
	; cmp eax, 282
	; jg litereX
	
	; mov eax,257
	; mov edx,area_width
	; mul edx ;;; ecx<= y*area_width
	; add eax,45
	; shl eax,2
	; add eax,area
	; mov ebx,dword ptr[eax]
	; cmp ebx, 000FF00h
	; jne mareZ
	; make_text_macro 'Z', area,pointer,pointer2
	; line_vertical pointer1,pointer2,20,0 ;;;; cursor
	; add pointer,10
	; add pointer1,10
	; jmp afisare_litere
	; mareZ:
	; make_text_macro 'z', area,pointer,pointer2
	; line_vertical pointer1,pointer2,20,0 ;;;; cursor
	; add pointer,10
	; add pointer1,10
	; jmp afisare_litere
	litereX:
	
	mov eax,[ebp+arg2];;;  tasta "x"
	cmp eax,98
	jl litereC
	cmp eax,111
	jg litereC
	mov eax,[ebp+arg3]
	cmp eax,269
	jl litereC
	cmp eax, 285
	jg litereC
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareX
	make_text_macro 'X', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareX:
	make_text_macro 'x', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereC:
		
	mov eax,[ebp+arg2];;;  tasta "c"
	cmp eax,117
	jl litereV
	cmp eax,133
	jg litereV
	mov eax,[ebp+arg3]
	cmp eax,269
	jl litereV
	cmp eax, 285
	jg litereV
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareC
	make_text_macro 'C', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareC:
	make_text_macro 'c', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereV:
		
	mov eax,[ebp+arg2];;;  tasta "v"
	cmp eax,137
	jl litereB
	cmp eax,152
	jg litereB
	mov eax,[ebp+arg3]
	cmp eax,269
	jl litereB
	cmp eax, 285
	jg litereB
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareV
	make_text_macro 'V', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareV:
	make_text_macro 'v', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereB:
	
		
	mov eax,[ebp+arg2];;;  tasta "b"
	cmp eax,157
	jl litereN
	cmp eax,172
	jg litereN
	mov eax,[ebp+arg3]
	cmp eax,269
	jl litereN
	cmp eax, 285
	jg litereN
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareB
	make_text_macro 'B', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareB:
	make_text_macro 'b', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereN:
	
		
	mov eax,[ebp+arg2];;;  tasta "n"
	cmp eax,178
	jl litereM
	cmp eax,192
	jg litereM
	mov eax,[ebp+arg3]
	cmp eax,269
	jl litereM
	cmp eax, 285
	jg litereM
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareN
	make_text_macro 'N', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareN:
	make_text_macro 'n', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	litereM:
	
	mov eax,[ebp+arg2];;;  tasta "m"
	cmp eax,197
	jl Stergere
	cmp eax,214
	jg Stergere
	mov eax,[ebp+arg3]
	cmp eax,269
	jl Stergere
	cmp eax, 285
	jg Stergere
	
	mov eax,257
	mov edx,area_width
	mul edx ;;; ecx<= y*area_width
	add eax,45
	shl eax,2
	add eax,area
	mov ebx,dword ptr[eax]
	cmp ebx, 000FF00h
	jne mareM
	make_text_macro 'M', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	mareM:
	make_text_macro 'm', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	
	
	Stergere:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;back
	mov eax,[ebp+arg2];;;  tasta "stergere"
	cmp eax,278
	jl stanga
	cmp eax,299
	jg stanga
	mov eax,[ebp+arg3]
	cmp eax,208
	jl stanga
	cmp eax, 223
	jg stanga
	
	sub pointer,10
	make_text_macro ' ', area,pointer,pointer2
	line_vertical pointer,pointer2,20,0
	sub pointer1,10
	line_vertical pointer1,pointer2,20,0FFFFFFh
	jmp afisare_litere
	
	stanga:
	mov eax,[ebp+arg2];;;  tasta "stanga"
	cmp eax,276
	jl dreapta
	cmp eax,301
	jg dreapta
	mov eax,[ebp+arg3]
	cmp eax,290
	jl dreapta
	cmp eax, 308
	jg dreapta
	line_vertical pointer1,pointer2,20,0FFFFFFh
	sub pointer,10
	line_vertical pointer,pointer2,20,0
	sub pointer1,10
	line_vertical pointer1,pointer2,20,0FFFFFFh
	
	;;line_vertical pointer1,pointer2,20,0 ;;;;;;;;; cursor
	jmp afisare_litere
	
	dreapta:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; semn de intrebare!!!!!!
	mov eax,[ebp+arg2];;;  tasta "dreapta"
	cmp eax,334
	jl space
	cmp eax,357
	jg space
	mov eax,[ebp+arg3]
	cmp eax,289
	jl space
	cmp eax, 310
	jg space

	
	sub pointer1,10
	line_vertical pointer1,pointer2,20,0FFFFFFh
	add pointer1,20
	
	add pointer,10
	line_vertical pointer,pointer2,20,0FFFFFFh
	jmp afisare_litere
	
	space:
	mov eax,[ebp+arg2];;;  tasta "space"
	cmp eax,74
	jl punct
	cmp eax,269
	jg punct
	mov eax,[ebp+arg3]
	cmp eax,290
	jl punct
	cmp eax, 309
	jg punct
	
	make_text_macro ' ', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	punct:
	mov eax,[ebp+arg2];;;  tasta "."
	cmp eax,219
	jl under
	cmp eax,233
	jg under
	mov eax,[ebp+arg3]
	cmp eax,271
	jl under
	cmp eax, 286
	jg under
	make_text_macro ',', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	
	under:
	mov eax,[ebp+arg2];;;  tasta "under"
	cmp eax,218
	jl plus
	cmp eax,250
	jg plus
	mov eax,[ebp+arg3]
	cmp eax,271
	jl plus
	cmp eax, 284
	jg plus
	make_text_macro '.', area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	plus:
	
	mov eax,[ebp+arg2];;;  tasta "plus"
	cmp eax,305
	jl minus
	cmp eax,328
	jg minus
	mov eax,[ebp+arg3]
	cmp eax,209
	jl minus
	cmp eax, 263
	jg minus
	make_text_macro 39, area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
	minus:
	mov eax,[ebp+arg2];;;  tasta "-"
	cmp eax,333
	jl afisare_litere
	cmp eax,357
	jg afisare_litere
	mov eax,[ebp+arg3]
	cmp eax,209
	jl afisare_litere
	cmp eax, 263
	jg afisare_litere
	make_text_macro 38, area,pointer,pointer2
	line_vertical pointer1,pointer2,20,0 ;;;; cursor
	add pointer,10
	add pointer1,10
	jmp afisare_litere
	
evt_timer:
	inc counter
afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	;scriem un mesaj	

	make_text_macro 35, area, 285, 292
	make_text_macro 33, area, 312, 292
	make_text_macro 36, area, 345, 292
    make_text_macro 34, area, 312, 266
	make_text_macro 41, area, 50, 226
	make_text_macro 40, area, 50, 245
	make_text_macro 42, area, 287,205
	make_text_macro 37, area, 284, 240
	make_text_macro 39, area, 312, 233
	make_text_macro 38, area, 342, 236
	
	make_text_macro 44, area, 224, 260
	make_text_macro 46, area, 240, 260
	make_text_macro 45, area, 277, 267

	line_vertical pointer,pointer2,20,0 ;;;; cursor
	make_text_macro '1', area, 80, 206
	make_text_macro '2', area, 100, 206
	make_text_macro '3', area, 120, 206
	make_text_macro '4', area, 140, 206
	make_text_macro '5', area, 160, 206
	make_text_macro '6', area, 180, 206
	make_text_macro '7', area, 200, 206
	make_text_macro '8', area, 220, 206
	make_text_macro '9', area, 240, 206
	make_text_macro '0', area, 260, 206
		
	make_text_macro 'Q', area, 80, 226
	make_text_macro 'W', area, 100, 226
	make_text_macro 'E', area, 120, 226
	make_text_macro 'R', area, 140, 226
	make_text_macro 'T', area, 160, 226
	make_text_macro 'Y', area, 180, 226
	make_text_macro 'U', area, 200, 226
	make_text_macro 'I', area, 220, 226
	make_text_macro 'O', area, 240, 226
	make_text_macro 'P', area, 260, 226	
	
	make_text_macro 'A', area, 80, 246
	make_text_macro 'S', area, 100, 246
	make_text_macro 'D', area, 120, 246
	make_text_macro 'F', area, 140, 246
	make_text_macro 'G', area, 160, 246
	make_text_macro 'H', area, 180, 246
	make_text_macro 'J', area, 200, 246
	make_text_macro 'K', area, 220, 246
	make_text_macro 'L', area, 240, 246
	
	make_text_macro 'Z', area, 80, 266
	make_text_macro 'X', area, 100, 266
	make_text_macro 'C', area, 120, 266
	make_text_macro 'V', area, 140, 266
	make_text_macro 'B', area, 160, 266
	make_text_macro 'N', area, 180, 266
	make_text_macro 'M', area, 200, 266
	
	
	
	
	line_vertical 40,130,181,0
	line_horizontal 40,206,320,0
	line_horizontal 40,130,320,0
	line_vertical 360,130,150,0
	line_vertical 360,206,105,0
	line_horizontal 40,311,320,0
	line_vertical 70,206,105,0  ;;  linia2
	line_horizontal 40,287,320,0
	line_horizontal 40,266,320,0
	line_horizontal 40,246,235,0
	line_horizontal 40,226,263,0
	line_vertical 95,206,81,0
	line_vertical 115,206,81,0
	line_vertical 135,206,81,0
	line_vertical 155,206,81,0
	line_vertical 175,206,81,0
	line_vertical 195,206,81,0
	line_vertical 215,206,81,0
	line_vertical 235,206,81,0
	line_vertical 255,206,81,0
	line_vertical 275,206,41,0
	line_vertical 273,287,25,0
	;line_vertical 295,206,81,0
	line_vertical 303,206,105,0
	line_vertical 331,206,105,0
	
	cmp pointer,350
	jl final_draw
	alta:
	line_vertical pointer,pointer2,20,0FFFFFFh
	mov pointer,46
	mov pointer1,56
	add pointer2,25
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
