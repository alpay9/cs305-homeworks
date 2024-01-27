
(define error-repl
   (lambda (perm-env)
      (begin
            (display "cs305: ERROR\n\n")
            (repl perm-env)
      )
   )
)

(define get-operator
   (lambda (op-symbol perm-env)
      (cond
         ((eq? op-symbol '+) +)
         ((eq? op-symbol '*) *)
         ((eq? op-symbol '-) -)
         ((eq? op-symbol '/) /)
         (else (error-repl perm-env))
      )
   )
)

(define var-in-env
   (lambda (var env)
      (cond
         ((null? env) 0)
         ((eq? var (caar env)) 1)
         (else (var-in-env var (cdr env)))
      )
   )
)

(define get-value 
   (lambda (var perm-env temp-env)
      (cond
         ((null? temp-env) (error-repl perm-env))
         ((eq? var (caar temp-env)) (cdar temp-env))
         (else (get-value var perm-env (cdr temp-env)))
      )
   )
)

(define extend-env 
   (lambda (var val old-env)
      (cons (cons var val) old-env)
   )
)

(define define-expr? 
   (lambda (e env)
      (if (and (list? e) (eq? (car e) 'define))
         (if (and (= (length e) 3) (symbol? (cadr e))) #t (error-repl env))
         #f
      )
   )
)

(define if-expr?
   (lambda (e env)
      (if (and (list? e) (eq? (car e) 'if))
         (if (= (length e) 4) #t (error-repl env))
         #f
      )
   )
)

(define if-expr
   (lambda (rest-expr perm-env temp-env)
      (if (= 0 (s7 (car rest-expr) perm-env temp-env))
          (s7 (caddr rest-expr) perm-env temp-env)
          (s7 (cadr rest-expr) perm-env temp-env)
      )
   )
)

(define let-expr?
   (lambda (e env)
      (if (and (list? e) (eq? (car e) 'let))
         (if (and (= (length e) 3) (list? (cadr e))) #t (error-repl))
         #f
      )
   )
)

(define is-duplicate
   (lambda (var bindings)
      (cond
         ((null? bindings) #f)
         ((eq? var (caar bindings)) #t)
         (else (is-duplicate var (cdr bindings)))
      )
   )
)

(define make-bindings
   (lambda (bindings perm-env temp-env let-env)
      (cond
         ((null? bindings) let-env)
         ((is-duplicate (caar bindings) (cdr bindings)) (error-repl perm-env))
         (else (make-bindings (cdr bindings) perm-env temp-env (extend-env (caar bindings) (s7 (cadar bindings) perm-env temp-env) let-env)))
      )
   )
)

(define let-expr
   (lambda (rest-expr perm-env temp-env)
      (s7 (cadr rest-expr)
          perm-env
          (append (make-bindings (car rest-expr) perm-env temp-env ()) temp-env)
      )
   )
)

(define lambda-expr?
   (lambda (e env)
      (if (and (list? e) (eq? (car e) 'lambda))
         (if (and (= (length e) 3) (list? (cadr e))) #t (error-repl env)) 
         #f
      )
   )
)

(define lambda-expr
   (lambda (rest-expr perm-env temp-env)
      (if (null? (car rest-expr))
         (s7 (cdr rest-expr) perm-env temp-env)
         (begin 
            (display "cs305: [PROCEDURE]\n\n")
            (repl perm-env)
         )
      )
      
   )
)

(define s7 
   (lambda (e perm-env temp-env)
      (cond
         ((number? e) e)
         ((symbol? e) (if (or (eq? e '+) (eq? e '-) (eq? e '*) (eq? e '/)) (begin (display "cs305: [PROCEDURE]\n\n") (repl perm-env)) (get-value e perm-env temp-env)))
         ((if-expr? e perm-env) (if-expr (cdr e) perm-env temp-env))
         ((let-expr? e perm-env) (let-expr (cdr e) perm-env temp-env))
         ((lambda-expr? e perm-env) (lambda-expr (cdr e) perm-env temp-env))
         ((not (list? e)) (error-repl perm-env))
         ((not (> (length e) 1)) (error-repl perm-env))
         (else
            (let (
                  (operator (get-operator (car e) perm-env))
                  (operands (map s7 (cdr e) (make-list (length (cdr e)) perm-env) (make-list (length (cdr e)) temp-env)))
               )
               (apply operator operands)
            )
         )
      )
   )
)

(define repl 
   (lambda (env)
      (let* (
            (dummy1 (display "cs305> "))
            (expr (read))
            (new-env (if (define-expr? expr env)
                         (extend-env (cadr expr) (s7 (caddr expr) env env) env)
                         env
            ))
            (val (if (define-expr? expr env)
                     (cadr expr)
                     (s7 expr env env)
            ))
            (dummy2 (display "cs305: "))
            (dummy3 (display val))
            (dummy4 (newline))
            (dummy5 (newline))
         )
         (repl new-env)
      )
   )
)

(define cs305
   (lambda () 
      (repl ())
   )
)