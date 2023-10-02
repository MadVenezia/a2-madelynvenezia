# Usage: ./calculator <op> <arg1> <arg2>
#

# Make `main` accessible outside of this module
.global main

# Start of the code section
.text

# int main(int argc, char argv[][])
main:
  # Function prologue
  enter $0, $0

  # Variable mappings:
  # op -> %r12
  # arg1 -> %r13
  # arg2 -> %r14
  movq 8(%rsi), %r12  # op = argv[1]

  # Convert 1st operand to long int
  movq 16(%rsi), %rdi  # Pass the address of the 1st operand to str_to_long
  call str_to_long
  movq %rax, %r13  # Store the converted long int in arg1

  # Convert 2nd operand to long int
  movq 24(%rsi), %rdi  # Pass the address of the 2nd operand to str_to_long
  call str_to_long
  movq %rax, %r14  # Store the converted long int in arg2

  # Copy the first char of op into an 8-bit register
  movb (%r12), %al

  # Check the operation and perform the corresponding calculation
  cmpb $'+', %al
  je addition
  cmpb $'-', %al
  je subtraction
  cmpb $'*', %al
  je multiplication
  cmpb $'/', %al
  je division

  # Invalid operation
  mov $unknown_op_msg, %rdi
  call printf
  jmp end_program

addition:
  # Add the two operands
  addq %r14, %r13
  jmp print_result

subtraction:
  # Subtract the second operand from the first operand
  subq %r14, %r13
  jmp print_result

multiplication:
  # Multiply the two operands
  imulq %r14, %r13
  jmp print_result

division:
  # Check for division by zero
  testq %r14, %r14
  jz division_by_zero

  # Move the numerator into eax and sign-extend it into edx:eax
  movq %r13, %rax
  cqto

  # Divide edx:eax by the denominator (%r14)
  idivq %r14
  jmp print_result

division_by_zero:
  # Print division by zero error message
  mov $division_by_zero_msg, %rdi
  call printf
  jmp end_program

print_result:
  # Print the result
  mov $format, %rdi
  movq %r13, %rsi  # Move the result to rsi for printing
  call printf
  jmp end_program

unknown_op_msg:
  .asciz "Unknown operation\n"

division_by_zero_msg:
  .asciz "Division by zero\n"

end_program:
  # Function epilogue
  leave
  ret

# Function to convert a string to a long integer
str_to_long:
  xor %rax, %rax  # Clear the result register
  xor %rcx, %rcx  # Clear the character counter
  mov $10, %rbx   # Set the base to 10

convert_loop:
  movzbq (%rdi, %rcx), %rdx  # Load the next character into rdx (zero-extend)
  test %rdx, %rdx            # Test for null terminator
  jz end_convert

  # Convert ASCII character to numeric value
  sub $'0', %rdx  # Subtract the ASCII value of '0'

  imulq %rax, %rbx  # Multiply the current result by the base
  addq %rdx, %rax   # Add the new digit to the result
  inc %rcx          # Move to the next character
  jmp convert_loop

end_convert:
  ret

# Start of the data section
.data

format: 
  .asciz "%ld\n"
