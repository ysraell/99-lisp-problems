;;;; Sudoku solver

;;; p97

(defun solve-sudoku (array &optional (spot (next-undefined-spot array)))
  "Return solutions to a valid Sudoku puzzle, represented by a 9x9 array with elements either an integer between 1 and 9 or NIL."
  (if (null spot)
      (list array)
      (mapcan (lambda (n &aux (a (copy-seq array))) ;expensive
                (setf (aref a (car spot) (cdr spot)) n)
                (solve-sudoku a (next-undefined-spot a spot)))
              (set-difference (range 1 9) ;p22
                (union (row-defined-spots array spot)
                       (col-defined-spots array spot)
                       (sqr-defined-spots array spot))))))

(defun next-undefined-spot (array &optional (start (cons 0 0)))
  "Return the next spot of ARRAY, read from left to right and from top to bottom, that comes after START and is NIL."
  (do ((row (car start)) 
       (col (cdr start)))
      ((= row (array-dimension array 0)))
      (unless (aref array row col)
        (return (cons row col)))
      (if (= (incf col) (array-dimension array 1))
          (setf row (1+ row) col 0))))

(defun row-defined-spots (array spot)
  "Return the numbers on the same row as SPOT in ARRAY that are not NIL."
  (loop for col to (array-dimension array 1)
        for row = (car spot)
        if (aref array row col)
        collect it))

(defun col-defined-spots (array spot)
  "Return the numbers on the same column as SPOT in ARRAY that are not NIL."
  (loop for row to (array-dimension array 0)
        for col = (cdr spot)
        if (aref array row col)
        collect it))

(defun sqr-defined-spots (array spot)
  "Return the numbers on the same 3x3 square as SPOT in ARRAY that are not NIL."
  (do ((row (* 3 (floor (car spot) 3) (1+ row))) res)
      ((= row (* 3 (ceiling (car spot) 3))) res)
      (do ((col (* 3 (floor (cdr spot) 3)) (1+ col)))
          ((= col (* 3 (ceiling (cdr spot) 3))))
          (if (aref array row col)
              (push (aref array row col) res)))))

(defun print-sudoku (array)
  "Print a 9x9 array representing a Sudoku puzzle."
  (dotimes (row 9)
    ;; horizontal separators
    (when (> row 0) 
      (if (= (rem row 3) 0)
          (print "--------+---------+--------")
          (print "        |         |        ")))
    ;; print each column
    (dotimes (col 9)
      ;; column separators
      (when (> col 0)
        (format t " ~[|~] " (rem col 3)))
      ;; print array[row, col] if not NIL, else print .
      (format t "~[.~;~:*~D~]" (aref array row col)))))

;;; p98

(defun solve-nonogram (rows cols &optional puzzle)
  "Solve the nonogram puzzle represented by the given lists of solid lengths across each row and column.
A full cell in a solution of the puzzle will be represented by T, and an empty cell by NIL."
  ;; Akin to the Sudoku solution, go through each combination of solids across a given row,
  ;; filtered based on the patterns for each column, which are adjusted accordingly.
  ;; Convert the inefficient tree recursion + mapcan implementation into an iterative tree search,
  ;; perhaps by recording lists of rows in place of each node (recursion) of the tree.
  (if (null rows)
      (list puzzle)
      ;; start from the last row
      (mapcan (lambda (row &aux (p (partition-cols cols row)))
                ;; if every cell is compatible with the current state of columns
                (when (every #'identity (mapcar #'car p))
                  (solve-nonogram (butlast rows)
                                  (mapcar #'cadr p)
                                  (cons row puzzle))))
              (generate-rows (car (last rows))))))

;; A column is represented as a list of numbers with last element possibly NIL, depending on if the last row can be filled.

(defun partition-cols (row cols)
  "Separate COLS into firsts and rests based on whether row is T at each column."
  (loop for cell in row
        for col in cols
        if cell 
          collect (list (column-first col) (column-rest col))
        else
          collect (list T col)))

(defun column-first (col)
  "Return T if a cell in the last row and same column as COL can be filled."
  (not (null (car (last col)))))

(defun column-rest (col)
  "Return the rest of COL after the last row has been applied."
  (case (car (last col))
    (NIL (butlast col)) ;works also if col is NIL
    (1   (append (butlast col) (list NIL)))
    (T   (append (butlast col) (mapcar #'1- (last col))))))

(defun generate-rows (row-list)
  "Fill a row with T and NIL based on the given list of lengths."
  )