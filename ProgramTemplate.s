;*******************************************************************************
;@file				 Main.s
;@project		     Microprocessor Systems Term Project
;@31/01/2021
;
;@PROJECT GROUP
;@Group no: 41
;@Muhammet Dervis Kopuz 504201531
;@member2
;@member3
;@member4
;@member5
;*******************************************************************************
;*******************************************************************************
;@section 		INPUT_DATASET
;*******************************************************************************

;@brief 	This data will be used for insertion and deletion operation.
;@note		The input dataset will be changed at the grading. 
;			Therefore, you shouldn't use the constant number size for this dataset in your code. 
				AREA     IN_DATA_AREA, DATA, READONLY
IN_DATA			DCD		0x10, 0x20, 0x15, 0x65, 0x25, 0x01, 0x01, 0x12, 0x65, 0x25, 0x85, 0x46, 0x10, 0x00
END_IN_DATA

;@brief 	This data contains operation flags of input dataset. 
;@note		0 -> Deletion operation, 1 -> Insertion 
				AREA     IN_DATA_FLAG_AREA, DATA, READONLY
IN_DATA_FLAG	DCD		0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x02
END_IN_DATA_FLAG


;*******************************************************************************
;@endsection 	INPUT_DATASET
;*******************************************************************************

;*******************************************************************************
;@section 		DATA_DECLARATION
;*******************************************************************************

;@brief 	This part will be used for constant numbers definition.
NUMBER_OF_AT	EQU		20									; Number of Allocation Table
AT_SIZE			EQU		NUMBER_OF_AT*4						; Allocation Table Size


DATA_AREA_SIZE	EQU		AT_SIZE*32*2						; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 2 word (Value + Address)
															; Each word has 4 byte
ARRAY_SIZE		EQU		AT_SIZE*32							; Allocable data area
															; Each allocation table has 32 Cell
															; Each Cell Has 1 word (Value)
															; Each word has 4 byte
LOG_ARRAY_SIZE	EQU     AT_SIZE*32*3						; Log Array Size
															; Each log contains 3 word
															; 16 bit for index
															; 8 bit for error_code
															; 8 bit for operation
															; 32 bit for data
															; 32 bit for timestamp in us

;//-------- <<< USER CODE BEGIN Constant Numbers Definitions >>> ----------------------	
;Flag codes for program status
PROGRAM_START	EQU			0								;Allocate flag code 0 to program start operation								
TIMER_START		EQU			1								;Allocate flag code 1 to program timer operation
FINISHED		EQU			2								;Allocate flag code 2 to program finish
	
;Operation Flags
REMOVE			EQU			0								;Allocate flag code 0 to remove data operation from Linked List
INSERT			EQU			1								;Allocate flag code 1 to inserting data to linked list
TRANSFORM		EQU			2								;Allocate flag code 2 to transforming linked list to array

;Error codes
NO_ERROR		EQU			0								;Allocate flag code 0 to No error explanation for all operations
NO_AREA			EQU			1								;Allocate flag code 1 to There is no allocable area explanation for insertion operations
DUPLICATE_DATA	EQU			2								;Allocate flag code 2 to Duplicated insertion operation explanation	for insertion operations
LL_EMPTY		EQU			3								;Allocate flag code 3 to The linked list is empty explanation for deletion operations
NO_ELEMENT		EQU			4								;Allocate flag code 4 to The element is not found explanation for deletion operations
CANT_TRANSFORM	EQU			5								;Allocate flag code 5 to The linked list could not be transformed explanation for Linked list to array function
NO_OPERATION	EQU			6								;Allocate flag code 6 to Operation is not found error.

;//-------- <<< USER CODE END Constant Numbers Definitions >>> ------------------------	

;*******************************************************************************
;@brief 	This area will be used for global variables.
				AREA     GLOBAL_VARIABLES, DATA, READWRITE		
				ALIGN	
