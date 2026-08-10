-- ================================================
-- All tickets with client, category, and agent
-- INNER JOIN: clients and categories are required.
-- LEFT JOIN: agent may be NULL (ticket not yet assigned).
-- ================================================
SELECT
    t.id           AS 'ID',
    t.title        AS 'Ticket title',
    t.status       AS 'Status',
    t.priority     AS 'Priority',
    t.created_at   AS 'Created at',
    t.resolved_at  AS 'Resolved at',
    c.name         AS 'Client',
    cat.name       AS 'Category',
    a.name         AS 'Agent'
FROM tickets t
INNER JOIN clients c   ON t.client_id   = c.id
INNER JOIN categories cat ON t.category_id = cat.id
LEFT  JOIN agents a    ON t.agent_id    = a.id
ORDER BY t.created_at;

-- ================================================
-- Unassigned tickets (no agent allocated yet)
-- LEFT JOIN agents: agent_id may be NULL.
-- WHERE agent_id IS NULL: filters only unassigned tickets.
-- ================================================
SELECT
    t.id           AS 'ID',
    t.title        AS 'Ticket title',
    t.status       AS 'Status',
    t.priority     AS 'Priority',
    t.created_at   AS 'Created at',
    t.resolved_at  AS 'Resolved at',
    c.name         AS 'Client',
    cat.name       AS 'Category',
    a.name         AS 'Agent'
FROM tickets t
INNER JOIN clients c   ON t.client_id   = c.id
INNER JOIN categories cat ON t.category_id = cat.id
LEFT JOIN agents a    ON t.agent_id    = a.id
WHERE t.agent_id IS NULL
ORDER BY t.created_at;

-- ================================================
-- Ticket count by category
-- LEFT JOIN: includes categories with no tickets.
-- GROUP BY: aggregates tickets per category.
-- ORDER BY COUNT DESC: busiest categories first.
--          cat.name: alphabetical tiebreaker.
-- ================================================
SELECT
    cat.name      AS 'Category',
    COUNT(t.id)   AS 'Quantity'
FROM tickets t
LEFT JOIN categories cat ON t.category_id = cat.id
GROUP BY t.category_id
ORDER BY COUNT(t.id) DESC, cat.name;

-- ================================================
-- Average ticket resolution time by priority
-- WHERE resolved_at IS NOT NULL: excludes open tickets.
-- AVG + TIMESTAMPDIFF: calculates mean resolution time in minutes.
-- ROUND(..., 0): rounds to whole minutes.
-- ORDER BY DESC: slowest priority first.
-- ================================================
SELECT
    priority,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, created_at, resolved_at)), 0) AS 'Average resolution time (min)'
FROM tickets
WHERE resolved_at IS NOT NULL
GROUP BY priority
ORDER BY AVG(TIMESTAMPDIFF(MINUTE, created_at, resolved_at)) DESC;

-- ================================================
-- Clients with at least one critical ticket
-- Subquery: returns client_id list from tickets where priority = 'critical'.
-- WHERE IN: filters clients table by that list.
-- ================================================
SELECT name AS 'Critical clients'
FROM clients
WHERE id IN (
    SELECT client_id FROM tickets
    WHERE priority = 'critical'
)
ORDER BY name;

-- ================================================
-- Open and in-progress tickets by priority
-- WHERE IN: filters by ticket.
-- ORDER BY status, priority: groups by status first,
--          then sorts by priority within each group.
-- ================================================
SELECT
    t.id           AS 'ID',
    t.title        AS 'Ticket title',
    t.status       AS 'Status',
    t.priority     AS 'Priority',
    t.created_at   AS 'Created at',
    c.name         AS 'Client',
    cat.name       AS 'Category',
    a.name         AS 'Agent'
FROM tickets t
INNER JOIN clients c      ON t.client_id   = c.id
INNER JOIN categories cat ON t.category_id = cat.id
LEFT  JOIN agents a       ON t.agent_id    = a.id
WHERE t.status IN ('open', 'in_progress')
ORDER BY t.status, t.priority;