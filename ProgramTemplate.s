;*******************************************************************************
;@file				 Main.s
;@project		     Microprocessor Systems Term Project
;@31/01/2021
;
;@PROJECT GROUP
;@Group no: 41
;@Muhammet Derviş Kopuz 504201531
;@Anıl Zeybek 			150190705
;@Mert Kaan Gül 		150190707
;@Doğu Can Elçi 		504201516
;@Ayberk Bozkuş 		150160067
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
				PUSH	{LR}							;Push LR to stack
				;increase tick count
				LDR		r0,=TICK_COUNT					;load tick count address
				LDR		r1,[r0]							;load tick count value to r1
				ADDS	r1,#1							;increase tick count by 1
				STR		r1,[r0]							;Store new tick count value
				
				;read input data
				LDR		r0,=IN_DATA						;Load address of input array
				LDR		r3,=INDEX_INPUT_DS				;load INDEX_INPUT_DS address
				LDR		r1,[r3]							;load INDEX_INPUT_DS value
				PUSH	{r1}							;SAVE INDEX
				PUSH	{r1}							;push INDEX_INPUT_DS value to stack
				LSLS	r1,#2							;Multiply index by 4 to get array index
				LDR		r0,[r0,r1]						;read the data from input dataset with the corresponding index
				LDR		r2,=IN_DATA_FLAG				;load address of input array
				LDR		r2,[r2,r1]						;Read data flag from data_flag array
				
				POP		{r1}							;pop INDEX_INPUT_DS value from stack
				PUSH	{r2}							;SAVE OPERATİON
				PUSH	{r0}							;SAVE DATA
				ADDS	r1,r1,#1						;increase INDEX_INPUT_DS value by one
				STR		r1,[r3]							;store new INDEX_INPUT_DS value
				CMP		r2,#INSERT						;check if operation = INSERT
				BL		Insert							;Branch with link to insert function
				CMP		r2,#REMOVE						;check if operation = REMOVE
				BL		Remove							;Branch with link to remove function
				CMP		r2,#TRANSFORM					;check if operation = TRANSFORM
				BL		LinkedList2Arr					;Branch with link to LinkedList2Arr function
				
				POP		{r3}							;READ DATA
				POP		{r2}							;READ OPERATİON
				MOV		r1,r0							;READ ERRORCODE
				POP 	{r0}							;READ INDEX
				push 	{r2}							;push r2 register to stack
				BL		WriteErrorLog					;branch with link to write error log function
				
				POP 	{r2}							 ;get r2 value back from stack
				CMP		r2,#TRANSFORM					;check if operation = TRANSFORM	
				BL		SysTick_Stop					;branch with link to sysTick stop function
				
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

				BEQ		ContinueTickStop				;If the operation is transform branch to ContinueTickStop
				BX 		LR								;else return with LR

ContinueTickStop
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
				B		FreeLoop					;branch to loop and continue searching
				

ClearBit		PUSH	{r1}						;push r1 value to stack
				LDR		r1,[r1]						;Load the value in AT address
				EORS	r2,r1						;XOR operation between bit clearer and AT byte
				POP		{r1}						;get r1 value back from stack
				STR		r2,[r1]						;store new AT byte in Allocation table
				
				BX		LR							;Return with LR
				
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
				STR		r3,[r0]						;new pointer = old FIRST_ELEMENT's address 
				LDR		r0,=NO_ERROR				;Return no error error code 
				BX		LR							;Return with LR
				
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
				BEQ		continueR			;If the operation is remove branch to ContinueR
				BX		LR					;else return with LR
continueR		
				LDR		R2,=FIRST_ELEMENT ;load the adress of first_element value in r2 register
				
				LDR		R4,=AT_MEM		;load AT memory start adress to r2
				MOVS	R3,#0			;i value use for iteration
				LDR		R5,[R2]			;if current input is the last element of the linkedlist, r5 register stores pointer adress of second last element to assign NULL							
				PUSH	{R2}			;push r3 to stack for later use
				LDR		R2,[R2]			;load the value in r2 address
				LDR		R2,[R2]			;load to first value of the linkedlist for testing if it is empty of not
				CMP 	R2,#0			;it means that there is no any element in the linkedlist
				BEQ		ERROR2			;branch to LL_EMPTY ERROR
				POP		{R2}			;get r2 value back from stack
