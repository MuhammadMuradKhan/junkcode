	.file	"trampoline.c"
# GNU C (GCC) version 4.5.1 20100924 (Red Hat 4.5.1-4) (x86_64-redhat-linux)
#	compiled by GNU C version 4.5.1 20100924 (Red Hat 4.5.1-4), GMP version 4.3.1, MPFR version 2.4.2, MPC version 0.8.1
# warning: MPFR header version 2.4.2 differs from library version 2.4.1.
# GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
# options passed:  trampoline.c -mtune=generic -march=x86-64 -Os
# -fverbose-asm
# options enabled:  -falign-loops -fargument-alias
# -fasynchronous-unwind-tables -fauto-inc-dec -fbranch-count-reg
# -fcaller-saves -fcommon -fcprop-registers -fcrossjumping
# -fcse-follow-jumps -fdefer-pop -fdelete-null-pointer-checks
# -fdwarf2-cfi-asm -fearly-inlining -feliminate-unused-debug-types
# -fexpensive-optimizations -fforward-propagate -ffunction-cse -fgcse
# -fgcse-lm -fguess-branch-probability -fident -fif-conversion
# -fif-conversion2 -findirect-inlining -finline -finline-functions
# -finline-functions-called-once -finline-small-functions -fipa-cp
# -fipa-pure-const -fipa-reference -fipa-sra -fira-share-save-slots
# -fira-share-spill-slots -fivopts -fkeep-static-consts
# -fleading-underscore -fmath-errno -fmerge-constants -fmerge-debug-strings
# -fmove-loop-invariants -fomit-frame-pointer -foptimize-register-move
# -foptimize-sibling-calls -fpeephole -fpeephole2 -freg-struct-return
# -fregmove -freorder-blocks -freorder-functions -frerun-cse-after-loop
# -fsched-critical-path-heuristic -fsched-dep-count-heuristic
# -fsched-group-heuristic -fsched-interblock -fsched-last-insn-heuristic
# -fsched-rank-heuristic -fsched-spec -fsched-spec-insn-heuristic
# -fsched-stalled-insns-dep -fschedule-insns2 -fshow-column -fsigned-zeros
# -fsplit-ivs-in-unroller -fsplit-wide-types -fstrict-aliasing
# -fstrict-overflow -fthread-jumps -ftoplevel-reorder -ftrapping-math
# -ftree-builtin-call-dce -ftree-ccp -ftree-ch -ftree-copy-prop
# -ftree-copyrename -ftree-cselim -ftree-dce -ftree-dominator-opts
# -ftree-dse -ftree-forwprop -ftree-fre -ftree-loop-im -ftree-loop-ivcanon
# -ftree-loop-optimize -ftree-parallelize-loops= -ftree-phiprop -ftree-pre
# -ftree-pta -ftree-reassoc -ftree-scev-cprop -ftree-sink
# -ftree-slp-vectorize -ftree-sra -ftree-switch-conversion -ftree-ter
# -ftree-vect-loop-version -ftree-vrp -funit-at-a-time -funwind-tables
# -fvect-cost-model -fverbose-asm -fzero-initialized-in-bss
# -m128bit-long-double -m64 -m80387 -maccumulate-outgoing-args
# -malign-stringops -mfancy-math-387 -mfp-ret-in-387 -mfused-madd -mglibc
# -mieee-fp -mmmx -mno-sse4 -mpush-args -mred-zone -msse -msse2
# -mtls-direct-seg-refs

# Compiler executable checksum: ea394b69293dd698607206e8e43d607e

	.text
	.type	localfn.2072, @function
localfn.2072:
.LFB1:
	.cfi_startproc
	movl	(%r10), %eax	# CHAIN.1_1(D)->ac, tmp63
	addl	%edi, %eax	# a, tmp63
	ret
	.cfi_endproc
.LFE1:
	.size	localfn.2072, .-localfn.2072
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"%d\n"
	.text
.globl main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	subq	$40, %rsp	#,
	.cfi_def_cfa_offset 48
	movl	$localfn.2072, %ecx	#, tmp67
	leaq	4(%rsp), %rax	#, tmp65
	movl	%edi, (%rsp)	# ac, FRAME.0.ac
	movw	$-17599, 4(%rsp)	#, FRAME.0.localfn
	orl	$-1, %edi	#,
	movl	%ecx, 2(%rax)	# tmp67, FRAME.0.localfn
	movq	%rsp, 8(%rax)	# tmp64, FRAME.0.localfn
	movw	$-17847, 6(%rax)	#, FRAME.0.localfn
	movl	$-1864106167, 16(%rax)	#, FRAME.0.localfn
	call	*%rax	# tmp65
	movl	$.LC0, %edi	#,
	movl	%eax, %esi	# D.3282,
	xorl	%eax, %eax	#
	call	printf	#
	xorl	%eax, %eax	#
	addq	$40, %rsp	#,
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (GNU) 4.5.1 20100924 (Red Hat 4.5.1-4)"
	.section	.note.GNU-stack,"x",@progbits
