	@@ 单片机PY32F002AF15P6TU
	@定时器
	@时间：2023-04-16
	@编译器：ARM-NONE-EABI
	.thumb
	.syntax unified
	.section .text

vectors:	
	.word STACKINIT
	.word _start + 1
	.word _nmi_handler + 1
	.word _hard_fault  + 1
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	.word _svc_handler +1
	.word 0
	.word 0
	.word _pendsv_handler +1
	.word _systickzhongduan +1           @ 15
	.word aaa +1     @ _wwdg +1          @ 0
	.word aaa +1     @_pvd +1            @ 1
	.word aaa +1     @_rtc +1            @ 2
	.word aaa +1     @_flash +1          @ 3
	.word aaa +1    @ _rcc + 1           @ 4
	.word aaa +1      @_exti0_1  +1      @ 5
	.word aaa +1      @ _exti2_3 +1      @ 6
	.word aaa +1       @_exti4_15 +1     @ 7
	.word aaa +1                         @ 8
	.word aaa +1    @__dma_wan  +1       @ 9
	.word aaa +1    @_dma1_2_3 +1        @ 10
	.word aaa +1       @_dma1_4_5 +1     @ 11
	.word aaa +1     @_adc1 +1           @ 12
	.word aaa +1       @_tim1_brk_up +1  @ 13
	.word aaa +1        @ _tim1_cc +1    @ 14
	.word aaa +1         @_tim2 +1       @ 15
	.word aaa +1          @_tim3 +1      @ 16
	.word aaa +1     @LPTIM1               @ 17
	.word aaa +1                         @ 18
	.word aaa +1    @_tim14 +1           @ 19
	.word aaa +1                         @ 20
	.word aaa +1         @_tim16 +1      @ 21
	.word aaa +1         @_tim17 +1      @ 22
	.word aaa +1          @_i2c   +1     @ 23
	.word aaa +1                         @ 24
	.word aaa +1           @_spi1  +1    @ 25
	.word aaa +1           @_spi2  +1    @ 26
	.word aaa +1         @_usart1 +1     @ 27
	.word aaa +1	@_usart2 +1	     @ 28
	.word aaa +1				@29
	.word aaa +1	@led			@30
	.word aaa +1				@31