REMOVE_S				
				PUSH 	{R3}			;push r3 to stack for later use
				LDR		R2,[R2]			;load to first element adress of linkedlist in r2
				LDR R3,[R2]				;load next input data from linked list
				CMP R2,#0				;it means that there is no any input like desired.
				BEQ ERROR1				;branch to NO_ELEMENT error
				
				CMP	R0,R3				;if input==linkedlist[i]
				BEQ	REMOVAL				;if equals branch to Removal
				POP {R3}				;get r3 value back from stack
				MOVS R5,R2				;R5 is used to store pointer adress of the second last element of the linkedlist
				ADDS R5,#4				;increase r5 register by 4 to get next byte
				ADDS R3,#1				;i++
				ADDS R2,#4				;NEXT ELEMENT
				B	REMOVE_S
				
REMOVAL			PUSH {R0,R1,R2,R3,R4,R5}	;push registers to stack because they will change
				PUSH {LR}					;push LR to stack
				MOVS R0,R2		;copy adress of current linkedlist element that is selected for removing , it is an argument for Free function.
				BL	Free		;branch to free function
				POP {R1}					;get r1 back from stack
				MOV LR,R1					;load r1 value in to LR	
				POP {R0,R1,R2,R3,R4,R5}		;get register values back from stack
				POP {R3}					;get r3 back from stack	
				PUSH {R2}					;push r2 register to stack for later use
				ADDS R2,#4		;pointer adress of the current input
				LDR R2,[R2]		;load to pointer adress of the last element of the linkedlist in r2
				CMP R2,#0		;if pointer adress of the last element equals to NULL,go to branch
				BEQ DELLAST		;branch to if current input is the last element of the linkedlist
				POP {R2}		;get r2 register back from stack
				CMP R3,#0		;if i=0 it means that current input is the first element of the linkedlist
				BEQ DELFIRST	;branch to if current input is the first element of the linkedlist
				
				CMP R3,#0		;check if it is equal to zero
				BEQ DELFIRST	;branch to if current input is the first element of the linkedlist				
				MOVS R6,#0		;assing 0 to r6 register
				STR R6,[R2]		;input data assign as 0 in data memory space
				PUSH {R2}		;push r2 register to stack
				ADDS R2,#4		;r2 stores pointer of current element
				PUSH {R1}		;get r1 value back from stack
				LDR R1,[R2]		;load to next element's adress in R1
				STR R6,[R2]		;pointer of the input data assign as 0 in data memory space
				POP {R2}		;get r2 value back from stack
				STR	R1,[R5]		;connection of pointer of previous element and next element.
				POP {R1}		;get r1 value back from stack					
				LDR R0,=NO_ERROR		;move to NO_ERROR VALUE in R0
				BX		LR		;return with LR
				
DELFIRST		PUSH {R1,R6}			;push r1 and r6 to stack for later use	
				LDR R1,=FIRST_ELEMENT	;load the address of the first element
				MOVS R6,#0				;assign 0 to r6 register
				STR R6,[R2]				;input data turns to 0
				ADDS R2,#4				;R2 stores the next element adress of the linkedlist (next element is current head node)
				PUSH {R2}				;push r2 value to stack
				LDR	 R2,[R2]			;load to adress of the first element of the linkedlist in R2
				STR	 R2,[R1]			;UPDATE FIRST_ELEMENT(change the head node of the linkedlist)
				POP {R2}				;get r2 value back from stack
				STR R6,[R2]				;adress pointer of input data turns to 0
				POP {R1,R6}				;get r1 and r6 registers back from stack
				LDR R0,=NO_ERROR		;move to NO_ERROR VALUE in R0
				BX		LR				;return with LR

