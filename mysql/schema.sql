-- ===========================================
-- Helpdesk Database Schema
-- Run this file first, before seed.sql
-- ===========================================

CREATE DATABASE IF NOT EXISTS helpdesk;
USE helpdesk;

-- Customers / System Users
CREATE TABLE IF NOT EXISTS clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    company VARCHAR(100)
);

-- Inquiry Categories
CREATE TABLE IF NOT EXISTS categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Support Agents
CREATE TABLE IF NOT EXISTS agents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    level ENUM('L1', 'L2', 'L3') NOT NULL
);

-- Tickets
CREATE TABLE IF NOT EXISTS tickets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    status ENUM('open', 'in_progress', 'resolved', 'closed') NOT NULL DEFAULT 'open',
    priority ENUM('low', 'medium', 'high', 'critical') NOT NULL,
    created_at DATETIME NOT NULL DEFAULT NOW(),
    resolved_at DATETIME,
    client_id INT NOT NULL,
    category_id INT NOT NULL,
    agent_id INT,
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (agent_id) REFERENCES agents(id)
);
