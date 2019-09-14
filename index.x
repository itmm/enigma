# Enigma Implementation for RISC-V
* emulate Enigma over terminal

```
@Def(file: enigma.ll)
	@put(globals)
@End(file: enigma.ll)
```
* one source file

```
@def(globals)
	%t0 <- %pc + 28 # _dummy_irq
@end(globals)
```
* set interrupt vector

```
@add(globals)
		%mtvec <- %t0
		%t0 <- %mhartid
	loop_hart:
		if %t0 != 0: goto loop_hart
@end(globals)
```
* don't continue if not running on first hart

```
@add(globals)
	%sp <- $80004000
@end(globals)
```

```
@add(globals)
	%pc <- %pc + 36 # setup
@end(globals)
```
* jump over data

```
@add(globals)
	_dummy_irq:
		goto _dummy_irq
@end(globals)
```
* interrupt blocks forever

```
@add(globals)
	welcome_msg:
		raw $636c6557
		raw $20656d6f
		raw $45206f74
		raw $4d47494e
		raw $00000041
@end(globals)
```
* welcome message on startup

```
@add(globals)
	prompt_msg:
		raw $203e0a0d
		raw 0
@end(globals)
```
* prompt on new line

```
@add(globals)
	setup:
		%s0 => uart <- $10013000
		%t0 <- [uart + $08]
		%t1 <- [uart + $0c]
		%t0 <- %t0 or $01
		%t1 <- %t1 or $01
		[uart + $08] <- %t0
		[uart + $0c] <- %t1
		uart_rd <== uart + $04
		uart_wr <== uart + $00
@end(globals)
```
* init UART

```
@add(globals)
		%pc <- %pc + 36 # after writer_str
	write_str:
		%t0 <-b [%a1]
		if %t0 = 0: %pc <- %pc + 24 # write_str_end
		%a1 <- %a1 + 1
	write_str_ready:
		%t1 <- [%a0]
		if %t1 < 0: goto write_str_ready
		[%a0] <- %t0
		goto write_str
	write_str_end:
		%pc <- %ra
@end(globals)
```

```
@add(globals)
		%a0 <- uart
		%a1 <- %pc + (welcome_msg - *)
		%ra <- %pc, goto write_str
@end(globals)
```

```
@add(globals)
	prompt:
		%a0 <- uart
		%a1 <- %pc + (prompt_msg - *)
		%ra <- %pc, goto write_str
@end(globals)
```

```
@add(globals)
		%t3 <- 4
	read:
		%t0 <- [uart_rd]
		if %t0 < 0: goto read
		%t0 <- %t0 and $ff
		%t1 <- $0d
		if %t0 = %t1: goto prompt
		%t1 <- %t0 - $41
		if %t1 < 0: goto read
		%t2 <- 25
		if %t1 > %t2: goto read
		if %t3 = 0: %pc <- %pc + 12 # write_pad
		%t3 <- %t3 - 1
		%pc <- %pc + 24 # after_pad
	write_pad:
		%t1 <- [uart_wr]
		if %t1 < 0: goto write_pad
		%t1 <- $20
		[uart_wr] <- %t1
		%t3 <- 4
	after_pad:

		%t0 <- %t0 + 13
		%t1 <- $5a
		if %t0 <= %t1: %pc <- %pc + 8 # no_correction
		%t0 <- %t0 - 26
	no_correction:

	can_write:
		%t1 <- [uart_wr]
		if %t1 < 0: goto can_write
		[uart_wr] <- %t0
		goto read
@end(globals)
```