ERROR1			LDR R0,=NO_ELEMENT		;load return register with NO_ELEMENT error code
				POP {R3}				;get r3 value back from stack
				BX		LR				;return with LR

DELLAST			POP {R2}				;get r2 value back from stack
				MOVS R6,#0				;Move 0 value in R6
				STR R6,[R2]				;current element assign as 0
				PUSH {R2}				;push r2 value to stack for later use
				ADDS R2,#4				;R2 stores pointer of current element
				STR R6,[R2]				;pointer of current element turns to 0
				POP {R2}				;get r2 value back from stack
				MOVS R3,#0				;assign 0 to r3 register
				STR R3,[R5]				;store the 0 in its new address
				LDR R0,=NO_ERROR		;move to NO_ERROR VALUE in R0
				BX		LR				;return with LR

ERROR2			LDR R0,=LL_EMPTY		;load to LL_EMPTY VALUE in R0
				POP {R2}				;get r2 register back from stack
				BX		LR				;return with LR
;//-------- <<< USER CODE END Remove Function >>> ------------------------				
				ENDFUNC
				
;*******************************************************************************				

;@brief 	This function will be used to clear the array and copy the linked list to the array
;@return	R0 <- Error Code
LinkedList2Arr	FUNCTION			
;//-------- <<< USER CODE BEGIN Linked List To Array >>> ----------------------															
				BEQ		continueL					;if operation = LinkedList2Arr branch to ContinueL
				BX		LR							;else return with lr
				
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
				LDR		r4,=LOG_MEM							;Load log memory address
				LDR		r5,=INDEX_ERROR_LOG					;Load address of INDEX_ERROR_LOG
				LDR		r5,[r5]								;Load value of INDEX_ERROR_LOG
	
				LSLS	r0,r0,#8							;Left shift r0 by 1 byte
				ORRS	r0, r1,r0							;Bitwise or r0 and r1 so we can store them into 1 cell
				LSLS	r0,r0,#8							;Left shift r0 by 1 byte
				ORRS	r0, r2,r0							;Bitwise or r0 and r2 so we can store them into 1 cell
				
				STR		r0,[r4,r5]							;Store @param0,@param1,@param2 to Err_log cell 1
				ADDS	r5,r5,#4							;increase index by 1
				STR		r3,[r4,r5]							;Store @param3 to Err_log
				ADDS	r5,r5,#4							;increase index by 1	
				PUSH 	{LR} 								;Save LR content to stack
				BL 		GetNow								;Call GetNow() to store timestamp in r6
				STR		r0,[r4,r5]							;Store @param4 to Err_log
				ADDS	r5,r5,#4							;increase index
				
				LDR		r7,=INDEX_ERROR_LOG					;Load address of INDEX_ERROR_LOG
				STR		r5,[r7]								;Store new index value to INDEX_ERROR_LOG
				POP 	{PC}								;Use stacked LR content to return to functionA
;//-------- <<< USER CODE END Write Error Log >>> ------------------------				
				ENDFUNC
				
;@brief 	This function will be used to get working time of the System Tick timer
;@return	R0 <- Working time of the System Tick Timer (in us).			
GetNow			FUNCTION			
;//-------- <<< USER CODE BEGIN Get Now >>> ----------------------															
				LDR		r2,=0xE000E014					;Load SystickReloadValue address	
				LDR		r2,[r2]							;Load SystickReload to r2
				LDR		r1,=TICK_COUNT					;Load tick count address
				LDR		r1,[r1]							;Load tick count value to r1
				LDR		r3,=0xE000E018					;Load SystickCurrentValue address
				LDR		r3,[r3]							;Load SystickCurrentValue to r3
				MULS	r1,r3,r1						;Multiply r3 with r1 and store to r1; r1 = r3 * r1
				adds	r0,r2,r1						;Add r1 with r2 and store to r0; r0 = r1 + r2

				BX 		LR								; Use stacked LR content to return	
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
