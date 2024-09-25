
RECODE amount_time_id (5=1) (6=2) (1=3) (2=4) (3=5) (4=6).
EXECUTE.

VALUE LABELS  timepoint 1 'Morning' 2 'Afternoon' 3 'Evening' 4 'Night' 5 'Monday' 6 'Tuesday' 7 'Wednesday' 8 'Thursday' 9 'Friday' 10 'Saturday' 11 'Sunday'.
VALUE LABELS amount_time_id 1 'Never' 2 'Occasionally' 3 '<1h' 4 '1-2h' 5 '2-4h' 6 '>4h'.

GRAPH
  /HISTOGRAM=amount_time_id
  /PANEL ROWVAR=timepoint ROWOP=CROSS.

