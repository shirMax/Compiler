%define T_void 				0
%define T_nil 				1
%define T_char 				2
%define T_string 			3
%define T_symbol 			4
%define T_closure 			5
%define T_boolean 			8
%define T_boolean_false 		(T_boolean | 1)
%define T_boolean_true 			(T_boolean | 2)
%define T_number 			16
%define T_rational 			(T_number | 1)
%define T_real 				(T_number | 2)
%define T_collection 			32
%define T_pair 				(T_collection | 1)
%define T_vector 			(T_collection | 2)

%define SOB_CHAR_VALUE(reg) 		byte [reg + 1]
%define SOB_PAIR_CAR(reg)		qword [reg + 1]
%define SOB_PAIR_CDR(reg)		qword [reg + 1 + 8]
%define SOB_STRING_LENGTH(reg)		qword [reg + 1]
%define SOB_VECTOR_LENGTH(reg)		qword [reg + 1]
%define SOB_CLOSURE_ENV(reg)		qword [reg + 1]
%define SOB_CLOSURE_CODE(reg)		qword [reg + 1 + 8]

%define OLD_RDP 			qword [rbp]
%define RET_ADDR 			qword [rbp + 8 * 1]
%define ENV 				qword [rbp + 8 * 2]
%define COUNT 				qword [rbp + 8 * 3]
%define PARAM(n) 			qword [rbp + 8 * (4 + n)]
%define AND_KILL_FRAME(n)		(8 * (2 + n))

%macro ENTER 0
	enter 0, 0
	and rsp, ~15
%endmacro

%macro LEAVE 0
	leave
%endmacro

%macro assert_type 2
        cmp byte [%1], %2
        jne L_error_incorrect_type
%endmacro

%macro assert_type_integer 1
        assert_rational(%1)
        cmp qword [%1 + 1 + 8], 1
        jne L_error_incorrect_type
%endmacro

%define assert_void(reg)		assert_type reg, T_void
%define assert_nil(reg)			assert_type reg, T_nil
%define assert_char(reg)		assert_type reg, T_char
%define assert_string(reg)		assert_type reg, T_string
%define assert_symbol(reg)		assert_type reg, T_symbol
%define assert_closure(reg)		assert_type reg, T_closure
%define assert_boolean(reg)		assert_type reg, T_boolean
%define assert_rational(reg)		assert_type reg, T_rational
%define assert_integer(reg)		assert_type_integer reg
%define assert_real(reg)		assert_type reg, T_real
%define assert_pair(reg)		assert_type reg, T_pair
%define assert_vector(reg)		assert_type reg, T_vector

%define sob_void			(L_constants + 0)
%define sob_nil				(L_constants + 1)
%define sob_boolean_false		(L_constants + 2)
%define sob_boolean_true		(L_constants + 3)
%define sob_char_nul			(L_constants + 4)

%define bytes(n)			(n)
%define kbytes(n) 			(bytes(n) << 10)
%define mbytes(n) 			(kbytes(n) << 10)
%define gbytes(n) 			(mbytes(n) << 10)

section .data
L_constants:
	db T_void
	db T_nil
	db T_boolean_false
	db T_boolean_true
	db T_char, 0x00	; #\x0
	db T_string	; "whatever"
	dq 8
	db 0x77, 0x68, 0x61, 0x74, 0x65, 0x76, 0x65, 0x72
	db T_symbol	; whatever
	dq L_constants + 6
	db T_rational	; 0
	dq 0, 1
	db T_string	; "+"
	dq 1
	db 0x2B
	db T_symbol	; +
	dq L_constants + 49
	db T_string	; "all arguments need ...
	dq 32
	db 0x61, 0x6C, 0x6C, 0x20, 0x61, 0x72, 0x67, 0x75
	db 0x6D, 0x65, 0x6E, 0x74, 0x73, 0x20, 0x6E, 0x65
	db 0x65, 0x64, 0x20, 0x74, 0x6F, 0x20, 0x62, 0x65
	db 0x20, 0x6E, 0x75, 0x6D, 0x62, 0x65, 0x72, 0x73
	db T_string	; "-"
	dq 1
	db 0x2D
	db T_symbol	; -
	dq L_constants + 109
	db T_rational	; 1
	dq 1, 1
	db T_string	; "*"
	dq 1
	db 0x2A
	db T_symbol	; *
	dq L_constants + 145
	db T_string	; "/"
	dq 1
	db 0x2F
	db T_symbol	; /
	dq L_constants + 164
	db T_string	; "generic-comparator"
	dq 18
	db 0x67, 0x65, 0x6E, 0x65, 0x72, 0x69, 0x63, 0x2D
	db 0x63, 0x6F, 0x6D, 0x70, 0x61, 0x72, 0x61, 0x74
	db 0x6F, 0x72
	db T_symbol	; generic-comparator
	dq L_constants + 183
	db T_string	; "all the arguments m...
	dq 33
	db 0x61, 0x6C, 0x6C, 0x20, 0x74, 0x68, 0x65, 0x20
	db 0x61, 0x72, 0x67, 0x75, 0x6D, 0x65, 0x6E, 0x74
	db 0x73, 0x20, 0x6D, 0x75, 0x73, 0x74, 0x20, 0x62
	db 0x65, 0x20, 0x6E, 0x75, 0x6D, 0x62, 0x65, 0x72
	db 0x73
	db T_string	; "make-list"
	dq 9
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x6C, 0x69, 0x73
	db 0x74
	db T_symbol	; make-list
	dq L_constants + 261
	db T_string	; "Usage: (make-list l...
	dq 45
	db 0x55, 0x73, 0x61, 0x67, 0x65, 0x3A, 0x20, 0x28
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x6C, 0x69, 0x73
	db 0x74, 0x20, 0x6C, 0x65, 0x6E, 0x67, 0x74, 0x68
	db 0x20, 0x3F, 0x6F, 0x70, 0x74, 0x69, 0x6F, 0x6E
	db 0x61, 0x6C, 0x2D, 0x69, 0x6E, 0x69, 0x74, 0x2D
	db 0x63, 0x68, 0x61, 0x72, 0x29
	db T_char, 0x41	; #\A
	db T_char, 0x5A	; #\Z
	db T_char, 0x61	; #\a
	db T_char, 0x7A	; #\z
	db T_string	; "make-vector"
	dq 11
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x76, 0x65, 0x63
	db 0x74, 0x6F, 0x72
	db T_symbol	; make-vector
	dq L_constants + 350
	db T_string	; "Usage: (make-vector...
	dq 43
	db 0x55, 0x73, 0x61, 0x67, 0x65, 0x3A, 0x20, 0x28
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x76, 0x65, 0x63
	db 0x74, 0x6F, 0x72, 0x20, 0x73, 0x69, 0x7A, 0x65
	db 0x20, 0x3F, 0x6F, 0x70, 0x74, 0x69, 0x6F, 0x6E
	db 0x61, 0x6C, 0x2D, 0x64, 0x65, 0x66, 0x61, 0x75
	db 0x6C, 0x74, 0x29
	db T_string	; "make-string"
	dq 11
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x73, 0x74, 0x72
	db 0x69, 0x6E, 0x67
	db T_symbol	; make-string
	dq L_constants + 431
	db T_string	; "Usage: (make-string...
	dq 43
	db 0x55, 0x73, 0x61, 0x67, 0x65, 0x3A, 0x20, 0x28
	db 0x6D, 0x61, 0x6B, 0x65, 0x2D, 0x73, 0x74, 0x72
	db 0x69, 0x6E, 0x67, 0x20, 0x73, 0x69, 0x7A, 0x65
	db 0x20, 0x3F, 0x6F, 0x70, 0x74, 0x69, 0x6F, 0x6E
	db 0x61, 0x6C, 0x2D, 0x64, 0x65, 0x66, 0x61, 0x75
	db 0x6C, 0x74, 0x29
	db T_rational	; 2
	dq 2, 1

section .bss
free_var_0:	; location of null?
	resq 1
free_var_1:	; location of pair?
	resq 1
free_var_2:	; location of void?
	resq 1
free_var_3:	; location of char?
	resq 1
free_var_4:	; location of string?
	resq 1
free_var_5:	; location of symbol?
	resq 1
free_var_6:	; location of vector?
	resq 1
free_var_7:	; location of procedure?
	resq 1
free_var_8:	; location of real?
	resq 1
free_var_9:	; location of rational?
	resq 1
free_var_10:	; location of boolean?
	resq 1
free_var_11:	; location of number?
	resq 1
free_var_12:	; location of collection?
	resq 1
free_var_13:	; location of cons
	resq 1
free_var_14:	; location of display-sexpr
	resq 1
free_var_15:	; location of write-char
	resq 1
free_var_16:	; location of car
	resq 1
free_var_17:	; location of cdr
	resq 1
free_var_18:	; location of string-length
	resq 1
free_var_19:	; location of vector-length
	resq 1
free_var_20:	; location of real->integer
	resq 1
free_var_21:	; location of exit
	resq 1
free_var_22:	; location of integer->real
	resq 1
free_var_23:	; location of rational->real
	resq 1
free_var_24:	; location of char->integer
	resq 1
free_var_25:	; location of integer->char
	resq 1
free_var_26:	; location of trng
	resq 1
free_var_27:	; location of zero?
	resq 1
free_var_28:	; location of integer?
	resq 1
free_var_29:	; location of __bin-apply
	resq 1
free_var_30:	; location of __bin-add-rr
	resq 1
free_var_31:	; location of __bin-sub-rr
	resq 1
free_var_32:	; location of __bin-mul-rr
	resq 1
free_var_33:	; location of __bin-div-rr
	resq 1
free_var_34:	; location of __bin-add-qq
	resq 1
free_var_35:	; location of __bin-sub-qq
	resq 1
free_var_36:	; location of __bin-mul-qq
	resq 1
free_var_37:	; location of __bin-div-qq
	resq 1
free_var_38:	; location of error
	resq 1
free_var_39:	; location of __bin-less-than-rr
	resq 1
free_var_40:	; location of __bin-less-than-qq
	resq 1
free_var_41:	; location of __bin-equal-rr
	resq 1
free_var_42:	; location of __bin-equal-qq
	resq 1
free_var_43:	; location of quotient
	resq 1
free_var_44:	; location of remainder
	resq 1
free_var_45:	; location of set-car!
	resq 1
free_var_46:	; location of set-cdr!
	resq 1
free_var_47:	; location of string-ref
	resq 1
free_var_48:	; location of vector-ref
	resq 1
free_var_49:	; location of vector-set!
	resq 1
free_var_50:	; location of string-set!
	resq 1
free_var_51:	; location of make-vector
	resq 1
free_var_52:	; location of make-string
	resq 1
free_var_53:	; location of numerator
	resq 1
free_var_54:	; location of denominator
	resq 1
free_var_55:	; location of eq?
	resq 1
free_var_56:	; location of caar
	resq 1
free_var_57:	; location of cadr
	resq 1
free_var_58:	; location of cdar
	resq 1
free_var_59:	; location of cddr
	resq 1
free_var_60:	; location of caaar
	resq 1
free_var_61:	; location of caadr
	resq 1
free_var_62:	; location of cadar
	resq 1
free_var_63:	; location of caddr
	resq 1
free_var_64:	; location of cdaar
	resq 1
free_var_65:	; location of cdadr
	resq 1
free_var_66:	; location of cddar
	resq 1
free_var_67:	; location of cdddr
	resq 1
free_var_68:	; location of caaaar
	resq 1
free_var_69:	; location of caaadr
	resq 1
free_var_70:	; location of caadar
	resq 1
free_var_71:	; location of caaddr
	resq 1
free_var_72:	; location of cadaar
	resq 1
free_var_73:	; location of cadadr
	resq 1
free_var_74:	; location of caddar
	resq 1
free_var_75:	; location of cadddr
	resq 1
free_var_76:	; location of cdaaar
	resq 1
free_var_77:	; location of cdaadr
	resq 1
free_var_78:	; location of cdadar
	resq 1
free_var_79:	; location of cdaddr
	resq 1
free_var_80:	; location of cddaar
	resq 1
free_var_81:	; location of cddadr
	resq 1
free_var_82:	; location of cdddar
	resq 1
free_var_83:	; location of cddddr
	resq 1
free_var_84:	; location of list?
	resq 1
free_var_85:	; location of list
	resq 1
free_var_86:	; location of not
	resq 1
free_var_87:	; location of fraction?
	resq 1
free_var_88:	; location of list*
	resq 1
free_var_89:	; location of apply
	resq 1
free_var_90:	; location of ormap
	resq 1
free_var_91:	; location of map
	resq 1
free_var_92:	; location of andmap
	resq 1
free_var_93:	; location of reverse
	resq 1
free_var_94:	; location of append
	resq 1
free_var_95:	; location of fold-left
	resq 1
free_var_96:	; location of fold-right
	resq 1
free_var_97:	; location of +
	resq 1
free_var_98:	; location of -
	resq 1
free_var_99:	; location of *
	resq 1
free_var_100:	; location of /
	resq 1
free_var_101:	; location of fact
	resq 1
free_var_102:	; location of <
	resq 1
free_var_103:	; location of <=
	resq 1
free_var_104:	; location of >
	resq 1
free_var_105:	; location of >=
	resq 1
free_var_106:	; location of =
	resq 1
free_var_107:	; location of make-list
	resq 1
free_var_108:	; location of char<?
	resq 1
free_var_109:	; location of char<=?
	resq 1
free_var_110:	; location of char=?
	resq 1
free_var_111:	; location of char>?
	resq 1
free_var_112:	; location of char>=?
	resq 1
free_var_113:	; location of char-downcase
	resq 1
free_var_114:	; location of char-upcase
	resq 1
free_var_115:	; location of char-ci<?
	resq 1
free_var_116:	; location of char-ci<=?
	resq 1
free_var_117:	; location of char-ci=?
	resq 1
free_var_118:	; location of char-ci>?
	resq 1
free_var_119:	; location of char-ci>=?
	resq 1
free_var_120:	; location of string-downcase
	resq 1
free_var_121:	; location of string-upcase
	resq 1
free_var_122:	; location of list->string
	resq 1
free_var_123:	; location of string->list
	resq 1
free_var_124:	; location of string<?
	resq 1
free_var_125:	; location of string<=?
	resq 1
free_var_126:	; location of string=?
	resq 1
free_var_127:	; location of string>=?
	resq 1
free_var_128:	; location of string>?
	resq 1
free_var_129:	; location of string-ci<?
	resq 1
free_var_130:	; location of string-ci<=?
	resq 1
free_var_131:	; location of string-ci=?
	resq 1
free_var_132:	; location of string-ci>=?
	resq 1
free_var_133:	; location of string-ci>?
	resq 1
free_var_134:	; location of length
	resq 1
free_var_135:	; location of list->vector
	resq 1
free_var_136:	; location of vector
	resq 1
free_var_137:	; location of vector->list
	resq 1
free_var_138:	; location of random
	resq 1
free_var_139:	; location of positive?
	resq 1
free_var_140:	; location of negative?
	resq 1
free_var_141:	; location of even?
	resq 1
free_var_142:	; location of odd?
	resq 1
free_var_143:	; location of abs
	resq 1
free_var_144:	; location of equal?
	resq 1
free_var_145:	; location of assoc
	resq 1

extern printf, fprintf, stdout, stderr, fwrite, exit, putchar
global main
section .text
main:
        enter 0, 0
        
	; building closure for null?
	mov rdi, free_var_0
	mov rsi, L_code_ptr_is_null
	call bind_primitive

	; building closure for pair?
	mov rdi, free_var_1
	mov rsi, L_code_ptr_is_pair
	call bind_primitive

	; building closure for void?
	mov rdi, free_var_2
	mov rsi, L_code_ptr_is_void
	call bind_primitive

	; building closure for char?
	mov rdi, free_var_3
	mov rsi, L_code_ptr_is_char
	call bind_primitive

	; building closure for string?
	mov rdi, free_var_4
	mov rsi, L_code_ptr_is_string
	call bind_primitive

	; building closure for symbol?
	mov rdi, free_var_5
	mov rsi, L_code_ptr_is_symbol
	call bind_primitive

	; building closure for vector?
	mov rdi, free_var_6
	mov rsi, L_code_ptr_is_vector
	call bind_primitive

	; building closure for procedure?
	mov rdi, free_var_7
	mov rsi, L_code_ptr_is_closure
	call bind_primitive

	; building closure for real?
	mov rdi, free_var_8
	mov rsi, L_code_ptr_is_real
	call bind_primitive

	; building closure for rational?
	mov rdi, free_var_9
	mov rsi, L_code_ptr_is_rational
	call bind_primitive

	; building closure for boolean?
	mov rdi, free_var_10
	mov rsi, L_code_ptr_is_boolean
	call bind_primitive

	; building closure for number?
	mov rdi, free_var_11
	mov rsi, L_code_ptr_is_number
	call bind_primitive

	; building closure for collection?
	mov rdi, free_var_12
	mov rsi, L_code_ptr_is_collection
	call bind_primitive

	; building closure for cons
	mov rdi, free_var_13
	mov rsi, L_code_ptr_cons
	call bind_primitive

	; building closure for display-sexpr
	mov rdi, free_var_14
	mov rsi, L_code_ptr_display_sexpr
	call bind_primitive

	; building closure for write-char
	mov rdi, free_var_15
	mov rsi, L_code_ptr_write_char
	call bind_primitive

	; building closure for car
	mov rdi, free_var_16
	mov rsi, L_code_ptr_car
	call bind_primitive

	; building closure for cdr
	mov rdi, free_var_17
	mov rsi, L_code_ptr_cdr
	call bind_primitive

	; building closure for string-length
	mov rdi, free_var_18
	mov rsi, L_code_ptr_string_length
	call bind_primitive

	; building closure for vector-length
	mov rdi, free_var_19
	mov rsi, L_code_ptr_vector_length
	call bind_primitive

	; building closure for real->integer
	mov rdi, free_var_20
	mov rsi, L_code_ptr_real_to_integer
	call bind_primitive

	; building closure for exit
	mov rdi, free_var_21
	mov rsi, L_code_ptr_exit
	call bind_primitive

	; building closure for integer->real
	mov rdi, free_var_22
	mov rsi, L_code_ptr_integer_to_real
	call bind_primitive

	; building closure for rational->real
	mov rdi, free_var_23
	mov rsi, L_code_ptr_rational_to_real
	call bind_primitive

	; building closure for char->integer
	mov rdi, free_var_24
	mov rsi, L_code_ptr_char_to_integer
	call bind_primitive

	; building closure for integer->char
	mov rdi, free_var_25
	mov rsi, L_code_ptr_integer_to_char
	call bind_primitive

	; building closure for trng
	mov rdi, free_var_26
	mov rsi, L_code_ptr_trng
	call bind_primitive

	; building closure for zero?
	mov rdi, free_var_27
	mov rsi, L_code_ptr_is_zero
	call bind_primitive

	; building closure for integer?
	mov rdi, free_var_28
	mov rsi, L_code_ptr_is_integer
	call bind_primitive

	; building closure for __bin-apply
	mov rdi, free_var_29
	mov rsi, L_code_ptr_bin_apply
	call bind_primitive

	; building closure for __bin-add-rr
	mov rdi, free_var_30
	mov rsi, L_code_ptr_raw_bin_add_rr
	call bind_primitive

	; building closure for __bin-sub-rr
	mov rdi, free_var_31
	mov rsi, L_code_ptr_raw_bin_sub_rr
	call bind_primitive

	; building closure for __bin-mul-rr
	mov rdi, free_var_32
	mov rsi, L_code_ptr_raw_bin_mul_rr
	call bind_primitive

	; building closure for __bin-div-rr
	mov rdi, free_var_33
	mov rsi, L_code_ptr_raw_bin_div_rr
	call bind_primitive

	; building closure for __bin-add-qq
	mov rdi, free_var_34
	mov rsi, L_code_ptr_raw_bin_add_qq
	call bind_primitive

	; building closure for __bin-sub-qq
	mov rdi, free_var_35
	mov rsi, L_code_ptr_raw_bin_sub_qq
	call bind_primitive

	; building closure for __bin-mul-qq
	mov rdi, free_var_36
	mov rsi, L_code_ptr_raw_bin_mul_qq
	call bind_primitive

	; building closure for __bin-div-qq
	mov rdi, free_var_37
	mov rsi, L_code_ptr_raw_bin_div_qq
	call bind_primitive

	; building closure for error
	mov rdi, free_var_38
	mov rsi, L_code_ptr_error
	call bind_primitive

	; building closure for __bin-less-than-rr
	mov rdi, free_var_39
	mov rsi, L_code_ptr_raw_less_than_rr
	call bind_primitive

	; building closure for __bin-less-than-qq
	mov rdi, free_var_40
	mov rsi, L_code_ptr_raw_less_than_qq
	call bind_primitive

	; building closure for __bin-equal-rr
	mov rdi, free_var_41
	mov rsi, L_code_ptr_raw_equal_rr
	call bind_primitive

	; building closure for __bin-equal-qq
	mov rdi, free_var_42
	mov rsi, L_code_ptr_raw_equal_qq
	call bind_primitive

	; building closure for quotient
	mov rdi, free_var_43
	mov rsi, L_code_ptr_quotient
	call bind_primitive

	; building closure for remainder
	mov rdi, free_var_44
	mov rsi, L_code_ptr_remainder
	call bind_primitive

	; building closure for set-car!
	mov rdi, free_var_45
	mov rsi, L_code_ptr_set_car
	call bind_primitive

	; building closure for set-cdr!
	mov rdi, free_var_46
	mov rsi, L_code_ptr_set_cdr
	call bind_primitive

	; building closure for string-ref
	mov rdi, free_var_47
	mov rsi, L_code_ptr_string_ref
	call bind_primitive

	; building closure for vector-ref
	mov rdi, free_var_48
	mov rsi, L_code_ptr_vector_ref
	call bind_primitive

	; building closure for vector-set!
	mov rdi, free_var_49
	mov rsi, L_code_ptr_vector_set
	call bind_primitive

	; building closure for string-set!
	mov rdi, free_var_50
	mov rsi, L_code_ptr_string_set
	call bind_primitive

	; building closure for make-vector
	mov rdi, free_var_51
	mov rsi, L_code_ptr_make_vector
	call bind_primitive

	; building closure for make-string
	mov rdi, free_var_52
	mov rsi, L_code_ptr_make_string
	call bind_primitive

	; building closure for numerator
	mov rdi, free_var_53
	mov rsi, L_code_ptr_numerator
	call bind_primitive

	; building closure for denominator
	mov rdi, free_var_54
	mov rsi, L_code_ptr_denominator
	call bind_primitive

	; building closure for eq?
	mov rdi, free_var_55
	mov rsi, L_code_ptr_eq
	call bind_primitive

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47b4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47b4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47b4
.L_lambda_simple_env_end_47b4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47b4:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47b4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47b4
.L_lambda_simple_params_end_47b4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47b4
	jmp .L_lambda_simple_end_47b4
.L_lambda_simple_code_47b4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47b4
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47b4:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5314:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5314
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5314
.L_tc_recycle_frame_done_5314:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47b4:	; new closure is in rax
	mov qword [free_var_56], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47b5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47b5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47b5
.L_lambda_simple_env_end_47b5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47b5:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47b5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47b5
.L_lambda_simple_params_end_47b5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47b5
	jmp .L_lambda_simple_end_47b5
.L_lambda_simple_code_47b5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47b5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47b5:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5315:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5315
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5315
.L_tc_recycle_frame_done_5315:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47b5:	; new closure is in rax
	mov qword [free_var_57], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47b6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47b6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47b6
.L_lambda_simple_env_end_47b6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47b6:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47b6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47b6
.L_lambda_simple_params_end_47b6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47b6
	jmp .L_lambda_simple_end_47b6
.L_lambda_simple_code_47b6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47b6
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47b6:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5316:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5316
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5316
.L_tc_recycle_frame_done_5316:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47b6:	; new closure is in rax
	mov qword [free_var_58], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47b7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47b7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47b7
.L_lambda_simple_env_end_47b7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47b7:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47b7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47b7
.L_lambda_simple_params_end_47b7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47b7
	jmp .L_lambda_simple_end_47b7
.L_lambda_simple_code_47b7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47b7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47b7:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5317:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5317
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5317
.L_tc_recycle_frame_done_5317:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47b7:	; new closure is in rax
	mov qword [free_var_59], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47b8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47b8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47b8
.L_lambda_simple_env_end_47b8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47b8:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47b8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47b8
.L_lambda_simple_params_end_47b8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47b8
	jmp .L_lambda_simple_end_47b8
.L_lambda_simple_code_47b8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47b8
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47b8:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5318:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5318
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5318
.L_tc_recycle_frame_done_5318:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47b8:	; new closure is in rax
	mov qword [free_var_60], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47b9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47b9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47b9
.L_lambda_simple_env_end_47b9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47b9:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47b9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47b9
.L_lambda_simple_params_end_47b9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47b9
	jmp .L_lambda_simple_end_47b9
.L_lambda_simple_code_47b9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47b9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47b9:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5319:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5319
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5319
.L_tc_recycle_frame_done_5319:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47b9:	; new closure is in rax
	mov qword [free_var_61], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47ba:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47ba
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47ba
.L_lambda_simple_env_end_47ba:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47ba:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47ba
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47ba
.L_lambda_simple_params_end_47ba:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47ba
	jmp .L_lambda_simple_end_47ba
.L_lambda_simple_code_47ba:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47ba
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47ba:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_531a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_531a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_531a
.L_tc_recycle_frame_done_531a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47ba:	; new closure is in rax
	mov qword [free_var_62], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47bb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47bb
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47bb
.L_lambda_simple_env_end_47bb:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47bb:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47bb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47bb
.L_lambda_simple_params_end_47bb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47bb
	jmp .L_lambda_simple_end_47bb
.L_lambda_simple_code_47bb:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47bb
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47bb:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_531b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_531b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_531b
.L_tc_recycle_frame_done_531b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47bb:	; new closure is in rax
	mov qword [free_var_63], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47bc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47bc
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47bc
.L_lambda_simple_env_end_47bc:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47bc:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47bc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47bc
.L_lambda_simple_params_end_47bc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47bc
	jmp .L_lambda_simple_end_47bc
.L_lambda_simple_code_47bc:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47bc
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47bc:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_531c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_531c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_531c
.L_tc_recycle_frame_done_531c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47bc:	; new closure is in rax
	mov qword [free_var_64], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47bd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47bd
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47bd
.L_lambda_simple_env_end_47bd:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47bd:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47bd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47bd
.L_lambda_simple_params_end_47bd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47bd
	jmp .L_lambda_simple_end_47bd
.L_lambda_simple_code_47bd:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47bd
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47bd:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_531d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_531d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_531d
.L_tc_recycle_frame_done_531d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47bd:	; new closure is in rax
	mov qword [free_var_65], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47be:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47be
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47be
.L_lambda_simple_env_end_47be:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47be:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47be
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47be
.L_lambda_simple_params_end_47be:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47be
	jmp .L_lambda_simple_end_47be
.L_lambda_simple_code_47be:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47be
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47be:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_531e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_531e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_531e
.L_tc_recycle_frame_done_531e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47be:	; new closure is in rax
	mov qword [free_var_66], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47bf:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47bf
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47bf
.L_lambda_simple_env_end_47bf:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47bf:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47bf
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47bf
.L_lambda_simple_params_end_47bf:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47bf
	jmp .L_lambda_simple_end_47bf
.L_lambda_simple_code_47bf:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47bf
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47bf:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_531f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_531f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_531f
.L_tc_recycle_frame_done_531f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47bf:	; new closure is in rax
	mov qword [free_var_67], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47c0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47c0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47c0
.L_lambda_simple_env_end_47c0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47c0:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47c0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47c0
.L_lambda_simple_params_end_47c0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47c0
	jmp .L_lambda_simple_end_47c0
.L_lambda_simple_code_47c0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47c0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47c0:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5320:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5320
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5320
.L_tc_recycle_frame_done_5320:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47c0:	; new closure is in rax
	mov qword [free_var_68], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47c1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47c1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47c1
.L_lambda_simple_env_end_47c1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47c1:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47c1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47c1
.L_lambda_simple_params_end_47c1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47c1
	jmp .L_lambda_simple_end_47c1
.L_lambda_simple_code_47c1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47c1
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47c1:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5321:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5321
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5321
.L_tc_recycle_frame_done_5321:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47c1:	; new closure is in rax
	mov qword [free_var_69], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47c2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47c2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47c2
.L_lambda_simple_env_end_47c2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47c2:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47c2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47c2
.L_lambda_simple_params_end_47c2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47c2
	jmp .L_lambda_simple_end_47c2
.L_lambda_simple_code_47c2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47c2
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47c2:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5322:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5322
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5322
.L_tc_recycle_frame_done_5322:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47c2:	; new closure is in rax
	mov qword [free_var_70], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47c3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47c3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47c3
.L_lambda_simple_env_end_47c3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47c3:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47c3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47c3
.L_lambda_simple_params_end_47c3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47c3
	jmp .L_lambda_simple_end_47c3
.L_lambda_simple_code_47c3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47c3
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47c3:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5323:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5323
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5323
.L_tc_recycle_frame_done_5323:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47c3:	; new closure is in rax
	mov qword [free_var_71], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47c4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47c4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47c4
.L_lambda_simple_env_end_47c4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47c4:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47c4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47c4
.L_lambda_simple_params_end_47c4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47c4
	jmp .L_lambda_simple_end_47c4
.L_lambda_simple_code_47c4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47c4
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47c4:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5324:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5324
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5324
.L_tc_recycle_frame_done_5324:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47c4:	; new closure is in rax
	mov qword [free_var_72], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47c5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47c5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47c5
.L_lambda_simple_env_end_47c5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47c5:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47c5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47c5
.L_lambda_simple_params_end_47c5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47c5
	jmp .L_lambda_simple_end_47c5
.L_lambda_simple_code_47c5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47c5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47c5:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5325:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5325
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5325
.L_tc_recycle_frame_done_5325:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47c5:	; new closure is in rax
	mov qword [free_var_73], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47c6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47c6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47c6
.L_lambda_simple_env_end_47c6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47c6:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47c6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47c6
.L_lambda_simple_params_end_47c6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47c6
	jmp .L_lambda_simple_end_47c6
.L_lambda_simple_code_47c6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47c6
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47c6:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5326:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5326
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5326
.L_tc_recycle_frame_done_5326:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47c6:	; new closure is in rax
	mov qword [free_var_74], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47c7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47c7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47c7
