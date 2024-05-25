.data

    input:  .space 4  # Reserve 4 bytes to store the input integer
    parity_mask_1: .word  0x55555554 
    parity_mask_2: .word  0x66666664 
    parity_mask_3: .word  0x78787870
    parity_mask_4: .word  0x7F807F00
    parity_mask_5: .word  0x7FFF0000
    title: .asciiz "** Controle Periodique **\n"
    message_1: .asciiz "veuillez entrez votre matricule: "
    message_2: .asciiz "veuillez entrez le nombre de rotation: "
    message_3: .asciiz "message a envoyer: "
    message_4: .asciiz "message mappe: "
    message_5: .asciiz "donne a envoyer: "
    SEPARATOR: .asciiz "\n#########################################\n"
    message_6: .asciiz "veuillez entrez les donnees recues: "
    message_7: .asciiz "Donnees corriges: "
    message_8: .asciiz "donnees envoyees de l'origine: "

    

.text

main:
    #print the title
    la a0,title
    jal print_string

    #print the message for the user
    la a0,message_1
    jal print_string

    #take the matricule input from the user
    jal input_from_terminal
    addi t0,a0,0

    #print the message for the user
    la a0,message_2
    jal print_string

    #take the number of rotation (use 7 to get the same result shown the figure)
    jal input_from_terminal
    addi t1,a0,0

    #print the message for the user
    la a0,message_3
    jal print_string

    #run the get_message_asm function
    addi a0,t0,0
    addi a1,t1,0
    jal get_message_asm
    addi t0,a0,0
    jal print_hexa


    jal print_new_line


    #print the message for the user
    la a0,message_4
    jal print_string


    #run the hamming_map_asm function
    addi a0,t0,0
    jal hamming_map_asm
    addi t0,a0,0
    jal print_hexa


    jal print_new_line


    #print the message for the user
    la a0,message_5
    jal print_string


    #run the hamming_encode function
    addi a0,t0,0
    jal hamming_encode
    addi t0,a0,0    
    jal print_hexa


    #print a separator for the second phase of the programm
    la a0,SEPARATOR
    jal print_string


    #print the message for the user
    la a0,message_6
    jal print_string

    #take the input from the user of the received data
    jal input_from_terminal
    addi t0,a0,0

    #print the message for the user
    la a0,message_7
    jal print_string


    #run the hamming_decode function
    addi a0,t0,0
    jal hamming_decode
    addi t0,a0,0
    jal print_hexa



    jal print_new_line


    #print the message for the user
    la a0,message_8
    jal print_string
    


    #run the hamming_unmap_asm function
    addi a0,t0,0
    jal hamming_unmap_asm
    addi t0,a0,0
    jal print_hexa



    jal print_new_line


    j EXIT


#
hamming_unmap_asm:

    addi sp,sp,-24
    sw t0,0(sp)
    sw t1,4(sp)
    sw t2,8(sp)
    sw t3,12(sp)
    sw t4,16(sp)
    sw t5,20(sp)

    # Arguments: a0 = 24-bit message
    # Result: a0 = 32-bit mapped integer with parity bits set to 0

    li t0, 0x0         # Initialize map to 0

    # Mapping each bit of msg to the appropriate position in map
    addi t1,x0,28

    addi t3 ,x0,3
    addi t4,x0,7
    addi t5,x0,15
    
    LOOP_UNMAP:

        addi t2 ,x0,1
        beq t1,t2,END_LOOP_UNMAP

        beq t1,t3,SKIP_BIT_UNMAP
        beq t1,t4,SKIP_BIT_UNMAP
        beq t1,t5,SKIP_BIT_UNMAP

        
        addi t2,x0,1
        sll t2,t2,t1
        and t2,a0,t2
        srl t2,t2,t1


        slli t0,t0,1
        or t0,t0,t2



        SKIP_BIT_UNMAP:


        addi t1,t1,-1
        j LOOP_UNMAP


    END_LOOP_UNMAP:


    addi a0, t0 ,0      # Return the result in a0


    lw t5,20(sp)
    lw t4,16(sp)
    lw t3,12(sp)
    lw t2,8(sp)
    lw t1,4(sp)
    lw t0,0(sp)
    addi sp,sp,24


    jr ra




