USE [master]
GO
/****** Object:  Database [Dating Service 2.0 ]    Script Date: 18.01.2025 1:49:21 ******/
CREATE DATABASE [Dating Service 2.0 ]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Dating Service 2.0', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Dating Service 2.0 .mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Dating Service 2.0 _log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Dating Service 2.0 _log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [Dating Service 2.0 ] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Dating Service 2.0 ].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Dating Service 2.0 ] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET ARITHABORT OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Dating Service 2.0 ] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Dating Service 2.0 ] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Dating Service 2.0 ] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Dating Service 2.0 ] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET RECOVERY FULL 
GO
ALTER DATABASE [Dating Service 2.0 ] SET  MULTI_USER 
GO
ALTER DATABASE [Dating Service 2.0 ] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Dating Service 2.0 ] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Dating Service 2.0 ] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Dating Service 2.0 ] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Dating Service 2.0 ] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Dating Service 2.0 ] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'Dating Service 2.0 ', N'ON'
GO
ALTER DATABASE [Dating Service 2.0 ] SET QUERY_STORE = ON
GO
ALTER DATABASE [Dating Service 2.0 ] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [Dating Service 2.0 ]
GO
/****** Object:  UserDefinedFunction [dbo].[CountOppositeGenderClients]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CountOppositeGenderClients](@Client_ID int)
RETURNS @result TABLE (
    Client_ID integer,
    OppositeGenderClientsCount integer
)
AS
BEGIN
    DECLARE @Client_Gender char(1), @Client_Age int;
    SELECT @Client_Gender = Gender, @Client_Age = Age FROM Clients WHERE Client_ID = @Client_ID;

    INSERT INTO @result (Client_ID, OppositeGenderClientsCount)
    SELECT @Client_ID, COUNT(*)
    FROM Clients
    WHERE Gender != @Client_Gender AND Age = @Client_Age;
    RETURN;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[CountOrdersAndClientsForWorker]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CountOrdersAndClientsForWorker](@Worker_ID INT)
RETURNS @WorkerStats TABLE (
    Worker_ID INT,
    Num_Orders INT,
    Num_Clients INT
)
AS
BEGIN
    INSERT INTO @WorkerStats
    SELECT 
        w.Worker_ID,
        COUNT(DISTINCT d.Order_ID) AS Num_Orders,
        COUNT(DISTINCT c.Client_ID) AS Num_Clients
    FROM 
        Workers w
        INNER JOIN Dates d ON w.Order_ID = d.Order_ID
		JOIN Matches M ON m.Match_ID = d.Match_ID
		JOIN Clients C ON C.Client_ID = M.Client_1_ID or C.Client_ID = M.Client_2_ID
    WHERE 
        w.Worker_ID = @Worker_ID
    GROUP BY 
        w.Worker_ID

    RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetMostInteractionsPartner]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetMostInteractionsPartner](@Partner_ID int)
RETURNS @result TABLE (
    Client_Name varchar(255),
    MostInteractionsPartner_Name varchar(255)
)
AS
BEGIN
    DECLARE @MostInteractionsPartner_Name varchar(255);

    SELECT TOP 1 @MostInteractionsPartner_Name = Name
    FROM Clients
    WHERE Client_ID != @Partner_ID
    ORDER BY (
        SELECT COUNT(*)
        FROM Interactions
        WHERE (Sender_ID = @Partner_ID AND Receiver_ID = Clients.Client_ID)
            OR (Receiver_ID = @Partner_ID AND Sender_ID = Clients.Client_ID)
    ) DESC;

    INSERT INTO @result (Client_Name, MostInteractionsPartner_Name)
    SELECT TOP 1 Name, @MostInteractionsPartner_Name
    FROM Clients
    WHERE Client_ID = @Partner_ID;

    RETURN;
END;
GO
/****** Object:  Table [dbo].[Interactions]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Interactions](
	[Interaction_ID] [int] IDENTITY(1,1) NOT NULL,
	[Sender_ID] [int] NULL,
	[Receiver_ID] [int] NULL,
	[Interaction_Type] [varchar](100) NULL,
	[Interaction_Date] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Interaction_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Messages]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Messages](
	[Message_ID] [int] NULL,
	[Message_Text] [varchar](200) NULL,
	[Status] [varchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ClientInteractions]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ClientInteractions] AS
SELECT 
    i.Sender_ID,
    i.Receiver_ID,
    COUNT(DISTINCT m.Message_ID) AS Num_Messages,
    SUM(CASE WHEN i.Interaction_Type = 'Like' THEN 1 ELSE 0 END) AS Num_Likes,
    SUM(CASE WHEN i.Interaction_Type = 'Comment' THEN 1 ELSE 0 END) AS Num_Comments,
    COUNT(DISTINCT CASE WHEN i.Interaction_Type = 'Meeting' THEN i.Interaction_ID ELSE NULL END) AS Num_Meetings
FROM 
    Interactions i
    LEFT JOIN Messages m ON i.Interaction_ID = m.Message_ID
GROUP BY 
    i.Sender_ID,
    i.Receiver_ID
GO
/****** Object:  Table [dbo].[Clients]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Clients](
	[Client_ID] [int] IDENTITY(1,1) NOT NULL,
	[Gender] [varchar](100) NULL,
	[Name] [varchar](100) NULL,
	[City_Region] [varchar](100) NULL,
	[Age] [int] NULL,
	[Matters] [int] NULL,
	[Interests_Hobbies] [varchar](150) NULL,
PRIMARY KEY CLUSTERED 
(
	[Client_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Matches]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Matches](
	[Match_ID] [int] IDENTITY(1,1) NOT NULL,
	[Client_1_ID] [int] NULL,
	[Client_2_ID] [int] NULL,
	[Common_Interests] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[Match_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Clients_Info]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Clients_Info] AS
SELECT 
    c1.Name AS Client_1_Name,
    c2.Name AS Client_2_Name,
    m.Common_Interests AS Common_Interests,
    c1.City_Region AS City_1,
    c2.City_Region AS City_2,
    c1.Age AS Age_1,
    c2.Age AS Age_2
FROM 
    Clients c1
    JOIN Clients c2 ON c1.Client_ID <> c2.Client_ID
    JOIN Matches m ON c1.Client_ID = m.Client_1_ID AND c2.Client_ID = m.Client_2_ID
GROUP BY 
    c1.Name, c2.Name, m.Common_Interests, c1.City_Region, c2.City_Region, c1.Age, c2.Age;
GO
/****** Object:  Table [dbo].[Black_List]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Black_List](
	[Ban_ID] [int] NULL,
	[Ban_Date] [datetime] NULL,
	[Reason] [varchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ClientBlackListStatistics]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ClientBlackListStatistics] AS
SELECT 
    c.Client_ID,
    COUNT(b.Ban_ID) AS Total_Bans,
    b.Reason
FROM 
    Clients c
    JOIN Interactions i ON c.Client_ID = i.Sender_ID
    JOIN Black_List b ON i.Interaction_ID = b.Ban_ID
GROUP BY 
    c.Client_ID,
    b.Reason
GO
/****** Object:  Table [dbo].[Comments]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Comments](
	[Comment_ID] [int] NULL,
	[Comment_Text] [varchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dates]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dates](
	[Order_ID] [int] IDENTITY(1,1) NOT NULL,
	[Status] [varchar](100) NULL,
	[Meeting_Date] [datetime] NULL,
	[Match_ID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Order_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Notifications]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notifications](
	[Notification_ID] [int] IDENTITY(1,1) NOT NULL,
	[Client_ID] [int] NULL,
	[Notification_Text] [varchar](100) NULL,
	[Viewed] [varchar](100) NULL,
	[Notification_Date] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Notification_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Workers]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Workers](
	[Worker_ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NULL,
	[Order_ID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Worker_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Black_List]  WITH CHECK ADD FOREIGN KEY([Ban_ID])
REFERENCES [dbo].[Interactions] ([Interaction_ID])
GO
ALTER TABLE [dbo].[Comments]  WITH CHECK ADD FOREIGN KEY([Comment_ID])
REFERENCES [dbo].[Interactions] ([Interaction_ID])
GO
ALTER TABLE [dbo].[Dates]  WITH CHECK ADD FOREIGN KEY([Match_ID])
REFERENCES [dbo].[Matches] ([Match_ID])
GO
ALTER TABLE [dbo].[Interactions]  WITH CHECK ADD FOREIGN KEY([Receiver_ID])
REFERENCES [dbo].[Clients] ([Client_ID])
GO
ALTER TABLE [dbo].[Interactions]  WITH CHECK ADD FOREIGN KEY([Sender_ID])
REFERENCES [dbo].[Clients] ([Client_ID])
GO
ALTER TABLE [dbo].[Matches]  WITH CHECK ADD FOREIGN KEY([Client_1_ID])
REFERENCES [dbo].[Clients] ([Client_ID])
GO
ALTER TABLE [dbo].[Matches]  WITH CHECK ADD FOREIGN KEY([Client_2_ID])
REFERENCES [dbo].[Clients] ([Client_ID])
GO
ALTER TABLE [dbo].[Messages]  WITH CHECK ADD FOREIGN KEY([Message_ID])
REFERENCES [dbo].[Interactions] ([Interaction_ID])
GO
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD FOREIGN KEY([Client_ID])
REFERENCES [dbo].[Clients] ([Client_ID])
GO
ALTER TABLE [dbo].[Workers]  WITH CHECK ADD FOREIGN KEY([Order_ID])
REFERENCES [dbo].[Dates] ([Order_ID])
GO
/****** Object:  StoredProcedure [dbo].[AddClient]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddClient]
    @Gender varchar(100),
    @Name varchar(100),
    @City_Region varchar(100),
    @Age integer,
    @Hobby_Interests varchar(100),
    @Matters integer
AS
BEGIN
    INSERT INTO Clients (Gender, Name, City_Region, Age, Interests_Hobbies, Matters)
    VALUES (@Gender, @Name, @City_Region, @Age, @Hobby_Interests, @Matters)
END
GO
/****** Object:  StoredProcedure [dbo].[GetBlackListForClient]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetBlackListForClient](@ClientID INT)
AS
BEGIN
    SELECT I.Receiver_ID, B.Reason
    FROM Interactions I
    JOIN Black_List B ON I.Interaction_ID = B.Ban_ID
    WHERE I.Sender_ID = @ClientID
END
GO
/****** Object:  StoredProcedure [dbo].[GetMessages]    Script Date: 18.01.2025 1:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetMessages]
    @ClientID INT
AS
BEGIN
    SELECT *
    FROM Messages 
	JOIN Interactions I ON I.Interaction_ID = Messages.Message_ID
    WHERE I.Receiver_ID = @ClientID AND Interaction_Type = 'Message'
END
GO
USE [master]
GO
ALTER DATABASE [Dating Service 2.0 ] SET  READ_WRITE 
GO