TICK_COUNT		SPACE	 4									; Allocate #4 byte area to store tick count of the system tick timer.
FIRST_ELEMENT  	SPACE    4									; Allocate #4 byte area to store the first element pointer of the linked list.
INDEX_INPUT_DS  SPACE    4									; Allocate #4 byte area to store the index of input dataset.
INDEX_ERROR_LOG SPACE	 4									; Allocate #4 byte aret to store the index of the error log array.
PROGRAM_STATUS  SPACE    4									; Allocate #4 byte to store program status.
															; 0-> Program started, 1->Timer started, 2-> All data operation finished.
;//-------- <<< USER CODE BEGIN Global Variables >>> ----------------------															
				;MOVS	PROGRAM_STATUS,#0					;assign 0 to pogram status


;//-------- <<< USER CODE END Global Variables >>> ------------------------															

;*******************************************************************************

;@brief 	This area will be used for the allocation table
				AREA     ALLOCATION_TABLE, DATA, READWRITE		
				ALIGN	
__AT_Start
AT_MEM       	SPACE    AT_SIZE							; Allocate #AT_SIZE byte area from memory.
__AT_END

;@brief 	This area will be used for the linked list.
				AREA     DATA_AREA, DATA, READWRITE		
				ALIGN	
__DATA_Start
DATA_MEM        SPACE    DATA_AREA_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__DATA_END

;@brief 	This area will be used for the array. 
;			Array will be used at the end of the program to transform linked list to array.
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__ARRAY_Start
ARRAY_MEM       SPACE    ARRAY_SIZE						; Allocate #ARRAY_SIZE byte area from memory.
__ARRAY_END

;@brief 	This area will be used for the error log array. 
				AREA     ARRAY_AREA, DATA, READWRITE		
				ALIGN	
__LOG_Start
LOG_MEM       	SPACE    LOG_ARRAY_SIZE						; Allocate #DATA_AREA_SIZE byte area from memory.
__LOG_END

;//-------- <<< USER CODE BEGIN Data Allocation >>> ----------------------															
							


;//-------- <<< USER CODE END Data Allocation >>> ------------------------															

;*******************************************************************************
;@endsection 	DATA_DECLARATION
;*******************************************************************************

;*******************************************************************************
;@section 		MAIN_FUNCTION
;*******************************************************************************

			
;@brief 	This area contains project codes. 
;@note		You shouldn't change the main function. 				
				AREA MAINFUNCTION, CODE, READONLY
				ENTRY
				THUMB
				ALIGN 
__main			FUNCTION
				EXPORT __main
					BL	Free
				BL	Clear_Alloc					; Call Clear Allocation Function.
				BL  Clear_ErrorLogs				; Call Clear ErrorLogs Function.
				BL	Init_GlobVars				; Call Initiate Global Variable Function.
				BL	SysTick_Init				; Call Initialize System Tick Timer Function.
				LDR R0, =PROGRAM_STATUS			; Load Program Status Variable Addresses.
LOOP			LDR R1, [R0]					; Load Program Status Variable.
				CMP	R1, #2						; Check If Program finished.
				BNE LOOP						; Go to loop If program do not finish.
STOP			B	STOP						; Infinite loop.
				
				ENDFUNC
			
;*******************************************************************************
;@endsection 		MAIN_FUNCTION
;*******************************************************************************				

;*******************************************************************************
;@section 			USER_FUNCTIONS
;*******************************************************************************