.L_lambda_simple_env_end_47c7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47c7:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47c7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47c7
.L_lambda_simple_params_end_47c7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47c7
	jmp .L_lambda_simple_end_47c7
.L_lambda_simple_code_47c7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47c7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47c7:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5327:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5327
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5327
.L_tc_recycle_frame_done_5327:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47c7:	; new closure is in rax
	mov qword [free_var_75], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47c8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47c8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47c8
.L_lambda_simple_env_end_47c8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47c8:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47c8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47c8
.L_lambda_simple_params_end_47c8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47c8
	jmp .L_lambda_simple_end_47c8
.L_lambda_simple_code_47c8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47c8
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47c8:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5328:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5328
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5328
.L_tc_recycle_frame_done_5328:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47c8:	; new closure is in rax
	mov qword [free_var_76], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47c9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47c9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47c9
.L_lambda_simple_env_end_47c9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47c9:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47c9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47c9
.L_lambda_simple_params_end_47c9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47c9
	jmp .L_lambda_simple_end_47c9
.L_lambda_simple_code_47c9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47c9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47c9:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5329:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5329
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5329
.L_tc_recycle_frame_done_5329:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47c9:	; new closure is in rax
	mov qword [free_var_77], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47ca:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47ca
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47ca
.L_lambda_simple_env_end_47ca:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47ca:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47ca
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47ca
.L_lambda_simple_params_end_47ca:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47ca
	jmp .L_lambda_simple_end_47ca
.L_lambda_simple_code_47ca:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47ca
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47ca:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_532a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_532a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_532a
.L_tc_recycle_frame_done_532a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47ca:	; new closure is in rax
	mov qword [free_var_78], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47cb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47cb
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47cb
.L_lambda_simple_env_end_47cb:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47cb:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47cb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47cb
.L_lambda_simple_params_end_47cb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47cb
	jmp .L_lambda_simple_end_47cb
.L_lambda_simple_code_47cb:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47cb
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47cb:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_532b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_532b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_532b
.L_tc_recycle_frame_done_532b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47cb:	; new closure is in rax
	mov qword [free_var_79], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47cc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47cc
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47cc
.L_lambda_simple_env_end_47cc:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47cc:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47cc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47cc
.L_lambda_simple_params_end_47cc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47cc
	jmp .L_lambda_simple_end_47cc
.L_lambda_simple_code_47cc:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47cc
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47cc:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_532c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_532c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_532c
.L_tc_recycle_frame_done_532c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47cc:	; new closure is in rax
	mov qword [free_var_80], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47cd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47cd
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47cd
.L_lambda_simple_env_end_47cd:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47cd:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47cd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47cd
.L_lambda_simple_params_end_47cd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47cd
	jmp .L_lambda_simple_end_47cd
.L_lambda_simple_code_47cd:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47cd
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47cd:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_57]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_532d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_532d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_532d
.L_tc_recycle_frame_done_532d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47cd:	; new closure is in rax
	mov qword [free_var_81], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47ce:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47ce
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47ce
.L_lambda_simple_env_end_47ce:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47ce:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47ce
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47ce
.L_lambda_simple_params_end_47ce:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47ce
	jmp .L_lambda_simple_end_47ce
.L_lambda_simple_code_47ce:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47ce
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47ce:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_58]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_532e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_532e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_532e
.L_tc_recycle_frame_done_532e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47ce:	; new closure is in rax
	mov qword [free_var_82], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47cf:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47cf
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47cf
.L_lambda_simple_env_end_47cf:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47cf:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47cf
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47cf
.L_lambda_simple_params_end_47cf:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47cf
	jmp .L_lambda_simple_end_47cf
.L_lambda_simple_code_47cf:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47cf
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47cf:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_59]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_532f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_532f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_532f
.L_tc_recycle_frame_done_532f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47cf:	; new closure is in rax
	mov qword [free_var_83], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47d0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47d0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47d0
.L_lambda_simple_env_end_47d0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47d0:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47d0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47d0
.L_lambda_simple_params_end_47d0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47d0
	jmp .L_lambda_simple_end_47d0
.L_lambda_simple_code_47d0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47d0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47d0:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0568
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51b1
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_84]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5330:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5330
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5330
.L_tc_recycle_frame_done_5330:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51b1
          .L_if_else_51b1:
          	mov rax, L_constants + 2
.L_if_end_51b1:
.L_or_end_0568:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47d0:	; new closure is in rax
	mov qword [free_var_84], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0aed:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_0aed
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0aed
.L_lambda_opt_env_end_0aed:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0aed:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_0aed
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0aed
.L_lambda_opt_params_end_0aed:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0aed
	jmp .L_lambda_opt_end_0aed
.L_lambda_opt_code_0aed:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0aed
	jg .L_lambda_opt_arity_check_more_0aed
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0aed:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20c5:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20c5
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20c5
.L_lambda_opt_stack_shrink_loop_exit_20c5:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0aed
.L_lambda_opt_arity_check_more_0aed:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20c6:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20c6
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20c6
.L_lambda_opt_stack_shrink_loop_exit_20c6:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_20c7:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20c7
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20c7
.L_lambda_opt_stack_shrink_loop_exit_20c7:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0aed:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0aed:	; new closure is in rax
	mov qword [free_var_85], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47d1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47d1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47d1
.L_lambda_simple_env_end_47d1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47d1:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47d1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47d1
.L_lambda_simple_params_end_47d1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47d1
	jmp .L_lambda_simple_end_47d1
.L_lambda_simple_code_47d1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47d1
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47d1:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	cmp rax, sob_boolean_false
          	je .L_if_else_51b2
          	mov rax, L_constants + 2
	jmp .L_if_end_51b2
          .L_if_else_51b2:
          	mov rax, L_constants + 3
.L_if_end_51b2:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47d1:	; new closure is in rax
	mov qword [free_var_86], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47d2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47d2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47d2
.L_lambda_simple_env_end_47d2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47d2:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47d2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47d2
.L_lambda_simple_params_end_47d2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47d2
	jmp .L_lambda_simple_end_47d2
.L_lambda_simple_code_47d2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47d2
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47d2:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51b3
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_28]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_86]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5331:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5331
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5331
.L_tc_recycle_frame_done_5331:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51b3
          .L_if_else_51b3:
          	mov rax, L_constants + 2
.L_if_end_51b3:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47d2:	; new closure is in rax
	mov qword [free_var_87], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47d3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47d3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47d3
.L_lambda_simple_env_end_47d3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47d3:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47d3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47d3
.L_lambda_simple_params_end_47d3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47d3
	jmp .L_lambda_simple_end_47d3
.L_lambda_simple_code_47d3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47d3
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47d3:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47d4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47d4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47d4
.L_lambda_simple_env_end_47d4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47d4:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47d4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47d4
.L_lambda_simple_params_end_47d4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47d4
	jmp .L_lambda_simple_end_47d4
.L_lambda_simple_code_47d4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_47d4
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47d4:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51b4
          	mov rax, qword [rbp + 8 * (4 + 0)]
	jmp .L_if_end_51b4
          .L_if_else_51b4:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5332:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5332
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5332
.L_tc_recycle_frame_done_5332:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51b4:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_47d4:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0aee:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0aee
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0aee
.L_lambda_opt_env_end_0aee:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0aee:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0aee
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0aee
.L_lambda_opt_params_end_0aee:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0aee
	jmp .L_lambda_opt_end_0aee
.L_lambda_opt_code_0aee:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0aee
	jg .L_lambda_opt_arity_check_more_0aee
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0aee:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20c8:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20c8
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20c8
.L_lambda_opt_stack_shrink_loop_exit_20c8:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0aee
.L_lambda_opt_arity_check_more_0aee:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20c9:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20c9
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20c9
.L_lambda_opt_stack_shrink_loop_exit_20c9:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_20ca:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20ca
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20ca
.L_lambda_opt_stack_shrink_loop_exit_20ca:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0aee:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5333:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5333
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5333
.L_tc_recycle_frame_done_5333:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0aee:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47d3:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_88], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47d5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47d5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47d5
.L_lambda_simple_env_end_47d5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47d5:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47d5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47d5
.L_lambda_simple_params_end_47d5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47d5
	jmp .L_lambda_simple_end_47d5
.L_lambda_simple_code_47d5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47d5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47d5:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47d6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47d6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47d6
.L_lambda_simple_env_end_47d6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47d6:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47d6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47d6
.L_lambda_simple_params_end_47d6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47d6
	jmp .L_lambda_simple_end_47d6
.L_lambda_simple_code_47d6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_47d6
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47d6:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51b5
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5334:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5334
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5334
.L_tc_recycle_frame_done_5334:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51b5
          .L_if_else_51b5:
          	mov rax, qword [rbp + 8 * (4 + 0)]
.L_if_end_51b5:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_47d6:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0aef:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0aef
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0aef
.L_lambda_opt_env_end_0aef:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0aef:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0aef
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0aef
.L_lambda_opt_params_end_0aef:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0aef
	jmp .L_lambda_opt_end_0aef
.L_lambda_opt_code_0aef:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0aef
	jg .L_lambda_opt_arity_check_more_0aef
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0aef:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20cb:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20cb
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20cb
.L_lambda_opt_stack_shrink_loop_exit_20cb:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0aef
.L_lambda_opt_arity_check_more_0aef:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20cc:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20cc
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20cc
.L_lambda_opt_stack_shrink_loop_exit_20cc:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_20cd:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20cd
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20cd
.L_lambda_opt_stack_shrink_loop_exit_20cd:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0aef:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_29]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5335:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5335
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5335
.L_tc_recycle_frame_done_5335:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0aef:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47d5:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_89], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0af0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_0af0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0af0
.L_lambda_opt_env_end_0af0:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0af0:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_0af0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0af0
.L_lambda_opt_params_end_0af0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0af0
	jmp .L_lambda_opt_end_0af0
.L_lambda_opt_code_0af0:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0af0
	jg .L_lambda_opt_arity_check_more_0af0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0af0:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20ce:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20ce
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20ce
.L_lambda_opt_stack_shrink_loop_exit_20ce:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0af0
.L_lambda_opt_arity_check_more_0af0:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20cf:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20cf
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20cf
.L_lambda_opt_stack_shrink_loop_exit_20cf:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_20d0:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20d0
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20d0
.L_lambda_opt_stack_shrink_loop_exit_20d0:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0af0:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47d7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47d7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47d7
.L_lambda_simple_env_end_47d7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47d7:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_47d7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47d7
.L_lambda_simple_params_end_47d7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47d7
	jmp .L_lambda_simple_end_47d7
.L_lambda_simple_code_47d7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47d7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47d7:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47d8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_47d8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47d8
.L_lambda_simple_env_end_47d8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47d8:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47d8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47d8
.L_lambda_simple_params_end_47d8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47d8
	jmp .L_lambda_simple_end_47d8
.L_lambda_simple_code_47d8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47d8
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47d8:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51b6
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0569
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5337:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5337
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5337
.L_tc_recycle_frame_done_5337:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_or_end_0569:
	jmp .L_if_end_51b6
          .L_if_else_51b6:
          	mov rax, L_constants + 2
.L_if_end_51b6:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47d8:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5338:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5338
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5338
.L_tc_recycle_frame_done_5338:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47d7:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5336:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5336
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5336
.L_tc_recycle_frame_done_5336:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0af0:	; new closure is in rax
	mov qword [free_var_90], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0af1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_0af1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0af1
.L_lambda_opt_env_end_0af1:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0af1:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_0af1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0af1
.L_lambda_opt_params_end_0af1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0af1
	jmp .L_lambda_opt_end_0af1
.L_lambda_opt_code_0af1:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0af1
	jg .L_lambda_opt_arity_check_more_0af1
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0af1:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20d1:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20d1
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20d1
.L_lambda_opt_stack_shrink_loop_exit_20d1:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0af1
.L_lambda_opt_arity_check_more_0af1:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20d2:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20d2
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20d2
.L_lambda_opt_stack_shrink_loop_exit_20d2:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_20d3:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20d3
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20d3
.L_lambda_opt_stack_shrink_loop_exit_20d3:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0af1:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47d9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47d9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47d9
.L_lambda_simple_env_end_47d9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47d9:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_47d9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47d9
.L_lambda_simple_params_end_47d9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47d9
	jmp .L_lambda_simple_end_47d9
.L_lambda_simple_code_47d9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47d9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47d9:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47da:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_47da
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47da
.L_lambda_simple_env_end_47da:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47da:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47da
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47da
.L_lambda_simple_params_end_47da:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47da
	jmp .L_lambda_simple_end_47da
.L_lambda_simple_code_47da:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47da
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47da:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_056a
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51b7
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_533a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_533a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_533a
.L_tc_recycle_frame_done_533a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51b7
          .L_if_else_51b7:
          	mov rax, L_constants + 2
.L_if_end_51b7:
.L_or_end_056a:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47da:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_533b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_533b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_533b
.L_tc_recycle_frame_done_533b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47d9:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5339:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5339
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5339
.L_tc_recycle_frame_done_5339:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0af1:	; new closure is in rax
	mov qword [free_var_92], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	mov rax, L_constants + 23
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47db:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47db
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47db
.L_lambda_simple_env_end_47db:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47db:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47db
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47db
.L_lambda_simple_params_end_47db:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47db
	jmp .L_lambda_simple_end_47db
.L_lambda_simple_code_47db:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_47db
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47db:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8 * (4 + 1)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 1)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47dc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47dc
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47dc
.L_lambda_simple_env_end_47dc:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47dc:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_47dc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47dc
.L_lambda_simple_params_end_47dc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47dc
	jmp .L_lambda_simple_end_47dc
.L_lambda_simple_code_47dc:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_47dc
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47dc:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51b8
          	mov rax, L_constants + 1
	jmp .L_if_end_51b8
          .L_if_else_51b8:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_533c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_533c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_533c
.L_tc_recycle_frame_done_533c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51b8:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_47dc:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47dd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47dd
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47dd
.L_lambda_simple_env_end_47dd:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47dd:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_47dd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47dd
.L_lambda_simple_params_end_47dd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47dd
	jmp .L_lambda_simple_end_47dd
.L_lambda_simple_code_47dd:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_47dd
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47dd:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51b9
          	mov rax, L_constants + 1
	jmp .L_if_end_51b9
          .L_if_else_51b9:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_533d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_533d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_533d
.L_tc_recycle_frame_done_533d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51b9:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_47dd:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0af2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0af2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0af2
.L_lambda_opt_env_end_0af2:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0af2:	; copy params
	cmp rsi, 2
	je .L_lambda_opt_params_end_0af2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0af2
.L_lambda_opt_params_end_0af2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0af2
	jmp .L_lambda_opt_end_0af2
.L_lambda_opt_code_0af2:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0af2
	jg .L_lambda_opt_arity_check_more_0af2
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0af2:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20d4:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20d4
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20d4
.L_lambda_opt_stack_shrink_loop_exit_20d4:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0af2
.L_lambda_opt_arity_check_more_0af2:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20d5:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20d5
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20d5
.L_lambda_opt_stack_shrink_loop_exit_20d5:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_20d6:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20d6
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20d6
.L_lambda_opt_stack_shrink_loop_exit_20d6:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0af2:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51ba
          	mov rax, L_constants + 1
	jmp .L_if_end_51ba
          .L_if_else_51ba:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_533e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_533e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_533e
.L_tc_recycle_frame_done_533e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51ba:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0af2:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_47db:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_91], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47de:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47de
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47de
.L_lambda_simple_env_end_47de:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47de:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47de
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47de
.L_lambda_simple_params_end_47de:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47de
	jmp .L_lambda_simple_end_47de
.L_lambda_simple_code_47de:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47de
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47de:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47df:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47df
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47df
.L_lambda_simple_env_end_47df:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47df:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47df
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47df
.L_lambda_simple_params_end_47df:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47df
	jmp .L_lambda_simple_end_47df
.L_lambda_simple_code_47df:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_47df
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47df:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51bb
          	mov rax, qword [rbp + 8 * (4 + 1)]
	jmp .L_if_end_51bb
          .L_if_else_51bb:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_533f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_533f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_533f
.L_tc_recycle_frame_done_533f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51bb:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_47df:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47e0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47e0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47e0
.L_lambda_simple_env_end_47e0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47e0:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47e0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47e0
.L_lambda_simple_params_end_47e0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47e0
	jmp .L_lambda_simple_end_47e0
.L_lambda_simple_code_47e0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47e0
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47e0:
	enter 0, 0
	mov rax, L_constants + 1
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5340:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5340
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5340
.L_tc_recycle_frame_done_5340:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47e0:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47de:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_93], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	mov rax, L_constants + 23
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47e1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47e1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47e1
.L_lambda_simple_env_end_47e1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47e1:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47e1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47e1
.L_lambda_simple_params_end_47e1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47e1
	jmp .L_lambda_simple_end_47e1
.L_lambda_simple_code_47e1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_47e1
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47e1:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8 * (4 + 1)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 1)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47e2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47e2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47e2
.L_lambda_simple_env_end_47e2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47e2:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_47e2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47e2
.L_lambda_simple_params_end_47e2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47e2
	jmp .L_lambda_simple_end_47e2
.L_lambda_simple_code_47e2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_47e2
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47e2:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51bc
          	mov rax, qword [rbp + 8 * (4 + 0)]
	jmp .L_if_end_51bc
          .L_if_else_51bc:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5341:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5341
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5341
.L_tc_recycle_frame_done_5341:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51bc:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_47e2:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47e3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47e3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47e3
.L_lambda_simple_env_end_47e3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47e3:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_47e3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47e3
.L_lambda_simple_params_end_47e3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47e3
	jmp .L_lambda_simple_end_47e3
.L_lambda_simple_code_47e3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_47e3
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47e3:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51bd
          	mov rax, qword [rbp + 8 * (4 + 1)]
	jmp .L_if_end_51bd
          .L_if_else_51bd:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5342:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5342
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5342
.L_tc_recycle_frame_done_5342:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51bd:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_47e3:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0af3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0af3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0af3
.L_lambda_opt_env_end_0af3:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0af3:	; copy params
	cmp rsi, 2
	je .L_lambda_opt_params_end_0af3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0af3
.L_lambda_opt_params_end_0af3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0af3
	jmp .L_lambda_opt_end_0af3
.L_lambda_opt_code_0af3:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0af3
	jg .L_lambda_opt_arity_check_more_0af3
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0af3:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20d7:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20d7
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20d7
.L_lambda_opt_stack_shrink_loop_exit_20d7:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0af3
.L_lambda_opt_arity_check_more_0af3:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20d8:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20d8
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20d8
.L_lambda_opt_stack_shrink_loop_exit_20d8:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_20d9:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20d9
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20d9
.L_lambda_opt_stack_shrink_loop_exit_20d9:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0af3:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51be
          	mov rax, L_constants + 1
	jmp .L_if_end_51be
          .L_if_else_51be:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5343:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5343
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5343
.L_tc_recycle_frame_done_5343:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51be:
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0af3:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_47e1:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_94], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47e4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47e4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47e4
.L_lambda_simple_env_end_47e4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47e4:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47e4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47e4
.L_lambda_simple_params_end_47e4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47e4
	jmp .L_lambda_simple_end_47e4
.L_lambda_simple_code_47e4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47e4
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47e4:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47e5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47e5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47e5
.L_lambda_simple_env_end_47e5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47e5:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47e5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47e5
.L_lambda_simple_params_end_47e5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47e5
	jmp .L_lambda_simple_end_47e5
.L_lambda_simple_code_47e5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_47e5
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47e5:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_0]
	push rax
	push 2
	mov rax, qword [free_var_90]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51bf
          	mov rax, qword [rbp + 8 * (4 + 1)]
	jmp .L_if_end_51bf
          .L_if_else_51bf:
          	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 3 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5344:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5344
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5344
.L_tc_recycle_frame_done_5344:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51bf:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_47e5:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0af4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0af4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0af4
.L_lambda_opt_env_end_0af4:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0af4:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0af4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0af4
.L_lambda_opt_params_end_0af4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0af4
	jmp .L_lambda_opt_end_0af4
.L_lambda_opt_code_0af4:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_opt_arity_check_exact_0af4
	jg .L_lambda_opt_arity_check_more_0af4
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0af4:
	mov qword [rsp + 8 * 2], 3
	mov rdx, 5
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20da:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20da
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20da
.L_lambda_opt_stack_shrink_loop_exit_20da:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0af4
.L_lambda_opt_arity_check_more_0af4:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 2
	mov qword [rsp + 8 * 2], 3
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 2 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20db:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20db
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20db
.L_lambda_opt_stack_shrink_loop_exit_20db:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 32
	mov rsi, 5
.L_lambda_opt_stack_shrink_loop_20dc:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20dc
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20dc
.L_lambda_opt_stack_shrink_loop_exit_20dc:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0af4:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 3 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5345:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5345
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5345
.L_tc_recycle_frame_done_5345:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 3)
.L_lambda_opt_end_0af4:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47e4:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_95], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47e6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47e6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47e6
.L_lambda_simple_env_end_47e6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47e6:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47e6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47e6
.L_lambda_simple_params_end_47e6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47e6
	jmp .L_lambda_simple_end_47e6
.L_lambda_simple_code_47e6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47e6
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47e6:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47e7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47e7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47e7
.L_lambda_simple_env_end_47e7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47e7:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47e7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47e7
.L_lambda_simple_params_end_47e7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47e7
	jmp .L_lambda_simple_end_47e7
.L_lambda_simple_code_47e7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_47e7
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47e7:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_0]
	push rax
	push 2
	mov rax, qword [free_var_90]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51c0
          	mov rax, qword [rbp + 8 * (4 + 1)]
	jmp .L_if_end_51c0
          .L_if_else_51c0:
          	mov rax, L_constants + 1
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_17]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [free_var_16]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_94]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5346:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5346
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5346
.L_tc_recycle_frame_done_5346:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51c0:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_47e7:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0af5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0af5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0af5
.L_lambda_opt_env_end_0af5:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0af5:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0af5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0af5
.L_lambda_opt_params_end_0af5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0af5
	jmp .L_lambda_opt_end_0af5
.L_lambda_opt_code_0af5:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_opt_arity_check_exact_0af5
	jg .L_lambda_opt_arity_check_more_0af5
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0af5:
	mov qword [rsp + 8 * 2], 3
	mov rdx, 5
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20dd:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20dd
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20dd
.L_lambda_opt_stack_shrink_loop_exit_20dd:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0af5
.L_lambda_opt_arity_check_more_0af5:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 2
	mov qword [rsp + 8 * 2], 3
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 2 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20de:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20de
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20de
.L_lambda_opt_stack_shrink_loop_exit_20de:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 32
	mov rsi, 5
.L_lambda_opt_stack_shrink_loop_20df:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20df
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20df
.L_lambda_opt_stack_shrink_loop_exit_20df:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0af5:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 3 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5347:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5347
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5347
.L_tc_recycle_frame_done_5347:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 3)
.L_lambda_opt_end_0af5:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47e6:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_96], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47eb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47eb
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47eb
.L_lambda_simple_env_end_47eb:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47eb:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47eb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47eb
.L_lambda_simple_params_end_47eb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47eb
	jmp .L_lambda_simple_end_47eb
.L_lambda_simple_code_47eb:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_47eb
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47eb:
	enter 0, 0
	mov rax, L_constants + 68
	push rax
	mov rax, L_constants + 59
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5351:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5351
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5351
.L_tc_recycle_frame_done_5351:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_47eb:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47e8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47e8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47e8
.L_lambda_simple_env_end_47e8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47e8:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47e8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47e8
.L_lambda_simple_params_end_47e8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47e8
	jmp .L_lambda_simple_end_47e8
.L_lambda_simple_code_47e8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47e8
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47e8:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47ea:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47ea
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47ea
.L_lambda_simple_env_end_47ea:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47ea:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47ea
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47ea
.L_lambda_simple_params_end_47ea:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47ea
	jmp .L_lambda_simple_end_47ea
.L_lambda_simple_code_47ea:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_47ea
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47ea:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51c6
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51c2
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_34]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_534a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_534a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_534a
.L_tc_recycle_frame_done_534a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51c2
          .L_if_else_51c2:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51c1
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_30]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_534b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_534b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_534b
.L_tc_recycle_frame_done_534b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51c1
          .L_if_else_51c1:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_534c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_534c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_534c
.L_tc_recycle_frame_done_534c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51c1:
.L_if_end_51c2:
	jmp .L_if_end_51c6
          .L_if_else_51c6:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51c5
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51c4
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_30]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_534d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_534d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_534d
.L_tc_recycle_frame_done_534d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51c4
          .L_if_else_51c4:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51c3
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_30]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_534e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_534e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_534e
.L_tc_recycle_frame_done_534e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51c3
          .L_if_else_51c3:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_534f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_534f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_534f
.L_tc_recycle_frame_done_534f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51c3:
.L_if_end_51c4:
	jmp .L_if_end_51c5
          .L_if_else_51c5:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5350:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5350
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5350
.L_tc_recycle_frame_done_5350:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51c5:
.L_if_end_51c6:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_47ea:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47e9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47e9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47e9
.L_lambda_simple_env_end_47e9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47e9:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47e9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47e9
.L_lambda_simple_params_end_47e9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47e9
	jmp .L_lambda_simple_end_47e9
.L_lambda_simple_code_47e9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47e9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47e9:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0af6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0af6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0af6
.L_lambda_opt_env_end_0af6:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0af6:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0af6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0af6
.L_lambda_opt_params_end_0af6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0af6
	jmp .L_lambda_opt_end_0af6
.L_lambda_opt_code_0af6:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0af6
	jg .L_lambda_opt_arity_check_more_0af6
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0af6:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20e0:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20e0
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20e0
.L_lambda_opt_stack_shrink_loop_exit_20e0:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0af6
.L_lambda_opt_arity_check_more_0af6:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20e1:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20e1
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20e1
.L_lambda_opt_stack_shrink_loop_exit_20e1:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_20e2:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20e2
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20e2
.L_lambda_opt_stack_shrink_loop_exit_20e2:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0af6:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, L_constants + 32
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 3
	mov rax, qword [free_var_95]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 3 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5349:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5349
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5349
.L_tc_recycle_frame_done_5349:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0af6:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47e9:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5348:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5348
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5348
.L_tc_recycle_frame_done_5348:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47e8:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_97], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47f0:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47f0
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47f0
.L_lambda_simple_env_end_47f0:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47f0:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47f0
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47f0
.L_lambda_simple_params_end_47f0:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47f0
	jmp .L_lambda_simple_end_47f0
.L_lambda_simple_code_47f0:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_47f0
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47f0:
	enter 0, 0
	mov rax, L_constants + 68
	push rax
	mov rax, L_constants + 119
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_535d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_535d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_535d
.L_tc_recycle_frame_done_535d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_47f0:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47ec:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47ec
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47ec
.L_lambda_simple_env_end_47ec:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47ec:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47ec
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47ec
.L_lambda_simple_params_end_47ec:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47ec
	jmp .L_lambda_simple_end_47ec
.L_lambda_simple_code_47ec:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47ec
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47ec:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47ef:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47ef
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47ef
.L_lambda_simple_env_end_47ef:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47ef:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47ef
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47ef
.L_lambda_simple_params_end_47ef:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47ef
	jmp .L_lambda_simple_end_47ef
.L_lambda_simple_code_47ef:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_47ef
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47ef:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51cd
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51c9
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_35]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5356:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5356
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5356
.L_tc_recycle_frame_done_5356:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51c9
          .L_if_else_51c9:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51c8
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_31]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5357:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5357
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5357
.L_tc_recycle_frame_done_5357:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51c8
          .L_if_else_51c8:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5358:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5358
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5358
.L_tc_recycle_frame_done_5358:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51c8:
.L_if_end_51c9:
	jmp .L_if_end_51cd
          .L_if_else_51cd:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51cc
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51cb
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_31]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5359:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5359
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5359
.L_tc_recycle_frame_done_5359:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51cb
          .L_if_else_51cb:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51ca
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_31]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_535a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_535a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_535a
.L_tc_recycle_frame_done_535a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51ca
          .L_if_else_51ca:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_535b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_535b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_535b
.L_tc_recycle_frame_done_535b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51ca:
.L_if_end_51cb:
	jmp .L_if_end_51cc
          .L_if_else_51cc:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_535c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_535c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_535c
.L_tc_recycle_frame_done_535c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51cc:
.L_if_end_51cd:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_47ef:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47ed:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47ed
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47ed
.L_lambda_simple_env_end_47ed:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47ed:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47ed
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47ed
.L_lambda_simple_params_end_47ed:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47ed
	jmp .L_lambda_simple_end_47ed
.L_lambda_simple_code_47ed:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47ed
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47ed:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0af7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0af7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0af7
.L_lambda_opt_env_end_0af7:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0af7:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0af7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0af7
.L_lambda_opt_params_end_0af7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0af7
	jmp .L_lambda_opt_end_0af7
.L_lambda_opt_code_0af7:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0af7
	jg .L_lambda_opt_arity_check_more_0af7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0af7:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20e3:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20e3
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20e3
.L_lambda_opt_stack_shrink_loop_exit_20e3:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0af7
.L_lambda_opt_arity_check_more_0af7:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20e4:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20e4
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20e4
.L_lambda_opt_stack_shrink_loop_exit_20e4:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_20e5:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20e5
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20e5
.L_lambda_opt_stack_shrink_loop_exit_20e5:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0af7:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51c7
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, L_constants + 32
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5353:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5353
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5353
.L_tc_recycle_frame_done_5353:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51c7
          .L_if_else_51c7:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, L_constants + 32
	push rax
	mov rax, qword [free_var_97]
	push rax
	push 3
	mov rax, qword [free_var_95]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47ee:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_47ee
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47ee
.L_lambda_simple_env_end_47ee:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47ee:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_47ee
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47ee
.L_lambda_simple_params_end_47ee:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47ee
	jmp .L_lambda_simple_end_47ee
.L_lambda_simple_code_47ee:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47ee
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47ee:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5355:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5355
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5355
.L_tc_recycle_frame_done_5355:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47ee:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5354:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5354
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5354
.L_tc_recycle_frame_done_5354:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51c7:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0af7:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47ed:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5352:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5352
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5352
.L_tc_recycle_frame_done_5352:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47ec:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_98], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47f4:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47f4
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47f4
.L_lambda_simple_env_end_47f4:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47f4:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47f4
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47f4
.L_lambda_simple_params_end_47f4:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47f4
	jmp .L_lambda_simple_end_47f4
