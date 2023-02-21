;;;
;;; CS0361  PROGRAMMING LANGUAGE I
;;;      ASSIGNMENT ONE
;;;
;;; STUDENT NAME   :  CHANG MAN WAI
;;; STUDENT NUMBER :  86xxxxxx
;;; GROUP NUMBER   :  8
;;; COURSE         : BSCCS-2 (5421-2)
;;; LECTURER & TUTOR : MR. H.C.HO
;;;
;;; This program sorts an input list by insertion sort.
;;; The algorithm of this program is given as follows:
;;;
;;;   sorts CDR of the original list recursively until its length is one
;;;       pick the first element of the sublist as key
;;;       insert it in its final position by looking down the list recursively
;;;            if the first element of the list > second element then exchange their position
;;;
(DEFUN SORT(L)
;; this procedure check if the list is valid and sorts it
   (COND ((NULL L) '(EMPTY LIST))       ;IF EMPTY LIST THEN NOP
         ((ATOM L) '(NOT A LIST))       ;ELSE IF NOT A LIST THEN ERROR
         ((NOT (ALL-NUMBER L)) '(NOT NUMBER))     ;     ELSE IF LETTER FOUND ERROR
         (T (INSERTION-SORT L) L)))     ;          ELSE SORT(LIST)
                                        ;               RETURN(SORTED LIST)
(DEFUN ALL-NUMBER(L)
;; check if the list L contains non-numeric atoms
   (COND ((NULL L) T)
         ((NUMBERP (CAR L)) (ALL-NUMBER (CDR L)))
         (T NIL)))

(DEFUN INSERTION-SORT(L)
;; this procedures sorts the input list recursively
   (COND ((= (LENGTH L) 1) L)        ;IF LENGTH(LIST[N]) = 1 THEN NOP
         (T (INSERTION-SORT (CDR L)) ;ELSE SORT(LIST[N-1])
            (INSERT (CAR L) L))))    ;     INSERT(FISRT-ATOM(LIST[N]),LIST[N])

(DEFUN INSERT(KEY L)
;; this procedure inserts the first element of a sublist of the input list
;; in its final position
  (COND ((= (LENGTH L) 1) L)         ;IF LENGTH(LIST[J]) = 1 THEN NOP
        ((> KEY (CADR L))            ;ELSE IF KEY > LIST[J+1]
             (RPLACA L (CADR L))     ;     THEN LIST[J] := LIST[J+1]
             (RPLACA (CDR L) KEY)    ;          LIST[J+1] := KEY
             (INSERT KEY (CDR L))))) ;          INSERT(KEY, LIST[J-1])
