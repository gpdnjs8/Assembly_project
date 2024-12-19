;insertion sort

	AREA code_area, CODE, READONLY
		ENTRY

float_number_series EQU 0x0450
sorted_number_series EQU 0x00018AEC
final_result_series EQU 0x00031190

;========== Do not change this area ===========

initialization
 	LDR r0, =0xDEADBEEF				; seed for random number
	LDR r1, =float_number_series	
	LDR r2, =10000	; The number of element in stored sereis
	LDR r3, =0x0EACBA90				; constant for random number

save_float_series
	CMP r2, #0
	BEQ is_init
	BL random_float_number
	STR r0, [r1], #4
	SUB r2, r2, #1
	ADD r4, r4, #1   ;count
	MOV r5, #0
	B save_float_series

random_float_number
	MOV r5, LR
	EOR r0, r0, r3
	EOR r3, r0, r3, ROR #2
	CMP r0, r1
	BLGE shift_left
	BLLT shift_right
	BX r5

shift_left
	LSL r0, r0, #1
	BX LR

shift_right
	LSR r0, r0, #1
	BX LR
	
;============================================

;========== Start your code here ===========

is_init 
	LDR r1, =float_number_series
	MOV r2, r4  ;count (the number of element)
	LDR r3, =final_result_series
	
	MOV r4, #1   ;index
	
	LDR r5, [r1]
	STR r5, [r3]  

	B is_loop
	
	
is_loop	
	MOV r8, r4  ;r8 = j
	
	CMP r2, r4   ;end
	BEQ exit
	
	LDR r7, [r1, r4, LSL #2]
	MOV r11, pc
	B is_loop2
	
	STR r7, [r3, r9, LSL #2]
	ADD r4, r4, #1  ;countup, modddd
	B is_loop
	
	
is_loop2
	SUBS r8, r8, #1
	ADD r9, r8, #1  
	BMI moveto   ;mod

	LDR r10, [r3, r8, LSL #2]
	
	ANDS r0, r7, r10  
	BLMI com_neg  ;negative
	
	CMP r10, r7
	BGT sort 
	BLE moveto  ;mod
	

moveto
	BX r11
	
com_neg  ;mod
	CMP r7, r10
	ADD pc, lr, #4
	
sort
	STR r10, [r3,  r9, LSL #2]
	B is_loop2
	
exit
	MOV pc, #0   ;Program end
	END 


;========== End your code here ===========