#
hamming_decode:
    #stack storage

    addi sp,sp,-16
    sw t0,0(sp)
    sw t1,4(sp)
    sw t2,8(sp)
    sw ra,12(sp)



    # Arguments: a0 = mapped integer
    # Result: a0 = encoded integer with parity bits

    addi t0, a0,0      # Copy map to t0
    addi t1,x0,0       # Initialize code to 0

    # Calculate parity and set the corresponding bits in code
    
    lw t2,parity_mask_1
    ori t2,t2,0b1
    and t2, t0, t2
    addi a0,t2,0
    jal parity
    or t1, t1, a0

    lw t2,parity_mask_2
    ori t2,t2,0b10
    and t2, t0,t2
    addi a0,t2,0
    jal parity
    slli a0, a0, 1
    or t1, t1, a0

    lw t2,parity_mask_3
    ori t2,t2,0b1000
    and t2, t0,t2
    addi a0,t2,0
    jal parity
    slli a0, a0, 2
    or t1, t1, a0

    lw t2,parity_mask_4
    ori t2,t2,0b10000000
    and t2, t0,t2
    addi a0,t2,0
    jal parity
    slli a0, a0, 3
    or t1, t1, a0

    lw t2,parity_mask_5
    addi a0,x0,1
    slli a0,a0,15
    or t2,t2,a0
    and t2, t0,t2
    addi a0,t2,0
    jal parity
    slli a0, a0, 4
    or t1, t1, a0

    addi a0, t0 ,0     # Return the result in a0

    beq t1 ,x0,no_error

    addi t0,x0,1
    addi t1,t1,-1
    sll t0,t0,t1
    xor a0,a0,t0



    no_error:


        lw ra,12(sp)
        lw t2,8(sp)
        lw t1,4(sp)
        lw t0,0(sp)
        addi sp,sp,16

        jr ra




#
hamming_encode:
    #stack storage

    addi sp,sp,-16
    sw t0,0(sp)
    sw t1,4(sp)
    sw t2,8(sp)
    sw ra,12(sp)



     # Arguments: a0 = mapped integer
    # Result: a0 = encoded integer with parity bits

    addi t0, a0,0      # Copy map to t0
    addi t1,a0,0       # Initialize code to map

    # Calculate parity and set the corresponding bits in code
    
    lw t2,parity_mask_1
    and t2, t0, t2
    addi a0,t2,0
    jal parity
    or t1, t1, a0

    lw t2,parity_mask_2
    and t2, t0,t2
    addi a0,t2,0
    jal parity
    slli a0, a0, 1
    or t1, t1, a0

    lw t2,parity_mask_3
    and t2, t0,t2
    addi a0,t2,0
    jal parity
    slli a0, a0, 3
    or t1, t1, a0

    lw t2,parity_mask_4
    and t2, t0,t2
    addi a0,t2,0
    jal parity
    slli a0, a0, 7
    or t1, t1, a0

    lw t2,parity_mask_5
    and t2, t0,t2
    addi a0,t2,0
    jal parity
    slli a0, a0, 15
    or t1, t1, a0

    addi a0, t1 ,0     # Return the result in a0

    lw ra,12(sp)
    lw t2,8(sp)
    lw t1,4(sp)
    lw t0,0(sp)
    addi sp,sp,16

    jr ra




#
parity:
    # Calculate the parity of a0
    addi sp,sp,-8
    sw t0,0(sp)
    sw t1,4(sp)


    addi t0, x0,0           #initiate the counter with 0
    parity_loop:

        beq a0, x0, parity_end
        andi t1, a0, 1
        add t0, t0, t1
        srli a0, a0, 1
        j parity_loop

    parity_end:
        andi a0, t0, 1   #paity of the counter

        lw t1,4(sp)
        lw t0,0(sp)
        addi sp,sp,8


        jr ra
        


#
hamming_map_asm:

    addi sp,sp,-24
    sw t0,0(sp)
    sw t1,4(sp)
    sw t2,8(sp)
    sw t3,12(sp)
    sw t4,16(sp)
    sw t5,20(sp)

    # Arguments: a0 = 24-bit message
    # Result: a0 = 32-bit mapped integer with parity bits set to 0

    li t0, 0x0         # Initialize map to 0

    # Mapping each bit of msg to the appropriate position in map
    addi t1,x0,2

    addi t3 ,x0,3
    addi t4,x0,7
    addi t5,x0,15
    
    LOOP_MAP:
        addi t2 ,x0,29
        beq t1,t2,END_LOOP_MAP

        beq t1,t3,SKIP_BIT_MAP
        beq t1,t4,SKIP_BIT_MAP
        beq t1,t5,SKIP_BIT_MAP

        
        andi t2,a0,1
        sll t2,t2,t1
        or t0,t0,t2
        srli a0,a0,1

    


        SKIP_BIT_MAP:


        addi t1,t1,1
        j LOOP_MAP


    END_LOOP_MAP:


    addi a0, t0 ,0      # Return the result in a0


    lw t5,20(sp)
    lw t4,16(sp)
    lw t3,12(sp)
    lw t2,8(sp)
    lw t1,4(sp)
    lw t0,0(sp)
    addi sp,sp,24


    jr ra


