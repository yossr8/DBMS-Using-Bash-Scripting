
# **Bash Database Management System**

This project is a simple **Database Management System (DBMS)** implemented in Bash. It provides a basic interface for managing databases and tables using shell scripting, without relying on external database systems. The project demonstrates the core functionalities of a DBMS, including creating, listing, and removing databases and tables, as well as inserting data into tables with metadata constraints.

---

## **Features**

### **Database Operations**
- **Create Database**: Allows users to create a new database.
- **List Databases**: Displays all existing databases.
- **Connect to Database**: Navigates into a selected database for table operations.
- **Drop Database**: Deletes an existing database with confirmation.

### **Table Operations**
- **Create Table**: Allows the creation of tables with column definitions and constraints.
- **List Tables**: Displays all tables within the connected database.
- **Remove Table**: Deletes a specific table with user confirmation.

### **Data Operations**
- **Insert into Table**: Inserts rows into a table while ensuring compliance with column definitions and constraints.
- **Metadata Management**: Each table has:
  - A **data file** that stores column names and data rows.
  - A **metadata file** that holds information about column definitions and constraints.

---

## **How to Use**

1. Clone the repository:
   ```bash
   git clone https://github.com/nada19885/DBMS-ITI.git
   cd bash-database-management-system
   ```

2. Run the script:
   ```bash
   ./database_manager.sh
   ```

3. Follow the menu options to:
   - Create and manage databases.
   - Define tables with column types and constraints.
   - Insert and manage data within tables.

---

## **Example Workflow**

1. **Create a Database**:
   - Choose the "Create Database" option and specify the database name.

2. **Connect to the Database**:
   - Select "Connect to Database" and choose the database to manage.

3. **Create a Table**:
   - Define table columns in the format `column_name(type)[constraint]` (e.g., `id(int) PK`).

4. **Insert Data**:
   - Input values for each column following the defined structure.

5. **Manage Tables**:
   - List or remove tables as needed.

---

## **Constraints and Validations**
- Supports basic column types: `int`, `string`.
- Allows constraints like `PK` (Primary Key) and `NOT NULL`.
- Ensures data integrity by validating input against column definitions.

---

## **Future Enhancements**
- Add support for more data types and constraints (e.g., `DEFAULT`, `UNIQUE`).
- Implement advanced query operations like filtering and sorting.
- Introduce better error handling and logging.



--- 

