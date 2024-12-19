;merge sort

	AREA code_area, CODE, READONLY
		ENTRY

float_number_series EQU 0x0450
sorted_number_series EQU 0x00018AEC
final_result_series EQU 0x00031190

;========== Do not change this area ===========

initialization
	LDR r0, =0xDEADBEEF				; seed for random number
	LDR r1, =float_number_series	
	LDR r2, =10000 				; The number of element in stored sereis
	LDR r3, =0x0EACBA90				; constant for random number

save_float_series
	CMP r2, #0
	BEQ ms_init
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
	
ms_init  ;merge
	LDR r0, =float_number_series
	LDR r2, =final_result_series
	LDR sp, =0x00100000  	;stack pointer
	
	
ms_loop
	LDMIA r0!, {r8}  
	STMIA r2!, {r8}  
	
	CMP r0, r1    
	BEQ ms_init2
	
	B ms_loop
	
	
ms_init2
	LDR r1, =sorted_number_series
	LDR r2, =final_result_series
	
	MOV r3, #0  ;r3 = p
	SUB r4, r4, #1   ;r4 = count = r
	
	BL merge_sort
	B exit


merge_sort   ;(A, p, r)
	PUSH {r3-r6, lr} 
	ADD r5, r3, r4       ;r5 = q
	MOV r5, r5, LSR #1   ;q = (p + r) / 2
	
	CMP r3, r4  		 ;if p < r
	POPGE {r3-r6, pc}    ;p >= r
	
	MOV r6, r4
	MOV r4, r5  	
	BL merge_sort   ;merge_sort(A, p, q)
	
	ADD r7, r5, #1 	;q + 1
	MOV r4, r6  	;r
	
	MOV r6, r3 
	MOV r3, r7 
	BL merge_sort   ;merge_sort(A, q+1, r)
	
	MOV r3, r6 
	BL merge
	POP {r3-r6, pc}
	
	
merge  ;(A, p, q, r)
	PUSH {lr}
	SUB r7, r5, r3  
	ADD r7, r7, #1  ;r7 = n1 = q - p + 1
	SUB r8, r4, r5  ;r8 = n2 = r - q
	
	MOV r9, #0   ;i
	
	
loop_L  ;i, n1
	CMP r9, r7   
	MOVEQ r9, #1 ;j
	BEQ loop_R
	
	ADD r10, r3, r9
	LDR r11, [r2, r10, LSL #2]
	STR r11, [r1, r9, LSL #2]
	ADD r9, r9, #1
	B loop_L
	
	
loop_R  ;j, n2
	CMP r9, r8
	BGT ms_init3
	
	ADD r10, r5, r9
	ADD r12, r7, r9
	MOV r10, r10, LSL #2
	MOV r12, r12, LSL #2
	LDR r11, [r2, r10]
	STR r11, [r1, r12]
	ADD r9, r9, #1
	B loop_R


ms_init3
	LDR r9, =0x7fffffff  
	STR r9, [r1, r7, LSL #2]
	ADD r8, r8, #1
	ADD r10, r7, r8
	STR r9, [r1, r10, LSL #2]


ms_init4
	MOV r9, #0 		 ;i
	ADD r7, r7, #1
	MOV r10, r7      ;j
	MOV r6, r3       ;k = p
	
	
loop_K
	CMP r6, r4   	 ;k < r
	BGT exit
	B loopk
	
	
loopk
	LDR r11, [r1, r9, LSL #2] 	;L[i]
	LDR r12, [r1, r10, LSL #2] 	;R[j]
	
	ANDS r0, r11, r12
	BLMI com_neg   ;negative
	
	CMP r11, r12
	;L[i] > R[j]
	STRGT r12, [r2, r6, LSL #2]
	ADDGT r10, r10, #1
	;L[i] <= R[j]
	STRLE r11, [r2, r6, LSL #2]
	ADDLE r9, r9, #1
	
	ADD r6, r6, #1
	B loop_K
	
	
com_neg
	CMP r12, r11
	ADD pc, lr, #4 
	
	
exit
	POP {pc}
	MOV pc, #0   ;Program end
	END

;========== End your code here ===========