
(define twoOperatorCalculator 
    (lambda (expr)
        (cond
            ((null? expr) 0)
            ((null? (cdr expr)) (car expr))
            ((eq? (cadr expr) '+) (twoOperatorCalculator (cons (+ (car expr) (caddr expr)) (cdddr expr))))
            ((eq? (cadr expr) '-) (twoOperatorCalculator (cons (- (car expr) (caddr expr)) (cdddr expr))))
        )
    )
)

(define fourOperatorCalculator
    (lambda (expr)
        (cond
            ((null? expr) expr)
            ((null? (cdr expr)) expr)
            ((eq? (cadr expr) '*) (fourOperatorCalculator (cons (* (car expr) (caddr expr)) (cdddr expr))))
            ((eq? (cadr expr) '/) (fourOperatorCalculator (cons (/ (car expr) (caddr expr)) (cdddr expr))))
            ((eq? (cadr expr) '+) (cons (car expr) (cons '+ (fourOperatorCalculator (cddr expr)))))
            ((eq? (cadr expr) '-) (cons (car expr) (cons '- (fourOperatorCalculator (cddr expr)))))
        )
    )
)

(define calculatorNested 
    (lambda (expr)
        (cond
            ((null? expr) expr)
            (else (cons
                    (if (list? (car expr))
                        (twoOperatorCalculator (fourOperatorCalculator (calculatorNested (car expr))))
                        (car expr)
                    )
                    (if (null? (cdr expr))
                        ()
                        (cons (cadr expr)
                            (calculatorNested (cddr expr))
                        )
                    )
                )
            )
        )
    )
)

(define checkOperators 
    (lambda (expr)
        (cond
            ((not (list? expr)) #f)
            ((null? expr) #f)
            ((cond
                ((list? (car expr)) (not (checkOperators (car expr))))
                (else (not (number? (car expr))))
            ) #f)
            ((null? (cdr expr)) #t)
            ((cond
                ((eq? (cadr expr) '+) #f)
                ((eq? (cadr expr) '-) #f)
                ((eq? (cadr expr) '*) #f)
                ((eq? (cadr expr) '/) #f)
                (else #t)
            ) #f)
            ((null? (cddr expr)) #f)
            (else (checkOperators (cddr expr)))
        )
    )
)

(define calculator
    (lambda (expr)
        (if (not (checkOperators expr))
            #f
            (twoOperatorCalculator (fourOperatorCalculator (calculatorNested expr)))
        )
    )
)
