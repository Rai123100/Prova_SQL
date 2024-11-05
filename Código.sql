--CRIANDO O BANCO DE DADOS DA LOJA DE PELÚCIA

CREATE DATABASE Pelúcia

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--CRIANDO A TABELA DE CLIENTES

USE Pelúcia;

CREATE TABLE Cliente (
	ClienteID INT PRIMARY KEY,
	CPF VARCHAR (12) NOT NULL,
	NomeCliente VARCHAR (100) NOT NULL,
	Email VARCHAR (100) NOT NULL,
	Genero VARCHAR (20) NOT NULL,
	Endereco VARCHAR (100) NOT NULL,
	Telefone VARCHAR (50),
	Nascimento DATE
);

--INSERINDO DADOS NA TABELA DE CLIENTES

INSERT INTO Cliente (ClienteID, CPF, NomeCliente, Email, Genero, Endereco, Telefone, Nascimento)
VALUES 
	(1, '111111111-10', 'Rafaela Botelho', 'aluno103devt.rafaelabotelho@gmail.com', 'F', 'Rua Batata, 111, São Paulo - SP', '55 (11) 99999-9999', '2005-05-17'),
	(2, '111111111-20', 'Bruna Barboza', 'aluno103devt.brunabarboza@gmail.com', 'F', 'Rua Chiclete, 222, São Paulo - SP', '55 (11) 88888-8888', '2007-12-31'),
	(3, '111111111-30', 'Arthur Américo', 'aluno103devt.arthuramerico@gmail.com', 'M', 'Rua Queijinho, 333, Pindamonhangaba - SP', '55 (11) 77777-7777; 55 (11) 66666-6666', '2007-06-12'),
	(4, '111111111-40', 'Cleyton Matheus', 'aluno103devt.cleytonmatheus@gmail.com', 'M', 'Rua Judas Perdeu as Botas, 444, Catapimbas, - SP', '55 (11) 66666-6666', '2005-06-12');

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--CRIANDO A TABELA PRODUTOS

CREATE TABLE Produtos (
	ProdutoID INT PRIMARY KEY,
	NomeProduto VARCHAR(50) NOT NULL,
	Descricao VARCHAR(100),
	Preco FLOAT NOT NULL,
	Tamanho FLOAT
);

--INSERINDO DADOS NA TABELA DE PRODUTOS

INSERT INTO Produtos (ProdutoID, NomeProduto, Descricao, Preco, Tamanho)
VALUES
	(1, 'Ovelinha Bruna', '1.Fica em pé e sentada, 2.Braços e pernas articulados, 3.Enchimento Hipoalergênico', '160', '40'),
	(2, 'Carneiro Arthur', '1.Fica em pé e sentada, 2.Braços e pernas articulados, 3.Enchimento Hipoalergênico', '200', '60'),
	(3, 'Ovelha Rafaela', '1.Fica em pé e sentada, 2.Braços e pernas articulados, 3.Enchimento Hipoalergênico', '220', '30' ),
	(4, 'Carneiro Matheus', '1.Fica em pé e sentada, 2.Braços e pernas articulados, 3.Enchimento Hipoalergênico', '180', '50');

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--CRIANDO A TABELA VENDAS

CREATE TABLE Vendas (
	VendaID INT PRIMARY KEY,
	ClienteID INT,
	ProdutoID INT,
	Quantidade INT NOT NULL,
	DatadaVenda DATETIME NOT NULL,
	ValordaVenda FLOAT NOT NULL,
	FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID),
	FOREIGN KEY (ProdutoID) REFERENCES Produtos(ProdutoID),
);

--INSERINDO DADOS NA TABELA DE VENDAS

INSERT INTO Vendas (VendaID, ClienteID, ProdutoID, Quantidade, DatadaVenda, ValordaVenda)
VALUES 
	(1, 2, 1, 1, '2023-24-05', '160'),
	(2, 1, 3, 4, '2024-24-07', '880'),
	(3, 3, 4, 2, '2024-30-08', '360'),
	(4, 1, 4, 1, '2024-30-08', '180');


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--VIEWS

--UMA VIEW QUE RELACIONA O NUMERO DA VENDA COM O NOME DOS PRODUTO E DO CLIENTE