.L_lambda_simple_code_47f4:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_47f4
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47f4:
	enter 0, 0
	mov rax, L_constants + 68
	push rax
	mov rax, L_constants + 155
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5367:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5367
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5367
.L_tc_recycle_frame_done_5367:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_47f4:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47f1:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47f1
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47f1
.L_lambda_simple_env_end_47f1:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47f1:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47f1
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47f1
.L_lambda_simple_params_end_47f1:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47f1
	jmp .L_lambda_simple_end_47f1
.L_lambda_simple_code_47f1:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47f1
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47f1:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47f3:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47f3
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47f3
.L_lambda_simple_env_end_47f3:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47f3:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47f3
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47f3
.L_lambda_simple_params_end_47f3:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47f3
	jmp .L_lambda_simple_end_47f3
.L_lambda_simple_code_47f3:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_47f3
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47f3:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51d3
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51cf
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_36]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5360:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5360
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5360
.L_tc_recycle_frame_done_5360:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51cf
          .L_if_else_51cf:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51ce
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_32]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5361:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5361
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5361
.L_tc_recycle_frame_done_5361:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51ce
          .L_if_else_51ce:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5362:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5362
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5362
.L_tc_recycle_frame_done_5362:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51ce:
.L_if_end_51cf:
	jmp .L_if_end_51d3
          .L_if_else_51d3:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51d2
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51d1
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_32]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5363:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5363
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5363
.L_tc_recycle_frame_done_5363:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51d1
          .L_if_else_51d1:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51d0
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_32]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5364:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5364
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5364
.L_tc_recycle_frame_done_5364:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51d0
          .L_if_else_51d0:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5365:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5365
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5365
.L_tc_recycle_frame_done_5365:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51d0:
.L_if_end_51d1:
	jmp .L_if_end_51d2
          .L_if_else_51d2:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5366:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5366
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5366
.L_tc_recycle_frame_done_5366:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51d2:
.L_if_end_51d3:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_47f3:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47f2:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47f2
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47f2
.L_lambda_simple_env_end_47f2:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47f2:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47f2
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47f2
.L_lambda_simple_params_end_47f2:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47f2
	jmp .L_lambda_simple_end_47f2
.L_lambda_simple_code_47f2:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47f2
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47f2:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0af8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0af8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0af8
.L_lambda_opt_env_end_0af8:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0af8:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0af8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0af8
.L_lambda_opt_params_end_0af8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0af8
	jmp .L_lambda_opt_end_0af8
.L_lambda_opt_code_0af8:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0af8
	jg .L_lambda_opt_arity_check_more_0af8
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0af8:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20e6:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20e6
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20e6
.L_lambda_opt_stack_shrink_loop_exit_20e6:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0af8
.L_lambda_opt_arity_check_more_0af8:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20e7:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20e7
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20e7
.L_lambda_opt_stack_shrink_loop_exit_20e7:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_20e8:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20e8
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20e8
.L_lambda_opt_stack_shrink_loop_exit_20e8:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0af8:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 3
	mov rax, qword [free_var_95]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 3 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_535f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_535f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_535f
.L_tc_recycle_frame_done_535f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0af8:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47f2:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_535e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_535e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_535e
.L_tc_recycle_frame_done_535e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47f1:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_99], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47f9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47f9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47f9
.L_lambda_simple_env_end_47f9:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47f9:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47f9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47f9
.L_lambda_simple_params_end_47f9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47f9
	jmp .L_lambda_simple_end_47f9
.L_lambda_simple_code_47f9:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_47f9
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47f9:
	enter 0, 0
	mov rax, L_constants + 68
	push rax
	mov rax, L_constants + 174
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5373:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5373
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5373
.L_tc_recycle_frame_done_5373:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_47f9:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47f5:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47f5
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47f5
.L_lambda_simple_env_end_47f5:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47f5:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47f5
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47f5
.L_lambda_simple_params_end_47f5:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47f5
	jmp .L_lambda_simple_end_47f5
.L_lambda_simple_code_47f5:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47f5
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47f5:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47f8:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47f8
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47f8
.L_lambda_simple_env_end_47f8:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47f8:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47f8
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47f8
.L_lambda_simple_params_end_47f8:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47f8
	jmp .L_lambda_simple_end_47f8
.L_lambda_simple_code_47f8:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_47f8
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47f8:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51da
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51d6
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_37]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_536c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_536c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_536c
.L_tc_recycle_frame_done_536c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51d6
          .L_if_else_51d6:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51d5
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_33]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_536d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_536d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_536d
.L_tc_recycle_frame_done_536d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51d5
          .L_if_else_51d5:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_536e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_536e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_536e
.L_tc_recycle_frame_done_536e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51d5:
.L_if_end_51d6:
	jmp .L_if_end_51da
          .L_if_else_51da:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51d9
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51d8
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_33]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_536f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_536f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_536f
.L_tc_recycle_frame_done_536f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51d8
          .L_if_else_51d8:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51d7
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_33]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5370:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5370
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5370
.L_tc_recycle_frame_done_5370:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51d7
          .L_if_else_51d7:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5371:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5371
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5371
.L_tc_recycle_frame_done_5371:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51d7:
.L_if_end_51d8:
	jmp .L_if_end_51d9
          .L_if_else_51d9:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5372:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5372
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5372
.L_tc_recycle_frame_done_5372:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51d9:
.L_if_end_51da:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_47f8:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47f6:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47f6
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47f6
.L_lambda_simple_env_end_47f6:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47f6:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47f6
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47f6
.L_lambda_simple_params_end_47f6:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47f6
	jmp .L_lambda_simple_end_47f6
.L_lambda_simple_code_47f6:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47f6
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47f6:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0af9:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0af9
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0af9
.L_lambda_opt_env_end_0af9:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0af9:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0af9
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0af9
.L_lambda_opt_params_end_0af9:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0af9
	jmp .L_lambda_opt_end_0af9
.L_lambda_opt_code_0af9:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0af9
	jg .L_lambda_opt_arity_check_more_0af9
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0af9:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20e9:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20e9
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20e9
.L_lambda_opt_stack_shrink_loop_exit_20e9:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0af9
.L_lambda_opt_arity_check_more_0af9:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20ea:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20ea
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20ea
.L_lambda_opt_stack_shrink_loop_exit_20ea:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_20eb:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20eb
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20eb
.L_lambda_opt_stack_shrink_loop_exit_20eb:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0af9:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51d4
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, L_constants + 128
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5369:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5369
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5369
.L_tc_recycle_frame_done_5369:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51d4
          .L_if_else_51d4:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [free_var_99]
	push rax
	push 3
	mov rax, qword [free_var_95]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47f7:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_47f7
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47f7
.L_lambda_simple_env_end_47f7:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47f7:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_47f7
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47f7
.L_lambda_simple_params_end_47f7:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47f7
	jmp .L_lambda_simple_end_47f7
.L_lambda_simple_code_47f7:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47f7
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47f7:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_536b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_536b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_536b
.L_tc_recycle_frame_done_536b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47f7:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_536a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_536a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_536a
.L_tc_recycle_frame_done_536a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51d4:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0af9:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47f6:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5368:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5368
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5368
.L_tc_recycle_frame_done_5368:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47f5:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_100], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47fa:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47fa
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47fa
.L_lambda_simple_env_end_47fa:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47fa:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47fa
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47fa
.L_lambda_simple_params_end_47fa:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47fa
	jmp .L_lambda_simple_end_47fa
.L_lambda_simple_code_47fa:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47fa
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47fa:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_27]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51db
          	mov rax, L_constants + 128
	jmp .L_if_end_51db
          .L_if_else_51db:
          	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_101]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_99]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5374:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5374
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5374
.L_tc_recycle_frame_done_5374:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51db:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47fa:	; new closure is in rax
	mov qword [free_var_101], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_102], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_103], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_104], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_105], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_106], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_480b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_480b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_480b
.L_lambda_simple_env_end_480b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_480b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_480b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_480b
.L_lambda_simple_params_end_480b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_480b
	jmp .L_lambda_simple_end_480b
.L_lambda_simple_code_480b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_480b
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_480b:
	enter 0, 0
	mov rax, L_constants + 219
	push rax
	mov rax, L_constants + 210
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5388:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5388
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5388
.L_tc_recycle_frame_done_5388:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_480b:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47fb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_47fb
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47fb
.L_lambda_simple_env_end_47fb:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47fb:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_47fb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47fb
.L_lambda_simple_params_end_47fb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47fb
	jmp .L_lambda_simple_end_47fb
.L_lambda_simple_code_47fb:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47fb
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47fb:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4809:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4809
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4809
.L_lambda_simple_env_end_4809:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4809:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4809
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4809
.L_lambda_simple_params_end_4809:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4809
	jmp .L_lambda_simple_end_4809
.L_lambda_simple_code_4809:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4809
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4809:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_480a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_480a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_480a
.L_lambda_simple_env_end_480a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_480a:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_480a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_480a
.L_lambda_simple_params_end_480a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_480a
	jmp .L_lambda_simple_end_480a
.L_lambda_simple_code_480a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_480a
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_480a:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51e2
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51de
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5382:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5382
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5382
.L_tc_recycle_frame_done_5382:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51de
          .L_if_else_51de:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51dd
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5383:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5383
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5383
.L_tc_recycle_frame_done_5383:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51dd
          .L_if_else_51dd:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5384:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5384
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5384
.L_tc_recycle_frame_done_5384:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51dd:
.L_if_end_51de:
	jmp .L_if_end_51e2
          .L_if_else_51e2:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51e1
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51e0
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_23]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5385:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5385
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5385
.L_tc_recycle_frame_done_5385:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51e0
          .L_if_else_51e0:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51df
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5386:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5386
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5386
.L_tc_recycle_frame_done_5386:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51df
          .L_if_else_51df:
          	push 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5387:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5387
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5387
.L_tc_recycle_frame_done_5387:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51df:
.L_if_end_51e0:
	jmp .L_if_end_51e1
          .L_if_else_51e1:
          	mov rax, L_constants + 0
.L_if_end_51e1:
.L_if_end_51e2:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_480a:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4809:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47fc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_47fc
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47fc
.L_lambda_simple_env_end_47fc:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47fc:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47fc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47fc
.L_lambda_simple_params_end_47fc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47fc
	jmp .L_lambda_simple_end_47fc
.L_lambda_simple_code_47fc:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47fc
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47fc:
	enter 0, 0
	mov rax, qword [free_var_39]
	push rax
	mov rax, qword [free_var_40]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47fd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_47fd
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47fd
.L_lambda_simple_env_end_47fd:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47fd:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47fd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47fd
.L_lambda_simple_params_end_47fd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47fd
	jmp .L_lambda_simple_end_47fd
.L_lambda_simple_code_47fd:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47fd
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47fd:
	enter 0, 0
	mov rax, qword [free_var_41]
	push rax
	mov rax, qword [free_var_42]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47fe:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_47fe
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47fe
.L_lambda_simple_env_end_47fe:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47fe:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47fe
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47fe
.L_lambda_simple_params_end_47fe:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47fe
	jmp .L_lambda_simple_end_47fe
.L_lambda_simple_code_47fe:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47fe
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47fe:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4808:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_4808
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4808
.L_lambda_simple_env_end_4808:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4808:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4808
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4808
.L_lambda_simple_params_end_4808:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4808
	jmp .L_lambda_simple_end_4808
.L_lambda_simple_code_4808:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4808
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4808:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_86]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5381:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5381
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5381
.L_tc_recycle_frame_done_5381:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4808:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_47ff:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_47ff
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_47ff
.L_lambda_simple_env_end_47ff:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_47ff:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_47ff
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_47ff
.L_lambda_simple_params_end_47ff:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_47ff
	jmp .L_lambda_simple_end_47ff
.L_lambda_simple_code_47ff:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_47ff
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_47ff:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 6	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4807:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 5
	je .L_lambda_simple_env_end_4807
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4807
.L_lambda_simple_env_end_4807:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4807:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4807
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4807
.L_lambda_simple_params_end_4807:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4807
	jmp .L_lambda_simple_end_4807
.L_lambda_simple_code_4807:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4807
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4807:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5380:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5380
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5380
.L_tc_recycle_frame_done_5380:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4807:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 6	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4800:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 5
	je .L_lambda_simple_env_end_4800
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4800
.L_lambda_simple_env_end_4800:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4800:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4800
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4800
.L_lambda_simple_params_end_4800:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4800
	jmp .L_lambda_simple_end_4800
.L_lambda_simple_code_4800:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4800
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4800:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 7	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4806:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 6
	je .L_lambda_simple_env_end_4806
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4806
.L_lambda_simple_env_end_4806:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4806:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4806
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4806
.L_lambda_simple_params_end_4806:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4806
	jmp .L_lambda_simple_end_4806
.L_lambda_simple_code_4806:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4806
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4806:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_86]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_537f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_537f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_537f
.L_tc_recycle_frame_done_537f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4806:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 7	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4801:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 6
	je .L_lambda_simple_env_end_4801
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4801
.L_lambda_simple_env_end_4801:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4801:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4801
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4801
.L_lambda_simple_params_end_4801:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4801
	jmp .L_lambda_simple_end_4801
.L_lambda_simple_code_4801:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4801
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4801:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 8	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4803:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 7
	je .L_lambda_simple_env_end_4803
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4803
.L_lambda_simple_env_end_4803:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4803:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4803
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4803
.L_lambda_simple_params_end_4803:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4803
	jmp .L_lambda_simple_end_4803
.L_lambda_simple_code_4803:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4803
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4803:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 9	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4804:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 8
	je .L_lambda_simple_env_end_4804
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4804
.L_lambda_simple_env_end_4804:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4804:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4804
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4804
.L_lambda_simple_params_end_4804:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4804
	jmp .L_lambda_simple_end_4804
.L_lambda_simple_code_4804:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4804
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4804:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 10	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4805:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 9
	je .L_lambda_simple_env_end_4805
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4805
.L_lambda_simple_env_end_4805:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4805:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4805
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4805
.L_lambda_simple_params_end_4805:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4805
	jmp .L_lambda_simple_end_4805
.L_lambda_simple_code_4805:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4805
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4805:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_056b
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51dc
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_537d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_537d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_537d
.L_tc_recycle_frame_done_537d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51dc
          .L_if_else_51dc:
          	mov rax, L_constants + 2
.L_if_end_51dc:
.L_or_end_056b:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4805:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 10	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0afa:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 9
	je .L_lambda_opt_env_end_0afa
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0afa
.L_lambda_opt_env_end_0afa:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0afa:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0afa
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0afa
.L_lambda_opt_params_end_0afa:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0afa
	jmp .L_lambda_opt_end_0afa
.L_lambda_opt_code_0afa:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0afa
	jg .L_lambda_opt_arity_check_more_0afa
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0afa:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20ec:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20ec
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20ec
.L_lambda_opt_stack_shrink_loop_exit_20ec:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0afa
.L_lambda_opt_arity_check_more_0afa:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20ed:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20ed
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20ed
.L_lambda_opt_stack_shrink_loop_exit_20ed:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_20ee:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20ee
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20ee
.L_lambda_opt_stack_shrink_loop_exit_20ee:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0afa:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_537e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_537e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_537e
.L_tc_recycle_frame_done_537e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0afa:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4804:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_537c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_537c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_537c
.L_tc_recycle_frame_done_537c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4803:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 8	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4802:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 7
	je .L_lambda_simple_env_end_4802
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4802
.L_lambda_simple_env_end_4802:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4802:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4802
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4802
.L_lambda_simple_params_end_4802:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4802
	jmp .L_lambda_simple_end_4802
.L_lambda_simple_code_4802:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4802
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4802:
	enter 0, 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 4]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_102], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_103], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_104], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_105], rax
	mov rax, sob_void

	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 3]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_106], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4802:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_537b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_537b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_537b
.L_tc_recycle_frame_done_537b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4801:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_537a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_537a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_537a
.L_tc_recycle_frame_done_537a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4800:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5379:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5379
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5379
.L_tc_recycle_frame_done_5379:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47ff:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5378:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5378
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5378
.L_tc_recycle_frame_done_5378:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47fe:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5377:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5377
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5377
.L_tc_recycle_frame_done_5377:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47fd:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5376:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5376
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5376
.L_tc_recycle_frame_done_5376:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47fc:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5375:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5375
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5375
.L_tc_recycle_frame_done_5375:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_47fb:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_480c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_480c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_480c
.L_lambda_simple_env_end_480c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_480c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_480c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_480c
.L_lambda_simple_params_end_480c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_480c
	jmp .L_lambda_simple_end_480c
.L_lambda_simple_code_480c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_480c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_480c:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_480d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_480d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_480d
.L_lambda_simple_env_end_480d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_480d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_480d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_480d
.L_lambda_simple_params_end_480d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_480d
	jmp .L_lambda_simple_end_480d
.L_lambda_simple_code_480d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_480d
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_480d:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_27]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51e3
          	mov rax, L_constants + 1
	jmp .L_if_end_51e3
          .L_if_else_51e3:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5389:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5389
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5389
.L_tc_recycle_frame_done_5389:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51e3:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_480d:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0afb:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0afb
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0afb
.L_lambda_opt_env_end_0afb:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0afb:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0afb
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0afb
.L_lambda_opt_params_end_0afb:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0afb
	jmp .L_lambda_opt_end_0afb
.L_lambda_opt_code_0afb:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0afb
	jg .L_lambda_opt_arity_check_more_0afb
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0afb:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20ef:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20ef
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20ef
.L_lambda_opt_stack_shrink_loop_exit_20ef:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0afb
.L_lambda_opt_arity_check_more_0afb:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20f0:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20f0
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20f0
.L_lambda_opt_stack_shrink_loop_exit_20f0:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_20f1:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20f1
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20f1
.L_lambda_opt_stack_shrink_loop_exit_20f1:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0afb:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51e7
          	mov rax, L_constants + 4
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_538a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_538a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_538a
.L_tc_recycle_frame_done_538a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51e7
          .L_if_else_51e7:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51e5
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51e4
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_3]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51e4
          .L_if_else_51e4:
          	mov rax, L_constants + 2
.L_if_end_51e4:
	jmp .L_if_end_51e5
          .L_if_else_51e5:
          	mov rax, L_constants + 2
.L_if_end_51e5:
	cmp rax, sob_boolean_false
          	je .L_if_else_51e6
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_538b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_538b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_538b
.L_tc_recycle_frame_done_538b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51e6
          .L_if_else_51e6:
          	mov rax, L_constants + 288
	push rax
	mov rax, L_constants + 279
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_538c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_538c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_538c
.L_tc_recycle_frame_done_538c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51e6:
.L_if_end_51e7:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0afb:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_480c:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_107], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_108], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_109], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_110], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_111], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_112], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_480f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_480f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_480f
.L_lambda_simple_env_end_480f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_480f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_480f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_480f
.L_lambda_simple_params_end_480f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_480f
	jmp .L_lambda_simple_end_480f
.L_lambda_simple_code_480f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_480f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_480f:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0afc:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0afc
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0afc
.L_lambda_opt_env_end_0afc:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0afc:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0afc
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0afc
.L_lambda_opt_params_end_0afc:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0afc
	jmp .L_lambda_opt_end_0afc
.L_lambda_opt_code_0afc:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0afc
	jg .L_lambda_opt_arity_check_more_0afc
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0afc:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20f2:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20f2
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20f2
.L_lambda_opt_stack_shrink_loop_exit_20f2:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0afc
.L_lambda_opt_arity_check_more_0afc:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20f3:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20f3
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20f3
.L_lambda_opt_stack_shrink_loop_exit_20f3:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_20f4:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20f4
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20f4
.L_lambda_opt_stack_shrink_loop_exit_20f4:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0afc:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [free_var_24]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_538d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_538d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_538d
.L_tc_recycle_frame_done_538d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0afc:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_480f:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_480e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_480e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_480e
.L_lambda_simple_env_end_480e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_480e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_480e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_480e
.L_lambda_simple_params_end_480e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_480e
	jmp .L_lambda_simple_end_480e
.L_lambda_simple_code_480e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_480e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_480e:
	enter 0, 0
	mov rax, qword [free_var_102]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_108], rax
	mov rax, sob_void

	mov rax, qword [free_var_103]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_109], rax
	mov rax, sob_void

	mov rax, qword [free_var_106]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_110], rax
	mov rax, sob_void

	mov rax, qword [free_var_104]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_111], rax
	mov rax, sob_void

	mov rax, qword [free_var_105]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_112], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_480e:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_113], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_114], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 342
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, L_constants + 346
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4810:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4810
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4810
.L_lambda_simple_env_end_4810:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4810:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4810
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4810
.L_lambda_simple_params_end_4810:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4810
	jmp .L_lambda_simple_end_4810
.L_lambda_simple_code_4810:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4810
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4810:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4811:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4811
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4811
.L_lambda_simple_env_end_4811:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4811:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4811
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4811
.L_lambda_simple_params_end_4811:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4811
	jmp .L_lambda_simple_end_4811
.L_lambda_simple_code_4811:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4811
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4811:
	enter 0, 0
	mov rax, L_constants + 344
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, L_constants + 342
	push rax
	push 3
	mov rax, qword [free_var_109]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51e8
          	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_25]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_538e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_538e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_538e
.L_tc_recycle_frame_done_538e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51e8
          .L_if_else_51e8:
          	mov rax, qword [rbp + 8 * (4 + 0)]
.L_if_end_51e8:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4811:	; new closure is in rax
	mov qword [free_var_113], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4812:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4812
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4812
.L_lambda_simple_env_end_4812:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4812:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4812
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4812
.L_lambda_simple_params_end_4812:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4812
	jmp .L_lambda_simple_end_4812
.L_lambda_simple_code_4812:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4812
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4812:
	enter 0, 0
	mov rax, L_constants + 348
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, L_constants + 346
	push rax
	push 3
	mov rax, qword [free_var_109]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51e9
          	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_25]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_538f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_538f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_538f
.L_tc_recycle_frame_done_538f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51e9
          .L_if_else_51e9:
          	mov rax, qword [rbp + 8 * (4 + 0)]
.L_if_end_51e9:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4812:	; new closure is in rax
	mov qword [free_var_114], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4810:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_115], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_116], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_117], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_118], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_119], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4814:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4814
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4814
.L_lambda_simple_env_end_4814:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4814:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4814
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4814
.L_lambda_simple_params_end_4814:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4814
	jmp .L_lambda_simple_end_4814
.L_lambda_simple_code_4814:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4814
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4814:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0afd:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0afd
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0afd
.L_lambda_opt_env_end_0afd:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0afd:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0afd
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0afd
.L_lambda_opt_params_end_0afd:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0afd
	jmp .L_lambda_opt_end_0afd
.L_lambda_opt_code_0afd:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0afd
	jg .L_lambda_opt_arity_check_more_0afd
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0afd:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20f5:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20f5
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20f5
.L_lambda_opt_stack_shrink_loop_exit_20f5:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0afd
.L_lambda_opt_arity_check_more_0afd:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20f6:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20f6
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20f6
.L_lambda_opt_stack_shrink_loop_exit_20f6:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_20f7:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20f7
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20f7
.L_lambda_opt_stack_shrink_loop_exit_20f7:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0afd:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4815:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4815
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4815
.L_lambda_simple_env_end_4815:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4815:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4815
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4815
.L_lambda_simple_params_end_4815:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4815
	jmp .L_lambda_simple_end_4815
.L_lambda_simple_code_4815:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4815
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4815:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_113]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_24]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5391:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5391
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5391
.L_tc_recycle_frame_done_5391:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4815:	; new closure is in rax
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [free_var_89]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5390:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5390
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5390
.L_tc_recycle_frame_done_5390:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0afd:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4814:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4813:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4813
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4813
.L_lambda_simple_env_end_4813:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4813:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4813
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4813
.L_lambda_simple_params_end_4813:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4813
	jmp .L_lambda_simple_end_4813
.L_lambda_simple_code_4813:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4813
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4813:
	enter 0, 0
	mov rax, qword [free_var_102]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_115], rax
	mov rax, sob_void

	mov rax, qword [free_var_103]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_116], rax
	mov rax, sob_void

	mov rax, qword [free_var_106]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_117], rax
	mov rax, sob_void

	mov rax, qword [free_var_104]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_118], rax
	mov rax, sob_void

	mov rax, qword [free_var_105]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_119], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4813:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_120], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_121], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4817:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4817
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4817
.L_lambda_simple_env_end_4817:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4817:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4817
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4817
.L_lambda_simple_params_end_4817:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4817
	jmp .L_lambda_simple_end_4817
.L_lambda_simple_code_4817:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4817
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4817:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4818:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4818
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4818
.L_lambda_simple_env_end_4818:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4818:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4818
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4818
.L_lambda_simple_params_end_4818:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4818
	jmp .L_lambda_simple_end_4818
.L_lambda_simple_code_4818:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4818
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4818:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_123]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [free_var_91]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_122]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5392:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5392
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5392
.L_tc_recycle_frame_done_5392:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4818:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4817:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4816:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4816
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4816
.L_lambda_simple_env_end_4816:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4816:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4816
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4816
.L_lambda_simple_params_end_4816:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4816
	jmp .L_lambda_simple_end_4816
.L_lambda_simple_code_4816:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4816
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4816:
	enter 0, 0
	mov rax, qword [free_var_113]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_120], rax
	mov rax, sob_void

	mov rax, qword [free_var_114]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_121], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4816:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_124], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_125], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_126], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_127], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_128], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_129], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_130], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_131], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_132], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 0
	mov qword [free_var_133], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_481a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_481a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_481a
.L_lambda_simple_env_end_481a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_481a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_481a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_481a
.L_lambda_simple_params_end_481a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_481a
	jmp .L_lambda_simple_end_481a
.L_lambda_simple_code_481a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_481a
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_481a:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_481b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_481b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_481b
.L_lambda_simple_env_end_481b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_481b:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_481b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_481b
.L_lambda_simple_params_end_481b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_481b
	jmp .L_lambda_simple_end_481b
.L_lambda_simple_code_481b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_481b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_481b:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_481c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_481c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_481c
.L_lambda_simple_env_end_481c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_481c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_481c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_481c
.L_lambda_simple_params_end_481c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_481c
	jmp .L_lambda_simple_end_481c
.L_lambda_simple_code_481c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 5
	je .L_lambda_simple_arity_check_ok_481c
	push qword [rsp + 8 * 2]
	push 5
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_481c:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51ea
          	mov rax, qword [rbp + 8 * (4 + 4)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51ea
          .L_if_else_51ea:
          	mov rax, L_constants + 2
.L_if_end_51ea:
	cmp rax, sob_boolean_false
	jne .L_or_end_056c
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51ec
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_056d
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51eb
          	mov rax, qword [rbp + 8 * (4 + 4)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 5 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5394:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5394
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5394
.L_tc_recycle_frame_done_5394:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51eb
          .L_if_else_51eb:
          	mov rax, L_constants + 2
.L_if_end_51eb:
.L_or_end_056d:
	jmp .L_if_end_51ec
          .L_if_else_51ec:
          	mov rax, L_constants + 2
.L_if_end_51ec:
.L_or_end_056c:
	leave
	ret 8 * (2 + 5)
.L_lambda_simple_end_481c:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4820:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4820
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4820
.L_lambda_simple_env_end_4820:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4820:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4820
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4820
.L_lambda_simple_params_end_4820:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4820
	jmp .L_lambda_simple_end_4820
.L_lambda_simple_code_4820:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4820
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4820:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4821:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_4821
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4821
.L_lambda_simple_env_end_4821:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4821:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4821
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4821
.L_lambda_simple_params_end_4821:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4821
	jmp .L_lambda_simple_end_4821
.L_lambda_simple_code_4821:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4821
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4821:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_103]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51ee
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	mov rax, L_constants + 32
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 5 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_539a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_539a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_539a
.L_tc_recycle_frame_done_539a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51ee
          .L_if_else_51ee:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	mov rax, L_constants + 32
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 5 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_539b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_539b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_539b
.L_tc_recycle_frame_done_539b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51ee:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4821:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5399:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5399
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5399
.L_tc_recycle_frame_done_5399:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4820:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_481d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_481d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_481d
.L_lambda_simple_env_end_481d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_481d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_481d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_481d
.L_lambda_simple_params_end_481d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_481d
	jmp .L_lambda_simple_end_481d
.L_lambda_simple_code_481d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_481d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_481d:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_481e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_481e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_481e
.L_lambda_simple_env_end_481e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_481e:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_481e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_481e
.L_lambda_simple_params_end_481e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_481e
	jmp .L_lambda_simple_end_481e
.L_lambda_simple_code_481e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_481e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_481e:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_481f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_481f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_481f
.L_lambda_simple_env_end_481f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_481f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_481f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_481f
.L_lambda_simple_params_end_481f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_481f
	jmp .L_lambda_simple_end_481f
.L_lambda_simple_code_481f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_481f
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_481f:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_056e
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51ed
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5397:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5397
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5397
.L_tc_recycle_frame_done_5397:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51ed
          .L_if_else_51ed:
          	mov rax, L_constants + 2
.L_if_end_51ed:
.L_or_end_056e:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_481f:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0afe:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_0afe
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0afe
.L_lambda_opt_env_end_0afe:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0afe:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0afe
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0afe
.L_lambda_opt_params_end_0afe:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0afe
	jmp .L_lambda_opt_end_0afe
.L_lambda_opt_code_0afe:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0afe
	jg .L_lambda_opt_arity_check_more_0afe
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0afe:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20f8:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20f8
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20f8
.L_lambda_opt_stack_shrink_loop_exit_20f8:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0afe
.L_lambda_opt_arity_check_more_0afe:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20f9:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20f9
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20f9
.L_lambda_opt_stack_shrink_loop_exit_20f9:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_20fa:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20fa
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20fa
.L_lambda_opt_stack_shrink_loop_exit_20fa:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0afe:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5398:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5398
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5398
.L_tc_recycle_frame_done_5398:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0afe:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_481e:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5396:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5396
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5396
.L_tc_recycle_frame_done_5396:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_481d:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5395:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5395
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5395
.L_tc_recycle_frame_done_5395:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_481b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5393:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5393
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5393
.L_tc_recycle_frame_done_5393:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_481a:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4819:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4819
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4819
.L_lambda_simple_env_end_4819:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4819:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4819
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4819
.L_lambda_simple_params_end_4819:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4819
	jmp .L_lambda_simple_end_4819
.L_lambda_simple_code_4819:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4819
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4819:
	enter 0, 0
	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_108]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_124], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	mov rax, qword [free_var_115]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_129], rax
	mov rax, sob_void

	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_111]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_128], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	mov rax, qword [free_var_118]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_133], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4819:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4823:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4823
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4823
.L_lambda_simple_env_end_4823:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4823:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4823
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4823
.L_lambda_simple_params_end_4823:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4823
	jmp .L_lambda_simple_end_4823
