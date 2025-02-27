-- Employee Productivity Analysis:
--- Identify employees with the highest total hours worked and least absenteeism.
WITH TotalHours AS (
    SELECT 
        employeeid, 
        SUM(total_hours) AS total_hours_worked
    FROM tech_sphere.attendance_records
    GROUP BY employeeid
),
Absenteeism AS (
    SELECT 
        employeeid, 
        SUM(days_absent) AS total_days_absent 
    FROM tech_sphere.attendance_records
    WHERE days_absent > 0  
    GROUP BY employeeid
)

SELECT 
    e.employeeid, 
    e.employeename, 
    COALESCE(th.total_hours_worked, 0) AS total_hours_worked, 
    COALESCE(a.total_days_absent, 0) AS total_days_absent, 
    (COALESCE(th.total_hours_worked, 0) / (1 + COALESCE(a.total_days_absent, 0))) AS Productivity_score
FROM tech_sphere.employee_details e
LEFT JOIN TotalHours th ON e.employeeid = th.employeeid
LEFT JOIN Absenteeism a ON e.employeeid = a.employeeid
ORDER BY Productivity_score DESC;
---  Departmental Training Impact: Analyze how training programs improve departmental performance
select e.department_id, avg(case when e.performance_score = 'Excellent' then 5 when e.performance_score = 'Good' then 4 when e.performance_score = 'Average' then 3 else 0 END) as avg_performance_score_before_training, avg(t.feedback_score) as avg_performance_score_after_training from tech_sphere.employee_details e join tech_sphere.training_programs t on e.employeeid = t.employeeid group by e.department_id;
--- Attendance Consistency:- Measure attendance trends and identify departments with significant deviations.
select e.department_id, avg(a.days_present) as average_days_present,avg(a.days_absent) as average_days_absent, stddev(a.days_present) as deviations_days_present from tech_sphere.employee_details e join tech_sphere.attendance_records a on e.employeeid = a.employeeid group by department_id;
--- Project Budget Efficiency- Evaluate the efficiency of project budgets by calculating costs per hour worked.
select project_name, sum(budget) as total_budget,sum(hours_worked) as total_hours_worked,(sum(budget) / sum(hours_worked)) as average_cost_per_hour from tech_sphere.project_assignments group by project_name;
--- Training and Project Success Correlation:- Link training technologies with project milestones to assess the real-world impact of training.
SELECT 
    t.technologies_covered, 
    COUNT(*) AS total_milestones_achieved
FROM tech_sphere.training_programs t
JOIN tech_sphere.project_assignments p 
    ON LOWER(COALESCE(p.technologies_used, '')) LIKE CONCAT('%', LOWER(COALESCE(t.technologies_covered, '')), '%')
GROUP BY t.technologies_covered;
--- High-Impact Employees:- Identify employees who significantly contribute to high-budget projects while maintaining excellent performance scores.
select e.employeeid, e.employeename, p.project_name, p.budget, e.performance_score from tech_sphere.employee_details e join tech_sphere.project_assignments p on e.employeeid = p.employeeid where p.budget > 300000 and e.performance_score="Excellent" order by p.budget desc,e.performance_score;