CREATE VIEW Nome_dos_Compradores
AS
SELECT
NomeCliente,
NomeProduto,
VendaID
FROM Vendas
INNER JOIN Cliente
ON Vendas.ClienteID = Cliente.ClienteID
INNER JOIN Produtos
ON Vendas.ProdutoID = Produtos.ProdutoID

SELECT *
FROM Nome_dos_Compradores

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Subqueries

--RETORNA ID DAS COMPRAS REALIZADAS POR HOMENS

SELECT
VendaID
FROM Vendas
WHERE ClienteID IN (SELECT ClienteID FROM Cliente WHERE Genero = 'M')

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--CTEs (Common Table Expressions)

--DIZ QUAL CLIENTE REALIZOU A COMPRA 

WITH Cliente_da_Venda
AS (
SELECT 
VendaID,
NomeCliente
FROM Vendas
INNER JOIN Cliente
ON Vendas.ClienteID = Cliente.ClienteID
)

SELECT *
FROM Cliente_da_Venda

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Window Functions

--MOSTRA QUANTAS VEZES CADA PRODUTO FOI VENDIDO

SELECT
DISTINCT ProdutoID,
COUNT(ProdutoID) OVER (PARTITION BY ProdutoID) AS 'Quantas vezes o produto foi comprado'
FROM Vendas

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Functions

--UMA FUNCTION QUE CALCULA A IDADE DE CADA CLIENTE COM BASE NA DATA DE NASCIMENTO

CREATE FUNCTION CalcularIdade (@dataNascimento DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @dataNascimento, GETDATE());
END;

--Uso da Função:

SELECT NomeCliente, dbo.CalcularIdade(Nascimento) AS Idade
FROM Cliente;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Loops

--RETORNA CLIENTES QUE NÃO FIZERAM COMPRAS NA LOJA NOS ULTIMOS 12 MESES

DECLARE @ClienteID INT;
DECLARE @Nome NVARCHAR(100);
DECLARE @contador INT = 1;
DECLARE @totalCliente INT;

-- Contar o total de pacientes sem consultas nos últimos 12 meses
SELECT @totalCliente = COUNT(*)
FROM Cliente
WHERE NOT EXISTS (
SELECT 1
FROM Vendas
WHERE Vendas.ClienteID = Cliente.ClienteID AND Vendas.DatadaVenda >= DATEADD(MONTH,-12, GETDATE())
);

WHILE @contador <= @totalCliente
BEGIN

SELECT
@ClienteID = ClienteID,
@Nome = NomeCliente
FROM (
SELECT Cliente.ClienteID, Cliente.NomeCliente,
ROW_NUMBER() OVER (ORDER BY Cliente.NomeCliente) AS RowNum
FROM Cliente
WHERE NOT EXISTS (
SELECT 1
FROM Vendas
WHERE Vendas.ClienteID = Cliente.ClienteID AND Vendas.DatadaVenda  >= DATEADD(MONTH, -12, GETDATE()) )) AS T
WHERE RowNum = @contador;

PRINT 'Clientes que não fizeram compras nos últimos 12 meses: ' + @Nome ;
SET @contador = @contador + 1;
END;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Procedures

--ESSA PROCEDURE TORNA POSSIVEL SABER O VALOR QUE CADA CLIENTE GASTOU NA LOJA, COM BASE NO ID DELE

IF EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE TYPE = 'P' AND NAME = 'ValorGasto')
BEGIN
DROP PROCEDURE ValorGasto
END
GO

CREATE PROCEDURE ValorGasto
@clienteid INT
AS
SELECT
DISTINCT NomeCliente,
SUM(ValordaVenda) OVER (PARTITION BY NomeCliente) AS 'Valor Gasto em Compras'
FROM Vendas
INNER JOIN Cliente
ON Vendas.ClienteID = Cliente.ClienteID
WHERE Vendas.ClienteID = @clienteid;
GO

EXEC ValorGasto 1



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Triggers

CREATE OR ALTER TRIGGER DeletarAlgumaVenda
ON Vendas
INSTEAD OF DELETE
AS
BEGIN
  IF EXISTS (SELECT 1 FROM Vendas WHERE VendaID IN (1, 2, 3, 4))
  BEGIN
    PRINT'A exclusão de dados desse campo é proibida!'
    RETURN
  END
END; 

DELETE FROM Vendas WHERE VendaID = 4


