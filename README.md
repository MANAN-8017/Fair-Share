# FairShare

**FairShare** is a mobile expense-sharing application built with **Flutter and Dart** that helps individuals and groups manage shared expenses, split bills, track debts, and settle outstanding balances.

The application is designed for situations such as **roommates sharing rent and utilities, friends travelling together, group outings, college events, and other shared expenses** where multiple people need to keep track of who paid, who owes money, and how much each person should contribute.

FairShare aims to make expense management simple by automatically calculating individual shares, maintaining transaction history, and simplifying debts between group members.

---

## Features

### Core Features

#### Secure Authentication

Users can create accounts and securely log in to FairShare.

* User registration
* Login/logout
* User profile
* Authentication and account management

#### Groups

Users can create and manage groups for different activities.

Examples:

* Trip with friends
* College group
* Roommates
* Family expenses
* Events

Users can add or join members within groups and manage expenses separately for each group.

#### Expense Management

Users can record shared expenses by specifying:

* Expense title
* Amount
* Paid by
* Group
* Participants
* Date
* Category
* Notes

FairShare automatically calculates how much each participant owes.

#### Multiple Split Methods

FairShare supports multiple ways of splitting an expense:

**Equal Split**

The expense is divided equally between selected members.

```text
Total: ₹1,000
Members: 4

Each member: ₹250
```

**Percentage Split**

Each member contributes a specified percentage.

```text
Member A → 50%
Member B → 30%
Member C → 20%
```

**Exact Amount Split**

Each member can be assigned a specific amount.

```text
Member A → ₹500
Member B → ₹300
Member C → ₹200
```

**Item-wise Split**

Individual items can be assigned to specific members.

```text
Pizza      → A, B
Drinks     → B
Dessert    → A, C
```

**Exclude Member**

Specific members can be excluded from an expense.

#### Settle Up

Members can record payments made to settle outstanding balances.

FairShare keeps track of:

* Amount owed
* Amount to receive
* Settled transactions
* Remaining balances

#### Debt Simplification

FairShare can simplify multiple outstanding debts into fewer transactions.

For example:

```text
Before:

A → B : ₹500
B → C : ₹300
A → C : ₹200

After simplification:

A → B : ₹200
A → C : ₹500
```

This reduces unnecessary transactions while preserving the correct net balances.

#### Expense History

Users can view previous expenses and transactions.

Expenses can be reviewed by:

* Group
* Date
* Member
* Category
* Amount

#### Search and Filters

Users can quickly find specific transactions using filters such as:

* Date
* Group
* Member
* Category
* Amount

---

# Smart Features

The following features are planned for future versions.

### UPI / Payment Integration

Allow users to settle outstanding balances using supported digital payment methods such as UPI.

### Recurring Expenses

Automatically handle repeated expenses such as:

* Rent
* Subscriptions
* Electricity
* Internet
* Monthly utilities

### Notifications and Reminders

Notify users about:

* New expenses
* Added group members
* Settlement requests
* Outstanding balances
* Upcoming due dates

### Settlement Due Dates

Allow users to specify deadlines for outstanding payments.

### Categories and Tags

Organize expenses using categories and custom tags.

Example:

```text
Food
Travel
Rent
Entertainment
Shopping
Utilities
```

### Spending Analytics

Provide visual insights into spending patterns.

Users will be able to analyze expenses based on:

* Category
* Group
* Member
* Time period

### Budgets

Users will be able to create:

* Personal budgets
* Group budgets

The application can then track spending against the defined budget.

### PDF / CSV Export

Allow users to export expense records and transaction history for offline use or documentation.

---

# Technology Stack

## Frontend

* **Flutter**
* **Dart**
* **Material Design**

## Authentication & Backend

The backend architecture is planned to support secure authentication and cloud-based data storage.

Potential technologies include:

* REST APIs
* Node.js
* Express.js

## Database

Depending on the final architecture:

* MongoDB

## Development Tools

* Android Studio
* Git
* GitHub
* Flutter SDK
* Dart SDK
* Postman
* Agile Methodology

---

# How FairShare Works

The general expense flow is:

```text
Create / Join Group
        │
        ▼
   Add Members
        │
        ▼
   Add Expense
        │
        ▼
 Select Split Method
        │
        ▼
Calculate Individual Shares
        │
        ▼
 Update Group Balances
        │
        ▼
 Simplify Outstanding Debts
        │
        ▼
     Settle Up
```

For example, if three friends go out for dinner:

```text
Total Bill = ₹1,500

A paid the complete bill.

A → Paid ₹1,500
B → Owes ₹500
C → Owes ₹500

After settlement:

B → A : ₹500
C → A : ₹500
```

FairShare maintains these calculations automatically instead of requiring users to manually track them.

---

# Getting Started

## Prerequisites

Make sure the following are installed:

* Flutter SDK
* Dart SDK
* Android Studio
* Android SDK
* Git

Verify your Flutter installation:

```bash
flutter doctor
```

## Clone the Repository

```bash
git clone https://github.com/<your-username>/fairshare-flutter.git
```

Navigate to the project:

```bash
cd fair_share
```

Install Flutter dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

# Environment Configuration

FairShare uses environment variables for configuration.

Create a `.env` file in the project root:

```env
API_BASE_URL=http://10.0.2.2:8000/api
```

For an Android emulator, `10.0.2.2` can be used to access the development machine's localhost.

---

# Security

FairShare is designed with security in mind.

Sensitive information such as:

* API keys
* Authentication credentials
* Database credentials
* Environment-specific configuration

The project uses `.gitignore` to prevent sensitive configuration files from being uploaded.

---

# Project Status

**Current Status:** `In Development`

FairShare is actively being developed. Features will be implemented incrementally, starting with the core expense-sharing functionality before moving toward advanced payment, analytics, and automation features.

---

# Contributing

This project is primarily developed as an academic project.

Suggestions, improvements, and contributions are welcome.

If you find an issue or have an idea for improving the application, feel free to open an issue or submit a pull request.

---

## Team

This project is developed by:

| Name | Role |
|------|------|
| **Manan Patel** | Developer |
| **Samarth Patel** | Developer |
| **Vedansh Rajput** | Developer |

**B.Tech Computer Engineering**  
**Dharmsinh Desai University**

---
