# System Architecture & Data Flow

## 
1. Architectural Pattern
The platform utilizes an n-tier architecture to separate system components based on user interactions and data management. The design strictly follows the Model-View-Controller (MVC) pattern to isolate application logic from the user interface.

## 2. Layer Boundaries
| Tier | Responsibility | Output/Tech Boundary |
| :--- | :--- | :--- |
| **Client Tier (Presentation)** | Provides the UI for mobile and web, ensuring accessibility for users with minimal tech skills. | Frontend components, forms, multimedia players. |
| **Application Tier (Logic)** | Hosts the web/application server handling business logic, user authentication, and AI service processing. | API endpoints, controllers, auth middleware. |
| **Data Tier (Storage)** | Manages structured data access and acts as a file server for digital assets (images, audio). | Database schemas, file storage structures. |

## 3. Data Flow
1.  **Request Initiation**: Client sends a request via the View.
2.  **Processing**: The Controller receives the request, processes business logic, and interacts with the Model.
3.  **Data Retrieval**: The Model queries the SQLite database or file server for content.
4.  **Response Delivery**: The View uses the data prepared by the Controller to render the final response to the user.

## 4. Mandatory Folder Structure
african-teller/
│
├── client/                              # Flutter Client Project
│   ├── android/
│   ├── ios/
│   ├── web/
│   └── lib/
│       ├── core/                        # Global utils, theme, network client, database helper
│       │   ├── database/                # Local SQLite (sqflite) configuration & migrations
│       │   ├── network/                 # Dio client, API endpoints, Interceptors (JWT)
│       │   ├── theme/                   # "Ancient Manuscript" UI themes & assets
│       │   └── utils/                   # QR scanner utilities, audio player helpers
│       ├── features/                    # Modular feature-first architecture
│       │   ├── authentication/          # Login, Register, Roles
│       │   │   ├── data/                # Models, Repositories, API providers
│       │   │   ├── domain/              # Entities, Use cases
│       │   │   └── presentation/        # Screens, Widgets, State (Bloc/Riverpod)
│       │   ├── stories/                 # Story discovery, detail view, audio player
│       │   ├── qr_engine/               # QR Code generator/scanner widgets
│       │   ├── gamification/            # Quizzes, badges, score tracking
│       │   └── management/              # Admin/Contributor contribution screens
│       └── main.dart
│
├── server/                              # Django Backend Project
│   ├── manage.py
│   ├── db.sqlite3                       # Development Server SQLite DB
│   ├── media/                           # User-uploaded audio, video, images
│   ├── config/                          # Project configuration
│   │   ├── settings/                    # base.py, dev.py, prod.py
│   │   ├── urls.py                      # Root API Router
│   │   └── wsgi.py
│   └── apps/                            # Modular Django Applications
│       ├── users/                       # Custom User model, Roles (Visitor, Contributor, Manager, Admin)
│       ├── stories/                     # Story model, Categories, Media assets, AI pipelines
│       ├── qr_codes/                    # QR generation logic & artifact mapping
│       ├── gamification/                # Quizzes, Points, User Badges
│       └── api/                         # Centralized DRF Routers & Serializers
│
└── docs/                                # Project Governance Documentation
    ├── PRD.md
    ├── Architecture.md
    ├── Decisions.md
    ├── agents.md
    └── Task.md