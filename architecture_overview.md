# Money Follow - Architecture & Technical Overview 📘

This document provides a comprehensive breakdown of the application's architecture, flow, and structural decisions. It is designed to be easily digestible for you and useful as context for external tooling (like NotebookLM) to understand how the system operates under the hood.

---

## 1. Core Architecture Pattern 🏗️
The project uses a modernized **Clean Architecture** inspired structure, heavily utilizing the **BLoC/Cubit** pattern for state management. This isolates the user interface from the business logic, ensuring the UI files remain heavily constrained strictly to rendering widgets (all kept under 60 lines max).

### Why Cubits over Providers or standard BLoC?
- Removed the old `Provider` boilerplate and monolith structures.
- `Cubit` provides a simpler, function-based interface compared to standard `Bloc` events, which is perfectly suited for CRUD operations (Create, Read, Update, Delete) taking place in forms and lists.
- **State Management Design**: The states are simple immutable classes utilizing `copyWith` methods. This is specifically chosen over complex sealed class inheritance structures (like `abstract class HomeState {}`) because forms and pages here require retaining existing data while a single field updates, and `copyWith` is vastly vastly superior and less verbose for this task.

---

## 2. Directory Structure 📁

The `lib/` directory is highly organized by technical and feature bounds:

```text
lib/
├── config/              # Centralized theming and global configurations
├── core/
│   ├── app_lifecycle_manager.dart # Handles app startup, permissions, SMS scanning
│   ├── app_material.dart          # Sets up MaterialApp, localization, and theme
│   ├── app_providers.dart         # MultiBlocProvider injecting dependencies
│   ├── cubit/           # 🧠 The Core Business Logic (Cubit & States) separated by feature
│   └── database/        # Local SQLite database configurations
├── features/            # (Future scale: specialized domain specific code)
├── models/              # Pure Dart objects (IncomeModel, ExpenseModel, etc.)
├── services/            # Device interfacing (Bank SMS, Notifications, Permissions)
├── utils/               # Helpers, formats, localization extensions
└── view/
    ├── pages/           # Strict Page routing & scaffold configurations (< 60 lines)
    └── widgets/         # 🧱 Reusable and extracted UI components separated by their host feature
```

---

## 3. Data Flow & Execution Pipeline 🔄

When a user opens the app or performs an action, the data flows predictably:

1. **System Init (`main.dart`)**:
   - Dart bootstraps, `AppProviders` load all Cubits into the context.
   - `AppLifecycleManager` registers system-level listeners to scan for Bank SMS notifications whenever the app is brought to the foreground.

2. **UI Layer (`view/pages/`)**:
   - The user opens `CommitmentsPage`. It's a clean Scaffold that fires `context.read<CommitmentCubit>().load()` immediately.
   - The UI does **not** query databases. It relies completely on `BlocBuilder` to listen to state shifts.

3. **Logic Layer (`core/cubit/`)**:
   - `CommitmentCubit` receives the `load()` call. It asks the underlying database/repository for the lists of data.
   - It runs the filters (Pending vs Completed) and emits a clean immutable state via `emit(state.copyWith(isLoading: false, allItems: data))`.

4. **Service / DB Layer (`services/` & `database/`)**:
   - Extracts data via standard SQL `SELECT * FROM...` statements. Local `sqflite` ensures speed and persistence.

---

## 4. Key Systems & Modules 🛠️

### **Bank SMS Integration** (`bank_sms_service.dart` & `bank_sms_cubit.dart`)
- **How it works**: Uses Android MethodChannels to scan incoming SMS messages from banking institutions.
- If an SMS matches a Bank deposit/withdrawal signature, the `AppLifecycleManager` prompts the user. If they accept, the service converts the SMS string to an `IncomeModel` or `ExpenseModel` and injects it straight into the database, immediately refreshing the `StatisticsCubit` graph data.

### **Commitment Reminders**
- Relies on flutter_local_notifications. Allows users to establish debts or future payments, and optionally fires local push notifications when the due date arrives.

### **Statistics & Home Analytics**
- The `HomeCubit` and `StatisticsCubit` aggregate rows from the `income_table` and `expense_table`.
- They build memory-mapped categories (e.g., how much spent on "Food" vs "Transport") which is then cleanly passed precisely to the `HomeExpenseChart` PieChart widget without the UI needing to do any math.

---

## 5. Strict Development Constraints enforced 🚫

During the refactoring process, the following strict architectural rules were imposed:
1. **No file exceeding 60 lines** inside the UI directories (Pages & Core). Every large scaffold has been systematically broken down into reusable `view/widgets/`.
2. **Zero Logic in the UI**: `setState()` is actively avoided for core data interactions. Only strictly used for ephemeral component animations. Everything relies on `Cubit`.
3. **No Direct Database Access in Pages**: Legacy code calling `SqlControl()` was completely scrubbed from `view/` to prevent memory leaks and out-of-sync widget bugs.
