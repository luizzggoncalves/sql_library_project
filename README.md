# Sistema de Gerenciamento de Biblioteca — SQL

## Visão Geral do Projeto

**Título**: Sistema de Gerenciamento de Biblioteca  
**Banco de Dados**: `library_db`

Este projeto demonstra a implementação de um Sistema de Gerenciamento de Biblioteca usando SQL. Inclui criação e gerenciamento de tabelas, operações CRUD e consultas SQL avançadas. O objetivo é demonstrar habilidades em design de banco de dados, manipulação e consultas.

---

## Objetivos

1. **Configurar o Banco de Dados**: Criar e popular o banco com tabelas para filiais, funcionários, membros, livros, status de empréstimo e status de devolução.
2. **Operações CRUD**: Executar operações de Create, Read, Update e Delete nos dados.
3. **CTAS (Create Table As Select)**: Utilizar CTAS para criar novas tabelas baseadas em resultados de consultas.
4. **Consultas SQL Avançadas**: Desenvolver consultas complexas para analisar e recuperar dados específicos.

---

## Estrutura do Projeto

### 1. Configuração do Banco de Dados

- **Criação do Banco**: Criado um banco de dados chamado `library_db`.
- **Criação das Tabelas**: Criadas tabelas para filiais, funcionários, membros, livros, status de empréstimo e status de devolução, cada uma com suas colunas e relacionamentos.

> **Observação:** A tabela `branch` foi inicialmente criada com um erro de digitação (`brach`) e renomeada posteriormente com `ALTER TABLE brach RENAME TO branch;`. As chaves estrangeiras foram adicionadas via `ALTER TABLE` após a criação de todas as tabelas.

```sql
-- Tabela de filiais
DROP TABLE IF EXISTS branch;
CREATE TABLE branch (
    branch_id      VARCHAR(10) PRIMARY KEY,
    manager_id     VARCHAR(10),
    branch_address VARCHAR(55),
    contact_no     VARCHAR(10)
);

-- Tabela de funcionários
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    emp_id    VARCHAR(10) PRIMARY KEY,
    emp_name  VARCHAR(25),
    position  VARCHAR(15),
    salary    FLOAT,
    branch_id VARCHAR(10) -- FK
);

-- Tabela de livros
DROP TABLE IF EXISTS books;
CREATE TABLE books (
    isbn         VARCHAR(20) PRIMARY KEY,
    book_title   VARCHAR(75),
    category     VARCHAR(25),
    rental_price FLOAT,
    status       VARCHAR(15),
    author       VARCHAR(35),
    publisher    VARCHAR(55)
);

-- Tabela de membros
DROP TABLE IF EXISTS members;
CREATE TABLE members (
    member_id      VARCHAR(10) PRIMARY KEY,
    member_name    VARCHAR(55),
    member_address VARCHAR(75),
    reg_date       DATE
);

-- Tabela de status de empréstimo
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status (
    issued_id        VARCHAR(10) PRIMARY KEY,
    issued_member_id VARCHAR(30),  -- FK
    issued_book_name VARCHAR(80),
    issued_date      DATE,
    issued_book_isbn VARCHAR(50),  -- FK
    issued_emp_id    VARCHAR(10)   -- FK
);

-- Tabela de status de devolução
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status (
    return_id        VARCHAR(10) PRIMARY KEY,
    issued_id        VARCHAR(30),
    return_book_name VARCHAR(80),
    return_date      DATE,
    return_book_isbn VARCHAR(50)
);
```

**Chaves Estrangeiras (adicionadas após a criação das tabelas):**

```sql
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id) REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id) REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id);
```

---

### 2. Operações CRUD

**Tarefa 1: Inserir um Novo Livro**

```sql
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books;
```

**Tarefa 2: Atualizar o Endereço de um Membro**

```sql
UPDATE members
SET member_address = '897 Winners Circle'
WHERE member_id = 'C102';
```

**Tarefa 3: Deletar um Registro da Tabela de Empréstimos**

Objetivo: Deletar o registro com `issued_id = 'IS121'` da tabela `issued_status`.

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';

SELECT issued_id
FROM issued_status
ORDER BY 1 DESC;
```

**Tarefa 4: Recuperar Todos os Livros Emitidos por um Funcionário Específico**

Objetivo: Selecionar todos os livros emitidos pelo funcionário com `emp_id = 'E101'`.

```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';
```

**Tarefa 5: Listar Membros que Emitiram Mais de Um Livro**

Objetivo: Usar `GROUP BY` para encontrar membros que emitiram mais de um livro.

```sql
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1;
```

---

### 3. CTAS (Create Table As Select)

**Tarefa 6: Criar Tabela Resumo — Livros e Total de Empréstimos**

```sql
CREATE TABLE book_cnts AS
SELECT
    b.isbn,
    b.book_title,
    COUNT(ist.issued_id) AS no_issued
FROM books AS b
JOIN issued_status AS ist
    ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;

SELECT * FROM book_cnts;
```

---

### 4. Análise de Dados

**Tarefa 7: Recuperar Todos os Livros de uma Categoria Específica**

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

**Tarefa 8: Calcular a Receita Total de Aluguel por Categoria**

```sql
SELECT
    category,
    SUM(rental_price) AS total_rental_price,
    COUNT(*)
FROM books
GROUP BY category;
```

Baseado apenas nos livros efetivamente emitidos:

```sql
SELECT
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM issued_status AS ist
JOIN books AS b
    ON b.isbn = ist.issued_book_isbn
GROUP BY 1;
```

**Tarefa 9: Listar Membros Registrados nos Últimos 180 Dias**

```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

**Tarefa 10: Listar Funcionários com o Nome do Gerente e Detalhes da Filial**

```sql
SELECT
    e1.*,
    b.branch_id,
    b.manager_id,
    e2.emp_name AS manager
FROM employees AS e1
JOIN branch AS b
    ON b.branch_id = e1.branch_id
JOIN employees AS e2
    ON b.manager_id = e2.emp_id;
```

**Tarefa 11: Criar Tabela de Livros com Preço de Aluguel Acima de um Limite**

```sql
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
```

**Tarefa 12: Recuperar a Lista de Livros Ainda Não Devolvidos**

```sql
SELECT * FROM issued_status AS ist
LEFT JOIN return_status AS rs
    ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```

---

## Como Executar

1. Crie um banco de dados PostgreSQL chamado `library_db`.
2. Execute o arquivo `schemas.sql` para criar todas as tabelas e constraints.
3. Popule as tabelas com os dados via scripts de INSERT.
4. Execute o arquivo `queries.sql` para rodar todas as tarefas do projeto.

---

## Autor

Projeto desenvolvido como exercício intermediário de SQL, cobrindo design de banco de dados, operações CRUD, CTAS e consultas analíticas usando PostgreSQL.
