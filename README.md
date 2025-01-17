# database-project
This project is a relational database designed to manage a matchmaking and interaction system. The database includes tables for clients, matches, dates, workers, interactions, messages, blacklists, notifications, and comments. It also includes triggers, functions, procedures, and views to support the system's functionality.
![image](https://github.com/user-attachments/assets/5953063b-50e9-4f72-85f0-cddc9bdfc7b6)


## Tables
### Clients

Stores information about clients, including their gender, name, city/region, age, and interests.
`Client_ID` is the primary key, auto-incremented.
`Matters` and `Hobby_Interests` store additional client preferences.

### Matches

Tracks matches between clients based on common interests.
`Match_ID` is the primary key, auto-incremented.
`Client_1_ID` and `Client_2_ID` are foreign keys referencing the `Clients` table.

### Dates

Manages scheduled dates between matched clients.
`Order_ID` is the primary key, auto-incremented.
`Match_ID` is a foreign key referencing the `Matches` table.

### Workers

Stores information about workers who manage the dates.
`Worker_ID` is the primary key, auto-incremented.
`Order_ID` is a foreign key referencing the `Dates` table.

### Interactions

Tracks interactions between clients, such as messages or comments.
`Interaction_ID` is the primary key, auto-incremented.
`Sender_ID` and `Receiver_ID` are foreign keys referencing the `Clients` table.

### Messages

Stores message details sent between clients.
`Message_ID` is a foreign key referencing the `Interactions` table.

### Black_List

Manages banned interactions or clients.
`Ban_ID` is a foreign key referencing the `Interactions` table.

### Notifications

Tracks notifications sent to clients.
`Notification_ID` is the primary key, auto-incremented.
`Client_ID` is a foreign key referencing the `Clients` table.

### Comments

Stores comments made by clients.
Comment_ID is a foreign key referencing the Interactions table.

## Functions
### 1. CountOrdersAndClientsForWorker
**Description**: This function calculates the number of orders (dates) and unique clients associated with a specific worker.

**Logic**: Joins the `Workers`, `Dates`, `Matches`, and `Clients` tables to count distinct orders and clients. Filters results based on the provided @Worker_ID.
### 2. CountOppositeGenderClients
**Description**: This function calculates the number of clients of the opposite gender who are the same age as the specified client.

**Logic**: Retrieves the gender and age of the specified client. Counts the number of clients in the `Clients` table who match the opposite gender and the same age.
### 3. GetMostInteractionsPartner
**Description**: This function identifies the client with whom the specified client has had the most interactions (either as a sender or receiver).

**Logic**: Counts interactions (both sent and received) between the specified client and other clients. Returns the name of the client with the highest interaction count.

## Procedures
### 1. AddClient
**Description**: This procedure adds a new client to the `Clients` table.

**Logic**: Inserts a new record into the `Clients` table with the provided details.
### 2. GetMessages
**Description**: This procedure retrieves all messages received by a specific client.

**Logic**: Joins the Messages and Interactions tables to fetch messages where the client is the receiver. Filters messages based on the interaction type being 'Message'.
### 3. DeleteBlackList
**Description**: This procedure removes a record from the Black_List table based on the provided Ban_ID.

**Logic**: Deletes the record from the `Black_List` table where `Ban_ID` matches the provided value.
## Triggers
### 1. DeleteInteractionsAndMessages
**Description**: This trigger deletes all interactions and related messages/comments between two clients when a "Ban" interaction is inserted.

**Logic**: Captures the `Sender_ID`, `Receiver_ID`, `Interaction_ID`, and `Interaction_Type` from the inserted row.If the interaction type is "Ban," it deletes all interactions (except the ban itself) and related messages/comments between the two clients.

**Tables Affected**: `Interactions`, `Messages`, `Comments`.
### 2. Check_Age
**Description**: This trigger ensures that clients are at least 18 years old

**Logic**: Checks the Age column in the inserted table during INSERT or UPDATE operations. Raises an error and rolls back the transaction if the age is less than 18.

**Tables Affected**: `Clients`.
### 3. DeleteMessagesAndCommentsWhenBan
**Description**: This trigger deletes messages and comments associated with a banned interaction.

**Logic**: Captures the `Interaction_ID` of the inserted row. Deletes related messages and comments from the Messages and Comments tables if the interaction is linked to a ban in the `Black_List` table.

**Tables Affected**: `Messages`, `Comments`.
### 4. NotifyClientWithUnreadMessages
**Description**: This trigger notifies a client if they have 2 or more unread messages.

**Logic**: Captures the `Receiver_ID` from the inserted interaction. Counts the number of unread messages for the recipient. If the count is 2 or more, inserts a notification into the `Notifications` table.

**Tables Affected**: Notifications.
## Views
### 1. ClientInteractions
**Description**: This view provides a summary of interactions between clients, including the number of messages, likes, comments, and meetings.

**Columns**:
`Sender_ID`: The ID of the client who initiated the interaction.
`Receiver_ID`: The ID of the client who received the interaction.
`Num_Messages`: The total number of messages exchanged between the two clients.
`Num_Likes`: The total number of "Like" interactions between the two clients.
`Num_Comments`: The total number of "Comment" interactions between the two clients.
`Num_Meetings`: The total number of "Meeting" interactions between the two clients.

**Logic**:Joins the `Interactions` and `Messages` tables. Groups by `Sender_ID` and `Receiver_ID` to calculate the number of messages, likes, comments, and meetings.
### 2. ClientBlackListStatistics
**Description**: This view provides statistics on clients who have been banned, including the total number of bans and the reasons for those bans.

**Columns**:
`Client_ID`: The ID of the client who was banned.
`Total_Bans`: The total number of bans issued to the client.
`Reason`: The reason for the ban(s).

**Logic**: Joins the `Clients`, `Interactions`, and `Black_List` tables. Groups by Client_ID and Reason to calculate the total number of bans and their reasons.