;@brief 	This function will be used for System Tick Handler
SysTick_Handler	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------	
				EXPORT	SysTick_Handler
				PUSH	{LR}
				;increase tick count
				LDR		r0,=TICK_COUNT					;load tick count address
				LDR		r1,[r0]							;load tick count value to r1
				ADDS	r1,#1							;increase tick count by 1
				STR		r1,[r0]							;Store new tick count value
				
				;read input data
				LDR		r0,=IN_DATA						;Load address of input array
				LDR		r3,=INDEX_INPUT_DS				;load INDEX_INPUT_DS address
				LDR		r1,[r3]							;load INDEX_INPUT_DS value
				PUSH	{r1}							;push INDEX_INPUT_DS value to stack
				LSLS	r1,#2							;Multiply index by 4 to get array index
				LDR		r0,[r0,r1]						;read the data from input dataset with the corresponding index
				LDR		r2,=IN_DATA_FLAG				;load address of input array
				LDR		r2,[r2,r1]						;Read data flag from data_flag array
				POP		{r1}							;pop INDEX_INPUT_DS value from stack
				ADDS	r1,r1,#1						;increase INDEX_INPUT_DS value by one
				STR		r1,[r3]							;store new INDEX_INPUT_DS value
				CMP		r2,#INSERT						;check if operation = INSERT
				BL		Insert							;Branch with link to insert function
				CMP		r2,#REMOVE						;check if operation = REMOVE
				BL		Remove							;Branch with link to remove function
				CMP		r2,#TRANSFORM					;check if operation = TRANSFORM
				BL		LinkedList2Arr					;Branch with link to LinkedList2Arr function
				
				;Check if all input data is read
				;LDR		r0,=IN_DATA_AREA
				;LDR		r1,=INDEX_INPUT_DS				;load INDEX_INPUT_DS address
				;LDR		r1,[r1]							;load INDEX_INPUT_DS value
				;ADDS	r0,r1
				;LDR		r2,=IN_DATA_FLAG				;load address of input array
				
				
				POP		{PC}							;pop pc to exit systickhandler
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to initiate System Tick Handler
SysTick_Init	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Initialize >>> ----------------------							
				LDR		r0,=0xE000E010					;Load SysTick control and status register address
				;According to the formula
				;Period = (1 + ReloadValue)/Frequency of the cpu
				;Our Period is 834 microsecond
				;Frequency of the cpu is 4 MHZ
				;834.10^(-6) = (1 + ReloadValue)/4.10^(6)
				;Reload Value = 3336
				LDR		r1,=3336						;Load the reload value to r1 register
				STR 	r1,[r0,#4]						;Store reload value to reload value register
				MOVS	r1,#0							;assign 0 to r1 register
				STR		r1,[r0,#8]						;clear current value register
				MOVS	r1,#7							;set enable,clock,and interrupt flags
				STR		r1,[r0]							;Store r1 value to SystickCSR register
				
				;update program status
				LDR		r0,=PROGRAM_STATUS				;load program status address
				LDR		r1,=TIMER_START					;load r1 with timer started info
				STR		r1,[r0]							;Change program status to 1
				
				BX 		LR								;return with LR
				
;//-------- <<< USER CODE END System Tick Timer Initialize >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to stop the System Tick Timer
SysTick_Stop	FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Timer Stop >>> ----------------------	
				LDR		r0,=0xE000E010					;Load SysTick control and status register address
				MOVS	r1,#0							;set enable,clock,and interrupt flags
				STR		r1,[r0]							;Store r1 value to SystickCSR register
				MOVS	r1,#0							;assign 0 to r1 register
				STR		r1,[r0,#8]						;clear current value register and count flag
				
				;update program status
				LDR		r0,=PROGRAM_STATUS				;load program status address
				LDR		r1,=FINISHED					;load r1 with finished info
				STR		r1,[r0]							;Change program status to 2
				
				BX 		LR								;return with LR
				
				
;//-------- <<< USER CODE END System Tick Timer Stop >>> ------------------------				
				ENDFUNC

;*******************************************************************************				

;@brief 	This function will be used to clear allocation table
Clear_Alloc		FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Allocation Table Function >>> ----------------------															
				LDR		r0,=AT_MEM							;Load AT memory address
				LDR		r1,=NUMBER_OF_AT					;Load number of allocation table to r1
				MOVS	r2,#0								;assign 0 to r2 for clearing
				;LDR		r2,=0x11111111
				MOVS	r3,#0								;assign 0 to r3 for counting loops(i)
C_A_LOOP		CMP		r3,r1								;check if i>Number of allocations
				BGE		C_A_END								;branch to end of clear allocation
				PUSH	{r3}								;push r3 to stack
				LSLS	r3,#2								;multiply r3 by 4
				STR		r2,[r0,r3]							;clear allocation node
				POP		{r3}								;get r3 back from stack
				ADDS	r3,r3,#1							;increase r3 by 1
				B		C_A_LOOP							;branch to next iteration
				
			
C_A_END			BX 		LR									;return with LR
				
				
;//-------- <<< USER CODE END Clear Allocation Table Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************		

;@brief 	This function will be used to clear error log array
Clear_ErrorLogs	FUNCTION			
;//-------- <<< USER CODE BEGIN Clear Error Logs Function >>> ----------------------															
				LDR		r0,=LOG_MEM							;Load log memory address
				LDR		r1,=NUMBER_OF_AT					;Load number of allocation table to r1
				MOVS	r2,#32								;assign 32 to r2, there is 32 cells
				MULS	r1,r2,r1							;multiply r1 by 32
				MOVS	r2,#3								;assign 3 to r2, each cell has 3 words
				MULS	r1,r2,r1							;multiply r1 by 3
				MOVS	r2,#0								;assign 0 to r2 for clearing
				MOVS	r3,#0								;assign 0 to r3 for counting loops(i)
C_E_LOOP		CMP		r3,r1								;check if i>log size
				BGE		C_E_END								;branch to end of clearing logs
				PUSH	{r3}								;push r3 to stack
				LSLS	r3,#2								;multiply r3 by 4
				STR		r2,[r0,r3]							;clear allocation node
				POP		{r3}								;get r3 back from stack
				ADDS	r3,r3,#1							;increase r3 by 1
				B		C_E_LOOP							;branch to next iteration
				
C_E_END			BX		LR									;Return with LR
				
				
;//-------- <<< USER CODE END Clear Error Logs Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************

;@brief 	This function will be used to initialize global variables
Init_GlobVars	FUNCTION			
;//-------- <<< USER CODE BEGIN Initialize Global Variables >>> ----------------------		
				MOVS 	r1,#0								;Assign 0 to r1 register for initialization
				LDR		r0,=TICK_COUNT						;Load address of TICK_COUNT	
				STR		r1,[r0]								;Initialize TICK_COUNT as 0
				LDR		r0,=FIRST_ELEMENT					;Load address of FIRST_ELEMENT
				STR		r1,[r0]								;Initialize FIRST_ELEMENT as 0
				LDR		r0,=INDEX_INPUT_DS					;Load address of INDEX_INPUT_DS
				STR		r1,[r0]								;Initialize INDEX_INPUT_DS as 0
				LDR		r0,=INDEX_ERROR_LOG					;Load address of INDEX_ERROR_LOG
				STR		r1,[r0]								;Initialize INDEX_ERROR_LOG as 0
				LDR		r0,=PROGRAM_STATUS					;Load address of PROGRAM_STATUS
				STR		r1,[r0]								;Initialize PROGRAM_STATUS as 0
				BX		LR									;Return with LR
				
;//-------- <<< USER CODE END Initialize Global Variables >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************	

;@brief 	This function will be used to allocate the new cell 
;			from the memory using the allocation table.
;@return 	R0 <- The allocated area address
Malloc			FUNCTION			
;//-------- <<< USER CODE BEGIN System Tick Handler >>> ----------------------	
				PUSH	{r1,r2,r3,r4,r5}				;Push r1,r2,r3,r4,r5 registers to stack
				MOVS	r0,#0							;index for AT_MEM
				MOVS	r1,#2_1							;r1 = 1, binary
				LDR		r2,=AT_MEM						;r2 = allocation table,alloc
				MOVS	r5,#0							;n th bit in AT,index
				MOVS	r4,#0							;byte index
CHECKBIT		PUSH	{r0}							;push r0 to stack
				LSLS	r0,#2							;multiply r0 by 8
				LDR		r3,[r2,r0]						;load AT_MEM[i]
				POP		{r0}							;push r0 to stack
				CMP		r4,#8							;if byteIndex == 8
				BEQ		NEXTBYTE						;Branch to next byte
				ANDS	r3,r3,r1						;Bitwise and operation to find if the bit is 0 or 1
				CMP		r3,r1							;if r3 == binary, bit =1 
				BEQ		LSHIFT							;branch to Lshift to check if next bit is empty
				B 		BITEMPTY						;branch to BITEMPTY, we found the empty bit	
				
LSHIFT			LSLS	r1,#4							;left shift binary by 1
				ADDS	r4,r4,#1						;increase byte index by 1
				ADDS	r5,r5,#1						;increase index by 1
				B		CHECKBIT						;Go to CHECKBIT branch
				
NEXTBYTE		ADDS	r0,r0,#1						;increase r0 by 1
				LDR		r6,=NUMBER_OF_AT				;load number of AT value in r6
				CMP		r0,r6							;check if byte number<Number of at
				BEQ		LL_FULL							;if byte number > Number of AT, LL is full
				MOVS	r1,#1							;binary = 1
				MOVS	r4,#0							;byteindex = 0
				B		CHECKBIT						;Go to CHECKBIT branch
				
BITEMPTY 		PUSH 	{r0}							;push r0 to stack
				LSLS	r0,#2							;multiply r0 by 4
				LDR		r3,[r2,r0]						;load corresponding byte
				POP		{r0}							;get r0 back from stack
				ORRS	r3,r1							;bitwise or operation to make the 0 bit 1
				MOVS	r1,#4							;assign 4 to r1
				MULS	r0,r1,r0						;multiply byte index by 4 to get byte address
				STR		r3,[r2,r0]						;make 0 bit 1					
				MOVS	r4,#8							;Multiply index by 8 to get corresponding data slot, 2 words = 8 bits
				MULS	r4,r5,r4						;multiply index by 8
				LDR		r3,=DATA_MEM					;Load Data memory to r3
				ADDS	r0,r3,r4						;get the data address to return
				
				POP		{r1,r2,r3,r4,r5}				;Pop r1,r2,r3,r4,r5 registers from stack				
				B		MallocEnd						;Branch to MallocEnd line
				;BX 		LR									;Return with LR
				
LL_FULL			MOVS	r0,#0							;assign 0 to r0 since LL is full
				POP		{r1,r2,r3,r4,r5}				;Pop r1,r2,r3,r4,r5 registers from stack				
				B		MallocEnd						;Branch to MallocEnd line
				
				
;//-------- <<< USER CODE END System Tick Handler >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used for deallocate the existing area
;@param		R0 <- Address to deallocate
Free			FUNCTION			
;//-------- <<< USER CODE BEGIN Free Function >>> ----------------------
				LDR		r1,=DATA_MEM				;Load the start address of the data memory
				LDR		r0,=0x20002894
				SUBS	r0,r0,r1					;DATA_MEM start - Address to deallocate
				LSRS	r0,#3						;divide by 8 to get n th element, r0 = n th bit to delete
				MOVS	r2,#1						;assign binary 1 for clearing, 0x00000001
				MOVS	r3,#0						;use r3 as counter, initialize as 0
				MOVS	r4,#8						;assign r4 as 8 as byte control flag 
	
				LDR		r1,=AT_MEM					;Load start address of AT memory
				
FreeLoop		CMP		r3,r0						;check if counter= n th bit(bit to clear)
				BEQ		ClearBit					;if counter = n th bit, branch to clearBit
				ADDS	r3,r3,#1					;increase counter by 1
				LSLS	r2,r2,#4					;0x00000001 -> 0x00000010, left shift in base 2
				CMP		r3,r4						;check if counter = 8
				BEQ		FreeNextB					;if counter = 8 go to next byte in AT
				B		FreeLoop
				
				
FreeNextB		SUBS	r3,r4,r3					;Substract 8 from counter
				SUBS	r0,r4,r0					;Substract 8 from n th bit
				ADDS	r1,r1,#4					;Go to the next byte in AT
				MOVS	r2,#1						;assign binary 1 for clearing, 0x00000001
				B		FreeLoop
				

ClearBit		PUSH	{r1}						;push r1 value to stack
				LDR		r1,[r1]						;Load the value in AT address
				EORS	r2,r1						;XOR operation between bit clearer and AT byte
				POP		{r1}						;get r1 value back from stack
				STR		r2,[r1]						;store new AT byte in Allocation table
				
				BX		LR
				
;//-------- <<< USER CODE END Free Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to insert data to the linked list
;@param		R0 <- The data to insert
;@return    R0 <- Error Code
Insert			FUNCTION			
;//-------- <<< USER CODE BEGIN Insert Function >>> ----------------------			
				BEQ		continueI					;If the operation is insert branch to ContinueI
				BX 		LR							;else return with LR
				
continueI		MOVS	r1,r0						;load the data to insert to r1 register
				B		Malloc						;Get allocated area address in r0					
MallocEnd		CMP		r0,#0						;if Malloc return 0, the LL is full
				BEQ		LinkLFull					;if LL is full branch to LLFull error
				LDR		r2,=FIRST_ELEMENT			;load FIRST_ELEMENT address
				LDR		r3,[r2,#0]					;load the address in FIRST_ELEMENT
				STR		r1,[r0]						;store the data in the allocated address from malloc
				CMP		r3,#0						;check if FIRST_ELEMENT is empty/ Linked list is empty
				BEQ		FIRST_EL					;if LL is empty branch to inserting first element
				;if it is not first element continue
				MOVS	r4,r3						;Load element pointer in r4
				LDR		r4,[r3]						;Load element value
				CMP		r1,r4						;check if new data<LL element
				BEQ		EQUAL_ERROR					;data=LL element, write error
				BLO		ADD_TO_FRONT				;data<LL element add to front of LL element
				BHI		NEXT_EL						;data>LL element, compare with next LL element
			

ADD_TO_FRONT	STR		r0,[r2]						;store new data address in FIRST_ELEMENT
				ADDS	r0,r0,#4					;add 4 to r0 to get new pointer's address
				STR		r3,[r0]						;new pointer = FIRST_ELEMENT pointer 
				POP		{PC}						;Return
				
FIRST_EL		STR		r0,[r2]						;store new data address in FIRST_ELEMENT's value
				ADDS	r0,r0,#4					;add 4 to r0 to get pointer's address
				MOVS	r3,#0						;assign 0 to r2
				STR		r3,[r0]						;first element pointer = NULL
				LDR		r0,=NO_ERROR				;Return no error error code 
				BX		LR							;Return with LR
				
NEXT_EL			LDR		r3,[r2]						;Load elements address
				ADDS	r3,r3,#4					;get elements pointer
				MOVS	r4,r3						;copy element pointer in r4
				MOVS	r5,r4						;copy element pointer in r5
				LDR		r3,[r3]						;Load next element/Elements pointer value
ITERATE			CMP		r3,#0						;if next element = 0, add to tail
				BEQ		ADD_TO_TAIL					;branch to add to tail operation
				LDR		r3,[r3]						;load next element's value
				CMP		r1,r3						;check if newData < prevData
				BLO		ADD_BW						;if newData<prevData add between two elements
				MOVS	r5,r4						;use r4 to store the address in r4
				LDR		r4,[r4]						;load the value in r4 register
				MOVS	r3,r4						;copy value in r4 to r3
				ADDS	r4,r4,#4					;increase r4 to get next address
				B 		ITERATE						;Branch to ITERATE
	
ADD_BW			MOVS	r3,r5						;copy the address in r5 to r3
				PUSH	{r3}						;push r3 value to stack
				LDR		r3,[r3]						;laod the value in r3 register
				STR		r3,[r0,#4]					;store first elements pointer in third elements pointer
				POP		{r3}						;get r3 value back from stack
				STR		r0,[r3]						;store newData address in first elements pointer
				LDR		r0,=NO_ERROR				;Return no error error code 
				BX		LR							;return with lr
	
ADD_TO_TAIL		STR		r0,[r5]						;store new data's address in element's pointer
				MOVS	r3,#0						;assign 0 to r3
				STR		r3,[r0,#4]					;new data's pointer = NULL
				LDR		r0,=NO_ERROR				;Return no error error code 
				BX		LR							;return with LR
				
EQUAL_ERROR		LDR		r0,=DUPLICATE_DATA			;Return duplicate data error code 
				BX		LR							;return with lr
				
LinkLFull		LDR		r0,=NO_AREA					;Return no allocable area error code
				BX		LR							;return with LR
				
;//-------- <<< USER CODE END Insert Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to remove data from the linked list
;@param		R0 <- the data to delete
;@return    R0 <- Error Code
Remove			FUNCTION			
;//-------- <<< USER CODE BEGIN Remove Function >>> ----------------------															
				BEQ		continueR
				BX		LR
continueR		
				;LDR 	R2,=DATA_MEM	;load data memory start adress to r2
				LDR		R2,=FIRST_ELEMENT
				
				LDR		R4,=AT_MEM		;load AT memory start adress to r2
				MOVS	R3,#0			;i value use for iteration
				MOVS	R6,R3			;(j)it is used for iteration in byte(when r6=32 it turns 0 value)(it is for alloc table iteration)
				ADDS	R5,#1			;it is range value(number of 1 values in allocation table)
				
REMOVE_S		
				
				
				PUSH 	{R3}			
				;LSLS 	R3,#4			;multiply r3 by 8
				LDR		R2,[R2]
				LDR R3,[R2]				;load input data for every iteration
				CMP R2,#0				;it means that there is no any input like desired.
				BEQ ERROR1
				CMP	R0,R3				;if input==dataspace[i]
				BEQ	REMOVAL				
				POP {R3}
				ADDS R3,#1				;i++
				ADDS R6,#1				;j++
				ADDS R2,#4				;NEXT ELEMENT
				;LDR R2,[R2]
				;ADDS R4,#1
				;CMP R3,#2				;if j==32(out of 32 bit)
				;BEQ	UPBYTE
				B	REMOVE_S



				
REMOVAL			
				POP {R3}
				PUSH {R1,R2,R4}
				LDR R2,=DATA_MEM
				MOVS R4,#0
FINDIND			LDR  R2,[R2]
				CMP R2,R0
				BEQ CONT
				ADDS R2,#8
				ADDS R4,#1
				CMP R0,R6
				BEQ CONT
				CMP R4,#2
				BEQ UPBYTE
				B FINDIND
UPBYTE			ADDS R4,#1				;alloc table adress increases 1 byte
				MOVS R3,#0				;j value turns to 0
				B FINDIND

CONT			;free()
				MOVS R6,R4
				POP {R1,R2,R4}
				MOVS R1,#1
				;MOVS R4,#3
				;MULS R0,R4,R0
				LSLS R1,R6
				LDR R4,=AT_MEM
				LDR R2,[R4]
				SUBS R2,R1
				STR R2,[R4]
				;POP {R0,R1,R2}
				
				PUSH {R2}
				ADDS R2,#4
				LDR R2,[R2]
				CMP R2,#0
				BEQ DELLAST
				POP {R2}
				CMP R3,#0
				BEQ DELFIRST
				
				CMP R3,#0
				BEQ DELFIRST
				PUSH {R6}				
				MOVS R6,#0
				STR R6,[R2]				;input data turns to 0
				PUSH {R2}
				ADDS R2,#4
				STR R6,[R2]				;adress pointer of input data turns to 0
				POP {R2}
				POP {R6}
				PUSH {R3,R4}
				MOVS R3,R2
				MOVS R4,R2
				SUBS R3,#4
				ADDS R4,#8
				STR R4,[R3]
				POP {R3,R4}
				
				LDR R6,[R4]
				SUBS R6,R6,#1
				STR R6,[R4]
				;ADDS R6,#10
				;STR R6,[R4]
				
DELFIRST		PUSH {R1,R6}				
				LDR R1,=FIRST_ELEMENT
				MOVS R6,#0
				STR R6,[R2]				;input data turns to 0
				ADDS R2,#4
				PUSH {R2}
				LDR	 R2,[R2]
				STR	 R2,[R1]			;UPDATE FIRST_ELEMENT
				POP {R2}
				STR R6,[R2]				;adress pointer of input data turns to 0
				POP {R1,R6}
				;ADDS R6,#10
				;STR R6,[R4]
				
				;LDR R6,[R4]
				;SUBS R6,R6,#1
				;STR R6,[R4]
				;MOVS	R2,#2_00000001	;byte value which is used for delete alloc table to 1 value
				;PUSH 	{R6}			
				;MULS	R6,R2,R6		
				;LSLS	R2,R6			;byte value shifts until where is 1 bit value which is correspond to desired input
				;POP		{R6}
				;SUBS	R3,R2			;delete the 1 value
				;STR		R3,[R4]			;save last update
				BX		LR
ERROR1			POP {R3}			
				BX		LR

DELLAST			POP {R2}
				PUSH {R6}				
				MOVS R6,#0
				STR R6,[R2]				;input data turns to 0
				PUSH {R2}
				ADDS R2,#4
				STR R6,[R2]				;adress pointer of input data turns to 0
				POP {R2}
							
				;LDR R6,[R4]
				;SUBS R6,R6,#1
				;STR R6,[R4]
				POP {R6}
				BX		LR
;//-------- <<< USER CODE END Remove Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to clear the array and copy the linked list to the array
;@return	R0 <- Error Code
LinkedList2Arr	FUNCTION			
;//-------- <<< USER CODE BEGIN Linked List To Array >>> ----------------------															
				BEQ		continueL
				BX		LR
				
continueL		LDR r0, =FIRST_ELEMENT 				;r0 holds the first element in linked list
				LDR r2, =ARRAY_MEM					;r2 holds the starting address of array
				
				CMP r0, #0							;if first_element holds 0,
				BEQ error_5							;linked list is empty
				LDR r0, [r0]						;go to the first element
				
				MOVS r3, #0							;r3 will be used for indexing in the loop
				
				MOVS r6, #32						;r6 is 32
				MOVS r5, #NUMBER_OF_AT				;r5 will hold the array size 
				MULS r5, r6, r5						;r5 will hold the array size 
				MOVS r1, #0							;r1 = 0 clear value for array

body			MOVS r4, #4							;r4 = 4
				MULS r4, r3, r4  					;r4 *= r3
				STR r1, [r2, r4]					;clear the location at array_mem + 4*i
				ADDS r3, r3, #1						;r3 += 1 means i++
				
				CMP r3, r5							;if r3 < array_size 
				BCC body							;continue clearing
				
				MOVS r3, #0							;r3 will be used for indexing in the loop
				B compare							;while loop starting point
transform		LDR r1, [r0]						;take the value from current position of linkedlist
				MOVS r4, #4							;r4 = 4
				MULS r4, r3, r4  					;r4 *= r3
				STR r1, [r2, r4]					;store the value to array_mem+4*i
				LDR r0, [r0, #4]					;r0 becomes linked list's next element's address
				ADDS r3, r3, #1						;r3 += 1
				
compare			LDR r1, [r0, #4]					;look at the address area of linked list
				CMP r1, #0							;if it is not 0, it means we haven't finished linked list yet
				BNE transform						;then go transform
				LDR r1, [r0]						;take the value from current position of linkedlist (last element hasn't taken)
				MOVS r4, #4							;r4 = 4
				MULS r4, r3, r4  					;r4 *= r3
				STR r1, [r2, r4]					;store the value to array_mem+4*i
				
				MOVS r0, #0							;no error, so r0 = 0
				BX LR								;return from function
				
error_5			MOVS r0, #5							;error, so r0 = 5
				BX LR								;return from function


;//-------- <<< USER CODE END Linked List To Array >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to write errors to the error log array.
;@param		R0 -> Index of Input Dataset Array
;@param     R1 -> Error Code 
;@param     R2 -> Operation (Insertion / Deletion / LinkedList2Array)
;@param     R3 -> Data
WriteErrorLog	FUNCTION			
;//-------- <<< USER CODE BEGIN Write Error Log >>> ----------------------															
				
;//-------- <<< USER CODE END Write Error Log >>> ------------------------				
				ENDFUNC
				
;@brief 	This function will be used to get working time of the System Tick timer
;@return	R0 <- Working time of the System Tick Timer (in us).			
GetNow			FUNCTION			
;//-------- <<< USER CODE BEGIN Get Now >>> ----------------------															
				
;//-------- <<< USER CODE END Get Now >>> ------------------------
				ENDFUNC
				
;*******************************************************************************	

;//-------- <<< USER CODE BEGIN Functions >>> ----------------------															


;//-------- <<< USER CODE END Functions >>> ------------------------

;*******************************************************************************
;@endsection 		USER_FUNCTIONS
;*******************************************************************************
				ALIGN
				END		; Finish the assembly file
				
;*******************************************************************************
;@endfile 			main.s
;*******************************************************************************				

