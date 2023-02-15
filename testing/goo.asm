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
.L_lambda_simple_env_loop_0001:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0001
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0001
.L_lambda_simple_env_end_0001:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0001:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0001
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0001
.L_lambda_simple_params_end_0001:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0001
	jmp .L_lambda_simple_end_0001
.L_lambda_simple_code_0001:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0001
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0001:
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
.L_tc_recycle_frame_loop_0001:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0001
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0001
.L_tc_recycle_frame_done_0001:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0001:	; new closure is in rax
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
.L_lambda_simple_env_loop_0002:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0002
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0002
.L_lambda_simple_env_end_0002:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0002:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0002
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0002
.L_lambda_simple_params_end_0002:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0002
	jmp .L_lambda_simple_end_0002
.L_lambda_simple_code_0002:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0002
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0002:
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
.L_tc_recycle_frame_loop_0002:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0002
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0002
.L_tc_recycle_frame_done_0002:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0002:	; new closure is in rax
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
.L_lambda_simple_env_loop_0003:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0003
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0003
.L_lambda_simple_env_end_0003:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0003:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0003
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0003
.L_lambda_simple_params_end_0003:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0003
	jmp .L_lambda_simple_end_0003
.L_lambda_simple_code_0003:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0003
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0003:
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
.L_tc_recycle_frame_loop_0003:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0003
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0003
.L_tc_recycle_frame_done_0003:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0003:	; new closure is in rax
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
.L_lambda_simple_env_loop_0004:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0004
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0004
.L_lambda_simple_env_end_0004:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0004:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0004
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0004
.L_lambda_simple_params_end_0004:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0004
	jmp .L_lambda_simple_end_0004
.L_lambda_simple_code_0004:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0004
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0004:
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
.L_tc_recycle_frame_loop_0004:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0004
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0004
.L_tc_recycle_frame_done_0004:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0004:	; new closure is in rax
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
.L_lambda_simple_env_loop_0005:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0005
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0005
.L_lambda_simple_env_end_0005:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0005:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0005
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0005
.L_lambda_simple_params_end_0005:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0005
	jmp .L_lambda_simple_end_0005
.L_lambda_simple_code_0005:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0005
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0005:
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
.L_tc_recycle_frame_loop_0005:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0005
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0005
.L_tc_recycle_frame_done_0005:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0005:	; new closure is in rax
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
.L_lambda_simple_env_loop_0006:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0006
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0006
.L_lambda_simple_env_end_0006:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0006:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0006
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0006
.L_lambda_simple_params_end_0006:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0006
	jmp .L_lambda_simple_end_0006
.L_lambda_simple_code_0006:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0006
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0006:
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
.L_tc_recycle_frame_loop_0006:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0006
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0006
.L_tc_recycle_frame_done_0006:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0006:	; new closure is in rax
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
.L_lambda_simple_env_loop_0007:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0007
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0007
.L_lambda_simple_env_end_0007:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0007:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0007
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0007
.L_lambda_simple_params_end_0007:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0007
	jmp .L_lambda_simple_end_0007
.L_lambda_simple_code_0007:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0007
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0007:
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
.L_tc_recycle_frame_loop_0007:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0007
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0007
.L_tc_recycle_frame_done_0007:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0007:	; new closure is in rax
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
.L_lambda_simple_env_loop_0008:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0008
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0008
.L_lambda_simple_env_end_0008:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0008:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0008
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0008
.L_lambda_simple_params_end_0008:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0008
	jmp .L_lambda_simple_end_0008
.L_lambda_simple_code_0008:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0008
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0008:
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
.L_tc_recycle_frame_loop_0008:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0008
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0008
.L_tc_recycle_frame_done_0008:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0008:	; new closure is in rax
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
.L_lambda_simple_env_loop_0009:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0009
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0009
.L_lambda_simple_env_end_0009:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0009:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0009
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0009
.L_lambda_simple_params_end_0009:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0009
	jmp .L_lambda_simple_end_0009
.L_lambda_simple_code_0009:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0009
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0009:
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
.L_tc_recycle_frame_loop_0009:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0009
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0009
.L_tc_recycle_frame_done_0009:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0009:	; new closure is in rax
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
.L_lambda_simple_env_loop_000a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_000a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_000a
.L_lambda_simple_env_end_000a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_000a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_000a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_000a
.L_lambda_simple_params_end_000a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_000a
	jmp .L_lambda_simple_end_000a
.L_lambda_simple_code_000a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_000a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_000a:
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
.L_tc_recycle_frame_loop_000a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_000a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_000a
.L_tc_recycle_frame_done_000a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_000a:	; new closure is in rax
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
.L_lambda_simple_env_loop_000b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_000b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_000b
.L_lambda_simple_env_end_000b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_000b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_000b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_000b
.L_lambda_simple_params_end_000b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_000b
	jmp .L_lambda_simple_end_000b
.L_lambda_simple_code_000b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_000b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_000b:
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
.L_tc_recycle_frame_loop_000b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_000b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_000b
.L_tc_recycle_frame_done_000b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_000b:	; new closure is in rax
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
.L_lambda_simple_env_loop_000c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_000c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_000c
.L_lambda_simple_env_end_000c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_000c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_000c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_000c
.L_lambda_simple_params_end_000c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_000c
	jmp .L_lambda_simple_end_000c
.L_lambda_simple_code_000c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_000c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_000c:
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
.L_tc_recycle_frame_loop_000c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_000c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_000c
.L_tc_recycle_frame_done_000c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_000c:	; new closure is in rax
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
.L_lambda_simple_env_loop_000d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_000d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_000d
.L_lambda_simple_env_end_000d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_000d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_000d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_000d
.L_lambda_simple_params_end_000d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_000d
	jmp .L_lambda_simple_end_000d
.L_lambda_simple_code_000d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_000d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_000d:
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
.L_tc_recycle_frame_loop_000d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_000d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_000d
.L_tc_recycle_frame_done_000d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_000d:	; new closure is in rax
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
.L_lambda_simple_env_loop_000e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_000e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_000e
.L_lambda_simple_env_end_000e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_000e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_000e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_000e
.L_lambda_simple_params_end_000e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_000e
	jmp .L_lambda_simple_end_000e
.L_lambda_simple_code_000e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_000e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_000e:
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
.L_tc_recycle_frame_loop_000e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_000e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_000e
.L_tc_recycle_frame_done_000e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_000e:	; new closure is in rax
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
.L_lambda_simple_env_loop_000f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_000f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_000f
.L_lambda_simple_env_end_000f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_000f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_000f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_000f
.L_lambda_simple_params_end_000f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_000f
	jmp .L_lambda_simple_end_000f
.L_lambda_simple_code_000f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_000f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_000f:
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
.L_tc_recycle_frame_loop_000f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_000f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_000f
.L_tc_recycle_frame_done_000f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_000f:	; new closure is in rax
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
.L_lambda_simple_env_loop_0010:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0010
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0010
.L_lambda_simple_env_end_0010:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0010:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0010
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0010
.L_lambda_simple_params_end_0010:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0010
	jmp .L_lambda_simple_end_0010
.L_lambda_simple_code_0010:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0010
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0010:
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
.L_tc_recycle_frame_loop_0010:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0010
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0010
.L_tc_recycle_frame_done_0010:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0010:	; new closure is in rax
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
.L_lambda_simple_env_loop_0011:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0011
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0011
.L_lambda_simple_env_end_0011:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0011:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0011
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0011
.L_lambda_simple_params_end_0011:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0011
	jmp .L_lambda_simple_end_0011
.L_lambda_simple_code_0011:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0011
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0011:
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
.L_tc_recycle_frame_loop_0011:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0011
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0011
.L_tc_recycle_frame_done_0011:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0011:	; new closure is in rax
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
.L_lambda_simple_env_loop_0012:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0012
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0012
.L_lambda_simple_env_end_0012:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0012:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0012
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0012
.L_lambda_simple_params_end_0012:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0012
	jmp .L_lambda_simple_end_0012
.L_lambda_simple_code_0012:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0012
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0012:
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
.L_tc_recycle_frame_loop_0012:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0012
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0012
.L_tc_recycle_frame_done_0012:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0012:	; new closure is in rax
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
.L_lambda_simple_env_loop_0013:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0013
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0013
.L_lambda_simple_env_end_0013:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0013:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0013
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0013
.L_lambda_simple_params_end_0013:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0013
	jmp .L_lambda_simple_end_0013
.L_lambda_simple_code_0013:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0013
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0013:
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
.L_tc_recycle_frame_loop_0013:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0013
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0013
.L_tc_recycle_frame_done_0013:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0013:	; new closure is in rax
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
.L_lambda_simple_env_loop_0014:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0014
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0014
.L_lambda_simple_env_end_0014:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0014:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0014
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0014
.L_lambda_simple_params_end_0014:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0014
	jmp .L_lambda_simple_end_0014
.L_lambda_simple_code_0014:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0014
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0014:
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
.L_tc_recycle_frame_loop_0014:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0014
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0014
.L_tc_recycle_frame_done_0014:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0014:	; new closure is in rax
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
.L_lambda_simple_env_loop_0015:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0015
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0015
.L_lambda_simple_env_end_0015:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0015:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0015
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0015
.L_lambda_simple_params_end_0015:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0015
	jmp .L_lambda_simple_end_0015
.L_lambda_simple_code_0015:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0015
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0015:
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
.L_tc_recycle_frame_loop_0015:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0015
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0015
.L_tc_recycle_frame_done_0015:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0015:	; new closure is in rax
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
.L_lambda_simple_env_loop_0016:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0016
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0016
.L_lambda_simple_env_end_0016:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0016:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0016
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0016
.L_lambda_simple_params_end_0016:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0016
	jmp .L_lambda_simple_end_0016
.L_lambda_simple_code_0016:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0016
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0016:
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
.L_tc_recycle_frame_loop_0016:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0016
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0016
.L_tc_recycle_frame_done_0016:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0016:	; new closure is in rax
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
.L_lambda_simple_env_loop_0017:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0017
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0017
.L_lambda_simple_env_end_0017:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0017:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0017
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0017
.L_lambda_simple_params_end_0017:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0017
	jmp .L_lambda_simple_end_0017
.L_lambda_simple_code_0017:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0017
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0017:
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
.L_tc_recycle_frame_loop_0017:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0017
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0017
.L_tc_recycle_frame_done_0017:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0017:	; new closure is in rax
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
.L_lambda_simple_env_loop_0018:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0018
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0018
.L_lambda_simple_env_end_0018:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0018:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0018
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0018
.L_lambda_simple_params_end_0018:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0018
	jmp .L_lambda_simple_end_0018
.L_lambda_simple_code_0018:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0018
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0018:
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
.L_tc_recycle_frame_loop_0018:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0018
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0018
.L_tc_recycle_frame_done_0018:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0018:	; new closure is in rax
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
.L_lambda_simple_env_loop_0019:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0019
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0019
.L_lambda_simple_env_end_0019:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0019:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0019
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0019
.L_lambda_simple_params_end_0019:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0019
	jmp .L_lambda_simple_end_0019
.L_lambda_simple_code_0019:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0019
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0019:
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
.L_tc_recycle_frame_loop_0019:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0019
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0019
.L_tc_recycle_frame_done_0019:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0019:	; new closure is in rax
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
.L_lambda_simple_env_loop_001a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_001a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_001a
.L_lambda_simple_env_end_001a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_001a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_001a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_001a
.L_lambda_simple_params_end_001a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_001a
	jmp .L_lambda_simple_end_001a
.L_lambda_simple_code_001a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_001a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_001a:
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
.L_tc_recycle_frame_loop_001a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_001a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_001a
.L_tc_recycle_frame_done_001a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_001a:	; new closure is in rax
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
.L_lambda_simple_env_loop_001b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_001b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_001b
.L_lambda_simple_env_end_001b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_001b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_001b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_001b
.L_lambda_simple_params_end_001b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_001b
	jmp .L_lambda_simple_end_001b
.L_lambda_simple_code_001b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_001b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_001b:
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
.L_tc_recycle_frame_loop_001b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_001b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_001b
.L_tc_recycle_frame_done_001b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_001b:	; new closure is in rax
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
.L_lambda_simple_env_loop_001c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_001c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_001c
.L_lambda_simple_env_end_001c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_001c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_001c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_001c
.L_lambda_simple_params_end_001c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_001c
	jmp .L_lambda_simple_end_001c
.L_lambda_simple_code_001c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_001c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_001c:
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
.L_tc_recycle_frame_loop_001c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_001c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_001c
.L_tc_recycle_frame_done_001c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_001c:	; new closure is in rax
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
.L_lambda_simple_env_loop_001d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_001d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_001d
.L_lambda_simple_env_end_001d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_001d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_001d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_001d
.L_lambda_simple_params_end_001d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_001d
	jmp .L_lambda_simple_end_001d
.L_lambda_simple_code_001d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_001d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_001d:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0001
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0001
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
.L_tc_recycle_frame_loop_001d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_001d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_001d
.L_tc_recycle_frame_done_001d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0001
          .L_if_else_0001:
          	mov rax, L_constants + 2
.L_if_end_0001:
.L_or_end_0001:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_001d:	; new closure is in rax
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
.L_lambda_opt_env_loop_0001:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_0001
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0001
.L_lambda_opt_env_end_0001:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0001:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_0001
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0001
.L_lambda_opt_params_end_0001:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0001
	jmp .L_lambda_opt_end_0001
.L_lambda_opt_code_0001:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0001
	jg .L_lambda_opt_arity_check_more_0001
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0001:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0001:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0001
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0001
.L_lambda_opt_stack_shrink_loop_exit_0001:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0001
.L_lambda_opt_arity_check_more_0001:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0002:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0002
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
	jmp .L_lambda_opt_stack_shrink_loop_0002
.L_lambda_opt_stack_shrink_loop_exit_0002:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_0003:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0003
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0003
.L_lambda_opt_stack_shrink_loop_exit_0003:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0001:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0001:	; new closure is in rax
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
.L_lambda_simple_env_loop_001e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_001e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_001e
.L_lambda_simple_env_end_001e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_001e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_001e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_001e
.L_lambda_simple_params_end_001e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_001e
	jmp .L_lambda_simple_end_001e
.L_lambda_simple_code_001e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_001e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_001e:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	cmp rax, sob_boolean_false
          	je .L_if_else_0002
          	mov rax, L_constants + 2
	jmp .L_if_end_0002
          .L_if_else_0002:
          	mov rax, L_constants + 3
.L_if_end_0002:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_001e:	; new closure is in rax
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
.L_lambda_simple_env_loop_001f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_001f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_001f
.L_lambda_simple_env_end_001f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_001f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_001f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_001f
.L_lambda_simple_params_end_001f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_001f
	jmp .L_lambda_simple_end_001f
.L_lambda_simple_code_001f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_001f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_001f:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0003
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
.L_tc_recycle_frame_loop_001e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_001e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_001e
.L_tc_recycle_frame_done_001e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0003
          .L_if_else_0003:
          	mov rax, L_constants + 2
.L_if_end_0003:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_001f:	; new closure is in rax
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
.L_lambda_simple_env_loop_0020:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0020
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0020
.L_lambda_simple_env_end_0020:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0020:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0020
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0020
.L_lambda_simple_params_end_0020:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0020
	jmp .L_lambda_simple_end_0020
.L_lambda_simple_code_0020:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0020
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0020:
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
.L_lambda_simple_env_loop_0021:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0021
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0021
.L_lambda_simple_env_end_0021:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0021:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0021
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0021
.L_lambda_simple_params_end_0021:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0021
	jmp .L_lambda_simple_end_0021
.L_lambda_simple_code_0021:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0021
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0021:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0004
          	mov rax, qword [rbp + 8 * (4 + 0)]
	jmp .L_if_end_0004
          .L_if_else_0004:
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
.L_tc_recycle_frame_loop_001f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_001f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_001f
.L_tc_recycle_frame_done_001f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0004:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0021:	; new closure is in rax
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
.L_lambda_opt_env_loop_0002:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0002
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0002
.L_lambda_opt_env_end_0002:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0002:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0002
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0002
.L_lambda_opt_params_end_0002:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0002
	jmp .L_lambda_opt_end_0002
.L_lambda_opt_code_0002:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0002
	jg .L_lambda_opt_arity_check_more_0002
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0002:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0004:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0004
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0004
.L_lambda_opt_stack_shrink_loop_exit_0004:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0002
.L_lambda_opt_arity_check_more_0002:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0005:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0005
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
	jmp .L_lambda_opt_stack_shrink_loop_0005
.L_lambda_opt_stack_shrink_loop_exit_0005:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0006:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0006
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0006
.L_lambda_opt_stack_shrink_loop_exit_0006:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0002:
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
.L_tc_recycle_frame_loop_0020:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0020
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0020
.L_tc_recycle_frame_done_0020:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0002:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0020:	; new closure is in rax
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
.L_lambda_simple_env_loop_0022:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0022
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0022
.L_lambda_simple_env_end_0022:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0022:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0022
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0022
.L_lambda_simple_params_end_0022:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0022
	jmp .L_lambda_simple_end_0022
.L_lambda_simple_code_0022:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0022
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0022:
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
.L_lambda_simple_env_loop_0023:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0023
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0023
.L_lambda_simple_env_end_0023:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0023:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0023
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0023
.L_lambda_simple_params_end_0023:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0023
	jmp .L_lambda_simple_end_0023
.L_lambda_simple_code_0023:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0023
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0023:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0005
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
.L_tc_recycle_frame_loop_0021:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0021
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0021
.L_tc_recycle_frame_done_0021:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0005
          .L_if_else_0005:
          	mov rax, qword [rbp + 8 * (4 + 0)]
.L_if_end_0005:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0023:	; new closure is in rax
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
.L_lambda_opt_env_loop_0003:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0003
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0003
.L_lambda_opt_env_end_0003:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0003:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0003
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0003
.L_lambda_opt_params_end_0003:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0003
	jmp .L_lambda_opt_end_0003
.L_lambda_opt_code_0003:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0003
	jg .L_lambda_opt_arity_check_more_0003
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0003:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0007:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0007
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0007
.L_lambda_opt_stack_shrink_loop_exit_0007:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0003
.L_lambda_opt_arity_check_more_0003:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0008:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0008
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
	jmp .L_lambda_opt_stack_shrink_loop_0008
.L_lambda_opt_stack_shrink_loop_exit_0008:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0009:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0009
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0009
.L_lambda_opt_stack_shrink_loop_exit_0009:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0003:
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
.L_tc_recycle_frame_loop_0022:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0022
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0022
.L_tc_recycle_frame_done_0022:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0003:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0022:	; new closure is in rax
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
.L_lambda_opt_env_loop_0004:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_0004
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0004
.L_lambda_opt_env_end_0004:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0004:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_0004
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0004
.L_lambda_opt_params_end_0004:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0004
	jmp .L_lambda_opt_end_0004
.L_lambda_opt_code_0004:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0004
	jg .L_lambda_opt_arity_check_more_0004
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0004:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_000a:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_000a
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_000a
.L_lambda_opt_stack_shrink_loop_exit_000a:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0004
.L_lambda_opt_arity_check_more_0004:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_000b:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_000b
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
	jmp .L_lambda_opt_stack_shrink_loop_000b
.L_lambda_opt_stack_shrink_loop_exit_000b:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_000c:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_000c
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_000c
.L_lambda_opt_stack_shrink_loop_exit_000c:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0004:
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
.L_lambda_simple_env_loop_0024:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0024
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0024
.L_lambda_simple_env_end_0024:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0024:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0024
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0024
.L_lambda_simple_params_end_0024:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0024
	jmp .L_lambda_simple_end_0024
.L_lambda_simple_code_0024:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0024
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0024:
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
.L_lambda_simple_env_loop_0025:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0025
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0025
.L_lambda_simple_env_end_0025:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0025:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0025
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0025
.L_lambda_simple_params_end_0025:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0025
	jmp .L_lambda_simple_end_0025
.L_lambda_simple_code_0025:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0025
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0025:
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
          	je .L_if_else_0006
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
	jne .L_or_end_0002
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
.L_tc_recycle_frame_loop_0024:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0024
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0024
.L_tc_recycle_frame_done_0024:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_or_end_0002:
	jmp .L_if_end_0006
          .L_if_else_0006:
          	mov rax, L_constants + 2
.L_if_end_0006:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0025:	; new closure is in rax
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
.L_tc_recycle_frame_loop_0025:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0025
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0025
.L_tc_recycle_frame_done_0025:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0024:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0023:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0023
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0023
.L_tc_recycle_frame_done_0023:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0004:	; new closure is in rax
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
.L_lambda_opt_env_loop_0005:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_0005
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0005
.L_lambda_opt_env_end_0005:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0005:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_0005
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0005
.L_lambda_opt_params_end_0005:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0005
	jmp .L_lambda_opt_end_0005
.L_lambda_opt_code_0005:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0005
	jg .L_lambda_opt_arity_check_more_0005
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0005:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_000d:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_000d
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_000d
.L_lambda_opt_stack_shrink_loop_exit_000d:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0005
.L_lambda_opt_arity_check_more_0005:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_000e:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_000e
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
	jmp .L_lambda_opt_stack_shrink_loop_000e
.L_lambda_opt_stack_shrink_loop_exit_000e:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_000f:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_000f
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_000f
.L_lambda_opt_stack_shrink_loop_exit_000f:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0005:
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
.L_lambda_simple_env_loop_0026:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0026
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0026
.L_lambda_simple_env_end_0026:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0026:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0026
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0026
.L_lambda_simple_params_end_0026:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0026
	jmp .L_lambda_simple_end_0026
.L_lambda_simple_code_0026:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0026
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0026:
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
.L_lambda_simple_env_loop_0027:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0027
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0027
.L_lambda_simple_env_end_0027:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0027:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0027
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0027
.L_lambda_simple_params_end_0027:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0027
	jmp .L_lambda_simple_end_0027
.L_lambda_simple_code_0027:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0027
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0027:
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
	jne .L_or_end_0003
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
          	je .L_if_else_0007
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
.L_tc_recycle_frame_loop_0027:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0027
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0027
.L_tc_recycle_frame_done_0027:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0007
          .L_if_else_0007:
          	mov rax, L_constants + 2
.L_if_end_0007:
.L_or_end_0003:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0027:	; new closure is in rax
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
.L_tc_recycle_frame_loop_0028:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0028
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0028
.L_tc_recycle_frame_done_0028:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0026:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0026:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0026
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0026
.L_tc_recycle_frame_done_0026:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0005:	; new closure is in rax
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
.L_lambda_simple_env_loop_0028:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0028
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0028
.L_lambda_simple_env_end_0028:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0028:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0028
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0028
.L_lambda_simple_params_end_0028:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0028
	jmp .L_lambda_simple_end_0028
.L_lambda_simple_code_0028:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0028
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0028:
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
.L_lambda_simple_env_loop_0029:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0029
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0029
.L_lambda_simple_env_end_0029:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0029:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0029
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0029
.L_lambda_simple_params_end_0029:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0029
	jmp .L_lambda_simple_end_0029
.L_lambda_simple_code_0029:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0029
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0029:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0008
          	mov rax, L_constants + 1
	jmp .L_if_end_0008
          .L_if_else_0008:
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
.L_tc_recycle_frame_loop_0029:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0029
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0029
.L_tc_recycle_frame_done_0029:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0008:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0029:	; new closure is in rax
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
.L_lambda_simple_env_loop_002a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_002a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_002a
.L_lambda_simple_env_end_002a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_002a:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_002a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_002a
.L_lambda_simple_params_end_002a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_002a
	jmp .L_lambda_simple_end_002a
.L_lambda_simple_code_002a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_002a
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_002a:
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
          	je .L_if_else_0009
          	mov rax, L_constants + 1
	jmp .L_if_end_0009
          .L_if_else_0009:
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
.L_tc_recycle_frame_loop_002a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_002a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_002a
.L_tc_recycle_frame_done_002a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0009:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_002a:	; new closure is in rax
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
.L_lambda_opt_env_loop_0006:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0006
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0006
.L_lambda_opt_env_end_0006:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0006:	; copy params
	cmp rsi, 2
	je .L_lambda_opt_params_end_0006
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0006
.L_lambda_opt_params_end_0006:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0006
	jmp .L_lambda_opt_end_0006
.L_lambda_opt_code_0006:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0006
	jg .L_lambda_opt_arity_check_more_0006
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0006:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0010:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0010
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0010
.L_lambda_opt_stack_shrink_loop_exit_0010:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0006
.L_lambda_opt_arity_check_more_0006:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0011:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0011
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
	jmp .L_lambda_opt_stack_shrink_loop_0011
.L_lambda_opt_stack_shrink_loop_exit_0011:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0012:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0012
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0012
.L_lambda_opt_stack_shrink_loop_exit_0012:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0006:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_000a
          	mov rax, L_constants + 1
	jmp .L_if_end_000a
          .L_if_else_000a:
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
.L_tc_recycle_frame_loop_002b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_002b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_002b
.L_tc_recycle_frame_done_002b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_000a:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0006:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0028:	; new closure is in rax
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
.L_lambda_simple_env_loop_002b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_002b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_002b
.L_lambda_simple_env_end_002b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_002b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_002b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_002b
.L_lambda_simple_params_end_002b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_002b
	jmp .L_lambda_simple_end_002b
.L_lambda_simple_code_002b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_002b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_002b:
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
.L_lambda_simple_env_loop_002c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_002c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_002c
.L_lambda_simple_env_end_002c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_002c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_002c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_002c
.L_lambda_simple_params_end_002c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_002c
	jmp .L_lambda_simple_end_002c
.L_lambda_simple_code_002c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_002c
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_002c:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_000b
          	mov rax, qword [rbp + 8 * (4 + 1)]
	jmp .L_if_end_000b
          .L_if_else_000b:
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
.L_tc_recycle_frame_loop_002c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_002c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_002c
.L_tc_recycle_frame_done_002c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_000b:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_002c:	; new closure is in rax
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
.L_lambda_simple_env_loop_002d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_002d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_002d
.L_lambda_simple_env_end_002d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_002d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_002d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_002d
.L_lambda_simple_params_end_002d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_002d
	jmp .L_lambda_simple_end_002d
.L_lambda_simple_code_002d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_002d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_002d:
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
.L_tc_recycle_frame_loop_002d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_002d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_002d
.L_tc_recycle_frame_done_002d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_002d:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_002b:	; new closure is in rax
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
.L_lambda_simple_env_loop_002e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_002e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_002e
.L_lambda_simple_env_end_002e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_002e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_002e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_002e
.L_lambda_simple_params_end_002e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_002e
	jmp .L_lambda_simple_end_002e
.L_lambda_simple_code_002e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_002e
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_002e:
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
.L_lambda_simple_env_loop_002f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_002f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_002f
.L_lambda_simple_env_end_002f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_002f:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_002f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_002f
.L_lambda_simple_params_end_002f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_002f
	jmp .L_lambda_simple_end_002f
.L_lambda_simple_code_002f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_002f
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_002f:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_000c
          	mov rax, qword [rbp + 8 * (4 + 0)]
	jmp .L_if_end_000c
          .L_if_else_000c:
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
.L_tc_recycle_frame_loop_002e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_002e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_002e
.L_tc_recycle_frame_done_002e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_000c:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_002f:	; new closure is in rax
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
.L_lambda_simple_env_loop_0030:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0030
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0030
.L_lambda_simple_env_end_0030:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0030:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0030
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0030
.L_lambda_simple_params_end_0030:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0030
	jmp .L_lambda_simple_end_0030
.L_lambda_simple_code_0030:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0030
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0030:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_000d
          	mov rax, qword [rbp + 8 * (4 + 1)]
	jmp .L_if_end_000d
          .L_if_else_000d:
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
.L_tc_recycle_frame_loop_002f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_002f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_002f
.L_tc_recycle_frame_done_002f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_000d:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0030:	; new closure is in rax
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
.L_lambda_opt_env_loop_0007:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0007
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0007
.L_lambda_opt_env_end_0007:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0007:	; copy params
	cmp rsi, 2
	je .L_lambda_opt_params_end_0007
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0007
.L_lambda_opt_params_end_0007:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0007
	jmp .L_lambda_opt_end_0007
.L_lambda_opt_code_0007:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0007
	jg .L_lambda_opt_arity_check_more_0007
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0007:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0013:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0013
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0013
.L_lambda_opt_stack_shrink_loop_exit_0013:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0007
.L_lambda_opt_arity_check_more_0007:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0014:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0014
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
	jmp .L_lambda_opt_stack_shrink_loop_0014
.L_lambda_opt_stack_shrink_loop_exit_0014:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_0015:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0015
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0015
.L_lambda_opt_stack_shrink_loop_exit_0015:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0007:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_000e
          	mov rax, L_constants + 1
	jmp .L_if_end_000e
          .L_if_else_000e:
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
.L_tc_recycle_frame_loop_0030:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0030
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0030
.L_tc_recycle_frame_done_0030:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_000e:
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0007:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_002e:	; new closure is in rax
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
.L_lambda_simple_env_loop_0031:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0031
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0031
.L_lambda_simple_env_end_0031:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0031:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0031
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0031
.L_lambda_simple_params_end_0031:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0031
	jmp .L_lambda_simple_end_0031
.L_lambda_simple_code_0031:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0031
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0031:
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
.L_lambda_simple_env_loop_0032:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0032
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0032
.L_lambda_simple_env_end_0032:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0032:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0032
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0032
.L_lambda_simple_params_end_0032:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0032
	jmp .L_lambda_simple_end_0032
.L_lambda_simple_code_0032:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_0032
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0032:
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
          	je .L_if_else_000f
          	mov rax, qword [rbp + 8 * (4 + 1)]
	jmp .L_if_end_000f
          .L_if_else_000f:
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
.L_tc_recycle_frame_loop_0031:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0031
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0031
.L_tc_recycle_frame_done_0031:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_000f:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_0032:	; new closure is in rax
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
.L_lambda_opt_env_loop_0008:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0008
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0008
.L_lambda_opt_env_end_0008:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0008:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0008
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0008
.L_lambda_opt_params_end_0008:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0008
	jmp .L_lambda_opt_end_0008
.L_lambda_opt_code_0008:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_opt_arity_check_exact_0008
	jg .L_lambda_opt_arity_check_more_0008
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0008:
	mov qword [rsp + 8 * 2], 3
	mov rdx, 5
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0016:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0016
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0016
.L_lambda_opt_stack_shrink_loop_exit_0016:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0008
.L_lambda_opt_arity_check_more_0008:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 2
	mov qword [rsp + 8 * 2], 3
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 2 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0017:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0017
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
	jmp .L_lambda_opt_stack_shrink_loop_0017
.L_lambda_opt_stack_shrink_loop_exit_0017:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 32
	mov rsi, 5
.L_lambda_opt_stack_shrink_loop_0018:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0018
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0018
.L_lambda_opt_stack_shrink_loop_exit_0018:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0008:
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
.L_tc_recycle_frame_loop_0032:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0032
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0032
.L_tc_recycle_frame_done_0032:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 3)
.L_lambda_opt_end_0008:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0031:	; new closure is in rax
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
.L_lambda_simple_env_loop_0033:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0033
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0033
.L_lambda_simple_env_end_0033:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0033:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0033
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0033
.L_lambda_simple_params_end_0033:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0033
	jmp .L_lambda_simple_end_0033
.L_lambda_simple_code_0033:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0033
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0033:
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
.L_lambda_simple_env_loop_0034:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0034
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0034
.L_lambda_simple_env_end_0034:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0034:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0034
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0034
.L_lambda_simple_params_end_0034:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0034
	jmp .L_lambda_simple_end_0034
.L_lambda_simple_code_0034:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_0034
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0034:
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
          	je .L_if_else_0010
          	mov rax, qword [rbp + 8 * (4 + 1)]
	jmp .L_if_end_0010
          .L_if_else_0010:
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
.L_tc_recycle_frame_loop_0033:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0033
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0033
.L_tc_recycle_frame_done_0033:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0010:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_0034:	; new closure is in rax
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
.L_lambda_opt_env_loop_0009:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0009
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0009
.L_lambda_opt_env_end_0009:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0009:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0009
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0009
.L_lambda_opt_params_end_0009:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0009
	jmp .L_lambda_opt_end_0009
.L_lambda_opt_code_0009:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_opt_arity_check_exact_0009
	jg .L_lambda_opt_arity_check_more_0009
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0009:
	mov qword [rsp + 8 * 2], 3
	mov rdx, 5
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0019:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0019
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0019
.L_lambda_opt_stack_shrink_loop_exit_0019:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0009
.L_lambda_opt_arity_check_more_0009:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 2
	mov qword [rsp + 8 * 2], 3
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 2 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_001a:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_001a
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
	jmp .L_lambda_opt_stack_shrink_loop_001a
.L_lambda_opt_stack_shrink_loop_exit_001a:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 32
	mov rsi, 5
.L_lambda_opt_stack_shrink_loop_001b:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_001b
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_001b
.L_lambda_opt_stack_shrink_loop_exit_001b:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0009:
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
.L_tc_recycle_frame_loop_0034:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0034
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0034
.L_tc_recycle_frame_done_0034:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 3)
.L_lambda_opt_end_0009:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0033:	; new closure is in rax
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
.L_lambda_simple_env_loop_0038:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0038
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0038
.L_lambda_simple_env_end_0038:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0038:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0038
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0038
.L_lambda_simple_params_end_0038:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0038
	jmp .L_lambda_simple_end_0038
.L_lambda_simple_code_0038:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_0038
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0038:
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
.L_tc_recycle_frame_loop_003e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_003e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_003e
.L_tc_recycle_frame_done_003e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_0038:	; new closure is in rax
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
.L_lambda_simple_env_loop_0035:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0035
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0035
.L_lambda_simple_env_end_0035:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0035:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0035
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0035
.L_lambda_simple_params_end_0035:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0035
	jmp .L_lambda_simple_end_0035
.L_lambda_simple_code_0035:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0035
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0035:
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
.L_lambda_simple_env_loop_0037:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0037
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0037
.L_lambda_simple_env_end_0037:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0037:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0037
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0037
.L_lambda_simple_params_end_0037:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0037
	jmp .L_lambda_simple_end_0037
.L_lambda_simple_code_0037:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0037
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0037:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0016
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0012
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
.L_tc_recycle_frame_loop_0037:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0037
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0037
.L_tc_recycle_frame_done_0037:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0012
          .L_if_else_0012:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0011
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
.L_tc_recycle_frame_loop_0038:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0038
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0038
.L_tc_recycle_frame_done_0038:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0011
          .L_if_else_0011:
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
.L_tc_recycle_frame_loop_0039:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0039
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0039
.L_tc_recycle_frame_done_0039:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0011:
.L_if_end_0012:
	jmp .L_if_end_0016
          .L_if_else_0016:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0015
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0014
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
.L_tc_recycle_frame_loop_003a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_003a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_003a
.L_tc_recycle_frame_done_003a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0014
          .L_if_else_0014:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0013
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
.L_tc_recycle_frame_loop_003b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_003b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_003b
.L_tc_recycle_frame_done_003b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0013
          .L_if_else_0013:
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
.L_tc_recycle_frame_loop_003c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_003c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_003c
.L_tc_recycle_frame_done_003c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0013:
.L_if_end_0014:
	jmp .L_if_end_0015
          .L_if_else_0015:
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
.L_tc_recycle_frame_loop_003d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_003d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_003d
.L_tc_recycle_frame_done_003d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0015:
.L_if_end_0016:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0037:	; new closure is in rax
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
.L_lambda_simple_env_loop_0036:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0036
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0036
.L_lambda_simple_env_end_0036:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0036:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0036
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0036
.L_lambda_simple_params_end_0036:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0036
	jmp .L_lambda_simple_end_0036
.L_lambda_simple_code_0036:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0036
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0036:
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
.L_lambda_opt_env_loop_000a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_000a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_000a
.L_lambda_opt_env_end_000a:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_000a:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_000a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_000a
.L_lambda_opt_params_end_000a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_000a
	jmp .L_lambda_opt_end_000a
.L_lambda_opt_code_000a:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_000a
	jg .L_lambda_opt_arity_check_more_000a
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_000a:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_001c:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_001c
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_001c
.L_lambda_opt_stack_shrink_loop_exit_001c:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_000a
.L_lambda_opt_arity_check_more_000a:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_001d:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_001d
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
	jmp .L_lambda_opt_stack_shrink_loop_001d
.L_lambda_opt_stack_shrink_loop_exit_001d:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_001e:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_001e
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_001e
.L_lambda_opt_stack_shrink_loop_exit_001e:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_000a:
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
.L_tc_recycle_frame_loop_0036:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0036
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0036
.L_tc_recycle_frame_done_0036:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_000a:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0036:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0035:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0035
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0035
.L_tc_recycle_frame_done_0035:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0035:	; new closure is in rax
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
.L_lambda_simple_env_loop_003d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_003d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_003d
.L_lambda_simple_env_end_003d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_003d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_003d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_003d
.L_lambda_simple_params_end_003d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_003d
	jmp .L_lambda_simple_end_003d
.L_lambda_simple_code_003d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_003d
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_003d:
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
.L_tc_recycle_frame_loop_004a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_004a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_004a
.L_tc_recycle_frame_done_004a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_003d:	; new closure is in rax
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
.L_lambda_simple_env_loop_0039:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0039
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0039
.L_lambda_simple_env_end_0039:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0039:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0039
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0039
.L_lambda_simple_params_end_0039:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0039
	jmp .L_lambda_simple_end_0039
.L_lambda_simple_code_0039:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0039
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0039:
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
.L_lambda_simple_env_loop_003c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_003c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_003c
.L_lambda_simple_env_end_003c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_003c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_003c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_003c
.L_lambda_simple_params_end_003c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_003c
	jmp .L_lambda_simple_end_003c
.L_lambda_simple_code_003c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_003c
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_003c:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_001d
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0019
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
.L_tc_recycle_frame_loop_0043:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0043
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0043
.L_tc_recycle_frame_done_0043:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0019
          .L_if_else_0019:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0018
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
.L_tc_recycle_frame_loop_0044:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0044
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0044
.L_tc_recycle_frame_done_0044:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0018
          .L_if_else_0018:
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
.L_tc_recycle_frame_loop_0045:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0045
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0045
.L_tc_recycle_frame_done_0045:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0018:
.L_if_end_0019:
	jmp .L_if_end_001d
          .L_if_else_001d:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_001c
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_001b
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
.L_tc_recycle_frame_loop_0046:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0046
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0046
.L_tc_recycle_frame_done_0046:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_001b
          .L_if_else_001b:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_001a
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
.L_tc_recycle_frame_loop_0047:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0047
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0047
.L_tc_recycle_frame_done_0047:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_001a
          .L_if_else_001a:
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
.L_tc_recycle_frame_loop_0048:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0048
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0048
.L_tc_recycle_frame_done_0048:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_001a:
.L_if_end_001b:
	jmp .L_if_end_001c
          .L_if_else_001c:
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
.L_tc_recycle_frame_loop_0049:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0049
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0049
.L_tc_recycle_frame_done_0049:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_001c:
.L_if_end_001d:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_003c:	; new closure is in rax
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
.L_lambda_simple_env_loop_003a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_003a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_003a
.L_lambda_simple_env_end_003a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_003a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_003a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_003a
.L_lambda_simple_params_end_003a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_003a
	jmp .L_lambda_simple_end_003a
.L_lambda_simple_code_003a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_003a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_003a:
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
.L_lambda_opt_env_loop_000b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_000b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_000b
.L_lambda_opt_env_end_000b:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_000b:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_000b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_000b
.L_lambda_opt_params_end_000b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_000b
	jmp .L_lambda_opt_end_000b
.L_lambda_opt_code_000b:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_000b
	jg .L_lambda_opt_arity_check_more_000b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_000b:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_001f:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_001f
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_001f
.L_lambda_opt_stack_shrink_loop_exit_001f:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_000b
.L_lambda_opt_arity_check_more_000b:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0020:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0020
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
	jmp .L_lambda_opt_stack_shrink_loop_0020
.L_lambda_opt_stack_shrink_loop_exit_0020:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0021:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0021
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0021
.L_lambda_opt_stack_shrink_loop_exit_0021:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_000b:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0017
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
.L_tc_recycle_frame_loop_0040:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0040
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0040
.L_tc_recycle_frame_done_0040:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0017
          .L_if_else_0017:
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
.L_lambda_simple_env_loop_003b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_003b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_003b
.L_lambda_simple_env_end_003b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_003b:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_003b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_003b
.L_lambda_simple_params_end_003b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_003b
	jmp .L_lambda_simple_end_003b
.L_lambda_simple_code_003b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_003b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_003b:
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
.L_tc_recycle_frame_loop_0042:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0042
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0042
.L_tc_recycle_frame_done_0042:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_003b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0041:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0041
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0041
.L_tc_recycle_frame_done_0041:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0017:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_000b:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_003a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_003f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_003f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_003f
.L_tc_recycle_frame_done_003f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0039:	; new closure is in rax
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
.L_lambda_simple_env_loop_0041:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0041
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0041
.L_lambda_simple_env_end_0041:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0041:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0041
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0041
.L_lambda_simple_params_end_0041:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0041
	jmp .L_lambda_simple_end_0041
.L_lambda_simple_code_0041:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_0041
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0041:
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
.L_tc_recycle_frame_loop_0054:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0054
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0054
.L_tc_recycle_frame_done_0054:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_0041:	; new closure is in rax
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
.L_lambda_simple_env_loop_003e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_003e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_003e
.L_lambda_simple_env_end_003e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_003e:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_003e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_003e
.L_lambda_simple_params_end_003e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_003e
	jmp .L_lambda_simple_end_003e
.L_lambda_simple_code_003e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_003e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_003e:
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
.L_lambda_simple_env_loop_0040:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0040
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0040
.L_lambda_simple_env_end_0040:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0040:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0040
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0040
.L_lambda_simple_params_end_0040:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0040
	jmp .L_lambda_simple_end_0040
.L_lambda_simple_code_0040:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0040
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0040:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0023
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_001f
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
.L_tc_recycle_frame_loop_004d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_004d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_004d
.L_tc_recycle_frame_done_004d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_001f
          .L_if_else_001f:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_001e
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
.L_tc_recycle_frame_loop_004e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_004e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_004e
.L_tc_recycle_frame_done_004e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_001e
          .L_if_else_001e:
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
.L_tc_recycle_frame_loop_004f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_004f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_004f
.L_tc_recycle_frame_done_004f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_001e:
.L_if_end_001f:
	jmp .L_if_end_0023
          .L_if_else_0023:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0022
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0021
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
.L_tc_recycle_frame_loop_0050:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0050
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0050
.L_tc_recycle_frame_done_0050:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0021
          .L_if_else_0021:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0020
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
.L_tc_recycle_frame_loop_0051:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0051
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0051
.L_tc_recycle_frame_done_0051:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0020
          .L_if_else_0020:
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
.L_tc_recycle_frame_loop_0052:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0052
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0052
.L_tc_recycle_frame_done_0052:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0020:
.L_if_end_0021:
	jmp .L_if_end_0022
          .L_if_else_0022:
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
.L_tc_recycle_frame_loop_0053:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0053
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0053
.L_tc_recycle_frame_done_0053:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0022:
.L_if_end_0023:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0040:	; new closure is in rax
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
.L_lambda_simple_env_loop_003f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_003f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_003f
.L_lambda_simple_env_end_003f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_003f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_003f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_003f
.L_lambda_simple_params_end_003f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_003f
	jmp .L_lambda_simple_end_003f
.L_lambda_simple_code_003f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_003f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_003f:
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
.L_lambda_opt_env_loop_000c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_000c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_000c
.L_lambda_opt_env_end_000c:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_000c:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_000c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_000c
.L_lambda_opt_params_end_000c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_000c
	jmp .L_lambda_opt_end_000c
.L_lambda_opt_code_000c:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_000c
	jg .L_lambda_opt_arity_check_more_000c
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_000c:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0022:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0022
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0022
.L_lambda_opt_stack_shrink_loop_exit_0022:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_000c
.L_lambda_opt_arity_check_more_000c:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0023:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0023
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
	jmp .L_lambda_opt_stack_shrink_loop_0023
.L_lambda_opt_stack_shrink_loop_exit_0023:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_0024:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0024
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0024
.L_lambda_opt_stack_shrink_loop_exit_0024:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_000c:
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
.L_tc_recycle_frame_loop_004c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_004c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_004c
.L_tc_recycle_frame_done_004c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_000c:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_003f:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_004b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_004b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_004b
.L_tc_recycle_frame_done_004b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_003e:	; new closure is in rax
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
.L_lambda_simple_env_loop_0046:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0046
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0046
.L_lambda_simple_env_end_0046:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0046:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0046
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0046
.L_lambda_simple_params_end_0046:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0046
	jmp .L_lambda_simple_end_0046
.L_lambda_simple_code_0046:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_0046
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0046:
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
.L_tc_recycle_frame_loop_0060:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0060
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0060
.L_tc_recycle_frame_done_0060:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_0046:	; new closure is in rax
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
.L_lambda_simple_env_loop_0042:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0042
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0042
.L_lambda_simple_env_end_0042:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0042:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0042
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0042
.L_lambda_simple_params_end_0042:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0042
	jmp .L_lambda_simple_end_0042
.L_lambda_simple_code_0042:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0042
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0042:
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
.L_lambda_simple_env_loop_0045:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0045
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0045
.L_lambda_simple_env_end_0045:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0045:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0045
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0045
.L_lambda_simple_params_end_0045:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0045
	jmp .L_lambda_simple_end_0045
.L_lambda_simple_code_0045:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0045
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0045:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_002a
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0026
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
.L_tc_recycle_frame_loop_0059:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0059
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0059
.L_tc_recycle_frame_done_0059:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0026
          .L_if_else_0026:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0025
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
.L_tc_recycle_frame_loop_005a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_005a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_005a
.L_tc_recycle_frame_done_005a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0025
          .L_if_else_0025:
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
.L_tc_recycle_frame_loop_005b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_005b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_005b
.L_tc_recycle_frame_done_005b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0025:
.L_if_end_0026:
	jmp .L_if_end_002a
          .L_if_else_002a:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0029
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0028
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
.L_tc_recycle_frame_loop_005c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_005c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_005c
.L_tc_recycle_frame_done_005c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0028
          .L_if_else_0028:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0027
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
.L_tc_recycle_frame_loop_005d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_005d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_005d
.L_tc_recycle_frame_done_005d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0027
          .L_if_else_0027:
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
.L_tc_recycle_frame_loop_005e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_005e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_005e
.L_tc_recycle_frame_done_005e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0027:
.L_if_end_0028:
	jmp .L_if_end_0029
          .L_if_else_0029:
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
.L_tc_recycle_frame_loop_005f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_005f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_005f
.L_tc_recycle_frame_done_005f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0029:
.L_if_end_002a:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0045:	; new closure is in rax
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
.L_lambda_simple_env_loop_0043:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0043
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0043
.L_lambda_simple_env_end_0043:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0043:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0043
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0043
.L_lambda_simple_params_end_0043:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0043
	jmp .L_lambda_simple_end_0043
.L_lambda_simple_code_0043:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0043
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0043:
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
.L_lambda_opt_env_loop_000d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_opt_env_end_000d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_000d
.L_lambda_opt_env_end_000d:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_000d:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_000d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_000d
.L_lambda_opt_params_end_000d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_000d
	jmp .L_lambda_opt_end_000d
.L_lambda_opt_code_000d:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_000d
	jg .L_lambda_opt_arity_check_more_000d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_000d:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0025:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0025
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0025
.L_lambda_opt_stack_shrink_loop_exit_0025:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_000d
.L_lambda_opt_arity_check_more_000d:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0026:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0026
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
	jmp .L_lambda_opt_stack_shrink_loop_0026
.L_lambda_opt_stack_shrink_loop_exit_0026:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0027:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0027
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0027
.L_lambda_opt_stack_shrink_loop_exit_0027:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_000d:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0024
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
.L_tc_recycle_frame_loop_0056:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0056
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0056
.L_tc_recycle_frame_done_0056:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0024
          .L_if_else_0024:
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
.L_lambda_simple_env_loop_0044:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_0044
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0044
.L_lambda_simple_env_end_0044:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0044:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0044
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0044
.L_lambda_simple_params_end_0044:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0044
	jmp .L_lambda_simple_end_0044
.L_lambda_simple_code_0044:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0044
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0044:
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
.L_tc_recycle_frame_loop_0058:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0058
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0058
.L_tc_recycle_frame_done_0058:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0044:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0057:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0057
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0057
.L_tc_recycle_frame_done_0057:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0024:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_000d:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0043:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0055:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0055
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0055
.L_tc_recycle_frame_done_0055:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0042:	; new closure is in rax
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
.L_lambda_simple_env_loop_0047:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0047
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0047
.L_lambda_simple_env_end_0047:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0047:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0047
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0047
.L_lambda_simple_params_end_0047:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0047
	jmp .L_lambda_simple_end_0047
.L_lambda_simple_code_0047:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0047
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0047:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_27]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_002b
          	mov rax, L_constants + 128
	jmp .L_if_end_002b
          .L_if_else_002b:
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
.L_tc_recycle_frame_loop_0061:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0061
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0061
.L_tc_recycle_frame_done_0061:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_002b:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0047:	; new closure is in rax
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
.L_lambda_simple_env_loop_0058:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0058
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0058
.L_lambda_simple_env_end_0058:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0058:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0058
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0058
.L_lambda_simple_params_end_0058:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0058
	jmp .L_lambda_simple_end_0058
.L_lambda_simple_code_0058:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_simple_arity_check_ok_0058
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0058:
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
.L_tc_recycle_frame_loop_0075:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0075
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0075
.L_tc_recycle_frame_done_0075:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 0)
.L_lambda_simple_end_0058:	; new closure is in rax
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
.L_lambda_simple_env_loop_0048:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0048
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0048
.L_lambda_simple_env_end_0048:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0048:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0048
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0048
.L_lambda_simple_params_end_0048:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0048
	jmp .L_lambda_simple_end_0048
.L_lambda_simple_code_0048:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0048
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0048:
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
.L_lambda_simple_env_loop_0056:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0056
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0056
.L_lambda_simple_env_end_0056:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0056:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0056
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0056
.L_lambda_simple_params_end_0056:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0056
	jmp .L_lambda_simple_end_0056
.L_lambda_simple_code_0056:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0056
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0056:
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
.L_lambda_simple_env_loop_0057:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0057
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0057
.L_lambda_simple_env_end_0057:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0057:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0057
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0057
.L_lambda_simple_params_end_0057:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0057
	jmp .L_lambda_simple_end_0057
.L_lambda_simple_code_0057:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0057
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0057:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0032
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_002e
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
.L_tc_recycle_frame_loop_006f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_006f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_006f
.L_tc_recycle_frame_done_006f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_002e
          .L_if_else_002e:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_002d
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
.L_tc_recycle_frame_loop_0070:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0070
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0070
.L_tc_recycle_frame_done_0070:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_002d
          .L_if_else_002d:
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
.L_tc_recycle_frame_loop_0071:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0071
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0071
.L_tc_recycle_frame_done_0071:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_002d:
.L_if_end_002e:
	jmp .L_if_end_0032
          .L_if_else_0032:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0031
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_9]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0030
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
.L_tc_recycle_frame_loop_0072:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0072
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0072
.L_tc_recycle_frame_done_0072:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0030
          .L_if_else_0030:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_8]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_002f
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
.L_tc_recycle_frame_loop_0073:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0073
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0073
.L_tc_recycle_frame_done_0073:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_002f
          .L_if_else_002f:
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
.L_tc_recycle_frame_loop_0074:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0074
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0074
.L_tc_recycle_frame_done_0074:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_002f:
.L_if_end_0030:
	jmp .L_if_end_0031
          .L_if_else_0031:
          	mov rax, L_constants + 0
.L_if_end_0031:
.L_if_end_0032:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0057:	; new closure is in rax
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0056:	; new closure is in rax
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
.L_lambda_simple_env_loop_0049:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0049
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0049
.L_lambda_simple_env_end_0049:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0049:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0049
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0049
.L_lambda_simple_params_end_0049:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0049
	jmp .L_lambda_simple_end_0049
.L_lambda_simple_code_0049:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0049
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0049:
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
.L_lambda_simple_env_loop_004a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_004a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_004a
.L_lambda_simple_env_end_004a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_004a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_004a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_004a
.L_lambda_simple_params_end_004a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_004a
	jmp .L_lambda_simple_end_004a
.L_lambda_simple_code_004a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_004a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_004a:
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
.L_lambda_simple_env_loop_004b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_004b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_004b
.L_lambda_simple_env_end_004b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_004b:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_004b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_004b
.L_lambda_simple_params_end_004b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_004b
	jmp .L_lambda_simple_end_004b
.L_lambda_simple_code_004b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_004b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_004b:
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
.L_lambda_simple_env_loop_0055:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_0055
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0055
.L_lambda_simple_env_end_0055:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0055:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0055
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0055
.L_lambda_simple_params_end_0055:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0055
	jmp .L_lambda_simple_end_0055
.L_lambda_simple_code_0055:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0055
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0055:
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
.L_tc_recycle_frame_loop_006e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_006e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_006e
.L_tc_recycle_frame_done_006e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0055:	; new closure is in rax
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
.L_lambda_simple_env_loop_004c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_004c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_004c
.L_lambda_simple_env_end_004c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_004c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_004c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_004c
.L_lambda_simple_params_end_004c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_004c
	jmp .L_lambda_simple_end_004c
.L_lambda_simple_code_004c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_004c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_004c:
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
.L_lambda_simple_env_loop_0054:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 5
	je .L_lambda_simple_env_end_0054
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0054
.L_lambda_simple_env_end_0054:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0054:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0054
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0054
.L_lambda_simple_params_end_0054:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0054
	jmp .L_lambda_simple_end_0054
.L_lambda_simple_code_0054:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0054
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0054:
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
.L_tc_recycle_frame_loop_006d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_006d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_006d
.L_tc_recycle_frame_done_006d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0054:	; new closure is in rax
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
.L_lambda_simple_env_loop_004d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 5
	je .L_lambda_simple_env_end_004d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_004d
.L_lambda_simple_env_end_004d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_004d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_004d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_004d
.L_lambda_simple_params_end_004d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_004d
	jmp .L_lambda_simple_end_004d
.L_lambda_simple_code_004d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_004d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_004d:
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
.L_lambda_simple_env_loop_0053:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 6
	je .L_lambda_simple_env_end_0053
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0053
.L_lambda_simple_env_end_0053:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0053:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0053
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0053
.L_lambda_simple_params_end_0053:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0053
	jmp .L_lambda_simple_end_0053
.L_lambda_simple_code_0053:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0053
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0053:
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
.L_tc_recycle_frame_loop_006c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_006c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_006c
.L_tc_recycle_frame_done_006c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0053:	; new closure is in rax
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
.L_lambda_simple_env_loop_004e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 6
	je .L_lambda_simple_env_end_004e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_004e
.L_lambda_simple_env_end_004e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_004e:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_004e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_004e
.L_lambda_simple_params_end_004e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_004e
	jmp .L_lambda_simple_end_004e
.L_lambda_simple_code_004e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_004e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_004e:
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
.L_lambda_simple_env_loop_0050:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 7
	je .L_lambda_simple_env_end_0050
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0050
.L_lambda_simple_env_end_0050:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0050:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0050
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0050
.L_lambda_simple_params_end_0050:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0050
	jmp .L_lambda_simple_end_0050
.L_lambda_simple_code_0050:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0050
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0050:
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
.L_lambda_simple_env_loop_0051:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 8
	je .L_lambda_simple_env_end_0051
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0051
.L_lambda_simple_env_end_0051:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0051:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0051
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0051
.L_lambda_simple_params_end_0051:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0051
	jmp .L_lambda_simple_end_0051
.L_lambda_simple_code_0051:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0051
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0051:
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
.L_lambda_simple_env_loop_0052:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 9
	je .L_lambda_simple_env_end_0052
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0052
.L_lambda_simple_env_end_0052:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0052:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0052
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0052
.L_lambda_simple_params_end_0052:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0052
	jmp .L_lambda_simple_end_0052
.L_lambda_simple_code_0052:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0052
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0052:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0004
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
          	je .L_if_else_002c
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
.L_tc_recycle_frame_loop_006a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_006a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_006a
.L_tc_recycle_frame_done_006a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_002c
          .L_if_else_002c:
          	mov rax, L_constants + 2
.L_if_end_002c:
.L_or_end_0004:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0052:	; new closure is in rax
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
.L_lambda_opt_env_loop_000e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 9
	je .L_lambda_opt_env_end_000e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_000e
.L_lambda_opt_env_end_000e:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_000e:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_000e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_000e
.L_lambda_opt_params_end_000e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_000e
	jmp .L_lambda_opt_end_000e
.L_lambda_opt_code_000e:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_000e
	jg .L_lambda_opt_arity_check_more_000e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_000e:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0028:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0028
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0028
.L_lambda_opt_stack_shrink_loop_exit_0028:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_000e
.L_lambda_opt_arity_check_more_000e:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0029:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0029
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
	jmp .L_lambda_opt_stack_shrink_loop_0029
.L_lambda_opt_stack_shrink_loop_exit_0029:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_002a:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_002a
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_002a
.L_lambda_opt_stack_shrink_loop_exit_002a:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_000e:
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
.L_tc_recycle_frame_loop_006b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_006b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_006b
.L_tc_recycle_frame_done_006b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_000e:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0051:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0069:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0069
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0069
.L_tc_recycle_frame_done_0069:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0050:	; new closure is in rax
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
.L_lambda_simple_env_loop_004f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 7
	je .L_lambda_simple_env_end_004f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_004f
.L_lambda_simple_env_end_004f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_004f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_004f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_004f
.L_lambda_simple_params_end_004f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_004f
	jmp .L_lambda_simple_end_004f
.L_lambda_simple_code_004f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_004f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_004f:
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
.L_lambda_simple_end_004f:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0068:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0068
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0068
.L_tc_recycle_frame_done_0068:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_004e:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0067:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0067
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0067
.L_tc_recycle_frame_done_0067:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_004d:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0066:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0066
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0066
.L_tc_recycle_frame_done_0066:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_004c:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0065:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0065
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0065
.L_tc_recycle_frame_done_0065:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_004b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0064:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0064
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0064
.L_tc_recycle_frame_done_0064:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_004a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0063:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0063
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0063
.L_tc_recycle_frame_done_0063:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0049:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0062:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0062
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0062
.L_tc_recycle_frame_done_0062:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0048:	; new closure is in rax
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
.L_lambda_simple_env_loop_0059:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0059
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0059
.L_lambda_simple_env_end_0059:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0059:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0059
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0059
.L_lambda_simple_params_end_0059:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0059
	jmp .L_lambda_simple_end_0059
.L_lambda_simple_code_0059:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0059
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0059:
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
.L_lambda_simple_env_loop_005a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_005a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_005a
.L_lambda_simple_env_end_005a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_005a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_005a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_005a
.L_lambda_simple_params_end_005a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_005a
	jmp .L_lambda_simple_end_005a
.L_lambda_simple_code_005a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_005a
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_005a:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_27]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0033
          	mov rax, L_constants + 1
	jmp .L_if_end_0033
          .L_if_else_0033:
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
.L_tc_recycle_frame_loop_0076:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0076
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0076
.L_tc_recycle_frame_done_0076:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0033:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_005a:	; new closure is in rax
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
.L_lambda_opt_env_loop_000f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_000f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_000f
.L_lambda_opt_env_end_000f:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_000f:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_000f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_000f
.L_lambda_opt_params_end_000f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_000f
	jmp .L_lambda_opt_end_000f
.L_lambda_opt_code_000f:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_000f
	jg .L_lambda_opt_arity_check_more_000f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_000f:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_002b:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_002b
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_002b
.L_lambda_opt_stack_shrink_loop_exit_002b:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_000f
.L_lambda_opt_arity_check_more_000f:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_002c:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_002c
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
	jmp .L_lambda_opt_stack_shrink_loop_002c
.L_lambda_opt_stack_shrink_loop_exit_002c:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_002d:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_002d
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_002d
.L_lambda_opt_stack_shrink_loop_exit_002d:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_000f:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0037
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
.L_tc_recycle_frame_loop_0077:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0077
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0077
.L_tc_recycle_frame_done_0077:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0037
          .L_if_else_0037:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0035
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
          	je .L_if_else_0034
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
	jmp .L_if_end_0034
          .L_if_else_0034:
          	mov rax, L_constants + 2
.L_if_end_0034:
	jmp .L_if_end_0035
          .L_if_else_0035:
          	mov rax, L_constants + 2
.L_if_end_0035:
	cmp rax, sob_boolean_false
          	je .L_if_else_0036
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
.L_tc_recycle_frame_loop_0078:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0078
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0078
.L_tc_recycle_frame_done_0078:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0036
          .L_if_else_0036:
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
.L_tc_recycle_frame_loop_0079:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0079
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0079
.L_tc_recycle_frame_done_0079:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0036:
.L_if_end_0037:
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_000f:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0059:	; new closure is in rax
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
.L_lambda_simple_env_loop_005c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_005c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_005c
.L_lambda_simple_env_end_005c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_005c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_005c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_005c
.L_lambda_simple_params_end_005c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_005c
	jmp .L_lambda_simple_end_005c
.L_lambda_simple_code_005c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_005c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_005c:
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
.L_lambda_opt_env_loop_0010:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0010
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0010
.L_lambda_opt_env_end_0010:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0010:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0010
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0010
.L_lambda_opt_params_end_0010:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0010
	jmp .L_lambda_opt_end_0010
.L_lambda_opt_code_0010:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0010
	jg .L_lambda_opt_arity_check_more_0010
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0010:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_002e:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_002e
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_002e
.L_lambda_opt_stack_shrink_loop_exit_002e:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0010
.L_lambda_opt_arity_check_more_0010:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_002f:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_002f
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
	jmp .L_lambda_opt_stack_shrink_loop_002f
.L_lambda_opt_stack_shrink_loop_exit_002f:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_0030:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0030
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0030
.L_lambda_opt_stack_shrink_loop_exit_0030:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0010:
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
.L_tc_recycle_frame_loop_007a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_007a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_007a
.L_tc_recycle_frame_done_007a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0010:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_005c:	; new closure is in rax
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
.L_lambda_simple_env_loop_005b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_005b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_005b
.L_lambda_simple_env_end_005b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_005b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_005b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_005b
.L_lambda_simple_params_end_005b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_005b
	jmp .L_lambda_simple_end_005b
.L_lambda_simple_code_005b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_005b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_005b:
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
.L_lambda_simple_end_005b:	; new closure is in rax
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
.L_lambda_simple_env_loop_005d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_005d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_005d
.L_lambda_simple_env_end_005d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_005d:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_005d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_005d
.L_lambda_simple_params_end_005d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_005d
	jmp .L_lambda_simple_end_005d
.L_lambda_simple_code_005d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_005d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_005d:
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
.L_lambda_simple_env_loop_005e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_005e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_005e
.L_lambda_simple_env_end_005e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_005e:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_005e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_005e
.L_lambda_simple_params_end_005e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_005e
	jmp .L_lambda_simple_end_005e
.L_lambda_simple_code_005e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_005e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_005e:
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
          	je .L_if_else_0038
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
.L_tc_recycle_frame_loop_007b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_007b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_007b
.L_tc_recycle_frame_done_007b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0038
          .L_if_else_0038:
          	mov rax, qword [rbp + 8 * (4 + 0)]
.L_if_end_0038:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_005e:	; new closure is in rax
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
.L_lambda_simple_env_loop_005f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_005f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_005f
.L_lambda_simple_env_end_005f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_005f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_005f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_005f
.L_lambda_simple_params_end_005f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_005f
	jmp .L_lambda_simple_end_005f
.L_lambda_simple_code_005f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_005f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_005f:
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
          	je .L_if_else_0039
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
.L_tc_recycle_frame_loop_007c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_007c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_007c
.L_tc_recycle_frame_done_007c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0039
          .L_if_else_0039:
          	mov rax, qword [rbp + 8 * (4 + 0)]
.L_if_end_0039:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_005f:	; new closure is in rax
	mov qword [free_var_114], rax
	mov rax, sob_void
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_005d:	; new closure is in rax
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
.L_lambda_simple_env_loop_0061:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0061
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0061
.L_lambda_simple_env_end_0061:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0061:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0061
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0061
.L_lambda_simple_params_end_0061:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0061
	jmp .L_lambda_simple_end_0061
.L_lambda_simple_code_0061:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0061
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0061:
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
.L_lambda_opt_env_loop_0011:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0011
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0011
.L_lambda_opt_env_end_0011:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0011:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0011
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0011
.L_lambda_opt_params_end_0011:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0011
	jmp .L_lambda_opt_end_0011
.L_lambda_opt_code_0011:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0011
	jg .L_lambda_opt_arity_check_more_0011
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0011:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0031:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0031
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0031
.L_lambda_opt_stack_shrink_loop_exit_0031:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0011
.L_lambda_opt_arity_check_more_0011:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0032:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0032
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
	jmp .L_lambda_opt_stack_shrink_loop_0032
.L_lambda_opt_stack_shrink_loop_exit_0032:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_0033:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0033
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0033
.L_lambda_opt_stack_shrink_loop_exit_0033:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0011:
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
.L_lambda_simple_env_loop_0062:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0062
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0062
.L_lambda_simple_env_end_0062:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0062:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0062
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0062
.L_lambda_simple_params_end_0062:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0062
	jmp .L_lambda_simple_end_0062
.L_lambda_simple_code_0062:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0062
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0062:
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
.L_tc_recycle_frame_loop_007e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_007e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_007e
.L_tc_recycle_frame_done_007e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0062:	; new closure is in rax
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
.L_tc_recycle_frame_loop_007d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_007d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_007d
.L_tc_recycle_frame_done_007d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0011:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0061:	; new closure is in rax
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
.L_lambda_simple_env_loop_0060:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0060
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0060
.L_lambda_simple_env_end_0060:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0060:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0060
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0060
.L_lambda_simple_params_end_0060:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0060
	jmp .L_lambda_simple_end_0060
.L_lambda_simple_code_0060:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0060
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0060:
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
.L_lambda_simple_end_0060:	; new closure is in rax
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
.L_lambda_simple_env_loop_0064:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0064
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0064
.L_lambda_simple_env_end_0064:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0064:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0064
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0064
.L_lambda_simple_params_end_0064:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0064
	jmp .L_lambda_simple_end_0064
.L_lambda_simple_code_0064:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0064
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0064:
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
.L_lambda_simple_env_loop_0065:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0065
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0065
.L_lambda_simple_env_end_0065:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0065:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0065
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0065
.L_lambda_simple_params_end_0065:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0065
	jmp .L_lambda_simple_end_0065
.L_lambda_simple_code_0065:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0065
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0065:
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
.L_tc_recycle_frame_loop_007f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_007f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_007f
.L_tc_recycle_frame_done_007f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0065:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0064:	; new closure is in rax
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
.L_lambda_simple_env_loop_0063:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0063
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0063
.L_lambda_simple_env_end_0063:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0063:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0063
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0063
.L_lambda_simple_params_end_0063:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0063
	jmp .L_lambda_simple_end_0063
.L_lambda_simple_code_0063:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0063
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0063:
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
.L_lambda_simple_end_0063:	; new closure is in rax
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
.L_lambda_simple_env_loop_0067:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0067
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0067
.L_lambda_simple_env_end_0067:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0067:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0067
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0067
.L_lambda_simple_params_end_0067:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0067
	jmp .L_lambda_simple_end_0067
.L_lambda_simple_code_0067:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0067
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0067:
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
.L_lambda_simple_env_loop_0068:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0068
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0068
.L_lambda_simple_env_end_0068:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0068:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0068
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0068
.L_lambda_simple_params_end_0068:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0068
	jmp .L_lambda_simple_end_0068
.L_lambda_simple_code_0068:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0068
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0068:
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
.L_lambda_simple_env_loop_0069:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0069
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0069
.L_lambda_simple_env_end_0069:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0069:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0069
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0069
.L_lambda_simple_params_end_0069:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0069
	jmp .L_lambda_simple_end_0069
.L_lambda_simple_code_0069:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 5
	je .L_lambda_simple_arity_check_ok_0069
	push qword [rsp + 8 * 2]
	push 5
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0069:
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
          	je .L_if_else_003a
          	mov rax, qword [rbp + 8 * (4 + 4)]
	push rax
	mov rax, qword [rbp + 8 * (4 + 2)]
	push rax
	push 2
	mov rax, qword [free_var_102]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_003a
          .L_if_else_003a:
          	mov rax, L_constants + 2
.L_if_end_003a:
	cmp rax, sob_boolean_false
	jne .L_or_end_0005
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
          	je .L_if_else_003c
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
	jne .L_or_end_0006
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
          	je .L_if_else_003b
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
.L_tc_recycle_frame_loop_0081:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0081
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0081
.L_tc_recycle_frame_done_0081:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_003b
          .L_if_else_003b:
          	mov rax, L_constants + 2
.L_if_end_003b:
.L_or_end_0006:
	jmp .L_if_end_003c
          .L_if_else_003c:
          	mov rax, L_constants + 2
.L_if_end_003c:
.L_or_end_0005:
	leave
	ret 8 * (2 + 5)
.L_lambda_simple_end_0069:	; new closure is in rax
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
.L_lambda_simple_env_loop_006d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_006d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_006d
.L_lambda_simple_env_end_006d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_006d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_006d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_006d
.L_lambda_simple_params_end_006d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_006d
	jmp .L_lambda_simple_end_006d
.L_lambda_simple_code_006d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_006d
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_006d:
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
.L_lambda_simple_env_loop_006e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_006e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_006e
.L_lambda_simple_env_end_006e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_006e:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_006e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_006e
.L_lambda_simple_params_end_006e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_006e
	jmp .L_lambda_simple_end_006e
.L_lambda_simple_code_006e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_006e
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_006e:
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
          	je .L_if_else_003e
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
.L_tc_recycle_frame_loop_0087:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0087
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0087
.L_tc_recycle_frame_done_0087:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_003e
          .L_if_else_003e:
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
.L_tc_recycle_frame_loop_0088:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0088
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0088
.L_tc_recycle_frame_done_0088:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_003e:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_006e:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0086:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0086
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0086
.L_tc_recycle_frame_done_0086:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_006d:	; new closure is in rax
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
.L_lambda_simple_env_loop_006a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_006a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_006a
.L_lambda_simple_env_end_006a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_006a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_006a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_006a
.L_lambda_simple_params_end_006a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_006a
	jmp .L_lambda_simple_end_006a
.L_lambda_simple_code_006a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_006a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_006a:
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
.L_lambda_simple_env_loop_006b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_006b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_006b
.L_lambda_simple_env_end_006b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_006b:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_006b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_006b
.L_lambda_simple_params_end_006b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_006b
	jmp .L_lambda_simple_end_006b
.L_lambda_simple_code_006b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_006b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_006b:
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
.L_lambda_simple_env_loop_006c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_006c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_006c
.L_lambda_simple_env_end_006c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_006c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_006c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_006c
.L_lambda_simple_params_end_006c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_006c
	jmp .L_lambda_simple_end_006c
.L_lambda_simple_code_006c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_006c
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_006c:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0007
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
          	je .L_if_else_003d
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
.L_tc_recycle_frame_loop_0084:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0084
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0084
.L_tc_recycle_frame_done_0084:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_003d
          .L_if_else_003d:
          	mov rax, L_constants + 2
.L_if_end_003d:
.L_or_end_0007:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_006c:	; new closure is in rax
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
.L_lambda_opt_env_loop_0012:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_0012
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0012
.L_lambda_opt_env_end_0012:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0012:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0012
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0012
.L_lambda_opt_params_end_0012:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0012
	jmp .L_lambda_opt_end_0012
.L_lambda_opt_code_0012:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0012
	jg .L_lambda_opt_arity_check_more_0012
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0012:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0034:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0034
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0034
.L_lambda_opt_stack_shrink_loop_exit_0034:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0012
.L_lambda_opt_arity_check_more_0012:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0035:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0035
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
	jmp .L_lambda_opt_stack_shrink_loop_0035
.L_lambda_opt_stack_shrink_loop_exit_0035:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0036:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0036
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0036
.L_lambda_opt_stack_shrink_loop_exit_0036:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0012:
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
.L_tc_recycle_frame_loop_0085:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0085
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0085
.L_tc_recycle_frame_done_0085:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0012:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_006b:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0083:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0083
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0083
.L_tc_recycle_frame_done_0083:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_006a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0082:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0082
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0082
.L_tc_recycle_frame_done_0082:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0068:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0080:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0080
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0080
.L_tc_recycle_frame_done_0080:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0067:	; new closure is in rax
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
.L_lambda_simple_env_loop_0066:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0066
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0066
.L_lambda_simple_env_end_0066:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0066:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0066
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0066
.L_lambda_simple_params_end_0066:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0066
	jmp .L_lambda_simple_end_0066
.L_lambda_simple_code_0066:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0066
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0066:
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
.L_lambda_simple_end_0066:	; new closure is in rax
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
.L_lambda_simple_env_loop_0070:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0070
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0070
.L_lambda_simple_env_end_0070:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0070:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0070
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0070
.L_lambda_simple_params_end_0070:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0070
	jmp .L_lambda_simple_end_0070
.L_lambda_simple_code_0070:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0070
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0070:
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
.L_lambda_simple_env_loop_0071:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0071
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0071
.L_lambda_simple_env_end_0071:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0071:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0071
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0071
.L_lambda_simple_params_end_0071:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0071
	jmp .L_lambda_simple_end_0071
.L_lambda_simple_code_0071:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0071
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0071:
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
.L_lambda_simple_env_loop_0072:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0072
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0072
.L_lambda_simple_env_end_0072:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0072:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0072
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0072
.L_lambda_simple_params_end_0072:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0072
	jmp .L_lambda_simple_end_0072
.L_lambda_simple_code_0072:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 5
	je .L_lambda_simple_arity_check_ok_0072
	push qword [rsp + 8 * 2]
	push 5
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0072:
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
	jne .L_or_end_0008
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
	jne .L_or_end_0008
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
          	je .L_if_else_0040
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
          	je .L_if_else_003f
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
.L_tc_recycle_frame_loop_008a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_008a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_008a
.L_tc_recycle_frame_done_008a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_003f
          .L_if_else_003f:
          	mov rax, L_constants + 2
.L_if_end_003f:
	jmp .L_if_end_0040
          .L_if_else_0040:
          	mov rax, L_constants + 2
.L_if_end_0040:
.L_or_end_0008:
	leave
	ret 8 * (2 + 5)
.L_lambda_simple_end_0072:	; new closure is in rax
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
.L_lambda_simple_env_loop_0076:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0076
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0076
.L_lambda_simple_env_end_0076:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0076:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0076
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0076
.L_lambda_simple_params_end_0076:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0076
	jmp .L_lambda_simple_end_0076
.L_lambda_simple_code_0076:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0076
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0076:
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
.L_lambda_simple_env_loop_0077:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_0077
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0077
.L_lambda_simple_env_end_0077:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0077:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0077
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0077
.L_lambda_simple_params_end_0077:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0077
	jmp .L_lambda_simple_end_0077
.L_lambda_simple_code_0077:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0077
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0077:
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
          	je .L_if_else_0042
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
.L_tc_recycle_frame_loop_0090:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0090
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0090
.L_tc_recycle_frame_done_0090:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0042
          .L_if_else_0042:
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
.L_tc_recycle_frame_loop_0091:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0091
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0091
.L_tc_recycle_frame_done_0091:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0042:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0077:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_008f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_008f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_008f
.L_tc_recycle_frame_done_008f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0076:	; new closure is in rax
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
.L_lambda_simple_env_loop_0073:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0073
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0073
.L_lambda_simple_env_end_0073:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0073:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0073
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0073
.L_lambda_simple_params_end_0073:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0073
	jmp .L_lambda_simple_end_0073
.L_lambda_simple_code_0073:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0073
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0073:
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
.L_lambda_simple_env_loop_0074:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_0074
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0074
.L_lambda_simple_env_end_0074:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0074:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0074
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0074
.L_lambda_simple_params_end_0074:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0074
	jmp .L_lambda_simple_end_0074
.L_lambda_simple_code_0074:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0074
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0074:
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
.L_lambda_simple_env_loop_0075:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_0075
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0075
.L_lambda_simple_env_end_0075:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0075:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0075
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0075
.L_lambda_simple_params_end_0075:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0075
	jmp .L_lambda_simple_end_0075
.L_lambda_simple_code_0075:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0075
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0075:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_0009
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
          	je .L_if_else_0041
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
.L_tc_recycle_frame_loop_008d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_008d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_008d
.L_tc_recycle_frame_done_008d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0041
          .L_if_else_0041:
          	mov rax, L_constants + 2
.L_if_end_0041:
.L_or_end_0009:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0075:	; new closure is in rax
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
.L_lambda_opt_env_loop_0013:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_0013
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0013
.L_lambda_opt_env_end_0013:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0013:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0013
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0013
.L_lambda_opt_params_end_0013:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0013
	jmp .L_lambda_opt_end_0013
.L_lambda_opt_code_0013:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0013
	jg .L_lambda_opt_arity_check_more_0013
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0013:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0037:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0037
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0037
.L_lambda_opt_stack_shrink_loop_exit_0037:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0013
.L_lambda_opt_arity_check_more_0013:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0038:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0038
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
	jmp .L_lambda_opt_stack_shrink_loop_0038
.L_lambda_opt_stack_shrink_loop_exit_0038:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0039:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0039
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0039
.L_lambda_opt_stack_shrink_loop_exit_0039:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0013:
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
.L_tc_recycle_frame_loop_008e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_008e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_008e
.L_tc_recycle_frame_done_008e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0013:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0074:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_008c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_008c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_008c
.L_tc_recycle_frame_done_008c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0073:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_008b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_008b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_008b
.L_tc_recycle_frame_done_008b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0071:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0089:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0089
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0089
.L_tc_recycle_frame_done_0089:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0070:	; new closure is in rax
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
.L_lambda_simple_env_loop_006f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_006f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_006f
.L_lambda_simple_env_end_006f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_006f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_006f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_006f
.L_lambda_simple_params_end_006f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_006f
	jmp .L_lambda_simple_end_006f
.L_lambda_simple_code_006f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_006f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_006f:
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
.L_lambda_simple_end_006f:	; new closure is in rax
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
.L_lambda_simple_env_loop_0079:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0079
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0079
.L_lambda_simple_env_end_0079:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0079:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0079
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0079
.L_lambda_simple_params_end_0079:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0079
	jmp .L_lambda_simple_end_0079
.L_lambda_simple_code_0079:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0079
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0079:
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
.L_lambda_simple_env_loop_007a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_007a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_007a
.L_lambda_simple_env_end_007a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_007a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_007a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_007a
.L_lambda_simple_params_end_007a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_007a
	jmp .L_lambda_simple_end_007a
.L_lambda_simple_code_007a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_007a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_007a:
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
.L_lambda_simple_env_loop_007b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_007b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_007b
.L_lambda_simple_env_end_007b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_007b:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_007b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_007b
.L_lambda_simple_params_end_007b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_007b
	jmp .L_lambda_simple_end_007b
.L_lambda_simple_code_007b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 4
	je .L_lambda_simple_arity_check_ok_007b
	push qword [rsp + 8 * 2]
	push 4
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_007b:
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
	jne .L_or_end_000a
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
          	je .L_if_else_0044
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
          	je .L_if_else_0043
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
.L_tc_recycle_frame_loop_0093:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0093
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0093
.L_tc_recycle_frame_done_0093:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0043
          .L_if_else_0043:
          	mov rax, L_constants + 2
.L_if_end_0043:
	jmp .L_if_end_0044
          .L_if_else_0044:
          	mov rax, L_constants + 2
.L_if_end_0044:
.L_or_end_000a:
	leave
	ret 8 * (2 + 4)
.L_lambda_simple_end_007b:	; new closure is in rax
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
.L_lambda_simple_env_loop_007f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_007f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_007f
.L_lambda_simple_env_end_007f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_007f:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_007f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_007f
.L_lambda_simple_params_end_007f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_007f
	jmp .L_lambda_simple_end_007f
.L_lambda_simple_code_007f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_007f
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_007f:
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
.L_lambda_simple_env_loop_0080:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_0080
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0080
.L_lambda_simple_env_end_0080:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0080:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0080
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0080
.L_lambda_simple_params_end_0080:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0080
	jmp .L_lambda_simple_end_0080
.L_lambda_simple_code_0080:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0080
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0080:
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
          	je .L_if_else_0046
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
.L_tc_recycle_frame_loop_0099:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0099
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0099
.L_tc_recycle_frame_done_0099:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0046
          .L_if_else_0046:
          	mov rax, L_constants + 2
.L_if_end_0046:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0080:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 2 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0098:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0098
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0098
.L_tc_recycle_frame_done_0098:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_007f:	; new closure is in rax
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
.L_lambda_simple_env_loop_007c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_007c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_007c
.L_lambda_simple_env_end_007c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_007c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_007c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_007c
.L_lambda_simple_params_end_007c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_007c
	jmp .L_lambda_simple_end_007c
.L_lambda_simple_code_007c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_007c
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_007c:
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
.L_lambda_simple_env_loop_007d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 3
	je .L_lambda_simple_env_end_007d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_007d
.L_lambda_simple_env_end_007d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_007d:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_007d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_007d
.L_lambda_simple_params_end_007d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_007d
	jmp .L_lambda_simple_end_007d
.L_lambda_simple_code_007d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_007d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_007d:
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
.L_lambda_simple_env_loop_007e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_simple_env_end_007e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_007e
.L_lambda_simple_env_end_007e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_007e:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_007e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_007e
.L_lambda_simple_params_end_007e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_007e
	jmp .L_lambda_simple_end_007e
.L_lambda_simple_code_007e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_007e
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_007e:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_000b
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
          	je .L_if_else_0045
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
.L_tc_recycle_frame_loop_0096:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0096
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0096
.L_tc_recycle_frame_done_0096:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0045
          .L_if_else_0045:
          	mov rax, L_constants + 2
.L_if_end_0045:
.L_or_end_000b:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_007e:	; new closure is in rax
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
.L_lambda_opt_env_loop_0014:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 4
	je .L_lambda_opt_env_end_0014
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0014
.L_lambda_opt_env_end_0014:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0014:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0014
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0014
.L_lambda_opt_params_end_0014:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0014
	jmp .L_lambda_opt_end_0014
.L_lambda_opt_code_0014:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0014
	jg .L_lambda_opt_arity_check_more_0014
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0014:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_003a:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_003a
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_003a
.L_lambda_opt_stack_shrink_loop_exit_003a:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0014
.L_lambda_opt_arity_check_more_0014:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_003b:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_003b
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
	jmp .L_lambda_opt_stack_shrink_loop_003b
.L_lambda_opt_stack_shrink_loop_exit_003b:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_003c:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_003c
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_003c
.L_lambda_opt_stack_shrink_loop_exit_003c:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0014:
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
.L_tc_recycle_frame_loop_0097:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0097
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0097
.L_tc_recycle_frame_done_0097:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0014:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_007d:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0095:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0095
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0095
.L_tc_recycle_frame_done_0095:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_007c:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0094:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0094
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0094
.L_tc_recycle_frame_done_0094:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_007a:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_0092:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_0092
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_0092
.L_tc_recycle_frame_done_0092:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0079:	; new closure is in rax
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
.L_lambda_simple_env_loop_0078:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0078
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0078
.L_lambda_simple_env_end_0078:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0078:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0078
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0078
.L_lambda_simple_params_end_0078:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0078
	jmp .L_lambda_simple_end_0078
.L_lambda_simple_code_0078:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0078
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0078:
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
.L_lambda_simple_end_0078:	; new closure is in rax
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
.L_lambda_simple_env_loop_0081:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0081
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0081
.L_lambda_simple_env_end_0081:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0081:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0081
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0081
.L_lambda_simple_params_end_0081:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0081
	jmp .L_lambda_simple_end_0081
.L_lambda_simple_code_0081:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0081
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0081:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0047
          	mov rax, L_constants + 32
	jmp .L_if_end_0047
          .L_if_else_0047:
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
.L_tc_recycle_frame_loop_009a:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_009a
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_009a
.L_tc_recycle_frame_done_009a:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0047:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0081:	; new closure is in rax
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
.L_lambda_simple_env_loop_0082:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0082
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0082
.L_lambda_simple_env_end_0082:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0082:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0082
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0082
.L_lambda_simple_params_end_0082:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0082
	jmp .L_lambda_simple_end_0082
.L_lambda_simple_code_0082:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0082
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0082:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
	jne .L_or_end_000c
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0048
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
.L_tc_recycle_frame_loop_009b:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_009b
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_009b
.L_tc_recycle_frame_done_009b:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0048
          .L_if_else_0048:
          	mov rax, L_constants + 2
.L_if_end_0048:
.L_or_end_000c:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0082:	; new closure is in rax
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
.L_lambda_simple_env_loop_0083:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0083
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0083
.L_lambda_simple_env_end_0083:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0083:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0083
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0083
.L_lambda_simple_params_end_0083:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0083
	jmp .L_lambda_simple_end_0083
.L_lambda_simple_code_0083:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0083
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0083:
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
.L_lambda_opt_env_loop_0015:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0015
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0015
.L_lambda_opt_env_end_0015:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0015:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0015
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0015
.L_lambda_opt_params_end_0015:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0015
	jmp .L_lambda_opt_end_0015
.L_lambda_opt_code_0015:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0015
	jg .L_lambda_opt_arity_check_more_0015
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0015:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_003d:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_003d
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_003d
.L_lambda_opt_stack_shrink_loop_exit_003d:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0015
.L_lambda_opt_arity_check_more_0015:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_003e:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_003e
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
	jmp .L_lambda_opt_stack_shrink_loop_003e
.L_lambda_opt_stack_shrink_loop_exit_003e:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_003f:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_003f
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_003f
.L_lambda_opt_stack_shrink_loop_exit_003f:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0015:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_004b
          	mov rax, L_constants + 0
	jmp .L_if_end_004b
          .L_if_else_004b:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0049
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
	jmp .L_if_end_0049
          .L_if_else_0049:
          	mov rax, L_constants + 2
.L_if_end_0049:
	cmp rax, sob_boolean_false
          	je .L_if_else_004a
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_004a
          .L_if_else_004a:
          	mov rax, L_constants + 379
	push rax
	mov rax, L_constants + 370
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
.L_if_end_004a:
.L_if_end_004b:
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
.L_lambda_simple_env_loop_0084:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0084
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0084
.L_lambda_simple_env_end_0084:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0084:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0084
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0084
.L_lambda_simple_params_end_0084:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0084
	jmp .L_lambda_simple_end_0084
.L_lambda_simple_code_0084:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0084
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0084:
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
.L_tc_recycle_frame_loop_009d:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_009d
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_009d
.L_tc_recycle_frame_done_009d:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0084:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_009c:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_009c
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_009c
.L_tc_recycle_frame_done_009c:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0015:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0083:	; new closure is in rax
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
.L_lambda_simple_env_loop_0085:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0085
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0085
.L_lambda_simple_env_end_0085:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0085:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0085
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0085
.L_lambda_simple_params_end_0085:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0085
	jmp .L_lambda_simple_end_0085
.L_lambda_simple_code_0085:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0085
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0085:
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
.L_lambda_opt_env_loop_0016:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_opt_env_end_0016
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0016
.L_lambda_opt_env_end_0016:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0016:	; copy params
	cmp rsi, 1
	je .L_lambda_opt_params_end_0016
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0016
.L_lambda_opt_params_end_0016:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0016
	jmp .L_lambda_opt_end_0016
.L_lambda_opt_code_0016:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_opt_arity_check_exact_0016
	jg .L_lambda_opt_arity_check_more_0016
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0016:
	mov qword [rsp + 8 * 2], 2
	mov rdx, 4
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0040:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0040
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0040
.L_lambda_opt_stack_shrink_loop_exit_0040:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0016
.L_lambda_opt_arity_check_more_0016:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 1
	mov qword [rsp + 8 * 2], 2
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 1 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0041:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0041
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
	jmp .L_lambda_opt_stack_shrink_loop_0041
.L_lambda_opt_stack_shrink_loop_exit_0041:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 24
	mov rsi, 4
.L_lambda_opt_stack_shrink_loop_0042:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0042
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0042
.L_lambda_opt_stack_shrink_loop_exit_0042:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0016:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_004e
          	mov rax, L_constants + 4
	jmp .L_if_end_004e
          .L_if_else_004e:
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_004c
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
	jmp .L_if_end_004c
          .L_if_else_004c:
          	mov rax, L_constants + 2
.L_if_end_004c:
	cmp rax, sob_boolean_false
          	je .L_if_else_004d
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_16]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_004d
          .L_if_else_004d:
          	mov rax, L_constants + 460
	push rax
	mov rax, L_constants + 451
	push rax
	push 2
	mov rax, qword [free_var_38]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
.L_if_end_004d:
.L_if_end_004e:
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
.L_lambda_simple_env_loop_0086:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0086
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0086
.L_lambda_simple_env_end_0086:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0086:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0086
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0086
.L_lambda_simple_params_end_0086:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0086
	jmp .L_lambda_simple_end_0086
.L_lambda_simple_code_0086:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0086
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0086:
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
.L_tc_recycle_frame_loop_009f:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_009f
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_009f
.L_tc_recycle_frame_done_009f:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0086:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_009e:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_009e
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_009e
.L_tc_recycle_frame_done_009e:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 2)
.L_lambda_opt_end_0016:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0085:	; new closure is in rax
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
.L_lambda_simple_env_loop_0087:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0087
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0087
.L_lambda_simple_env_end_0087:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0087:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0087
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0087
.L_lambda_simple_params_end_0087:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0087
	jmp .L_lambda_simple_end_0087
.L_lambda_simple_code_0087:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0087
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0087:
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
.L_lambda_simple_env_loop_0088:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0088
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0088
.L_lambda_simple_env_end_0088:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0088:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0088
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0088
.L_lambda_simple_params_end_0088:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0088
	jmp .L_lambda_simple_end_0088
.L_lambda_simple_code_0088:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_0088
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0088:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_004f
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
.L_tc_recycle_frame_loop_00a0:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00a0
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00a0
.L_tc_recycle_frame_done_00a0:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_004f
          .L_if_else_004f:
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
.L_lambda_simple_env_loop_0089:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_0089
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0089
.L_lambda_simple_env_end_0089:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0089:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_0089
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0089
.L_lambda_simple_params_end_0089:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0089
	jmp .L_lambda_simple_end_0089
.L_lambda_simple_code_0089:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0089
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0089:
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
.L_lambda_simple_end_0089:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00a1:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00a1
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00a1
.L_tc_recycle_frame_done_00a1:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_004f:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_0088:	; new closure is in rax
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
.L_lambda_simple_env_loop_008a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_008a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_008a
.L_lambda_simple_env_end_008a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_008a:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_008a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_008a
.L_lambda_simple_params_end_008a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_008a
	jmp .L_lambda_simple_end_008a
.L_lambda_simple_code_008a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_008a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_008a:
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
.L_tc_recycle_frame_loop_00a2:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00a2
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00a2
.L_tc_recycle_frame_done_00a2:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_008a:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0087:	; new closure is in rax
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
.L_lambda_simple_env_loop_008b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_008b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_008b
.L_lambda_simple_env_end_008b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_008b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_008b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_008b
.L_lambda_simple_params_end_008b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_008b
	jmp .L_lambda_simple_end_008b
.L_lambda_simple_code_008b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_008b
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_008b:
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
.L_lambda_simple_env_loop_008c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_008c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_008c
.L_lambda_simple_env_end_008c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_008c:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_008c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_008c
.L_lambda_simple_params_end_008c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_008c
	jmp .L_lambda_simple_end_008c
.L_lambda_simple_code_008c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_008c
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_008c:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0050
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
.L_tc_recycle_frame_loop_00a3:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00a3
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00a3
.L_tc_recycle_frame_done_00a3:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0050
          .L_if_else_0050:
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
.L_lambda_simple_env_loop_008d:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 2
	je .L_lambda_simple_env_end_008d
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_008d
.L_lambda_simple_env_end_008d:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_008d:	; copy params
	cmp rsi, 2
	je .L_lambda_simple_params_end_008d
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_008d
.L_lambda_simple_params_end_008d:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_008d
	jmp .L_lambda_simple_end_008d
.L_lambda_simple_code_008d:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_008d
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_008d:
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
.L_lambda_simple_end_008d:	; new closure is in rax
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	push qword [rbp + 8 * 1] ; old ret addr
	push qword [rbp] ; same the old rbp
	mov rdx, 1 + 3
	mov rcx, COUNT
	lea rcx, [rbp + 8*4 + rcx * 8]
	mov rdi, rbp
.L_tc_recycle_frame_loop_00a4:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00a4
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00a4
.L_tc_recycle_frame_done_00a4:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_0050:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_008c:	; new closure is in rax
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
.L_lambda_simple_env_loop_008e:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_008e
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_008e
.L_lambda_simple_env_end_008e:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_008e:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_008e
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_008e
.L_lambda_simple_params_end_008e:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_008e
	jmp .L_lambda_simple_end_008e
.L_lambda_simple_code_008e:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_008e
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_008e:
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
.L_tc_recycle_frame_loop_00a5:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00a5
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00a5
.L_tc_recycle_frame_done_00a5:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_008e:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_008b:	; new closure is in rax
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
.L_lambda_opt_env_loop_0017:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_opt_env_end_0017
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_opt_env_loop_0017
.L_lambda_opt_env_end_0017:
	pop rbx
	mov rsi, 0
.L_lambda_opt_params_loop_0017:	; copy params
	cmp rsi, 0
	je .L_lambda_opt_params_end_0017
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_opt_params_loop_0017
.L_lambda_opt_params_end_0017:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_opt_code_0017
	jmp .L_lambda_opt_end_0017
.L_lambda_opt_code_0017:	; lambda-opt body
	cmp qword [rsp + 8 * 2], 0
	je .L_lambda_opt_arity_check_exact_0017
	jg .L_lambda_opt_arity_check_more_0017
	push qword [rsp + 8 * 2]
	push 0
	jmp L_error_incorrect_arity_opt
.L_lambda_opt_arity_check_exact_0017:
	mov qword [rsp + 8 * 2], 1
	mov rdx, 3
	push qword [rsp]
	mov rsi, 1
.L_lambda_opt_stack_shrink_loop_0043:
	cmp rsi, rdx
	je .L_lambda_opt_stack_shrink_loop_exit_0043
	lea rbx, [rsp + 8 + rsi * 8]
	mov rcx, [rbx]
	mov qword [rbx - 8], rcx
	inc rsi
	jmp .L_lambda_opt_stack_shrink_loop_0043
.L_lambda_opt_stack_shrink_loop_exit_0043:
	mov qword [rbx], sob_nil
	jmp .L_lambda_opt_stack_adjusted_0017
.L_lambda_opt_arity_check_more_0017:
	mov rdx, qword [rsp + 8 * 2]
	sub rdx, 0
	mov qword [rsp + 8 * 2], 1
	mov rsi, 0
	lea rbx, [rsp + 2 * 8 + 0 * 8 + rdx * 8]
	mov rcx, sob_nil
.L_lambda_opt_stack_shrink_loop_0044:
	cmp rsi, rdx
je .L_lambda_opt_stack_shrink_loop_exit_0044
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
	jmp .L_lambda_opt_stack_shrink_loop_0044
.L_lambda_opt_stack_shrink_loop_exit_0044:
	mov qword [rbx], rcx
	sub rbx, 8
	mov rdi, rsp
	add rdi, 16
	mov rsi, 3
.L_lambda_opt_stack_shrink_loop_0045:
	cmp rsi,0
	je .L_lambda_opt_stack_shrink_loop_exit_0045
	mov rcx, qword [rdi]
	mov [rbx], rcx
	dec rsi
	sub rbx, 8
	sub rdi, 8
	jmp .L_lambda_opt_stack_shrink_loop_0045
.L_lambda_opt_stack_shrink_loop_exit_0045:
	add rbx, 8
	mov rsp, rbx
.L_lambda_opt_stack_adjusted_0017:
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
.L_tc_recycle_frame_loop_00a6:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00a6
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00a6
.L_tc_recycle_frame_done_00a6:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_opt_end_0017:	; new closure is in rax
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
.L_lambda_simple_env_loop_008f:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_008f
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_008f
.L_lambda_simple_env_end_008f:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_008f:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_008f
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_008f
.L_lambda_simple_params_end_008f:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_008f
	jmp .L_lambda_simple_end_008f
.L_lambda_simple_code_008f:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_008f
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_008f:
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
.L_lambda_simple_env_loop_0090:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0090
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0090
.L_lambda_simple_env_end_0090:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0090:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0090
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0090
.L_lambda_simple_params_end_0090:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0090
	jmp .L_lambda_simple_end_0090
.L_lambda_simple_code_0090:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_0090
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0090:
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
          	je .L_if_else_0051
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
.L_tc_recycle_frame_loop_00a7:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00a7
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00a7
.L_tc_recycle_frame_done_00a7:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0051
          .L_if_else_0051:
          	mov rax, L_constants + 1
.L_if_end_0051:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_0090:	; new closure is in rax
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
.L_lambda_simple_env_loop_0091:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0091
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0091
.L_lambda_simple_env_end_0091:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0091:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0091
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0091
.L_lambda_simple_params_end_0091:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0091
	jmp .L_lambda_simple_end_0091
.L_lambda_simple_code_0091:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0091
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0091:
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
.L_tc_recycle_frame_loop_00a8:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00a8
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00a8
.L_tc_recycle_frame_done_00a8:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0091:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_008f:	; new closure is in rax
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
.L_lambda_simple_env_loop_0092:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0092
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0092
.L_lambda_simple_env_end_0092:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0092:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0092
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0092
.L_lambda_simple_params_end_0092:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0092
	jmp .L_lambda_simple_end_0092
.L_lambda_simple_code_0092:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0092
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0092:
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
.L_lambda_simple_env_loop_0093:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0093
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0093
.L_lambda_simple_env_end_0093:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0093:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0093
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0093
.L_lambda_simple_params_end_0093:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0093
	jmp .L_lambda_simple_end_0093
.L_lambda_simple_code_0093:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 3
	je .L_lambda_simple_arity_check_ok_0093
	push qword [rsp + 8 * 2]
	push 3
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0093:
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
          	je .L_if_else_0052
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
.L_tc_recycle_frame_loop_00a9:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00a9
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00a9
.L_tc_recycle_frame_done_00a9:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0052
          .L_if_else_0052:
          	mov rax, L_constants + 1
.L_if_end_0052:
	leave
	ret 8 * (2 + 3)
.L_lambda_simple_end_0093:	; new closure is in rax
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
.L_lambda_simple_env_loop_0094:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 1
	je .L_lambda_simple_env_end_0094
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0094
.L_lambda_simple_env_end_0094:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0094:	; copy params
	cmp rsi, 1
	je .L_lambda_simple_params_end_0094
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0094
.L_lambda_simple_params_end_0094:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0094
	jmp .L_lambda_simple_end_0094
.L_lambda_simple_code_0094:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0094
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0094:
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
.L_tc_recycle_frame_loop_00aa:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00aa
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00aa
.L_tc_recycle_frame_done_00aa:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0094:	; new closure is in rax
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0092:	; new closure is in rax
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
.L_lambda_simple_env_loop_0095:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0095
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0095
.L_lambda_simple_env_end_0095:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0095:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0095
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0095
.L_lambda_simple_params_end_0095:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0095
	jmp .L_lambda_simple_end_0095
.L_lambda_simple_code_0095:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0095
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0095:
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
.L_tc_recycle_frame_loop_00ab:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00ab
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00ab
.L_tc_recycle_frame_done_00ab:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0095:	; new closure is in rax
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
.L_lambda_simple_env_loop_0096:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0096
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0096
.L_lambda_simple_env_end_0096:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0096:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0096
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0096
.L_lambda_simple_params_end_0096:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0096
	jmp .L_lambda_simple_end_0096
.L_lambda_simple_code_0096:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0096
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0096:
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
.L_tc_recycle_frame_loop_00ac:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00ac
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00ac
.L_tc_recycle_frame_done_00ac:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0096:	; new closure is in rax
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
.L_lambda_simple_env_loop_0097:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0097
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0097
.L_lambda_simple_env_end_0097:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0097:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0097
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0097
.L_lambda_simple_params_end_0097:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0097
	jmp .L_lambda_simple_end_0097
.L_lambda_simple_code_0097:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0097
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0097:
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
.L_tc_recycle_frame_loop_00ad:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00ad
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00ad
.L_tc_recycle_frame_done_00ad:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0097:	; new closure is in rax
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
.L_lambda_simple_env_loop_0098:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0098
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0098
.L_lambda_simple_env_end_0098:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0098:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0098
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0098
.L_lambda_simple_params_end_0098:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0098
	jmp .L_lambda_simple_end_0098
.L_lambda_simple_code_0098:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0098
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0098:
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
.L_tc_recycle_frame_loop_00ae:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00ae
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00ae
.L_tc_recycle_frame_done_00ae:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0098:	; new closure is in rax
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
.L_lambda_simple_env_loop_0099:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_0099
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_0099
.L_lambda_simple_env_end_0099:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_0099:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_0099
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_0099
.L_lambda_simple_params_end_0099:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_0099
	jmp .L_lambda_simple_end_0099
.L_lambda_simple_code_0099:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_0099
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_0099:
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
.L_tc_recycle_frame_loop_00af:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00af
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00af
.L_tc_recycle_frame_done_00af:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_0099:	; new closure is in rax
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
.L_lambda_simple_env_loop_009a:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_009a
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_009a
.L_lambda_simple_env_end_009a:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_009a:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_009a
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_009a
.L_lambda_simple_params_end_009a:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_009a
	jmp .L_lambda_simple_end_009a
.L_lambda_simple_code_009a:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 1
	je .L_lambda_simple_arity_check_ok_009a
	push qword [rsp + 8 * 2]
	push 1
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_009a:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_140]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0053
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
.L_tc_recycle_frame_loop_00b0:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00b0
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00b0
.L_tc_recycle_frame_done_00b0:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0053
          .L_if_else_0053:
          	mov rax, qword [rbp + 8 * (4 + 0)]
.L_if_end_0053:
	leave
	ret 8 * (2 + 1)
.L_lambda_simple_end_009a:	; new closure is in rax
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
.L_lambda_simple_env_loop_009b:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_009b
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_009b
.L_lambda_simple_env_end_009b:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_009b:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_009b
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_009b
.L_lambda_simple_params_end_009b:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_009b
	jmp .L_lambda_simple_end_009b
.L_lambda_simple_code_009b:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_009b
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_009b:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0054
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_1]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0054
          .L_if_else_0054:
          	mov rax, L_constants + 2
.L_if_end_0054:
	cmp rax, sob_boolean_false
          	je .L_if_else_005c
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
          	je .L_if_else_0055
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
.L_tc_recycle_frame_loop_00b1:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00b1
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00b1
.L_tc_recycle_frame_done_00b1:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_0055
          .L_if_else_0055:
          	mov rax, L_constants + 2
.L_if_end_0055:
	jmp .L_if_end_005c
          .L_if_else_005c:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_6]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0057
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_6]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0056
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
	jmp .L_if_end_0056
          .L_if_else_0056:
          	mov rax, L_constants + 2
.L_if_end_0056:
	jmp .L_if_end_0057
          .L_if_else_0057:
          	mov rax, L_constants + 2
.L_if_end_0057:
	cmp rax, sob_boolean_false
          	je .L_if_else_005b
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
.L_tc_recycle_frame_loop_00b2:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00b2
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00b2
.L_tc_recycle_frame_done_00b2:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_005b
          .L_if_else_005b:
          	mov rax, qword [rbp + 8 * (4 + 0)]
	push rax
	push 1
	mov rax, qword [free_var_4]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0059
          	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_4]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_0058
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
	jmp .L_if_end_0058
          .L_if_else_0058:
          	mov rax, L_constants + 2
.L_if_end_0058:
	jmp .L_if_end_0059
          .L_if_else_0059:
          	mov rax, L_constants + 2
.L_if_end_0059:
	cmp rax, sob_boolean_false
          	je .L_if_else_005a
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
.L_tc_recycle_frame_loop_00b3:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00b3
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00b3
.L_tc_recycle_frame_done_00b3:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_005a
          .L_if_else_005a:
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
.L_tc_recycle_frame_loop_00b4:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00b4
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00b4
.L_tc_recycle_frame_done_00b4:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_005a:
.L_if_end_005b:
.L_if_end_005c:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_009b:	; new closure is in rax
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
.L_lambda_simple_env_loop_009c:	; ext_env[i + 1] <-- env[i]
	cmp rsi, 0
	je .L_lambda_simple_env_end_009c
	mov rcx, qword [rdi + 8 * rsi]
	mov qword [rax + 8 * rdx], rcx
	inc rsi
	inc rdx
	jmp .L_lambda_simple_env_loop_009c
.L_lambda_simple_env_end_009c:
	pop rbx
	mov rsi, 0
.L_lambda_simple_params_loop_009c:	; copy params
	cmp rsi, 0
	je .L_lambda_simple_params_end_009c
	mov rdx, qword [rbp + 8 * rsi + 8 * 4]
	mov qword [rbx + 8 * rsi], rdx
	inc rsi
	jmp .L_lambda_simple_params_loop_009c
.L_lambda_simple_params_end_009c:
	mov qword [rax], rbx	; ext_env[0] <-- new_rib 
	mov rbx, rax
	pop rax
	mov byte [rax], T_closure
	mov SOB_CLOSURE_ENV(rax), rbx
	mov SOB_CLOSURE_CODE(rax), .L_lambda_simple_code_009c
	jmp .L_lambda_simple_end_009c
.L_lambda_simple_code_009c:	; lambda-simple body
	cmp qword [rsp + 8 * 2], 2
	je .L_lambda_simple_arity_check_ok_009c
	push qword [rsp + 8 * 2]
	push 2
	jmp L_error_incorrect_arity_simple
.L_lambda_simple_arity_check_ok_009c:
	enter 0, 0
	mov rax, qword [rbp + 8 * (4 + 1)]
	push rax
	push 1
	mov rax, qword [free_var_0]
	assert_closure(rax)
	push SOB_CLOSURE_ENV(rax)
	call SOB_CLOSURE_CODE(rax)
	cmp rax, sob_boolean_false
          	je .L_if_else_005e
          	mov rax, L_constants + 2
	jmp .L_if_end_005e
          .L_if_else_005e:
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
          	je .L_if_else_005d
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
.L_tc_recycle_frame_loop_00b5:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00b5
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00b5
.L_tc_recycle_frame_done_00b5:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
	jmp .L_if_end_005d
          .L_if_else_005d:
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
.L_tc_recycle_frame_loop_00b6:
	cmp rdx, 0
	je .L_tc_recycle_frame_done_00b6
	sub rcx, 8
	sub rdi, 8
	mov rsi, [rdi]
	mov qword [rcx], rsi
	dec rdx
	jmp .L_tc_recycle_frame_loop_00b6
.L_tc_recycle_frame_done_00b6:
	pop rbp ; restore the old rbp
	mov rsp, rcx
	jmp SOB_CLOSURE_CODE(rax)
.L_if_end_005d:
.L_if_end_005e:
	leave
	ret 8 * (2 + 2)
.L_lambda_simple_end_009c:	; new closure is in rax
	mov qword [free_var_145], rax
	mov rax, sob_void

	mov rdi, rax
	call print_sexpr_if_not_void

	mov rax, L_constants + 512
	push rax
	mov rax, L_constants + 128
	push rax
	push 2
	mov rax, qword [free_var_97]
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