.L_lambda_simple_code_4823:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4823
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4823:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4824:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4824
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4824
.L_lambda_simple_env_end_4824:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4824:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4824
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4824
.L_lambda_simple_params_end_4824:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4824
	jmp .L_lambda_simple_end_4824
.L_lambda_simple_code_4824:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4824
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4824:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4825:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4825
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4825
.L_lambda_simple_env_end_4825:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4825:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4825
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4825
.L_lambda_simple_params_end_4825:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4825
	jmp .L_lambda_simple_end_4825
.L_lambda_simple_code_4825:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 5
	je .L_lambda_simple_arity_check_ok_4825
	push qword [rsp + 8 * 2]
	push 5
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4825:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_056f
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_056f
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51f0
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51ef
          	mov rax, qword [rbp + 8 * (4 + 4)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 5 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_539d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_539d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_539d
.L_tc_recycle_frame_done_539d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51ef
          .L_if_else_51ef:
          	mov rax, L_constants + 2
.L_if_end_51ef:
	jmp .L_if_end_51f0
          .L_if_else_51f0:
          	mov rax, L_constants + 2
.L_if_end_51f0:
.L_or_end_056f:
	leave
	ret 8 * (2 + 5)
.L_lambda_simple_end_4825:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4829:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4829
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4829
.L_lambda_simple_env_end_4829:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4829:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4829
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4829
.L_lambda_simple_params_end_4829:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4829
	jmp .L_lambda_simple_end_4829
.L_lambda_simple_code_4829:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4829
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4829:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_482a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_482a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_482a
.L_lambda_simple_env_end_482a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_482a:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_482a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_482a
.L_lambda_simple_params_end_482a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_482a
	jmp .L_lambda_simple_end_482a
.L_lambda_simple_code_482a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_482a
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_482a:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_103]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51f2
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	mov rax, L_constants + 32
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 5 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53a3:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53a3
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53a3
.L_tc_recycle_frame_done_53a3:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51f2
          .L_if_else_51f2:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	mov rax, L_constants + 32
	push rax
	push 5
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 5 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53a4:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53a4
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53a4
.L_tc_recycle_frame_done_53a4:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51f2:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_482a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53a2:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53a2
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53a2
.L_tc_recycle_frame_done_53a2:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4829:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4826:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4826
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4826
.L_lambda_simple_env_end_4826:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4826:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4826
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4826
.L_lambda_simple_params_end_4826:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4826
	jmp .L_lambda_simple_end_4826
.L_lambda_simple_code_4826:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4826
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4826:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4827:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_4827
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4827
.L_lambda_simple_env_end_4827:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4827:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4827
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4827
.L_lambda_simple_params_end_4827:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4827
	jmp .L_lambda_simple_end_4827
.L_lambda_simple_code_4827:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4827
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4827:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4828:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_4828
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4828
.L_lambda_simple_env_end_4828:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4828:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4828
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4828
.L_lambda_simple_params_end_4828:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4828
	jmp .L_lambda_simple_end_4828
.L_lambda_simple_code_4828:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4828
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4828:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0570
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51f1
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53a0:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53a0
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53a0
.L_tc_recycle_frame_done_53a0:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51f1
          .L_if_else_51f1:
          	mov rax, L_constants + 2
.L_if_end_51f1:
.L_or_end_0570:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4828:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0aff:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_0aff
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0aff
.L_lambda_opt_env_end_0aff:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0aff:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0aff
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0aff
.L_lambda_opt_params_end_0aff:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0aff
	jmp .L_lambda_opt_end_0aff
.L_lambda_opt_code_0aff:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0aff
	jg .L_lambda_opt_arity_check_more_0aff
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0aff:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20fb:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20fb
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20fb
.L_lambda_opt_stack_shrink_loop_exit_20fb:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0aff
.L_lambda_opt_arity_check_more_0aff:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20fc:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20fc
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20fc
.L_lambda_opt_stack_shrink_loop_exit_20fc:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_20fd:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_20fd
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_20fd
.L_lambda_opt_stack_shrink_loop_exit_20fd:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0aff:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53a1:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53a1
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53a1
.L_tc_recycle_frame_done_53a1:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0aff:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4827:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_539f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_539f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_539f
.L_tc_recycle_frame_done_539f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4826:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_539e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_539e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_539e
.L_tc_recycle_frame_done_539e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4824:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_539c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_539c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_539c
.L_tc_recycle_frame_done_539c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4823:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4822:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4822
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4822
.L_lambda_simple_env_end_4822:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4822:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4822
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4822
.L_lambda_simple_params_end_4822:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4822
	jmp .L_lambda_simple_end_4822
.L_lambda_simple_code_4822:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4822
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4822:
	enter 0, 0
	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_108]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_125], rax
	mov rax, sob_void

	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_108]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_130], rax
	mov rax, sob_void

	mov rax, qword [free_var_110]
	push rax
	mov rax, qword [free_var_111]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_127], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	mov rax, qword [free_var_118]
	push rax
	push 2
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_132], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4822:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_482c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_482c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_482c
.L_lambda_simple_env_end_482c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_482c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_482c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_482c
.L_lambda_simple_params_end_482c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_482c
	jmp .L_lambda_simple_end_482c
.L_lambda_simple_code_482c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_482c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_482c:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_482d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_482d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_482d
.L_lambda_simple_env_end_482d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_482d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_482d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_482d
.L_lambda_simple_params_end_482d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_482d
	jmp .L_lambda_simple_end_482d
.L_lambda_simple_code_482d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_482d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_482d:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_482e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_482e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_482e
.L_lambda_simple_env_end_482e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_482e:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_482e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_482e
.L_lambda_simple_params_end_482e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_482e
	jmp .L_lambda_simple_end_482e
.L_lambda_simple_code_482e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 4
	je .L_lambda_simple_arity_check_ok_482e
	push qword [rsp + 8 * 2]
	push 4
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_482e:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0571
	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51f4
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51f3
          	mov rax, qword [rbp + 8 * (4 + 3)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 4
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 4 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53a6:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53a6
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53a6
.L_tc_recycle_frame_done_53a6:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51f3
          .L_if_else_51f3:
          	mov rax, L_constants + 2
.L_if_end_51f3:
	jmp .L_if_end_51f4
          .L_if_else_51f4:
          	mov rax, L_constants + 2
.L_if_end_51f4:
.L_or_end_0571:
	leave
	ret 8 * (2 + 4)
.L_lambda_simple_end_482e:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4832:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4832
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4832
.L_lambda_simple_env_end_4832:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4832:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4832
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4832
.L_lambda_simple_params_end_4832:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4832
	jmp .L_lambda_simple_end_4832
.L_lambda_simple_code_4832:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4832
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4832:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4833:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_4833
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4833
.L_lambda_simple_env_end_4833:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4833:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4833
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4833
.L_lambda_simple_params_end_4833:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4833
	jmp .L_lambda_simple_end_4833
.L_lambda_simple_code_4833:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4833
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4833:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51f6
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	mov rax, L_constants + 32
	push rax
	push 4
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 4 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53ac:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53ac
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53ac
.L_tc_recycle_frame_done_53ac:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51f6
          .L_if_else_51f6:
          	mov rax, L_constants + 2
.L_if_end_51f6:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4833:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53ab:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53ab
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53ab
.L_tc_recycle_frame_done_53ab:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4832:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_482f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_482f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_482f
.L_lambda_simple_env_end_482f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_482f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_482f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_482f
.L_lambda_simple_params_end_482f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_482f
	jmp .L_lambda_simple_end_482f
.L_lambda_simple_code_482f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_482f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_482f:
	enter 0, 0
	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4830:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_4830
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4830
.L_lambda_simple_env_end_4830:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4830:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4830
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4830
.L_lambda_simple_params_end_4830:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4830
	jmp .L_lambda_simple_end_4830
.L_lambda_simple_code_4830:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4830
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4830:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4831:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_4831
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4831
.L_lambda_simple_env_end_4831:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4831:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4831
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4831
.L_lambda_simple_params_end_4831:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4831
	jmp .L_lambda_simple_end_4831
.L_lambda_simple_code_4831:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_4831
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4831:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0572
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51f5
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53a9:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53a9
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53a9
.L_tc_recycle_frame_done_53a9:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51f5
          .L_if_else_51f5:
          	mov rax, L_constants + 2
.L_if_end_51f5:
.L_or_end_0572:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_4831:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b00:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_0b00
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b00
.L_lambda_opt_env_end_0b00:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b00:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b00
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b00
.L_lambda_opt_params_end_0b00:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b00
	jmp .L_lambda_opt_end_0b00
.L_lambda_opt_code_0b00:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0b00
	jg .L_lambda_opt_arity_check_more_0b00
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b00:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_20fe:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_20fe
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20fe
.L_lambda_opt_stack_shrink_loop_exit_20fe:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b00
.L_lambda_opt_arity_check_more_0b00:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_20ff:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_20ff
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_20ff
.L_lambda_opt_stack_shrink_loop_exit_20ff:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_2100:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2100
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2100
.L_lambda_opt_stack_shrink_loop_exit_2100:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b00:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53aa:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53aa
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53aa
.L_tc_recycle_frame_done_53aa:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0b00:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4830:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53a8:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53a8
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53a8
.L_tc_recycle_frame_done_53a8:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_482f:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53a7:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53a7
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53a7
.L_tc_recycle_frame_done_53a7:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_482d:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53a5:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53a5
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53a5
.L_tc_recycle_frame_done_53a5:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_482c:	; new closure is in rax
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_482b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_482b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_482b
.L_lambda_simple_env_end_482b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_482b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_482b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_482b
.L_lambda_simple_params_end_482b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_482b
	jmp .L_lambda_simple_end_482b
.L_lambda_simple_code_482b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_482b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_482b:
	enter 0, 0
	mov rax, qword [free_var_110]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_126], rax
	mov rax, sob_void

	mov rax, qword [free_var_117]
	push rax
	push 1
	mov rax, qword [rbp + 8 * (4 + 0)]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_131], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_482b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4834:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4834
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4834
.L_lambda_simple_env_end_4834:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4834:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4834
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4834
.L_lambda_simple_params_end_4834:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4834
	jmp .L_lambda_simple_end_4834
.L_lambda_simple_code_4834:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4834
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4834:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51f7
          	mov rax, L_constants + 32
	jmp .L_if_end_51f7
          .L_if_else_51f7:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_134]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, L_constants + 128
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53ad:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53ad
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53ad
.L_tc_recycle_frame_done_53ad:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51f7:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4834:	; new closure is in rax
	mov qword [free_var_134], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4835:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4835
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4835
.L_lambda_simple_env_end_4835:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4835:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4835
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4835
.L_lambda_simple_params_end_4835:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4835
	jmp .L_lambda_simple_end_4835
.L_lambda_simple_code_4835:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4835
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4835:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0573
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51f8
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_84]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53ae:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53ae
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53ae
.L_tc_recycle_frame_done_53ae:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51f8
          .L_if_else_51f8:
          	mov rax, L_constants + 2
.L_if_end_51f8:
.L_or_end_0573:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4835:	; new closure is in rax
	mov qword [free_var_84], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword [free_var_51]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4836:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4836
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4836
.L_lambda_simple_env_end_4836:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4836:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4836
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4836
.L_lambda_simple_params_end_4836:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4836
	jmp .L_lambda_simple_end_4836
.L_lambda_simple_code_4836:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4836
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4836:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b01:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0b01
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b01
.L_lambda_opt_env_end_0b01:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b01:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b01
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b01
.L_lambda_opt_params_end_0b01:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b01
	jmp .L_lambda_opt_end_0b01
.L_lambda_opt_code_0b01:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0b01
	jg .L_lambda_opt_arity_check_more_0b01
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b01:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2101:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2101
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2101
.L_lambda_opt_stack_shrink_loop_exit_2101:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b01
.L_lambda_opt_arity_check_more_0b01:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2102:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2102
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2102
.L_lambda_opt_stack_shrink_loop_exit_2102:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_2103:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2103
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2103
.L_lambda_opt_stack_shrink_loop_exit_2103:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b01:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51fb
          	mov rax, L_constants + 0
	jmp .L_if_end_51fb
          .L_if_else_51fb:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51f9
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51f9
          .L_if_else_51f9:
          	mov rax, L_constants + 2
.L_if_end_51f9:
	cmp rax, sob_boolean_false
          	je .L_if_else_51fa
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51fa
          .L_if_else_51fa:
          	mov rax, L_constants + 379
	push rax
	mov rax, L_constants + 370
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
.L_if_end_51fa:
.L_if_end_51fb:
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4837:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4837
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4837
.L_lambda_simple_env_end_4837:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4837:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4837
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4837
.L_lambda_simple_params_end_4837:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4837
	jmp .L_lambda_simple_end_4837
.L_lambda_simple_code_4837:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4837
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4837:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53b0:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53b0
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53b0
.L_tc_recycle_frame_done_53b0:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4837:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53af:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53af
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53af
.L_tc_recycle_frame_done_53af:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0b01:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4836:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_51], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, qword [free_var_52]
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4838:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4838
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4838
.L_lambda_simple_env_end_4838:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4838:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4838
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4838
.L_lambda_simple_params_end_4838:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4838
	jmp .L_lambda_simple_end_4838
.L_lambda_simple_code_4838:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4838
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4838:
	enter 0, 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b02:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0b02
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b02
.L_lambda_opt_env_end_0b02:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b02:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b02
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b02
.L_lambda_opt_params_end_0b02:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b02
	jmp .L_lambda_opt_end_0b02
.L_lambda_opt_code_0b02:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0b02
	jg .L_lambda_opt_arity_check_more_0b02
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b02:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2104:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2104
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2104
.L_lambda_opt_stack_shrink_loop_exit_2104:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b02
.L_lambda_opt_arity_check_more_0b02:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2105:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2105
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2105
.L_lambda_opt_stack_shrink_loop_exit_2105:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_2106:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2106
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2106
.L_lambda_opt_stack_shrink_loop_exit_2106:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b02:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51fe
          	mov rax, L_constants + 4
	jmp .L_if_end_51fe
          .L_if_else_51fe:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51fc
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51fc
          .L_if_else_51fc:
          	mov rax, L_constants + 2
.L_if_end_51fc:
	cmp rax, sob_boolean_false
          	je .L_if_else_51fd
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51fd
          .L_if_else_51fd:
          	mov rax, L_constants + 460
	push rax
	mov rax, L_constants + 451
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
.L_if_end_51fd:
.L_if_end_51fe:
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4839:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4839
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4839
.L_lambda_simple_env_end_4839:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4839:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4839
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4839
.L_lambda_simple_params_end_4839:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4839
	jmp .L_lambda_simple_end_4839
.L_lambda_simple_code_4839:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4839
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4839:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 1]
	mov rax, qword [rax + 8 * 0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53b2:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53b2
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53b2
.L_tc_recycle_frame_done_53b2:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4839:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53b1:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53b1
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53b1
.L_tc_recycle_frame_done_53b1:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0b02:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4838:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_52], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_483a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_483a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_483a
.L_lambda_simple_env_end_483a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_483a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_483a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_483a
.L_lambda_simple_params_end_483a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_483a
	jmp .L_lambda_simple_end_483a
.L_lambda_simple_code_483a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_483a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_483a:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_483b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_483b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_483b
.L_lambda_simple_env_end_483b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_483b:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_483b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_483b
.L_lambda_simple_params_end_483b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_483b
	jmp .L_lambda_simple_end_483b
.L_lambda_simple_code_483b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_483b
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_483b:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_51ff
          	mov rax, L_constants + 0
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_51]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53b3:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53b3
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53b3
.L_tc_recycle_frame_done_53b3:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_51ff
          .L_if_else_51ff:
          	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_483c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_483c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_483c
.L_lambda_simple_env_end_483c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_483c:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_483c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_483c
.L_lambda_simple_params_end_483c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_483c
	jmp .L_lambda_simple_end_483c
.L_lambda_simple_code_483c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_483c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_483c:
	enter 0, 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [free_var_49]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rax, qword [rbp + 8 * (4 + 0)]
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_483c:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53b4:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53b4
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53b4
.L_tc_recycle_frame_done_53b4:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_51ff:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_483b:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_483d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_483d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_483d
.L_lambda_simple_env_end_483d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_483d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_483d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_483d
.L_lambda_simple_params_end_483d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_483d
	jmp .L_lambda_simple_end_483d
.L_lambda_simple_code_483d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_483d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_483d:
	enter 0, 0
	mov rax, L_constants + 32
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53b5:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53b5
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53b5
.L_tc_recycle_frame_done_53b5:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_483d:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_483a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_135], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_483e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_483e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_483e
.L_lambda_simple_env_end_483e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_483e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_483e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_483e
.L_lambda_simple_params_end_483e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_483e
	jmp .L_lambda_simple_end_483e
.L_lambda_simple_code_483e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_483e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_483e:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_483f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_483f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_483f
.L_lambda_simple_env_end_483f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_483f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_483f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_483f
.L_lambda_simple_params_end_483f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_483f
	jmp .L_lambda_simple_end_483f
.L_lambda_simple_code_483f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_483f
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_483f:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_5200
          	mov rax, L_constants + 4
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_52]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53b6:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53b6
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53b6
.L_tc_recycle_frame_done_53b6:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_5200
          .L_if_else_5200:
          	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 2	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4840:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_4840
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4840
.L_lambda_simple_env_end_4840:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4840:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_4840
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4840
.L_lambda_simple_params_end_4840:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4840
	jmp .L_lambda_simple_end_4840
.L_lambda_simple_code_4840:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4840
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4840:
	enter 0, 0
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 1]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [free_var_50]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rax, qword [rbp + 8 * (4 + 0)]
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4840:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53b7:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53b7
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53b7
.L_tc_recycle_frame_done_53b7:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_5200:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_483f:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4841:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4841
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4841
.L_lambda_simple_env_end_4841:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4841:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4841
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4841
.L_lambda_simple_params_end_4841:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4841
	jmp .L_lambda_simple_end_4841
.L_lambda_simple_code_4841:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4841
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4841:
	enter 0, 0
	mov rax, L_constants + 32
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53b8:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53b8
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53b8
.L_tc_recycle_frame_done_53b8:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4841:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_483e:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_122], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b03:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_0b03
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b03
.L_lambda_opt_env_end_0b03:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b03:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_0b03
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b03
.L_lambda_opt_params_end_0b03:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b03
	jmp .L_lambda_opt_end_0b03
.L_lambda_opt_code_0b03:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b03
	jg .L_lambda_opt_arity_check_more_0b03
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b03:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2107:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2107
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2107
.L_lambda_opt_stack_shrink_loop_exit_2107:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b03
.L_lambda_opt_arity_check_more_0b03:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2108:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2108
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2108
.L_lambda_opt_stack_shrink_loop_exit_2108:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2109:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2109
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2109
.L_lambda_opt_stack_shrink_loop_exit_2109:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b03:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_135]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53b9:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53b9
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53b9
.L_tc_recycle_frame_done_53b9:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b03:	; new closure is in rax
	mov qword [free_var_136], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4842:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4842
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4842
.L_lambda_simple_env_end_4842:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4842:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4842
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4842
.L_lambda_simple_params_end_4842:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4842
	jmp .L_lambda_simple_end_4842
.L_lambda_simple_code_4842:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4842
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4842:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4843:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4843
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4843
.L_lambda_simple_env_end_4843:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4843:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4843
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4843
.L_lambda_simple_params_end_4843:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4843
	jmp .L_lambda_simple_end_4843
.L_lambda_simple_code_4843:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_4843
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4843:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_5201
          	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_47]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53ba:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53ba
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53ba
.L_tc_recycle_frame_done_53ba:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_5201
          .L_if_else_5201:
          	mov rax, L_constants + 1
.L_if_end_5201:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_4843:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4844:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4844
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4844
.L_lambda_simple_env_end_4844:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4844:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4844
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4844
.L_lambda_simple_params_end_4844:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4844
	jmp .L_lambda_simple_end_4844
.L_lambda_simple_code_4844:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4844
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4844:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, L_constants + 32
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 3 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53bb:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53bb
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53bb
.L_tc_recycle_frame_done_53bb:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4844:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4842:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_123], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 23
	push rax
	push 1
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4845:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4845
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4845
.L_lambda_simple_env_end_4845:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4845:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4845
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4845
.L_lambda_simple_params_end_4845:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4845
	jmp .L_lambda_simple_end_4845
.L_lambda_simple_code_4845:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4845
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4845:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	mov rdx, rax
	mov rdi, 8
	call malloc
	mov qword[rax], rdx
	mov qword [rbp + 8 * (4 + 0)], rax
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4846:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4846
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4846
.L_lambda_simple_env_end_4846:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4846:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4846
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4846
.L_lambda_simple_params_end_4846:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4846
	jmp .L_lambda_simple_end_4846
.L_lambda_simple_code_4846:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_4846
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4846:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_5202
          	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	mov rax, L_constants + 128
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 2
	mov rax, qword [free_var_97]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_48]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_13]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53bc:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53bc
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53bc
.L_tc_recycle_frame_done_53bc:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_5202
          .L_if_else_5202:
          	mov rax, L_constants + 1
.L_if_end_5202:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_4846:	; new closure is in rax
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	pop qword [rax]
	mov rax, sob_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4847:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_4847
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4847
.L_lambda_simple_env_end_4847:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4847:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_4847
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4847
.L_lambda_simple_params_end_4847:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4847
	jmp .L_lambda_simple_end_4847
.L_lambda_simple_code_4847:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4847
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4847:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_19]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, L_constants + 32
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 3
	mov rax, qword [rbp + 8 * 2]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax + 8 * 0]
	mov rax, qword [rax]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 3 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53bd:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53bd
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53bd
.L_tc_recycle_frame_done_53bd:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4847:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4845:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	mov qword [free_var_137], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4848:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4848
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4848
.L_lambda_simple_env_end_4848:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4848:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4848
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4848
.L_lambda_simple_params_end_4848:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4848
	jmp .L_lambda_simple_end_4848
.L_lambda_simple_code_4848:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4848
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4848:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 0
	mov rax, qword [free_var_26]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_44]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53be:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53be
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53be
.L_tc_recycle_frame_done_53be:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4848:	; new closure is in rax
	mov qword [free_var_138], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_4849:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_4849
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_4849
.L_lambda_simple_env_end_4849:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_4849:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_4849
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_4849
.L_lambda_simple_params_end_4849:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_4849
	jmp .L_lambda_simple_end_4849
.L_lambda_simple_code_4849:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_4849
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_4849:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, L_constants + 32
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53bf:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53bf
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53bf
.L_tc_recycle_frame_done_53bf:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_4849:	; new closure is in rax
	mov qword [free_var_139], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_484a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_484a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_484a
.L_lambda_simple_env_end_484a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_484a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_484a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_484a
.L_lambda_simple_params_end_484a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_484a
	jmp .L_lambda_simple_end_484a
.L_lambda_simple_code_484a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_484a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_484a:
	enter 0, 0
	mov rax, L_constants + 32
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53c0:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53c0
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53c0
.L_tc_recycle_frame_done_53c0:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_484a:	; new closure is in rax
	mov qword [free_var_140], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_484b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_484b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_484b
.L_lambda_simple_env_end_484b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_484b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_484b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_484b
.L_lambda_simple_params_end_484b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_484b
	jmp .L_lambda_simple_end_484b
.L_lambda_simple_code_484b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_484b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_484b:
	enter 0, 0
	mov rax, L_constants + 512
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_44]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_27]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53c1:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53c1
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53c1
.L_tc_recycle_frame_done_53c1:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_484b:	; new closure is in rax
	mov qword [free_var_141], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_484c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_484c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_484c
.L_lambda_simple_env_end_484c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_484c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_484c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_484c
.L_lambda_simple_params_end_484c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_484c
	jmp .L_lambda_simple_end_484c
.L_lambda_simple_code_484c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_484c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_484c:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_141]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 1
	mov rax, qword [free_var_86]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53c2:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53c2
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53c2
.L_tc_recycle_frame_done_53c2:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_484c:	; new closure is in rax
	mov qword [free_var_142], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_484d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_484d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_484d
.L_lambda_simple_env_end_484d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_484d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_484d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_484d
.L_lambda_simple_params_end_484d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_484d
	jmp .L_lambda_simple_end_484d
.L_lambda_simple_code_484d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_484d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_484d:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_140]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_5203
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_98]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53c3:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53c3
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53c3
.L_tc_recycle_frame_done_53c3:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_5203
          .L_if_else_5203:
          	mov rax, qword [rbp + 8 * (4 + 0)]
.L_if_end_5203:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_484d:	; new closure is in rax
	mov qword [free_var_143], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_484e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_484e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_484e
.L_lambda_simple_env_end_484e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_484e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_484e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_484e
.L_lambda_simple_params_end_484e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_484e
	jmp .L_lambda_simple_end_484e
.L_lambda_simple_code_484e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_484e
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_484e:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_5204
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_5204
          .L_if_else_5204:
          	mov rax, L_constants + 2
.L_if_end_5204:
	cmp rax, sob_boolean_false
          	je .L_if_else_520c
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_144]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_5205
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_144]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53c4:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53c4
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53c4
.L_tc_recycle_frame_done_53c4:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_5205
          .L_if_else_5205:
          	mov rax, L_constants + 2
.L_if_end_5205:
	jmp .L_if_end_520c
          .L_if_else_520c:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_6]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_5207
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_6]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_5206
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_19]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_19]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_5206
          .L_if_else_5206:
          	mov rax, L_constants + 2
.L_if_end_5206:
	jmp .L_if_end_5207
          .L_if_else_5207:
          	mov rax, L_constants + 2
.L_if_end_5207:
	cmp rax, sob_boolean_false
          	je .L_if_else_520b
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_137]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_137]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_144]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53c5:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53c5
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53c5
.L_tc_recycle_frame_done_53c5:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_520b
          .L_if_else_520b:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_4]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_5209
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_4]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_5208
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_18]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_106]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_5208
          .L_if_else_5208:
          	mov rax, L_constants + 2
.L_if_end_5208:
	jmp .L_if_end_5209
          .L_if_else_5209:
          	mov rax, L_constants + 2
.L_if_end_5209:
	cmp rax, sob_boolean_false
          	je .L_if_else_520a
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_126]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53c6:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53c6
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53c6
.L_tc_recycle_frame_done_53c6:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_520a
          .L_if_else_520a:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_55]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53c7:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53c7
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53c7
.L_tc_recycle_frame_done_53c7:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_520a:
.L_if_end_520b:
.L_if_end_520c:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_484e:	; new closure is in rax
	mov qword [free_var_144], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_simple_env_loop_484f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_484f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_484f
.L_lambda_simple_env_end_484f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_484f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_484f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_484f
.L_lambda_simple_params_end_484f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_484f
	jmp .L_lambda_simple_end_484f
.L_lambda_simple_code_484f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_484f
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_484f:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_520e
          	mov rax, L_constants + 2
	jmp .L_if_end_520e
          .L_if_else_520e:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_56]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	push 2
	mov rax, qword [free_var_55]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_520d
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53c8:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53c8
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53c8
.L_tc_recycle_frame_done_53c8:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_520d
          .L_if_else_520d:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_17]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	push rax
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 2
	mov rax, qword [free_var_145]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53c9:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53c9
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53c9
.L_tc_recycle_frame_done_53c9:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_520d:
.L_if_end_520e:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_484f:	; new closure is in rax
	mov qword [free_var_145], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 0	; new rib
	call malloc
	push rax
	mov rdi, 8 * 1	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b04:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_0b04
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b04
.L_lambda_opt_env_end_0b04:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b04:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_0b04
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b04
.L_lambda_opt_params_end_0b04:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b04
	jmp .L_lambda_opt_end_0b04
.L_lambda_opt_code_0b04:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b04
	jg .L_lambda_opt_arity_check_more_0b04
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b04:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_210a:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_210a
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_210a
.L_lambda_opt_stack_shrink_loop_exit_210a:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b04
.L_lambda_opt_arity_check_more_0b04:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_210b:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_210b
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_210b
.L_lambda_opt_stack_shrink_loop_exit_210b:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_210c:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_210c
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_210c
.L_lambda_opt_stack_shrink_loop_exit_210c:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b04:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 2	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b05:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0b05
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b05
.L_lambda_opt_env_end_0b05:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b05:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b05
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b05
.L_lambda_opt_params_end_0b05:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b05
	jmp .L_lambda_opt_end_0b05
.L_lambda_opt_code_0b05:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b05
	jg .L_lambda_opt_arity_check_more_0b05
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b05:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_210d:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_210d
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_210d
.L_lambda_opt_stack_shrink_loop_exit_210d:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b05
.L_lambda_opt_arity_check_more_0b05:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_210e:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_210e
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_210e
.L_lambda_opt_stack_shrink_loop_exit_210e:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_210f:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_210f
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_210f
.L_lambda_opt_stack_shrink_loop_exit_210f:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b05:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 3	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b06:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_0b06
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b06
.L_lambda_opt_env_end_0b06:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b06:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b06
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b06
.L_lambda_opt_params_end_0b06:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b06
	jmp .L_lambda_opt_end_0b06
.L_lambda_opt_code_0b06:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b06
	jg .L_lambda_opt_arity_check_more_0b06
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b06:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2110:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2110
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2110
.L_lambda_opt_stack_shrink_loop_exit_2110:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b06
.L_lambda_opt_arity_check_more_0b06:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2111:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2111
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2111
.L_lambda_opt_stack_shrink_loop_exit_2111:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2112:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2112
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2112
.L_lambda_opt_stack_shrink_loop_exit_2112:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b06:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 4	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b07:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_opt_env_end_0b07
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b07
.L_lambda_opt_env_end_0b07:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b07:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b07
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b07
.L_lambda_opt_params_end_0b07:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b07
	jmp .L_lambda_opt_end_0b07
.L_lambda_opt_code_0b07:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b07
	jg .L_lambda_opt_arity_check_more_0b07
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b07:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2113:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2113
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2113
.L_lambda_opt_stack_shrink_loop_exit_2113:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b07
.L_lambda_opt_arity_check_more_0b07:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2114:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2114
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2114
.L_lambda_opt_stack_shrink_loop_exit_2114:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2115:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2115
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2115
.L_lambda_opt_stack_shrink_loop_exit_2115:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b07:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 5	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b08:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_0b08
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b08
.L_lambda_opt_env_end_0b08:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b08:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b08
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b08
.L_lambda_opt_params_end_0b08:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b08
	jmp .L_lambda_opt_end_0b08
.L_lambda_opt_code_0b08:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b08
	jg .L_lambda_opt_arity_check_more_0b08
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b08:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2116:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2116
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2116
.L_lambda_opt_stack_shrink_loop_exit_2116:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b08
.L_lambda_opt_arity_check_more_0b08:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2117:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2117
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2117
.L_lambda_opt_stack_shrink_loop_exit_2117:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2118:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2118
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2118
.L_lambda_opt_stack_shrink_loop_exit_2118:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b08:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 6	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b09:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 5
	je .L_lambda_opt_env_end_0b09
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b09
.L_lambda_opt_env_end_0b09:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b09:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b09
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b09
.L_lambda_opt_params_end_0b09:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b09
	jmp .L_lambda_opt_end_0b09
.L_lambda_opt_code_0b09:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b09
	jg .L_lambda_opt_arity_check_more_0b09
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b09:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2119:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2119
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2119
.L_lambda_opt_stack_shrink_loop_exit_2119:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b09
.L_lambda_opt_arity_check_more_0b09:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_211a:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_211a
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_211a
.L_lambda_opt_stack_shrink_loop_exit_211a:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_211b:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_211b
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_211b
.L_lambda_opt_stack_shrink_loop_exit_211b:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b09:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 7	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b0a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 6
	je .L_lambda_opt_env_end_0b0a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b0a
.L_lambda_opt_env_end_0b0a:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b0a:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b0a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b0a
.L_lambda_opt_params_end_0b0a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b0a
	jmp .L_lambda_opt_end_0b0a
.L_lambda_opt_code_0b0a:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b0a
	jg .L_lambda_opt_arity_check_more_0b0a
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b0a:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_211c:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_211c
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_211c
.L_lambda_opt_stack_shrink_loop_exit_211c:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b0a
.L_lambda_opt_arity_check_more_0b0a:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_211d:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_211d
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_211d
.L_lambda_opt_stack_shrink_loop_exit_211d:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_211e:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_211e
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_211e
.L_lambda_opt_stack_shrink_loop_exit_211e:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b0a:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 8	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b0b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 7
	je .L_lambda_opt_env_end_0b0b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b0b
.L_lambda_opt_env_end_0b0b:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b0b:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b0b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b0b
.L_lambda_opt_params_end_0b0b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b0b
	jmp .L_lambda_opt_end_0b0b
.L_lambda_opt_code_0b0b:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b0b
	jg .L_lambda_opt_arity_check_more_0b0b
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b0b:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_211f:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_211f
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_211f
.L_lambda_opt_stack_shrink_loop_exit_211f:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b0b
.L_lambda_opt_arity_check_more_0b0b:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2120:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2120
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2120
.L_lambda_opt_stack_shrink_loop_exit_2120:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2121:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2121
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2121
.L_lambda_opt_stack_shrink_loop_exit_2121:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b0b:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 9	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b0c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 8
	je .L_lambda_opt_env_end_0b0c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b0c
.L_lambda_opt_env_end_0b0c:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b0c:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b0c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b0c
.L_lambda_opt_params_end_0b0c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b0c
	jmp .L_lambda_opt_end_0b0c
.L_lambda_opt_code_0b0c:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b0c
	jg .L_lambda_opt_arity_check_more_0b0c
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b0c:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2122:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2122
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2122
.L_lambda_opt_stack_shrink_loop_exit_2122:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b0c
.L_lambda_opt_arity_check_more_0b0c:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2123:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2123
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2123
.L_lambda_opt_stack_shrink_loop_exit_2123:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2124:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2124
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2124
.L_lambda_opt_stack_shrink_loop_exit_2124:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b0c:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 10	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b0d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 9
	je .L_lambda_opt_env_end_0b0d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b0d
.L_lambda_opt_env_end_0b0d:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b0d:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b0d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b0d
.L_lambda_opt_params_end_0b0d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b0d
	jmp .L_lambda_opt_end_0b0d
.L_lambda_opt_code_0b0d:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b0d
	jg .L_lambda_opt_arity_check_more_0b0d
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b0d:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2125:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2125
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2125
.L_lambda_opt_stack_shrink_loop_exit_2125:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b0d
.L_lambda_opt_arity_check_more_0b0d:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2126:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2126
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2126
.L_lambda_opt_stack_shrink_loop_exit_2126:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2127:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2127
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2127
.L_lambda_opt_stack_shrink_loop_exit_2127:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b0d:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 11	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b0e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 10
	je .L_lambda_opt_env_end_0b0e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b0e
.L_lambda_opt_env_end_0b0e:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b0e:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b0e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b0e
.L_lambda_opt_params_end_0b0e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b0e
	jmp .L_lambda_opt_end_0b0e
.L_lambda_opt_code_0b0e:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b0e
	jg .L_lambda_opt_arity_check_more_0b0e
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b0e:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2128:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2128
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2128
.L_lambda_opt_stack_shrink_loop_exit_2128:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b0e
.L_lambda_opt_arity_check_more_0b0e:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2129:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2129
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2129
.L_lambda_opt_stack_shrink_loop_exit_2129:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_212a:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_212a
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_212a
.L_lambda_opt_stack_shrink_loop_exit_212a:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b0e:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 12	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b0f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 11
	je .L_lambda_opt_env_end_0b0f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b0f
.L_lambda_opt_env_end_0b0f:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b0f:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b0f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b0f
.L_lambda_opt_params_end_0b0f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b0f
	jmp .L_lambda_opt_end_0b0f
.L_lambda_opt_code_0b0f:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b0f
	jg .L_lambda_opt_arity_check_more_0b0f
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b0f:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_212b:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_212b
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_212b
.L_lambda_opt_stack_shrink_loop_exit_212b:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b0f
.L_lambda_opt_arity_check_more_0b0f:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_212c:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_212c
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_212c
.L_lambda_opt_stack_shrink_loop_exit_212c:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_212d:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_212d
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_212d
.L_lambda_opt_stack_shrink_loop_exit_212d:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b0f:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 13	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b10:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 12
	je .L_lambda_opt_env_end_0b10
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b10
.L_lambda_opt_env_end_0b10:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b10:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b10
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b10
.L_lambda_opt_params_end_0b10:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b10
	jmp .L_lambda_opt_end_0b10
.L_lambda_opt_code_0b10:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b10
	jg .L_lambda_opt_arity_check_more_0b10
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b10:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_212e:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_212e
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_212e
.L_lambda_opt_stack_shrink_loop_exit_212e:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b10
.L_lambda_opt_arity_check_more_0b10:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_212f:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_212f
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_212f
.L_lambda_opt_stack_shrink_loop_exit_212f:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2130:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2130
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2130
.L_lambda_opt_stack_shrink_loop_exit_2130:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b10:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 14	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b11:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 13
	je .L_lambda_opt_env_end_0b11
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b11
.L_lambda_opt_env_end_0b11:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b11:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b11
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b11
.L_lambda_opt_params_end_0b11:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b11
	jmp .L_lambda_opt_end_0b11
.L_lambda_opt_code_0b11:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b11
	jg .L_lambda_opt_arity_check_more_0b11
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b11:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2131:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2131
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2131
.L_lambda_opt_stack_shrink_loop_exit_2131:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b11
.L_lambda_opt_arity_check_more_0b11:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2132:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2132
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2132
.L_lambda_opt_stack_shrink_loop_exit_2132:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2133:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2133
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2133
.L_lambda_opt_stack_shrink_loop_exit_2133:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b11:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 15	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b12:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 14
	je .L_lambda_opt_env_end_0b12
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b12
.L_lambda_opt_env_end_0b12:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b12:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b12
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b12
.L_lambda_opt_params_end_0b12:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b12
	jmp .L_lambda_opt_end_0b12
.L_lambda_opt_code_0b12:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b12
	jg .L_lambda_opt_arity_check_more_0b12
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b12:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2134:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2134
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2134
.L_lambda_opt_stack_shrink_loop_exit_2134:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b12
.L_lambda_opt_arity_check_more_0b12:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2135:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2135
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2135
.L_lambda_opt_stack_shrink_loop_exit_2135:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2136:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2136
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2136
.L_lambda_opt_stack_shrink_loop_exit_2136:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b12:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 16	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b13:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 15
	je .L_lambda_opt_env_end_0b13
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b13
.L_lambda_opt_env_end_0b13:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b13:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b13
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b13
.L_lambda_opt_params_end_0b13:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b13
	jmp .L_lambda_opt_end_0b13
.L_lambda_opt_code_0b13:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b13
	jg .L_lambda_opt_arity_check_more_0b13
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b13:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2137:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2137
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2137
.L_lambda_opt_stack_shrink_loop_exit_2137:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b13
.L_lambda_opt_arity_check_more_0b13:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2138:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2138
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2138
.L_lambda_opt_stack_shrink_loop_exit_2138:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2139:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2139
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2139
.L_lambda_opt_stack_shrink_loop_exit_2139:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b13:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 17	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b14:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 16
	je .L_lambda_opt_env_end_0b14
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b14
.L_lambda_opt_env_end_0b14:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b14:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b14
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b14
.L_lambda_opt_params_end_0b14:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b14
	jmp .L_lambda_opt_end_0b14
.L_lambda_opt_code_0b14:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b14
	jg .L_lambda_opt_arity_check_more_0b14
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b14:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_213a:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_213a
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_213a
.L_lambda_opt_stack_shrink_loop_exit_213a:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b14
.L_lambda_opt_arity_check_more_0b14:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_213b:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_213b
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_213b
.L_lambda_opt_stack_shrink_loop_exit_213b:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_213c:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_213c
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_213c
.L_lambda_opt_stack_shrink_loop_exit_213c:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b14:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 18	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b15:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 17
	je .L_lambda_opt_env_end_0b15
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b15
.L_lambda_opt_env_end_0b15:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b15:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b15
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b15
.L_lambda_opt_params_end_0b15:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b15
	jmp .L_lambda_opt_end_0b15
.L_lambda_opt_code_0b15:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b15
	jg .L_lambda_opt_arity_check_more_0b15
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b15:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_213d:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_213d
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_213d
.L_lambda_opt_stack_shrink_loop_exit_213d:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b15
.L_lambda_opt_arity_check_more_0b15:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_213e:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_213e
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_213e
.L_lambda_opt_stack_shrink_loop_exit_213e:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_213f:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_213f
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_213f
.L_lambda_opt_stack_shrink_loop_exit_213f:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b15:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 19	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b16:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 18
	je .L_lambda_opt_env_end_0b16
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b16
.L_lambda_opt_env_end_0b16:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b16:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b16
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b16
.L_lambda_opt_params_end_0b16:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b16
	jmp .L_lambda_opt_end_0b16
.L_lambda_opt_code_0b16:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b16
	jg .L_lambda_opt_arity_check_more_0b16
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b16:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2140:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2140
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2140
.L_lambda_opt_stack_shrink_loop_exit_2140:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b16
.L_lambda_opt_arity_check_more_0b16:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2141:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2141
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2141
.L_lambda_opt_stack_shrink_loop_exit_2141:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2142:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2142
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2142
.L_lambda_opt_stack_shrink_loop_exit_2142:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b16:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 20	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b17:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 19
	je .L_lambda_opt_env_end_0b17
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b17
.L_lambda_opt_env_end_0b17:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b17:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b17
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b17
.L_lambda_opt_params_end_0b17:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b17
	jmp .L_lambda_opt_end_0b17
.L_lambda_opt_code_0b17:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b17
	jg .L_lambda_opt_arity_check_more_0b17
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b17:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2143:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2143
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2143
.L_lambda_opt_stack_shrink_loop_exit_2143:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b17
.L_lambda_opt_arity_check_more_0b17:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2144:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2144
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2144
.L_lambda_opt_stack_shrink_loop_exit_2144:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2145:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2145
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2145
.L_lambda_opt_stack_shrink_loop_exit_2145:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b17:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 21	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b18:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 20
	je .L_lambda_opt_env_end_0b18
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b18
.L_lambda_opt_env_end_0b18:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b18:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b18
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b18
.L_lambda_opt_params_end_0b18:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b18
	jmp .L_lambda_opt_end_0b18
.L_lambda_opt_code_0b18:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b18
	jg .L_lambda_opt_arity_check_more_0b18
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b18:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2146:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2146
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2146
.L_lambda_opt_stack_shrink_loop_exit_2146:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b18
.L_lambda_opt_arity_check_more_0b18:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2147:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2147
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2147
.L_lambda_opt_stack_shrink_loop_exit_2147:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2148:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2148
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2148
.L_lambda_opt_stack_shrink_loop_exit_2148:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b18:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 22	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b19:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 21
	je .L_lambda_opt_env_end_0b19
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b19
.L_lambda_opt_env_end_0b19:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b19:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b19
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b19
.L_lambda_opt_params_end_0b19:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b19
	jmp .L_lambda_opt_end_0b19
.L_lambda_opt_code_0b19:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b19
	jg .L_lambda_opt_arity_check_more_0b19
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b19:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2149:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2149
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2149
.L_lambda_opt_stack_shrink_loop_exit_2149:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b19
.L_lambda_opt_arity_check_more_0b19:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_214a:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_214a
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_214a
.L_lambda_opt_stack_shrink_loop_exit_214a:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_214b:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_214b
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_214b
.L_lambda_opt_stack_shrink_loop_exit_214b:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b19:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 23	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b1a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 22
	je .L_lambda_opt_env_end_0b1a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b1a
.L_lambda_opt_env_end_0b1a:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b1a:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b1a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b1a
.L_lambda_opt_params_end_0b1a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b1a
	jmp .L_lambda_opt_end_0b1a
.L_lambda_opt_code_0b1a:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b1a
	jg .L_lambda_opt_arity_check_more_0b1a
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b1a:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_214c:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_214c
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_214c
.L_lambda_opt_stack_shrink_loop_exit_214c:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b1a
.L_lambda_opt_arity_check_more_0b1a:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_214d:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_214d
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_214d
.L_lambda_opt_stack_shrink_loop_exit_214d:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_214e:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_214e
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_214e
.L_lambda_opt_stack_shrink_loop_exit_214e:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b1a:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 24	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b1b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 23
	je .L_lambda_opt_env_end_0b1b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b1b
.L_lambda_opt_env_end_0b1b:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b1b:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b1b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b1b
.L_lambda_opt_params_end_0b1b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b1b
	jmp .L_lambda_opt_end_0b1b
.L_lambda_opt_code_0b1b:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b1b
	jg .L_lambda_opt_arity_check_more_0b1b
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b1b:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_214f:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_214f
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_214f
.L_lambda_opt_stack_shrink_loop_exit_214f:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b1b
.L_lambda_opt_arity_check_more_0b1b:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2150:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2150
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2150
.L_lambda_opt_stack_shrink_loop_exit_2150:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2151:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2151
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2151
.L_lambda_opt_stack_shrink_loop_exit_2151:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b1b:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 25	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b1c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 24
	je .L_lambda_opt_env_end_0b1c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b1c
.L_lambda_opt_env_end_0b1c:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b1c:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b1c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b1c
.L_lambda_opt_params_end_0b1c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b1c
	jmp .L_lambda_opt_end_0b1c
.L_lambda_opt_code_0b1c:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b1c
	jg .L_lambda_opt_arity_check_more_0b1c
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b1c:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2152:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2152
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2152
.L_lambda_opt_stack_shrink_loop_exit_2152:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b1c
.L_lambda_opt_arity_check_more_0b1c:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2153:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2153
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2153
.L_lambda_opt_stack_shrink_loop_exit_2153:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2154:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2154
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2154
.L_lambda_opt_stack_shrink_loop_exit_2154:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b1c:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 26	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b1d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 25
	je .L_lambda_opt_env_end_0b1d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b1d
.L_lambda_opt_env_end_0b1d:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b1d:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b1d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b1d
.L_lambda_opt_params_end_0b1d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b1d
	jmp .L_lambda_opt_end_0b1d
.L_lambda_opt_code_0b1d:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b1d
	jg .L_lambda_opt_arity_check_more_0b1d
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b1d:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2155:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2155
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2155
.L_lambda_opt_stack_shrink_loop_exit_2155:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b1d
.L_lambda_opt_arity_check_more_0b1d:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2156:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2156
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2156
.L_lambda_opt_stack_shrink_loop_exit_2156:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2157:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2157
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2157
.L_lambda_opt_stack_shrink_loop_exit_2157:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b1d:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 27	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b1e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 26
	je .L_lambda_opt_env_end_0b1e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b1e
.L_lambda_opt_env_end_0b1e:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b1e:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b1e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b1e
.L_lambda_opt_params_end_0b1e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b1e
	jmp .L_lambda_opt_end_0b1e
.L_lambda_opt_code_0b1e:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b1e
	jg .L_lambda_opt_arity_check_more_0b1e
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b1e:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2158:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2158
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2158
.L_lambda_opt_stack_shrink_loop_exit_2158:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b1e
.L_lambda_opt_arity_check_more_0b1e:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2159:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2159
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2159
.L_lambda_opt_stack_shrink_loop_exit_2159:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_215a:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_215a
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_215a
.L_lambda_opt_stack_shrink_loop_exit_215a:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b1e:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 28	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b1f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 27
	je .L_lambda_opt_env_end_0b1f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b1f
.L_lambda_opt_env_end_0b1f:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b1f:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b1f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b1f
.L_lambda_opt_params_end_0b1f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b1f
	jmp .L_lambda_opt_end_0b1f
.L_lambda_opt_code_0b1f:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b1f
	jg .L_lambda_opt_arity_check_more_0b1f
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b1f:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_215b:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_215b
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_215b
.L_lambda_opt_stack_shrink_loop_exit_215b:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b1f
.L_lambda_opt_arity_check_more_0b1f:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_215c:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_215c
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_215c
.L_lambda_opt_stack_shrink_loop_exit_215c:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_215d:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_215d
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_215d
.L_lambda_opt_stack_shrink_loop_exit_215d:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b1f:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 29	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b20:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 28
	je .L_lambda_opt_env_end_0b20
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b20
.L_lambda_opt_env_end_0b20:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b20:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b20
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b20
.L_lambda_opt_params_end_0b20:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b20
	jmp .L_lambda_opt_end_0b20
.L_lambda_opt_code_0b20:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b20
	jg .L_lambda_opt_arity_check_more_0b20
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b20:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_215e:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_215e
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_215e
.L_lambda_opt_stack_shrink_loop_exit_215e:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b20
.L_lambda_opt_arity_check_more_0b20:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_215f:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_215f
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_215f
.L_lambda_opt_stack_shrink_loop_exit_215f:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2160:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2160
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2160
.L_lambda_opt_stack_shrink_loop_exit_2160:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b20:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 30	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b21:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 29
	je .L_lambda_opt_env_end_0b21
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b21
.L_lambda_opt_env_end_0b21:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b21:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b21
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b21
.L_lambda_opt_params_end_0b21:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b21
	jmp .L_lambda_opt_end_0b21
.L_lambda_opt_code_0b21:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b21
	jg .L_lambda_opt_arity_check_more_0b21
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b21:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2161:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2161
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2161
.L_lambda_opt_stack_shrink_loop_exit_2161:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b21
.L_lambda_opt_arity_check_more_0b21:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2162:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2162
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2162
.L_lambda_opt_stack_shrink_loop_exit_2162:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2163:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2163
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2163
.L_lambda_opt_stack_shrink_loop_exit_2163:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b21:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 31	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b22:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 30
	je .L_lambda_opt_env_end_0b22
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b22
.L_lambda_opt_env_end_0b22:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b22:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b22
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b22
.L_lambda_opt_params_end_0b22:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b22
	jmp .L_lambda_opt_end_0b22
.L_lambda_opt_code_0b22:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b22
	jg .L_lambda_opt_arity_check_more_0b22
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b22:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2164:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2164
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2164
.L_lambda_opt_stack_shrink_loop_exit_2164:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b22
.L_lambda_opt_arity_check_more_0b22:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2165:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2165
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2165
.L_lambda_opt_stack_shrink_loop_exit_2165:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2166:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2166
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2166
.L_lambda_opt_stack_shrink_loop_exit_2166:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b22:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 32	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b23:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 31
	je .L_lambda_opt_env_end_0b23
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b23
.L_lambda_opt_env_end_0b23:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b23:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b23
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b23
.L_lambda_opt_params_end_0b23:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b23
	jmp .L_lambda_opt_end_0b23
.L_lambda_opt_code_0b23:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b23
	jg .L_lambda_opt_arity_check_more_0b23
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b23:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2167:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2167
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2167
.L_lambda_opt_stack_shrink_loop_exit_2167:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b23
.L_lambda_opt_arity_check_more_0b23:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2168:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2168
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2168
.L_lambda_opt_stack_shrink_loop_exit_2168:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2169:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2169
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2169
.L_lambda_opt_stack_shrink_loop_exit_2169:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b23:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 33	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b24:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 32
	je .L_lambda_opt_env_end_0b24
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b24
.L_lambda_opt_env_end_0b24:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b24:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b24
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b24
.L_lambda_opt_params_end_0b24:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b24
	jmp .L_lambda_opt_end_0b24
.L_lambda_opt_code_0b24:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b24
	jg .L_lambda_opt_arity_check_more_0b24
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b24:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_216a:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_216a
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_216a
.L_lambda_opt_stack_shrink_loop_exit_216a:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b24
.L_lambda_opt_arity_check_more_0b24:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_216b:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_216b
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_216b
.L_lambda_opt_stack_shrink_loop_exit_216b:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_216c:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_216c
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_216c
.L_lambda_opt_stack_shrink_loop_exit_216c:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b24:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 34	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b25:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 33
	je .L_lambda_opt_env_end_0b25
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b25
.L_lambda_opt_env_end_0b25:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b25:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b25
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b25
.L_lambda_opt_params_end_0b25:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b25
	jmp .L_lambda_opt_end_0b25
.L_lambda_opt_code_0b25:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b25
	jg .L_lambda_opt_arity_check_more_0b25
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b25:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_216d:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_216d
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_216d
.L_lambda_opt_stack_shrink_loop_exit_216d:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b25
.L_lambda_opt_arity_check_more_0b25:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_216e:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_216e
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_216e
.L_lambda_opt_stack_shrink_loop_exit_216e:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_216f:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_216f
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_216f
.L_lambda_opt_stack_shrink_loop_exit_216f:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b25:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 35	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b26:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 34
	je .L_lambda_opt_env_end_0b26
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b26
.L_lambda_opt_env_end_0b26:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b26:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b26
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b26
.L_lambda_opt_params_end_0b26:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b26
	jmp .L_lambda_opt_end_0b26
.L_lambda_opt_code_0b26:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b26
	jg .L_lambda_opt_arity_check_more_0b26
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b26:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2170:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2170
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2170
.L_lambda_opt_stack_shrink_loop_exit_2170:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b26
.L_lambda_opt_arity_check_more_0b26:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2171:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2171
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2171
.L_lambda_opt_stack_shrink_loop_exit_2171:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2172:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2172
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2172
.L_lambda_opt_stack_shrink_loop_exit_2172:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b26:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 36	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b27:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 35
	je .L_lambda_opt_env_end_0b27
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b27
.L_lambda_opt_env_end_0b27:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b27:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b27
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b27
.L_lambda_opt_params_end_0b27:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b27
	jmp .L_lambda_opt_end_0b27
.L_lambda_opt_code_0b27:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b27
	jg .L_lambda_opt_arity_check_more_0b27
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b27:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2173:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2173
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2173
.L_lambda_opt_stack_shrink_loop_exit_2173:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b27
.L_lambda_opt_arity_check_more_0b27:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2174:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2174
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2174
.L_lambda_opt_stack_shrink_loop_exit_2174:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2175:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2175
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2175
.L_lambda_opt_stack_shrink_loop_exit_2175:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b27:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 37	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b28:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 36
	je .L_lambda_opt_env_end_0b28
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b28
.L_lambda_opt_env_end_0b28:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b28:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b28
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b28
.L_lambda_opt_params_end_0b28:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b28
	jmp .L_lambda_opt_end_0b28
.L_lambda_opt_code_0b28:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b28
	jg .L_lambda_opt_arity_check_more_0b28
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b28:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2176:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2176
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2176
.L_lambda_opt_stack_shrink_loop_exit_2176:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b28
.L_lambda_opt_arity_check_more_0b28:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2177:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2177
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2177
.L_lambda_opt_stack_shrink_loop_exit_2177:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2178:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2178
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2178
.L_lambda_opt_stack_shrink_loop_exit_2178:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b28:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 38	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b29:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 37
	je .L_lambda_opt_env_end_0b29
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b29
.L_lambda_opt_env_end_0b29:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b29:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b29
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b29
.L_lambda_opt_params_end_0b29:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b29
	jmp .L_lambda_opt_end_0b29
.L_lambda_opt_code_0b29:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b29
	jg .L_lambda_opt_arity_check_more_0b29
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b29:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2179:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2179
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2179
.L_lambda_opt_stack_shrink_loop_exit_2179:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b29
.L_lambda_opt_arity_check_more_0b29:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_217a:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_217a
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_217a
.L_lambda_opt_stack_shrink_loop_exit_217a:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_217b:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_217b
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_217b
.L_lambda_opt_stack_shrink_loop_exit_217b:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b29:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 39	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b2a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 38
	je .L_lambda_opt_env_end_0b2a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b2a
.L_lambda_opt_env_end_0b2a:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b2a:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b2a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b2a
.L_lambda_opt_params_end_0b2a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b2a
	jmp .L_lambda_opt_end_0b2a
.L_lambda_opt_code_0b2a:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b2a
	jg .L_lambda_opt_arity_check_more_0b2a
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b2a:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_217c:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_217c
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_217c
.L_lambda_opt_stack_shrink_loop_exit_217c:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b2a
.L_lambda_opt_arity_check_more_0b2a:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_217d:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_217d
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_217d
.L_lambda_opt_stack_shrink_loop_exit_217d:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_217e:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_217e
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_217e
.L_lambda_opt_stack_shrink_loop_exit_217e:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b2a:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 40	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b2b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 39
	je .L_lambda_opt_env_end_0b2b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b2b
.L_lambda_opt_env_end_0b2b:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b2b:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b2b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b2b
.L_lambda_opt_params_end_0b2b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b2b
	jmp .L_lambda_opt_end_0b2b
.L_lambda_opt_code_0b2b:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b2b
	jg .L_lambda_opt_arity_check_more_0b2b
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b2b:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_217f:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_217f
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_217f
.L_lambda_opt_stack_shrink_loop_exit_217f:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b2b
.L_lambda_opt_arity_check_more_0b2b:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2180:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2180
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2180
.L_lambda_opt_stack_shrink_loop_exit_2180:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2181:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2181
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2181
.L_lambda_opt_stack_shrink_loop_exit_2181:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b2b:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 41	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b2c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 40
	je .L_lambda_opt_env_end_0b2c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b2c
.L_lambda_opt_env_end_0b2c:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b2c:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b2c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b2c
.L_lambda_opt_params_end_0b2c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b2c
	jmp .L_lambda_opt_end_0b2c
.L_lambda_opt_code_0b2c:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b2c
	jg .L_lambda_opt_arity_check_more_0b2c
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b2c:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2182:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2182
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2182
.L_lambda_opt_stack_shrink_loop_exit_2182:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b2c
.L_lambda_opt_arity_check_more_0b2c:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2183:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2183
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2183
.L_lambda_opt_stack_shrink_loop_exit_2183:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2184:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2184
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2184
.L_lambda_opt_stack_shrink_loop_exit_2184:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b2c:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 42	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b2d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 41
	je .L_lambda_opt_env_end_0b2d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b2d
.L_lambda_opt_env_end_0b2d:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b2d:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b2d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b2d
.L_lambda_opt_params_end_0b2d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b2d
	jmp .L_lambda_opt_end_0b2d
.L_lambda_opt_code_0b2d:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b2d
	jg .L_lambda_opt_arity_check_more_0b2d
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b2d:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2185:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2185
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2185
.L_lambda_opt_stack_shrink_loop_exit_2185:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b2d
.L_lambda_opt_arity_check_more_0b2d:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2186:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2186
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2186
.L_lambda_opt_stack_shrink_loop_exit_2186:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2187:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2187
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2187
.L_lambda_opt_stack_shrink_loop_exit_2187:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b2d:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 43	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b2e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 42
	je .L_lambda_opt_env_end_0b2e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b2e
.L_lambda_opt_env_end_0b2e:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b2e:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b2e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b2e
.L_lambda_opt_params_end_0b2e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b2e
	jmp .L_lambda_opt_end_0b2e
.L_lambda_opt_code_0b2e:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b2e
	jg .L_lambda_opt_arity_check_more_0b2e
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b2e:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2188:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2188
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2188
.L_lambda_opt_stack_shrink_loop_exit_2188:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b2e
.L_lambda_opt_arity_check_more_0b2e:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2189:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2189
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2189
.L_lambda_opt_stack_shrink_loop_exit_2189:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_218a:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_218a
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_218a
.L_lambda_opt_stack_shrink_loop_exit_218a:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b2e:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 44	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b2f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 43
	je .L_lambda_opt_env_end_0b2f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b2f
.L_lambda_opt_env_end_0b2f:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b2f:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b2f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b2f
.L_lambda_opt_params_end_0b2f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b2f
	jmp .L_lambda_opt_end_0b2f
.L_lambda_opt_code_0b2f:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b2f
	jg .L_lambda_opt_arity_check_more_0b2f
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b2f:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_218b:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_218b
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_218b
.L_lambda_opt_stack_shrink_loop_exit_218b:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b2f
.L_lambda_opt_arity_check_more_0b2f:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_218c:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_218c
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_218c
.L_lambda_opt_stack_shrink_loop_exit_218c:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_218d:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_218d
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_218d
.L_lambda_opt_stack_shrink_loop_exit_218d:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b2f:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 45	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b30:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 44
	je .L_lambda_opt_env_end_0b30
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b30
.L_lambda_opt_env_end_0b30:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b30:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b30
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b30
.L_lambda_opt_params_end_0b30:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b30
	jmp .L_lambda_opt_end_0b30
.L_lambda_opt_code_0b30:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b30
	jg .L_lambda_opt_arity_check_more_0b30
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b30:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_218e:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_218e
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_218e
.L_lambda_opt_stack_shrink_loop_exit_218e:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b30
.L_lambda_opt_arity_check_more_0b30:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_218f:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_218f
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_218f
.L_lambda_opt_stack_shrink_loop_exit_218f:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2190:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2190
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2190
.L_lambda_opt_stack_shrink_loop_exit_2190:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b30:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 46	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b31:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 45
	je .L_lambda_opt_env_end_0b31
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b31
.L_lambda_opt_env_end_0b31:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b31:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b31
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b31
.L_lambda_opt_params_end_0b31:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b31
	jmp .L_lambda_opt_end_0b31
.L_lambda_opt_code_0b31:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b31
	jg .L_lambda_opt_arity_check_more_0b31
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b31:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2191:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2191
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2191
.L_lambda_opt_stack_shrink_loop_exit_2191:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b31
.L_lambda_opt_arity_check_more_0b31:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2192:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2192
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2192
.L_lambda_opt_stack_shrink_loop_exit_2192:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2193:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2193
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2193
.L_lambda_opt_stack_shrink_loop_exit_2193:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b31:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 47	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b32:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 46
	je .L_lambda_opt_env_end_0b32
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b32
.L_lambda_opt_env_end_0b32:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b32:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b32
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b32
.L_lambda_opt_params_end_0b32:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b32
	jmp .L_lambda_opt_end_0b32
.L_lambda_opt_code_0b32:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b32
	jg .L_lambda_opt_arity_check_more_0b32
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b32:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2194:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2194
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2194
.L_lambda_opt_stack_shrink_loop_exit_2194:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b32
.L_lambda_opt_arity_check_more_0b32:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2195:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2195
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2195
.L_lambda_opt_stack_shrink_loop_exit_2195:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2196:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2196
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2196
.L_lambda_opt_stack_shrink_loop_exit_2196:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b32:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 48	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b33:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 47
	je .L_lambda_opt_env_end_0b33
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b33
.L_lambda_opt_env_end_0b33:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b33:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b33
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b33
.L_lambda_opt_params_end_0b33:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b33
	jmp .L_lambda_opt_end_0b33
.L_lambda_opt_code_0b33:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b33
	jg .L_lambda_opt_arity_check_more_0b33
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b33:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2197:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2197
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2197
.L_lambda_opt_stack_shrink_loop_exit_2197:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b33
.L_lambda_opt_arity_check_more_0b33:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2198:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2198
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2198
.L_lambda_opt_stack_shrink_loop_exit_2198:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2199:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2199
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2199
.L_lambda_opt_stack_shrink_loop_exit_2199:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b33:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 49	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b34:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 48
	je .L_lambda_opt_env_end_0b34
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b34
.L_lambda_opt_env_end_0b34:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b34:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b34
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b34
.L_lambda_opt_params_end_0b34:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b34
	jmp .L_lambda_opt_end_0b34
.L_lambda_opt_code_0b34:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b34
	jg .L_lambda_opt_arity_check_more_0b34
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b34:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_219a:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_219a
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_219a
.L_lambda_opt_stack_shrink_loop_exit_219a:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b34
.L_lambda_opt_arity_check_more_0b34:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_219b:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_219b
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_219b
.L_lambda_opt_stack_shrink_loop_exit_219b:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_219c:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_219c
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_219c
.L_lambda_opt_stack_shrink_loop_exit_219c:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b34:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 50	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b35:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 49
	je .L_lambda_opt_env_end_0b35
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b35
.L_lambda_opt_env_end_0b35:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b35:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b35
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b35
.L_lambda_opt_params_end_0b35:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b35
	jmp .L_lambda_opt_end_0b35
.L_lambda_opt_code_0b35:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b35
	jg .L_lambda_opt_arity_check_more_0b35
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b35:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_219d:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_219d
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_219d
.L_lambda_opt_stack_shrink_loop_exit_219d:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b35
.L_lambda_opt_arity_check_more_0b35:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_219e:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_219e
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_219e
.L_lambda_opt_stack_shrink_loop_exit_219e:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_219f:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_219f
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_219f
.L_lambda_opt_stack_shrink_loop_exit_219f:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b35:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 51	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b36:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 50
	je .L_lambda_opt_env_end_0b36
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b36
.L_lambda_opt_env_end_0b36:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b36:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b36
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b36
.L_lambda_opt_params_end_0b36:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b36
	jmp .L_lambda_opt_end_0b36
.L_lambda_opt_code_0b36:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b36
	jg .L_lambda_opt_arity_check_more_0b36
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b36:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21a0:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21a0
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21a0
.L_lambda_opt_stack_shrink_loop_exit_21a0:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b36
.L_lambda_opt_arity_check_more_0b36:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21a1:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21a1
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21a1
.L_lambda_opt_stack_shrink_loop_exit_21a1:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21a2:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21a2
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21a2
.L_lambda_opt_stack_shrink_loop_exit_21a2:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b36:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 52	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b37:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 51
	je .L_lambda_opt_env_end_0b37
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b37
.L_lambda_opt_env_end_0b37:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b37:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b37
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b37
.L_lambda_opt_params_end_0b37:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b37
	jmp .L_lambda_opt_end_0b37
.L_lambda_opt_code_0b37:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b37
	jg .L_lambda_opt_arity_check_more_0b37
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b37:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21a3:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21a3
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21a3
.L_lambda_opt_stack_shrink_loop_exit_21a3:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b37
.L_lambda_opt_arity_check_more_0b37:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21a4:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21a4
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21a4
.L_lambda_opt_stack_shrink_loop_exit_21a4:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21a5:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21a5
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21a5
.L_lambda_opt_stack_shrink_loop_exit_21a5:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b37:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 53	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b38:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 52
	je .L_lambda_opt_env_end_0b38
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b38
.L_lambda_opt_env_end_0b38:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b38:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b38
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b38
.L_lambda_opt_params_end_0b38:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b38
	jmp .L_lambda_opt_end_0b38
.L_lambda_opt_code_0b38:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b38
	jg .L_lambda_opt_arity_check_more_0b38
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b38:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21a6:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21a6
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21a6
.L_lambda_opt_stack_shrink_loop_exit_21a6:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b38
.L_lambda_opt_arity_check_more_0b38:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21a7:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21a7
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21a7
.L_lambda_opt_stack_shrink_loop_exit_21a7:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21a8:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21a8
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21a8
.L_lambda_opt_stack_shrink_loop_exit_21a8:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b38:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 54	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b39:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 53
	je .L_lambda_opt_env_end_0b39
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b39
.L_lambda_opt_env_end_0b39:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b39:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b39
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b39
.L_lambda_opt_params_end_0b39:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b39
	jmp .L_lambda_opt_end_0b39
.L_lambda_opt_code_0b39:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b39
	jg .L_lambda_opt_arity_check_more_0b39
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b39:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21a9:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21a9
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21a9
.L_lambda_opt_stack_shrink_loop_exit_21a9:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b39
.L_lambda_opt_arity_check_more_0b39:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21aa:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21aa
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21aa
.L_lambda_opt_stack_shrink_loop_exit_21aa:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21ab:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21ab
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21ab
.L_lambda_opt_stack_shrink_loop_exit_21ab:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b39:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 55	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b3a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 54
	je .L_lambda_opt_env_end_0b3a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b3a
.L_lambda_opt_env_end_0b3a:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b3a:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b3a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b3a
.L_lambda_opt_params_end_0b3a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b3a
	jmp .L_lambda_opt_end_0b3a
.L_lambda_opt_code_0b3a:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b3a
	jg .L_lambda_opt_arity_check_more_0b3a
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b3a:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21ac:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21ac
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21ac
.L_lambda_opt_stack_shrink_loop_exit_21ac:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b3a
.L_lambda_opt_arity_check_more_0b3a:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21ad:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21ad
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21ad
.L_lambda_opt_stack_shrink_loop_exit_21ad:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21ae:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21ae
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21ae
.L_lambda_opt_stack_shrink_loop_exit_21ae:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b3a:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 56	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b3b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 55
	je .L_lambda_opt_env_end_0b3b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b3b
.L_lambda_opt_env_end_0b3b:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b3b:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b3b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b3b
.L_lambda_opt_params_end_0b3b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b3b
	jmp .L_lambda_opt_end_0b3b
.L_lambda_opt_code_0b3b:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b3b
	jg .L_lambda_opt_arity_check_more_0b3b
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b3b:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21af:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21af
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21af
.L_lambda_opt_stack_shrink_loop_exit_21af:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b3b
.L_lambda_opt_arity_check_more_0b3b:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21b0:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21b0
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21b0
.L_lambda_opt_stack_shrink_loop_exit_21b0:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21b1:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21b1
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21b1
.L_lambda_opt_stack_shrink_loop_exit_21b1:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b3b:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 57	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b3c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 56
	je .L_lambda_opt_env_end_0b3c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b3c
.L_lambda_opt_env_end_0b3c:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b3c:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b3c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b3c
.L_lambda_opt_params_end_0b3c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b3c
	jmp .L_lambda_opt_end_0b3c
.L_lambda_opt_code_0b3c:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b3c
	jg .L_lambda_opt_arity_check_more_0b3c
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b3c:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21b2:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21b2
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21b2
.L_lambda_opt_stack_shrink_loop_exit_21b2:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b3c
.L_lambda_opt_arity_check_more_0b3c:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21b3:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21b3
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21b3
.L_lambda_opt_stack_shrink_loop_exit_21b3:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21b4:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21b4
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21b4
.L_lambda_opt_stack_shrink_loop_exit_21b4:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b3c:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 58	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b3d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 57
	je .L_lambda_opt_env_end_0b3d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b3d
.L_lambda_opt_env_end_0b3d:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b3d:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b3d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b3d
.L_lambda_opt_params_end_0b3d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b3d
	jmp .L_lambda_opt_end_0b3d
.L_lambda_opt_code_0b3d:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b3d
	jg .L_lambda_opt_arity_check_more_0b3d
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b3d:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21b5:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21b5
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21b5
.L_lambda_opt_stack_shrink_loop_exit_21b5:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b3d
.L_lambda_opt_arity_check_more_0b3d:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21b6:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21b6
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21b6
.L_lambda_opt_stack_shrink_loop_exit_21b6:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21b7:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21b7
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21b7
.L_lambda_opt_stack_shrink_loop_exit_21b7:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b3d:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 59	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b3e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 58
	je .L_lambda_opt_env_end_0b3e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b3e
.L_lambda_opt_env_end_0b3e:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b3e:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b3e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b3e
.L_lambda_opt_params_end_0b3e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b3e
	jmp .L_lambda_opt_end_0b3e
.L_lambda_opt_code_0b3e:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b3e
	jg .L_lambda_opt_arity_check_more_0b3e
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b3e:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21b8:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21b8
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21b8
.L_lambda_opt_stack_shrink_loop_exit_21b8:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b3e
.L_lambda_opt_arity_check_more_0b3e:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21b9:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21b9
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21b9
.L_lambda_opt_stack_shrink_loop_exit_21b9:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21ba:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21ba
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21ba
.L_lambda_opt_stack_shrink_loop_exit_21ba:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b3e:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 60	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b3f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 59
	je .L_lambda_opt_env_end_0b3f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b3f
.L_lambda_opt_env_end_0b3f:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b3f:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b3f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b3f
.L_lambda_opt_params_end_0b3f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b3f
	jmp .L_lambda_opt_end_0b3f
.L_lambda_opt_code_0b3f:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b3f
	jg .L_lambda_opt_arity_check_more_0b3f
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b3f:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21bb:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21bb
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21bb
.L_lambda_opt_stack_shrink_loop_exit_21bb:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b3f
.L_lambda_opt_arity_check_more_0b3f:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21bc:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21bc
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21bc
.L_lambda_opt_stack_shrink_loop_exit_21bc:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21bd:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21bd
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21bd
.L_lambda_opt_stack_shrink_loop_exit_21bd:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b3f:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 61	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b40:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 60
	je .L_lambda_opt_env_end_0b40
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b40
.L_lambda_opt_env_end_0b40:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b40:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b40
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b40
.L_lambda_opt_params_end_0b40:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b40
	jmp .L_lambda_opt_end_0b40
.L_lambda_opt_code_0b40:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b40
	jg .L_lambda_opt_arity_check_more_0b40
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b40:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21be:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21be
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21be
.L_lambda_opt_stack_shrink_loop_exit_21be:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b40
.L_lambda_opt_arity_check_more_0b40:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21bf:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21bf
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21bf
.L_lambda_opt_stack_shrink_loop_exit_21bf:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21c0:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21c0
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21c0
.L_lambda_opt_stack_shrink_loop_exit_21c0:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b40:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 62	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b41:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 61
	je .L_lambda_opt_env_end_0b41
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b41
.L_lambda_opt_env_end_0b41:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b41:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b41
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b41
.L_lambda_opt_params_end_0b41:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b41
	jmp .L_lambda_opt_end_0b41
.L_lambda_opt_code_0b41:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b41
	jg .L_lambda_opt_arity_check_more_0b41
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b41:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21c1:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21c1
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21c1
.L_lambda_opt_stack_shrink_loop_exit_21c1:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b41
.L_lambda_opt_arity_check_more_0b41:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21c2:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21c2
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21c2
.L_lambda_opt_stack_shrink_loop_exit_21c2:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21c3:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21c3
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21c3
.L_lambda_opt_stack_shrink_loop_exit_21c3:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b41:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 63	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b42:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 62
	je .L_lambda_opt_env_end_0b42
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b42
.L_lambda_opt_env_end_0b42:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b42:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b42
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b42
.L_lambda_opt_params_end_0b42:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b42
	jmp .L_lambda_opt_end_0b42
.L_lambda_opt_code_0b42:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b42
	jg .L_lambda_opt_arity_check_more_0b42
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b42:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21c4:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21c4
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21c4
.L_lambda_opt_stack_shrink_loop_exit_21c4:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b42
.L_lambda_opt_arity_check_more_0b42:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21c5:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21c5
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21c5
.L_lambda_opt_stack_shrink_loop_exit_21c5:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21c6:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21c6
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21c6
.L_lambda_opt_stack_shrink_loop_exit_21c6:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b42:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 64	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b43:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 63
	je .L_lambda_opt_env_end_0b43
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b43
.L_lambda_opt_env_end_0b43:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b43:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b43
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b43
.L_lambda_opt_params_end_0b43:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b43
	jmp .L_lambda_opt_end_0b43
.L_lambda_opt_code_0b43:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b43
	jg .L_lambda_opt_arity_check_more_0b43
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b43:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21c7:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21c7
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21c7
.L_lambda_opt_stack_shrink_loop_exit_21c7:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b43
.L_lambda_opt_arity_check_more_0b43:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21c8:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21c8
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21c8
.L_lambda_opt_stack_shrink_loop_exit_21c8:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21c9:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21c9
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21c9
.L_lambda_opt_stack_shrink_loop_exit_21c9:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b43:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 65	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b44:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 64
	je .L_lambda_opt_env_end_0b44
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b44
.L_lambda_opt_env_end_0b44:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b44:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b44
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b44
.L_lambda_opt_params_end_0b44:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b44
	jmp .L_lambda_opt_end_0b44
.L_lambda_opt_code_0b44:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b44
	jg .L_lambda_opt_arity_check_more_0b44
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b44:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21ca:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21ca
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21ca
.L_lambda_opt_stack_shrink_loop_exit_21ca:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b44
.L_lambda_opt_arity_check_more_0b44:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21cb:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21cb
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21cb
.L_lambda_opt_stack_shrink_loop_exit_21cb:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21cc:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21cc
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21cc
.L_lambda_opt_stack_shrink_loop_exit_21cc:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b44:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 66	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b45:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 65
	je .L_lambda_opt_env_end_0b45
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b45
.L_lambda_opt_env_end_0b45:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b45:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b45
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b45
.L_lambda_opt_params_end_0b45:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b45
	jmp .L_lambda_opt_end_0b45
.L_lambda_opt_code_0b45:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b45
	jg .L_lambda_opt_arity_check_more_0b45
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b45:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21cd:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21cd
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21cd
.L_lambda_opt_stack_shrink_loop_exit_21cd:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b45
.L_lambda_opt_arity_check_more_0b45:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21ce:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21ce
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21ce
.L_lambda_opt_stack_shrink_loop_exit_21ce:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21cf:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21cf
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21cf
.L_lambda_opt_stack_shrink_loop_exit_21cf:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b45:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 67	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b46:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 66
	je .L_lambda_opt_env_end_0b46
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b46
.L_lambda_opt_env_end_0b46:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b46:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b46
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b46
.L_lambda_opt_params_end_0b46:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b46
	jmp .L_lambda_opt_end_0b46
.L_lambda_opt_code_0b46:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b46
	jg .L_lambda_opt_arity_check_more_0b46
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b46:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21d0:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21d0
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21d0
.L_lambda_opt_stack_shrink_loop_exit_21d0:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b46
.L_lambda_opt_arity_check_more_0b46:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21d1:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21d1
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21d1
.L_lambda_opt_stack_shrink_loop_exit_21d1:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21d2:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21d2
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21d2
.L_lambda_opt_stack_shrink_loop_exit_21d2:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b46:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 68	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b47:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 67
	je .L_lambda_opt_env_end_0b47
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b47
.L_lambda_opt_env_end_0b47:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b47:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b47
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b47
.L_lambda_opt_params_end_0b47:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b47
	jmp .L_lambda_opt_end_0b47
.L_lambda_opt_code_0b47:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b47
	jg .L_lambda_opt_arity_check_more_0b47
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b47:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21d3:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21d3
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21d3
.L_lambda_opt_stack_shrink_loop_exit_21d3:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b47
.L_lambda_opt_arity_check_more_0b47:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21d4:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21d4
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21d4
.L_lambda_opt_stack_shrink_loop_exit_21d4:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21d5:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21d5
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21d5
.L_lambda_opt_stack_shrink_loop_exit_21d5:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b47:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 69	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b48:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 68
	je .L_lambda_opt_env_end_0b48
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b48
.L_lambda_opt_env_end_0b48:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b48:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b48
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b48
.L_lambda_opt_params_end_0b48:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b48
	jmp .L_lambda_opt_end_0b48
.L_lambda_opt_code_0b48:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b48
	jg .L_lambda_opt_arity_check_more_0b48
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b48:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21d6:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21d6
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21d6
.L_lambda_opt_stack_shrink_loop_exit_21d6:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b48
.L_lambda_opt_arity_check_more_0b48:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21d7:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21d7
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21d7
.L_lambda_opt_stack_shrink_loop_exit_21d7:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21d8:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21d8
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21d8
.L_lambda_opt_stack_shrink_loop_exit_21d8:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b48:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 70	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b49:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 69
	je .L_lambda_opt_env_end_0b49
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b49
.L_lambda_opt_env_end_0b49:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b49:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b49
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b49
.L_lambda_opt_params_end_0b49:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b49
	jmp .L_lambda_opt_end_0b49
.L_lambda_opt_code_0b49:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b49
	jg .L_lambda_opt_arity_check_more_0b49
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b49:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21d9:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21d9
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21d9
.L_lambda_opt_stack_shrink_loop_exit_21d9:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b49
.L_lambda_opt_arity_check_more_0b49:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21da:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21da
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21da
.L_lambda_opt_stack_shrink_loop_exit_21da:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21db:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21db
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21db
.L_lambda_opt_stack_shrink_loop_exit_21db:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b49:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 71	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b4a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 70
	je .L_lambda_opt_env_end_0b4a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b4a
.L_lambda_opt_env_end_0b4a:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b4a:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b4a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b4a
.L_lambda_opt_params_end_0b4a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b4a
	jmp .L_lambda_opt_end_0b4a
.L_lambda_opt_code_0b4a:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b4a
	jg .L_lambda_opt_arity_check_more_0b4a
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b4a:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21dc:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21dc
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21dc
.L_lambda_opt_stack_shrink_loop_exit_21dc:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b4a
.L_lambda_opt_arity_check_more_0b4a:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21dd:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21dd
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21dd
.L_lambda_opt_stack_shrink_loop_exit_21dd:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21de:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21de
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21de
.L_lambda_opt_stack_shrink_loop_exit_21de:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b4a:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 72	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b4b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 71
	je .L_lambda_opt_env_end_0b4b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b4b
.L_lambda_opt_env_end_0b4b:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b4b:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b4b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b4b
.L_lambda_opt_params_end_0b4b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b4b
	jmp .L_lambda_opt_end_0b4b
.L_lambda_opt_code_0b4b:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b4b
	jg .L_lambda_opt_arity_check_more_0b4b
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b4b:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21df:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21df
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21df
.L_lambda_opt_stack_shrink_loop_exit_21df:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b4b
.L_lambda_opt_arity_check_more_0b4b:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21e0:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21e0
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21e0
.L_lambda_opt_stack_shrink_loop_exit_21e0:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21e1:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21e1
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21e1
.L_lambda_opt_stack_shrink_loop_exit_21e1:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b4b:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 73	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b4c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 72
	je .L_lambda_opt_env_end_0b4c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b4c
.L_lambda_opt_env_end_0b4c:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b4c:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b4c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b4c
.L_lambda_opt_params_end_0b4c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b4c
	jmp .L_lambda_opt_end_0b4c
.L_lambda_opt_code_0b4c:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b4c
	jg .L_lambda_opt_arity_check_more_0b4c
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b4c:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21e2:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21e2
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21e2
.L_lambda_opt_stack_shrink_loop_exit_21e2:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b4c
.L_lambda_opt_arity_check_more_0b4c:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21e3:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21e3
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21e3
.L_lambda_opt_stack_shrink_loop_exit_21e3:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21e4:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21e4
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21e4
.L_lambda_opt_stack_shrink_loop_exit_21e4:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b4c:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 74	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b4d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 73
	je .L_lambda_opt_env_end_0b4d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b4d
.L_lambda_opt_env_end_0b4d:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b4d:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b4d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b4d
.L_lambda_opt_params_end_0b4d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b4d
	jmp .L_lambda_opt_end_0b4d
.L_lambda_opt_code_0b4d:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b4d
	jg .L_lambda_opt_arity_check_more_0b4d
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b4d:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21e5:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21e5
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21e5
.L_lambda_opt_stack_shrink_loop_exit_21e5:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b4d
.L_lambda_opt_arity_check_more_0b4d:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21e6:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21e6
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21e6
.L_lambda_opt_stack_shrink_loop_exit_21e6:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21e7:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21e7
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21e7
.L_lambda_opt_stack_shrink_loop_exit_21e7:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b4d:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 75	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b4e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 74
	je .L_lambda_opt_env_end_0b4e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b4e
.L_lambda_opt_env_end_0b4e:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b4e:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b4e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b4e
.L_lambda_opt_params_end_0b4e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b4e
	jmp .L_lambda_opt_end_0b4e
.L_lambda_opt_code_0b4e:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b4e
	jg .L_lambda_opt_arity_check_more_0b4e
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b4e:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21e8:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21e8
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21e8
.L_lambda_opt_stack_shrink_loop_exit_21e8:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b4e
.L_lambda_opt_arity_check_more_0b4e:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21e9:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21e9
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21e9
.L_lambda_opt_stack_shrink_loop_exit_21e9:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21ea:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21ea
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21ea
.L_lambda_opt_stack_shrink_loop_exit_21ea:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b4e:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 76	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b4f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 75
	je .L_lambda_opt_env_end_0b4f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b4f
.L_lambda_opt_env_end_0b4f:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b4f:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b4f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b4f
.L_lambda_opt_params_end_0b4f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b4f
	jmp .L_lambda_opt_end_0b4f
.L_lambda_opt_code_0b4f:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b4f
	jg .L_lambda_opt_arity_check_more_0b4f
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b4f:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21eb:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21eb
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21eb
.L_lambda_opt_stack_shrink_loop_exit_21eb:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b4f
.L_lambda_opt_arity_check_more_0b4f:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21ec:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21ec
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21ec
.L_lambda_opt_stack_shrink_loop_exit_21ec:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21ed:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21ed
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21ed
.L_lambda_opt_stack_shrink_loop_exit_21ed:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b4f:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 77	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b50:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 76
	je .L_lambda_opt_env_end_0b50
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b50
.L_lambda_opt_env_end_0b50:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b50:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b50
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b50
.L_lambda_opt_params_end_0b50:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b50
	jmp .L_lambda_opt_end_0b50
.L_lambda_opt_code_0b50:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b50
	jg .L_lambda_opt_arity_check_more_0b50
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b50:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21ee:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21ee
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21ee
.L_lambda_opt_stack_shrink_loop_exit_21ee:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b50
.L_lambda_opt_arity_check_more_0b50:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21ef:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21ef
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21ef
.L_lambda_opt_stack_shrink_loop_exit_21ef:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21f0:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21f0
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21f0
.L_lambda_opt_stack_shrink_loop_exit_21f0:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b50:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 78	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b51:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 77
	je .L_lambda_opt_env_end_0b51
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b51
.L_lambda_opt_env_end_0b51:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b51:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b51
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b51
.L_lambda_opt_params_end_0b51:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b51
	jmp .L_lambda_opt_end_0b51
.L_lambda_opt_code_0b51:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b51
	jg .L_lambda_opt_arity_check_more_0b51
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b51:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21f1:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21f1
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21f1
.L_lambda_opt_stack_shrink_loop_exit_21f1:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b51
.L_lambda_opt_arity_check_more_0b51:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21f2:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21f2
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21f2
.L_lambda_opt_stack_shrink_loop_exit_21f2:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21f3:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21f3
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21f3
.L_lambda_opt_stack_shrink_loop_exit_21f3:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b51:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 79	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b52:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 78
	je .L_lambda_opt_env_end_0b52
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b52
.L_lambda_opt_env_end_0b52:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b52:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b52
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b52
.L_lambda_opt_params_end_0b52:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b52
	jmp .L_lambda_opt_end_0b52
.L_lambda_opt_code_0b52:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b52
	jg .L_lambda_opt_arity_check_more_0b52
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b52:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21f4:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21f4
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21f4
.L_lambda_opt_stack_shrink_loop_exit_21f4:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b52
.L_lambda_opt_arity_check_more_0b52:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21f5:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21f5
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21f5
.L_lambda_opt_stack_shrink_loop_exit_21f5:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21f6:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21f6
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21f6
.L_lambda_opt_stack_shrink_loop_exit_21f6:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b52:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 80	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b53:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 79
	je .L_lambda_opt_env_end_0b53
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b53
.L_lambda_opt_env_end_0b53:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b53:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b53
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b53
.L_lambda_opt_params_end_0b53:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b53
	jmp .L_lambda_opt_end_0b53
.L_lambda_opt_code_0b53:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b53
	jg .L_lambda_opt_arity_check_more_0b53
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b53:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21f7:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21f7
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21f7
.L_lambda_opt_stack_shrink_loop_exit_21f7:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b53
.L_lambda_opt_arity_check_more_0b53:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21f8:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21f8
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21f8
.L_lambda_opt_stack_shrink_loop_exit_21f8:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21f9:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21f9
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21f9
.L_lambda_opt_stack_shrink_loop_exit_21f9:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b53:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 81	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b54:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 80
	je .L_lambda_opt_env_end_0b54
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b54
.L_lambda_opt_env_end_0b54:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b54:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b54
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b54
.L_lambda_opt_params_end_0b54:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b54
	jmp .L_lambda_opt_end_0b54
.L_lambda_opt_code_0b54:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b54
	jg .L_lambda_opt_arity_check_more_0b54
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b54:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21fa:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21fa
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21fa
.L_lambda_opt_stack_shrink_loop_exit_21fa:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b54
.L_lambda_opt_arity_check_more_0b54:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21fb:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21fb
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21fb
.L_lambda_opt_stack_shrink_loop_exit_21fb:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21fc:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21fc
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21fc
.L_lambda_opt_stack_shrink_loop_exit_21fc:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b54:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 82	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b55:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 81
	je .L_lambda_opt_env_end_0b55
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b55
.L_lambda_opt_env_end_0b55:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b55:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b55
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b55
.L_lambda_opt_params_end_0b55:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b55
	jmp .L_lambda_opt_end_0b55
.L_lambda_opt_code_0b55:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b55
	jg .L_lambda_opt_arity_check_more_0b55
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b55:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_21fd:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_21fd
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21fd
.L_lambda_opt_stack_shrink_loop_exit_21fd:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b55
.L_lambda_opt_arity_check_more_0b55:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_21fe:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_21fe
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_21fe
.L_lambda_opt_stack_shrink_loop_exit_21fe:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_21ff:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_21ff
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_21ff
.L_lambda_opt_stack_shrink_loop_exit_21ff:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b55:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 83	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b56:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 82
	je .L_lambda_opt_env_end_0b56
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b56
.L_lambda_opt_env_end_0b56:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b56:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b56
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b56
.L_lambda_opt_params_end_0b56:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b56
	jmp .L_lambda_opt_end_0b56
.L_lambda_opt_code_0b56:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b56
	jg .L_lambda_opt_arity_check_more_0b56
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b56:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2200:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2200
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2200
.L_lambda_opt_stack_shrink_loop_exit_2200:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b56
.L_lambda_opt_arity_check_more_0b56:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2201:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2201
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2201
.L_lambda_opt_stack_shrink_loop_exit_2201:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2202:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2202
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2202
.L_lambda_opt_stack_shrink_loop_exit_2202:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b56:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 84	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b57:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 83
	je .L_lambda_opt_env_end_0b57
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b57
.L_lambda_opt_env_end_0b57:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b57:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b57
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b57
.L_lambda_opt_params_end_0b57:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b57
	jmp .L_lambda_opt_end_0b57
.L_lambda_opt_code_0b57:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b57
	jg .L_lambda_opt_arity_check_more_0b57
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b57:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2203:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2203
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2203
.L_lambda_opt_stack_shrink_loop_exit_2203:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b57
.L_lambda_opt_arity_check_more_0b57:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2204:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2204
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2204
.L_lambda_opt_stack_shrink_loop_exit_2204:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2205:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2205
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2205
.L_lambda_opt_stack_shrink_loop_exit_2205:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b57:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 85	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b58:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 84
	je .L_lambda_opt_env_end_0b58
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b58
.L_lambda_opt_env_end_0b58:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b58:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b58
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b58
.L_lambda_opt_params_end_0b58:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b58
	jmp .L_lambda_opt_end_0b58
.L_lambda_opt_code_0b58:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b58
	jg .L_lambda_opt_arity_check_more_0b58
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b58:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2206:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2206
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2206
.L_lambda_opt_stack_shrink_loop_exit_2206:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b58
.L_lambda_opt_arity_check_more_0b58:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2207:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2207
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2207
.L_lambda_opt_stack_shrink_loop_exit_2207:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2208:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2208
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2208
.L_lambda_opt_stack_shrink_loop_exit_2208:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b58:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 86	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b59:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 85
	je .L_lambda_opt_env_end_0b59
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b59
.L_lambda_opt_env_end_0b59:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b59:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b59
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b59
.L_lambda_opt_params_end_0b59:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b59
	jmp .L_lambda_opt_end_0b59
.L_lambda_opt_code_0b59:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b59
	jg .L_lambda_opt_arity_check_more_0b59
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b59:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2209:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2209
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2209
.L_lambda_opt_stack_shrink_loop_exit_2209:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b59
.L_lambda_opt_arity_check_more_0b59:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_220a:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_220a
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_220a
.L_lambda_opt_stack_shrink_loop_exit_220a:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_220b:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_220b
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_220b
.L_lambda_opt_stack_shrink_loop_exit_220b:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b59:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 87	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b5a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 86
	je .L_lambda_opt_env_end_0b5a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b5a
.L_lambda_opt_env_end_0b5a:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b5a:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b5a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b5a
.L_lambda_opt_params_end_0b5a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b5a
	jmp .L_lambda_opt_end_0b5a
.L_lambda_opt_code_0b5a:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b5a
	jg .L_lambda_opt_arity_check_more_0b5a
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b5a:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_220c:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_220c
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_220c
.L_lambda_opt_stack_shrink_loop_exit_220c:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b5a
.L_lambda_opt_arity_check_more_0b5a:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_220d:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_220d
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_220d
.L_lambda_opt_stack_shrink_loop_exit_220d:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_220e:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_220e
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_220e
.L_lambda_opt_stack_shrink_loop_exit_220e:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b5a:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 88	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b5b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 87
	je .L_lambda_opt_env_end_0b5b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b5b
.L_lambda_opt_env_end_0b5b:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b5b:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b5b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b5b
.L_lambda_opt_params_end_0b5b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b5b
	jmp .L_lambda_opt_end_0b5b
.L_lambda_opt_code_0b5b:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b5b
	jg .L_lambda_opt_arity_check_more_0b5b
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b5b:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_220f:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_220f
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_220f
.L_lambda_opt_stack_shrink_loop_exit_220f:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b5b
.L_lambda_opt_arity_check_more_0b5b:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2210:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2210
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2210
.L_lambda_opt_stack_shrink_loop_exit_2210:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2211:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2211
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2211
.L_lambda_opt_stack_shrink_loop_exit_2211:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b5b:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 89	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b5c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 88
	je .L_lambda_opt_env_end_0b5c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b5c
.L_lambda_opt_env_end_0b5c:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b5c:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b5c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b5c
.L_lambda_opt_params_end_0b5c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b5c
	jmp .L_lambda_opt_end_0b5c
.L_lambda_opt_code_0b5c:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b5c
	jg .L_lambda_opt_arity_check_more_0b5c
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b5c:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2212:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2212
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2212
.L_lambda_opt_stack_shrink_loop_exit_2212:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b5c
.L_lambda_opt_arity_check_more_0b5c:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2213:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2213
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2213
.L_lambda_opt_stack_shrink_loop_exit_2213:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2214:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2214
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2214
.L_lambda_opt_stack_shrink_loop_exit_2214:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b5c:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 90	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b5d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 89
	je .L_lambda_opt_env_end_0b5d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b5d
.L_lambda_opt_env_end_0b5d:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b5d:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b5d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b5d
.L_lambda_opt_params_end_0b5d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b5d
	jmp .L_lambda_opt_end_0b5d
.L_lambda_opt_code_0b5d:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b5d
	jg .L_lambda_opt_arity_check_more_0b5d
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b5d:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2215:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2215
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2215
.L_lambda_opt_stack_shrink_loop_exit_2215:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b5d
.L_lambda_opt_arity_check_more_0b5d:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2216:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2216
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2216
.L_lambda_opt_stack_shrink_loop_exit_2216:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2217:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2217
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2217
.L_lambda_opt_stack_shrink_loop_exit_2217:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b5d:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 91	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b5e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 90
	je .L_lambda_opt_env_end_0b5e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b5e
.L_lambda_opt_env_end_0b5e:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b5e:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b5e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b5e
.L_lambda_opt_params_end_0b5e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b5e
	jmp .L_lambda_opt_end_0b5e
.L_lambda_opt_code_0b5e:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b5e
	jg .L_lambda_opt_arity_check_more_0b5e
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b5e:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2218:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2218
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2218
.L_lambda_opt_stack_shrink_loop_exit_2218:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b5e
.L_lambda_opt_arity_check_more_0b5e:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2219:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2219
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2219
.L_lambda_opt_stack_shrink_loop_exit_2219:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_221a:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_221a
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_221a
.L_lambda_opt_stack_shrink_loop_exit_221a:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b5e:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 92	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b5f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 91
	je .L_lambda_opt_env_end_0b5f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b5f
.L_lambda_opt_env_end_0b5f:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b5f:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b5f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b5f
.L_lambda_opt_params_end_0b5f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b5f
	jmp .L_lambda_opt_end_0b5f
.L_lambda_opt_code_0b5f:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b5f
	jg .L_lambda_opt_arity_check_more_0b5f
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b5f:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_221b:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_221b
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_221b
.L_lambda_opt_stack_shrink_loop_exit_221b:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b5f
.L_lambda_opt_arity_check_more_0b5f:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_221c:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_221c
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_221c
.L_lambda_opt_stack_shrink_loop_exit_221c:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_221d:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_221d
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_221d
.L_lambda_opt_stack_shrink_loop_exit_221d:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b5f:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 93	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b60:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 92
	je .L_lambda_opt_env_end_0b60
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b60
.L_lambda_opt_env_end_0b60:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b60:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b60
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b60
.L_lambda_opt_params_end_0b60:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b60
	jmp .L_lambda_opt_end_0b60
.L_lambda_opt_code_0b60:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b60
	jg .L_lambda_opt_arity_check_more_0b60
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b60:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_221e:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_221e
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_221e
.L_lambda_opt_stack_shrink_loop_exit_221e:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b60
.L_lambda_opt_arity_check_more_0b60:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_221f:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_221f
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_221f
.L_lambda_opt_stack_shrink_loop_exit_221f:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2220:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2220
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2220
.L_lambda_opt_stack_shrink_loop_exit_2220:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b60:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 94	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b61:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 93
	je .L_lambda_opt_env_end_0b61
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b61
.L_lambda_opt_env_end_0b61:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b61:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b61
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b61
.L_lambda_opt_params_end_0b61:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b61
	jmp .L_lambda_opt_end_0b61
.L_lambda_opt_code_0b61:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b61
	jg .L_lambda_opt_arity_check_more_0b61
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b61:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2221:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2221
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2221
.L_lambda_opt_stack_shrink_loop_exit_2221:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b61
.L_lambda_opt_arity_check_more_0b61:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2222:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2222
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2222
.L_lambda_opt_stack_shrink_loop_exit_2222:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2223:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2223
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2223
.L_lambda_opt_stack_shrink_loop_exit_2223:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b61:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 95	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b62:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 94
	je .L_lambda_opt_env_end_0b62
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b62
.L_lambda_opt_env_end_0b62:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b62:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b62
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b62
.L_lambda_opt_params_end_0b62:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b62
	jmp .L_lambda_opt_end_0b62
.L_lambda_opt_code_0b62:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b62
	jg .L_lambda_opt_arity_check_more_0b62
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b62:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2224:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2224
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2224
.L_lambda_opt_stack_shrink_loop_exit_2224:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b62
.L_lambda_opt_arity_check_more_0b62:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2225:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2225
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2225
.L_lambda_opt_stack_shrink_loop_exit_2225:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2226:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2226
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2226
.L_lambda_opt_stack_shrink_loop_exit_2226:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b62:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 96	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b63:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 95
	je .L_lambda_opt_env_end_0b63
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b63
.L_lambda_opt_env_end_0b63:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b63:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b63
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b63
.L_lambda_opt_params_end_0b63:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b63
	jmp .L_lambda_opt_end_0b63
.L_lambda_opt_code_0b63:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b63
	jg .L_lambda_opt_arity_check_more_0b63
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b63:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2227:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2227
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2227
.L_lambda_opt_stack_shrink_loop_exit_2227:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b63
.L_lambda_opt_arity_check_more_0b63:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2228:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2228
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2228
.L_lambda_opt_stack_shrink_loop_exit_2228:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2229:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2229
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2229
.L_lambda_opt_stack_shrink_loop_exit_2229:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b63:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 97	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b64:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 96
	je .L_lambda_opt_env_end_0b64
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b64
.L_lambda_opt_env_end_0b64:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b64:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b64
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b64
.L_lambda_opt_params_end_0b64:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b64
	jmp .L_lambda_opt_end_0b64
.L_lambda_opt_code_0b64:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b64
	jg .L_lambda_opt_arity_check_more_0b64
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b64:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_222a:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_222a
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_222a
.L_lambda_opt_stack_shrink_loop_exit_222a:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b64
.L_lambda_opt_arity_check_more_0b64:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_222b:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_222b
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_222b
.L_lambda_opt_stack_shrink_loop_exit_222b:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_222c:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_222c
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_222c
.L_lambda_opt_stack_shrink_loop_exit_222c:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b64:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 98	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b65:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 97
	je .L_lambda_opt_env_end_0b65
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b65
.L_lambda_opt_env_end_0b65:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b65:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b65
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b65
.L_lambda_opt_params_end_0b65:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b65
	jmp .L_lambda_opt_end_0b65
.L_lambda_opt_code_0b65:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b65
	jg .L_lambda_opt_arity_check_more_0b65
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b65:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_222d:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_222d
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_222d
.L_lambda_opt_stack_shrink_loop_exit_222d:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b65
.L_lambda_opt_arity_check_more_0b65:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_222e:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_222e
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_222e
.L_lambda_opt_stack_shrink_loop_exit_222e:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_222f:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_222f
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_222f
.L_lambda_opt_stack_shrink_loop_exit_222f:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b65:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 99	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b66:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 98
	je .L_lambda_opt_env_end_0b66
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b66
.L_lambda_opt_env_end_0b66:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b66:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b66
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b66
.L_lambda_opt_params_end_0b66:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b66
	jmp .L_lambda_opt_end_0b66
.L_lambda_opt_code_0b66:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b66
	jg .L_lambda_opt_arity_check_more_0b66
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b66:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2230:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2230
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2230
.L_lambda_opt_stack_shrink_loop_exit_2230:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b66
.L_lambda_opt_arity_check_more_0b66:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2231:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2231
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2231
.L_lambda_opt_stack_shrink_loop_exit_2231:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2232:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2232
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2232
.L_lambda_opt_stack_shrink_loop_exit_2232:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b66:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 100	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b67:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 99
	je .L_lambda_opt_env_end_0b67
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b67
.L_lambda_opt_env_end_0b67:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b67:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b67
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b67
.L_lambda_opt_params_end_0b67:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b67
	jmp .L_lambda_opt_end_0b67
.L_lambda_opt_code_0b67:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b67
	jg .L_lambda_opt_arity_check_more_0b67
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b67:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2233:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2233
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2233
.L_lambda_opt_stack_shrink_loop_exit_2233:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b67
.L_lambda_opt_arity_check_more_0b67:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2234:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2234
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2234
.L_lambda_opt_stack_shrink_loop_exit_2234:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2235:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2235
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2235
.L_lambda_opt_stack_shrink_loop_exit_2235:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b67:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 101	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b68:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 100
	je .L_lambda_opt_env_end_0b68
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b68
.L_lambda_opt_env_end_0b68:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b68:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b68
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b68
.L_lambda_opt_params_end_0b68:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b68
	jmp .L_lambda_opt_end_0b68
.L_lambda_opt_code_0b68:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b68
	jg .L_lambda_opt_arity_check_more_0b68
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b68:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2236:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2236
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2236
.L_lambda_opt_stack_shrink_loop_exit_2236:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b68
.L_lambda_opt_arity_check_more_0b68:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2237:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2237
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2237
.L_lambda_opt_stack_shrink_loop_exit_2237:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2238:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2238
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2238
.L_lambda_opt_stack_shrink_loop_exit_2238:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b68:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 102	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b69:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 101
	je .L_lambda_opt_env_end_0b69
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b69
.L_lambda_opt_env_end_0b69:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b69:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b69
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b69
.L_lambda_opt_params_end_0b69:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b69
	jmp .L_lambda_opt_end_0b69
.L_lambda_opt_code_0b69:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b69
	jg .L_lambda_opt_arity_check_more_0b69
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b69:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2239:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2239
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2239
.L_lambda_opt_stack_shrink_loop_exit_2239:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b69
.L_lambda_opt_arity_check_more_0b69:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_223a:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_223a
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_223a
.L_lambda_opt_stack_shrink_loop_exit_223a:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_223b:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_223b
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_223b
.L_lambda_opt_stack_shrink_loop_exit_223b:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b69:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 103	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b6a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 102
	je .L_lambda_opt_env_end_0b6a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b6a
.L_lambda_opt_env_end_0b6a:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b6a:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b6a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b6a
.L_lambda_opt_params_end_0b6a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b6a
	jmp .L_lambda_opt_end_0b6a
.L_lambda_opt_code_0b6a:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b6a
	jg .L_lambda_opt_arity_check_more_0b6a
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b6a:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_223c:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_223c
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_223c
.L_lambda_opt_stack_shrink_loop_exit_223c:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b6a
.L_lambda_opt_arity_check_more_0b6a:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_223d:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_223d
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_223d
.L_lambda_opt_stack_shrink_loop_exit_223d:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_223e:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_223e
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_223e
.L_lambda_opt_stack_shrink_loop_exit_223e:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b6a:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 104	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b6b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 103
	je .L_lambda_opt_env_end_0b6b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b6b
.L_lambda_opt_env_end_0b6b:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b6b:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b6b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b6b
.L_lambda_opt_params_end_0b6b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b6b
	jmp .L_lambda_opt_end_0b6b
.L_lambda_opt_code_0b6b:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b6b
	jg .L_lambda_opt_arity_check_more_0b6b
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b6b:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_223f:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_223f
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_223f
.L_lambda_opt_stack_shrink_loop_exit_223f:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b6b
.L_lambda_opt_arity_check_more_0b6b:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2240:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2240
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2240
.L_lambda_opt_stack_shrink_loop_exit_2240:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2241:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2241
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2241
.L_lambda_opt_stack_shrink_loop_exit_2241:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b6b:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 105	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b6c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 104
	je .L_lambda_opt_env_end_0b6c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b6c
.L_lambda_opt_env_end_0b6c:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b6c:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b6c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b6c
.L_lambda_opt_params_end_0b6c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b6c
	jmp .L_lambda_opt_end_0b6c
.L_lambda_opt_code_0b6c:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b6c
	jg .L_lambda_opt_arity_check_more_0b6c
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b6c:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2242:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2242
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2242
.L_lambda_opt_stack_shrink_loop_exit_2242:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b6c
.L_lambda_opt_arity_check_more_0b6c:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2243:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2243
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2243
.L_lambda_opt_stack_shrink_loop_exit_2243:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2244:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2244
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2244
.L_lambda_opt_stack_shrink_loop_exit_2244:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b6c:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 106	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b6d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 105
	je .L_lambda_opt_env_end_0b6d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b6d
.L_lambda_opt_env_end_0b6d:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b6d:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b6d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b6d
.L_lambda_opt_params_end_0b6d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b6d
	jmp .L_lambda_opt_end_0b6d
.L_lambda_opt_code_0b6d:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b6d
	jg .L_lambda_opt_arity_check_more_0b6d
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b6d:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2245:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2245
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2245
.L_lambda_opt_stack_shrink_loop_exit_2245:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b6d
.L_lambda_opt_arity_check_more_0b6d:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2246:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2246
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2246
.L_lambda_opt_stack_shrink_loop_exit_2246:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2247:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2247
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2247
.L_lambda_opt_stack_shrink_loop_exit_2247:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b6d:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 107	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b6e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 106
	je .L_lambda_opt_env_end_0b6e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b6e
.L_lambda_opt_env_end_0b6e:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b6e:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b6e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b6e
.L_lambda_opt_params_end_0b6e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b6e
	jmp .L_lambda_opt_end_0b6e
.L_lambda_opt_code_0b6e:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b6e
	jg .L_lambda_opt_arity_check_more_0b6e
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b6e:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_2248:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_2248
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2248
.L_lambda_opt_stack_shrink_loop_exit_2248:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b6e
.L_lambda_opt_arity_check_more_0b6e:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_2249:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_2249
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_2249
.L_lambda_opt_stack_shrink_loop_exit_2249:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_224a:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_224a
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_224a
.L_lambda_opt_stack_shrink_loop_exit_224a:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b6e:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 108	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b6f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 107
	je .L_lambda_opt_env_end_0b6f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b6f
.L_lambda_opt_env_end_0b6f:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b6f:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b6f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b6f
.L_lambda_opt_params_end_0b6f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b6f
	jmp .L_lambda_opt_end_0b6f
.L_lambda_opt_code_0b6f:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b6f
	jg .L_lambda_opt_arity_check_more_0b6f
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b6f:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_224b:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_224b
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_224b
.L_lambda_opt_stack_shrink_loop_exit_224b:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b6f
.L_lambda_opt_arity_check_more_0b6f:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_224c:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_224c
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_224c
.L_lambda_opt_stack_shrink_loop_exit_224c:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_224d:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_224d
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_224d
.L_lambda_opt_stack_shrink_loop_exit_224d:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b6f:
	enter 0, 0
	push 0
	mov rdi, (1 + 8 + 8)	; sob closure
	call malloc
	push rax
	mov rdi, 8 * 1	; new rib
	call malloc
	push rax
	mov rdi, 8 * 109	; extended env
	call malloc
	mov rdi, ENV
	mov rsi, 0
	mov rdx, 1
.L_lambda_opt_env_loop_0b70:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 108
	je .L_lambda_opt_env_end_0b70
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0b70
.L_lambda_opt_env_end_0b70:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0b70:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0b70
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0b70
.L_lambda_opt_params_end_0b70:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0b70
	jmp .L_lambda_opt_end_0b70
.L_lambda_opt_code_0b70:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0b70
	jg .L_lambda_opt_arity_check_more_0b70
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0b70:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_224e:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_224e
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_224e
.L_lambda_opt_stack_shrink_loop_exit_224e:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0b70
.L_lambda_opt_arity_check_more_0b70:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_224f:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_224f
	mov rdi, 17 ; 1+8+8
	call malloc
	mov SOB_PAIR_CDR(rax), rcx
	neg rsi
	mov rcx, qword [rbx + rsi * 8]
	neg rsi
	mov SOB_PAIR_CAR(rax), rcx
	mov byte [rax], T_pair
	mov rcx, rax
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_224f
.L_lambda_opt_stack_shrink_loop_exit_224f:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_2250:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_2250
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_2250
.L_lambda_opt_stack_shrink_loop_exit_2250:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0b70:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b70:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5435:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5435
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5435
.L_tc_recycle_frame_done_5435:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b6f:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5434:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5434
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5434
.L_tc_recycle_frame_done_5434:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b6e:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5433:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5433
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5433
.L_tc_recycle_frame_done_5433:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b6d:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5432:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5432
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5432
.L_tc_recycle_frame_done_5432:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b6c:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5431:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5431
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5431
.L_tc_recycle_frame_done_5431:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b6b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5430:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5430
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5430
.L_tc_recycle_frame_done_5430:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b6a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_542f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_542f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_542f
.L_tc_recycle_frame_done_542f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b69:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_542e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_542e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_542e
.L_tc_recycle_frame_done_542e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b68:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_542d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_542d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_542d
.L_tc_recycle_frame_done_542d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b67:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_542c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_542c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_542c
.L_tc_recycle_frame_done_542c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b66:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_542b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_542b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_542b
.L_tc_recycle_frame_done_542b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b65:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_542a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_542a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_542a
.L_tc_recycle_frame_done_542a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b64:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5429:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5429
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5429
.L_tc_recycle_frame_done_5429:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b63:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5428:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5428
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5428
.L_tc_recycle_frame_done_5428:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b62:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5427:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5427
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5427
.L_tc_recycle_frame_done_5427:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b61:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5426:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5426
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5426
.L_tc_recycle_frame_done_5426:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b60:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5425:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5425
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5425
.L_tc_recycle_frame_done_5425:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b5f:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5424:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5424
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5424
.L_tc_recycle_frame_done_5424:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b5e:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5423:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5423
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5423
.L_tc_recycle_frame_done_5423:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b5d:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5422:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5422
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5422
.L_tc_recycle_frame_done_5422:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b5c:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5421:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5421
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5421
.L_tc_recycle_frame_done_5421:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b5b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5420:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5420
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5420
.L_tc_recycle_frame_done_5420:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b5a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_541f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_541f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_541f
.L_tc_recycle_frame_done_541f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b59:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_541e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_541e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_541e
.L_tc_recycle_frame_done_541e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b58:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_541d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_541d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_541d
.L_tc_recycle_frame_done_541d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b57:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_541c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_541c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_541c
.L_tc_recycle_frame_done_541c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b56:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_541b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_541b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_541b
.L_tc_recycle_frame_done_541b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b55:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_541a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_541a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_541a
.L_tc_recycle_frame_done_541a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b54:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5419:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5419
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5419
.L_tc_recycle_frame_done_5419:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b53:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5418:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5418
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5418
.L_tc_recycle_frame_done_5418:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b52:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5417:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5417
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5417
.L_tc_recycle_frame_done_5417:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b51:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5416:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5416
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5416
.L_tc_recycle_frame_done_5416:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b50:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5415:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5415
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5415
.L_tc_recycle_frame_done_5415:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b4f:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5414:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5414
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5414
.L_tc_recycle_frame_done_5414:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b4e:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5413:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5413
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5413
.L_tc_recycle_frame_done_5413:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b4d:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5412:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5412
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5412
.L_tc_recycle_frame_done_5412:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b4c:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5411:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5411
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5411
.L_tc_recycle_frame_done_5411:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b4b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5410:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5410
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5410
.L_tc_recycle_frame_done_5410:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b4a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_540f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_540f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_540f
.L_tc_recycle_frame_done_540f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b49:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_540e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_540e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_540e
.L_tc_recycle_frame_done_540e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b48:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_540d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_540d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_540d
.L_tc_recycle_frame_done_540d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b47:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_540c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_540c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_540c
.L_tc_recycle_frame_done_540c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b46:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_540b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_540b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_540b
.L_tc_recycle_frame_done_540b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b45:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_540a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_540a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_540a
.L_tc_recycle_frame_done_540a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b44:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5409:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5409
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5409
.L_tc_recycle_frame_done_5409:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b43:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5408:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5408
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5408
.L_tc_recycle_frame_done_5408:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b42:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5407:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5407
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5407
.L_tc_recycle_frame_done_5407:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b41:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5406:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5406
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5406
.L_tc_recycle_frame_done_5406:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b40:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5405:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5405
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5405
.L_tc_recycle_frame_done_5405:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b3f:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5404:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5404
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5404
.L_tc_recycle_frame_done_5404:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b3e:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5403:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5403
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5403
.L_tc_recycle_frame_done_5403:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b3d:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5402:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5402
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5402
.L_tc_recycle_frame_done_5402:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b3c:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5401:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5401
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5401
.L_tc_recycle_frame_done_5401:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b3b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_5400:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_5400
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_5400
.L_tc_recycle_frame_done_5400:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b3a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53ff:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53ff
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53ff
.L_tc_recycle_frame_done_53ff:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b39:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53fe:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53fe
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53fe
.L_tc_recycle_frame_done_53fe:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b38:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53fd:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53fd
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53fd
.L_tc_recycle_frame_done_53fd:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b37:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53fc:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53fc
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53fc
.L_tc_recycle_frame_done_53fc:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b36:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53fb:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53fb
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53fb
.L_tc_recycle_frame_done_53fb:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b35:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53fa:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53fa
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53fa
.L_tc_recycle_frame_done_53fa:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b34:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53f9:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53f9
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53f9
.L_tc_recycle_frame_done_53f9:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b33:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53f8:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53f8
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53f8
.L_tc_recycle_frame_done_53f8:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b32:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53f7:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53f7
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53f7
.L_tc_recycle_frame_done_53f7:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b31:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53f6:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53f6
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53f6
.L_tc_recycle_frame_done_53f6:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b30:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53f5:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53f5
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53f5
.L_tc_recycle_frame_done_53f5:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b2f:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53f4:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53f4
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53f4
.L_tc_recycle_frame_done_53f4:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b2e:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53f3:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53f3
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53f3
.L_tc_recycle_frame_done_53f3:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b2d:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53f2:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53f2
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53f2
.L_tc_recycle_frame_done_53f2:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b2c:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53f1:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53f1
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53f1
.L_tc_recycle_frame_done_53f1:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b2b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53f0:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53f0
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53f0
.L_tc_recycle_frame_done_53f0:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b2a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53ef:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53ef
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53ef
.L_tc_recycle_frame_done_53ef:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b29:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53ee:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53ee
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53ee
.L_tc_recycle_frame_done_53ee:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b28:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53ed:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53ed
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53ed
.L_tc_recycle_frame_done_53ed:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b27:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53ec:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53ec
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53ec
.L_tc_recycle_frame_done_53ec:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b26:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53eb:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53eb
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53eb
.L_tc_recycle_frame_done_53eb:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b25:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53ea:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53ea
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53ea
.L_tc_recycle_frame_done_53ea:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b24:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53e9:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53e9
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53e9
.L_tc_recycle_frame_done_53e9:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b23:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53e8:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53e8
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53e8
.L_tc_recycle_frame_done_53e8:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b22:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53e7:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53e7
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53e7
.L_tc_recycle_frame_done_53e7:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b21:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53e6:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53e6
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53e6
.L_tc_recycle_frame_done_53e6:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b20:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53e5:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53e5
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53e5
.L_tc_recycle_frame_done_53e5:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b1f:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53e4:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53e4
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53e4
.L_tc_recycle_frame_done_53e4:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b1e:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53e3:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53e3
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53e3
.L_tc_recycle_frame_done_53e3:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b1d:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53e2:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53e2
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53e2
.L_tc_recycle_frame_done_53e2:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b1c:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53e1:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53e1
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53e1
.L_tc_recycle_frame_done_53e1:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b1b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53e0:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53e0
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53e0
.L_tc_recycle_frame_done_53e0:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b1a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53df:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53df
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53df
.L_tc_recycle_frame_done_53df:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b19:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53de:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53de
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53de
.L_tc_recycle_frame_done_53de:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b18:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53dd:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53dd
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53dd
.L_tc_recycle_frame_done_53dd:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b17:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53dc:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53dc
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53dc
.L_tc_recycle_frame_done_53dc:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b16:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53db:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53db
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53db
.L_tc_recycle_frame_done_53db:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b15:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53da:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53da
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53da
.L_tc_recycle_frame_done_53da:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b14:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53d9:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53d9
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53d9
.L_tc_recycle_frame_done_53d9:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b13:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53d8:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53d8
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53d8
.L_tc_recycle_frame_done_53d8:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b12:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53d7:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53d7
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53d7
.L_tc_recycle_frame_done_53d7:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b11:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53d6:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53d6
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53d6
.L_tc_recycle_frame_done_53d6:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b10:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53d5:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53d5
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53d5
.L_tc_recycle_frame_done_53d5:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b0f:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53d4:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53d4
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53d4
.L_tc_recycle_frame_done_53d4:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b0e:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53d3:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53d3
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53d3
.L_tc_recycle_frame_done_53d3:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b0d:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53d2:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53d2
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53d2
.L_tc_recycle_frame_done_53d2:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b0c:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53d1:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53d1
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53d1
.L_tc_recycle_frame_done_53d1:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b0b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53d0:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53d0
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53d0
.L_tc_recycle_frame_done_53d0:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b0a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53cf:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53cf
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53cf
.L_tc_recycle_frame_done_53cf:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b09:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53ce:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53ce
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53ce
.L_tc_recycle_frame_done_53ce:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b08:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53cd:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53cd
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53cd
.L_tc_recycle_frame_done_53cd:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b07:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53cc:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53cc
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53cc
.L_tc_recycle_frame_done_53cc:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b06:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53cb:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53cb
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53cb
.L_tc_recycle_frame_done_53cb:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b05:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 0 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_53ca:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_53ca
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_53ca
.L_tc_recycle_frame_done_53ca:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0b04:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)

	mov rdi, rax
	call print_sexpr_if_not_void

        mov rdi, fmt_memory_usage
        mov rsi, qword [top_of_memory]
        sub rsi, memory
        mov rax, 0
	ENTER
        call printf
	LEAVE
	leave
	ret

L_error_non_closure:
        mov rdi, qword [stderr]
        mov rsi, fmt_non_closure
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -2
        call exit

L_error_improper_list:
	mov rdi, qword [stderr]
	mov rsi, fmt_error_improper_list
	mov rax, 0
	ENTER
	call fprintf
	LEAVE
	mov rax, -7
	call exit

L_error_incorrect_arity_simple:
        mov rdi, qword [stderr]
        mov rsi, fmt_incorrect_arity_simple
        jmp L_error_incorrect_arity_common
L_error_incorrect_arity_opt:
        mov rdi, qword [stderr]
        mov rsi, fmt_incorrect_arity_opt
L_error_incorrect_arity_common:
        pop rdx
        pop rcx
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -6
        call exit

section .data
fmt_incorrect_arity_simple:
        db `!!! Expected %ld arguments, but given %ld\n\0`
fmt_incorrect_arity_opt:
        db `!!! Expected at least %ld arguments, but given %ld\n\0`
fmt_memory_usage:
        db `\n\n!!! Used %ld bytes of dynamically-allocated memory\n\n\0`
fmt_non_closure:
        db `!!! Attempting to apply a non-closure!\n\0`
fmt_error_improper_list:
	db `!!! The argument is not a proper list!\n\0`

section .bss
memory:
	resb gbytes(1)

section .data
top_of_memory:
        dq memory

section .text
malloc:
        mov rax, qword [top_of_memory]
        add qword [top_of_memory], rdi
        ret
        
print_sexpr_if_not_void:
	cmp rdi, sob_void
	jne print_sexpr
	ret