_start:
@	bkpt # 1
shizhong:
	ldr r2, = 0x40022000   @FLASH访问控制
	movs r1, # 1
	str r1, [r2]          @0:flash没等待，1:flash等待
	ldr r0, = 0x40021000 @ rcc
	ldr r1, = 0x20008
	str r1, [r0, # 0x10]	@外部晶振选择
	ldr r1, [r0]
	ldr r2, = 0x10000
	orrs r1, r1, r2
	str r1, [r0]		@开外部振荡器
denghse:
	ldr r1, [r0]
	lsls r1, r1, # 14
	bpl denghse		@等外部振荡器
	
	ldr r1, = 0x01
	str r1, [r0, # 0x0c]	@PLL配置
	ldr r2, [r0]
	ldr r1, = 0x1000000
	orrs r1, r1, r2
	str r1, [r0]		@开PLL

dengpll:
	ldr r1, [r0]
	lsls r1, # 6
	bpl dengpll		@等PLL
	movs r1, # 0x02
	str r1, [r0, # 0x08]	@选择系统时钟
	
_neicunqingling:
	ldr r0, = 0x20001000
	ldr r2, = 0x20000000
	movs r1, # 0
_neicunqinglingxunhuan:
	subs r0, r0, # 4
	str r1, [r0]
	cmp r0, r2
	bne _neicunqinglingxunhuan
	
__wai_she_shi_zhong:
	@0x34
	@0=PA、1=PB、5=PF
	ldr r0, = 0x40021000
	movs r1, # 0x23
	str r1, [r0, # 0x34]	@IO时钟
	
	@0X38 复位值0x300
	@0=DMA，8=FLASH，12=CRC
	ldr r1, = 0x301
	str r1, [r0, # 0x38]

	@0X3C
	@1=TIM3,10=RTC，11=WWDG，14=SPI2,17=USART2,21=I2C，28=PWR，31=LPTIM
	movs r1, # 0x02
	str r1, [r0, # 0x3c]
	@0X40
	@0SYSCFG，11=TIM1,12=SPI1,14=USART1,15=TIM14,17=TIM16,18=TIM17,20=ADC
	@21=COMP1,22=COMP2,23=LED
	ldr r1, = 0x101801
	str r1, [r0, # 0x40]   
	str r1, [r0, # 0x30]
	movs r1, # 0
	str r1, [r0, # 0x30]
		
__io_she_zhi:
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@	
	@pa=0x50000000,pb=0x50000400,pf=0x50001400
	@0xebffffff	0xffffffff	0xfffffcff
	@00=输入，01=通用输出，10=复用，11=模拟
	@0x04, 0=推挽，1=开漏
	@0x08, 00=非常低，01=低速，10=高速，11=非常高
	@PA=0X0C000000
	@0x0c, 00=无上拉下拉，01=上拉，10=下拉
	@PA=0X24000000,PB=0，PF=0X200
	@0x10=输入数据寄存器
	@0x14=输出数据寄存器
	@0X18，0-15 IO开，16-31 IO关
	@0X28, 0-15 IO关
	@0x20=复用功能低
	@0x24=复用功能高
	@0=AF0, 1=AF1，2=AF2，3=AF3，4=AF4, 5=AF5, 6=AF6, 7=AF7
	@8=AF8, 9=AF9, A=AF10,B=AF11,C=AF12,D=AF13,E=AF14,F=AF15
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	ldr r0, = 0x50000000
	ldr r1, = 0x2800890f
	str r1, [r0]
	movs r1, # 0x0c
	str r1, [r0, # 0x04]
	ldr r1, = 0x0c000050
	str r1, [r0, # 0x0c]
	ldr r1, = 0x0c000000
	str r1, [r0, # 0x08]
	ldr r0, = 0x50000400
	ldr r1, = 0xffffffbd
	str r1, [r0]
	movs r1, # 0xc0
	str r1, [r0, # 0x08]
	ldr r1, = 0x1000
	str r1, [r0, # 0x20]


@	movs r1, # 0x01
@	str r1, [r0, # 0x018]
	

spi_chushihua:
	ldr r0, = 0x40013000
	ldr r1, = 0xf00
	str r1, [r0, # 0x04]
	ldr r1, = 0xc07c
	str r1, [r0]

__adc_dma:
	ldr r0, = 0x40020000
	ldr r1, = 0x40012440    @外设地址
	str r1, [r0, # 0x10]
	ldr r1, = 0x20000160    @储存器地址
	str r1, [r0, # 0x14]
	ldr r1, = 1000          @传输数量
	str r1, [r0, # 0x0c]
	ldr r1, = 0x35a1 @  0x583        @ 5a1  @传输模式
	str r1, [r0, # 0x08]

_adcchushihua:
	ldr r0, = 0x40012400  @ adc基地址
	ldr r1, = 0x80000000
	str r1, [r0, # 0x08]  @ ADC 控制寄存器 (ADC_CR)  @adc校准
_dengadcjiaozhun:
	ldr r1, [r0, # 0x08]
	movs r1, r1
	bmi _dengadcjiaozhun   @ 等ADC校准
_tongdaoxuanze:
	ldr r1, = 0x20000000
	str r1, [r0, # 0x10]    @时钟分频
	movs r1, # 0x03
	str r1, [r0, # 0x28]    @ 通道选择寄存器 (ADC_CHSELR)
	ldr r1, = 0x8c3         @0x3003         @连续0x2003 @触发0x8c3 @ 0xc43         @TIM3 0x8c3 @0x2003 @0x8c3
	str r1, [r0, # 0x0c]    @ 配置寄存器 1 (ADC_CFGR1)
	movs r1, # 0
	str r1, [r0, # 0x14]    @ ADC 采样时间寄存器 (ADC_SMPR)
	ldr r1, = 0x05         @ 开始转换
	str r1, [r0, # 0x08]    @ 控制寄存器 (ADC_CR)
	str r1, [r0, # 0x08]
	
	@__tim1_dma:
	@       ldr r0, = 0x40010000
	@       ldr r1, = 0x1000
	@       str r1, [r0, # 0x1c]
	@
	@       ldr r0, = 0x40020000
	@       ldr r1, = 0x40012c38    @外设地址
	@       str r1, [r0, # 0x24]
	@       ldr r1, =  zheng_xian_1khz @ 储存器地址
	@       str r1, [r0, # 0x28]
	@       ldr r1, = 200           @传输数量
	@       str r1, [r0, # 0x20]
	@       ldr r1, = 0x31b1        @传输模式
	@       str r1, [r0, # 0x1c]
	@
	@tim3chushihua:
	ldr r3, = 0x40000400 @ tim3_cr1
	ldr r2, = 0
	str r2, [r3, # 0x28] @ psc
	ldr r2, = 959
	str r2, [r3, # 0x2c] @ ARR
	movs r2, # 0x20
	str r2, [r3, # 0x04] @ TRGO

	@tim1chushiha:
	ldr r0, = 0x40012c00 @ tim1_cr1
	movs r1, # 0
	str r1, [r0, # 0x28] @ psc
	ldr r1, = 47999
	str r1, [r0, # 0x2c] @ ARR
	@       movs r1, # 0x20
	@       str r1, [r0, # 0x04] @ TRGO
	ldr r1, = 0x6800
	str r1, [r0, # 0x18] @ ccmr1  CC2
	ldr r1, = 0x10    @  CC2
	str r1, [r0, # 0x20] @ ccer
	ldr r1, = 0x8000
	str r1, [r0, # 0x44] @ BDTR
	@       ldr r1, = 0x100 @ CC2 DMA
	@       str r1, [r0, # 0x0c] @ DIER
	ldr r1, = 24000
	str r1, [r0, # 0x38]
	ldr r1, = 0x81
	str r1, [r0]
	str r1, [r3]
	ldr r4, = 0xe000e010
	ldr r3, = 479999
	str r3, [r4, # 4]
	str r3, [r4, # 8]
	movs r3, # 0x07
	str r3, [r4]    @systick 开

	ldr r0, = lvbo_changdu
	ldr r1, = lvbo_youyi
	movs r2, # 200
	str r2, [r0]
	movs r2, # 14
	str r2, [r1]

	ldr r0, = cossin
	ldr r1, = cos_sin_biao_1k
	str r1, [r0]


__anjian0:
	b ting
__anjian1:
__dangwei_jia_deng_songshou:
	bl __an_jian
	cmp r0, # 3
	beq __anjian3
	cmp r0, # 0
	beq __dangwei_jia_le
	bl __xianshi_neizu
	b __dangwei_jia_deng_songshou
__dangwei_jia_le:
	ldr r0, = liangcheng
	ldr r1, [r0]
	adds r1, r1, # 1
	str r1, [r0]
	cmp r1, # 2
	bne __anjian2_fanhui
	movs r1, # 0
	str r1, [r0]

__anjian2_fanhui:
	b __ren_wu_diao_du
	.ltorg
	
__anjian2:
	movs r0, # 2
	movs r1, # 0xff
	bl _zhuanshumaguanma
	bl _xieshumaguan
	b __ren_wu_diao_du
	
__anjian3:
	movs r0, # 3
	movs r1, # 0xff
	bl _zhuanshumaguanma
	bl _xieshumaguan
	b __ren_wu_diao_du
__ren_wu_diao_du:
	bl __an_jian
	lsls r0, r0, # 2
	ldr r1, = an_jian_biao
	ldr r2, [r1, r0]
	mov pc, r2


	
ting:
	bl __xianshi_neizu
	b __ren_wu_diao_du
	ldr r0, = z
	ldr r0, [r0]
	movs r1, # 0xff
	bl _zhuanshumaguanma
	bl _xieshumaguan
	b __ren_wu_diao_du
	
	
	@	ldr r0, = 1234
	bl __jishu
	movs r1, # 0xff
	bl _zhuanshumaguanma
	bl _xieshumaguan
	b ting
	

__xianshi_neizu:
	push {r0-r2,lr}
	ldr r0, = liangcheng
	ldr r1, = danwei_biao
	ldr r0, [r0]
	ldr r3, = xiaoshudian_weizhi
	ldrb r1, [r1, r0]
	ldrb r3, [r3, r0]
	ldr r2, = danwei
	str r1, [r2]
	ldr r1, = chuchang_dianzu
	lsls r0, r0, # 2
	ldr r1, [r1, r0]
	ldr r0, = fudu
	ldr r2, = z
	ldr r0, [r0]
	muls r0, r0, r1
	asrs r0, r0, # 15
	str r0, [r2]
	mov r1, r3
	bl _zhuanshumaguanma
	bl _xieshumaguan
	pop {r0-r2,pc}

__an_jian:
	@入口PA2=按键1，PA3=按键2
	@出口R0
	ldr r0, = 0x50000010
	ldr r0, [r0]	@pa6 pa9
	mvns r0, r0
	lsls r0, r0, # 28
	lsrs r0, r0, # 30
	bx lr
	
__dft:
	push {r2-r7,lr}
	mov r5, r10
	mov r6, r11
	mov r7, r12
	push {r5-r7}
	ldr r0, = cossin
	ldr r1, = dianyabiao
	ldr r0, [r0]
	movs r6, # 0
	mov r7, r6
	mov r12, sp
	mov r11, r0
	mov r10, r1
	b __dft_xunhuan
	.ltorg
__dft_xunhuan:
	@0
	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4		@R
	muls r1, r1, r4		@I
	muls r2, r2, r5		@R
	muls r3, r3, r5		@I
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2	 @r
	adds r1, r1, r3	 @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2  @r
	adds r1, r1, r3  @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	@1
	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4		@R
	muls r1, r1, r4		@I
	muls r2, r2, r5		@R
	muls r3, r3, r5		@I
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2	 @r
	adds r1, r1, r3	 @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2  @r
	adds r1, r1, r3  @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	@2
	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4		@R
	muls r1, r1, r4		@I
	muls r2, r2, r5		@R
	muls r3, r3, r5		@I
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2	 @r
	adds r1, r1, r3	 @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2  @r
	adds r1, r1, r3  @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	@3
	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4		@R
	muls r1, r1, r4		@I
	muls r2, r2, r5		@R
	muls r3, r3, r5		@I
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2	 @r
	adds r1, r1, r3	 @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2  @r
	adds r1, r1, r3  @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	@4
	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4		@R
	muls r1, r1, r4		@I
	muls r2, r2, r5		@R
	muls r3, r3, r5		@I
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2	 @r
	adds r1, r1, r3	 @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2  @r
	adds r1, r1, r3  @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	@5
	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4		@R
	muls r1, r1, r4		@I
	muls r2, r2, r5		@R
	muls r3, r3, r5		@I
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2	 @r
	adds r1, r1, r3	 @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2  @r
	adds r1, r1, r3  @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	@6
	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4		@R
	muls r1, r1, r4		@I
	muls r2, r2, r5		@R
	muls r3, r3, r5		@I
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2	 @r
	adds r1, r1, r3	 @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2  @r
	adds r1, r1, r3  @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	@7
	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4		@R
	muls r1, r1, r4		@I
	muls r2, r2, r5		@R
	muls r3, r3, r5		@I
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2	 @r
	adds r1, r1, r3	 @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2  @r
	adds r1, r1, r3  @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	@8
	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4		@R
	muls r1, r1, r4		@I
	muls r2, r2, r5		@R
	muls r3, r3, r5		@I
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2	 @r
	adds r1, r1, r3	 @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2  @r
	adds r1, r1, r3  @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	@9
	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4		@R
	muls r1, r1, r4		@I
	muls r2, r2, r5		@R
	muls r3, r3, r5		@I
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2	 @r
	adds r1, r1, r3	 @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2  @r
	adds r1, r1, r3  @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	@10
	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4		@R
	muls r1, r1, r4		@I
	muls r2, r2, r5		@R
	muls r3, r3, r5		@I
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2	 @r
	adds r1, r1, r3	 @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2  @r
	adds r1, r1, r3  @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	@11
	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4		@R
	muls r1, r1, r4		@I
	muls r2, r2, r5		@R
	muls r3, r3, r5		@I
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2	 @r
	adds r1, r1, r3	 @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2  @r
	adds r1, r1, r3  @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1

	@12
	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4         @R
	muls r1, r1, r4         @I
	muls r2, r2, r5         @R
	muls r3, r3, r5         @I
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2  @r
	adds r1, r1, r3  @i
	adds r6, r6, r0
	adds r7, r7, r1

	mov sp, r11
	pop {r0-r3}
	mov r11, sp
	mov sp, r10
	pop {r4}
	mov r10, sp
	mov r5, r4
	lsls r4, r4, # 16
	lsrs r4, r4, # 16
	lsrs r5, r5, # 16
	muls r0, r0, r4
	muls r1, r1, r4
	muls r2, r2, r5
	muls r3, r3, r5
	asrs r0, r0, # 6
	asrs r1, r1, # 6
	asrs r2, r2, # 6
	asrs r3, r3, # 6
	adds r0, r0, r2         @r
	adds r1, r1, r3         @i
	adds r6, r6, r0
	adds r7, r7, r1


	@	bkpt # 1
	ldr r0, = dianyabiao
	ldr r1, = 0x7d0
	adds r0, r0, r1
	cmp r10, r0
	beq __dft_fanhuile
	ldr r0, = cossin
	ldr r0, [r0]
	mov r11, r0
	ldr r0, = __dft_xunhuan
	adds r0, r0, # 1
	mov pc, r0
	@	b __dft_xunhuan
__dft_fanhuile:
	mov r0, r6
	mov r1, r7
	asrs r0, r0, # 9	@dfdf
	asrs r1, r1, # 9
	mov sp, r12
	pop {r2-r4}
	mov r10, r2
	mov r11, r3
	mov r12, r4
	pop {r2-r7,pc}
	.ltorg

__lv_bo_qi:
	@地址顺序：指针，累加值，缓冲区
	@入口R0=缓冲区，R1=数据, r2,=指针
	@出口R0
	push {r3-r7,lr}
	ldr r4, = lvbo_changdu
	ldr r7, = lvbo_youyi
	ldr r4, [r4]
	ldr r7, [r7]
	ldr r5, [r2]
	mov r3, r5
	lsls r3, r5, # 2
	ldr r6, [r0, r3]
	str r1, [r0, r3]
	adds r5, r5, # 1
	str r5, [r2]
	cmp r5, r4
	bne __huanchong_leijia
	movs r5, # 0
	str r5, [r2]
__huanchong_leijia:
	subs r0, r0, # 4
	ldr r5, [r0]
	adds r1, r1, r5
	subs r1, r1, r6
	str r1, [r0]
	asrs r1, r1, r7	 @# 12 @12 @  7	@128
	mov r0, r1
	pop {r3-r7,pc}
	.ltorg
__ji_suan_fu_du:		    @ 计算幅度
	@ 入r0= 实部，r1= 虚部
	@ 出r0 = 幅度
	@ Mag ~=Alpha * max(|I|, |Q|) + Beta * min(|I|, |Q|)
	@ Alpha * Max + Beta * Min
	push {r1-r3,lr}
	movs r0, r0
	bpl _shibubushifushu
	mvns r0, r0                             @ 是负数转成正数
	adds r0, r0, # 1
_shibubushifushu:		                               @ 实部不是负数
	movs r1, r1
	bpl _xububushifushu
	mvns r1, r1                             @ 是负数转成正数
	adds r1, r1, # 1
_xububushifushu:		                                @ 虚部不是负数
	cmp r0, # 0
	bne _panduanxubushibushi0
	mov r0, r1
	pop {r1-r3,pc}
_panduanxubushibushi0:
	cmp r1, # 0
	bne _jisuanfudu1
	pop {r1-r3,pc}
_jisuanfudu1:
	ldr r2, = 31066		@ Alpha q15 0.948059448969
	ldr r3, = 12867		@ Beta q15 0.392699081699
	cmp r1, r0
	bhi _alpha_min_beta_max
_alpha_max_beta_min:
	muls r0, r0, r2
	muls r1, r1, r3
	asrs r0, r0, # 15
	asrs r1, r1, # 15
	adds r0, r0, r1
	movs r1, # 1
	pop {r1-r3,pc}
_alpha_min_beta_max:
	muls r0, r0, r3
	muls r1, r1, r2
	asrs r0, r0, # 15
	asrs r1, r1, # 15
	adds r0, r0, r1
	movs r1, # 0
	pop {r1-r3,pc}


	
__jishu:
	push {r1-r2}
	ldr r2, = 10000
	ldr r1, = jishu
	ldr r0, [r1]
	adds r0, r0, # 1
	str r0, [r1]
	cmp r0, r2
	bne __jisuan_fanhui
	movs r0, # 0
	str r0, [r1]
__jisuan_fanhui:
	pop {r1-r2}
	bx lr

_zhuanshumaguanma:	@ 16进制转数码管码
	@ R0要转的数据, r1小数点位置
	push {r2-r7,lr}
	mov r3, r8
	push {r3}
	mov r8, r1
	ldr r2, = shumaguanma
	ldr r7, = shumaguanmabiao
	mov r5, r0
	movs r3, # 4 @长度
	mov r6, r3
	movs r1, # 10
_xunhuanqiuma:
	bl _chufa
	mov r4, r0
	muls r4, r1
	subs r3, r5, r4
	ldrb r4, [r7, r3]
	cmp r6, r8
	beq __tian_jia_xiao_shu_dian
	b __bao_cun_shu_ma_guan_ma
__tian_jia_xiao_shu_dian:
	subs r4, r4, # 0x80
__bao_cun_shu_ma_guan_ma:
	strb r4, [r2]
	mov r5, r0
	adds r2, r2, # 1
	subs r6, # 1
	bne _xunhuanqiuma
	pop {r3}
	mov r8, r3
	pop {r2-r7,pc}
_xieshumaguan:	 @ 
	push {r0-r6,lr}
	movs r6, # 0
	ldr r5, = shumaguanma
	ldr r1, = danwei
	ldr r1, [r1]
	lsls r1, r1, # 8
	ldr r2, = shumaguanshuaxinbiao
_shumaguanshuaxin:
	ldrb r3, [r5, r6]
	ldrb r4, [r2, r6]
	lsls r4, r4, # 8
	orrs r4, r4, r3
	adds r4, r4, r1
	mov r0, r4
	bl __xie_spi
	adds  r6, r6, # 1
	cmp r6, # 4
	bne _shumaguanshuaxin
	
	pop {r0-r6,pc}

	
__xie_spi: @ r0=16位
	push {r1-r4,lr}
	ldr r2, = 0x40013000
__spi_mang:
	ldr r1, [r2,0x08]
	lsls r1, r1, # 24
	bmi __spi_mang
	strh r0, [r2,0x0c]

	ldr r0, = 0x50000018
	movs r1, # 0x10
	str r1, [r0]
	ldr r2, = 0xff
__pa4_yanshi:
	subs r2, r2, # 1
	bne __pa4_yanshi
	lsls r1, r1, # 16
	str r1, [r0]
	pop {r1-r4,pc}
	
	
_chufa:					@软件除法
	@ r0 除以 r1 等于 商(r0)
	push {r1-r4,lr}
	cmp r0, # 0
	beq _chufafanhui
	cmp r1, # 0
	beq _chufafanhui
	mov r2, r0
	movs r3, # 1
	lsls r3, r3, # 31
	movs r0, # 0
	mov r4, r0
_chufaxunhuan:
	lsls r2, r2, # 1
	adcs r4, r4, r4
	cmp r4, r1
	bcc _chufaweishubudao0
	adds r0, r0, r3
	subs r4, r4, r1
_chufaweishubudao0:
	lsrs r3, r3, # 1
	bne _chufaxunhuan
_chufafanhui:
	pop {r1-r4,pc}
	.ltorg


	
_nmi_handler:
	bx lr
_hard_fault:
	bx lr
_svc_handler:
	bx lr
_pendsv_handler:
	bx lr
_systickzhongduan:		@syzd
	push {r0-r4,lr}
__suan_dft:
	bl __dft
	ldr r2, = shangbi_rr
	ldr r3, = shangbi_ii
	str r0, [r2]
	str r1, [r3]
	mov r4, r0
	ldr r2, = lvboqizhizhen1
	ldr r0, =lvboqihuanchong1
	bl __lv_bo_qi
	ldr r1, = shangbi_i
	str r0, [r1]
	mov r1, r4
	ldr r2, = lvboqizhizhen
	ldr r0, =lvboqihuanchong
	bl __lv_bo_qi
	ldr r1, = shangbi_r
	str r0, [r1]

	ldr r0, = shangbi_r
	ldr r1, = shangbi_i
	ldr r0, [r0]
	ldr r1, [r1]
	bl __ji_suan_fu_du
	ldr r2, = fudu
	str r0, [r2]

	ldr r0, = liangcheng
	ldr r2, = 0x50000400
	ldr r3, [r0]
	ldr r0, [r2, # 0x14]
	ldr r1, = 0xffff
	ands r0, r0, r1
	orrs r0, r0, r3
	str r0, [r2, # 0x14]
	
__systick_fanhui:
	ldr r0, = 0xe0000d04
	ldr r1, = 0x02000000
	str r1, [r0]                 @ 清除SYSTICK中断
	pop {r0-r4,pc}
	
aaa:
	bx lr
	.ltorg
	
	.align 4
	.equ dianyabiao,        	0x20000160
	.equ STACKINIT,         	0x20000160
	.equ lvboqizhizhen,             0x20000930
	.equ lvboqihuanchong,           0x20000938
	.equ lvboqizhizhen1,            0x20000c60
	.equ lvboqihuanchong1,          0x20000c68

	.equ liangcheng,		0x20000fcc
	.equ z,				0x20000fd0
	.equ jishu,			0x20000fd4
	.equ fudu,			0x20000fd8
	.equ shangbi_rr,		0x20000fdc
	.equ shangbi_ii,		0x20000fe0
	.equ shangbi_r,			0x20000fe4
	.equ shangbi_i,			0x20000fe8
	.equ lvbo_youyi,		0x20000fec
	.equ lvbo_changdu,		0x20000ff0
	.equ cossin,                    0x20000ff4
	.equ danwei,                    0x20000ff8
	.equ shumaguanma,               0x20000ffc

an_jian_biao:
	.word __anjian0	+1
	.word __anjian1	+1
	.word __anjian2	+1
	.word __anjian3	+1

xiaoshudian_weizhi:
	.byte 1,2
	.align 4
chuchang_dianzu:
	.int 7124,20591		@2欧=7124 58毫欧=20591
	.align 4
danwei_biao:
	.byte 0x40,0x80
	.align 4
yjmwxwx:
	.ascii "yjmwxwx-20230516"
	.align 4
zheng_xian_1khz:
	.byte 125,128,132,136,140,144,148,152,155,159,163,167,170,174,178,181,184,188,191,194,198,201,204,207,210,213,215,218,220,223,225,227,230,232,234,235,237,239,240,242,243,244,245,246,247,247,248,248,249,249,249,249,249,248,248,247,247,246,245,244,243,242,240,239,237,235,234,232,230,227,225,223,220,218,215,213,210,207,204,201,198,194,191,188,184,181,178,174,170,167,163,159,155,152,148,144,140,136,132,128,125,121,117,113,109,105,101,97,94,90,86,82,79,75,71,68,65,61,58,55,51,48,45,42,39,36,34,31,29,26,24,22,19,17,15,14,12,10,9,7,6,5,4,3,2,2,1,1,0,0,0,0,0,1,1,2,2,3,4,5,6,7,9,10,12,14,15,17,19,22,24,26,29,31,34,36,39,42,45,48,51,55,58,61,65,68,71,75,79,82,86,90,94,97,101,105,109,113,117,121
	
	.align 4
shumaguanmabiao:
	.byte 0xc0,0xf9,0xa4,0xb0,0x99,0x92,0x82,0xf8,0x80,0x90
	.align 4
shumaguanshuaxinbiao:
	.byte 0x10,0x08,0x04,0x02
	.align 4
cos_sin_biao_1k:
	.int 0x8000,0x0000,0x7FBF,0xFFFFF7F7,0x7EFD,0xFFFFEFF6,0x7DBB,0xFFFFE804,0x7BFA,0xFFFFE02B,0x79BC,0xFFFFD873,0x7702,0xFFFFD0E2,0x73D1,0xFFFFC981,0x702A,0xFFFFC256,0x6C12,0xFFFFBB6B,0x678D,0xFFFFB4C4,0x62A0,0xFFFFAE69,0x5D4E,0xFFFFA861,0x579F,0xFFFFA2B2,0x5197,0xFFFF9D60,0x4B3C,0xFFFF9873,0x4495,0xFFFF93EE,0x3DAA,0xFFFF8FD6,0x367F,0xFFFF8C2F,0x2F1E,0xFFFF88FE,0x278D,0xFFFF8644,0x1FD5,0xFFFF8406,0x17FC,0xFFFF8245,0x100A,0xFFFF8103,0x0809,0xFFFF8041,0x0000,0xFFFF8000,0xFFFFF7F7,0xFFFF8041,0xFFFFEFF6,0xFFFF8103,0xFFFFE804,0xFFFF8245,0xFFFFE02B,0xFFFF8406,0xFFFFD873,0xFFFF8644,0xFFFFD0E2,0xFFFF88FE,0xFFFFC981,0xFFFF8C2F,0xFFFFC256,0xFFFF8FD6,0xFFFFBB6B,0xFFFF93EE,0xFFFFB4C4,0xFFFF9873,0xFFFFAE69,0xFFFF9D60,0xFFFFA861,0xFFFFA2B2,0xFFFFA2B2,0xFFFFA861,0xFFFF9D60,0xFFFFAE69,0xFFFF9873,0xFFFFB4C4,0xFFFF93EE,0xFFFFBB6B,0xFFFF8FD6,0xFFFFC256,0xFFFF8C2F,0xFFFFC981,0xFFFF88FE,0xFFFFD0E2,0xFFFF8644,0xFFFFD873,0xFFFF8406,0xFFFFE02B,0xFFFF8245,0xFFFFE804,0xFFFF8103,0xFFFFEFF6,0xFFFF8041,0xFFFFF7F7,0xFFFF8000,0x0000,0xFFFF8041,0x0809,0xFFFF8103,0x100A,0xFFFF8245,0x17FC,0xFFFF8406,0x1FD5,0xFFFF8644,0x278D,0xFFFF88FE,0x2F1E,0xFFFF8C2F,0x367F,0xFFFF8FD6,0x3DAA,0xFFFF93EE,0x4495,0xFFFF9873,0x4B3C,0xFFFF9D60,0x5197,0xFFFFA2B2,0x579F,0xFFFFA861,0x5D4E,0xFFFFAE69,0x62A0,0xFFFFB4C4,0x678D,0xFFFFBB6B,0x6C12,0xFFFFC256,0x702A,0xFFFFC981,0x73D1,0xFFFFD0E2,0x7702,0xFFFFD873,0x79BC,0xFFFFE02B,0x7BFA,0xFFFFE804,0x7DBB,0xFFFFEFF6,0x7EFD,0xFFFFF7F7,0x7FBF,0x0000,0x8000,0x0809,0x7FBF,0x100A,0x7EFD,0x17FC,0x7DBB,0x1FD5,0x7BFA,0x278D,0x79BC,0x2F1E,0x7702,0x367F,0x73D1,0x3DAA,0x702A,0x4495,0x6C12,0x4B3C,0x678D,0x5197,0x62A0,0x579F,0x5D4E,0x5D4E,0x579F,0x62A0,0x5197,0x678D,0x4B3C,0x6C12,0x4495,0x702A,0x3DAA,0x73D1,0x367F,0x7702,0x2F1E,0x79BC,0x278D,0x7BFA,0x1FD5,0x7DBB,0x17FC,0x7EFD,0x100A,0x7FBF,0x0809,0x8000,0x0000,0x7FBF,0xFFFFF7F7,0x7EFD,0xFFFFEFF6,0x7DBB,0xFFFFE804,0x7BFA,0xFFFFE02B,0x79BC,0xFFFFD873,0x7702,0xFFFFD0E2,0x73D1,0xFFFFC981,0x702A,0xFFFFC256,0x6C12,0xFFFFBB6B,0x678D,0xFFFFB4C4,0x62A0,0xFFFFAE69,0x5D4E,0xFFFFA861,0x579F,0xFFFFA2B2,0x5197,0xFFFF9D60,0x4B3C,0xFFFF9873,0x4495,0xFFFF93EE,0x3DAA,0xFFFF8FD6,0x367F,0xFFFF8C2F,0x2F1E,0xFFFF88FE,0x278D,0xFFFF8644,0x1FD5,0xFFFF8406,0x17FC,0xFFFF8245,0x100A,0xFFFF8103,0x0809,0xFFFF8041,0x0000,0xFFFF8000,0xFFFFF7F7,0xFFFF8041,0xFFFFEFF6,0xFFFF8103,0xFFFFE804,0xFFFF8245,0xFFFFE02B,0xFFFF8406,0xFFFFD873,0xFFFF8644,0xFFFFD0E2,0xFFFF88FE,0xFFFFC981,0xFFFF8C2F,0xFFFFC256,0xFFFF8FD6,0xFFFFBB6B,0xFFFF93EE,0xFFFFB4C4,0xFFFF9873,0xFFFFAE69,0xFFFF9D60,0xFFFFA861,0xFFFFA2B2,0xFFFFA2B2,0xFFFFA861,0xFFFF9D60,0xFFFFAE69,0xFFFF9873,0xFFFFB4C4,0xFFFF93EE,0xFFFFBB6B,0xFFFF8FD6,0xFFFFC256,0xFFFF8C2F,0xFFFFC981,0xFFFF88FE,0xFFFFD0E2,0xFFFF8644,0xFFFFD873,0xFFFF8406,0xFFFFE02B,0xFFFF8245,0xFFFFE804,0xFFFF8103,0xFFFFEFF6,0xFFFF8041,0xFFFFF7F7,0xFFFF8000,0x0000,0xFFFF8041,0x0809,0xFFFF8103,0x100A,0xFFFF8245,0x17FC,0xFFFF8406,0x1FD5,0xFFFF8644,0x278D,0xFFFF88FE,0x2F1E,0xFFFF8C2F,0x367F,0xFFFF8FD6,0x3DAA,0xFFFF93EE,0x4495,0xFFFF9873,0x4B3C,0xFFFF9D60,0x5197,0xFFFFA2B2,0x579F,0xFFFFA861,0x5D4E,0xFFFFAE69,0x62A0,0xFFFFB4C4,0x678D,0xFFFFBB6B,0x6C12,0xFFFFC256,0x702A,0xFFFFC981,0x73D1,0xFFFFD0E2,0x7702,0xFFFFD873,0x79BC,0xFFFFE02B,0x7BFA,0xFFFFE804,0x7DBB,0xFFFFEFF6,0x7EFD,0xFFFFF7F7,0x7FBF,0x0000,0x8000,0x0809,0x7FBF,0x100A,0x7EFD,0x17FC,0x7DBB,0x1FD5,0x7BFA,0x278D,0x79BC,0x2F1E,0x7702,0x367F,0x73D1,0x3DAA,0x702A,0x4495,0x6C12,0x4B3C,0x678D,0x5197,0x62A0,0x579F,0x5D4E,0x5D4E,0x579F,0x62A0,0x5197,0x678D,0x4B3C,0x6C12,0x4495,0x702A,0x3DAA,0x73D1,0x367F,0x7702,0x2F1E,0x79BC,0x278D,0x7BFA,0x1FD5,0x7DBB,0x17FC,0x7EFD,0x100A,0x7FBF,0x0809,0x8000,0x0000,0x7FBF,0xFFFFF7F7,0x7EFD,0xFFFFEFF6,0x7DBB,0xFFFFE804,0x7BFA,0xFFFFE02B,0x79BC,0xFFFFD873,0x7702,0xFFFFD0E2,0x73D1,0xFFFFC981,0x702A,0xFFFFC256,0x6C12,0xFFFFBB6B,0x678D,0xFFFFB4C4,0x62A0,0xFFFFAE69,0x5D4E,0xFFFFA861,0x579F,0xFFFFA2B2,0x5197,0xFFFF9D60,0x4B3C,0xFFFF9873,0x4495,0xFFFF93EE,0x3DAA,0xFFFF8FD6,0x367F,0xFFFF8C2F,0x2F1E,0xFFFF88FE,0x278D,0xFFFF8644,0x1FD5,0xFFFF8406,0x17FC,0xFFFF8245,0x100A,0xFFFF8103,0x0809,0xFFFF8041,0x0000,0xFFFF8000,0xFFFFF7F7,0xFFFF8041,0xFFFFEFF6,0xFFFF8103,0xFFFFE804,0xFFFF8245,0xFFFFE02B,0xFFFF8406,0xFFFFD873,0xFFFF8644,0xFFFFD0E2,0xFFFF88FE,0xFFFFC981,0xFFFF8C2F,0xFFFFC256,0xFFFF8FD6,0xFFFFBB6B,0xFFFF93EE,0xFFFFB4C4,0xFFFF9873,0xFFFFAE69,0xFFFF9D60,0xFFFFA861,0xFFFFA2B2,0xFFFFA2B2,0xFFFFA861,0xFFFF9D60,0xFFFFAE69,0xFFFF9873,0xFFFFB4C4,0xFFFF93EE,0xFFFFBB6B,0xFFFF8FD6,0xFFFFC256,0xFFFF8C2F,0xFFFFC981,0xFFFF88FE,0xFFFFD0E2,0xFFFF8644,0xFFFFD873,0xFFFF8406,0xFFFFE02B,0xFFFF8245,0xFFFFE804,0xFFFF8103,0xFFFFEFF6,0xFFFF8041,0xFFFFF7F7,0xFFFF8000,0x0000,0xFFFF8041,0x0809,0xFFFF8103,0x100A,0xFFFF8245,0x17FC,0xFFFF8406,0x1FD5,0xFFFF8644,0x278D,0xFFFF88FE,0x2F1E,0xFFFF8C2F,0x367F,0xFFFF8FD6,0x3DAA,0xFFFF93EE,0x4495,0xFFFF9873,0x4B3C,0xFFFF9D60,0x5197,0xFFFFA2B2,0x579F,0xFFFFA861,0x5D4E,0xFFFFAE69,0x62A0,0xFFFFB4C4,0x678D,0xFFFFBB6B,0x6C12,0xFFFFC256,0x702A,0xFFFFC981,0x73D1,0xFFFFD0E2,0x7702,0xFFFFD873,0x79BC,0xFFFFE02B,0x7BFA,0xFFFFE804,0x7DBB,0xFFFFEFF6,0x7EFD,0xFFFFF7F7,0x7FBF,0x0000,0x8000,0x0809,0x7FBF,0x100A,0x7EFD,0x17FC,0x7DBB,0x1FD5,0x7BFA,0x278D,0x79BC,0x2F1E,0x7702,0x367F,0x73D1,0x3DAA,0x702A,0x4495,0x6C12,0x4B3C,0x678D,0x5197,0x62A0,0x579F,0x5D4E,0x5D4E,0x579F,0x62A0,0x5197,0x678D,0x4B3C,0x6C12,0x4495,0x702A,0x3DAA,0x73D1,0x367F,0x7702,0x2F1E,0x79BC,0x278D,0x7BFA,0x1FD5,0x7DBB,0x17FC,0x7EFD,0x100A,0x7FBF,0x0809,0x8000,0x0000,0x7FBF,0xFFFFF7F7,0x7EFD,0xFFFFEFF6,0x7DBB,0xFFFFE804,0x7BFA,0xFFFFE02B,0x79BC,0xFFFFD873,0x7702,0xFFFFD0E2,0x73D1,0xFFFFC981,0x702A,0xFFFFC256,0x6C12,0xFFFFBB6B,0x678D,0xFFFFB4C4,0x62A0,0xFFFFAE69,0x5D4E,0xFFFFA861,0x579F,0xFFFFA2B2,0x5197,0xFFFF9D60,0x4B3C,0xFFFF9873,0x4495,0xFFFF93EE,0x3DAA,0xFFFF8FD6,0x367F,0xFFFF8C2F,0x2F1E,0xFFFF88FE,0x278D,0xFFFF8644,0x1FD5,0xFFFF8406,0x17FC,0xFFFF8245,0x100A,0xFFFF8103,0x0809,0xFFFF8041,0x0000,0xFFFF8000,0xFFFFF7F7,0xFFFF8041,0xFFFFEFF6,0xFFFF8103,0xFFFFE804,0xFFFF8245,0xFFFFE02B,0xFFFF8406,0xFFFFD873,0xFFFF8644,0xFFFFD0E2,0xFFFF88FE,0xFFFFC981,0xFFFF8C2F,0xFFFFC256,0xFFFF8FD6,0xFFFFBB6B,0xFFFF93EE,0xFFFFB4C4,0xFFFF9873,0xFFFFAE69,0xFFFF9D60,0xFFFFA861,0xFFFFA2B2,0xFFFFA2B2,0xFFFFA861,0xFFFF9D60,0xFFFFAE69,0xFFFF9873,0xFFFFB4C4,0xFFFF93EE,0xFFFFBB6B,0xFFFF8FD6,0xFFFFC256,0xFFFF8C2F,0xFFFFC981,0xFFFF88FE,0xFFFFD0E2,0xFFFF8644,0xFFFFD873,0xFFFF8406,0xFFFFE02B,0xFFFF8245,0xFFFFE804,0xFFFF8103,0xFFFFEFF6,0xFFFF8041,0xFFFFF7F7,0xFFFF8000,0x0000,0xFFFF8041,0x0809,0xFFFF8103,0x100A,0xFFFF8245,0x17FC,0xFFFF8406,0x1FD5,0xFFFF8644,0x278D,0xFFFF88FE,0x2F1E,0xFFFF8C2F,0x367F,0xFFFF8FD6,0x3DAA,0xFFFF93EE,0x4496,0xFFFF9873,0x4B3C,0xFFFF9D60,0x5197,0xFFFFA2B2,0x579F,0xFFFFA861,0x5D4E,0xFFFFAE69,0x62A0,0xFFFFB4C4,0x678D,0xFFFFBB6B,0x6C13,0xFFFFC256,0x702A,0xFFFFC981,0x73D1,0xFFFFD0E2,0x7702,0xFFFFD873,0x79BC,0xFFFFE02B,0x7BFA,0xFFFFE804,0x7DBB,0xFFFFEFF6,0x7EFD,0xFFFFF7F7,0x7FBF,0x0000,0x8000,0x0809,0x7FBF,0x100A,0x7EFD,0x17FC,0x7DBB,0x1FD5,0x7BFA,0x278D,0x79BC,0x2F1E,0x7702,0x367F,0x73D1,0x3DAA,0x702A,0x4495,0x6C12,0x4B3C,0x678D,0x5197,0x62A0,0x579F,0x5D4E,0x5D4E,0x579F,0x62A0,0x5197,0x678D,0x4B3C,0x6C12,0x4495,0x702A,0x3DAA,0x73D1,0x367F,0x7702,0x2F1E,0x79BC,0x278D,0x7BFA,0x1FD5,0x7DBB,0x17FC,0x7EFD,0x100A,0x7FBF,0x0809,0x8000,0x0000,0x7FBF,0xFFFFF7F7,0x7EFD,0xFFFFEFF6,0x7DBB,0xFFFFE804,0x7BFA,0xFFFFE02B,0x79BC,0xFFFFD873,0x7702,0xFFFFD0E2,0x73D1,0xFFFFC980,0x702A,0xFFFFC256,0x6C12,0xFFFFBB6B,0x678D,0xFFFFB4C4,0x62A0,0xFFFFAE69,0x5D4E,0xFFFFA861,0x579F,0xFFFFA2B2,0x5197,0xFFFF9D60,0x4B3C,0xFFFF9873,0x4495,0xFFFF93EE,0x3DAA,0xFFFF8FD6,0x367F,0xFFFF8C2F,0x2F1E,0xFFFF88FE,0x278D,0xFFFF8644,0x1FD5,0xFFFF8406,0x17FC,0xFFFF8245,0x100A,0xFFFF8103,0x0809,0xFFFF8041,0x0000,0xFFFF8000,0xFFFFF7F7,0xFFFF8041,0xFFFFEFF6,0xFFFF8103,0xFFFFE804,0xFFFF8245,0xFFFFE02B,0xFFFF8406,0xFFFFD873,0xFFFF8644,0xFFFFD0E2,0xFFFF88FE,0xFFFFC981,0xFFFF8C2F,0xFFFFC256,0xFFFF8FD6,0xFFFFBB6A,0xFFFF93EE,0xFFFFB4C4,0xFFFF9873,0xFFFFAE69,0xFFFF9D60,0xFFFFA861,0xFFFFA2B2,0xFFFFA2B2,0xFFFFA861,0xFFFF9D60,0xFFFFAE69,0xFFFF9873,0xFFFFB4C4,0xFFFF93EE,0xFFFFBB6B,0xFFFF8FD6,0xFFFFC256,0xFFFF8C2F,0xFFFFC981,0xFFFF88FE,0xFFFFD0E2,0xFFFF8644,0xFFFFD873,0xFFFF8406,0xFFFFE02B,0xFFFF8245,0xFFFFE804,0xFFFF8103,0xFFFFEFF6,0xFFFF8041,0xFFFFF7F7,0xFFFF8000,0x0000,0xFFFF8041,0x0809,0xFFFF8103,0x100A,0xFFFF8245,0x17FC,0xFFFF8406,0x1FD5,0xFFFF8644,0x278D,0xFFFF88FE,0x2F1E,0xFFFF8C2F,0x3680,0xFFFF8FD6,0x3DAA,0xFFFF93EE,0x4496,0xFFFF9873,0x4B3C,0xFFFF9D60,0x5197,0xFFFFA2B2,0x579F,0xFFFFA861,0x5D4E,0xFFFFAE69,0x62A0,0xFFFFB4C4,0x678D,0xFFFFBB6B,0x6C12,0xFFFFC256,0x702A,0xFFFFC981,0x73D1,0xFFFFD0E2,0x7702,0xFFFFD873,0x79BC,0xFFFFE02C,0x7BFA,0xFFFFE804,0x7DBB,0xFFFFEFF6,0x7EFD,0xFFFFF7F7,0x7FBF,0x0000,0x8000,0x0809,0x7FBF,0x100B,0x7EFD,0x17FC,0x7DBB,0x1FD5,0x7BFA,0x278D,0x79BC,0x2F1E,0x7702,0x367F,0x73D1,0x3DAA,0x702A,0x4495,0x6C12,0x4B3C,0x678D,0x5197,0x62A0,0x579F,0x5D4E,0x5D4E,0x579F,0x62A0,0x5197,0x678D,0x4B3C,0x6C12,0x4495,0x702A,0x3DAA,0x73D1,0x367F,0x7702,0x2F1E,0x79BC,0x278D,0x7BFA,0x1FD5,0x7DBB,0x17FC,0x7EFD,0x100A,0x7FBF,0x0809,0x8000,0x0000,0x7FBF,0xFFFFF7F7,0x7EFD,0xFFFFEFF6,0x7DBB,0xFFFFE804,0x7BFA,0xFFFFE02B,0x79BC,0xFFFFD873,0x7702,0xFFFFD0E2,0x73D1,0xFFFFC981,0x702A,0xFFFFC256,0x6C12,0xFFFFBB6A,0x678D,0xFFFFB4C4,0x62A0,0xFFFFAE69,0x5D4E,0xFFFFA861,0x579F,0xFFFFA2B2,0x5197,0xFFFF9D60,0x4B3C,0xFFFF9873,0x4495,0xFFFF93EE,0x3DAA,0xFFFF8FD6,0x367F,0xFFFF8C2F,0x2F1E,0xFFFF88FE,0x278D,0xFFFF8644,0x1FD5,0xFFFF8406,0x17FC,0xFFFF8245,0x100A,0xFFFF8103,0x0809,0xFFFF8041,0x0000,0xFFFF8000,0xFFFFF7F7,0xFFFF8041,0xFFFFEFF6,0xFFFF8103,0xFFFFE804,0xFFFF8245,0xFFFFE02B,0xFFFF8406,0xFFFFD873,0xFFFF8644,0xFFFFD0E2,0xFFFF88FE,0xFFFFC980,0xFFFF8C2F,0xFFFFC256,0xFFFF8FD6,0xFFFFBB6A,0xFFFF93EE,0xFFFFB4C4,0xFFFF9873,0xFFFFAE69,0xFFFF9D60,0xFFFFA861,0xFFFFA2B2,0xFFFFA2B2,0xFFFFA861,0xFFFF9D60,0xFFFFAE69,0xFFFF9873,0xFFFFB4C4,0xFFFF93EE,0xFFFFBB6B,0xFFFF8FD6,0xFFFFC256,0xFFFF8C2F,0xFFFFC981,0xFFFF88FE,0xFFFFD0E2,0xFFFF8644,0xFFFFD873,0xFFFF8406,0xFFFFE02C,0xFFFF8245,0xFFFFE804,0xFFFF8103,0xFFFFEFF6,0xFFFF8041,0xFFFFF7F7,0xFFFF8000,0x0000,0xFFFF8041,0x0809,0xFFFF8103,0x100A,0xFFFF8245,0x17FC,0xFFFF8406,0x1FD5,0xFFFF8644,0x278D,0xFFFF88FE,0x2F1E,0xFFFF8C2F,0x3680,0xFFFF8FD6,0x3DAA,0xFFFF93EE,0x4496,0xFFFF9873,0x4B3C,0xFFFF9D60,0x5197,0xFFFFA2B2,0x579F,0xFFFFA861,0x5D4E,0xFFFFAE69,0x62A0,0xFFFFB4C4,0x678D,0xFFFFBB6B,0x6C12,0xFFFFC256,0x702A,0xFFFFC981,0x73D1,0xFFFFD0E2,0x7702,0xFFFFD873,0x79BC,0xFFFFE02B,0x7BFA,0xFFFFE804,0x7DBB,0xFFFFEFF6,0x7EFD,0xFFFFF7F7,0x7FBF,0x0000,0x8000,0x0809,0x7FBF,0x100A,0x7EFD,0x17FC,0x7DBB,0x1FD5,0x7BFA,0x278D,0x79BC,0x2F1E,0x7702,0x3680,0x73D1,0x3DAA,0x702A,0x4496,0x6C12,0x4B3C,0x678D,0x5197,0x62A0,0x579F,0x5D4E,0x5D4E,0x579F,0x62A0,0x5197,0x678D,0x4B3C,0x6C12,0x4495,0x702A,0x3DAA,0x73D1,0x367F,0x7702,0x2F1E,0x79BC,0x278D,0x7BFA,0x1FD5,0x7DBB,0x17FC,0x7EFD,0x100A,0x7FBF,0x0809,0x8000,0x0000,0x7FBF,0xFFFFF7F7,0x7EFD,0xFFFFEFF6,0x7DBB,0xFFFFE804,0x7BFA,0xFFFFE02C,0x79BC,0xFFFFD873,0x7702,0xFFFFD0E2,0x73D1,0xFFFFC980,0x702A,0xFFFFC256,0x6C12,0xFFFFBB6A,0x678D,0xFFFFB4C4,0x62A0,0xFFFFAE69,0x5D4E,0xFFFFA861,0x579F,0xFFFFA2B2,0x5197,0xFFFF9D60,0x4B3C,0xFFFF9873,0x4495,0xFFFF93EE,0x3DAA,0xFFFF8FD6,0x367F,0xFFFF8C2F,0x2F1E,0xFFFF88FE,0x278D,0xFFFF8644,0x1FD5,0xFFFF8406,0x17FC,0xFFFF8245,0x100A,0xFFFF8103,0x0809,0xFFFF8041,0x0000,0xFFFF8000,0xFFFFF7F7,0xFFFF8041,0xFFFFEFF6,0xFFFF8103,0xFFFFE804,0xFFFF8245,0xFFFFE02B,0xFFFF8406,0xFFFFD873,0xFFFF8644,0xFFFFD0E2,0xFFFF88FE,0xFFFFC981,0xFFFF8C2F,0xFFFFC256,0xFFFF8FD6,0xFFFFBB6A,0xFFFF93EE,0xFFFFB4C4,0xFFFF9873,0xFFFFAE69,0xFFFF9D60,0xFFFFA861,0xFFFFA2B2,0xFFFFA2B2,0xFFFFA861,0xFFFF9D60,0xFFFFAE69,0xFFFF9873,0xFFFFB4C4,0xFFFF93EE,0xFFFFBB6B,0xFFFF8FD6,0xFFFFC256,0xFFFF8C2F,0xFFFFC981,0xFFFF88FE,0xFFFFD0E2,0xFFFF8644,0xFFFFD873,0xFFFF8406,0xFFFFE02B,0xFFFF8245,0xFFFFE804,0xFFFF8103,0xFFFFEFF6,0xFFFF8041,0xFFFFF7F7,0xFFFF8000,0x0000,0xFFFF8041,0x0809,0xFFFF8103,0x100A,0xFFFF8245,0x17FC,0xFFFF8406,0x1FD4,0xFFFF8644,0x278D,0xFFFF88FE,0x2F1E,0xFFFF8C2F,0x367F,0xFFFF8FD6,0x3DAA,0xFFFF93EE,0x4496,0xFFFF9873,0x4B3C,0xFFFF9D60,0x5197,0xFFFFA2B2,0x579F,0xFFFFA861,0x5D4E,0xFFFFAE69,0x62A0,0xFFFFB4C4,0x678D,0xFFFFBB6B,0x6C12,0xFFFFC256,0x702A,0xFFFFC981,0x73D1,0xFFFFD0E2,0x7702,0xFFFFD873,0x79BC,0xFFFFE02B,0x7BFA,0xFFFFE804,0x7DBB,0xFFFFEFF6,0x7EFD,0xFFFFF7F7,0x7FBF,0x0000,0x8000,0x0809,0x7FBF,0x100A,0x7EFD,0x17FC,0x7DBB,0x1FD5,0x7BFA,0x278D,0x79BC,0x2F1E,0x7702,0x3680,0x73D1,0x3DAA,0x702A,0x4496,0x6C12,0x4B3C,0x678D,0x5197,0x62A0,0x579F,0x5D4E,0x5D4E,0x579F,0x62A0,0x5197,0x678D,0x4B3C,0x6C12,0x4495,0x702A,0x3DAA,0x73D1,0x367F,0x7702,0x2F1E,0x79BC,0x278D,0x7BFA,0x1FD4,0x7DBB,0x17FC,0x7EFD,0x100A,0x7FBF,0x0809,0x8000,0x0000,0x7FBF,0xFFFFF7F7,0x7EFD,0xFFFFEFF5,0x7DBB,0xFFFFE804,0x7BFA,0xFFFFE02B,0x79BC,0xFFFFD873,0x7702,0xFFFFD0E2,0x73D1,0xFFFFC981,0x702A,0xFFFFC256,0x6C12,0xFFFFBB6B,0x678D,0xFFFFB4C4,0x62A0,0xFFFFAE69,0x5D4E,0xFFFFA861,0x579F,0xFFFFA2B2,0x5197,0xFFFF9D60,0x4B3C,0xFFFF9873,0x4495,0xFFFF93EE,0x3DAA,0xFFFF8FD6,0x367F,0xFFFF8C2F,0x2F1E,0xFFFF88FE,0x278D,0xFFFF8644,0x1FD5,0xFFFF8406,0x17FC,0xFFFF8245,0x100A,0xFFFF8103,0x0809,0xFFFF8041,0x0000,0xFFFF8000,0xFFFFF7F7,0xFFFF8041,0xFFFFEFF6,0xFFFF8103,0xFFFFE804,0xFFFF8245,0xFFFFE02B,0xFFFF8406,0xFFFFD873,0xFFFF8644,0xFFFFD0E2,0xFFFF88FE,0xFFFFC980,0xFFFF8C2F,0xFFFFC256,0xFFFF8FD6,0xFFFFBB6B,0xFFFF93EE,0xFFFFB4C4,0xFFFF9873,0xFFFFAE69,0xFFFF9D60,0xFFFFA861,0xFFFFA2B2,0xFFFFA2B2,0xFFFFA861,0xFFFF9D60,0xFFFFAE69,0xFFFF9873,0xFFFFB4C4,0xFFFF93EE,0xFFFFBB6B,0xFFFF8FD6,0xFFFFC256,0xFFFF8C2F,0xFFFFC981,0xFFFF88FE,0xFFFFD0E2,0xFFFF8644,0xFFFFD873,0xFFFF8406,0xFFFFE02B,0xFFFF8245,0xFFFFE804,0xFFFF8103,0xFFFFEFF6,0xFFFF8041,0xFFFFF7F7,0xFFFF8000,0x0000,0xFFFF8041,0x0809,0xFFFF8103,0x100A,0xFFFF8245,0x17FC,0xFFFF8406,0x1FD5,0xFFFF8644,0x278D,0xFFFF88FE,0x2F1E,0xFFFF8C2F,0x367F,0xFFFF8FD6,0x3DAA,0xFFFF93EE,0x4496,0xFFFF9873,0x4B3C,0xFFFF9D60,0x5197,0xFFFFA2B2,0x579F,0xFFFFA861,0x5D4E,0xFFFFAE69,0x62A0,0xFFFFB4C4,0x678D,0xFFFFBB6B,0x6C12,0xFFFFC256,0x702A,0xFFFFC981,0x73D1,0xFFFFD0E2,0x7702,0xFFFFD873,0x79BC,0xFFFFE02B,0x7BFA,0xFFFFE804,0x7DBB,0xFFFFEFF6,0x7EFD,0xFFFFF7F7,0x7FBF,0x0000,0x8000,0x0809,0x7FBF,0x100A,0x7EFD,0x17FC,0x7DBB,0x1FD5,0x7BFA,0x278D,0x79BC,0x2F1E,0x7702,0x367F,0x73D1,0x3DAA,0x702A,0x4496,0x6C12,0x4B3C,0x678D,0x5197,0x62A0,0x579F,0x5D4E,0x5D4E,0x579F,0x62A0,0x5197,0x678D,0x4B3C,0x6C12,0x4495,0x702A,0x3DAA,0x73D1,0x367F,0x7702,0x2F1E,0x79BC,0x278D,0x7BFA,0x1FD5,0x7DBB,0x17FC,0x7EFD,0x100A,0x7FBF,0x0809,0x8000,0x0000,0x7FBF,0xFFFFF7F7,0x7EFD,0xFFFFEFF6,0x7DBB,0xFFFFE804,0x7BFA,0xFFFFE02B,0x79BC,0xFFFFD873,0x7702,0xFFFFD0E2,0x73D1,0xFFFFC981,0x702A,0xFFFFC256,0x6C12,0xFFFFBB6A,0x678D,0xFFFFB4C4,0x62A0,0xFFFFAE69,0x5D4E,0xFFFFA861,0x579F,0xFFFFA2B2,0x5196,0xFFFF9D60,0x4B3C,0xFFFF9873,0x4495,0xFFFF93ED,0x3DAA,0xFFFF8FD6,0x367F,0xFFFF8C2F,0x2F1E,0xFFFF88FE,0x278D,0xFFFF8644,0x1FD5,0xFFFF8406,0x17FC,0xFFFF8245,0x100A,0xFFFF8103,0x0809,0xFFFF8041,0x0000,0xFFFF8000,0xFFFFF7F7,0xFFFF8041,0xFFFFEFF6,0xFFFF8103,0xFFFFE804,0xFFFF8245,0xFFFFE02B,0xFFFF8406,0xFFFFD873,0xFFFF8644,0xFFFFD0E2,0xFFFF88FE,0xFFFFC981,0xFFFF8C2F,0xFFFFC256,0xFFFF8FD6,0xFFFFBB6B,0xFFFF93EE,0xFFFFB4C4,0xFFFF9873,0xFFFFAE69,0xFFFF9D60,0xFFFFA861,0xFFFFA2B2,0xFFFFA2B2,0xFFFFA861,0xFFFF9D60,0xFFFFAE6A,0xFFFF9873,0xFFFFB4C4,0xFFFF93ED,0xFFFFBB6B,0xFFFF8FD6,0xFFFFC256,0xFFFF8C2F,0xFFFFC981,0xFFFF88FE,0xFFFFD0E2,0xFFFF8644,0xFFFFD873,0xFFFF8406,0xFFFFE02B,0xFFFF8245,0xFFFFE804,0xFFFF8103,0xFFFFEFF6,0xFFFF8041,0xFFFFF7F7,0xFFFF8000,0x0000,0xFFFF8041,0x0809,0xFFFF8103,0x100A,0xFFFF8245,0x17FC,0xFFFF8406,0x1FD5,0xFFFF8644,0x278D,0xFFFF88FE,0x2F1E,0xFFFF8C2F,0x367F,0xFFFF8FD6,0x3DAA,0xFFFF93EE,0x4495,0xFFFF9873,0x4B3C,0xFFFF9D60,0x5197,0xFFFFA2B2,0x579F,0xFFFFA861,0x5D4E,0xFFFFAE69,0x62A0,0xFFFFB4C4,0x678D,0xFFFFBB6B,0x6C12,0xFFFFC256,0x702A,0xFFFFC981,0x73D1,0xFFFFD0E2,0x7702,0xFFFFD873,0x79BC,0xFFFFE02C,0x7BFA,0xFFFFE804,0x7DBB,0xFFFFEFF6,0x7EFD,0xFFFFF7F7,0x7FBF,0x0000,0x8000,0x0809,0x7FBF,0x100A,0x7EFD,0x17FC,0x7DBB,0x1FD5,0x7BFA,0x278D,0x79BC,0x2F1E,0x7702,0x367F,0x73D1,0x3DAA,0x702A,0x4495,0x6C12,0x4B3C,0x678D,0x5197,0x62A0,0x579F,0x5D4E,0x5D4E,0x579F,0x62A0,0x5197,0x678D,0x4B3C,0x6C13,0x4495,0x702A,0x3DA9,0x73D1,0x367F,0x7702,0x2F1E,0x79BC,0x278D,0x7BFA,0x1FD4,0x7DBB,0x17FB,0x7EFD,0x100A,0x7FBF,0x0809,0x8000,0x0000,0x7FBF,0xFFFFF7F7,0x7EFD,0xFFFFEFF6,0x7DBB,0xFFFFE804,0x7BFA,0xFFFFE02B,0x79BC,0xFFFFD873,0x7702,0xFFFFD0E2,0x73D1,0xFFFFC981,0x702A,0xFFFFC256,0x6C12,0xFFFFBB6B,0x678D,0xFFFFB4C4,0x62A0,0xFFFFAE69,0x5D4E,0xFFFFA861,0x579F,0xFFFFA2B2,0x5197,0xFFFF9D60,0x4B3C,0xFFFF9873,0x4495,0xFFFF93ED,0x3DA9,0xFFFF8FD6,0x367F,0xFFFF8C2F,0x2F1E,0xFFFF88FE,0x278D,0xFFFF8644,0x1FD4,0xFFFF8406,0x17FB,0xFFFF8245,0x100A,0xFFFF8103,0x0809,0xFFFF8041,0x0000,0xFFFF8000,0xFFFFF7F7,0xFFFF8041,0xFFFFEFF5,0xFFFF8103,0xFFFFE804,0xFFFF8245,0xFFFFE02C,0xFFFF8406,0xFFFFD873,0xFFFF8644,0xFFFFD0E2,0xFFFF88FE,0xFFFFC981,0xFFFF8C2F,0xFFFFC256,0xFFFF8FD6,0xFFFFBB6A,0xFFFF93EE,0xFFFFB4C4,0xFFFF9873,0xFFFFAE69,0xFFFF9D60,0xFFFFA861,0xFFFFA2B2,0xFFFFA2B2,0xFFFFA861,0xFFFF9D60,0xFFFFAE69,0xFFFF9873,0xFFFFB4C4,0xFFFF93EE,0xFFFFBB6B,0xFFFF8FD6,0xFFFFC257,0xFFFF8C2F,0xFFFFC981,0xFFFF88FE,0xFFFFD0E2,0xFFFF8644,0xFFFFD873,0xFFFF8406,0xFFFFE02C,0xFFFF8245,0xFFFFE804,0xFFFF8103,0xFFFFEFF6,0xFFFF8041,0xFFFFF7F7,0xFFFF8000,0x0000,0xFFFF8041,0x0809,0xFFFF8103,0x100B,0xFFFF8245,0x17FC,0xFFFF8406,0x1FD5,0xFFFF8644,0x278D,0xFFFF88FE,0x2F1E,0xFFFF8C2F,0x367F,0xFFFF8FD6,0x3DAA,0xFFFF93EE,0x4495,0xFFFF9873,0x4B3C,0xFFFF9D60,0x5197,0xFFFFA2B2,0x579F,0xFFFFA861,0x5D4E,0xFFFFAE69,0x62A0,0xFFFFB4C4,0x678D,0xFFFFBB6B,0x6C12,0xFFFFC256,0x702A,0xFFFFC981,0x73D1,0xFFFFD0E2,0x7702,0xFFFFD873,0x79BC,0xFFFFE02B,0x7BFA,0xFFFFE804,0x7DBB,0xFFFFEFF6,0x7EFD,0xFFFFF7F7,0x7FBF,0x0000,0x8000,0x0809,0x7FBF,0x100A,0x7EFD,0x17FC,0x7DBB,0x1FD5,0x7BFA,0x278D,0x79BC,0x2F1E,0x7702,0x3680,0x73D1,0x3DAA,0x702A,0x4495,0x6C12,0x4B3C,0x678D,0x5197,0x62A0,0x579F,0x5D4E,0x5D4E,0x579F,0x62A0,0x5197,0x678D,0x4B3C,0x6C12,0x4495,0x702A,0x3DAA,0x73D1,0x367F,0x7702,0x2F1E,0x79BC,0x278D,0x7BFA,0x1FD4,0x7DBB,0x17FC,0x7EFD,0x100A,0x7FBF,0x0809
	