#
get_message_asm:

    #store_stack:

        addi sp,sp,-8
        sw t0,0(sp)
        sw t1,4(sp)


    # Arguments: a0 = matricule, a1 = r
    # Result: a0 = message

    # Invert all bits of matricule
    not a0, a0

    # Perform left rotation by r positions
    sll t0, a0, a1         # t0 = a0 << a1
    sub t1, x0, a1          # t1 = 32 - a1
    srl t1, a0, t1         # t1 = a0 >> (32 - a1)
    or a0, t0, t1           # a0 = (a0 << a1) | (a0 >> (32 - a1))

    # Keep only the least significant 24 bits
    li t0, 0xFFFFFF         # t0 = 0xFFFFFF
    and a0, a0, t0          # a0 = a0 & 0xFFFFFF

    # Return the result in a0
    #empty_stack:
        lw t1,4(sp)
        lw t0,0(sp)
        addi sp,sp,8


    jr ra








#
input_from_terminal:


        store_stack:

            addi sp,sp,-24
            sw a1,0(sp)
            sw t1,4(sp)
            sw t2,8(sp)
            sw t3,12(sp)
            sw t4,16(sp)
            sw t0,20(sp)

        start:
            # Activate terminal input
            addi a0, x0, 0x130
            ecall

            # Initialize input variables
            la t0, input   # Load address of input into t0
            li t1, 0       # Initialize t1 to store the integer value
            addi t2,x0,10

        read_input:
            # Poll for console input
            addi a0, x0, 0x131
            ecall


            addi t4,x0,1

            # Check input status
            beq a0, x0, input_done  # If a0 == 0, all input has been read
            beq a0, t4, read_input  # If a0 == 1, still waiting for input

            # a0 == 2, valid input character read
            # a1 contains the character in UTF-16

            # Convert character to integer if it's a digit
            addi t3, a1, -48  # Convert ASCII to integer by subtracting '0' (48 in ASCII)


            addi t4,x0,72
            bne t3,t4,not_hex
                addi t2,x0,16
                addi t3,x0,0
            not_hex:
            
            
            



            blt t3, x0, read_input   # If character is less than '0', read next input

            addi t4,x0,17      # A
            bne t3,t4,not_A
                addi t3,x0,10
                j ready
            not_A:

             addi t4,x0,18      # B
            bne t3,t4,not_B
                addi t3,x0,11
                j ready
            not_B:

             addi t4,x0,19      # C
            bne t3,t4,not_C
                addi t3,x0,12
                j ready
            not_C:

             addi t4,x0,20      # D
            bne t3,t4,not_D
                addi t3,x0,13
                j ready
            not_D:

             addi t4,x0,21      # E
            bne t3,t4,not_E
                addi t3,x0,14
                j ready
            not_E:

             addi t4,x0,22      # F
            bne t3,t4,not_F
                addi t3,x0,15
                j ready
            not_F:



            addi t4,x0,10
            bge t3, t4, read_input   # If character is greater than '9', read next input




            ready:

            # Accumulate the integer value
            add t4,x0,t2
            mul t1, t1, t4   # Multiply current value by 10 or 16 in case of hex
            add t1, t1, t3   # Add the new digit

            j read_input     # Continue reading input

        input_done:


            # return the integer value
            addi a0,t1,0
            sw x0,0(t0)


            empty_stack:

                lw t0,20(sp)
                lw t4,16(sp)
                lw t3,12(sp)
                lw t1,4(sp)
                lw t2,8(sp)
                lw a1,0(sp)
                addi sp,sp,24


            jr ra
                 
#
print_int:
    addi sp,sp,-4
    sw a1,0(sp)

    addi a1,a0,0
    addi a0,x0,1
    ecall

    lw a1,0(sp)
    addi sp,sp,4
    jr ra

#
print_hexa:
    addi sp,sp,-4
    sw a1,0(sp)

    addi a1,a0,0
    addi a0,x0,34
    ecall

    lw a1,0(sp)
    addi sp,sp,4


    jr ra

#
print_space:
    addi sp,sp,-4
    sw a1,0(sp)

    addi a1,x0,32
    addi a0,x0,11
    ecall

    lw a1,0(sp)
    addi sp,sp,4

    jr ra

#
print_new_line:
    addi sp,sp,-4
    sw a1,0(sp)

    addi a1,x0,10
    addi a0,x0,11
    ecall

    lw a1,0(sp)
    addi sp,sp,4
   

    jr ra

#
print_string:
    addi sp,sp,-4
    sw a1,0(sp)

    addi a1,a0,0
    addi a0,x0,4
    ecall

    lw a1,0(sp)
    addi sp,sp,4

    jr ra

#

EXIT: