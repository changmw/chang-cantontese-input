;;;
;;; CS0361  PROGRAMMING LANGUAGE I
;;;     ASSIGNMENT ONE
;;;
;;; STUDENT NAME   :  CHANG MAN WAI
;;; STUDENT NUMBER :  86xxxxxx
;;; GROUP NUMBER   :  8
;;; COURSE         :  BSCCS-2 (5421-2)
;;; LECTURER & TUTOR : MR. H.C. HO
;;;
;;; This program implements a simple parser that parse an arithmetic 
;;; expression according to the grammer specified below:
;;;
;;; <expression> ::= <simple expression> | <simple expression> <relational operator> <simple expression>
;;; <simple expression> ::= <term> | <sign> <term> | <term> <adding operator> <simple expression>
;;; <term> ::= <factor> | <factor> <multiplying operator> <term>
;;; <factor> ::= <number> | <identifier> | not <factor> | (<expression>)
;;; <relational operator> ::= <> | >= | <= | > | < | =
;;; <sign> ::= + | -
;;; <adding operator> ::= + | - | OR
;;; <multiplying operator> ::= * | / | DIV | MOD | AND
;;; <number> ::= valid LISP numeric atoms
;;; <identifier> ::= valid LISP symbol except the binary and unary operators
;;;
(DEFUN PARSER()
;; this procedure reads in an arithmetic expression, hands it over to the
;; parser and echos back the expression with the result of parsing
   (SETQ REL-OP '(= <> < > >= <=))      ;define valid character sets
   (SETQ SIGNS '(+ -))
   (SETQ ADD-OP '(+ - OR))
   (SETQ MUL-OP '(* / DIV MOD AND))
;; get expression from user
   (FORMAT T "~%~%***  ARITHMETIC AND LOGIC EXPRESSION PARSER  ***")
   (FORMAT T "~%~%Input an arithmetic and/or logic expression.")
   (FORMAT T "~%Enclose expression in paired parenthesis.")
   (FORMAT T "~%Seperate each symbol by a space.")
   (FORMAT T "~%Press ENTER when finished.~%? ")
   (SETQ IN-EXP (READ))
;; responds whether the expression is correct
   (FORMAT T "~% PARSING....")
   (FORMAT T "~%~%Expression ~S" IN-EXP)
   (COND ((EXP IN-EXP) (FORMAT T " Valid~%~%"))
         (T            (FORMAT T " Invalid~%~%")))
   (FORMAT T "***  END  ***~%"))

(DEFUN GET-LEFT-TREE(OP-SET L)
;; this procedure returns (A operator) of (A operator B) where operator is
;; a member of OP-SET and A,B are sublists of L
   (COND ((NULL L) NIL)
         ((NOT (NULL (MEMBER (CAR L) OP-SET))) (LIST (CAR L)))
         (T (CONS (CAR L) (GET-LEFT-TREE OP-SET (CDR L))))))

(DEFUN GET-RIGHT-TREE(OP-SET L)
;; this procedure returns (A) of (A operator B) where operator is a member
;; of OP-SET and A,B are sublists of L
   (CDR (REVERSE (GET-LEFT-TREE OP-SET (REVERSE L)))))

(DEFUN BACK-CDR(L)
;; this procedure returns (X Y) of (X Y Z) where X,Y,Z are atoms or lists of L
    (REVERSE (CDR (REVERSE L))))

(DEFUN EXP(IN-EXP)
   (COND ((NULL IN-EXP) NIL)  ;check if expression is null
	 ((ATOM IN-EXP) NIL) ;check if expression is list
         ((SIMPLE-EXP IN-EXP) T)
         ((AND (SIMPLE-EXP (BACK-CDR (GET-LEFT-TREE REL-OP IN-EXP))) ;the left sublist is a <simple expressio> and 
               (CHECK-OP REL-OP (LAST (GET-LEFT-TREE REL-OP IN-EXP)))  ;<relational operator> is specified and is correct and 
               (SIMPLE-EXP (GET-RIGHT-TREE REL-OP IN-EXP))) T)       ; right sublist is a <simple expression>
         (T NIL)))

(DEFUN SIMPLE-EXP(IN-EXP)
   (COND ((TERM IN-EXP) T)                                      ;check if the whole list is a <term> OR
         ((AND (CHECK-OP SIGNS IN-EXP)                          ;check if <sign> is a valid sign and
               (TERM (CDR IN-EXP))) T)                          ;check if the list is a <term> OR
         ((AND (TERM (BACK-CDR (GET-LEFT-TREE ADD-OP IN-EXP)))  ;check if left sublist is a <term> and
               (CHECK-OP ADD-OP (LAST (GET-LEFT-TREE ADD-OP IN-EXP))) ;check if valid adding operator and
               (SIMPLE-EXP (GET-RIGHT-TREE ADD-OP IN-EXP))) T)  ;check if the right sublist is a <simple expression>
         (T NIL)))

(DEFUN TERM(IN-EXP)
   (COND ((FACTOR IN-EXP) T)                                         ;check if the whole list is a <factor> OR
         ((AND (FACTOR (BACK-CDR (GET-LEFT-TREE MUL-OP IN-EXP)))     ;left sublist is a <factor> and
               (CHECK-OP MUL-OP (LAST (GET-LEFT-TREE MUL-OP IN-EXP))) ;an valid <multiplying operator> is specified and
               (TERM (GET-RIGHT-TREE MUL-OP IN-EXP))) T)             ;right sublist is  a <term>
         (T NIL)))

(DEFUN FACTOR(IN-EXP)
   (COND ((NULL IN-EXP) NIL)                  ;<factor> cannot be nil
         ((AND (CHECK-OP '(NOT) IN-EXP)       ;a leading 'not' is found and
               (FACTOR (CDR IN-EXP))) T)      ;the rest of list is a <factor>
         ((> (LENGTH IN-EXP) 1) NIL)          ;if the list has one atom
         ((AND (LISTP (CAR IN-EXP))           ;(<expression>) must be a list 
               (EXP (CAR IN-EXP))) T)         ; and is correct OR
         ((NUMBERP (CAR IN-EXP)) T)           ;  it is a valid LISP <number> OR
         ((AND (SYMBOLP (CAR IN-EXP))         ; (identifier> must be a valid LISP symbol and
               (NOT (NULL (CAR IN-EXP)))      ;  is not null and
               (NOT (CHECK-OP (APPEND REL-OP ADD-OP MUL-OP SIGNS '(NOT)) IN-EXP))) T) ;   is not a operator symbol
         (T NIL)))

(DEFUN CHECK-OP(OP-SET ELEMENT)
   (COND ((NULL ELEMENT) NIL)      ;empty list is not a valid symbol
         ((NULL (MEMBER (CAR ELEMENT) OP-SET)) NIL) (T))) ;check if the symbol is contained in the OP-SET