section .data
fmt_void:
	db `#<void>\0`
fmt_nil:
	db `()\0`
fmt_boolean_false:
	db `#f\0`
fmt_boolean_true:
	db `#t\0`
fmt_char_backslash:
	db `#\\\\\0`
fmt_char_dquote:
	db `#\\"\0`
fmt_char_simple:
	db `#\\%c\0`
fmt_char_null:
	db `#\\nul\0`
fmt_char_bell:
	db `#\\bell\0`
fmt_char_backspace:
	db `#\\backspace\0`
fmt_char_tab:
	db `#\\tab\0`
fmt_char_newline:
	db `#\\newline\0`
fmt_char_formfeed:
	db `#\\page\0`
fmt_char_return:
	db `#\\return\0`
fmt_char_escape:
	db `#\\esc\0`
fmt_char_space:
	db `#\\space\0`
fmt_char_hex:
	db `#\\x%02X\0`
fmt_closure:
	db `#<closure at 0x%08X env=0x%08X code=0x%08X>\0`
fmt_lparen:
	db `(\0`
fmt_dotted_pair:
	db ` . \0`
fmt_rparen:
	db `)\0`
fmt_space:
	db ` \0`
fmt_empty_vector:
	db `#()\0`
fmt_vector:
	db `#(\0`
fmt_real:
	db `%f\0`
fmt_fraction:
	db `%ld/%ld\0`
fmt_zero:
	db `0\0`
fmt_int:
	db `%ld\0`
fmt_unknown_sexpr_error:
	db `\n\n!!! Error: Unknown type of sexpr (0x%02X) `
	db `at address 0x%08X\n\n\0`
fmt_dquote:
	db `\"\0`
fmt_string_char:
        db `%c\0`
fmt_string_char_7:
        db `\\a\0`
fmt_string_char_8:
        db `\\b\0`
fmt_string_char_9:
        db `\\t\0`
fmt_string_char_10:
        db `\\n\0`
fmt_string_char_11:
        db `\\v\0`
fmt_string_char_12:
        db `\\f\0`
fmt_string_char_13:
        db `\\r\0`
fmt_string_char_34:
        db `\\"\0`
fmt_string_char_92:
        db `\\\\\0`
fmt_string_char_hex:
        db `\\x%X;\0`

section .text

print_sexpr:
	ENTER
	mov al, byte [rdi]
	cmp al, T_void
	je .Lvoid
	cmp al, T_nil
	je .Lnil
	cmp al, T_boolean_false
	je .Lboolean_false
	cmp al, T_boolean_true
	je .Lboolean_true
	cmp al, T_char
	je .Lchar
	cmp al, T_symbol
	je .Lsymbol
	cmp al, T_pair
	je .Lpair
	cmp al, T_vector
	je .Lvector
	cmp al, T_closure
	je .Lclosure
	cmp al, T_real
	je .Lreal
	cmp al, T_rational
	je .Lrational
	cmp al, T_string
	je .Lstring

	jmp .Lunknown_sexpr_type

.Lvoid:
	mov rdi, fmt_void
	jmp .Lemit

.Lnil:
	mov rdi, fmt_nil
	jmp .Lemit

.Lboolean_false:
	mov rdi, fmt_boolean_false
	jmp .Lemit

.Lboolean_true:
	mov rdi, fmt_boolean_true
	jmp .Lemit

.Lchar:
	mov al, byte [rdi + 1]
	cmp al, ' '
	jle .Lchar_whitespace
	cmp al, 92 		; backslash
	je .Lchar_backslash
	cmp al, '"'
	je .Lchar_dquote
	and rax, 255
	mov rdi, fmt_char_simple
	mov rsi, rax
	jmp .Lemit

.Lchar_whitespace:
	cmp al, 0
	je .Lchar_null
	cmp al, 7
	je .Lchar_bell
	cmp al, 8
	je .Lchar_backspace
	cmp al, 9
	je .Lchar_tab
	cmp al, 10
	je .Lchar_newline
	cmp al, 12
	je .Lchar_formfeed
	cmp al, 13
	je .Lchar_return
	cmp al, 27
	je .Lchar_escape
	and rax, 255
	cmp al, ' '
	je .Lchar_space
	mov rdi, fmt_char_hex
	mov rsi, rax
	jmp .Lemit	

.Lchar_backslash:
	mov rdi, fmt_char_backslash
	jmp .Lemit

.Lchar_dquote:
	mov rdi, fmt_char_dquote
	jmp .Lemit

.Lchar_null:
	mov rdi, fmt_char_null
	jmp .Lemit

.Lchar_bell:
	mov rdi, fmt_char_bell
	jmp .Lemit

.Lchar_backspace:
	mov rdi, fmt_char_backspace
	jmp .Lemit

.Lchar_tab:
	mov rdi, fmt_char_tab
	jmp .Lemit

.Lchar_newline:
	mov rdi, fmt_char_newline
	jmp .Lemit

.Lchar_formfeed:
	mov rdi, fmt_char_formfeed
	jmp .Lemit

.Lchar_return:
	mov rdi, fmt_char_return
	jmp .Lemit

.Lchar_escape:
	mov rdi, fmt_char_escape
	jmp .Lemit

.Lchar_space:
	mov rdi, fmt_char_space
	jmp .Lemit

.Lclosure:
	mov rsi, qword rdi
	mov rdi, fmt_closure
	mov rdx, SOB_CLOSURE_ENV(rsi)
	mov rcx, SOB_CLOSURE_CODE(rsi)
	jmp .Lemit

.Lsymbol:
	mov rdi, qword [rdi + 1] ; sob_string
	mov rsi, 1		 ; size = 1 byte
	mov rdx, qword [rdi + 1] ; length
	lea rdi, [rdi + 1 + 8]	 ; actual characters
	mov rcx, qword [stdout]	 ; FILE *
	call fwrite
	jmp .Lend
	
.Lpair:
	push rdi
	mov rdi, fmt_lparen
	mov rax, 0
        ENTER
	call printf
        LEAVE
	mov rdi, qword [rsp] 	; pair
	mov rdi, SOB_PAIR_CAR(rdi)
	call print_sexpr
	pop rdi 		; pair
	mov rdi, SOB_PAIR_CDR(rdi)
.Lcdr:
	mov al, byte [rdi]
	cmp al, T_nil
	je .Lcdr_nil
	cmp al, T_pair
	je .Lcdr_pair
	push rdi
	mov rdi, fmt_dotted_pair
	mov rax, 0
	ENTER
	call printf
	LEAVE
	pop rdi
	call print_sexpr
	mov rdi, fmt_rparen
	mov rax, 0
	ENTER
	call printf
	LEAVE
	LEAVE
	ret

.Lcdr_nil:
	mov rdi, fmt_rparen
	mov rax, 0
	ENTER
	call printf
	LEAVE
	LEAVE
	ret

.Lcdr_pair:
	push rdi
	mov rdi, fmt_space
	mov rax, 0
	ENTER
	call printf
	LEAVE
	mov rdi, qword [rsp]
	mov rdi, SOB_PAIR_CAR(rdi)
	call print_sexpr
	pop rdi
	mov rdi, SOB_PAIR_CDR(rdi)
	jmp .Lcdr

.Lvector:
	mov rax, qword [rdi + 1] ; length
	cmp rax, 0
	je .Lvector_empty
	push rdi
	mov rdi, fmt_vector
	mov rax, 0
	ENTER
	call printf
	LEAVE
	mov rdi, qword [rsp]
	push qword [rdi + 1]
	push 1
	mov rdi, qword [rdi + 1 + 8] ; v[0]
	call print_sexpr
.Lvector_loop:
	; [rsp] index
	; [rsp + 8*1] limit
	; [rsp + 8*2] vector
	mov rax, qword [rsp]
	cmp rax, qword [rsp + 8*1]
	je .Lvector_end
	mov rdi, fmt_space
	mov rax, 0
	ENTER
	call printf
	LEAVE
	mov rax, qword [rsp]
	mov rbx, qword [rsp + 8*2]
	mov rdi, qword [rbx + 1 + 8 + 8 * rax] ; v[i]
	call print_sexpr
	inc qword [rsp]
	jmp .Lvector_loop

.Lvector_end:
	add rsp, 8*3
	mov rdi, fmt_rparen
	jmp .Lemit	

.Lvector_empty:
	mov rdi, fmt_empty_vector
	jmp .Lemit

.Lreal:
	push qword [rdi + 1]
	movsd xmm0, qword [rsp]
	add rsp, 8*1
	mov rdi, fmt_real
	mov rax, 1
	ENTER
	call printf
	LEAVE
	jmp .Lend

.Lrational:
	mov rsi, qword [rdi + 1]
	mov rdx, qword [rdi + 1 + 8]
	cmp rsi, 0
	je .Lrat_zero
	cmp rdx, 1
	je .Lrat_int
	mov rdi, fmt_fraction
	jmp .Lemit

.Lrat_zero:
	mov rdi, fmt_zero
	jmp .Lemit

.Lrat_int:
	mov rdi, fmt_int
	jmp .Lemit

.Lstring:
	lea rax, [rdi + 1 + 8]
	push rax
	push qword [rdi + 1]
	mov rdi, fmt_dquote
	mov rax, 0
	ENTER
	call printf
	LEAVE
.Lstring_loop:
	; qword [rsp]: limit
	; qword [rsp + 8*1]: char *
	cmp qword [rsp], 0
	je .Lstring_end
	mov rax, qword [rsp + 8*1]
	mov al, byte [rax]
	and rax, 255
	cmp al, 7
        je .Lstring_char_7
        cmp al, 8
        je .Lstring_char_8
        cmp al, 9
        je .Lstring_char_9
        cmp al, 10
        je .Lstring_char_10
        cmp al, 11
        je .Lstring_char_11
        cmp al, 12
        je .Lstring_char_12
        cmp al, 13
        je .Lstring_char_13
        cmp al, 34
        je .Lstring_char_34
        cmp al, 92              ; \
        je .Lstring_char_92
        cmp al, ' '
        jl .Lstring_char_hex
        mov rdi, fmt_string_char
        mov rsi, rax
.Lstring_char_emit:
        mov rax, 0
        ENTER
        call printf
        LEAVE
        dec qword [rsp]
        inc qword [rsp + 8*1]
        jmp .Lstring_loop

.Lstring_char_7:
        mov rdi, fmt_string_char_7
        jmp .Lstring_char_emit

.Lstring_char_8:
        mov rdi, fmt_string_char_8
        jmp .Lstring_char_emit
        
.Lstring_char_9:
        mov rdi, fmt_string_char_9
        jmp .Lstring_char_emit

.Lstring_char_10:
        mov rdi, fmt_string_char_10
        jmp .Lstring_char_emit

.Lstring_char_11:
        mov rdi, fmt_string_char_11
        jmp .Lstring_char_emit

.Lstring_char_12:
        mov rdi, fmt_string_char_12
        jmp .Lstring_char_emit

.Lstring_char_13:
        mov rdi, fmt_string_char_13
        jmp .Lstring_char_emit

.Lstring_char_34:
        mov rdi, fmt_string_char_34
        jmp .Lstring_char_emit

.Lstring_char_92:
        mov rdi, fmt_string_char_92
        jmp .Lstring_char_emit

.Lstring_char_hex:
        mov rdi, fmt_string_char_hex
        mov rsi, rax
        jmp .Lstring_char_emit        

.Lstring_end:
	add rsp, 8 * 2
	mov rdi, fmt_dquote
	jmp .Lemit

.Lunknown_sexpr_type:
	mov rsi, fmt_unknown_sexpr_error
	and rax, 255
	mov rdx, rax
	mov rcx, rdi
	mov rdi, qword [stderr]
	mov rax, 0
	ENTER
	call fprintf
	LEAVE
	mov rax, -1
	call exit

.Lemit:
	mov rax, 0
	ENTER
	call printf
	LEAVE
	jmp .Lend

.Lend:
	LEAVE
	ret

;;; rdi: address of free variable
;;; rsi: address of code-pointer
bind_primitive:
        ENTER
        push rdi
        mov rdi, (1 + 8 + 8)
        call malloc
        pop rdi
        mov byte [rax], T_closure
        mov SOB_CLOSURE_ENV(rax), 0 ; dummy, lexical environment
        mov SOB_CLOSURE_CODE(rax), rsi ; code pointer
        mov qword [rdi], rax
        LEAVE
        ret

;;; PLEASE IMPLEMENT THIS PROCEDURE
L_code_ptr_bin_apply:
	enter 0, 0 ; mov rbp, rsp  push rbp
	cmp COUNT, 2 ;check if number of arguments are 2 - closure and list
	jne L_error_arg_count_2
	mov rax, PARAM(0) ;first argument - closure
        cmp byte [rax], T_closure
        jne L_error_non_closure
        mov rax, PARAM(1) ;second argument - list
        cmp byte [rax], T_pair
        je .L_apply_second_arg_is_pair
        cmp rax, sob_nil
        je .L_apply_second_arg_is_null
        jmp L_error_improper_list
.L_apply_second_arg_is_pair:
	mov rdx, 0 ; initialize rdx to 0
	mov rsi, PARAM(1) ; rsi will be used to iterate through the list 
.L_start_loop_length_pair:
	cmp rsi, sob_nil ; check if the current element is the end of the list 
	je .L_apply_end_count_list ; if it is, jump to done 
	mov rsi, SOB_PAIR_CDR(rsi)  ; move to the next element in the list 
	inc rdx ; increment the counter in rdx 
	sub rsp, 8
	jmp .L_start_loop_length_pair ; jump back to the beginning of the loop 
.L_apply_end_count_list: 
	mov rbx, rsp
	mov rsi, PARAM(1)
.L_apply_push_elements: 
	cmp rsi, sob_nil
	je .L_apply_push_elements_end
	mov rcx, SOB_PAIR_CAR(rsi)
	mov qword [rbx], rcx
	mov rsi, SOB_PAIR_CDR(rsi) 
	add rbx, 8
	jmp .L_apply_push_elements
.L_apply_push_elements_end:
	push rdx
	jmp .L_apply_end
.L_apply_second_arg_is_null:
	push 0
.L_apply_end:
	mov rax, PARAM(0)
	push SOB_CLOSURE_ENV(rax) ;closure in rax
        push qword [rbp + 8 * 1] ; old ret addr
        push qword [rbp] ; same the old rbp
        add rdx, 4
        mov rcx, COUNT
        lea rcx, [rbp + 8*4 + rcx * 8]
        mov rdi, rbp
.L_startLoop_recycle:
        cmp rdx, 0
        je .L_endLoop_recycle
       	sub rcx, 8
        sub rdi, 8
        mov rsi, [rdi]
        mov qword [rcx], rsi
        dec rdx
        jmp .L_startLoop_recycle
.L_endLoop_recycle:
        mov rsp, rcx
        pop rbp ; restore the old rbp
        jmp SOB_CLOSURE_CODE(rax)
		

	
L_code_ptr_is_null:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_nil
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_pair:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_pair
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_is_void:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_void
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_char:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_char
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_string:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_string
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_symbol:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_symbol
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_vector:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_vector
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_closure:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_closure
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_real:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_real
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_rational:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_rational
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_boolean:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        mov bl, byte [rax]
        and bl, T_boolean
        je .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_is_number:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        mov bl, byte [rax]
        and bl, T_number
        je .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_is_collection:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        mov bl, byte [rax]
        and bl, T_collection
        je .L_false
        mov rax, sob_boolean_true
        jmp .L_end
.L_false:
        mov rax, sob_boolean_false
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_cons:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rdi, (1 + 8 + 8)
        call malloc
        mov byte [rax], T_pair
        mov rbx, PARAM(0)
        mov SOB_PAIR_CAR(rax), rbx
        mov rbx, PARAM(1)
        mov SOB_PAIR_CDR(rax), rbx
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_display_sexpr:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rdi, PARAM(0)
        call print_sexpr
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_write_char:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_char(rax)
        mov al, SOB_CHAR_VALUE(rax)
        and rax, 255
        mov rdi, fmt_char
        mov rsi, rax
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_car:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rax, SOB_PAIR_CAR(rax)
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_cdr:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rax, SOB_PAIR_CDR(rax)
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_string_length:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_string(rax)
        mov rdi, SOB_STRING_LENGTH(rax)
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_vector_length:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_vector(rax)
        mov rdi, SOB_VECTOR_LENGTH(rax)
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_real_to_integer:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rbx, PARAM(0)
        assert_real(rbx)
        movsd xmm0, qword [rbx + 1]
        cvttsd2si rdi, xmm0
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_exit:
        ENTER
        cmp COUNT, 0
        jne L_error_arg_count_0
        mov rax, 0
        call exit

L_code_ptr_integer_to_real:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_integer(rax)
        push qword [rax + 1]
        cvtsi2sd xmm0, qword [rsp]
        call make_real
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_rational_to_real:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_rational(rax)
        push qword [rax + 1]
        cvtsi2sd xmm0, qword [rsp]
        push qword [rax + 1 + 8]
        cvtsi2sd xmm1, qword [rsp]
        divsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_char_to_integer:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_char(rax)
        mov al, byte [rax + 1]
        and rax, 255
        mov rdi, rax
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_integer_to_char:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_integer(rax)
        mov rbx, qword [rax + 1]
        cmp rbx, 0
        jle L_error_integer_range
        cmp rbx, 256
        jge L_error_integer_range
        mov rdi, (1 + 1)
        call malloc
        mov byte [rax], T_char
        mov byte [rax + 1], bl
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_trng:
        ENTER
        cmp COUNT, 0
        jne L_error_arg_count_0
        rdrand rdi
        shr rdi, 1
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(0)

L_code_ptr_is_zero:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_rational
        je .L_rational
        cmp byte [rax], T_real
        je .L_real
        jmp L_error_incorrect_type
.L_rational:
        cmp qword [rax + 1], 0
        je .L_zero
        jmp .L_not_zero
.L_real:
        pxor xmm0, xmm0
        push qword [rax + 1]
        movsd xmm1, qword [rsp]
        ucomisd xmm0, xmm1
        je .L_zero
.L_not_zero:
        mov rax, sob_boolean_false
        jmp .L_end
.L_zero:
        mov rax, sob_boolean_true
.L_end:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_is_integer:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        cmp byte [rax], T_rational
        jne .L_false
        cmp qword [rax + 1 + 8], 1
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_raw_bin_add_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        addsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_sub_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        subsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_mul_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        mulsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_div_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rbx, PARAM(0)
        assert_real(rbx)
        mov rcx, PARAM(1)
        assert_real(rcx)
        movsd xmm0, qword [rbx + 1]
        movsd xmm1, qword [rcx + 1]
        pxor xmm2, xmm2
        ucomisd xmm1, xmm2
        je L_error_division_by_zero
        divsd xmm0, xmm1
        call make_real
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_add_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1 + 8] ; den 2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1]     ; num2
        cqo
        imul rbx
        add rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1 + 8] ; den2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_sub_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1 + 8] ; den 2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1]     ; num2
        cqo
        imul rbx
        sub rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1 + 8] ; den2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_bin_mul_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1] ; num2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1 + 8] ; den2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_raw_bin_div_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov r8, PARAM(0)
        assert_rational(r8)
        mov r9, PARAM(1)
        assert_rational(r9)
        cmp qword [r9 + 1], 0
        je L_error_division_by_zero
        mov rax, qword [r8 + 1] ; num1
        mov rbx, qword [r9 + 1 + 8] ; den 2
        cqo
        imul rbx
        mov rsi, rax
        mov rax, qword [r8 + 1 + 8] ; den1
        mov rbx, qword [r9 + 1] ; num2
        cqo
        imul rbx
        mov rdi, rax
        call normalize_rational
        LEAVE
        ret AND_KILL_FRAME(2)
        
normalize_rational:
        push rsi
        push rdi
        call gcd
        mov rbx, rax
        pop rax
        cqo
        idiv rbx
        mov r8, rax
        pop rax
        cqo
        idiv rbx
        mov r9, rax
        mov rdi, (1 + 8 + 8)
        call malloc
        mov byte [rax], T_rational
        mov qword [rax + 1], r9
        mov qword [rax + 1 + 8], r8
        ret

iabs:
        mov rax, rdi
        cmp rax, 0
        jl .Lneg
        ret
.Lneg:
        neg rax
        ret

gcd:
        call iabs
        mov rbx, rax
        mov rdi, rsi
        call iabs
        cmp rax, 0
        jne .L0
        xchg rax, rbx
.L0:
        cmp rbx, 0
        je .L1
        cqo
        div rbx
        mov rax, rdx
        xchg rax, rbx
        jmp .L0
.L1:
        ret

L_code_ptr_error:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_symbol(rsi)
        mov rsi, PARAM(1)
        assert_string(rsi)
        mov rdi, fmt_scheme_error_part_1
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rdi, PARAM(0)
        call print_sexpr
        mov rdi, fmt_scheme_error_part_2
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rax, PARAM(1)       ; sob_string
        mov rsi, 1              ; size = 1 byte
        mov rdx, qword [rax + 1] ; length
        lea rdi, [rax + 1 + 8]   ; actual characters
        mov rcx, qword [stdout]  ; FILE*
        call fwrite
        mov rdi, fmt_scheme_error_part_3
        mov rax, 0
	ENTER
        call printf
	LEAVE
        mov rax, -9
        call exit

L_code_ptr_raw_less_than_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_real(rsi)
        mov rdi, PARAM(1)
        assert_real(rdi)
        movsd xmm0, qword [rsi + 1]
        movsd xmm1, qword [rdi + 1]
        comisd xmm0, xmm1
        jae .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_raw_less_than_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_rational(rsi)
        mov rdi, PARAM(1)
        assert_rational(rdi)
        mov rax, qword [rsi + 1] ; num1
        cqo
        imul qword [rdi + 1 + 8] ; den2
        mov rcx, rax
        mov rax, qword [rsi + 1 + 8] ; den1
        cqo
        imul qword [rdi + 1]          ; num2
        sub rcx, rax
        jge .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_raw_equal_rr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_real(rsi)
        mov rdi, PARAM(1)
        assert_real(rdi)
        movsd xmm0, qword [rsi + 1]
        movsd xmm1, qword [rdi + 1]
        comisd xmm0, xmm1
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_raw_equal_qq:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_rational(rsi)
        mov rdi, PARAM(1)
        assert_rational(rdi)
        mov rax, qword [rsi + 1] ; num1
        cqo
        imul qword [rdi + 1 + 8] ; den2
        mov rcx, rax
        mov rax, qword [rdi + 1 + 8] ; den1
        cqo
        imul qword [rdi + 1]          ; num2
        sub rcx, rax
        jne .L_false
        mov rax, sob_boolean_true
        jmp .L_exit
.L_false:
        mov rax, sob_boolean_false
.L_exit:
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_quotient:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_integer(rsi)
        mov rdi, PARAM(1)
        assert_integer(rdi)
        mov rax, qword [rsi + 1]
        mov rbx, qword [rdi + 1]
        cmp rbx, 0
        je L_error_division_by_zero
        cqo
        idiv rbx
        mov rdi, rax
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_remainder:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rsi, PARAM(0)
        assert_integer(rsi)
        mov rdi, PARAM(1)
        assert_integer(rdi)
        mov rax, qword [rsi + 1]
        mov rbx, qword [rdi + 1]
        cmp rbx, 0
        je L_error_division_by_zero
        cqo
        idiv rbx
        mov rdi, rdx
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_set_car:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rbx, PARAM(1)
        mov SOB_PAIR_CAR(rax), rbx
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_set_cdr:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rax, PARAM(0)
        assert_pair(rax)
        mov rbx, PARAM(1)
        mov SOB_PAIR_CDR(rax), rbx
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_string_ref:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rdi, PARAM(0)
        assert_string(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov bl, byte [rdi + 1 + 8 + 1 * rcx]
        mov rdi, 2
        call malloc
        mov byte [rax], T_char
        mov byte [rax + 1], bl
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_vector_ref:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rdi, PARAM(0)
        assert_vector(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov rax, [rdi + 1 + 8 + 8 * rcx]
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_vector_set:
        ENTER
        cmp COUNT, 3
        jne L_error_arg_count_3
        mov rdi, PARAM(0)
        assert_vector(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov rax, PARAM(2)
        mov qword [rdi + 1 + 8 + 8 * rcx], rax
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(3)

L_code_ptr_string_set:
        ENTER
        cmp COUNT, 3
        jne L_error_arg_count_3
        mov rdi, PARAM(0)
        assert_string(rdi)
        mov rsi, PARAM(1)
        assert_integer(rsi)
        mov rdx, qword [rdi + 1]
        mov rcx, qword [rsi + 1]
        cmp rcx, rdx
        jge L_error_integer_range
        cmp rcx, 0
        jl L_error_integer_range
        mov rax, PARAM(2)
        assert_char(rax)
        mov al, byte [rax + 1]
        mov byte [rdi + 1 + 8 + 1 * rcx], al
        mov rax, sob_void
        LEAVE
        ret AND_KILL_FRAME(3)

L_code_ptr_make_vector:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rcx, PARAM(0)
        assert_integer(rcx)
        mov rcx, qword [rcx + 1]
        cmp rcx, 0
        jl L_error_integer_range
        mov rdx, PARAM(1)
        lea rdi, [1 + 8 + 8 * rcx]
        call malloc
        mov byte [rax], T_vector
        mov qword [rax + 1], rcx
        mov r8, 0
.L0:
        cmp r8, rcx
        je .L1
        mov qword [rax + 1 + 8 + 8 * r8], rdx
        inc r8
        jmp .L0
.L1:
        LEAVE
        ret AND_KILL_FRAME(2)
        
L_code_ptr_make_string:
        ENTER
        cmp COUNT, 2
        jne L_error_arg_count_2
        mov rcx, PARAM(0)
        assert_integer(rcx)
        mov rcx, qword [rcx + 1]
        cmp rcx, 0
        jl L_error_integer_range
        mov rdx, PARAM(1)
        assert_char(rdx)
        mov dl, byte [rdx + 1]
        lea rdi, [1 + 8 + 1 * rcx]
        call malloc
        mov byte [rax], T_string
        mov qword [rax + 1], rcx
        mov r8, 0
.L0:
        cmp r8, rcx
        je .L1
        mov byte [rax + 1 + 8 + 1 * r8], dl
        inc r8
        jmp .L0
.L1:
        LEAVE
        ret AND_KILL_FRAME(2)

L_code_ptr_numerator:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_rational(rax)
        mov rdi, qword [rax + 1]
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)
        
L_code_ptr_denominator:
        ENTER
        cmp COUNT, 1
        jne L_error_arg_count_1
        mov rax, PARAM(0)
        assert_rational(rax)
        mov rdi, qword [rax + 1 + 8]
        call make_integer
        LEAVE
        ret AND_KILL_FRAME(1)

L_code_ptr_eq:
	ENTER
	cmp COUNT, 2
	jne L_error_arg_count_2
	mov rdi, PARAM(0)
	mov rsi, PARAM(1)
	cmp rdi, rsi
	je .L_eq_true
	mov dl, byte [rdi]
	cmp dl, byte [rsi]
	jne .L_eq_false
	cmp dl, T_char
	je .L_char
	cmp dl, T_symbol
	je .L_symbol
	cmp dl, T_real
	je .L_real
	cmp dl, T_rational
	je .L_rational
	jmp .L_eq_false
.L_rational:
	mov rax, qword [rsi + 1]
	cmp rax, qword [rdi + 1]
	jne .L_eq_false
	mov rax, qword [rsi + 1 + 8]
	cmp rax, qword [rdi + 1 + 8]
	jne .L_eq_false
	jmp .L_eq_true
.L_real:
	mov rax, qword [rsi + 1]
	cmp rax, qword [rdi + 1]
.L_symbol:
	; never reached, because symbols are static!
	; but I'm keeping it in case, I'll ever change
	; the implementation
	mov rax, qword [rsi + 1]
	cmp rax, qword [rdi + 1]
.L_char:
	mov bl, byte [rsi + 1]
	cmp bl, byte [rdi + 1]
	jne .L_eq_false
.L_eq_true:
	mov rax, sob_boolean_true
	jmp .L_eq_exit
.L_eq_false:
	mov rax, sob_boolean_false
.L_eq_exit:
	LEAVE
	ret AND_KILL_FRAME(2)

make_real:
        ENTER
        mov rdi, (1 + 8)
        call malloc
        mov byte [rax], T_real
        movsd qword [rax + 1], xmm0
        LEAVE
        ret
        
make_integer:
        ENTER
        mov rsi, rdi
        mov rdi, (1 + 8 + 8)
        call malloc
        mov byte [rax], T_rational
        mov qword [rax + 1], rsi
        mov qword [rax + 1 + 8], 1
        LEAVE
        ret
        
L_error_integer_range:
        mov rdi, qword [stderr]
        mov rsi, fmt_integer_range
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -5
        call exit

L_error_arg_count_0:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_0
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_1:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_1
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_2:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_2
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_12:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_12
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit

L_error_arg_count_3:
        mov rdi, qword [stderr]
        mov rsi, fmt_arg_count_3
        mov rdx, COUNT
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -3
        call exit
        
L_error_incorrect_type:
        mov rdi, qword [stderr]
        mov rsi, fmt_type
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -4
        call exit

L_error_division_by_zero:
        mov rdi, qword [stderr]
        mov rsi, fmt_division_by_zero
        mov rax, 0
	ENTER
        call fprintf
	LEAVE
        mov rax, -8
        call exit

section .data
fmt_char:
        db `%c\0`
fmt_arg_count_0:
        db `!!! Expecting zero arguments. Found %d\n\0`
fmt_arg_count_1:
        db `!!! Expecting one argument. Found %d\n\0`
fmt_arg_count_12:
        db `!!! Expecting one required and one optional argument. Found %d\n\0`
fmt_arg_count_2:
        db `!!! Expecting two arguments. Found %d\n\0`
fmt_arg_count_3:
        db `!!! Expecting three arguments. Found %d\n\0`
fmt_type:
        db `!!! Function passed incorrect type\n\0`
fmt_integer_range:
        db `!!! Incorrect integer range\n\0`
fmt_division_by_zero:
        db `!!! Division by zero\n\0`
fmt_scheme_error_part_1:
        db `\n!!! The procedure \0`
fmt_scheme_error_part_2:
        db ` asked to terminate the program\n`
        db `    with the following message:\n\n\0`
fmt_scheme_error_part_3:
        db `\n\nGoodbye!\n\n\0`

