USE helpdesk;

-- clients
INSERT INTO clients (name, email, company) VALUES
('Alice Morgan', 'alice@techcorp.com', 'TechCorp'),
('Bob Stevens', 'bob@netwave.io', 'NetWave'),
('Clara Hunt', 'clara@datasys.net', 'DataSys'),
('David Park', 'david@cloudzero.com', 'CloudZero'),
('Elena Russo', 'elena@softbridge.eu', 'SoftBridge'),
('Frank Meyer', 'frank@infraplus.de', 'InfraPlus'),
('Grace Kim', 'grace@apexsrv.com', 'ApexSrv'),
('Henry Walsh', 'henry@netwave.io', 'NetWave'),
('Irene Costa', 'irene@techcorp.com', 'TechCorp'),
('James Obi', 'james@datasys.net', 'DataSys');

-- categories
INSERT INTO categories (name) VALUES
('Network'),
('Server'),
('Database'),
('Access'),
('Hardware');

-- agents
INSERT INTO agents (name, level) VALUES
('Nina Petrova', 'L1'),
('Omar Hassan', 'L1'),
('Sara Lind', 'L2'),
('Tom Brecker', 'L2'),
('Yuki Tanaka', 'L3');

-- tickets
INSERT INTO tickets (title, status, priority, created_at, resolved_at, client_id, category_id, agent_id) VALUES
('Cannot connect to VPN', 'resolved', 'high', '2024-11-01 09:15:00', '2024-11-01 11:30:00', 1, 1, 1),
('MySQL replication lag', 'resolved', 'critical', '2024-11-02 10:00:00', '2024-11-02 14:45:00', 3, 3, 5),
('SSH access denied after password reset', 'resolved', 'high', '2024-11-03 08:30:00', '2024-11-03 09:50:00', 2, 4, 3),
('Server CPU 100% load', 'resolved', 'critical', '2024-11-04 14:00:00', '2024-11-04 16:20:00', 4, 2, 5),
('New user needs DB read access', 'closed', 'low', '2024-11-05 11:00:00', '2024-11-05 12:00:00', 5, 4, 2),
('Disk space alert on /var', 'resolved', 'medium', '2024-11-06 09:00:00', '2024-11-06 10:30:00', 6, 2, 3),
('Network packet loss to datacenter', 'in_progress', 'high', '2024-11-07 13:00:00', NULL, 7, 1, 4),
('Backup job failed overnight', 'open', 'high', '2024-11-08 07:45:00', NULL, 8, 2, NULL),
('GRANT privileges not applying', 'resolved', 'medium', '2024-11-09 10:30:00', '2024-11-09 13:00:00', 9, 3, 3),
('Switch port down in rack B', 'in_progress', 'critical', '2024-11-10 15:00:00', NULL, 10, 5, 4),
('Cannot login to admin panel', 'open', 'medium', '2024-11-11 09:00:00', NULL, 1, 4, NULL),
('Slow query on reports table', 'resolved', 'medium', '2024-11-12 11:00:00', '2024-11-12 15:30:00', 3, 3, 5),
('Firewall blocking internal traffic', 'resolved', 'high', '2024-11-13 08:00:00', '2024-11-13 10:00:00', 2, 1, 4),
('RAM upgrade needed on DB server', 'closed', 'low', '2024-11-14 14:00:00', '2024-11-15 09:00:00', 4, 5, 2),
('Cron job not executing', 'open', 'medium', '2024-11-15 16:00:00', NULL, 5, 2, NULL),
('Replication broken after failover', 'resolved', 'critical', '2024-11-16 02:00:00', '2024-11-16 05:30:00', 6, 3, 5),
('New server needs OS install', 'in_progress', 'low', '2024-11-17 10:00:00', NULL, 7, 2, 3),
('User locked out of SSH key auth', 'resolved', 'high', '2024-11-18 09:30:00', '2024-11-18 10:15:00', 8, 4, 1),
('Database connection pool exhausted', 'resolved', 'critical', '2024-11-19 13:00:00', '2024-11-19 14:30:00', 9, 3, 5),
('NIC not detected after reboot', 'open', 'high', '2024-11-20 11:00:00', NULL, 10, 5, NULL);