:- consult('example-input.pl').

employee(_).

workstation(_, Min, Max) :-
    integer(Min),
    integer(Max),
    Min >= 0,
    Max >= Min.

workstation_idle(_, Shift) :-
    member(Shift, [morning, evening, night]).

avoid_workstation(_, _).

avoid_shift(_, Shift) :-
    member(Shift, [morning, evening, night]).

works_at([], _, _) :- fail.
works_at([workstation(Station, Workers)|_], Worker, Station) :-
    member(Worker, Workers),!.
works_at([_|T], Worker, Station) :-
    works_at(T, Worker, Station).

works_at(plan(Morning,_,_), morning, Worker, Station) :-
    works_at(Morning, Worker, Station).
works_at(plan(_,Evening,_), evening, Worker, Station) :-
    works_at(Evening, Worker, Station).
works_at(plan(_,_,Night), night, Worker, Station) :-
    works_at(Night, Worker, Station).

has_work(plan(Morning,_,_), Worker) :-
    works_at(Morning, Worker, _).
has_work(plan(_,Evening,_), Worker) :-
    works_at(Evening, Worker, _).
has_work(plan(_,_,Night), Worker) :-
    works_at(Night, Worker, _).

no_work(Plan, Worker) :-
    employee(Worker),
    \+ has_work(Plan, Worker).

double_work(Plan, Worker) :-
    employee(Worker),
    works_at(Plan, Shift1, Worker, Station1),
    works_at(Plan, Shift2, Worker, Station2),
    different_work(Shift1,Shift2,Station1,Station2).

different_work(Shift1,Shift2,_,_) :- Shift1 \= Shift2.
different_work(_,_,Station1,Station2) :- Station1 \= Station2.

plan(plan(Morning, Evening, Night)) :-
    findall(Workstation, (workstation(Workstation, _, _), not_idle_workstation(Workstation)), Workstations),
    findall(Employee, employee(Employee), Employees),
    plan_shift(morning, Workstations, Employees, Morning),
    plan_shift(evening, Workstations, Employees, Evening),
    plan_shift(night, Workstations, Employees, Night).

not_idle_workstation(Workstation) :-
    workstation_idle(Workstation, Shift),
    avoid_shift(_, Shift),
    !,
    fail.
not_idle_workstation(Workstation).

plan_shift(_, [], _, []).
plan_shift(Shift, [Workstation|RestWorkstations], Employees, [Workstation/AssignedEmployees|RestPlan]) :-
    assign_employees_to_workstation(Workstation, Shift, Employees, AssignedEmployees),
    plan_shift(Shift, RestWorkstations, Employees, RestPlan).

assign_employees_to_workstation(_, _, [], []).
assign_employees_to_workstation(Workstation, Shift, [Employee|RestEmployees], [Employee|RestAssigned]) :-
    \+ avoid_workstation(Employee, Workstation),
    \+ avoid_shift(Employee, Shift),
    workstation(Workstation, Min, Max),
    count_assigned_employees(Workstation, Shift, CurrentCount),
    CurrentCount < Max,
    assign_employees_to_workstation(Workstation, Shift, RestEmployees, RestAssigned).
assign_employees_to_workstation(Workstation, Shift, [Employee|RestEmployees], Assigned) :-
    assign_employees_to_workstation(Workstation, Shift, RestEmployees, Assigned).

count_assigned_employees(Workstation, Shift, Count) :-
    findall(Employee, (employee(Employee), assigned_to_workstation(Employee, Workstation, Shift)), Assigned),
    length(Assigned, Count).

assigned_to_workstation(Employee, Workstation, Shift) :-
    avoid_workstation(Employee, AvoidWorkstation),
    AvoidWorkstation \= Workstation,
    avoid_shift(Employee, AvoidShift),
    AvoidShift \= Shift.





